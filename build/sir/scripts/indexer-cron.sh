#!/bin/sh

set -eu

log() {
  echo "[indexer-cron] $*"
}

is_true() {
  case "${1:-}" in
    1|true|TRUE|yes|YES|on|ON) return 0 ;;
    *) return 1 ;;
  esac
}

if ! is_true "${MUSICBRAINZ_INDEXING_ENABLED:-0}"; then
  log "Indexing disabled (MUSICBRAINZ_INDEXING_ENABLED=${MUSICBRAINZ_INDEXING_ENABLED:-0})."
  log "Sleeping."
  sleep infinity
fi

time_val="${MUSICBRAINZ_INDEXING_TIME:-01:00}"
if ! echo "$time_val" | grep -Eq '^([01][0-9]|2[0-3]):[0-5][0-9]$'; then
  echo "Invalid MUSICBRAINZ_INDEXING_TIME: '$time_val' (expected HH:MM 24hr)" >&2
  exit 1
fi

hh="${time_val%%:*}"
mm="${time_val##*:}"

cat > /crons.conf <<EOC
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
${mm} ${hh} * * * /usr/local/bin/indexer-reindex.sh
EOC

crontab /crons.conf
log "Cron installed for ${time_val} daily; frequency handled by indexer-reindex.sh."
exec cron -f
