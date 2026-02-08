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


class LeaderboardEntry(BaseModel):
    """Individual entry in a leaderboard"""
    user_id: PyObjectId
    username: str
    display_name: str
    avatar_url: Optional[str] = None
    xp: int
    level: int
    rank: int
    
    class Config:
        arbitrary_types_allowed = True
        json_encoders = {ObjectId: str}


class Leaderboard(BaseModel):
    """Leaderboard model"""
    id: Optional[PyObjectId] = Field(default_factory=PyObjectId, alias="_id")
    type: str  # "weekly", "monthly", "all_time"
    start_date: datetime
    end_date: Optional[datetime] = None
    entries: List[LeaderboardEntry] = []
    
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)
    
    class Config:
        arbitrary_types_allowed = True
        json_encoders = {ObjectId: str}
        populate_by_name = True


def get_current_week_start() -> datetime:
    """Get the start of the current week (Monday 00:00:00)"""
    now = datetime.utcnow()
    # Monday is 0, Sunday is 6
    days_since_monday = now.weekday()
    monday = now - timedelta(days=days_since_monday)
    return monday.replace(hour=0, minute=0, second=0, microsecond=0)


def get_current_month_start() -> datetime:
    """Get the start of the current month (1st day 00:00:00)"""
    now = datetime.utcnow()
    return now.replace(day=1, hour=0, minute=0, second=0, microsecond=0)


def is_friend_leaderboard_eligible(user_friends: List[str], leaderboard_user_id: str) -> bool:
    """Check if a user should appear in friend leaderboard"""
    return leaderboard_user_id in user_friends
