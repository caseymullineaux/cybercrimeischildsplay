# 🔴 Bad Coding Practices (Educational Examples)

## ⚠️ WARNING
This document shows **INTENTIONALLY BAD CODE** for educational purposes. These are examples of what **NOT TO DO** in production applications!

---

## 🔥 SQL Injection: The "Worst Way" to Write Queries

### ❌ BAD CODE (from `/status` endpoint)

```python
# EXTREMELY VULNERABLE: Building SQL by concatenating user input directly!
payment_id = request.args.get("id", "")  # User-controlled input

# Bad practice #1: String concatenation with user input
query = "SELECT * FROM payments WHERE user_id = " + str(current_user.id)
query = query + " AND id = " + payment_id  # ← Directly concatenating user input!

# Bad practice #2: No input validation or sanitization
# Bad practice #3: Executing the raw concatenated string
cursor.execute(query)
```

### Why This Is Terrible

1. **Direct String Concatenation**: Using `+` to build SQL with user input
2. **No Validation**: `payment_id` comes directly from URL parameter
3. **No Sanitization**: Attacker can inject ANY SQL code
4. **Obvious Vulnerability**: Even beginners can spot this is wrong

### Attack Example

**Normal use:**
```
/status?id=123
→ SELECT * FROM payments WHERE user_id = 1 AND id = 123
```

**Malicious use:**
```
/status?id=1 UNION SELECT 1,2,'hacked',0.00,'stolen data','pwned',CURRENT_TIMESTAMP
→ SELECT * FROM payments WHERE user_id = 1 AND id = 1 UNION SELECT...
```

---

## ✅ CORRECT WAY: Parameterized Queries

### The Right Way

```python
# SECURE: Using parameterized queries
payment_id = request.args.get("id", "")

# Good practice: Use placeholders (%s) and pass values separately
query = "SELECT * FROM payments WHERE user_id = %s AND id = %s"
cursor.execute(query, (current_user.id, payment_id))  # ← Values in tuple!
```

### Why This Is Safe

1. **Separation**: SQL structure separated from data
2. **Database Escaping**: Driver automatically escapes special characters
3. **Type Safety**: Values are properly typed and validated
4. **No Injection**: Impossible to break out of the value context

---

## 🎯 Comparison: Bad vs Good

### ❌ INSECURE CODE
```python
# String concatenation = SQL injection vulnerability
query = "SELECT * FROM users WHERE id = " + user_id
cursor.execute(query)

# F-string formatting = SQL injection vulnerability  
query = f"SELECT * FROM users WHERE id = {user_id}"
cursor.execute(query)

# .format() = SQL injection vulnerability
query = "SELECT * FROM users WHERE id = {}".format(user_id)
cursor.execute(query)

# % operator = SQL injection vulnerability
query = "SELECT * FROM users WHERE id = %s" % user_id
cursor.execute(query)
```

### ✅ SECURE CODE
```python
# Parameterized query with tuple = SAFE!
query = "SELECT * FROM users WHERE id = %s"
cursor.execute(query, (user_id,))  # ← Note the tuple!

# Multiple parameters = SAFE!
query = "SELECT * FROM payments WHERE user_id = %s AND amount > %s"
cursor.execute(query, (user_id, min_amount))
```

---

## 🔍 How to Spot SQL Injection Vulnerabilities

### Red Flags 🚩

1. **String Concatenation**: `query = "..." + user_input`
2. **F-strings with user input**: `f"SELECT * FROM table WHERE id = {user_input}"`
3. **No parameter binding**: `execute(raw_string)` instead of `execute(query, params)`
4. **Direct URL/form input in SQL**: `request.args.get("id")` directly in query string

### Safe Patterns ✅

1. **Placeholders**: Use `%s` (PostgreSQL), `?` (SQLite), or `:name` (named parameters)
2. **Tuple/list of values**: Pass values separately: `execute(query, (val1, val2))`
3. **ORM usage**: Use Django ORM, SQLAlchemy, etc. (they handle escaping)
4. **Input validation**: Even with parameterization, validate input types/ranges

---

## 📚 Other Bad Practices in This Demo

### XSS Vulnerabilities

```python
# VULNERABLE: No sanitization of user input
message = request.form["message"]  # User input from form
# Store directly without cleaning HTML/JavaScript
cursor.execute("INSERT INTO feedback (message) VALUES (%s)", (message,))

# Then in template:
# {{ message|safe }}  ← Renders as HTML/JavaScript = XSS!
```

