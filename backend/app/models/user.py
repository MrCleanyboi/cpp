<<<<<<< HEAD
from pydantic import BaseModel, Field
=======
from pydantic import BaseModel, EmailStr, Field
>>>>>>> origin/main
from typing import Optional, List, Any
from bson import ObjectId
from datetime import datetime
from pydantic_core import core_schema

class PyObjectId(ObjectId):
    """Custom ObjectId for Pydantic v2 models"""
    
    @classmethod
    def __get_pydantic_core_schema__(cls, source_type: Any, handler):
        return core_schema.union_schema([
            core_schema.is_instance_schema(ObjectId),
            core_schema.no_info_plain_validator_function(cls.validate),
        ], serialization=core_schema.plain_serializer_function_ser_schema(str))

    @classmethod
    def validate(cls, v):
        if isinstance(v, ObjectId):
            return v
        if isinstance(v, str) and ObjectId.is_valid(v):
            return ObjectId(v)
        raise ValueError("Invalid ObjectId")

class UserBase(BaseModel):
    username: str
    email: str  # Required for authentication
    native_language: str
    target_language: str
    proficiency_level: str = "Beginner" # Beginner, Intermediate, Advanced
    
    # Social profile fields
    display_name: Optional[str] = None  # Defaults to username if not set
    avatar_url: Optional[str] = None
    bio: Optional[str] = None
    is_public_profile: bool = True
    
    # Friends
    friends: List[str] = []  # List of user IDs
    friend_requests: List[str] = []  # Pending friend request user IDs

class UserCreate(UserBase):
    password_hash: str  # Hashed password for storage

class UserInDB(UserBase):
    id: Optional[PyObjectId] = Field(alias="_id")
    password_hash: str  # Hashed password
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    class Config:
        allow_population_by_field_name = True
        arbitrary_types_allowed = True
        json_encoders = {ObjectId: str}
