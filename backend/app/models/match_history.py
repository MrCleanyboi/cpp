from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime

class MatchHistory(BaseModel):
    """Document stored in match_history collection - archives completed matches"""
    id: Optional[str] = Field(alias="_id", default=None)
    match_id: str  # Reference to the original active_matches document
    
    # Participants
    user1_id: str
    user2_id: str
    
    # Match info
    practice_language: str
    duration_seconds: int
    started_at: datetime
    ended_at: datetime
    
    # Engagement metrics
    message_count: int = 0
    voice_used: bool = False
    video_used: bool = False
    
    # Reasons for ending
    ended_by: str  # "user1", "user2", "system_timeout", "both"
    end_reason: str  # "user_left", "skip", "report", "timeout", "finished"
    
    class Config:
        json_schema_extra = {
            "example": {
                "match_id": "65f1a2b3c4d5e6f7g8h9i0j1",
                "user1_id": "507f1f77bcf86cd799439011",
                "user2_id": "507f191e810c19729de860ea",
                "practice_language": "Spanish",
                "duration_seconds": 1847,
                "message_count": 42,
                "voice_used": True,
                "video_used": False,
                "ended_by": "user1",
                "end_reason": "finished"
            }
        }
        populate_by_name = True
