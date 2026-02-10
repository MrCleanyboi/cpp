from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime
from bson import ObjectId

class MatchPreferences(BaseModel):
    """User preferences for matching"""
    practice_mode: str = "conversation"  # "conversation", "tutoring", "casual"
    topics: List[str] = Field(default_factory=list)
    
    class Config:
        json_schema_extra = {
            "example": {
                "practice_mode": "conversation",
                "topics": ["travel", "food", "culture"]
            }
        }

class WaitingQueueEntry(BaseModel):
    """Document stored in waiting_queue collection"""
    id: Optional[str] = Field(alias="_id", default=None)
    user_id: str
    username: str
    display_name: str
    avatar_url: Optional[str] = None
    
    # Language preferences
    native_language: str
    target_language: str
    proficiency_level: str  # "Beginner", "Intermediate", "Advanced"
    
    # Matching preferences
    match_preferences: MatchPreferences
    
    # Metadata
    joined_at: datetime = Field(default_factory=datetime.utcnow)
    socket_id: Optional[str] = None
    status: str = "waiting"  # "waiting", "matching", "matched"
    
    class Config:
        json_schema_extra = {
            "example": {
                "user_id": "507f1f77bcf86cd799439011",
                "username": "john_doe",
                "display_name": "John",
                "native_language": "English",
                "target_language": "Spanish",
                "proficiency_level": "Intermediate",
                "match_preferences": {
                    "practice_mode": "conversation",
                    "topics": ["travel", "food"]
                }
            }
        }
        populate_by_name = True

class JoinQueueRequest(BaseModel):
    """Request body for joining the queue"""
    target_language: str
    proficiency_level: str = "Intermediate"
    practice_mode: str = "conversation"
    topics: List[str] = Field(default_factory=list)
    
    class Config:
        json_schema_extra = {
            "example": {
                "target_language": "Spanish",
                "proficiency_level": "Intermediate",
                "practice_mode": "conversation",
                "topics": ["travel", "culture"]
            }
        }

class QueueStatusResponse(BaseModel):
    """Response for queue status"""
    status: str  # "queued", "matched"
    position: Optional[int] = None
    estimated_wait_seconds: Optional[int] = None
    
    class Config:
        json_schema_extra = {
            "example": {
                "status": "queued",
                "position": 3,
                "estimated_wait_seconds": 45
            }
        }
