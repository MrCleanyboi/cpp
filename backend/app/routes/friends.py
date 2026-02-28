from fastapi import APIRouter, HTTPException, Header, Depends
from typing import Optional, List
from bson import ObjectId
from datetime import datetime

from app.database import db
from app.utils.security import get_user_id_from_token
from app.models.user import FriendRequest

router = APIRouter(prefix="/api/friends", tags=["Friends"])

async def get_current_user_id(authorization: Optional[str] = Header(None)):
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Missing or invalid authorization header")
    
    token = authorization.replace("Bearer ", "")
    user_id = get_user_id_from_token(token)
    if not user_id:
        raise HTTPException(status_code=401, detail="Invalid token")
    return user_id

@router.post("/request/{to_user_id}")
async def send_friend_request(to_user_id: str, current_user_id: str = Depends(get_current_user_id)):
    print(f"DEBUG: Friend request from {current_user_id} to {to_user_id}")
    if to_user_id == current_user_id:
        raise HTTPException(status_code=400, detail="Cannot add yourself as a friend")
    
    database = db.get_db()
    users = database["users"]
    
    # Get current user info for the request
    sender = await users.find_one({"_id": ObjectId(current_user_id)})
    if not sender:
        raise HTTPException(status_code=404, detail="Current user not found")
    
    # Check if already friends
    if to_user_id in sender.get("friends", []):
        return {"status": "already_friends"}
    
    # Check if already sent
    target = await users.find_one({"_id": ObjectId(to_user_id)})
    if not target:
        raise HTTPException(status_code=404, detail="Target user not found")
    
    for req in target.get("friend_requests", []):
        if req.get("from_user_id") == current_user_id:
            return {"status": "request_already_sent"}
            
    # Add friend request to target user
    new_request = FriendRequest(
        from_user_id=current_user_id,
        from_username=sender.get("username"),
        from_display_name=sender.get("display_name") or sender.get("username")
    ).model_dump()
    
    await users.update_one(
        {"_id": ObjectId(to_user_id)},
        {"$push": {"friend_requests": new_request}}
    )
    
    # Notify target user via WebSocket if they are online
    from app.routes.websocket import manager
    print(f"DEBUG: Notifying user {to_user_id} via WS")
    await manager.send_personal_message(
        {"type": "friend_request", "from_display_name": sender.get("display_name") or sender.get("username")},
        to_user_id
    )
    
    return {"status": "request_sent"}

@router.post("/accept/{from_user_id}")
async def accept_friend_request(from_user_id: str, current_user_id: str = Depends(get_current_user_id)):
    database = db.get_db()
    users = database["users"]
    
    # Add to current user's friends, remove from requests
    res = await users.update_one(
        {"_id": ObjectId(current_user_id)},
        {
            "$addToSet": {"friends": from_user_id},
            "$pull": {"friend_requests": {"from_user_id": from_user_id}}
        }
    )
    
    if res.modified_count == 0:
        raise HTTPException(status_code=404, detail="Friend request not found")
        
    # Add current user to friend's friends list
    await users.update_one(
        {"_id": ObjectId(from_user_id)},
        {"$addToSet": {"friends": current_user_id}}
    )
    
    return {"status": "accepted"}

@router.get("/")
async def list_friends(current_user_id: str = Depends(get_current_user_id)):
    database = db.get_db()
    users = database["users"]
    
    user = await users.find_one({"_id": ObjectId(current_user_id)})
    friend_ids = user.get("friends", [])
    
    friends_list = []
    for fid in friend_ids:
        f_user = await users.find_one({"_id": ObjectId(fid)})
        if f_user:
            friends_list.append({
                "id": str(f_user["_id"]),
                "username": f_user.get("username"),
                "display_name": f_user.get("display_name") or f_user.get("username"),
                "avatar_url": f_user.get("avatar_url")
            })
            
    return friends_list

@router.get("/requests")
async def list_requests(current_user_id: str = Depends(get_current_user_id)):
    print(f"DEBUG: Listing requests for {current_user_id}")
    database = db.get_db()
    users = database["users"]
    
    user = await users.find_one({"_id": ObjectId(current_user_id)})
    return user.get("friend_requests", [])

@router.post("/call/{friend_id}")
async def call_friend(friend_id: str, current_user_id: str = Depends(get_current_user_id)):
    database = db.get_db()
    users = database["users"]
    active_matches = database["active_matches"]
    
    caller = await users.find_one({"_id": ObjectId(current_user_id)})
    receiver = await users.find_one({"_id": ObjectId(friend_id)})
    
    if not caller or not receiver:
        raise HTTPException(status_code=404, detail="User not found")

    # Check for existing active match
    existing_match = await active_matches.find_one({
        "status": "active",
        "$or": [
            {"user1.user_id": current_user_id, "user2.user_id": friend_id},
            {"user1.user_id": friend_id, "user2.user_id": current_user_id}
        ]
    })
    
    if existing_match:
        match_id = str(existing_match["_id"])
    else:
        # Create a new active match for this direct call
        from app.models.communications import MatchParticipant, ActiveMatch
        
        user1_p = MatchParticipant(
            user_id=current_user_id,
            username=caller.get("username", "Unknown"),
            display_name=caller.get("display_name") or caller.get("username", "Unknown"),
            language="English" # Default
        )
        
        user2_p = MatchParticipant(
            user_id=friend_id,
            username=receiver.get("username", "Unknown"),
            display_name=receiver.get("display_name") or receiver.get("username", "Unknown"),
            language="English" # Default
        )
        
        match_doc = ActiveMatch(
            user1=user1_p,
            user2=user2_p,
            practice_language="Direct Call",
            status="active"
        )
        
        res = await active_matches.insert_one(match_doc.model_dump(by_alias=True, exclude={"id"}))
        match_id = str(res.inserted_id)
    
    # Notify target user via WebSocket if they are online
    from app.routes.websocket import manager
    await manager.send_personal_message(
        {
            "type": "incoming_call",
            "from_user_id": current_user_id,
            "from_display_name": caller.get("display_name") or caller.get("username"),
            "match_id": match_id
        },
        friend_id
    )
    
    return {"status": "calling", "match_id": match_id}
