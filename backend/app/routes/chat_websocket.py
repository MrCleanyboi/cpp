"""
WebSocket Chat Server for Communications Module

Handles real-time text chat between matched users.

Features:
- Connection management (connect/disconnect)
- Message broadcasting
- Typing indicators
- Partner disconnect notifications
"""

from fastapi import APIRouter, WebSocket, WebSocketDisconnect, Query
from typing import Dict, Optional
from datetime import datetime
from bson import ObjectId
import json
import logging
import sys

def debug_log(message):
    print(f"WS_DEBUG: {message}", flush=True)
    sys.stdout.flush()

from app.database import db
from app.utils.security import get_user_id_from_token

router = APIRouter(tags=["WebSocket Chat"])

# Connection manager to track active WebSocket connections
class ConnectionManager:
    """Manages WebSocket connections for active matches"""
    
    def __init__(self):
        # Format: {match_id: {user_id: websocket}}
        self.active_connections: Dict[str, Dict[str, WebSocket]] = {}
    
    async def connect(self, match_id: str, user_id: str, websocket: WebSocket):
        """Accept WebSocket connection and add to active connections"""
        await websocket.accept()
        
        if match_id not in self.active_connections:
            self.active_connections[match_id] = {}
        
        self.active_connections[match_id][user_id] = websocket
    
    def disconnect(self, match_id: str, user_id: str):
        """Remove connection from active connections"""
        if match_id in self.active_connections:
            if user_id in self.active_connections[match_id]:
                del self.active_connections[match_id][user_id]
            
            # Clean up empty match entries
            if not self.active_connections[match_id]:
                del self.active_connections[match_id]
    
    async def send_to_partner(self, match_id: str, sender_id: str, message: dict):
        """Send message to the partner (not the sender)"""
        if match_id not in self.active_connections:
            return False
        
        # Find partner's connection
        for user_id, connection in self.active_connections[match_id].items():
            if user_id != sender_id:
                try:
                    await connection.send_json(message)
                    return True
                except Exception as e:
                    print(f"Error sending to partner: {e}")
                    return False
        
        return False
    
    async def broadcast_to_match(self, match_id: str, message: dict):
        """Send message to all participants in a match"""
        if match_id not in self.active_connections:
            return
        
        disconnected = []
        for user_id, connection in self.active_connections[match_id].items():
            try:
                await connection.send_json(message)
            except Exception:
                disconnected.append(user_id)
        
        # Clean up disconnected users
        for user_id in disconnected:
            self.disconnect(match_id, user_id)
    
    def is_partner_connected(self, match_id: str, user_id: str) -> bool:
        """Check if partner is connected"""
        if match_id not in self.active_connections:
            return False
        
        # Count connections other than this user
        other_connections = [uid for uid in self.active_connections[match_id].keys() if uid != user_id]
        return len(other_connections) > 0


# Singleton connection manager
manager = ConnectionManager()


