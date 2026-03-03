"""
Communications Module - REST API Routes

Endpoints for partner matching, queue management, and match operations.

Routes:
- POST /api/match/join-queue - Join waiting queue
- POST /api/match/leave-queue - Leave waiting queue
- GET /api/match/status - Check match status
- POST /api/match/end/{match_id} - End active match
- POST /api/match/report - Report user
- GET /api/match/stats - Get user's match statistics
"""

from fastapi import APIRouter, HTTPException, Header
from typing import Optional
from bson import ObjectId

from app.models.communications import (
    JoinQueueRequest,
    QueueStatusResponse,
    MatchFoundResponse,
    EndMatchRequest,
    EndMatchResponse,
    ReportUserRequest,
    ReportUserResponse,
    MatchPreferences,
    MatchParticipant
)
from app.models.user_report import UserReport, ReportStatus
from app.services.matching_service import matching_service
from app.utils.security import get_user_id_from_token
from app.database import db

router = APIRouter(prefix="/api/match", tags=["Partner Matching"])


# ==========================================
# QUEUE MANAGEMENT
# ==========================================

@router.post("/join-queue")
async def join_queue(
    request: JoinQueueRequest,
    authorization: Optional[str] = Header(None)
):
    """
    Join the waiting queue to find a language practice partner.
    
    **Authentication**: Required (Bearer token)
    
    **Returns**:
    - If matched immediately: match_id and partner info
    - If added to queue: queue position and estimated wait time
    """
    # Authenticate user
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Missing or invalid authorization header")
    
    token = authorization.replace("Bearer ", "")
    user_id = get_user_id_from_token(token)
    
    if not user_id:
        raise HTTPException(status_code=401, detail="Invalid token")
    
    # Get user info from database
    database = db.get_db()
    users = database["users"]
    
    try:
        user = await users.find_one({"_id": ObjectId(user_id)})
    except:
        raise HTTPException(status_code=400, detail="Invalid user ID")
    
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    # Check if user already has an active match
    active_match = await matching_service.get_active_match(user_id)
    if active_match:
        print(f"DEBUG: Join-queue failed. User {user_id} already has active match.")
        raise HTTPException(
            status_code=400,
            detail="You already have an active match. Please end it first."
        )
    
    # Prepare match preferences
    match_prefs = MatchPreferences(
        practice_mode=request.practice_mode,
        topics=request.topics
    )
    
    # Add to queue and attempt matching
    result = await matching_service.add_to_queue(
        user_id=user_id,
        username=user.get("username", ""),
        display_name=user.get("display_name", user.get("username", "User")),
        native_language=user.get("native_language", "English"),
        target_language=request.target_language,
        proficiency_level=request.proficiency_level,
        match_preferences=match_prefs,
        avatar_url=user.get("avatar_url"),
        socket_id=None  # Will be set when WebSocket connects
    )
    
    # Check if matched immediately
    if result.get("matched"):
        # Build WebSocket URL
        websocket_url = f"{config.WS_PROTOCOL}://{config.API_BASE_URL}/ws/chat/{result['match_id']}"
        
        return MatchFoundResponse(
            status="matched",
            match_id=result["match_id"],
            partner=MatchParticipant(**result["partner"]),
            websocket_url=websocket_url
        )
    
    # Return queue status
    return QueueStatusResponse(
        status="queued",
        position=result.get("position"),
        estimated_wait_seconds=result.get("estimated_wait_seconds")
    )


@router.post("/leave-queue")
async def leave_queue(authorization: Optional[str] = Header(None)):
    """
    Leave the waiting queue (cancel search).
    
    **Authentication**: Required (Bearer token)
    """
    # Authenticate user
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Missing or invalid authorization header")
    
    token = authorization.replace("Bearer ", "")
    user_id = get_user_id_from_token(token)
    
    if not user_id:
        raise HTTPException(status_code=401, detail="Invalid token")
    
    # Remove from queue
    removed = await matching_service.remove_from_queue(user_id)
    
    if not removed:
        raise HTTPException(status_code=404, detail="Not in queue")
    
    return {"status": "removed"}


@router.get("/status")
async def get_match_status(authorization: Optional[str] = Header(None)):
    print("DEBUG: get_match_status endpoint hit")
    """
    Check current match status for the user.
    
    **Authentication**: Required (Bearer token)
    
    **Returns**:
    - If matched: match_id and partner info
    - If in queue: queue position
    - If neither: no_match status
    """
    # Authenticate user
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Missing or invalid authorization header")
    
    token = authorization.replace("Bearer ", "")
    user_id = get_user_id_from_token(token)
    
    if not user_id:
        raise HTTPException(status_code=401, detail="Invalid token")
    
    # Check for active match
    active_match = await matching_service.get_active_match(user_id)
    
    if active_match:
        print(f"DEBUG: Match found for user {user_id} via polling")
        # Determine which user is the partner
        is_user1 = active_match["user1"]["user_id"] == user_id
        partner_data = active_match["user2"] if is_user1 else active_match["user1"]
        
        websocket_url = f"{config.WS_PROTOCOL}://{config.API_BASE_URL}/ws/chat/{str(active_match['_id'])}"
        
        return MatchFoundResponse(
            status="matched",
            match_id=str(active_match["_id"]),
            partner=MatchParticipant(**partner_data),
            websocket_url=websocket_url
        )
    
    # Check if in queue
    database = db.get_db()
    waiting_queue = database["waiting_queue"]
    
    queue_entry = await waiting_queue.find_one({"user_id": user_id})
    
    if queue_entry:
        position = await matching_service.get_queue_position(
            user_id,
            queue_entry["target_language"]
        )
        
        return QueueStatusResponse(
            status="waiting",
            position=position,
            estimated_wait_seconds=position * 15
        )
    
    # Not in queue, no active match
    return {"status": "no_match"}


