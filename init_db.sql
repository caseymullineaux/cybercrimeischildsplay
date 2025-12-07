-- WARNING: Intentionally insecure configuration for SQLi RCE demonstration
-- This grants superuser privileges to allow COPY TO PROGRAM for command execution
-- Note: The admin user is created automatically by PostgreSQL from POSTGRES_USER
DO $$ BEGIN IF EXISTS (
    SELECT
    FROM pg_catalog.pg_roles
    WHERE rolname = 'admin'
) THEN ALTER USER admin WITH SUPERUSER;
END IF;
END $$;
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
-- User details table (contains sensitive PII)
-- WARNING: This contains intentionally exposed sensitive data for SQLi demonstration
CREATE TABLE IF NOT EXISTS user_details (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL UNIQUE REFERENCES users(id),
    date_of_birth DATE NOT NULL,
    ssn VARCHAR(11) NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    address_line1 VARCHAR(200) NOT NULL,
    address_line2 VARCHAR(200),
    city VARCHAR(100) NOT NULL,
    state VARCHAR(50) NOT NULL,
    zip_code VARCHAR(10) NOT NULL,
    country VARCHAR(100) DEFAULT 'USA',
    credit_card_number VARCHAR(19) NOT NULL,
    credit_card_cvv VARCHAR(4) NOT NULL,
    credit_card_expiry VARCHAR(7) NOT NULL,
    bank_account_number VARCHAR(20),
    bank_routing_number VARCHAR(9),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- Insert demo users
-- Note: These are intentionally weak passwords for demonstration purposes
-- Passwords: alice/password123, john/password123, admin/admin123
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
        'Alice Johnson',
        FALSE
    ),
    (
        'john',
        'john@typo-payments.com',
        '3941de2b1cfbe343743c5a8b7b45f63a',
        'John Smith',
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
        'Alice Johnson',
        'Starbucks',
        5.75,
        'Morning coffee',
        'completed'
    ),
    (
        1,
        'Alice Johnson',
        'Amazon',
        49.99,
        'Office supplies',
        'completed'
    ),
    (
        1,
        'Alice Johnson',
        'Netflix',
        15.99,
        'Monthly subscription',
        'completed'
    ),
    (
        1,
        'Alice Johnson',
        'Uber',
        23.50,
        'Ride to airport',
        'completed'
    ),
    (
        1,
        'Alice Johnson',
        'Whole Foods',
        127.43,
        'Grocery shopping',
        'completed'
    ),
    (
        1,
        'Alice Johnson',
        'Shell Gas Station',
        45.00,
        'Fuel',
        'completed'
    ),
    (
        1,
        'Alice Johnson',
        'Apple',
        1.99,
        'App purchase',
        'completed'
    ),
    (
        1,
        'Alice Johnson',
        'Target',
        78.32,
        'Household items',
        'completed'
    ) ON CONFLICT DO NOTHING;
-- Insert realistic payment data for john (user_id = 2)
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
        'John Smith',
        'Home Depot',
        234.56,
        'Building materials',
        'completed'
    ),
    (
        2,
        'John Smith',
        'Chipotle',
        12.45,
        'Lunch',
        'completed'
    ),
    (
        2,
        'John Smith',
        'Spotify',
        9.99,
        'Music streaming',
        'completed'
    ),
    (
        2,
        'John Smith',
        'Costco',
        187.92,
        'Bulk shopping',
        'completed'
    ),
    (
        2,
        'John Smith',
        'Chevron',
        52.00,
        'Gas station',
        'completed'
    ),
    (
        2,
        'John Smith',
        'Best Buy',
        399.99,
        'Electronics',
        'completed'
    ),
    (
        2,
        'John Smith',
        'Pizza Hut',
        28.75,
        'Family dinner',
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
        'john',
        'The status page is helpful for tracking payments.'
    ),
    (
        1,
        'alice',
        'I love the search feature! Makes finding old payments super quick.'
    ),
    (
        2,
        'john',
        'Would be nice to have payment categories for better organization.'
    ),
    (
        1,
        'alice',
        'The email notifications are timely and helpful. Keep it up!'
    ),
    (
        2,
        'john',
        'Can we get a monthly summary report feature? That would be awesome.'
    ),
    (
        1,
        'alice',
        'Payment processing is fast! Usually completes in under a minute.'
    ),
    (
        2,
        'john',
        'The mobile experience is great. Very responsive design.'
    ),
    (
        1,
        'alice',
        'Just made my 50th payment! This platform has been reliable from day one.'
    ) ON CONFLICT DO NOTHING;
-- Insert sensitive user details (PII for SQLi demonstration)
-- WARNING: This is intentionally insecure - sensitive data should be encrypted!
INSERT INTO user_details (
        user_id,
        date_of_birth,
        ssn,
        phone_number,
        address_line1,
        address_line2,
        city,
        state,
        zip_code,
        credit_card_number,
        credit_card_cvv,
        credit_card_expiry,
        bank_account_number,
        bank_routing_number
    )
VALUES (
        1,
        '1985-03-15',
        '123-45-6789',
        '+1 (555) 123-4567',
        '742 Evergreen Terrace',
        'Apt 4B',
        'Springfield',
        'Illinois',
        '62701',
        '4532-1234-5678-9010',
        '123',
        '12/2027',
        '9876543210',
        '021000021'
    ),
    (
        2,
        '1990-07-22',
        '987-65-4321',
        '+1 (555) 987-6543',
        '1600 Pennsylvania Avenue',
        NULL,
        'Washington',
        'DC',
        '20500',
        '5425-2334-3010-9876',
        '456',
        '08/2026',
        '1234567890',
        '026009593'
    ),
    (
        3,
        '1978-11-30',
        '555-12-3456',
        '+1 (555) 234-5678',
        '350 Fifth Avenue',
        'Suite 1000',
        'New York',
        'New York',
        '10118',
        '3782-822463-10005',
        '789',
        '03/2028',
        '5555666677',
        '021001088'
    ) ON CONFLICT (user_id) DO NOTHING;