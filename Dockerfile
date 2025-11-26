# Use Python 3.11 slim image
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    FLASK_APP=app.py

# Install system dependencies
RUN apt-get update && apt-get install -y netcat-traditional && rm -rf /var/lib/apt/lists/*

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host files.pythonhosted.org -r requirements.txt

# Copy application code
COPY app.py .
COPY init_db.py .
COPY reset_db.py .
COPY dbconf.ini .

# Copy templates and static files
COPY templates/ templates/
COPY static/ static/

# Create directory for database
RUN mkdir -p /app/data

# Copy entrypoint script
COPY entrypoint.sh .
RUN chmod +x entrypoint.sh

# Expose port 5000
EXPOSE 5000

# Run the application with entrypoint
ENTRYPOINT ["./entrypoint.sh"]
