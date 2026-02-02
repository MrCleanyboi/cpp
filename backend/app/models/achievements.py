from datetime import datetime
from typing import List, Optional, Dict
from pydantic import BaseModel, Field
from enum import Enum


class AchievementCategory(str, Enum):
    """Achievement categories"""
    LESSONS = "lessons"
    STREAKS = "streaks"
    SOCIAL = "social"
    MILESTONES = "milestones"
    PERFECT = "perfect"
    SPEED = "speed"


class AchievementTier(str, Enum):
    """Achievement tiers (for rarity/difficulty)"""
    BRONZE = "bronze"
    SILVER = "silver"
    GOLD = "gold"
    PLATINUM = "platinum"
    DIAMOND = "diamond"


class Achievement(BaseModel):
    """Achievement definition"""
    id: str  # Unique identifier (e.g., "first_lesson", "streak_7")
    title: str
    description: str
    category: AchievementCategory
    tier: AchievementTier
    icon: str  # Icon name or emoji
    
    # Requirements
    requirement_type: str  # "count", "streak", "perfect", etc.
    requirement_value: int  # Target value
    
    # Rewards
    xp_reward: int
    gem_reward: int
    
    # Display
    is_secret: bool = False  # Secret achievements (hidden until unlocked)
    
    class Config:
        use_enum_values = True


# Pre-defined achievements
ACHIEVEMENTS_LIBRARY: List[Achievement] = [
    # Lesson Achievements
    Achievement(
        id="first_lesson",
        title="First Steps",
        description="Complete your first lesson",
        category=AchievementCategory.LESSONS,
        tier=AchievementTier.BRONZE,
        icon="🎯",
        requirement_type="lessons_completed",
        requirement_value=1,
        xp_reward=10,
        gem_reward=5
    ),
    Achievement(
        id="lessons_10",
        title="Dedicated Learner",
        description="Complete 10 lessons",
        category=AchievementCategory.LESSONS,
        tier=AchievementTier.BRONZE,
        icon="📚",
        requirement_type="lessons_completed",
        requirement_value=10,
        xp_reward=25,
        gem_reward=10
    ),
    Achievement(
        id="lessons_50",
        title="Knowledge Seeker",
        description="Complete 50 lessons",
        category=AchievementCategory.LESSONS,
        tier=AchievementTier.SILVER,
        icon="🎓",
        requirement_type="lessons_completed",
        requirement_value=50,
        xp_reward=50,
        gem_reward=25
    ),
    Achievement(
        id="lessons_100",
        title="Master Student",
        description="Complete 100 lessons",
        category=AchievementCategory.LESSONS,
        tier=AchievementTier.GOLD,
        icon="👑",
        requirement_type="lessons_completed",
        requirement_value=100,
        xp_reward=100,
        gem_reward=50
    ),
    
    # Streak Achievements
    Achievement(
        id="streak_3",
        title="Getting Started",
        description="Maintain a 3-day streak",
        category=AchievementCategory.STREAKS,
        tier=AchievementTier.BRONZE,
        icon="🔥",
        requirement_type="streak_count",
        requirement_value=3,
        xp_reward=15,
        gem_reward=5
    ),
    Achievement(
        id="streak_7",
        title="Week Warrior",
        description="Maintain a 7-day streak",
        category=AchievementCategory.STREAKS,
        tier=AchievementTier.SILVER,
        icon="⚡",
        requirement_type="streak_count",
        requirement_value=7,
        xp_reward=30,
        gem_reward=15
    ),
    Achievement(
        id="streak_30",
        title="Monthly Master",
        description="Maintain a 30-day streak",
        category=AchievementCategory.STREAKS,
        tier=AchievementTier.GOLD,
        icon="💪",
        requirement_type="streak_count",
        requirement_value=30,
        xp_reward=75,
        gem_reward=40
    ),
    Achievement(
        id="streak_100",
        title="Unstoppable",
        description="Maintain a 100-day streak",
        category=AchievementCategory.STREAKS,
        tier=AchievementTier.DIAMOND,
        icon="💎",
        requirement_type="streak_count",
        requirement_value=100,
        xp_reward=200,
        gem_reward=100
    ),
    
    # Perfect Achievements
    Achievement(
        id="perfect_lesson_1",
        title="Flawless",
        description="Complete a lesson with no mistakes",
        category=AchievementCategory.PERFECT,
        tier=AchievementTier.BRONZE,
        icon="✨",
        requirement_type="perfect_lessons",
        requirement_value=1,
        xp_reward=15,
        gem_reward=5
    ),
    Achievement(
        id="perfect_lesson_10",
        title="Perfectionist",
        description="Complete 10 lessons with no mistakes",
        category=AchievementCategory.PERFECT,
        tier=AchievementTier.SILVER,
        icon="⭐",
        requirement_type="perfect_lessons",
        requirement_value=10,
        xp_reward=40,
        gem_reward=20
    ),
    
    # Milestone Achievements
    Achievement(
        id="level_5",
        title="Rising Star",
        description="Reach level 5",
        category=AchievementCategory.MILESTONES,
        tier=AchievementTier.BRONZE,
        icon="🌟",
        requirement_type="level",
        requirement_value=5,
        xp_reward=20,
        gem_reward=10
    ),
    Achievement(
        id="level_10",
        title="Expert Learner",
        description="Reach level 10",
        category=AchievementCategory.MILESTONES,
        tier=AchievementTier.SILVER,
        icon="🏆",
        requirement_type="level",
        requirement_value=10,
        xp_reward=50,
        gem_reward=25
    ),
    Achievement(
        id="level_25",
        title="Language Legend",
        description="Reach level 25",
        category=AchievementCategory.MILESTONES,
        tier=AchievementTier.GOLD,
        icon="🥇",
        requirement_type="level",
        requirement_value=25,
        xp_reward=100,
        gem_reward=50
    ),
    
    # Social Achievements
    Achievement(
        id="first_friend",
        title="Social Butterfly",
        description="Add your first friend",
        category=AchievementCategory.SOCIAL,
        tier=AchievementTier.BRONZE,
        icon="👥",
        requirement_type="friends_count",
        requirement_value=1,
        xp_reward=10,
        gem_reward=5
    ),
    Achievement(
        id="friends_5",
        title="Popular Learner",
        description="Add 5 friends",
        category=AchievementCategory.SOCIAL,
        tier=AchievementTier.SILVER,
        icon="🎉",
        requirement_type="friends_count",
        requirement_value=5,
        xp_reward=25,
        gem_reward=15
    ),
    
    # Daily Goal Achievements
    Achievement(
        id="daily_goal_7",
        title="Goal Getter",
        description="Meet your daily goal 7 days in a row",
        category=AchievementCategory.MILESTONES,
        tier=AchievementTier.SILVER,
        icon="🎯",
        requirement_type="daily_goal_streak",
        requirement_value=7,
        xp_reward=35,
        gem_reward=20
    ),
    Achievement(
        id="daily_goal_30",
        title="Consistent Champion",
        description="Meet your daily goal 30 days in a row",
        category=AchievementCategory.MILESTONES,
        tier=AchievementTier.GOLD,
        icon="🏅",
        requirement_type="daily_goal_streak",
        requirement_value=30,
        xp_reward=100,
        gem_reward=50
    ),
    
    # Secret Achievements
    Achievement(
        id="night_owl",
        title="Night Owl",
        description="Complete a lesson after midnight",
        category=AchievementCategory.MILESTONES,
        tier=AchievementTier.BRONZE,
        icon="🦉",
        requirement_type="special",
        requirement_value=1,
        xp_reward=10,
        gem_reward=5,
        is_secret=True
    ),
    Achievement(
        id="early_bird",
        title="Early Bird",
        description="Complete a lesson before 6 AM",
        category=AchievementCategory.MILESTONES,
        tier=AchievementTier.BRONZE,
        icon="🐦",
        requirement_type="special",
        requirement_value=1,
        xp_reward=10,
        gem_reward=5,
        is_secret=True
    ),
]


