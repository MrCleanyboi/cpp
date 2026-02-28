import asyncio
import os
import sys
from bson import ObjectId

# Add current directory to path so we can import 'app'
sys.path.append(os.getcwd())

from app.database import db

async def debug_users():
    try:
        db.connect_to_database()
        database = db.get_db()
        users_col = database["users"]
        
        print("\n--- DEBUG: Users and Social Data ---")
        cursor = users_col.find({})
        async for user in cursor:
            username = user.get("username", "N/A")
            uid = str(user.get("_id"))
            friends = user.get("friends", [])
            reqs = user.get("friend_requests", [])
            
            print(f"User: {username} ({uid})")
            print(f"  - Friends: {friends}")
            print(f"  - Pending Requests: {len(reqs)}")
            for r in reqs:
                print(f"    - From: {r.get('from_username')} ({r.get('from_user_id')}) Status: {r.get('status')}")
        print("------------------------------------\n")
        
    except Exception as e:
        print(f"Error: {e}")
    finally:
        db.close_database_connection()

if __name__ == "__main__":
    asyncio.run(debug_users())
