import psycopg2
import os
import hashlib

# INSECURE: Using MD5 for password hashing (for demo purposes only!)
def generate_password_hash(password):
    """VULNERABLE: MD5 hashing is easily crackable - DO NOT USE IN PRODUCTION!"""
    return hashlib.md5(password.encode()).hexdigest()


def init_db():
    """Initialize the database with tables and sample data"""
    conn = psycopg2.connect(
        host=os.environ.get("DB_HOST", "localhost"),
        port=os.environ.get("DB_PORT", "5432"),
        database=os.environ.get("DB_NAME", "typo_payments"),
        user=os.environ.get("DB_USER", "admin"),
        password=os.environ.get("DB_PASSWORD", "password123"),
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
            user_name TEXT,
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
            generate_password_hash("Welcome123!"),
            "Alice Johnson",
            False,
        ),
        (
            "john",
            "john@example.com",
            generate_password_hash("Summer2023!"),
            "John Smith",
            False,
        ),
        (
            "admin",
            "admin@typo.com",
            generate_password_hash("P@$$w0rd"),
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
        (1, "Alice Johnson", 1250.00, "Rent Payment - Landlord", "Monthly rent for November", "completed"),
        (1, "Alice Johnson", 89.99, "Netflix Subscription", "Monthly streaming service", "completed"),
        (1, "Alice Johnson", 45.67, "Electric Company", "Utility bill payment", "completed"),
        (1, "Alice Johnson", 23.50, "Coffee Shop Downtown", "Weekly coffee expenses", "completed"),
        (1, "Alice Johnson", 156.78, "Grocery Store", "Weekly shopping", "completed"),
        (1, "Alice Johnson", 299.99, "Amazon", "Electronics purchase", "pending"),
        (1, "Alice Johnson", 75.00, "Gym Membership", "Monthly fitness subscription", "completed"),
        (1, "Alice Johnson", 12.99, "Spotify Premium", "Music streaming", "completed"),
        # John's payments (user_id = 2)
        (2, "John Smith", 2100.00, "Mortgage Payment", "Home loan monthly payment", "completed"),
        (2, "John Smith", 450.00, "Auto Insurance", "Car insurance premium", "completed"),
        (2, "John Smith", 67.89, "Gas Station", "Fuel for vehicle", "completed"),
        (2, "John Smith", 123.45, "Internet Provider", "High-speed internet service", "completed"),
        (2, "John Smith", 89.00, "Phone Bill", "Mobile service payment", "completed"),
        (2, "John Smith", 234.56, "Restaurant", "Dinner with clients", "pending"),
        (2, "John Smith", 15.99, "Apple iCloud", "Cloud storage subscription", "completed"),
        (2, "John Smith", 199.00, "Home Depot", "Home improvement supplies", "completed"),
    ]

    try:
        cursor.executemany(
            "INSERT INTO payments (user_id, user_name, amount, recipient, description, status) VALUES (%s, %s, %s, %s, %s, %s)",
            sample_payments,
        )
    except psycopg2.IntegrityError:
        print("Sample payments already exist")
        conn.rollback()

    # Insert sample feedback
    sample_feedback = [
        (1, "alice", "Great payment system! Very easy to use."),
        (2, "john", "The status page is helpful for tracking payments."),
        (1, "alice", "I love the search feature! Makes finding old payments super quick."),
        (2, "john", "Would be nice to have payment categories for better organization."),
        (1, "alice", "The email notifications are timely and helpful. Keep it up!"),
        (2, "john", "Can we get a monthly summary report feature? That would be awesome."),
        (1, "alice", "Payment processing is fast! Usually completes in under a minute."),
        (2, "john", "The mobile experience is great. Very responsive design."),
        (1, "alice", "Just made my 50th payment! This platform has been reliable from day one."),
    ]

    try:
        cursor.executemany(
            "INSERT INTO feedback (user_id, username, message) VALUES (%s, %s, %s)",
            sample_feedback,
        )
    except psycopg2.IntegrityError:
        print("Sample feedback already exists")
        conn.rollback()

    conn.commit()
    cursor.close()
    conn.close()
    print("Database initialized successfully!")


if __name__ == "__main__":
    init_db()
