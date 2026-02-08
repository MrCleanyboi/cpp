from fastapi import APIRouter, HTTPException, Query
from typing import Optional
from pydantic import BaseModel

from app.services.gamification_service import gamification_service
from app.models.achievements import ACHIEVEMENTS_LIBRARY

router = APIRouter(prefix="/api/gamification", tags=["gamification"])


# Request/Response Models
class AwardXPRequest(BaseModel):
    user_id: str
    xp_amount: int
    reason: Optional[str] = ""


class LessonCompleteRequest(BaseModel):
    user_id: str
    perfect: bool = False
    time_spent_minutes: int = 0


class RefillHeartsRequest(BaseModel):
    user_id: str
    use_gems: bool = False


class LoseHeartRequest(BaseModel):
    user_id: str


# Routes
@router.get("/profile")
async def get_user_profile(user_id: str = Query(..., description="User ID")):
    """Get comprehensive user gamification profile"""
    try:
        profile = await gamification_service.get_user_profile(user_id)
        return {"status": "success", "data": profile}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/xp")
async def award_xp(request: AwardXPRequest):
    """Award XP to a user"""
    try:
        result = await gamification_service.award_xp(
            request.user_id,
            request.xp_amount,
            request.reason
        )
        return {"status": "success", "data": result}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/lesson/complete")
async def complete_lesson(request: LessonCompleteRequest):
    """Handle lesson completion with all gamification updates"""
    try:
        result = await gamification_service.complete_lesson(
            request.user_id,
            request.perfect,
            request.time_spent_minutes
        )
        return {"status": "success", "data": result}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/hearts/lose")
async def lose_heart(request: LoseHeartRequest):
    """Deduct a heart when user makes a mistake"""
    try:
        result = await gamification_service.lose_heart(request.user_id)
        return {"status": "success", "data": result}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/hearts/refill")
async def refill_hearts(request: RefillHeartsRequest):
    """Refill hearts (free or with gems)"""
    try:
        result = await gamification_service.refill_hearts(
            request.user_id,
            request.use_gems
        )
        return {"status": "success", "data": result}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/achievements")
async def get_achievements(user_id: str = Query(..., description="User ID")):
    """Get all achievements and user's progress"""
    try:
        # Get user's earned achievements
        profile = await gamification_service.get_user_profile(user_id)
        earned_achievement_ids = profile['achievements']
        
        # Format all achievements
        achievements = []
        for achievement in ACHIEVEMENTS_LIBRARY:
            achievements.append({
                "id": achievement.id,
                "title": achievement.title,
                "description": achievement.description,
                "category": achievement.category,
                "tier": achievement.tier,
                "icon": achievement.icon,
                "xp_reward": achievement.xp_reward,
                "gem_reward": achievement.gem_reward,
                "is_secret": achievement.is_secret,
                "earned": achievement.id in earned_achievement_ids
            })
        
        return {
            "status": "success",
            "data": {
                "achievements": achievements,
                "total_earned": len(earned_achievement_ids),
                "total_available": len(ACHIEVEMENTS_LIBRARY)
            }
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/leaderboard")
async def get_leaderboard(
    leaderboard_type: str = Query("weekly", description="Type of leaderboard: weekly, monthly, all_time"),
    user_id: Optional[str] = Query(None, description="User ID to include even if not in top"),
    limit: int = Query(50, description="Number of entries to return", le=100)
):
    """Get leaderboard data"""
    try:
        if leaderboard_type not in ["weekly", "monthly", "all_time"]:
            raise HTTPException(status_code=400, detail="Invalid leaderboard type")
        
        entries = await gamification_service.get_leaderboard(
            leaderboard_type,
            user_id,
            limit
        )
        
        # Convert to dict
        entries_data = [
            {
                "user_id": str(entry.user_id),
                "username": entry.username,
                "display_name": entry.display_name,
                "avatar_url": entry.avatar_url,
                "xp": entry.xp,
                "level": entry.level,
                "rank": entry.rank
            }
            for entry in entries
        ]
        
        # Find current user's rank if provided
        user_rank = None
        if user_id:
            for entry in entries_data:
                if entry["user_id"] == user_id:
                    user_rank = entry["rank"]
                    break
        
        return {
            "status": "success",
            "data": {
                "type": leaderboard_type,
                "entries": entries_data,
                "user_rank": user_rank,
                "total_entries": len(entries_data)
            }
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/streak/update")
async def update_streak(user_id: str = Query(..., description="User ID")):
    """Update user's streak (called on lesson completion)"""
    try:
        result = await gamification_service.update_streak(user_id)
        return {"status": "success", "data": result}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
