# 🐳 Docker Quick Start Guide

The easiest way to run the Typo Payments XSS Demo!

## Prerequisites

- Docker installed ([Get Docker](https://docs.docker.com/get-docker/))
- Docker Compose installed (included with Docker Desktop)

## 🚀 One-Command Launch

```bash
docker-compose up
```

That's it! The application will be available at: **http://localhost:5000**

## 📦 What Gets Built

The Docker setup includes:
- Python 3.11 slim image
- All required dependencies (Flask, Flask-Login, Werkzeug)
- Pre-initialized SQLite database with demo accounts
- Full application code and templates

## 🎮 Usage Commands

### Start the Application
```bash
# Start in foreground (see logs)
docker-compose up

# Start in background (detached mode)
docker-compose up -d
```

### Stop the Application
```bash
# Stop (from same directory)
docker-compose down

# Stop and remove volumes (clean slate)
docker-compose down -v
```

### View Logs
```bash
# View logs in real-time
docker-compose logs -f

# View last 50 lines
docker-compose logs --tail=50
```

### Rebuild Container
```bash
# Rebuild after code changes
docker-compose up --build

# Force rebuild from scratch
docker-compose build --no-cache
```

### Reset Database Inside Container
```bash
# Execute reset script in running container
docker-compose exec typo-payments python reset_db.py

# Or restart the container to reset
docker-compose restart
```

### Access Container Shell
```bash
# Open bash shell in container
docker-compose exec typo-payments bash

# Or sh if bash not available
docker-compose exec typo-payments sh
```

## 📁 Data Persistence

The database is stored in `./data/` directory on your host machine:
- Database persists between container restarts
- Can be easily backed up or deleted
- Delete `./data/` folder to reset everything

## 🔧 Development Mode

To enable live code reloading, uncomment these lines in `docker-compose.yml`:

```yaml
volumes:
  - ./app.py:/app/app.py
  - ./templates:/app/templates
  - ./static:/app/static
```

Then restart:
```bash
docker-compose down
docker-compose up
```

Changes to Python files, templates, or CSS will reload automatically!

## 🌐 Port Configuration

Default port is `5000`. To change it, edit `docker-compose.yml`:

```yaml
ports:
  - "8080:5000"  # Access at http://localhost:8080
```

## 🐛 Troubleshooting

### Port Already in Use
```bash
# Check what's using port 5000
lsof -i :5000

# Or change port in docker-compose.yml
ports:
  - "5001:5000"
```

### Container Won't Start
```bash
# View container logs
docker-compose logs

# Rebuild from scratch
docker-compose down -v
docker-compose build --no-cache
docker-compose up
```

### Database Issues
```bash
# Remove database and restart
rm -rf ./data
docker-compose restart
```

### Permission Issues (Linux)
```bash
# Fix file permissions
sudo chown -R $USER:$USER ./data
```

## 🧹 Cleanup

### Remove Everything
```bash
# Stop containers and remove volumes
docker-compose down -v

# Remove built images
docker-compose down --rmi all

# Clean up Docker system
docker system prune -a
```

## 📊 Container Info

### View Running Containers
```bash
docker-compose ps
```

### Check Resource Usage
```bash
docker stats typo-payments-demo
```

### View Image Size
```bash
docker images | grep typo
```

## 🎯 Quick Demo Setup

Perfect for presentations:

```bash
# 1. Start the application
docker-compose up -d

# 2. Open browser to http://localhost:5000

# 3. Login with demo accounts:
#    - admin / admin123 (for admin features)
#    - alice / password123 (for user features)

# 4. After demo, clean up
docker-compose down
```

## 🚀 Production Notes

⚠️ **WARNING**: This application is intentionally vulnerable!

**DO NOT** use in production or expose to the internet. This is for:
- ✅ Local demos
- ✅ Training environments
- ✅ Educational purposes
- ✅ Controlled networks only

## 🔐 Environment Variables

You can customize via environment variables in `docker-compose.yml`:

```yaml
environment:
  - FLASK_ENV=development
  - FLASK_DEBUG=1
  - SECRET_KEY=your-secret-key
```

## 📝 Docker Compose File Structure

```yaml
version: '3.8'

services:
  typo-payments:
    build: .                    # Build from Dockerfile
    container_name: typo-payments-demo
    ports:
      - "5000:5000"            # Host:Container port mapping
    volumes:
      - ./data:/app/data       # Persist database
    environment:
      - FLASK_ENV=development
      - FLASK_DEBUG=1
    restart: unless-stopped    # Auto-restart on crash
    networks:
      - typo-network

networks:
  typo-network:
    driver: bridge
```

## 💡 Tips

1. **First Time Setup**: First `docker-compose up` will take a few minutes to build
2. **Subsequent Starts**: Much faster (uses cached image)
3. **Database Reset**: Just delete `./data/` folder and restart
4. **Live Logs**: Use `docker-compose logs -f` to watch in real-time
5. **Background Mode**: Use `-d` flag for detached mode

## 🎓 Educational Use

Perfect for:
- Security training workshops
- University courses
- Developer education
- Conference presentations
- Security awareness programs

## 📚 Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- Main README.md for application features
- SETUP.md for non-Docker installation

## ❓ Common Questions

**Q: Can I run multiple instances?**  
A: Yes! Change the container name and port in `docker-compose.yml`

**Q: How do I update the application?**  
A: Pull latest code and run `docker-compose up --build`

**Q: Where is the database stored?**  
A: In `./data/` directory (gitignored)

**Q: Can I use this on Windows/Mac/Linux?**  
A: Yes! Docker works on all platforms

**Q: How do I backup my data?**  
A: Copy the `./data/` directory

---

**Need help?** Check the main README.md or create an issue!
