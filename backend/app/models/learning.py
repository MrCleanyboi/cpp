from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any
from bson import ObjectId
from app.models.user import PyObjectId


class VocabItem(BaseModel):
    word: str                       # Target language word/phrase (e.g. "Ich möchte")
    meaning: str                    # English meaning (e.g. "I would like")
    example: str                    # Example sentence in target language
    example_translation: str        # English translation of the example


class IntroLesson(BaseModel):
    id: str
    title: str                      # e.g. "Unit Preview: The Café"
    vocab_items: List[VocabItem]


class Lesson(BaseModel):
    id: str = Field(default_factory=lambda: str(ObjectId()))
    title: str
    description: str
    type: str  # "vocabulary", "grammar", "dialogue", "quiz"
    icon: str  # Flutter icon name/code
    content: List[Dict[str, Any]] = []  # Flexible content structure for exercises
    is_locked: bool = True
    xp_reward: int = 10
    order: int


class Unit(BaseModel):
    id: str = Field(default_factory=lambda: str(ObjectId()))
    title: str
    description: str
    order: int
    lessons: List[Lesson]
    base_color: Optional[str] = None  # Hex code for specific unit override
    intro_lesson: Optional[IntroLesson] = None  # Preparatory vocab preview lesson


class Course(BaseModel):
    id: Optional[PyObjectId] = Field(alias="_id", default=None)
    language_code: str  # "fr", "es", "de", "en"
    title: str
    description: str
    units: List[Unit]

    class Config:
        allow_population_by_field_name = True
        arbitrary_types_allowed = True
        json_encoders = {ObjectId: str}
