#!/usr/bin/env python3
"""
Reset the database to clean state for demos
Drops all tables and recreates them with sample data
"""

import os
import psycopg2


def reset_database():
    """Reset PostgreSQL database to initial state"""
    try:
        # Connect to database
        conn = psycopg2.connect(
            host=os.environ.get("DB_HOST", "localhost"),
            port=os.environ.get("DB_PORT", "5432"),
            database=os.environ.get("DB_NAME", "typo_payments"),
            user=os.environ.get("DB_USER", "typo_admin"),
            password=os.environ.get("DB_PASSWORD", "insecure_password_123"),
        )
        cursor = conn.cursor()

        print("🔄 Dropping existing tables...")
        
        # Drop tables in correct order (respecting foreign keys)
        cursor.execute("DROP TABLE IF EXISTS feedback CASCADE")
        cursor.execute("DROP TABLE IF EXISTS payments CASCADE")
        cursor.execute("DROP TABLE IF EXISTS users CASCADE")
        
        conn.commit()
        print("✅ Tables dropped")

        cursor.close()
        conn.close()

        # Reinitialize the database
        print("🔄 Initializing fresh database...")
        from init_db import init_db
        init_db()

        print("\n✅ Database reset complete!")
        print("\n👥 Demo accounts available:")
        print("   • alice / password123 (User)")
        print("   • bob / password123 (User)")
        print("   • admin / admin123 (Admin)")

        return True

    except Exception as e:
        print(f"❌ Error resetting database: {e}")
        return False


if __name__ == "__main__":
    reset_database()
