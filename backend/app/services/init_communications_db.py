"""
Database initialization script for Communications Module

Creates MongoDB collections and indexes for optimal query performance.
Run this once to set up the database schema.
"""

from app.database import db
from datetime import datetime, timedelta

async def init_communications_collections():
    """
    Initialize all collections and indexes for the communications module.
    This should be run once during deployment or app startup.
    """
    
    # Get database instance
    database = db.get_db()
    
    # ========================================
    # 1. WAITING_QUEUE COLLECTION
    # ========================================
    waiting_queue = database["waiting_queue"]
    
    # Index for fast matching by target language and status
    await waiting_queue.create_index(
        [("target_language", 1), ("status", 1)],
        name="target_language_status_idx"
    )
    
    # Index to prevent duplicate queue entries
    await waiting_queue.create_index(
        [("user_id", 1)],
        unique=True,
        name="user_id_unique_idx"
    )
    
    # TTL index - auto-remove entries older than 15 minutes
    await waiting_queue.create_index(
        [("joined_at", 1)],
        expireAfterSeconds=900,  # 15 minutes
        name="joined_at_ttl_idx"
    )
    
    print("✅ Created indexes for waiting_queue collection")
    
    # ========================================
    # 2. ACTIVE_MATCHES COLLECTION
    # ========================================
    active_matches = database["active_matches"]
    
    # Index to quickly find a user's active match
    await active_matches.create_index(
        [("user1.user_id", 1)],
        name="user1_idx"
    )
    
    await active_matches.create_index(
        [("user2.user_id", 1)],
        name="user2_idx"
    )
    
    # Index for analytics - active matches by time
    await active_matches.create_index(
        [("status", 1), ("matched_at", 1)],
        name="status_matched_at_idx"
    )
    
    # Compound index for finding active match by user
    await active_matches.create_index(
        [("status", 1), ("user1.user_id", 1), ("user2.user_id", 1)],
        name="active_match_lookup_idx"
    )
    
    print("✅ Created indexes for active_matches collection")
    
    # ========================================
    # 3. MATCH_HISTORY COLLECTION
    # ========================================
    match_history = database["match_history"]
    
    # Index for user's match history
    await match_history.create_index(
        [("user1_id", 1), ("ended_at", -1)],
        name="user1_history_idx"
    )
    
    await match_history.create_index(
        [("user2_id", 1), ("ended_at", -1)],
        name="user2_history_idx"
    )
    
    # Index for analytics - matches by language and date
    await match_history.create_index(
        [("practice_language", 1), ("ended_at", -1)],
        name="language_date_idx"
    )
    
    print("✅ Created indexes for match_history collection")
    
    # ========================================
    # 4. USER_REPORTS COLLECTION
    # ========================================
    user_reports = database["user_reports"]
    
    # Index to quickly count reports for a user
    await user_reports.create_index(
        [("reported_user_id", 1), ("status", 1)],
        name="reported_user_status_idx"
    )
    
    # Index for moderators to review pending reports
    await user_reports.create_index(
        [("status", 1), ("reported_at", -1)],
        name="moderation_queue_idx"
    )
    
    # Index by reporter (to prevent spam reports)
    await user_reports.create_index(
        [("reporter_id", 1), ("reported_at", -1)],
        name="reporter_history_idx"
    )
    
    print("✅ Created indexes for user_reports collection")
    
    print("\n🎉 All communications module collections initialized successfully!")
    print("\nCollections created:")
    print("  • waiting_queue (with TTL: 15 min)")
    print("  • active_matches")
    print("  • match_history")
    print("  • user_reports")

# Helper function to drop all communications collections (for testing)
async def drop_communications_collections():
    """
    WARNING: This will delete all communications data!
    Only use for testing or resetting the database.
    """
    database = db.get_db()
    
    await database["waiting_queue"].drop()
    await database["active_matches"].drop()
    await database["match_history"].drop()
    await database["user_reports"].drop()
    
    print("⚠️ All communications collections dropped!")

if __name__ == "__main__":
    # For testing - run this file directly
    import asyncio
    
    async def main():
        db.connect_to_database()
        await init_communications_collections()
        db.close_database_connection()
    
    asyncio.run(main())
