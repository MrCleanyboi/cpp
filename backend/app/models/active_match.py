from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime

class MatchParticipant(BaseModel):
    """Information about a match participant"""
    user_id: str
    username: str
    display_name: str
    avatar_url: Optional[str] = None
    socket_id: Optional[str] = None
    language: str  # Their native language
    
    class Config:
        json_schema_extra = {
            "example": {
                "user_id": "507f1f77bcf86cd799439011",
                "username": "john_doe",
                "display_name": "John",
                "language": "English"
            }
        }

class ChatMessage(BaseModel):
    """A single chat message in the match"""
    sender_id: str
    text: str
    timestamp: datetime = Field(default_factory=datetime.utcnow)
    
    class Config:
        json_schema_extra = {
            "example": {
                "sender_id": "507f1f77bcf86cd799439011",
                "text": "Hola! ¿Cómo estás?",
                "timestamp": "2026-02-08T08:00:00Z"
            }
        }

class ActiveMatch(BaseModel):
    """Document stored in active_matches collection"""
    id: Optional[str] = Field(alias="_id", default=None)
    
    # Participants
    user1: MatchParticipant
    user2: MatchParticipant
    
    # Match info
    practice_language: str
    matched_at: datetime = Field(default_factory=datetime.utcnow)
    
    # Communication status
    text_chat_active: bool = True
    voice_chat_active: bool = False
    video_chat_active: bool = False
    
    # Chat history (limited to recent messages)
    messages: List[ChatMessage] = Field(default_factory=list)
    
    # Session info
    status: str = "active"  # "active", "ended"
    ended_at: Optional[datetime] = None
    ended_by: Optional[str] = None  # user_id who ended it
    
    class Config:
        json_schema_extra = {
            "example": {
                "_id": "65f1a2b3c4d5e6f7g8h9i0j1",
                "user1": {
                    "user_id": "507f1f77bcf86cd799439011",
                    "username": "john_doe",
                    "display_name": "John",
                    "language": "English"
                },
                "user2": {
                    "user_id": "507f191e810c19729de860ea",
                    "username": "maria_garcia",
                    "display_name": "Maria",
                    "language": "Spanish"
                },
                "practice_language": "Spanish",
                "text_chat_active": True,
                "status": "active"
            }
        }
        populate_by_name = True

class MatchFoundResponse(BaseModel):
    """Response when a match is found"""
    status: str = "matched"
    match_id: str
    partner: MatchParticipant
    websocket_url: str
    
    class Config:
        json_schema_extra = {
            "example": {
                "status": "matched",
                "match_id": "65f1a2b3c4d5e6f7g8h9i0j1",
                "partner": {
                    "user_id": "507f191e810c19729de860ea",
                    "username": "maria_garcia",
                    "display_name": "Maria",
                    "language": "Spanish"
                },
                "websocket_url": "ws://10.0.2.2:8000/ws/chat/65f1a2b3c4d5e6f7g8h9i0j1"
            }
        }

class EndMatchRequest(BaseModel):
    """Request body for ending a match"""
    reason: str = "finished"  # "finished", "skip", "report"
    
    class Config:
        json_schema_extra = {
            "example": {
                "reason": "finished"
            }
        }

class EndMatchResponse(BaseModel):
    """Response after ending a match"""
    status: str = "ended"
    duration_seconds: int
    
    class Config:
        json_schema_extra = {
            "example": {
                "status": "ended",
                "duration_seconds": 1847
            }
        }