def get_achievement_by_id(achievement_id: str) -> Optional[Achievement]:
    """Get achievement definition by ID"""
    for achievement in ACHIEVEMENTS_LIBRARY:
        if achievement.id == achievement_id:
            return achievement
    return None


def get_achievements_by_category(category: AchievementCategory) -> List[Achievement]:
    """Get all achievements in a category"""
    return [a for a in ACHIEVEMENTS_LIBRARY if a.category == category]


def check_achievements(user_stats: Dict) -> List[Achievement]:
    """
    Check which achievements a user has earned based on their stats.
    
    Args:
        user_stats: Dictionary containing user statistics
            - lessons_completed: int
            - streak_count: int
            - level: int
            - friends_count: int
            - perfect_lessons: int
            - daily_goal_streak: int
            - current_hour: int (for special achievements)
    
    Returns:
        List of newly earned achievements
    """
    newly_earned = []
    
    for achievement in ACHIEVEMENTS_LIBRARY:
        # Skip if already earned
        if achievement.id in user_stats.get('earned_achievements', []):
            continue
        
        # Check requirement
        requirement_met = False
        
        if achievement.requirement_type in user_stats:
            stat_value = user_stats[achievement.requirement_type]
            requirement_met = stat_value >= achievement.requirement_value
        
        # Special achievements
        elif achievement.requirement_type == "special":
            if achievement.id == "night_owl":
                requirement_met = user_stats.get('current_hour', 12) >= 0 and user_stats.get('current_hour', 12) < 6
            elif achievement.id == "early_bird":
                requirement_met = user_stats.get('current_hour', 12) >= 4 and user_stats.get('current_hour', 12) < 6
        
        if requirement_met:
            newly_earned.append(achievement)
    
    return newly_earned
