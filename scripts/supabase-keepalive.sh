#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="${SCRIPT_DIR}/../logs"
mkdir -p "${LOG_DIR}" >/dev/null 2>&1 || true
LOG_FILE="${LOG_DIR}/supabase-keepalive.log"

if [[ -f "${SCRIPT_DIR}/.env" ]]; then
  set -a
  source "${SCRIPT_DIR}/.env"
  set +a
fi

if [[ -z "${SUPABASE_PROJECT_REF:-}" || -z "${SUPABASE_API_KEY:-}" ]]; then
  echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] FAIL MISSING_ENV" >> "${LOG_FILE}"
  exit 1
fi

URL="https://${SUPABASE_PROJECT_REF}.supabase.co/rest/v1/"
HTTP_CODE=$(curl -s -o /dev/null -w '%{http_code}' \
  -H "apikey: ${SUPABASE_API_KEY}" \
  -H 'Accept: application/json' \
  --max-time 30 "${URL}" || true)

if [[ "${HTTP_CODE}" =~ ^2 ]]; then
  STATUS="OK"
else
  STATUS="FAIL"
fi

echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] ${STATUS} ${HTTP_CODE}" >> "${LOG_FILE}"
exit 0
