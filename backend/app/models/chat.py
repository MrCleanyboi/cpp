from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime
from bson import ObjectId

class Message(BaseModel):
    sender: str # "user" or "ai"
    content: str
    timestamp: datetime = Field(default_factory=datetime.utcnow)
    correction: Optional[str] = None

class ChatSession(BaseModel):
    id: Optional[str] = Field(alias="_id", default=None)
    user_id: str
    messages: List[Message] = []
    created_at: datetime = Field(default_factory=datetime.utcnow)

    class Config:
        allow_population_by_field_name = True
        arbitrary_types_allowed = True
        json_encoders = {ObjectId: str}
