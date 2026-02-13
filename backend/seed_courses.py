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
            # BEGINNER (Units 1-3)
            Unit(id="de_u1", title="The Café", description="Ordering food and drinks", order=1, lessons=[
                Lesson(id="de_u1_l1", title="Ordering Coffee", description="Basic ordering", type="vocabulary", icon="coffee", order=1, is_locked=False),
                Lesson(id="de_u1_l2", title="The Menu", description="Reading the card", type="vocabulary", icon="restaurant_menu", order=2, is_locked=True),
                Lesson(id="de_u1_l3", title="Paying the Bill", description="Handling money", type="dialogue", icon="receipt_long", order=3, is_locked=True),
            ]),
            Unit(id="de_u2", title="Family & Friends", description="Talking about people", order=2, lessons=[
                Lesson(id="de_u2_l1", title="Family Members", description="Mom, Dad, etc.", type="vocabulary", icon="groups", order=1, is_locked=True),
                Lesson(id="de_u2_l2", title="Describing People", description="Tall, short, nice", type="vocabulary", icon="face", order=2, is_locked=True),
                Lesson(id="de_u2_l3", title="Pets", description="Cats and dogs", type="vocabulary", icon="pets", order=3, is_locked=True),
            ]),
            Unit(id="de_u3", title="My Home", description="Housing and objects", order=3, lessons=[
                Lesson(id="de_u3_l1", title="Rooms", description="Kitchen, Bedroom", type="vocabulary", icon="home", order=1, is_locked=True),
                Lesson(id="de_u3_l2", title="Furniture", description="Table, Chair", type="vocabulary", icon="chair", order=2, is_locked=True),
                Lesson(id="de_u3_l3", title="Where is it?", description="Prepositions", type="vocabulary", icon="search", order=3, is_locked=True),
            ]),
            
            # INTERMEDIATE (Units 4-6)
            Unit(id="de_u4", title="Travel & City", description="Getting around", order=4, lessons=[
                Lesson(id="de_u4_l1", title="At the Station", description="Buying tickets", type="dialogue", icon="train", order=1, is_locked=True),
                Lesson(id="de_u4_l2", title="Hotel Check-in", description="Booking a room", type="vocabulary", icon="hotel", order=2, is_locked=True),
                Lesson(id="de_u4_l3", title="Directions", description="Left, Right", type="vocabulary", icon="map", order=3, is_locked=True),
            ]),
            Unit(id="de_u5", title="Hobbies & Sports", description="Free time activities", order=5, lessons=[
                Lesson(id="de_u5_l1", title="Sports", description="Football, Tennis", type="vocabulary", icon="sports_soccer", order=1, is_locked=True),
                Lesson(id="de_u5_l2", title="Music & Movies", description="Entertainment", type="vocabulary", icon="movie", order=2, is_locked=True),
                Lesson(id="de_u5_l3", title="Weekend Plans", description="Future tense", type="dialogue", icon="calendar_today", order=3, is_locked=True),
            ]),
            Unit(id="de_u6", title="Shopping", description="Buying things", order=6, lessons=[
                Lesson(id="de_u6_l1", title="Clothing", description="Shirt, Pants", type="vocabulary", icon="checkroom", order=1, is_locked=True),
                Lesson(id="de_u6_l2", title="Colors & Sizes", description="Red, Big", type="vocabulary", icon="palette", order=2, is_locked=True),
                Lesson(id="de_u6_l3", title="At the Market", description="Groceries", type="dialogue", icon="storefront", order=3, is_locked=True),
            ]),

            # ADVANCED (Units 7-9)
            Unit(id="de_u7", title="Business", description="Professional life", order=7, lessons=[
                Lesson(id="de_u7_l1", title="The Meeting", description="Business talk", type="vocabulary", icon="meeting_room", order=1, is_locked=True),
                Lesson(id="de_u7_l2", title="Office Life", description="Supplies, formatting", type="vocabulary", icon="desk", order=2, is_locked=True),
                Lesson(id="de_u7_l3", title="Emails", description="Formal writing", type="vocabulary", icon="email", order=3, is_locked=True),
            ]),
            Unit(id="de_u8", title="Media & News", description="Current events", order=8, lessons=[
                Lesson(id="de_u8_l1", title="The News", description="Headlines", type="vocabulary", icon="newspaper", order=1, is_locked=True),
                Lesson(id="de_u8_l2", title="Technology", description="Computers, AI", type="vocabulary", icon="computer", order=2, is_locked=True),
                Lesson(id="de_u8_l3", title="Social Media", description="Posting, Liking", type="vocabulary", icon="share", order=3, is_locked=True),
            ]),
            Unit(id="de_u9", title="Environment", description="Global issues", order=9, lessons=[
                Lesson(id="de_u9_l1", title="Nature", description="Trees, Animals", type="vocabulary", icon="forest", order=1, is_locked=True),
                Lesson(id="de_u9_l2", title="The Future", description="Predictions", type="vocabulary", icon="public", order=2, is_locked=True),
                Lesson(id="de_u9_l3", title="Debate", description="Expressing opinion", type="dialogue", icon="record_voice_over", order=3, is_locked=True),
            ]),
        ]
    )

