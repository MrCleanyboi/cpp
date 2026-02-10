from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime
from enum import Enum

class ReportReason(str, Enum):
    """Predefined report reasons"""
    INAPPROPRIATE_CONTENT = "inappropriate_content"
    HARASSMENT = "harassment"
    SPAM = "spam"
    OTHER = "other"

class ReportStatus(str, Enum):
    """Report processing status"""
    PENDING = "pending"
    REVIEWED = "reviewed"
    ACTION_TAKEN = "action_taken"
    DISMISSED = "dismissed"

class UserReport(BaseModel):
    """Document stored in user_reports collection"""
    id: Optional[str] = Field(alias="_id", default=None)
    
    # Who reported whom
    reporter_id: str
    reported_user_id: str
    match_id: str
    
    # Report details
    reason: ReportReason
    description: Optional[str] = None
    
    # Metadata
    reported_at: datetime = Field(default_factory=datetime.utcnow)
    status: ReportStatus = ReportStatus.PENDING
    
    # Auto-block tracking
    reported_user_total_reports: int = 0
    auto_blocked: bool = False
    
    class Config:
        json_schema_extra = {
            "example": {
                "reporter_id": "507f1f77bcf86cd799439011",
                "reported_user_id": "507f191e810c19729de860ea",
                "match_id": "65f1a2b3c4d5e6f7g8h9i0j1",
                "reason": "inappropriate_content",
                "description": "User was using offensive language",
                "status": "pending"
            }
        }
        use_enum_values = True
        populate_by_name = True

class ReportUserRequest(BaseModel):
    """Request body for reporting a user"""
    match_id: str
    reported_user_id: str
    reason: ReportReason
    description: Optional[str] = None
    
    class Config:
        json_schema_extra = {
            "example": {
                "match_id": "65f1a2b3c4d5e6f7g8h9i0j1",
                "reported_user_id": "507f191e810c19729de860ea",
                "reason": "inappropriate_content",
                "description": "Offensive language"
            }
        }
        use_enum_values = True

class ReportUserResponse(BaseModel):
    """Response after submitting a report"""
    status: str = "reported"
    report_id: str
    
    class Config:
        json_schema_extra = {
            "example": {
                "status": "reported",
                "report_id": "65f1a2b3c4d5e6f7g8h9i0j2"
            }
        }
