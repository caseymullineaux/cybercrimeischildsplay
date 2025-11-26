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
-- Passwords: alice/password123, bob/password123, admin/admin123
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
        'scrypt:32768:8:1$UxUr3pNhNm0xQvpt$19dc424b889620ab70c635048cc61ceb87a3ad15900db91454826c3e7c87ccbbbc452e8e2cec34d25b403f49921c611ee2f8dc824e9e2a0766aedd346c90dc77',
        'Alice Anderson',
        FALSE
    ),
    (
        'bob',
        'bob@typo-payments.com',
        'scrypt:32768:8:1$eTV7wCaaT9wtsOtK$a3d998e12ede1fae9d56c12c2a3b22316557495f6ae253902b1c12d68a9ac596275e09101959eb1186e2ba9d056eac1f2ac7add54109f6314d55c838ee0da865',
        'Bob Builder',
        FALSE
    ),
    (
        'admin',
        'admin@typo-payments.com',
        'scrypt:32768:8:1$y2OdA6rIss9XIGId$fb8ddc35c39f13d53bac9738473ca14283fef73b58b077a09f2ef3ea7c31cb35a94acf28a09ae58ee55a81b1632c793052ea29e883490637e89ffab81d7ee8a8',
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