from pydantic import BaseModel
from typing import Optional

class ChatRequest(BaseModel):
    message: str
    target_language: Optional[str] = "German"

class ChatResponse(BaseModel):
    reply: str