def create_french_course():
    return Course(
        language_code="fr",
        title="French Mastery",
        description="Master the language of love.",
        units=[
            # BEGINNER
            Unit(id="fr_u1", title="Le Café", description="Parisian coffee", order=1, lessons=[
                Lesson(id="fr_u1_l1", title="Un Café", description="Ordering", type="vocabulary", icon="coffee", order=1, is_locked=False),
                Lesson(id="fr_u1_l2", title="Croissants", description="Bakery", type="vocabulary", icon="bakery_dining", order=2, is_locked=True),
                Lesson(id="fr_u1_l3", title="Paying", description="Money", type="dialogue", icon="receipt", order=3, is_locked=True),
            ]),
            Unit(id="fr_u2", title="Famille", description="Family members", order=2, lessons=[
                Lesson(id="fr_u2_l1", title="Parents", description="Mom & Dad", type="vocabulary", icon="groups", order=1, is_locked=True),
                Lesson(id="fr_u2_l2", title="Siblings", description="Brothers/Sisters", type="vocabulary", icon="face", order=2, is_locked=True),
                Lesson(id="fr_u2_l3", title="Pets", description="Animals", type="vocabulary", icon="pets", order=3, is_locked=True),
            ]),
            Unit(id="fr_u3", title="Ma Maison", description="My House", order=3, lessons=[
                Lesson(id="fr_u3_l1", title="Rooms", description="Kitchen...", type="vocabulary", icon="home", order=1, is_locked=True),
                Lesson(id="fr_u3_l2", title="Furniture", description="Bed, Table", type="vocabulary", icon="chair", order=2, is_locked=True),
                Lesson(id="fr_u3_l3", title="Garden", description="Flowers", type="vocabulary", icon="deck", order=3, is_locked=True),
            ]),

            # INTERMEDIATE
            Unit(id="fr_u4", title="Voyage à Paris", description="Travel", order=4, lessons=[
                Lesson(id="fr_u4_l1", title="Le Métro", description="Subway", type="vocabulary", icon="subway", order=1, is_locked=True),
                Lesson(id="fr_u4_l2", title="Musée", description="Culture", type="vocabulary", icon="museum", order=2, is_locked=True),
                Lesson(id="fr_u4_l3", title="Tour Eiffel", description="Sightseeing", type="vocabulary", icon="camera_alt", order=3, is_locked=True),
            ]),
            Unit(id="fr_u5", title="Loisirs", description="Hobbies", order=5, lessons=[
                Lesson(id="fr_u5_l1", title="Sport", description="Football", type="vocabulary", icon="sports_soccer", order=1, is_locked=True),
                Lesson(id="fr_u5_l2", title="Cinema", description="Movies", type="vocabulary", icon="movie", order=2, is_locked=True),
                Lesson(id="fr_u5_l3", title="Music", description="Concerts", type="vocabulary", icon="music_note", order=3, is_locked=True),
            ]),
            Unit(id="fr_u6", title="Shopping", description="Mode & Style", order=6, lessons=[
                Lesson(id="fr_u6_l1", title="Vêtements", description="Clothes", type="vocabulary", icon="checkroom", order=1, is_locked=True),
                Lesson(id="fr_u6_l2", title="Couleurs", description="Colors", type="vocabulary", icon="palette", order=2, is_locked=True),
                Lesson(id="fr_u6_l3", title="Boutique", description="Shopping", type="dialogue", icon="shopping_bag", order=3, is_locked=True),
            ]),

            # ADVANCED
            Unit(id="fr_u7", title="Vie Pro", description="Work Life", order=7, lessons=[
                Lesson(id="fr_u7_l1", title="Entretien", description="Interview", type="vocabulary", icon="work", order=1, is_locked=True),
                Lesson(id="fr_u7_l2", title="Bureau", description="Office", type="vocabulary", icon="desk", order=2, is_locked=True),
                Lesson(id="fr_u7_l3", title="Réunion", description="Meeting", type="vocabulary", icon="meeting_room", order=3, is_locked=True),
            ]),
            Unit(id="fr_u8", title="Actualités", description="News", order=8, lessons=[
                Lesson(id="fr_u8_l1", title="Journal", description="Newspaper", type="vocabulary", icon="newspaper", order=1, is_locked=True),
                Lesson(id="fr_u8_l2", title="Politique", description="Politics", type="vocabulary", icon="policy", order=2, is_locked=True),
                Lesson(id="fr_u8_l3", title="Internet", description="Web", type="vocabulary", icon="language", order=3, is_locked=True),
            ]),
            Unit(id="fr_u9", title="Environnement", description="Ecology", order=9, lessons=[
                Lesson(id="fr_u9_l1", title="Nature", description="Forest", type="vocabulary", icon="forest", order=1, is_locked=True),
                Lesson(id="fr_u9_l2", title="Pollution", description="Issues", type="vocabulary", icon="warning", order=2, is_locked=True),
                Lesson(id="fr_u9_l3", title="Recyclage", description="Recycling", type="vocabulary", icon="recycling", order=3, is_locked=True),
            ]),
        ]
    )

