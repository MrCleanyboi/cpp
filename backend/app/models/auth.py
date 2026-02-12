from pydantic import BaseModel, EmailStr
from typing import Optional, Dict, Any


class UserSignup(BaseModel):
    """User registration data"""
    username: str
    email: EmailStr
    password: str
    native_language: str
    target_language: str
    proficiency_level: str = "Beginner"


class UserLogin(BaseModel):
    """User login credentials"""
    username_or_email: str
    password: str


class Token(BaseModel):
    """JWT token response"""
    access_token: str
    token_type: str = "bearer"
    user_id: str
    username: str


class TokenData(BaseModel):
    """Decoded token payload"""
    user_id: Optional[str] = None
    username: Optional[str] = None


class UserResponse(BaseModel):
    """User data returned to client (no password)"""
    id: str
    username: str
    email: str
    native_language: str
    target_language: str
    proficiency_level: str
    display_name: Optional[str] = None
    avatar_url: Optional[str] = None
    language_progress: Optional[Dict[str, Any]] = None  # Added language_progress
