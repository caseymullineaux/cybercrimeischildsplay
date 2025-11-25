# 🚀 Getting Started - Choose Your Path

## 🎯 Quick Comparison

| Feature | Docker 🐳 | Local Python 💻 |
|---------|-----------|-----------------|
| **Setup Time** | 2 minutes | 5 minutes |
| **Command** | `docker-compose up` | Multiple steps |
| **Prerequisites** | Docker only | Python + pip + venv |
| **Cleanup** | `docker-compose down` | Manual |
| **Isolation** | ✅ Complete | ⚠️ System-wide |
| **Cross-platform** | ✅ Identical | ⚠️ May vary |
| **File Size** | ~300MB | ~50MB |
| **Best For** | Demos, Presentations | Development, Learning |

## 🐳 Docker Method (Recommended)

### Why Choose Docker?
- **Zero hassle**: No Python installation, no virtual environments
- **Consistent**: Works the same on Windows, Mac, and Linux
- **Clean**: Easy cleanup, no system pollution
- **Professional**: Industry-standard deployment method

### Prerequisites
- [Docker Desktop](https://www.docker.com/products/docker-desktop) (includes Docker Compose)

### Quick Start
```bash
# 1. Clone or navigate to directory
cd vuln_slam_demo

# 2. Start everything
docker-compose up

# 3. Open browser
# http://localhost:5000
```

### Using Makefile (Even Easier!)
```bash
# Start the app
make up

# View logs
make logs

# Reset database
make reset

# Stop the app
make down

# See all commands
make help
```

### Learn More
📖 [DOCKER.md](DOCKER.md) - Complete Docker documentation

---

## 💻 Local Python Method

### Why Choose Local Python?
- **Direct access**: Modify code and see changes immediately
- **Learning**: Better for understanding the codebase
- **Lightweight**: Smaller disk footprint
- **Debugging**: Easier to debug with Python tools

### Prerequisites
- Python 3.8+ ([Download](https://www.python.org/downloads/))
- pip (included with Python)

### Quick Start
```bash
# 1. Create virtual environment
python3 -m venv venv

# 2. Activate it
source venv/bin/activate  # macOS/Linux
# venv\Scripts\activate   # Windows

# 3. Install dependencies
pip install -r requirements.txt

# 4. Initialize database
python init_db.py

# 5. Run the app
python app.py

# 6. Open browser
# http://localhost:5000
```

### Using Makefile
```bash
# Install dependencies
make install

# Initialize database
make init-db

# Run locally
make run-local
```

### Learn More
📖 [SETUP.md](SETUP.md) - Complete setup documentation

---

## ⚡ Ultra Quick Start

Choose your path:

### Docker Users
```bash
docker-compose up
```
**Done!** → http://localhost:5000

### Python Users
```bash
pip install -r requirements.txt && python init_db.py && python app.py
```
**Done!** → http://localhost:5000

---

## 🎮 Demo Accounts

No matter which method you choose, use these accounts:

| Username | Password | Role |
|----------|----------|------|
| `alice` | `password123` | User |
| `bob` | `password123` | User |
| `admin` | `admin123` | Admin |

---

## 🛠️ Common Commands

### Docker
```bash
# Start
docker-compose up

# Start in background
docker-compose up -d

# Stop
docker-compose down

# View logs
docker-compose logs -f

# Reset database
docker-compose exec typo-payments python reset_db.py

# Complete cleanup
docker-compose down -v
```

### Local Python
```bash
# Start
python app.py

# Reset database
python reset_db.py

# Or
rm typo_payments.db && python init_db.py

# Stop
Ctrl+C
```

### Makefile (Both Methods)
```bash
make help     # See all commands
make up       # Start with Docker
make down     # Stop Docker
make logs     # View logs
make reset    # Reset database
make clean    # Full cleanup
```

---

## 🎓 Which Method Should I Use?

### Use Docker If:
- ✅ You're doing a live demo or presentation
- ✅ You want the fastest setup
- ✅ You're teaching a workshop
- ✅ You need consistent environments
- ✅ You don't have Python installed
- ✅ You want easy cleanup

### Use Local Python If:
- ✅ You're learning the codebase
- ✅ You plan to modify the code
- ✅ You're developing new features
- ✅ You need to debug issues
- ✅ You prefer direct file access
- ✅ You're teaching Python/Flask

---

## 📁 Project Structure

```
vuln_slam_demo/
├── 🐳 Docker Files
│   ├── Dockerfile           # Container definition
│   ├── docker-compose.yml   # Orchestration
│   ├── .dockerignore        # Build exclusions
│   └── Makefile            # Helper commands
│
├── 🐍 Python Files
│   ├── app.py              # Main application
│   ├── init_db.py          # Database setup
│   ├── reset_db.py         # Database reset
│   └── requirements.txt    # Dependencies
│
├── 🎨 Frontend
│   ├── templates/          # HTML templates
│   └── static/            # CSS files
│
└── 📚 Documentation
    ├── README.md           # Main documentation
    ├── DOCKER.md          # Docker guide
    ├── SETUP.md           # Setup guide
    ├── GETTING_STARTED.md # This file
    └── ...more docs
```

---

## 🐛 Troubleshooting

### Port 5000 Already in Use?

**Docker:**
```yaml
# Edit docker-compose.yml
ports:
  - "5001:5000"  # Use port 5001 instead
```

**Local Python:**
```python
# Edit app.py
app.run(debug=True, host='0.0.0.0', port=5001)
```

### Database Issues?

**Docker:**
```bash
# Delete data directory
rm -rf ./data
docker-compose restart
```

**Local Python:**
```bash
# Reset database
python reset_db.py
```

### Can't Access Application?

- ✅ Check the app is running
- ✅ Try http://127.0.0.1:5000 instead of localhost
- ✅ Check firewall settings
- ✅ Verify port isn't blocked

---

## 🎬 Next Steps

1. **Start the application** (choose your method above)
2. **Open** http://localhost:5000
3. **Login** as admin (admin/admin123)
4. **Explore** the XSS vulnerabilities
5. **Read** [README.md](README.md) for demo scenarios

---

## 📞 Need Help?

- 📖 [README.md](README.md) - Complete documentation
- 🐳 [DOCKER.md](DOCKER.md) - Docker detailed guide
- 💻 [SETUP.md](SETUP.md) - Python setup guide
- 🎯 [XSS_PAYLOADS.md](XSS_PAYLOADS.md) - Attack examples
- 🛡️ [ADMIN_GUIDE.md](ADMIN_GUIDE.md) - Admin features

---

**Ready to go? Pick your method and start! 🚀**

```bash
# Docker (recommended)
docker-compose up

# Or local Python
python app.py
```

**Then visit:** http://localhost:5000
