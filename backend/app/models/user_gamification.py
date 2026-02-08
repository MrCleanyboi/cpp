from datetime import datetime, timedelta
from typing import List, Optional, Any
from bson import ObjectId
from pydantic import BaseModel, Field
from pydantic_core import core_schema


class PyObjectId(ObjectId):
    """Custom ObjectId for Pydantic v2 models"""
    
    @classmethod
    def __get_pydantic_core_schema__(cls, source_type: Any, handler):
        return core_schema.union_schema([
            core_schema.is_instance_schema(ObjectId),
            core_schema.no_info_plain_validator_function(cls.validate),
        ], serialization=core_schema.plain_serializer_function_ser_schema(str))

    @classmethod
    def validate(cls, v):
        if isinstance(v, ObjectId):
            return v
        if isinstance(v, str) and ObjectId.is_valid(v):
            return ObjectId(v)
        raise ValueError("Invalid ObjectId")


class UserGamification(BaseModel):
    """User gamification data model"""
    id: Optional[PyObjectId] = Field(default_factory=PyObjectId, alias="_id")
    user_id: PyObjectId
    
    # XP and Level System
    xp: int = 0
    level: int = 1
    
    # Streak System
    streak_count: int = 0
    last_practice_date: Optional[datetime] = None
    longest_streak: int = 0
    
    # Virtual Currency
    gems: int = 0
    
    # Hearts/Lives System
    hearts: int = 5  # Max 5 hearts
    hearts_refill_time: Optional[datetime] = None
    
    # Achievements
    achievements: List[str] = []  # List of achievement IDs
    achievements_progress: dict = {}  # Track progress toward achievements
    
    # Daily Goals
    daily_goal_xp: int = 20  # Default daily goal
    daily_xp_earned: int = 0
    daily_goal_last_reset: Optional[datetime] = None
    daily_goal_streak: int = 0  # Consecutive days meeting goal
    
    # Statistics
    total_lessons_completed: int = 0
    total_time_minutes: int = 0
    
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    class Config:
        arbitrary_types_allowed = True
        json_encoders = {ObjectId: str}
        populate_by_name = True


class GamificationUpdate(BaseModel):
    """Model for updating gamification data"""
    xp_earned: Optional[int] = None
    hearts_lost: Optional[int] = None
    gems_earned: Optional[int] = None
    lesson_completed: Optional[bool] = None
    time_spent_minutes: Optional[int] = None


# XP Calculation Constants
XP_REWARDS = {
    'lesson_complete': 10,
    'perfect_lesson': 15,  # No mistakes
    'daily_goal_met': 5,
    'streak_milestone_7': 20,
    'streak_milestone_30': 50,
    'streak_milestone_100': 100,
    'first_lesson': 10,
    'chat_message': 1,  # Small XP for AI chat
}

# Level Progression
def calculate_level_from_xp(xp: int) -> int:
    """Calculate level based on total XP using a progressive formula"""
    # Level 1: 0 XP
    # Level 2: 50 XP
    # Level 3: 150 XP, etc. (progressive difficulty)
    if xp < 50:
        return 1
    
    level = 1
    xp_required = 0
    xp_per_level = 50
    
    while xp_required + xp_per_level <= xp:
        xp_required += xp_per_level
        level += 1
        xp_per_level = int(xp_per_level * 1.1)  # 10% increase per level
    
    return level


def xp_required_for_next_level(current_level: int) -> int:
    """Calculate XP required to reach next level from current level"""
    xp = 0
    xp_per_level = 50
    
    for _ in range(current_level):
        xp += xp_per_level
        xp_per_level = int(xp_per_level * 1.1)
    
    return xp


# Hearts Refill Constants
HEARTS_REFILL_TIME_MINUTES = 30
HEARTS_REFILL_GEM_COST = 50
MAX_HEARTS = 5


def can_refill_hearts_for_free(refill_time: Optional[datetime]) -> bool:
    """Check if hearts can be refilled for free (time-based)"""
    if not refill_time:
        return True
    return datetime.utcnow() >= refill_time


def next_heart_refill_time() -> datetime:
    """Calculate next free heart refill time"""
    return datetime.utcnow() + timedelta(minutes=HEARTS_REFILL_TIME_MINUTES)