# ==========================================
# MATCH OPERATIONS
# ==========================================

@router.post("/end/{match_id}", response_model=EndMatchResponse)
async def end_match(
    match_id: str,
    request: EndMatchRequest,
    authorization: Optional[str] = Header(None)
):
    """
    End an active match.
    
    **Authentication**: Required (Bearer token)
    
    **Reasons**: "finished", "skip", "report"
    """
    # Authenticate user
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Missing or invalid authorization header")
    
    token = authorization.replace("Bearer ", "")
    user_id = get_user_id_from_token(token)
    
    if not user_id:
        raise HTTPException(status_code=401, detail="Invalid token")
    
    # Verify user is part of this match
    try:
        database = db.get_db()
        active_matches = database["active_matches"]
        match = await active_matches.find_one({"_id": ObjectId(match_id)})
    except:
        raise HTTPException(status_code=400, detail="Invalid match ID")
    
    if not match:
        raise HTTPException(status_code=404, detail="Match not found")
    
    # Check if user is a participant
    if match["user1"]["user_id"] != user_id and match["user2"]["user_id"] != user_id:
        raise HTTPException(status_code=403, detail="Not a participant in this match")
    
    # Check if match is already ended
    if match["status"] == "ended":
        raise HTTPException(status_code=400, detail="Match already ended")
    
    # End the match
    duration = await matching_service.end_match(
        match_id=match_id,
        ended_by_user_id=user_id,
        reason=request.reason
    )
    
    if duration is None:
        raise HTTPException(status_code=500, detail="Failed to end match")
        
    # Broadcast match terminated event to all participants
    from app.routes.chat_websocket import manager
    await manager.broadcast_to_match(match_id, {
        "type": "match_ended",
        "reason": request.reason,
        "ended_by": user_id
    })
    
    return EndMatchResponse(
        status="ended",
        duration_seconds=duration
    )


# ==========================================
# USER REPORTS
# ==========================================

@router.post("/report", response_model=ReportUserResponse)
async def report_user(
    request: ReportUserRequest,
    authorization: Optional[str] = Header(None)
):
    """
    Report a user for inappropriate behavior.
    
    **Authentication**: Required (Bearer token)
    
    **Reasons**: "inappropriate_content", "harassment", "spam", "other"
    
    **Auto-block**: User gets blocked after 5 reports
    """
    # Authenticate user
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Missing or invalid authorization header")
    
    token = authorization.replace("Bearer ", "")
    user_id = get_user_id_from_token(token)
    
    if not user_id:
        raise HTTPException(status_code=401, detail="Invalid token")
    
    # Verify match exists
    try:
        database = db.get_db()
        active_matches = database["active_matches"]
        match = await active_matches.find_one({"_id": ObjectId(request.match_id)})
    except:
        raise HTTPException(status_code=400, detail="Invalid match ID")
    
    if not match:
        raise HTTPException(status_code=404, detail="Match not found")
    
    # Verify user is part of this match
    if match["user1"]["user_id"] != user_id and match["user2"]["user_id"] != user_id:
        raise HTTPException(status_code=403, detail="You were not part of this match")
    
    # Verify reported user is the other participant
    if match["user1"]["user_id"] != request.reported_user_id and \
       match["user2"]["user_id"] != request.reported_user_id:
        raise HTTPException(status_code=400, detail="Reported user is not part of this match")
    
    # Can't report yourself
    if request.reported_user_id == user_id:
        raise HTTPException(status_code=400, detail="Cannot report yourself")
    
    # Count existing reports for this user
    user_reports = database["user_reports"]
    existing_reports = await user_reports.count_documents({
        "reported_user_id": request.reported_user_id,
        "status": {"$in": ["pending", "reviewed"]}
    })
    
    # Create report
    report = UserReport(
        reporter_id=user_id,
        reported_user_id=request.reported_user_id,
        match_id=request.match_id,
        reason=request.reason,
        description=request.description,
        status=ReportStatus.PENDING,
        reported_user_total_reports=existing_reports + 1,
        auto_blocked=False
    )
    
    # Check if user should be auto-blocked (5+ reports)
    if existing_reports + 1 >= 5:
        report.auto_blocked = True
        # TODO: Implement actual blocking logic
        # For now, just mark the flag
    
    # Insert report
    result = await user_reports.insert_one(
        report.model_dump(by_alias=True, exclude={"id"})
    )
    
    report_id = str(result.inserted_id)
    
    # Automatically end the match
    await matching_service.end_match(
        match_id=request.match_id,
        ended_by_user_id=user_id,
        reason="report"
    )
    
    return ReportUserResponse(
        status="reported",
        report_id=report_id
    )


# ==========================================
# STATISTICS
# ==========================================

@router.get("/stats")
async def get_user_stats(authorization: Optional[str] = Header(None)):
    """
    Get user's match statistics.
    
    **Authentication**: Required (Bearer token)
    
    **Returns**: Total matches, hours practiced, messages sent, etc.
    """
    # Authenticate user
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Missing or invalid authorization header")
    
    token = authorization.replace("Bearer ", "")
    user_id = get_user_id_from_token(token)
    
    if not user_id:
        raise HTTPException(status_code=401, detail="Invalid token")
    
    # Get statistics
    stats = await matching_service.get_match_stats(user_id)
    
    return stats
