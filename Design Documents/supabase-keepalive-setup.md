# Supabase Keep-Alive Ping

## Purpose

Supabase Free tier projects enter a 7-day pause after 7 days of inactivity. This setup keeps the project active with a weekly health ping so development and preview deploys stay warm.

## What It Does

- Hits the Supabase health endpoint once per week
- Logs success / failure for debugging
- Runs on a local machine and survives reboots

## Files

`scripts/supabase-keepalive.sh`
`scripts/supabase-keepalive.bat`

## Requirements

Windows 10+, Git Bash (MSYS), curl.

## Environment Variables

Create a `.env` file in the same folder as the script, or set system-level variables.

`SUPABASE_PROJECT_REF` — your project ref ID (found in Supabase dashboard URL or Settings)
`SUPABASE_API_KEY` — **anon key only**. Do not use the `service_role` key for health checks; it grants full admin access to your Supabase project and should never be shared. The anon key has read-only permissions and is safe for public health endpoints.

Example:

```
SUPABASE_PROJECT_REF=abcdefghijklmnopqrstu
SUPABASE_API_KEY=eyJhbG...
```

## Setup

1. Create the scripts folder if missing.
2. Save `supabase-keepalive.sh` and `supabase-keepalive.bat` in that folder.
3. Create a `.env` file there with the two variables above.
4. Add `.env` to `.gitignore` in every repo that could accidentally commit it. The `.env` file contains secrets and is stored **unencrypted at rest** on disk — treat it like a password file.
5. Install the cron job with Task Scheduler so it runs at boot and repeats weekly.

## Task Scheduler Setup

- Action: Start a program
- Program: `scripts/supabase-keepalive.bat`
- Trigger: At startup, repeat every 7 days indefinitely
- Conditions: Wake the computer to run this task
- History: enabled

## Health Endpoint

Supabase health check:
`https://<project_ref>.supabase.co/rest/v1/` with the `apikey` header set to the API key.

The script follows redirects and treats HTTP 2xx as active.

## Logs

Each run appends a timestamped line to:
`logs/supabase-keepalive.log`

Sample log line:
`[2026-06-29T12:00:00Z] OK 200`

Failure line:
`[2026-07-06T12:00:00Z] FAIL 000`

## Troubleshooting

- `curl: (6) Could not resolve host` — the project ref or network is wrong.
- `401 Unauthorized` — check `SUPABASE_API_KEY`.
- No log lines — the Task Scheduler trigger is missing or disabled.

## Upgrade Path

Once the project is actively used, disable the cron job and upgrade to Supabase Pro ($25/mo) to remove the activity requirement entirely.
