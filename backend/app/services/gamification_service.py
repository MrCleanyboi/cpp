from datetime import datetime
from typing import List, Dict, Optional
from bson import ObjectId

from app.database import db
from app.models.user_gamification import (
    UserGamification,
    calculate_level_from_xp,
    xp_required_for_next_level,
    can_refill_hearts_for_free,
    next_heart_refill_time,
    MAX_HEARTS,
    HEARTS_REFILL_GEM_COST,
    XP_REWARDS
)
from app.models.achievements import check_achievements, get_achievement_by_id
from app.models.leaderboard import LeaderboardEntry, get_current_week_start, get_current_month_start


class GamificationService:
    """Service for handling all gamification logic"""
    
    @staticmethod
    async def get_or_create_user_gamification(user_id: str) -> UserGamification:
        """Get user gamification data or create if doesn't exist"""
        user_obj_id = ObjectId(user_id)
        
        # Try to find existing gamification data
        gam_data = await db.user_gamifications.find_one({"user_id": user_obj_id})
        
        if gam_data:
            return UserGamification(**gam_data)
        
        # Create new gamification data
        new_gam = UserGamification(user_id=user_obj_id)
        result = await db.user_gamifications.insert_one(new_gam.dict(by_alias=True, exclude={'id'}))
        new_gam.id = result.inserted_id
        
        return new_gam
    
    @staticmethod
    async def award_xp(user_id: str, xp_amount: int, reason: str = "") -> Dict:
        """
        Award XP to a user and check for level ups and achievements.
        
        Returns:
            Dictionary with updates (xp_gained, old_level, new_level, achievements_earned)
        """
        gam = await GamificationService.get_or_create_user_gamification(user_id)
        
        old_xp = gam.xp
        old_level = gam.level
        
        # Add XP
        gam.xp += xp_amount
        gam.level = calculate_level_from_xp(gam.xp)
        gam.updated_at = datetime.utcnow()
        
        # Update daily XP
        if not gam.daily_goal_last_reset or gam.daily_goal_last_reset.date() < datetime.utcnow().date():
            # New day, reset daily XP
            gam.daily_xp_earned = xp_amount
            gam.daily_goal_last_reset = datetime.utcnow()
        else:
            gam.daily_xp_earned += xp_amount
        
        # Check if daily goal met
        daily_goal_met = False
        if gam.daily_xp_earned >= gam.daily_goal_xp:
            if not hasattr(gam, '_daily_goal_already_met_today'):
                daily_goal_met = True
                gam.daily_goal_streak += 1
        
        # Check for achievements
        user_stats = {
            'lessons_completed': gam.total_lessons_completed,
            'streak_count': gam.streak_count,
            'level': gam.level,
            'friends_count': 0,  # Will be updated when we implement social
            'perfect_lessons': gam.achievements_progress.get('perfect_lessons', 0),
            'daily_goal_streak': gam.daily_goal_streak,
            'earned_achievements': gam.achievements,
            'current_hour': datetime.utcnow().hour
        }
        
        newly_earned_achievements = check_achievements(user_stats)
        
        # Award achievement rewards
        for achievement in newly_earned_achievements:
            gam.achievements.append(achievement.id)
            gam.xp += achievement.xp_reward
            gam.gems += achievement.gem_reward
        
        # Recalculate level in case achievement XP caused level up
        gam.level = calculate_level_from_xp(gam.xp)
        
        # Save to database
        await db.user_gamifications.update_one(
            {"user_id": ObjectId(user_id)},
            {"$set": gam.dict(by_alias=True, exclude={'id'})}
        )
        
        return {
            "xp_gained": xp_amount,
            "total_xp": gam.xp,
            "old_level": old_level,
            "new_level": gam.level,
            "level_up": gam.level > old_level,
            "xp_to_next_level": xp_required_for_next_level(gam.level) - gam.xp,
            "achievements_earned": [
                {
                    "id": a.id,
                    "title": a.title,
                    "description": a.description,
                    "xp_reward": a.xp_reward,
                    "gem_reward": a.gem_reward,
                    "icon": a.icon
                } for a in newly_earned_achievements
            ],
            "daily_goal_met": daily_goal_met,
            "gems": gam.gems
        }
    
    @staticmethod
    async def update_streak(user_id: str) -> Dict:
        """
        Update user's streak based on practice activity.
        Called when user completes a lesson.
        
        Returns:
            Dictionary with streak info
        """
        gam = await GamificationService.get_or_create_user_gamification(user_id)
        
        today = datetime.utcnow().date()
        
        # First time practicing
        if not gam.last_practice_date:
            gam.streak_count = 1
            gam.longest_streak = 1
            gam.last_practice_date = datetime.utcnow()
        else:
            last_practice = gam.last_practice_date.date()
            
            # Practiced yesterday - continue streak
            if (today - last_practice).days == 1:
                gam.streak_count += 1
                if gam.streak_count > gam.longest_streak:
                    gam.longest_streak = gam.streak_count
                gam.last_practice_date = datetime.utcnow()
                
                # Check for streak milestone achievements
                if gam.streak_count == 7:
                    await GamificationService.award_xp(user_id, XP_REWARDS['streak_milestone_7'], "7-day streak")
                elif gam.streak_count == 30:
                    await GamificationService.award_xp(user_id, XP_REWARDS['streak_milestone_30'], "30-day streak")
                elif gam.streak_count == 100:
                    await GamificationService.award_xp(user_id, XP_REWARDS['streak_milestone_100'], "100-day streak")
            
            # Practiced today already - just update timestamp
            elif last_practice == today:
                gam.last_practice_date = datetime.utcnow()
            
            # Missed a day - streak broken
            elif (today - last_practice).days > 1:
                gam.streak_count = 1
                gam.last_practice_date = datetime.utcnow()
        
        gam.updated_at = datetime.utcnow()
        
        await db.user_gamifications.update_one(
            {"user_id": ObjectId(user_id)},
            {"$set": gam.dict(by_alias=True, exclude={'id'})}
        )
        
        return {
            "streak_count": gam.streak_count,
            "longest_streak": gam.longest_streak,
            "last_practice_date": gam.last_practice_date.isoformat()
        }
    
    @staticmethod
    async def lose_heart(user_id: str) -> Dict:
        """
        Deduct a heart when user makes a mistake.
        
        Returns:
            Dictionary with hearts info
        """
        gam = await GamificationService.get_or_create_user_gamification(user_id)
        
        if gam.hearts > 0:
            gam.hearts -= 1
            
            # Set refill timer if this was the last heart
            if gam.hearts == 0 and not gam.hearts_refill_time:
                gam.hearts_refill_time = next_heart_refill_time()
            
            gam.updated_at = datetime.utcnow()
            
            await db.user_gamifications.update_one(
                {"user_id": ObjectId(user_id)},
                {"$set": gam.dict(by_alias=True, exclude={'id'})}
            )
        
        return {
            "hearts": gam.hearts,
            "max_hearts": MAX_HEARTS,
            "can_practice": gam.hearts > 0,
            "hearts_refill_time": gam.hearts_refill_time.isoformat() if gam.hearts_refill_time else None
        }
    
    @staticmethod
    async def refill_hearts(user_id: str, use_gems: bool = False) -> Dict:
        """
        Refill hearts either for free (time-based) or using gems.
        
        Args:
            user_id: User ID
            use_gems: If True, spend gems to refill immediately
        
        Returns:
            Dictionary with hearts info and success status
        """
        gam = await GamificationService.get_or_create_user_gamification(user_id)
        
        # Free refill (time-based)
        if not use_gems:
            if can_refill_hearts_for_free(gam.hearts_refill_time):
                gam.hearts = MAX_HEARTS
                gam.hearts_refill_time = None
                success = True
            else:
                return {
                    "success": False,
                    "reason": "Hearts refill time not reached",
                    "hearts": gam.hearts,
                    "hearts_refill_time": gam.hearts_refill_time.isoformat() if gam.hearts_refill_time else None
                }
        
        # Gem-based refill
        else:
            if gam.gems >= HEARTS_REFILL_GEM_COST:
                gam.hearts = MAX_HEARTS
                gam.gems -= HEARTS_REFILL_GEM_COST
                gam.hearts_refill_time = None
                success = True
            else:
                return {
                    "success": False,
                    "reason": "Not enough gems",
                    "hearts": gam.hearts,
                    "gems": gam.gems,
                    "gems_required": HEARTS_REFILL_GEM_COST
                }
        
        gam.updated_at = datetime.utcnow()
        
        await db.user_gamifications.update_one(
            {"user_id": ObjectId(user_id)},
            {"$set": gam.dict(by_alias=True, exclude={'id'})}
        )
        
        return {
            "success": True,
            "hearts": gam.hearts,
            "gems": gam.gems,
            "gems_spent": HEARTS_REFILL_GEM_COST if use_gems else 0
        }
    
    @staticmethod
    async def complete_lesson(user_id: str, lesson_id: str = None, perfect: bool = False, time_spent_minutes: int = 0) -> Dict:
        """
        Handle lesson completion with all gamification updates.
        
        Args:
            user_id: User ID
            lesson_id: Lesson identifier (e.g., 'fr_beginner_1_1')
            perfect: True if lesson completed with no mistakes
            time_spent_minutes: Time spent on lesson
        
        Returns:
            Dictionary with XP gained, achievements, level up info
        """
        gam = await GamificationService.get_or_create_user_gamification(user_id)
        
        # Calculate XP reward
        base_xp = XP_REWARDS['lesson_completion']
        perfect_bonus = XP_REWARDS['perfect_lesson'] if perfect else 0
        speed_bonus = XP_REWARDS['quick_lesson'] if time_spent_minutes <= 5 else 0
        
        total_xp = base_xp + perfect_bonus + speed_bonus
        
        # Update total lessons completed (cross-language)
        gam.total_lessons_completed += 1
        
        # Update perfect lesson count for achievements
        if perfect:
            if 'perfect_lessons' not in gam.achievements_progress:
                gam.achievements_progress['perfect_lessons'] = 0
            gam.achievements_progress['perfect_lessons'] += 1
        
        # Track per-language progress if lesson_id provided
        if lesson_id:
            # Extract language code from lesson_id (e.g., 'fr' from 'fr_beginner_1_1')
            lang_code = lesson_id.split('_')[0] if '_' in lesson_id else 'en'
            
            # Get user document to update language_progress
            user = await db.users.find_one({"_id": ObjectId(user_id)})
            if user:
                language_progress = user.get('language_progress', {})
                
                # Initialize language progress if doesn't exist
                if lang_code not in language_progress:
                    language_progress[lang_code] = {
                        'completed_lessons': [],
                        'xp': 0,
                        'current_lesson': None
                    }
                
                # Add lesson to completed if not already there
                if lesson_id not in language_progress[lang_code].get('completed_lessons', []):
                    language_progress[lang_code]['completed_lessons'].append(lesson_id)
                
                # Add XP to language-specific progress
                language_progress[lang_code]['xp'] = language_progress[lang_code].get('xp', 0) + total_xp
                
                # Update user's language_progress
                await db.users.update_one(
                    {"_id": ObjectId(user_id)},
                    {"$set": {"language_progress": language_progress}}
                )
        
        # Award XP (this handles level ups and achievements)
        xp_result = await GamificationService.award_xp(user_id, total_xp, "lesson_completion")
        
        # Update streak
        streak_result = await GamificationService.update_streak(user_id)
        
        # Save gamification updates
        gam.updated_at = datetime.utcnow()
        await db.user_gamifications.update_one(
            {"user_id": ObjectId(user_id)},
            {"$set": gam.dict(by_alias=True, exclude={'id'})}
        )
        
        # Refresh gam data after all updates
        gam = await GamificationService.get_or_create_user_gamification(user_id)
        
        return {
            **xp_result,
            **streak_result,
            "lessons_completed": gam.total_lessons_completed,
            "perfect": perfect
        }
    
    @staticmethod
    async def get_leaderboard(leaderboard_type: str = "weekly", user_id: Optional[str] = None, limit: int = 50) -> List[LeaderboardEntry]:
        """
        Get leaderboard entries.
        
        Args:
            leaderboard_type: "weekly", "monthly", or "all_time"
            user_id: If provided, also return user's rank even if not in top
            limit: Maximum number of entries to return
        
        Returns:
            List of leaderboard entries
        """
        # Determine date range
        if leaderboard_type == "weekly":
            start_date = get_current_week_start()
        elif leaderboard_type == "monthly":
            start_date = get_current_month_start()
        else:  # all_time
            start_date = datetime.min
        
        # Get all user gamification data
        gamifications = await db.user_gamifications.find({}).to_list(length=None)
        
        # Get user data for display names
        user_ids = [g['user_id'] for g in gamifications]
        users = await db.users.find({"_id": {"$in": user_ids}}).to_list(length=None)
        user_map = {str(u['_id']): u for u in users}
        
        # Create leaderboard entries
        entries = []
        for gam_data in gamifications:
            user_id_str = str(gam_data['user_id'])
            user = user_map.get(user_id_str, {})
            
            # Filter by date if needed (for weekly/monthly)
            if leaderboard_type != "all_time":
                created_at = gam_data.get('created_at', datetime.min)
                if created_at < start_date:
                    # For time-limited leaderboards, we'd need to track XP per period
                    # For now, using total XP as approximation
                    pass
            
            entries.append(LeaderboardEntry(
                user_id=gam_data['user_id'],
                username=user.get('username', 'Unknown'),
                display_name=user.get('display_name', user.get('username', 'Unknown')),
                avatar_url=user.get('avatar_url'),
                xp=gam_data.get('xp', 0),
                level=gam_data.get('level', 1),
                rank=0  # Will be set below
            ))
        
        # Sort by XP (descending)
        entries.sort(key=lambda x: x.xp, reverse=True)
        
        # Assign ranks
        for i, entry in enumerate(entries):
            entry.rank = i + 1
        
        # Return top N
        return entries[:limit]
    
    @staticmethod
    async def get_user_profile(user_id: str) -> Dict:
        """Get comprehensive user gamification profile"""
        gam = await GamificationService.get_or_create_user_gamification(user_id)
        
        # Get user data
        user = await db.users.find_one({"_id": ObjectId(user_id)})
        
        return {
            "user_id": user_id,
            "username": user.get('username', 'Unknown') if user else 'Unknown',
            "display_name": user.get('display_name', user.get('username', 'Unknown')) if user else 'Unknown',
            "avatar_url": user.get('avatar_url') if user else None,
            "xp": gam.xp,
            "level": gam.level,
            "xp_to_next_level": xp_required_for_next_level(gam.level) - gam.xp,
            "streak_count": gam.streak_count,
            "longest_streak": gam.longest_streak,
            "gems": gam.gems,
            "hearts": gam.hearts,
            "max_hearts": MAX_HEARTS,
            "hearts_refill_time": gam.hearts_refill_time.isoformat() if gam.hearts_refill_time else None,
            "daily_goal_xp": gam.daily_goal_xp,
            "daily_xp_earned": gam.daily_xp_earned,
            "daily_goal_met": gam.daily_xp_earned >= gam.daily_goal_xp,
            "achievements": gam.achievements,
            "achievements_count": len(gam.achievements),
            "total_lessons_completed": gam.total_lessons_completed,
            "total_time_minutes": gam.total_time_minutes
        }


# Singleton instance
gamification_service = GamificationService()