### Debug Output to Users

```python
except Exception as e:
    # VULNERABLE: Showing SQL errors to users
    error = str(e)  # ← Reveals database structure, table names, etc.
    print(f"[DEBUG] SQL Error: {error}")  # ← Logs help attackers
```

### Insecure Configuration

```python
# VULNERABLE: Hardcoded secrets
app.secret_key = "insecure_secret_key_for_demo"

# VULNERABLE: Allows JavaScript to access cookies
app.config["SESSION_COOKIE_HTTPONLY"] = False

# VULNERABLE: Debug mode in production
app.run(debug=True, host="0.0.0.0")
```

---

## 🎓 Educational Value

### Why Write Bad Code on Purpose?

1. **Recognition**: Learn to spot vulnerabilities in code reviews
2. **Understanding**: See how attacks actually work
3. **Prevention**: Understand why secure coding practices exist
4. **Real-world**: These mistakes happen in production all the time!

### The Progression

```
Beginner Mistake:
"I'll just concatenate the string, it's easier"
                ↓
SQL Injection Vulnerability
                ↓
Database Compromise
                ↓
Data Breach, Business Loss, Legal Issues
```

### The Fix

```
Secure Approach:
"I'll use parameterized queries from the start"
                ↓
SQL Injection Prevention
                ↓
Secure Application
                ↓
Protected Data, Happy Users, Compliance
```

---

## 🛠️ How to Fix the Demo App

### Step 1: Fix SQL Injection in `/status`

**Before (INSECURE):**
```python
query = "SELECT * FROM payments WHERE user_id = " + str(current_user.id)
query = query + " AND id = " + payment_id
cursor.execute(query)
```

**After (SECURE):**
```python
query = "SELECT * FROM payments WHERE user_id = %s AND id = %s"
cursor.execute(query, (current_user.id, payment_id))
```

### Step 2: Fix XSS in Templates

**Before (INSECURE):**
```html
<p>Search results for: {{ query|safe }}</p>
<div>{{ message|safe }}</div>
```

**After (SECURE):**
```html
<p>Search results for: {{ query }}</p>  <!-- Auto-escaped -->
<div>{{ message|escape }}</div>  <!-- Explicit escape -->
```

### Step 3: Fix Configuration

**Before (INSECURE):**
```python
app.config["SESSION_COOKIE_HTTPONLY"] = False
```

**After (SECURE):**
```python
app.config["SESSION_COOKIE_HTTPONLY"] = True  # Protect from XSS
app.config["SESSION_COOKIE_SECURE"] = True    # HTTPS only
app.config["SESSION_COOKIE_SAMESITE"] = "Lax" # CSRF protection
```

---

## 📖 Further Reading

### OWASP Resources
- [OWASP SQL Injection](https://owasp.org/www-community/attacks/SQL_Injection)
- [OWASP XSS Prevention](https://cheatsheetseries.owasp.org/cheatsheets/Cross_Site_Scripting_Prevention_Cheat_Sheet.html)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)

### Language-Specific Guides
- [psycopg2 SQL Injection Prevention](https://www.psycopg.org/docs/usage.html#passing-parameters-to-sql-queries)
- [Python SQLAlchemy Security](https://docs.sqlalchemy.org/en/14/core/tutorial.html#using-textual-sql)
- [Flask Security Considerations](https://flask.palletsprojects.com/en/2.3.x/security/)

---

## 💡 Key Takeaways

1. ⚠️ **Never concatenate user input into SQL queries**
2. ✅ **Always use parameterized queries** (placeholders + value tuples)
3. 🔍 **Validate and sanitize ALL user input**
4. 🛡️ **Use prepared statements** provided by your database driver
5. 🧪 **Test for SQL injection** during development and security audits
6. 📚 **Follow OWASP guidelines** for secure coding
7. 🎓 **Learn from mistakes** (yours and others')

---

## 🎯 Demo Purpose

This application intentionally demonstrates bad practices to teach:
- How vulnerabilities are introduced
- How to recognize insecure code
- How attacks exploit these weaknesses
- Why secure coding practices exist
- How to fix common security issues

**Remember**: Understanding how to break things helps you build them securely! 🔒

---

**Status**: Educational Demonstration  
**Use Case**: Security Training & Vulnerability Research  
**Production Ready**: ❌ **ABSOLUTELY NOT!**
