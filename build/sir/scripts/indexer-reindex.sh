#!/bin/sh

set -eu

log() {
  echo "[indexer-reindex] $*"
}

is_true() {
  case "${1:-}" in
    1|true|TRUE|yes|YES|on|ON) return 0 ;;
    *) return 1 ;;
  esac
}

to_lower() {
  echo "$1" | tr '[:upper:]' '[:lower:]'
}

normalize_day() {
  case "$(to_lower "$1")" in
    sun|sunday) echo 0 ;;
    mon|monday) echo 1 ;;
    tue|tues|tuesday) echo 2 ;;
    wed|wednesday) echo 3 ;;
    thu|thur|thurs|thursday) echo 4 ;;
    fri|friday) echo 5 ;;
    sat|saturday) echo 6 ;;
    *) echo -1 ;;
  esac
}

if ! is_true "${MUSICBRAINZ_INDEXING_ENABLED:-0}"; then
  exit 0
fi

freq="${MUSICBRAINZ_INDEXING_FREQUENCY:-weekly}"
freq="$(to_lower "$freq")"
case "$freq" in
  daily|weekly|biweekly) ;;
  *)
    log "Invalid MUSICBRAINZ_INDEXING_FREQUENCY: '$freq' (daily|weekly|biweekly)"
    exit 1
    ;;
 esac

if [ "$freq" != "daily" ]; then
  day_val="${MUSICBRAINZ_INDEXING_DAY:-Sunday}"
  day_num="$(normalize_day "$day_val")"
  if [ "$day_num" -lt 0 ]; then
    log "Invalid MUSICBRAINZ_INDEXING_DAY: '$day_val'"
    exit 1
  fi
  today_num=$(date +%w)
  if [ "$today_num" -ne "$day_num" ]; then
    log "Not scheduled day ($day_val); skipping."
    exit 0
  fi
fi

if [ "$freq" = "biweekly" ]; then
  week=$(date +%V)
  if [ $((week % 2)) -ne 0 ]; then
    log "Biweekly schedule: odd ISO week $week; skipping."
    exit 0
  fi
fi

marker="${MUSICBRAINZ_BOOTSTRAP_DB_MARKER:-/media/dbdump/.bootstrap.db.done}"
if [ -n "$marker" ] && [ ! -f "$marker" ]; then
  log "DB bootstrap marker not found at $marker; skipping."
  exit 0
fi

lock_dir="/tmp/sir-reindex.lock"
if ! mkdir "$lock_dir" 2>/dev/null; then
  log "Another reindex appears to be running; skipping."
  exit 0
fi
trap 'rmdir "$lock_dir"' EXIT

# Basic readiness check for search host:port
search="${MUSICBRAINZ_SEARCH_SERVER:-search:8983/solr}"
search_host="${search%%/*}"
search_host="${search_host#http://}"
search_host="${search_host#https://}"
search_port="${search_host##*:}"
if [ "$search_port" = "$search_host" ]; then
  search_port=8983
  search_host="$search_host"
else
  search_host="${search_host%%:*}"
fi

python - <<PY
import socket, time, sys
host = "${search_host}"
port = int("${search_port}")
start = time.time()
while time.time() - start < 60:
    try:
        with socket.create_connection((host, port), timeout=5):
            sys.exit(0)
    except OSError:
        time.sleep(3)
print("[indexer-reindex] Search not reachable; skipping.")
sys.exit(0)
PY

log "Starting full reindex (this can take hours)."
python -m sir reindex
log "Reindex complete."
