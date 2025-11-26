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
    user_name VARCHAR(120),
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
        '23cb2d3d426b10abdf03417cdb095f08',
        'Alice Anderson',
        FALSE
    ),
    (
        'bob',
        'bob@typo-payments.com',
        '3941de2b1cfbe343743c5a8b7b45f63a',
        'Bob Builder',
        FALSE
    ),
    (
        'admin',
        'admin@typo-payments.com',
        'c53e479b03b3220d3d56da88c4cace20',
        'Admin User',
        TRUE
    ) ON CONFLICT (username) DO NOTHING;
-- Insert realistic payment data for Alice (user_id = 1)
INSERT INTO payments (
        user_id,
        user_name,
        recipient,
        amount,
        description,
        status
    )
VALUES (
        1,
        'Alice Anderson',
        'Starbucks',
        5.75,
        'Morning coffee',
        'completed'
    ),
    (
        1,
        'Alice Anderson',
        'Amazon',
        49.99,
        'Office supplies',
        'completed'
    ),
    (
        1,
        'Alice Anderson',
        'Netflix',
        15.99,
        'Monthly subscription',
        'completed'
    ),
    (
        1,
        'Alice Anderson',
        'Uber',
        23.50,
        'Ride to airport',
        'completed'
    ),
    (
        1,
        'Alice Anderson',
        'Whole Foods',
        127.43,
        'Grocery shopping',
        'completed'
    ),
    (
        1,
        'Alice Anderson',
        'Shell Gas Station',
        45.00,
        'Fuel',
        'completed'
    ),
    (
        1,
        'Alice Anderson',
        'Apple',
        1.99,
        'App purchase',
        'completed'
    ),
    (
        1,
        'Alice Anderson',
        'Target',
        78.32,
        'Household items',
        'completed'
    ) ON CONFLICT DO NOTHING;
-- Insert realistic payment data for Bob (user_id = 2)
INSERT INTO payments (
        user_id,
        user_name,
        recipient,
        amount,
        description,
        status
    )
VALUES (
        2,
        'Bob Builder',
        'Home Depot',
        234.56,
        'Building materials',
        'completed'
    ),
    (
        2,
        'Bob Builder',
        'Chipotle',
        12.45,
        'Lunch',
        'completed'
    ),
    (
        2,
        'Bob Builder',
        'Spotify',
        9.99,
        'Music streaming',
        'completed'
    ),
    (
        2,
        'Bob Builder',
        'Costco',
        187.92,
        'Bulk shopping',
        'completed'
    ),
    (
        2,
        'Bob Builder',
        'Chevron',
        52.00,
        'Gas station',
        'completed'
    ),
    (
        2,
        'Bob Builder',
        'Best Buy',
        399.99,
        'Electronics',
        'completed'
    ),
    (
        2,
        'Bob Builder',
        'Pizza Hut',
        28.75,
        'Family dinner',
        'completed'
    ) ON CONFLICT DO NOTHING;
-- Insert realistic payment data for Admin (user_id = 3)
INSERT INTO payments (
        user_id,
        user_name,
        recipient,
        amount,
        description,
        status
    )
VALUES (
        3,
        'Admin User',
        'AWS',
        450.00,
        'Cloud hosting services',
        'completed'
    ),
    (
        3,
        'Admin User',
        'GitHub',
        21.00,
        'Enterprise subscription',
        'completed'
    ),
    (
        3,
        'Admin User',
        'Slack',
        80.00,
        'Team communication',
        'completed'
    ),
    (
        3,
        'Admin User',
        'DigitalOcean',
        120.00,
        'Server costs',
        'completed'
    ),
    (
        3,
        'Admin User',
        'JetBrains',
        149.00,
        'IDE license',
        'completed'
    ),
    (
        3,
        'Admin User',
        'Zoom',
        14.99,
        'Pro subscription',
        'completed'
    ),
    (
        3,
        'Admin User',
        'Adobe',
        52.99,
        'Creative Cloud',
        'completed'
    ),
    (
        3,
        'Admin User',
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
    ),
    (
        1,
        'alice',
        'I love the search feature! Makes finding old payments super quick.'
    ),
    (
        3,
        'admin',
        'Dashboard looks clean and professional. Nice work on the UI!'
    ),
    (
        2,
        'bob',
        'Would be nice to have payment categories for better organization.'
    ),
    (
        1,
        'alice',
        'The email notifications are timely and helpful. Keep it up!'
    ),
    (
        3,
        'admin',
        'Security note: Please ensure all users enable 2FA for their accounts.'
    ),
    (
        2,
        'bob',
        'Can we get a monthly summary report feature? That would be awesome.'
    ),
    (
        1,
        'alice',
        'Payment processing is fast! Usually completes in under a minute.'
    ),
    (
        2,
        'bob',
        'The mobile experience is great. Very responsive design.'
    ),
    (
        3,
        'admin',
        'Running some maintenance this weekend. Expect brief downtime.'
    ),
    (
        1,
        'alice',
        'Just made my 50th payment! This platform has been reliable from day one.'
    ) ON CONFLICT DO NOTHING;