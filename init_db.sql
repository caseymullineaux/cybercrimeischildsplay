-- Typo Payments PostgreSQL Database Initialization
-- This script creates tables and populates them with demo data
-- Users table
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(80) UNIQUE NOT NULL,
    email VARCHAR(120) UNIQUE NOT NULL,
    password_hash VARCHAR(200) NOT NULL,
    full_name VARCHAR(120),
    is_admin BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- Payments table
CREATE TABLE IF NOT EXISTS payments (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id),
    recipient VARCHAR(120) NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    description TEXT,
    status VARCHAR(20) DEFAULT 'completed',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- Feedback table (for stored XSS)
CREATE TABLE IF NOT EXISTS feedback (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id),
    username VARCHAR(80) NOT NULL,
    message TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- Insert demo users
-- Note: These are intentionally weak passwords for demonstration purposes
-- Password hashes are plain text (pbkdf2:sha256 format in production)
INSERT INTO users (
        username,
        email,
        password_hash,
        full_name,
        is_admin
    )
VALUES (
        'alice',
        'alice@typo-payments.com',
        'scrypt:32768:8:1$xqHnz5KdOLk4aMpE$5d2c8d3a6f1e9b8c7a4d2e1f0c9b8a7d6e5f4c3b2a1d0e9f8c7b6a5d4e3f2c1b0a9d8e7f6c5b4a3d2e1f0c9b8a7d6e5f4c3b2a1d',
        'Alice Anderson',
        FALSE
    ),
    (
        'bob',
        'bob@typo-payments.com',
        'scrypt:32768:8:1$xqHnz5KdOLk4aMpE$5d2c8d3a6f1e9b8c7a4d2e1f0c9b8a7d6e5f4c3b2a1d0e9f8c7b6a5d4e3f2c1b0a9d8e7f6c5b4a3d2e1f0c9b8a7d6e5f4c3b2a1d',
        'Bob Builder',
        FALSE
    ),
    (
        'admin',
        'admin@typo-payments.com',
        'scrypt:32768:8:1$xqHnz5KdOLk4aMpE$5d2c8d3a6f1e9b8c7a4d2e1f0c9b8a7d6e5f4c3b2a1d0e9f8c7b6a5d4e3f2c1b0a9d8e7f6c5b4a3d2e1f0c9b8a7d6e5f4c3b2a1d',
        'Admin User',
        TRUE
    ) ON CONFLICT (username) DO NOTHING;
-- Insert realistic payment data for Alice (user_id = 1)
INSERT INTO payments (user_id, recipient, amount, description, status)
VALUES (
        1,
        'Starbucks',
        5.75,
        'Morning coffee',
        'completed'
    ),
    (
        1,
        'Amazon',
        49.99,
        'Office supplies',
        'completed'
    ),
    (
        1,
        'Netflix',
        15.99,
        'Monthly subscription',
        'completed'
    ),
    (1, 'Uber', 23.50, 'Ride to airport', 'completed'),
    (
        1,
        'Whole Foods',
        127.43,
        'Grocery shopping',
        'completed'
    ),
    (
        1,
        'Shell Gas Station',
        45.00,
        'Fuel',
        'completed'
    ),
    (1, 'Apple', 1.99, 'App purchase', 'completed'),
    (
        1,
        'Target',
        78.32,
        'Household items',
        'completed'
    ) ON CONFLICT DO NOTHING;
-- Insert realistic payment data for Bob (user_id = 2)
INSERT INTO payments (user_id, recipient, amount, description, status)
VALUES (
        2,
        'Home Depot',
        234.56,
        'Building materials',
        'completed'
    ),
    (2, 'Chipotle', 12.45, 'Lunch', 'completed'),
    (
        2,
        'Spotify',
        9.99,
        'Music streaming',
        'completed'
    ),
    (
        2,
        'Costco',
        187.92,
        'Bulk shopping',
        'completed'
    ),
    (2, 'Chevron', 52.00, 'Gas station', 'completed'),
    (
        2,
        'Best Buy',
        399.99,
        'Electronics',
        'completed'
    ),
    (
        2,
        'Pizza Hut',
        28.75,
        'Family dinner',
        'completed'
    ) ON CONFLICT DO NOTHING;
-- Insert realistic payment data for Admin (user_id = 3)
INSERT INTO payments (user_id, recipient, amount, description, status)
VALUES (
        3,
        'AWS',
        450.00,
        'Cloud hosting services',
        'completed'
    ),
    (
        3,
        'GitHub',
        21.00,
        'Enterprise subscription',
        'completed'
    ),
    (
        3,
        'Slack',
        80.00,
        'Team communication',
        'completed'
    ),
    (
        3,
        'DigitalOcean',
        120.00,
        'Server costs',
        'completed'
    ),
    (
        3,
        'JetBrains',
        149.00,
        'IDE license',
        'completed'
    ),
    (
        3,
        'Zoom',
        14.99,
        'Pro subscription',
        'completed'
    ),
    (3, 'Adobe', 52.99, 'Creative Cloud', 'completed'),
    (
        3,
        'Microsoft 365',
        69.99,
        'Office subscription',
        'completed'
    ) ON CONFLICT DO NOTHING;
-- Create some sample feedback (safe examples)
INSERT INTO feedback (user_id, username, message)
VALUES (
        1,
        'alice',
        'Great payment system! Very easy to use.'
    ),
    (
        2,
        'bob',
        'The status page is helpful for tracking payments.'
    ) ON CONFLICT DO NOTHING;