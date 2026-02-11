from fastapi import APIRouter, HTTPException, Depends
from typing import List, Optional
from app.database import db
from app.models.learning import Course
from app.services.auth_service import get_current_user
from app.models.user import UserInDB

router = APIRouter(prefix="/learning", tags=["Learning Path"])

@router.get("/course/{language_code}", response_model=Course)
async def get_course(language_code: str, current_user: UserInDB = Depends(get_current_user)):
    """
    Get the full course structure for a specific language.
    """
    course = await db.courses.find_one({"language_code": language_code})
    
    if not course:
        raise HTTPException(status_code=404, detail=f"Course for {language_code} not found")
        
    return course

@router.get("/courses", response_model=List[Course])
async def get_all_courses():
    """
    Get all available courses (public endpoint).
    """
    courses = await db.courses.find().to_list(length=100)
    return courses