@router.websocket("/ws/chat/{match_id}")
async def websocket_chat_endpoint(
    websocket: WebSocket,
    match_id: str,
    token: Optional[str] = Query(None)
):
    """
    WebSocket endpoint for real-time text chat.
    
    URL: ws://localhost:8000/ws/chat/{match_id}?token={jwt_token}
    
    Client → Server Message Types:
    - message: Send text message
    - typing: Typing indicator
    
    Server → Client Message Types:
    - message: Received text message
    - partner_disconnected: Partner left
    - match_ended: Match was ended
    - error: Error occurred
    """
    
    try:
        # Authenticate user
        debug_log(f"Connection attempt. Match: {match_id}")
        if not token:
            debug_log("No token provided")
            await websocket.close(code=1008, reason="Authentication required")
            return
        
        try:
            user_id = get_user_id_from_token(token)
            debug_log(f"Token resolved to User ID: {user_id}")
        except Exception as e:
            debug_log(f"Token decode error: {e}")
            await websocket.close(code=1008, reason="Invalid token")
            return

        if not user_id:
            debug_log("Invalid token (no user_id)")
            await websocket.close(code=1008, reason="Invalid token")
            return
        
        # Verify match exists and user is a participant
        database = db.get_db()
        active_matches = database["active_matches"]
        
        try:
            match = await active_matches.find_one({"_id": ObjectId(match_id)})
            debug_log(f"Match found: {match is not None}")
        except Exception as e:
            debug_log(f"Invalid match ID format: {e}")
            await websocket.close(code=1008, reason="Invalid match ID")
            return
        
        if not match:
            debug_log("Match not found in DB")
            await websocket.close(code=1008, reason="Match not found")
            return
        
        # Check if user is a participant
        if match["user1"]["user_id"] != user_id and match["user2"]["user_id"] != user_id:
            debug_log(f"User {user_id} not in match {match_id}")
            await websocket.close(code=1008, reason="Not a participant")
            return
        
        # Check if match is still active
        if match["status"] != "active":
            debug_log(f"Match status is {match['status']}")
            await websocket.close(code=1008, reason="Match already ended")
            return
        
        # Get user info
        is_user1 = match["user1"]["user_id"] == user_id
        user_info = match["user1"] if is_user1 else match["user2"]
        partner_info = match["user2"] if is_user1 else match["user1"]
        
        # Connect to WebSocket
        debug_log("Accepting WebSocket connection")
        await manager.connect(match_id, user_id, websocket)
    except Exception as e:
        debug_log(f"CRITICAL ERROR in WebSocket endpoint: {e}")
        traceback.print_exc()
        await websocket.close(code=1011, reason="Internal Server Error")
        return # Added return to prevent further execution if an error occurs during setup
    
    # Send connection confirmation
    await websocket.send_json({
        "type": "connected",
        "match_id": match_id,
        "partner": {
            "user_id": partner_info["user_id"],
            "username": partner_info["username"],
            "display_name": partner_info["display_name"],
            "language": partner_info["language"]
        }
    })
    
    # Notify partner that user connected (if they're online)
    if manager.is_partner_connected(match_id, user_id):
        await manager.send_to_partner(match_id, user_id, {
            "type": "partner_connected",
            "user_id": user_id
        })
    
    try:
        while True:
            # Receive message from client
            data = await websocket.receive_json()
            message_type = data.get("type")
            
            # Handle different message types
            if message_type == "message":
                # Text message
                text = data.get("text", "").strip()
                if not text:
                    continue
                
                # Create message document
                message_doc = {
                    "sender_id": user_id,
                    "text": text,
                    "timestamp": datetime.utcnow()
                }
                
                # Save to database (append to messages array)
                await active_matches.update_one(
                    {"_id": ObjectId(match_id)},
                    {"$push": {"messages": message_doc}}
                )
                
                # Send to partner
                partner_message = {
                    "type": "message",
                    "sender_id": user_id,
                    "sender_name": user_info["display_name"],
                    "text": text,
                    "timestamp": message_doc["timestamp"].isoformat()
                }
                
                await manager.send_to_partner(match_id, user_id, partner_message)
            
            elif message_type == "typing":
                # Typing indicator
                is_typing = data.get("is_typing", False)
                
                await manager.send_to_partner(match_id, user_id, {
                    "type": "typing",
                    "user_id": user_id,
                    "is_typing": is_typing
                })
            
            elif message_type == "ping":
                # Keep-alive ping
                await websocket.send_json({"type": "pong"})

            elif message_type in ["offer", "answer", "ice_candidate"]:
                # WebRTC Signaling: Relay blindly to partner
                # We don't store these in the DB as they are ephemeral
                debug_log(f"Broadcasting {message_type} signal from {user_id}")
                await manager.send_to_partner(match_id, user_id, data)
            
            else:
                # Unknown message type
                await websocket.send_json({
                    "type": "error",
                    "message": f"Unknown message type: {message_type}"
                })
    
    except WebSocketDisconnect:
        # User disconnected
        manager.disconnect(match_id, user_id)
        
        # Notify partner
        if manager.is_partner_connected(match_id, user_id):
            await manager.send_to_partner(match_id, user_id, {
                "type": "partner_disconnected",
                "user_id": user_id
            })
    
    except Exception as e:
        # Error occurred
        print(f"WebSocket error for user {user_id} in match {match_id}: {e}")
        manager.disconnect(match_id, user_id)
        
        try:
            await websocket.send_json({
                "type": "error",
                "message": "An error occurred"
            })
        except:
            pass



