import asyncio
import os
from motor.motor_asyncio import AsyncIOMotorClient
from app.models.learning import Course, Unit, Lesson
from bson import ObjectId

# Database Connection
MONGODB_URL = os.getenv("MONGODB_URL", "mongodb://localhost:27017")
DATABASE_NAME = os.getenv("DATABASE_NAME", "ai_tutor_db")

client = AsyncIOMotorClient(MONGODB_URL)
db = client[DATABASE_NAME]

def create_german_course():
    return Course(
        language_code="de",
        title="German Mastery",
        description="Learn German from scratch to fluency.",
        units=[
            Unit(
                id=str(ObjectId()),
                title="BEGINNER",
                description="Start your journey",
                order=1,
                lessons=[
                    Lesson(id=str(ObjectId()), title="Beginner 1", description="Basics 1", type="vocabulary", icon="star_rounded", order=1, is_locked=False),
                    Lesson(id=str(ObjectId()), title="Beginner 2", description="Basics 2", type="vocabulary", icon="translate_rounded", order=2, is_locked=True),
                    Lesson(id=str(ObjectId()), title="Beginner 3", description="Phrases", type="dialogue", icon="chat_bubble_rounded", order=3, is_locked=True),
                ]
            ),
            Unit(
                id=str(ObjectId()),
                title="INTERMEDIATE", 
                description="Expand your skills",
                order=2,
                lessons=[
                    Lesson(id=str(ObjectId()), title="Intermediate 1", description="Grammar", type="grammar", icon="school_rounded", order=1, is_locked=True),
                    Lesson(id=str(ObjectId()), title="Intermediate 2", description="Food", type="vocabulary", icon="restaurant_menu_rounded", order=2, is_locked=True),
                    Lesson(id=str(ObjectId()), title="Intermediate 3", description="Travel", type="vocabulary", icon="train_rounded", order=3, is_locked=True),
                ]
            ),
            Unit(
                id=str(ObjectId()),
                title="ADVANCED",
                description="Master the language",
                order=3,
                lessons=[
                    Lesson(id=str(ObjectId()), title="Advanced 1", description="Literature", type="vocabulary", icon="menu_book_rounded", order=1, is_locked=True),
                    Lesson(id=str(ObjectId()), title="Advanced 2", description="Business", type="vocabulary", icon="business_center_rounded", order=2, is_locked=True),
                    Lesson(id=str(ObjectId()), title="Advanced 3", description="Culture", type="vocabulary", icon="theater_comedy_rounded", order=3, is_locked=True),
                ]
            )
        ]
    )

def create_french_course():
    return Course(
        language_code="fr",
        title="French Mastery",
        description="Master the language of love.",
        units=[
            Unit(
                id=str(ObjectId()),
                title="DÉBUTANT", # Beginner
                description="Start your journey",
                order=1,
                lessons=[
                    Lesson(id=str(ObjectId()), title="Bonjour!", description="Greetings", type="vocabulary", icon="waving_hand", order=1, is_locked=False),
                    Lesson(id=str(ObjectId()), title="Bases 1", description="Basics 1", type="vocabulary", icon="looks_one", order=2, is_locked=True),
                    Lesson(id=str(ObjectId()), title="Bases 2", description="Basics 2", type="vocabulary", icon="looks_two", order=3, is_locked=True),
                ]
            ),
            Unit(
                id=str(ObjectId()),
                title="INTERMÉDIAIRE",
                description="Expand your skills",
                order=2,
                lessons=[
                    Lesson(id=str(ObjectId()), title="Voyage", description="Travel", type="vocabulary", icon="flight", order=1, is_locked=True),
                    Lesson(id=str(ObjectId()), title="Restaurant", description="Food", type="vocabulary", icon="restaurant", order=2, is_locked=True),
                    Lesson(id=str(ObjectId()), title="Famille", description="Family", type="vocabulary", icon="people", order=3, is_locked=True),
                ]
            ),
             Unit(
                id=str(ObjectId()),
                title="AVANCÉ",
                description="Master the language",
                order=3,
                lessons=[
                    Lesson(id=str(ObjectId()), title="Affaires", description="Business", type="vocabulary", icon="work", order=1, is_locked=True),
                    Lesson(id=str(ObjectId()), title="Arts", description="Culture", type="vocabulary", icon="palette", order=2, is_locked=True),
                    Lesson(id=str(ObjectId()), title="Politique", description="Politics", type="vocabulary", icon="gavel", order=3, is_locked=True),
                ]
            )
        ]
    )

def create_spanish_course():
    return Course(
        language_code="es",
        title="Spanish Mastery",
        description="Learn Spanish for travel and life.",
        units=[
            Unit(
                id=str(ObjectId()),
                title="PRINCIPIANTE", # Beginner
                description="Start your journey",
                order=1,
                lessons=[
                    Lesson(id=str(ObjectId()), title="¡Hola!", description="Greetings", type="vocabulary", icon="emoji_people", order=1, is_locked=False),
                    Lesson(id=str(ObjectId()), title="Básico 1", description="Basics 1", type="vocabulary", icon="filter_1", order=2, is_locked=True),
                    Lesson(id=str(ObjectId()), title="Básico 2", description="Basics 2", type="vocabulary", icon="filter_2", order=3, is_locked=True),
                ]
            ),
            Unit(
                id=str(ObjectId()),
                title="INTERMEDIO",
                description="Expand your skills",
                order=2,
                lessons=[
                    Lesson(id=str(ObjectId()), title="Comida", description="Food", type="vocabulary", icon="tapas", order=1, is_locked=True),
                    Lesson(id=str(ObjectId()), title="Ciudad", description="City", type="vocabulary", icon="location_city", order=2, is_locked=True),
                    Lesson(id=str(ObjectId()), title="Amigos", description="Friends", type="vocabulary", icon="groups", order=3, is_locked=True),
                ]
            ),
             Unit(
                id=str(ObjectId()),
                title="AVANZADO",
                description="Master the language",
                order=3,
                lessons=[
                    Lesson(id=str(ObjectId()), title="Negocios", description="Business", type="vocabulary", icon="attach_money", order=1, is_locked=True),
                    Lesson(id=str(ObjectId()), title="Historia", description="History", type="vocabulary", icon="history_edu", order=2, is_locked=True),
                    Lesson(id=str(ObjectId()), title="Literatura", description="Literature", type="vocabulary", icon="auto_stories", order=3, is_locked=True),
                ]
            )
        ]
    )

async def seed_courses():
    print("🌱 Seeding courses...")
    
    # 1. German
    german = create_german_course()
    existing_de = await db.courses.find_one({"language_code": "de"})
    if not existing_de:
        course_data = german.model_dump(by_alias=True, exclude={"id"})
        await db.courses.insert_one(course_data)
        print("✅ German course created")
    else:
        print("ℹ️ German course already exists")

    # 2. French
    french = create_french_course()
    existing_fr = await db.courses.find_one({"language_code": "fr"})
    if not existing_fr:
        course_data = french.model_dump(by_alias=True, exclude={"id"})
        await db.courses.insert_one(course_data)
        print("✅ French course created")
    else:
        print("ℹ️ French course already exists")
        
    # 3. Spanish
    spanish = create_spanish_course()
    existing_es = await db.courses.find_one({"language_code": "es"})
    if not existing_es:
        course_data = spanish.model_dump(by_alias=True, exclude={"id"})
        await db.courses.insert_one(course_data)
        print("✅ Spanish course created")
    else:
         print("ℹ️ Spanish course already exists")

if __name__ == "__main__":
    asyncio.run(seed_courses())