def create_spanish_course():
    return Course(
        language_code="es",
        title="Spanish Mastery",
        description="Learn Spanish for travel and life.",
        units=[
            # BEGINNER
            Unit(id="es_u1", title="El Restaurante", description="Ordering food", order=1, lessons=[
                Lesson(id="es_u1_l1", title="Tapas", description="Ordering", type="vocabulary", icon="tapas", order=1, is_locked=False),
                Lesson(id="es_u1_l2", title="Bebidas", description="Drinks", type="vocabulary", icon="wine_bar", order=2, is_locked=True),
                Lesson(id="es_u1_l3", title="La Cuenta", description="Bill", type="dialogue", icon="receipt", order=3, is_locked=True),
            ]),
            Unit(id="es_u2", title="Familia", description="Family", order=2, lessons=[
                Lesson(id="es_u2_l1", title="Padres", description="Parents", type="vocabulary", icon="groups", order=1, is_locked=True),
                Lesson(id="es_u2_l2", title="Hermanos", description="Siblings", type="vocabulary", icon="face", order=2, is_locked=True),
                Lesson(id="es_u2_l3", title="Mascotas", description="Pets", type="vocabulary", icon="pets", order=3, is_locked=True),
            ]),
             Unit(id="es_u3", title="Mi Casa", description="My House", order=3, lessons=[
                Lesson(id="es_u3_l1", title="Cuartos", description="Rooms", type="vocabulary", icon="home", order=1, is_locked=True),
                Lesson(id="es_u3_l2", title="Muebles", description="Furniture", type="vocabulary", icon="chair", order=2, is_locked=True),
                Lesson(id="es_u3_l3", title="Dónde está?", description="Location", type="vocabulary", icon="search", order=3, is_locked=True),
            ]),

            # INTERMEDIATE
            Unit(id="es_u4", title="La Ciudad", description="The City", order=4, lessons=[
                Lesson(id="es_u4_l1", title="Mercado", description="Market", type="vocabulary", icon="storefront", order=1, is_locked=True),
                Lesson(id="es_u4_l2", title="Taxi", description="Transport", type="vocabulary", icon="local_taxi", order=2, is_locked=True),
                Lesson(id="es_u4_l3", title="Emergencia", description="Help", type="vocabulary", icon="emergency", order=3, is_locked=True),
            ]),
            Unit(id="es_u5", title="Hobbies", description="Pasatiempos", order=5, lessons=[
                Lesson(id="es_u5_l1", title="Fútbol", description="Soccer", type="vocabulary", icon="sports_soccer", order=1, is_locked=True),
                Lesson(id="es_u5_l2", title="Música", description="Music", type="vocabulary", icon="music_note", order=2, is_locked=True),
                Lesson(id="es_u5_l3", title="Playa", description="Beach", type="vocabulary", icon="beach_access", order=3, is_locked=True),
            ]),
            Unit(id="es_u6", title="Compras", description="Shopping", order=6, lessons=[
                Lesson(id="es_u6_l1", title="Ropa", description="Clothes", type="vocabulary", icon="checkroom", order=1, is_locked=True),
                Lesson(id="es_u6_l2", title="Colores", description="Colors", type="vocabulary", icon="palette", order=2, is_locked=True),
                Lesson(id="es_u6_l3", title="Pagar", description="Paying", type="dialogue", icon="credit_card", order=3, is_locked=True),
            ]),

            # ADVANCED
            Unit(id="es_u7", title="Negocios", description="Business", order=7, lessons=[
                Lesson(id="es_u7_l1", title="Oficina", description="Office", type="vocabulary", icon="desk", order=1, is_locked=True),
                Lesson(id="es_u7_l2", title="Reunión", description="Meeting", type="vocabulary", icon="meeting_room", order=2, is_locked=True),
                Lesson(id="es_u7_l3", title="Contrato", description="Contract", type="vocabulary", icon="gavel", order=3, is_locked=True),
            ]),
            Unit(id="es_u8", title="Noticias", description="News", order=8, lessons=[
                Lesson(id="es_u8_l1", title="Periódico", description="Newspaper", type="vocabulary", icon="newspaper", order=1, is_locked=True),
                Lesson(id="es_u8_l2", title="Mundo", description="World", type="vocabulary", icon="public", order=2, is_locked=True),
                Lesson(id="es_u8_l3", title="Internet", description="Web", type="vocabulary", icon="language", order=3, is_locked=True),
            ]),
            Unit(id="es_u9", title="Medio Ambiente", description="Environment", order=9, lessons=[
                Lesson(id="es_u9_l1", title="Naturaleza", description="Nature", type="vocabulary", icon="forest", order=1, is_locked=True),
                Lesson(id="es_u9_l2", title="Cambio", description="Change", type="vocabulary", icon="trending_up", order=2, is_locked=True),
                Lesson(id="es_u9_l3", title="Futuro", description="Future", type="dialogue", icon="history_edu", order=3, is_locked=True),
            ]),
        ]
    )

async def seed_courses():
    print("🌱 Seeding courses with EXPANDED structure (9 Units/Lang)...")
    
    # CLEAR EXISTING COURSES
    print("⚠️ Clearing existing courses...")
    await db.courses.delete_many({})
    
    # 1. German
    german = create_german_course()
    course_data = german.model_dump(by_alias=True, exclude={"id"})
    await db.courses.insert_one(course_data)
    print("✅ German course created (9 Units)")

    # 2. French
    french = create_french_course()
    course_data = french.model_dump(by_alias=True, exclude={"id"})
    await db.courses.insert_one(course_data)
    print("✅ French course created (9 Units)")
        
    # 3. Spanish
    spanish = create_spanish_course()
    course_data = spanish.model_dump(by_alias=True, exclude={"id"})
    await db.courses.insert_one(course_data)
    print("✅ Spanish course created (9 Units)")

if __name__ == "__main__":
    asyncio.run(seed_courses())
