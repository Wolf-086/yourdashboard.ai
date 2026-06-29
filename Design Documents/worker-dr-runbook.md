# Worker DR Runbook

## Architecture Overview

The worker tier processes asynchronous jobs from a queue. Each worker polls a task queue, executes the job, writes results to a Supabase backend, and reports status back through a monitoring layer. Workers are stateless — any worker can pick up any job. State lives in Supabase (PostgreSQL + Storage) and the queue itself. Recovery means getting workers running again and confirming the data layer is healthy.

```
[Queue] -> [Worker Pool] -> [Supabase (DB + Storage)]
 |
 v
 [Monitoring / Alerts]
```

## Worker Process Restart Steps

### Prerequisites
- SSH / terminal access to the worker host(s)
- Supabase project credentials in the secure store
- Docker or service manager access (`systemd` / `pm2` / etc.)

### Step 1 — Detect Failure
- Check process manager: `systemctl status worker` or `pm2 list`
- Confirm the worker process is `inactive`, `failed`, or absent
- Pull recent logs: `journalctl -u worker -n 100` or `pm2 logs worker`

### Step 2 — Stop Existing Processes Gracefully
- If any worker is still partially alive, drain it first:
  - Send SIGTERM (allows in-flight jobs to finish)
  - Wait 30 seconds
  - Force-kill with SIGKILL if still present:
    `systemctl kill --signal=SIGKILL worker` or `pm2 kill`

### Step 3 — Verify Queue Health
- Confirm the queue has no poison messages that will crash workers on boot:
  - Check queue depth and DLQ (dead-letter queue) count
  - If DLQ has entries, acknowledge or move them aside before restarting

**Executable commands:**
```bash
# Check queue depth (Redis-based queue example)
redis-cli LLEN worker:queue

# Check dead-letter queue entries
redis-cli LLEN worker:queue:dlq

# List poison messages in DLQ (first 10)
redis-cli LRANGE worker:queue:dlq 0 9

# Acknowledge/remove poison message by ID
redis-cli LREM worker:queue:dlq 0 '{"id":"poison-job-123","status":"failed"}'

# Move DLQ entries to an archive list
redis-cli RPOPLPUSH worker:queue:dlq worker:queue:dlq:archive

# Valid for RabbitMQ:
# rabbitmqctl list_queues name messages consumers
# rabbitmqctl list_queues name messages dead | grep worker
```

### Step 4 — Start Workers
- Start via service manager:
  `systemctl start worker` or `pm2 start worker --name worker`
- Watch startup logs for the first 30 seconds to confirm healthy polling

### Step 5 — Confirm Workers Are Processing
- Check logs for a "polling" or "connected" message
- Verify queue depth is decreasing
- Spot-check one completed job in Supabase to confirm end-to-end flow

**Executable commands:**
```bash
# Check worker logs for poll/connect signals (last 50 lines)
journalctl -u worker -n 50 --no-pager | grep -E "polling|connected|job_started|job_completed"
# Or pm2:
pm2 logs worker --lines 50 | grep -E "polling|connected|job_started|job_completed"

# Verify queue depth is decreasing (poll twice, 10s apart)
redis-cli LLEN worker:queue
sleep 10
redis-cli LLEN worker:queue

# Supabase: spot-check a recently completed job via psql
psql "$SUPABASE_DB_URL" -c \
 "SELECT id, status, created_at, updated_at FROM jobs WHERE status = 'completed' ORDER BY updated_at DESC LIMIT 1;"

# Supabase: verify storage file exists for completed job
supabase storage ls worker-outputs --limit 1 --prefix "$(psql "$SUPABASE_DB_URL" -Atc "SELECT id FROM jobs WHERE status = 'completed' ORDER BY updated_at DESC LIMIT 1;")"
```

### Step 6 — Clean Up
- Archive old logs
- Update the incident log (time, duration, root cause)

---

## Supabase Backup / Restore Procedure

### Backup (Daily, Automated)
1. Use `pg_dump` against the Supabase database:
   ```
   pg_dump -Fc -f backup_{date}.dump postgres://user:***@host:5432/postgres
   ```
2. Copy the dump to object storage (S3 / R2 / equivalent) with 30-day retention
3. Verify: `pg_restore -l backup_{date}.dump | head`

### Restore
1. Confirm target database is healthy or create a fresh project
2. Stop accepting new traffic (maintenance mode or traffic reroute)
3. Restore the dump:
   ```
   pg_restore -d postgres://user:***@host:5432/postgres backup_{date}.dump
   ```
4. Run sanity queries (row counts on critical tables)
5. Re-enable traffic and confirm worker processing resumes

### Point-in-Time Notes
- Supabase supports PITR via its control panel. Use the dashboard for restores finer than daily dumps.
- Storage files (buckets) are separate — back up buckets independently if required.

---

## Monitoring Checks

Check these every 5 minutes during an incident:

- **CPU** — alert if > 85 % sustained for 3 minutes
- **Memory** — alert if > 90 % or OOM events in logs
- **Queue Depth** — alert if depth grows instead of shrinking for 5 minutes
- **Error Rate** — alert if > 5 % of last 100 jobs failed

**Executable commands:**
```bash
# CPU usage (1-second sample, 3 iterations)
mpstat -P ALL 1 3 | awk '/Average:/ && $3 ~ /[0-9]/ {print $1, $3"%"}'

# Memory usage (percentage used)
free -m | awk '/Mem:/ {printf "%.1f%%\n", $3/$2 * 100}'

# OOM events in last 15 minutes
journalctl -u worker --since "15 min ago" --no-pager | grep -i "out of memory\|oom-killer\|killed process"

# Queue depth (Redis example)
redis-cli LLEN worker:queue
# If using RabbitMQ:
# rabbitmqctl list_queues name messages | grep worker

# Error rate from last 100 jobs (Supabase/psql)
psql "$SUPABASE_DB_URL" -Atc \
 "SELECT ROUND(100.0 * SUM(CASE WHEN status = 'failed' THEN 1 ELSE 0 END) / COUNT(*), 1) FROM jobs ORDER BY created_at DESC LIMIT 100;"

# Failed job count in last 100
psql "$SUPABASE_DB_URL" -Atc \
 "SELECT COUNT(*) FROM (SELECT status FROM jobs ORDER BY created_at DESC LIMIT 100) t WHERE status = 'failed';"
```

Healthy steady state:
- CPU 10–40 %
- Memory stable with headroom
- Queue depth trending to zero
- Error rate near 0 %

---

## Escalation to Scott

Ping Scott if any of the following are true:
- Worker pool is not processing jobs within 20 minutes of restart
- Supabase restore fails or data integrity checks fail
- Monitoring shows recurring crashes (more than 2 restarts in 30 minutes)
- Root cause is unknown after initial triage

Contact: Scott Mason
Priority: P1 — page immediately. Reply expected within 10 minutes.

---

## Recovery Target

**30 minutes end-to-end** from detection to confirmed processing.

Breakdown:
- Detection & triage — 5 min
- Worker restart — 10 min
- Supabase health check — 5 min
- End-to-end validation — 5 min
- Buffer for unknowns — 5 min

If this target is missed, document why in the incident log and schedule a post-mortem.
