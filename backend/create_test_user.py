import asyncio
from motor.motor_asyncio import AsyncIOMotorClient
import os
from dotenv import load_dotenv

load_dotenv()

MONGODB_URL = os.getenv("MONGODB_URL")
import bcrypt

async def create_test_user():
    client = AsyncIOMotorClient(MONGODB_URL, tlsAllowInvalidCertificates=True)
    db = client.get_database(os.getenv("DATABASE_NAME", "ai_tutor_db"))
    
    username = "testuser"
    email = "test@example.com"
    password = "password123"
    
    # Hash using bcrypt directly to match app/utils/security.py
    hashed = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')
    
    # Check if exists
    existing = await db.users.find_one({"username": username})
    if existing:
        print(f"User '{username}' already exists. Updating password...")
        await db.users.update_one({"username": username}, {"$set": {"password_hash": hashed}})
        print(f"Password reset to '{password}' for user '{username}'")
    else:
        print(f"Creating new user '{username}'...")
        # hashed is already computed above
        user_doc = {
            "username": username,
            "email": email,
            "password_hash": hashed,
            "native_language": "English",
            "target_language": "Spanish",
            "proficiency_level": "Beginner",
            "display_name": "Test User"
        }
        await db.users.insert_one(user_doc)
        print(f"User '{username}' created successfully!")

if __name__ == "__main__":
    asyncio.run(create_test_user())
