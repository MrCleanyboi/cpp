from motor.motor_asyncio import AsyncIOMotorClient
import asyncio
from bson import ObjectId

async def check_match():
    try:
        client = AsyncIOMotorClient("mongodb://localhost:27017")
        db = client["ai_tutor_db"]
        active_matches = db["active_matches"]
        
        match_id = "69aeed433d60f7b3e27b6630"
        match = await active_matches.find_one({"_id": ObjectId(match_id)})
        
        if match:
            print(f"Match found: {match_id}")
            print(f"Status: {match.get('status')}")
            print(f"User 1: {match.get('user1')}")
            print(f"User 2: {match.get('user2')}")
        else:
            print(f"Match NOT found: {match_id}")
        
        client.close()
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    asyncio.run(check_match())
