import asyncio
import os
from dotenv import load_dotenv
from motor.motor_asyncio import AsyncIOMotorClient

load_dotenv()

async def main():
    client = AsyncIOMotorClient(os.getenv("MONGODB_URL", "mongodb://localhost:27017"))
    db = client[os.getenv("DATABASE_NAME", "ai_tutor_db")]
    
    users = await db.users.find().to_list(None)
    print(f"Found {len(users)} users.")
    
    for u in users:
        print(f"User: {u.get('username')}, Display: {u.get('display_name')}")
        user_id = str(u["_id"])
        
        # Check if gamification exists
        gamification = await db.user_gamifications.find_one({"user_id": user_id})
        
        if gamification:
            res = await db.user_gamifications.update_one(
                {"user_id": user_id},
                {"$inc": {"gems": 500}}
            )
            print(" - Updated existing gamification.")
        else:
            await db.user_gamifications.insert_one({
                "user_id": user_id,
                "xp": 0,
                "level": 1,
                "streak_days": 1,
                "gems": 500,
                "hearts": 5,
                "last_active": None,
                "equipped_banner": "default",
                "equipped_title": "Novice",
                "equipped_effect": "none",
                "inventory": []
            })
            print(" - Created new gamification doc with 500 gems.")

if __name__ == "__main__":
    asyncio.run(main())
