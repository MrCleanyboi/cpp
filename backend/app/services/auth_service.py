from fastapi import HTTPException, Header, Depends
from typing import Optional
from bson import ObjectId
from app.database import db
from app.utils.security import get_user_id_from_token
from app.models.user import UserInDB

async def get_current_user(authorization: Optional[str] = Header(None)) -> UserInDB:
    """Dependency to get current authenticated user"""
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Not authenticated")
    
    token = authorization.replace("Bearer ", "")
    user_id = get_user_id_from_token(token)
    
    if not user_id:
        raise HTTPException(status_code=401, detail="Invalid token")
    
    # Get user from database
    user = await db.users.find_one({"_id": ObjectId(user_id)})
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    return UserInDB(**user)
