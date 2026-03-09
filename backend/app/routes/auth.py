from fastapi import APIRouter, HTTPException, Header, Depends
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
from app.services.auth_service import get_current_user
from app.services.gamification_service import GamificationService

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

    # Initialize gamification profile with 1000 starter gems
    await GamificationService.get_or_create_user_gamification(user_id)
    
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


from app.services.auth_service import get_current_user

# ... (rest of imports should be fine)

@router.get("/me", response_model=UserResponse)
async def get_me(current_user: UserInDB = Depends(get_current_user)):
    """Get current authenticated user"""
    return UserResponse(
        id=str(current_user.id),
        username=current_user.username,
        email=current_user.email,
        native_language=current_user.native_language,
        target_language=current_user.target_language,
        proficiency_level=current_user.proficiency_level,
        display_name=current_user.display_name,
        avatar_url=current_user.avatar_url,
        language_progress=current_user.language_progress
    )

@router.patch("/me", response_model=UserResponse)
async def update_me(
    update_data: dict,
    current_user: UserInDB = Depends(get_current_user)
):
    """Update current authenticated user's profile"""
    from datetime import datetime
    
    # Only allow updating certain fields
    allowed_fields = {
        'target_language', 'native_language', 'proficiency_level',
        'display_name', 'avatar_url', 'bio'
    }
    
    # Filter update data to only allowed fields
    filtered_update = {
        key: value for key, value in update_data.items() 
        if key in allowed_fields
    }
    
    if not filtered_update:
        raise HTTPException(status_code=400, detail="No valid fields to update")
    
    # Add updated timestamp
    filtered_update['updated_at'] = datetime.utcnow()
    
    # Update user in database
    result = await db.users.update_one(
        {"_id": ObjectId(str(current_user.id))},
        {"$set": filtered_update}
    )
    
    if result.modified_count == 0:
        # Still return success even if nothing changed
        pass
    
    # Fetch updated user
    updated_user = await db.users.find_one({"_id": ObjectId(str(current_user.id))})
    
    if not updated_user:
        raise HTTPException(status_code=404, detail="User not found after update")
    
    return UserResponse(
        id=str(updated_user['_id']),
        username=updated_user['username'],
        email=updated_user['email'],
        native_language=updated_user['native_language'],
        target_language=updated_user['target_language'],
        proficiency_level=updated_user['proficiency_level'],
        display_name=updated_user.get('display_name'),
        avatar_url=updated_user.get('avatar_url')
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
