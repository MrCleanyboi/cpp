"""
Communications Module Models

This module exports all Pydantic models for the real-time communications feature.

Collections:
- waiting_queue: Users waiting to be matched
- active_matches: Ongoing conversations
- match_history: Completed sessions (analytics)
- user_reports: Safety/moderation system
"""

# Waiting Queue
from .waiting_queue import (
    WaitingQueueEntry,
    MatchPreferences,
    JoinQueueRequest,
    QueueStatusResponse
)

# Active Matches
from .active_match import (
    ActiveMatch,
    MatchParticipant,
    ChatMessage,
    MatchFoundResponse,
    EndMatchRequest,
    EndMatchResponse
)

# Match History
from .match_history import MatchHistory

# User Reports
from .user_report import (
    UserReport,
    ReportReason,
    ReportStatus,
    ReportUserRequest,
    ReportUserResponse
)

__all__ = [
    # Waiting Queue
    "WaitingQueueEntry",
    "MatchPreferences",
    "JoinQueueRequest",
    "QueueStatusResponse",
    
    # Active Matches
    "ActiveMatch",
    "MatchParticipant",
    "ChatMessage",
    "MatchFoundResponse",
    "EndMatchRequest",
    "EndMatchResponse",
    
    # Match History
    "MatchHistory",
    
    # User Reports
    "UserReport",
    "ReportReason",
    "ReportStatus",
    "ReportUserRequest",
    "ReportUserResponse",
]
