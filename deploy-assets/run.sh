#!/usr/bin/env bash
set -euo pipefail

ENV_FILE="${ENV_FILE:-.env}"

if [ ! -f "$ENV_FILE" ]; then
  echo "Missing .env file. Please edit .env before starting." >&2
  exit 1
fi

compose_profiles=$(
  grep -E '^[[:space:]]*COMPOSE_PROFILES=' "$ENV_FILE" \
    | tail -n 1 \
    | cut -d= -f2- \
    || true
)

compose_profiles=${compose_profiles%%#*}
compose_profiles=$(printf '%s' "$compose_profiles" | tr -d "\"'" | tr -d '[:space:]')

if [ -z "$compose_profiles" ] || ! printf ',%s,' "$compose_profiles" | grep -q ',mbms,'; then
  echo "You need to edit the .env file before starting. Uncomment COMPOSE_PROFILES=mbms." >&2
  exit 1
fi

docker compose up -d
