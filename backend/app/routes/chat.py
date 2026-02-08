from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from app.services.ai_service import ai_service

router = APIRouter()

class ChatRequest(BaseModel):
    message: str
    target_language: str = "Spanish"

@router.post("/chat")
async def chat_endpoint(request: ChatRequest):
    response = await ai_service.get_response(request.message, request.target_language)
    return response
