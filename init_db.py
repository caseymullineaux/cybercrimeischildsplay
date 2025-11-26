import psycopg2
import os
from werkzeug.security import generate_password_hash


def init_db():
    """Initialize the database with tables and sample data"""
    conn = psycopg2.connect(
        host=os.environ.get("DB_HOST", "localhost"),
        port=os.environ.get("DB_PORT", "5432"),
        database=os.environ.get("DB_NAME", "typo_payments"),
        user=os.environ.get("DB_USER", "typo_admin"),
        password=os.environ.get("DB_PASSWORD", "insecure_password_123"),
    )
    cursor = conn.cursor()

    # Create users table
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS users (
            id SERIAL PRIMARY KEY,
            username TEXT UNIQUE NOT NULL,
            email TEXT UNIQUE NOT NULL,
            password_hash TEXT NOT NULL,
            full_name TEXT NOT NULL,
            is_admin BOOLEAN DEFAULT FALSE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    """)

    # Create payments table
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS payments (
            id SERIAL PRIMARY KEY,
            user_id INTEGER NOT NULL,
            amount DECIMAL(10, 2) NOT NULL,
            recipient TEXT NOT NULL,
            description TEXT,
            status TEXT DEFAULT 'pending',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users (id)
        )
    """)

    # Create feedback/comments table (vulnerable to stored XSS)
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS feedback (
            id SERIAL PRIMARY KEY,
            user_id INTEGER NOT NULL,
            username TEXT NOT NULL,
            message TEXT NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users (id)
        )
    """)

    # Insert sample users
    sample_users = [
        (
            "alice",
            "alice@example.com",
            generate_password_hash("password123"),
            "Alice Johnson",
            False,
        ),
        (
            "bob",
            "bob@example.com",
            generate_password_hash("password123"),
            "Bob Smith",
            False,
        ),
        (
            "admin",
            "admin@typo.com",
            generate_password_hash("admin123"),
            "Admin User",
            True,
        ),
    ]

    try:
        cursor.executemany(
            "INSERT INTO users (username, email, password_hash, full_name, is_admin) VALUES (%s, %s, %s, %s, %s)",
            sample_users,
        )
    except psycopg2.IntegrityError:
        print("Sample users already exist")
        conn.rollback()

    # Insert sample payments - More realistic data for each user
    sample_payments = [
        # Alice's payments (user_id = 1)
        (
            1,
            1250.00,
            "Rent Payment - Landlord",
            "Monthly rent for November",
            "completed",
        ),
        (1, 89.99, "Netflix Subscription", "Monthly streaming service", "completed"),
        (1, 45.67, "Electric Company", "Utility bill payment", "completed"),
        (1, 23.50, "Coffee Shop Downtown", "Weekly coffee expenses", "completed"),
        (1, 156.78, "Grocery Store", "Weekly shopping", "completed"),
        (1, 299.99, "Amazon", "Electronics purchase", "pending"),
        (1, 75.00, "Gym Membership", "Monthly fitness subscription", "completed"),
        (1, 12.99, "Spotify Premium", "Music streaming", "completed"),
        # Bob's payments (user_id = 2)
        (2, 2100.00, "Mortgage Payment", "Home loan monthly payment", "completed"),
        (2, 450.00, "Auto Insurance", "Car insurance premium", "completed"),
        (2, 67.89, "Gas Station", "Fuel for vehicle", "completed"),
        (2, 123.45, "Internet Provider", "High-speed internet service", "completed"),
        (2, 89.00, "Phone Bill", "Mobile service payment", "completed"),
        (2, 234.56, "Restaurant", "Dinner with clients", "pending"),
        (2, 15.99, "Apple iCloud", "Cloud storage subscription", "completed"),
        (2, 199.00, "Home Depot", "Home improvement supplies", "completed"),
        # Admin's payments (user_id = 3)
        (3, 5000.00, "Company Payroll", "Monthly salary distribution", "completed"),
        (3, 850.00, "AWS Services", "Cloud hosting infrastructure", "completed"),
        (3, 299.00, "Office Supplies", "Stationery and equipment", "completed"),
        (3, 1200.00, "Marketing Agency", "Digital advertising campaign", "pending"),
        (3, 450.00, "Software Licenses", "Annual subscription renewal", "completed"),
    ]

    try:
        cursor.executemany(
            "INSERT INTO payments (user_id, amount, recipient, description, status) VALUES (%s, %s, %s, %s, %s)",
            sample_payments,
        )
    except psycopg2.IntegrityError:
        print("Sample payments already exist")
        conn.rollback()

    conn.commit()
    cursor.close()
    conn.close()
    print("Database initialized successfully!")


if __name__ == "__main__":
    init_db()
