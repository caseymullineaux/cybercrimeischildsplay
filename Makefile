.PHONY: help build up down restart logs shell reset clean

help:
	@echo "🎯 Typo Payments XSS Demo - Available Commands"
	@echo ""
	@echo "Docker Commands:"
	@echo "  make up        - Start the application"
	@echo "  make down      - Stop the application"
	@echo "  make build     - Build/rebuild the Docker image"
	@echo "  make restart   - Restart the application"
	@echo "  make logs      - View application logs"
	@echo "  make shell     - Open shell in container"
	@echo ""
	@echo "Utility Commands:"
	@echo "  make reset     - Reset the database"
	@echo "  make clean     - Remove all containers, images, and data"
	@echo ""
	@echo "Quick Start:"
	@echo "  make up        - Start the app at http://localhost:5000"

build:
	@echo "🔨 Building Docker image..."
	docker-compose build

up:
	@echo "🚀 Starting Typo Payments..."
	@echo "📍 Application will be available at http://localhost:5000"
	@echo ""
	@echo "Demo Accounts:"
	@echo "  👤 alice  / password123"
	@echo "  👤 bob    / password123"
	@echo "  🛡️  admin / admin123"
	@echo ""
	docker-compose up

up-detached:
	@echo "🚀 Starting Typo Payments in background..."
	docker-compose up -d
	@echo "✅ Application running at http://localhost:5000"

down:
	@echo "🛑 Stopping Typo Payments..."
	docker-compose down

restart:
	@echo "🔄 Restarting Typo Payments..."
	docker-compose restart

logs:
	@echo "📋 Viewing logs (Ctrl+C to exit)..."
	docker-compose logs -f

shell:
	@echo "🐚 Opening shell in container..."
	docker-compose exec typo-payments sh

reset:
	@echo "🔄 Resetting database..."
	docker-compose exec typo-payments python reset_db.py

clean:
	@echo "🧹 Cleaning up Docker resources..."
	docker-compose down -v
	docker-compose down --rmi all
	rm -rf ./data
	@echo "✅ Cleanup complete!"

# Python local development commands
install:
	@echo "📦 Installing Python dependencies..."
	pip install -r requirements.txt

init-db:
	@echo "🗄️  Initializing database..."
	python init_db.py

run-local:
	@echo "🚀 Starting local Python server..."
	python app.py
