from fastapi import APIRouter, HTTPException, Header
from typing import Optional
from bson import ObjectId
from datetime import datetime

from app.models.auth import UserSignup, UserLogin, Token, UserResponse
from app.models.user import UserCreate, UserInDB
from app.database import db
from app.utils.security import (
    verify_password,
    get_password_hash,
    create_access_token,
    get_user_id_from_token
)

router = APIRouter(prefix="/api/auth", tags=["authentication"])


@router.post("/signup", response_model=Token)
async def signup(user_data: UserSignup):
    """Register a new user"""
    
    # Check if username already exists
    existing_user = await db.users.find_one({"username": user_data.username})
    if existing_user:
        raise HTTPException(status_code=400, detail="Username already registered")
    
    # Check if email already exists
    existing_email = await db.users.find_one({"email": user_data.email})
    if existing_email:
        raise HTTPException(status_code=400, detail="Email already registered")
    
    # Hash password
    password_hash = get_password_hash(user_data.password)
    
    # Create user document
    new_user = UserCreate(
        username=user_data.username,
        email=user_data.email,
        password_hash=password_hash,
        native_language=user_data.native_language,
        target_language=user_data.target_language,
        proficiency_level=user_data.proficiency_level,
        display_name=user_data.username,  # Default to username
    )
    
    # Insert into database
    user_dict = new_user.dict(exclude={'id'})
    user_dict['created_at'] = datetime.utcnow()
    user_dict['updated_at'] = datetime.utcnow()
    
    result = await db.users.insert_one(user_dict)
    user_id = str(result.inserted_id)
    
    # Create access token
    access_token = create_access_token(data={"sub": user_id, "username": user_data.username})
    
    return Token(
        access_token=access_token,
        user_id=user_id,
        username=user_data.username
    )


@router.post("/login", response_model=Token)
async def login(credentials: UserLogin):
    """Authenticate a user and return JWT token"""
    
    # Find user by username or email
    user = await db.users.find_one({
        "$or": [
            {"username": credentials.username_or_email},
            {"email": credentials.username_or_email}
        ]
    })
    
    print(f"DEBUG: Login attempt for {credentials.username_or_email}")
    print(f"DEBUG: User found: {user}")
    
    if not user:
        raise HTTPException(status_code=401, detail="Incorrect username/email or password")
    
    # Verify password
    is_valid = verify_password(credentials.password, user['password_hash'])
    print(f"DEBUG: Password valid: {is_valid}")
    if not is_valid:
        raise HTTPException(status_code=401, detail="Incorrect username/email or password")
    
    # Create access token
    user_id = str(user['_id'])
    access_token = create_access_token(data={"sub": user_id, "username": user['username']})
    
    return Token(
        access_token=access_token,
        user_id=user_id,
        username=user['username']
    )


@router.get("/me", response_model=UserResponse)
async def get_current_user(authorization: Optional[str] = Header(None)):
    """Get current authenticated user"""
    
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
    
    return UserResponse(
        id=str(user['_id']),
        username=user['username'],
        email=user['email'],
        native_language=user['native_language'],
        target_language=user['target_language'],
        proficiency_level=user['proficiency_level'],
        display_name=user.get('display_name'),
        avatar_url=user.get('avatar_url')
    )


@router.get("/verify-token")
async def verify_token(authorization: Optional[str] = Header(None)):
    """Verify if a token is valid"""
    
    if not authorization or not authorization.startswith("Bearer "):
        return {"valid": False}
    
    token = authorization.replace("Bearer ", "")
    user_id = get_user_id_from_token(token)
    
    if user_id:
        return {"valid": True, "user_id": user_id}
    return {"valid": False}
