import asyncio
from motor.motor_asyncio import AsyncIOMotorClient
import os
from dotenv import load_dotenv
from datetime import datetime

load_dotenv()

MONGODB_URL = os.getenv("MONGODB_URL")
DATABASE_NAME = os.getenv("DATABASE_NAME", "ai_tutor_db")

async def create_mock_partner():
    print(f"Connecting to {DATABASE_NAME}...")
    client = AsyncIOMotorClient(MONGODB_URL, tlsAllowInvalidCertificates=True)
    db = client[DATABASE_NAME]
    
    # 1. Create the Mock User Account (if not exists)
    mock_user_id = "mock_partner_001"
    mock_username = "hans_mueller"
    
    user_doc = {
        "username": mock_username,
        "email": "hans@example.com",
        "password_hash": "hashed_secret",
        "native_language": "German",
        "target_language": "English",
        "proficiency_level": "Intermediate",
        "display_name": "Hans Müller",
        "avatar_url": "https://i.pravatar.cc/150?u=hans", 
        "bio": "Hallo! I want to improve my English.",
        "created_at": datetime.utcnow()
    }
    
    # Upsert user
    await db.users.update_one(
        {"username": mock_username}, 
        {"$set": user_doc}, 
        upsert=True
    )
    
    # Get the actual ID
    user = await db.users.find_one({"username": mock_username})
    user_id = str(user["_id"])
    
    print(f"Mock user '{mock_username}' ready (ID: {user_id})")
    
    # 2. Add to Waiting Queue
    # Compatible with: English native learning German
    queue_entry = {
        "user_id": user_id,
        "username": mock_username,
        "display_name": "Hans Müller",
        "avatar_url": "https://i.pravatar.cc/150?u=hans",
        "native_language": "German",      # Target for our User
        "target_language": "English",     # Native of our User (Perfect Match)
        "proficiency_level": "Intermediate",
        "match_preferences": {
            "practice_mode": "conversation",
            "topics": ["travel", "culture"]
        },
        "status": "waiting",
        "joined_at": datetime.utcnow(),
        "socket_id": "mock_socket_123"
    }
    
    # Remove existing queue entry for this user
    await db.waiting_queue.delete_many({"user_id": user_id})
    
    # Insert new entry
    await db.waiting_queue.insert_one(queue_entry)
    
    print(f"✅ Mock partner '{mock_username}' added to Waiting Queue!")
    print("   - Speaks: German")
    print("   - Learning: English")
    print("   -> Go to your app and search for a 'German' partner now!")

if __name__ == "__main__":
    asyncio.run(create_mock_partner())
