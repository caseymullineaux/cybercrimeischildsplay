# Changelog

## 2025-11-25 - SQL Injection Feature Added

### Added
- **Status page** (`/status` route) - Now vulnerable to SQL injection
- **`check_status()` function** with intentional SQLi vulnerability
- **`templates/status.html`** with educational SQLi examples
- **Navigation link** to Status page in `base.html`
- **`docs/SQLI_PAYLOADS.md`** - Comprehensive SQL injection attack documentation

### Key Features
- SQL injection vulnerability demonstrates string concatenation risks
- Error messages displayed to help with SQLi exploitation
- Built-in educational hints and example payloads on the page
- Attack chain demonstrations (SQLi → credential theft → privilege escalation)

### Demo Capabilities
1. **Basic SQLi**: Bypass user restrictions with `?id=1 OR 1=1--`
2. **Data Extraction**: Extract user credentials with UNION SELECT
3. **Admin Discovery**: Find admin accounts and password hashes
4. **Database Enumeration**: List all tables and columns
5. **Attack Chains**: Combine SQLi + XSS for full compromise

### Security Lessons
- Never use string concatenation/formatting for SQL queries
- Always use parameterized queries
- Don't expose detailed error messages
- Demonstrates real-world attack scenarios

---

## 2025-11-25 - Status Page Removal (Later Re-added)

### Removed (Temporary)
- Status page was temporarily removed to simplify demo
- Later re-added with SQL injection vulnerability for advanced demos

---

## Initial Release - 2025-11-25

### Features
- Flask-based vulnerable web application
- SQLite database with sample data
- User authentication system
- Admin permission system
- Reflected XSS in search
- Stored XSS in feedback
- Docker containerization
- Comprehensive documentation
