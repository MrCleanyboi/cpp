import asyncio
from motor.motor_asyncio import AsyncIOMotorClient
import os
from dotenv import load_dotenv

load_dotenv()

MONGODB_URL = os.getenv("MONGODB_URL")

async def list_users():
    # tlsAllowInvalidCertificates=True for the 2026 date issue
    client = AsyncIOMotorClient(MONGODB_URL, tlsAllowInvalidCertificates=True)
    db = client.get_database(os.getenv("DATABASE_NAME", "ai_tutor_db"))
    
    print("\n--- Existing Users ---")
    users = await db.users.find().to_list(length=100)
    
    if not users:
        print("No users found in database.")
    
    for user in users:
        print(f"Username: {user.get('username')} | Email: {user.get('email')}")
    print("----------------------\n")

if __name__ == "__main__":
    asyncio.run(list_users())
