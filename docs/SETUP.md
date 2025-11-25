# 🚀 Quick Setup Guide

## Choose Your Method

### 🐳 Method 1: Docker (Recommended - Easiest!)

**Perfect for**: Quick demos, presentations, workshops

**Prerequisites**: Docker and Docker Compose

#### One-Command Setup
```bash
docker-compose up
```

That's it! Open **http://localhost:5000** in your browser.

**Pros**:
- ✅ No Python installation needed
- ✅ No dependency management
- ✅ Works the same on all platforms
- ✅ Easy cleanup (`docker-compose down`)
- ✅ Isolated environment

**Cons**:
- ❌ Requires Docker installed
- ❌ Larger download size

**Detailed Docker instructions**: See [DOCKER.md](DOCKER.md)

---

### 💻 Method 2: Local Python Installation

**Perfect for**: Development, customization, learning

**Prerequisites**: Python 3.8+, pip

**Pros**:
- ✅ No Docker needed
- ✅ Direct code access
- ✅ Easier to modify and debug
- ✅ Smaller footprint

**Cons**:
- ❌ Must install Python and dependencies
- ❌ Virtual environment recommended
- ❌ Platform-specific setup

## Step-by-Step Setup (Local Python)

### 1. Install Dependencies
```bash
pip install -r requirements.txt
```

This will install:
- Flask 3.0.0
- Flask-Login 0.6.3
- Werkzeug 3.0.1

### 2. Initialize Database
```bash
python init_db.py
```

Expected output:
```
Database initialized successfully!
```

This creates `typo_payments.db` with:
- 3 sample users (alice, bob, admin)
- Sample payments for each user
- Empty feedback table

### 3. Start the Application
```bash
python app.py
```

Expected output:
```
 * Serving Flask app 'app'
 * Debug mode: on
 * Running on http://127.0.0.1:5000
```

### 4. Access the Application
Open your browser and navigate to:
```
http://localhost:5000
```

## Demo Account Credentials

### Regular Users
- **Alice**: `alice` / `password123`
- **Bob**: `bob` / `password123`

### Administrator
- **Admin**: `admin` / `admin123`

## Quick Demo Flow

### Test Regular User Features (5 min)
1. Login as Alice
2. View Dashboard (see her payments)
3. Try Search with: `<script>alert('XSS')</script>`
4. Submit feedback with XSS: `<script>alert('Stored XSS')</script>`
5. View Profile and click "Show Cookies"

### Test Admin Features (5 min)
1. Logout and login as Admin
2. Click 🛡️ Admin link in navigation
3. View admin dashboard statistics
4. Navigate to "Manage Users"
5. Click "Make Admin" for Alice
6. Create a new test user
7. Logout and login as Alice
8. Verify Alice now has admin access

### Demonstrate XSS → Admin Compromise (5 min)
1. Login as Bob (regular user)
2. Go to Feedback page
3. Submit: `<img src=x onerror=alert('Admin cookie: ' + document.cookie)>`
4. Logout and login as Admin
5. Navigate to Feedback page
6. XSS executes with admin privileges
7. Explain how attacker could steal the cookie
8. Show how stolen cookie gives full admin access

## Troubleshooting

### Database Already Exists
If you see "Sample users already exist", the database is already initialized.
To reset:
```bash
python reset_db.py
```

### Port 5000 In Use
Change the port in `app.py`:
```python
app.run(debug=True, port=8080)  # Or any other port
```

### Cannot Access Admin Panel
Make sure you're logged in as the `admin` user or a user with admin privileges.
The 🛡️ Admin link only appears for admin users.

### XSS Not Working
Make sure you're using the exact payloads with proper quotes and brackets.
The application intentionally uses `|safe` filter to allow XSS execution.

## File Structure

```
vuln_slam_demo/
├── app.py                      # Main Flask application
├── init_db.py                  # Database initialization
├── reset_db.py                 # Database reset utility
├── requirements.txt            # Python dependencies
├── README.md                   # Full documentation
├── ADMIN_GUIDE.md             # Admin panel reference
├── ADMIN_IMPLEMENTATION.md    # Implementation details
├── SETUP.md                   # This file
├── .gitignore                 # Git ignore rules
├── templates/                 # HTML templates
│   ├── base.html              # Base template
│   ├── index.html             # Homepage
│   ├── login.html             # Login page
│   ├── register.html          # Registration
│   ├── dashboard.html         # User dashboard
│   ├── search.html            # Search (Reflected XSS)
│   ├── status.html            # Status (Reflected XSS)
│   ├── feedback.html          # Feedback (Stored XSS)
│   ├── profile.html           # User profile
│   ├── admin_dashboard.html   # Admin overview
│   ├── admin_users.html       # User management
│   └── admin_create_user.html # User creation
└── static/
    └── css/
        └── style.css          # Application styles
```

## Features Overview

### User Features
✅ User registration and authentication
✅ Session-based login with cookies
✅ Personal dashboard with payment history
✅ Search payments (vulnerable to XSS)
✅ Check payment status (vulnerable to XSS)
✅ Submit feedback (vulnerable to stored XSS)
✅ View profile

### Admin Features
✅ Admin dashboard with system stats
✅ View all registered users
✅ Create new user accounts
✅ Grant/revoke admin privileges
✅ Delete user accounts
✅ Protected admin routes

### Security Vulnerabilities (Intentional)
⚠️ Reflected XSS in search
⚠️ Reflected XSS in status check
⚠️ Stored XSS in feedback
⚠️ Non-HttpOnly cookies
⚠️ No CSRF protection
⚠️ SQL injection in search (bonus)

## Running Your Demo

### Recommended Demo Structure (20 min)

**Part 1: Introduction (2 min)**
- Explain the application
- Show the homepage
- Mention it's intentionally vulnerable

**Part 2: Reflected XSS (3 min)**
- Demonstrate search XSS
- Explain reflected vs stored

**Part 3: Stored XSS (5 min)**
- Submit malicious feedback
- Show persistence
- Login as different user
- Show it affects everyone

**Part 4: Session Hijacking (3 min)**
- Show non-HttpOnly cookies
- Demonstrate cookie access
- Explain session theft

**Part 5: Admin Panel (5 min)**
- Show admin features
- Create users
- Grant permissions
- Demonstrate privilege escalation

**Part 6: XSS + Admin = Complete Compromise (5 min)**
- Combine XSS with admin access
- Show how attacker gets admin session
- Create backdoor accounts
- Explain real-world impact

## Clean Up After Demo

```bash
# Reset database to clean state
python reset_db.py

# Or manually
rm typo_payments.db
python init_db.py
```

## Next Steps

Ready to go! Just run:
```bash
python app.py
```

And open: http://localhost:5000

Happy demoing! 🎯
