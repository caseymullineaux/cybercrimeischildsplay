# 🚀 Quick Reference Card

## One-Command Start

```bash
docker-compose up
```

**→ http://localhost:5000**

---

## 👥 Demo Accounts

| User | Password | Role |
|------|----------|------|
| `admin` | `admin123` | 🛡️ Admin |
| `alice` | `password123` | 👤 User |
| `bob` | `password123` | 👤 User |

---

## 🎯 XSS Attack URLs

### Reflected XSS - Search
```
/search?q=<script>alert('XSS')</script>
/search?q=<img src=x onerror=alert(document.cookie)>
```

### Stored XSS - Feedback
```html
<script>alert('Stored XSS')</script>
<img src=x onerror=alert(document.cookie)>
```

---

## 🐳 Docker Commands

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

# Shell access
docker-compose exec typo-payments sh

# Complete cleanup
docker-compose down -v
```

---

## 📝 Makefile Commands

```bash
make up        # Start
make down      # Stop
make logs      # View logs
make reset     # Reset DB
make shell     # Open shell
make clean     # Clean all
make help      # Show all
```

---

## 🎬 Demo Flow (15 min)

**1. Start (1 min)**
```bash
docker-compose up -d
# Open http://localhost:5000
```

**2. Basic XSS (4 min)**
- Login as alice
- Search: `<script>alert('XSS')</script>`
- Show cookie: `<img src=x onerror=alert(document.cookie)>`

**3. Stored XSS (4 min)**
- Go to Feedback
- Submit: `<script>alert('Stored!')</script>`
- Login as bob - show it affects everyone

**4. Admin Access (3 min)**
- Login as admin
- Show admin dashboard
- Create user / grant permissions

**5. Complete Compromise (3 min)**
- Show XSS + admin = full access
- Explain cookie theft scenario
- Demonstrate privilege escalation

---

## 📱 Key Pages

| Page | URL | Purpose |
|------|-----|---------|
| Home | `/` | Landing page |
| Login | `/login` | Authentication |
| Dashboard | `/dashboard` | User payments |
| Search | `/search` | Reflected XSS |
| Feedback | `/feedback` | Stored XSS |
| Profile | `/profile` | Show cookies |
| Admin | `/admin` | Admin dashboard |
| Users | `/admin/users` | User management |

---

## 🎯 Demo Talking Points

### What to Show
- ✅ Reflected XSS in search
- ✅ Stored XSS in feedback
- ✅ Cookie theft capability
- ✅ Admin panel features
- ✅ Privilege escalation
- ✅ Session hijacking risk

### What to Explain
- ✅ XSS = executing attacker's JavaScript
- ✅ Reflected vs Stored difference
- ✅ Non-HttpOnly cookies = vulnerable
- ✅ XSS + Admin = complete compromise
- ✅ Real-world impact
- ✅ How to fix (output encoding, HttpOnly, CSP)

---

## 🛡️ Security Issues

| Issue | Location | Impact |
|-------|----------|--------|
| Reflected XSS | `/search` | Immediate execution |
| Stored XSS | `/feedback` | Persistent, affects all users |
| Non-HttpOnly | All pages | Cookies accessible via JS |
| No CSRF | All forms | Can be submitted externally |

---

## 🔧 Quick Fixes to Mention

### Fix XSS
```python
# Remove |safe filter in templates
{{ query }}  # Instead of {{ query|safe }}
```

### Fix Cookies
```python
app.config['SESSION_COOKIE_HTTPONLY'] = True
app.config['SESSION_COOKIE_SECURE'] = True
app.config['SESSION_COOKIE_SAMESITE'] = 'Lax'
```

### Add CSP
```python
@app.after_request
def set_csp(response):
    response.headers['Content-Security-Policy'] = "default-src 'self'"
    return response
```

---

## 🧹 Reset & Cleanup

```bash
# Quick reset
make reset

# Full cleanup
make clean

# Or manually
docker-compose down -v
rm -rf ./data
```

---

## 📚 Documentation

- 📖 **README.md** - Main docs
- 🐳 **DOCKER.md** - Docker guide
- 💻 **SETUP.md** - Setup guide
- 🎯 **GETTING_STARTED.md** - Quick start
- 💉 **XSS_PAYLOADS.md** - Attack examples
- 🛡️ **ADMIN_GUIDE.md** - Admin features

---

## ⚠️ Remember

- ❌ Don't deploy to production
- ❌ Don't expose to internet
- ❌ Don't use real data
- ✅ Use for education only
- ✅ Controlled environments
- ✅ Explain vulnerabilities clearly

---

## 🎓 Learning Objectives

After this demo, attendees should understand:
- How XSS attacks work
- Reflected vs Stored XSS
- Session hijacking techniques
- Impact of XSS on privileged accounts
- Basic XSS prevention methods
- Importance of secure coding

---

**Need help? Run:** `make help`

**Ready? Start with:** `docker-compose up`

**Access at:** http://localhost:5000

---

*Keep this card handy during your demo!* 📋
