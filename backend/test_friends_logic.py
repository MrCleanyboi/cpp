import asyncio
import os
import sys
from bson import ObjectId

# Add current directory to path
sys.path.append(os.getcwd())

from app.database import db
from app.routes.friends import send_friend_request

async def test_api():
    try:
        db.connect_to_database()
        database = db.get_db()
        users_col = database["users"]
        
        # Find two users
        all_users = await users_col.find({}).to_list(length=10)
        if len(all_users) < 2:
            print("Not enough users to test")
            return
            
        u1 = all_users[0]
        u2 = all_users[1]
        
        u1_id = str(u1["_id"])
        u2_id = str(u2["_id"])
        
        print(f"Testing: {u1['username']} ({u1_id}) sending to {u2['username']} ({u2_id})")
        
        # Call the logic directly
        # Note: Depends(get_current_user_id) won't work in direct call, 
        # but we can simulate the function call if we mock the dependency
        # For simplicity, let's just do the DB logic manually or mock the call
        
        # Let's just do exactly what the route does
        from app.models.user import FriendRequest
        
        # 1. Update target user
        new_request = FriendRequest(
            from_user_id=u1_id,
            from_username=u1.get("username"),
            from_display_name=u1.get("display_name") or u1.get("username")
        ).model_dump()
        
        result = await users_col.update_one(
            {"_id": ObjectId(u2_id)},
            {"$push": {"friend_requests": new_request}}
        )
        
        print(f"Update result: matched={result.matched_count}, modified={result.modified_count}")
        
        # Verify
        check = await users_col.find_one({"_id": ObjectId(u2_id)})
        print(f"Target user now has {len(check.get('friend_requests', []))} pending requests")
        
    except Exception as e:
        print(f"Error: {e}")
    finally:
        db.close_database_connection()

if __name__ == "__main__":
    asyncio.run(test_api())
