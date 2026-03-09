
import asyncio
from motor.motor_asyncio import AsyncIOMotorClient
import os
from pprint import pprint
from bson import ObjectId

async def debug_matching():
    mongo_url = "mongodb://localhost:27017"
    db_name = "ai_tutor_db"
    
    client = AsyncIOMotorClient(mongo_url)
    db = client[db_name]
    
    print("--- WAITING QUEUE ---")
    queue_entries = await db["waiting_queue"].find({}).to_list(length=100)
    for entry in queue_entries:
        uid = entry.get('user_id')
        print(f"User: {entry.get('username')} ID: {uid} (Type: {type(uid)})")
        
    print("\n--- ACTIVE MATCHES ---")
    active_matches = await db["active_matches"].find({"status": "active"}).to_list(length=100)
    for match in active_matches:
        u1id = match.get('user1', {}).get('user_id')
        u2id = match.get('user2', {}).get('user_id')
        print(f"Match ID: {match.get('_id')} Participant 1 ID: {u1id} (Type: {type(u1id)}) Participant 2 ID: {u2id} (Type: {type(u2id)})")
        
    print("\n--- USERS COLLECTION ---")
    users = await db["users"].find({}).limit(5).to_list(length=5)
    for user in users:
        print(f"Username: {user.get('username')} _id: {user.get('_id')} (Type: {type(user.get('_id'))})")

if __name__ == "__main__":
    asyncio.run(debug_matching())
