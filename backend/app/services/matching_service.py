"""
Matching Service for Communications Module

This service handles the core matching logic for pairing users together
based on their language preferences and proficiency levels.

Matching Priority:
1. Perfect Match - Language exchange (both benefit)
2. Same Level Match - Similar proficiency
3. Any Match - Same target language
"""

from datetime import datetime
from typing import Optional, Dict, Any
from bson import ObjectId

from app.database import db
from app.models.communications import (
    WaitingQueueEntry,
    ActiveMatch,
    MatchParticipant,
    MatchPreferences
)


class MatchingService:
    """Service for managing user matching and queue operations"""
    
    def __init__(self):
        self.database = None
    
    def _get_db(self):
        """Lazy load database"""
        if self.database is None:
            self.database = db.get_db()
        return self.database
    
    # ==========================================
    # QUEUE MANAGEMENT
    # ==========================================
    
    async def add_to_queue(
        self,
        user_id: str,
        username: str,
        display_name: str,
        native_language: str,
        target_language: str,
        proficiency_level: str,
        match_preferences: MatchPreferences,
        avatar_url: Optional[str] = None,
        socket_id: Optional[str] = None
    ) -> Dict[str, Any]:
        """
        Add a user to the waiting queue and attempt immediate matching.
        
        Returns:
            dict: {"matched": bool, "match_id": str, "partner": dict} if matched
                  {"queued": bool, "position": int} if added to queue
        """
        database = self._get_db()
        waiting_queue = database["waiting_queue"]
        
        # Ensure all IDs are strings for consistency in the queue/matches
        user_id_str = str(user_id)
        
        # Check if user already has an active match
        active_match = await self.get_active_match(user_id_str)
        if active_match:
             return {"matched": True, "match_id": str(active_match["_id"]), "partner": {}} # Already matched

        # Check if user is already in queue
        existing = await waiting_queue.find_one({"user_id": user_id_str})
        if not existing:
             # Also check by ObjectId for legacy entries
             try:
                 existing = await waiting_queue.find_one({"user_id": ObjectId(user_id_str)})
             except:
                 pass

        if existing:
            # Update their preferences instead of creating duplicate
            await waiting_queue.update_one(
                {"user_id": existing["user_id"]},
                {
                    "$set": {
                        "target_language": target_language,
                        "proficiency_level": proficiency_level,
                        "match_preferences": match_preferences.model_dump(),
                        "joined_at": datetime.utcnow(),
                        "status": "waiting",
                        "socket_id": socket_id
                    }
                }
            )
            user_id_str = existing["user_id"] # Use the one from DB (usually already a string)
        else:
            # Create new queue entry
            queue_entry = WaitingQueueEntry(
                user_id=user_id_str,
                username=username,
                display_name=display_name,
                avatar_url=avatar_url,
                native_language=native_language,
                target_language=target_language,
                proficiency_level=proficiency_level,
                match_preferences=match_preferences,
                socket_id=socket_id,
                status="waiting"
            )
            
            await waiting_queue.insert_one(queue_entry.model_dump(by_alias=True, exclude={"id"}))
        
        # Try to find immediate match
        match_result = await self.find_and_create_match(user_id_str, native_language, target_language, proficiency_level)
        
        if match_result:
            return {
                "matched": True,
                "match_id": match_result["match_id"],
                "partner": match_result["partner"]
            }
        
        # No immediate match - return queue position
        position = await self.get_queue_position(user_id, target_language)
        
        return {
            "queued": True,
            "position": position,
            "estimated_wait_seconds": position * 15  # Rough estimate
        }
    
    async def remove_from_queue(self, user_id: str) -> bool:
        """
        Remove a user from the waiting queue.
        
        Returns:
            bool: True if user was removed, False if not found
        """
        database = self._get_db()
        waiting_queue = database["waiting_queue"]
        
        result = await waiting_queue.delete_one({"user_id": user_id})
        return result.deleted_count > 0
    
    async def get_queue_position(self, user_id: str, target_language: str) -> int:
        """Get user's approximate position in queue"""
        database = self._get_db()
        waiting_queue = database["waiting_queue"]
        
        user_entry = await waiting_queue.find_one({"user_id": user_id})
        if not user_entry:
            return 0
        
        # Count users who joined before this user
        earlier_count = await waiting_queue.count_documents({
            "target_language": target_language,
            "status": "waiting",
            "joined_at": {"$lt": user_entry["joined_at"]}
        })
        
        return earlier_count + 1
    
    # ==========================================
    # MATCHING LOGIC
    # ==========================================
    
    async def find_match(
        self,
        user_id: str,
        native_language: str,
        target_language: str,
        proficiency_level: str
    ) -> Optional[Dict[str, Any]]:
        """
        Find the best match for a user using priority-based matching.
        
        Priority:
        1. Perfect Match - Partner speaks target_language natively and wants to learn user's native
        2. Same Level - Both learning same language, similar proficiency
        3. Any Match - Anyone practicing same language
        
        Args:
            user_id: Current user's ID
            native_language: User's native language
            target_language: Language user wants to practice
            proficiency_level: User's proficiency level
        
        Returns:
            Matched user's queue entry or None
        """
        database = self._get_db()
        waiting_queue = database["waiting_queue"]
        
        user_id_str = str(user_id)
        
        # Support both String and ObjectId for exclusion
        query_exclusion = {"$nin": [user_id_str]}
        try:
            query_exclusion["$nin"].append(ObjectId(user_id_str))
        except:
            pass

        # Priority 1: Perfect language exchange match
        perfect_match = await waiting_queue.find_one({
            "user_id": query_exclusion,
            "native_language": target_language,
            "target_language": native_language,
            "status": "waiting"
        })
        
        if perfect_match:
            return perfect_match
        
        # Priority 2: Same proficiency level match
        similar_match = await waiting_queue.find_one({
            "user_id": query_exclusion,
            "target_language": target_language,
            "proficiency_level": proficiency_level,
            "status": "waiting"
        })
        
        if similar_match:
            return similar_match
        
        # Priority 3: Any available match
        any_match = await waiting_queue.find_one({
            "user_id": query_exclusion,
            "target_language": target_language,
            "status": "waiting"
        })
        
        return any_match
    
    async def find_and_create_match(
        self,
        user_id: str,
        native_language: str,
        target_language: str,
        proficiency_level: str
    ) -> Optional[Dict[str, Any]]:
        """
        Find a match and create the active match document.
        
        Returns:
            dict: {"match_id": str, "partner": dict} if match created
            None if no match found
        """
        # Find match
        partner = await self.find_match(user_id, native_language, target_language, proficiency_level)
        
        if not partner:
            return None
        
        # Get current user's info from queue
        database = self._get_db()
        waiting_queue = database["waiting_queue"]
        
        current_user = await waiting_queue.find_one({"user_id": user_id})
        if not current_user:
            return None
        
        # Create the match
        match_id = await self.create_match(current_user, partner)
        
        # Build partner response
        partner_info = MatchParticipant(
            user_id=str(partner["user_id"]),
            username=partner["username"],
            display_name=partner["display_name"],
            avatar_url=partner.get("avatar_url"),
            socket_id=partner.get("socket_id"),
            language=partner["native_language"]
        )
        
        return {
            "match_id": match_id,
            "partner": partner_info.model_dump()
        }
    
    async def create_match(self, user1_data: dict, user2_data: dict) -> str:
        """
        Create an active match between two users.
        
        Args:
            user1_data: First user's queue entry
            user2_data: Second user's queue entry
        
        Returns:
            str: The created match_id
        """
        database = self._get_db()
        active_matches = database["active_matches"]
        waiting_queue = database["waiting_queue"]
        
        # Build participant objects
        user1_participant = MatchParticipant(
            user_id=str(user1_data["user_id"]),
            username=user1_data["username"],
            display_name=user1_data["display_name"],
            avatar_url=user1_data.get("avatar_url"),
            socket_id=user1_data.get("socket_id"),
            language=user1_data["native_language"]
        )
        
        user2_participant = MatchParticipant(
            user_id=str(user2_data["user_id"]),
            username=user2_data["username"],
            display_name=user2_data["display_name"],
            avatar_url=user2_data.get("avatar_url"),
            socket_id=user2_data.get("socket_id"),
            language=user2_data["native_language"]
        )
        
        # Create match document
        match_doc = ActiveMatch(
            user1=user1_participant,
            user2=user2_participant,
            practice_language=user1_data["target_language"],
            matched_at=datetime.utcnow(),
            text_chat_active=True,
            voice_chat_active=False,
            video_chat_active=False,
            messages=[],
            status="active"
        )
        
        # Insert into database
        result = await active_matches.insert_one(
            match_doc.model_dump(by_alias=True, exclude={"id"})
        )
        match_id = str(result.inserted_id)
        
        # Remove both users from waiting queue
        await waiting_queue.delete_many({
            "user_id": {"$in": [user1_data["user_id"], user2_data["user_id"]]}
        })
        
        return match_id
    
    # ==========================================
    # MATCH OPERATIONS
    # ==========================================
    
    async def get_active_match(self, user_id: str) -> Optional[Dict[str, Any]]:
        """
        Get user's current active match if any.
        
        Returns:
            Active match document or None
        """
        database = self._get_db()
        active_matches = database["active_matches"]
        
        # Ensure user_id is a string for the query, but also support ObjectId just in case
        # because some old records might have stored them as ObjectIds
        user_id_str = str(user_id)
        
        # DEBUG LOGGING
        print(f"DEBUG: Checking active match for user_id: {user_id_str}")
        
        query = {
            "status": "active",
            "$or": [
                {"user1.user_id": user_id_str},
                {"user2.user_id": user_id_str}
            ]
        }
        
        match = await active_matches.find_one(query)
        
        # If not found by string, try by ObjectId (fallback for legacy/inconsistent data)
        if not match:
            try:
                user_id_oid = ObjectId(user_id_str)
                query_oid = {
                    "status": "active",
                    "$or": [
                        {"user1.user_id": user_id_oid},
                        {"user2.user_id": user_id_oid}
                    ]
                }
                match = await active_matches.find_one(query_oid)
            except:
                pass
        
        if match:
            print(f"DEBUG: Found match {match['_id']} for user {user_id_str}")
        else:
            print(f"DEBUG: No active match found for user {user_id_str}")
            
        return match
    
    async def end_match(
        self,
        match_id: str,
        ended_by_user_id: str,
        reason: str = "finished"
    ) -> Optional[int]:
        """
        End an active match.
        
        Args:
            match_id: The match to end
            ended_by_user_id: User who ended the match
            reason: Reason for ending ("finished", "skip", "report")
        
        Returns:
            Duration in seconds or None if match not found
        """
        database = self._get_db()
        active_matches = database["active_matches"]
        match_history = database["match_history"]
        
        # Get the match
        try:
            match = await active_matches.find_one({"_id": ObjectId(match_id)})
        except:
            return None
        
        if not match or match["status"] != "active":
            return None
        
        # Calculate duration
        ended_at = datetime.utcnow()
        duration = (ended_at - match["matched_at"]).total_seconds()
        
        # Update match status
        await active_matches.update_one(
            {"_id": ObjectId(match_id)},
            {
                "$set": {
                    "status": "ended",
                    "ended_at": ended_at,
                    "ended_by": ended_by_user_id
                }
            }
        )
        
        # Archive to match history
        history_doc = {
            "match_id": match_id,
            "user1_id": match["user1"]["user_id"],
            "user2_id": match["user2"]["user_id"],
            "practice_language": match["practice_language"],
            "duration_seconds": int(duration),
            "started_at": match["matched_at"],
            "ended_at": ended_at,
            "message_count": len(match.get("messages", [])),
            "voice_used": match.get("voice_chat_active", False),
            "video_used": match.get("video_chat_active", False),
            "ended_by": "user1" if ended_by_user_id == match["user1"]["user_id"] else "user2",
            "end_reason": reason
        }
        
        await match_history.insert_one(history_doc)
        
        return int(duration)
    
    async def get_match_stats(self, user_id: str) -> Dict[str, Any]:
        """
        Get statistics about a user's matches.
        
        Returns:
            dict: Stats including total matches, total time, etc.
        """
        database = self._get_db()
        match_history = database["match_history"]
        
        # Get all user's matches
        matches = await match_history.find({
            "$or": [
                {"user1_id": user_id},
                {"user2_id": user_id}
            ]
        }).to_list(length=None)
        
        total_matches = len(matches)
        total_duration = sum(m["duration_seconds"] for m in matches)
        total_messages = sum(m.get("message_count", 0) for m in matches)
        
        return {
            "total_matches": total_matches,
            "total_duration_seconds": total_duration,
            "total_duration_hours": round(total_duration / 3600, 1),
            "total_messages": total_messages,
            "average_duration_seconds": int(total_duration / total_matches) if total_matches > 0 else 0
        }


# Singleton instance
matching_service = MatchingService()
