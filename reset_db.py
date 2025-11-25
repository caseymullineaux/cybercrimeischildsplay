#!/usr/bin/env python3
"""
Reset the database to clean state for demos
Deletes the existing database and recreates it with sample data
"""

import os
import sys


def reset_database():
    db_file = "typo_payments.db"

    # Check if database exists
    if os.path.exists(db_file):
        response = input(f"⚠️  Delete existing database '{db_file}'? (y/N): ")
        if response.lower() != "y":
            print("❌ Database reset cancelled")
            sys.exit(0)

        # Delete the database
        os.remove(db_file)
        print(f"✅ Deleted {db_file}")

    # Reinitialize the database
    print("🔄 Initializing fresh database...")
    from init_db import init_db

    init_db()

    print("\n✅ Database reset complete!")
    print("\n👥 Demo accounts available:")
    print("   • alice / password123 (User)")
    print("   • bob / password123 (User)")
    print("   • admin / admin123 (Admin)")
    print("\n🚀 Start the app with: python app.py")


if __name__ == "__main__":
    reset_database()
