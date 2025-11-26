#!/bin/bash
set -e

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL..."
while ! nc -z postgres 5432; do
  sleep 0.1
done
echo "PostgreSQL is ready!"

# Initialize the database
echo "Initializing database..."
python init_db.py

# Start the Flask application
echo "Starting Flask application..."
exec python app.py
