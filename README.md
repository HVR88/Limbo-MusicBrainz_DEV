# MusicBrainz Docker (DEV)

This repo is a streamlined, automation-first wrapper around the official MusicBrainz Docker stack. It keeps the modern multi-service architecture (Postgres, Solr, SIR, RabbitMQ, Redis) but removes the multi-step manual setup by adding bootstrap and scheduling services.

## Highlights

- One-command bring-up with automatic database import
- Materialized tables built by default
- Prebuilt Solr indexes downloaded by default
- Replication and indexing schedules controlled via simple env values
- Helper scripts for first run, validation, and manual jobs

## Quick start

1. Create `.env` from the example and validate it:

```bash
admin/preflight
```

2. Start everything (bootstrap + services):

```bash
./run.sh
```

That’s it. The initial import and indexing can take hours and consume significant disk.

## Configuration

Edit `.env` for the most common settings. The file is organized with a “common” section at the top and advanced settings below.

Common settings:
- `MUSICBRAINZ_WEB_SERVER_HOST`
- `MUSICBRAINZ_WEB_SERVER_PORT`
- `STATIC_RESOURCES_LOCATION`
- `MUSICBRAINZ_SERVER_PROCESSES`
- `MUSICBRAINZ_REPLICATION_ENABLED`
- `MUSICBRAINZ_REPLICATION_TIME` (HH:MM, 24-hour)
- `MUSICBRAINZ_REPLICATION_TOKEN`
- `MUSICBRAINZ_INDEXING_ENABLED`
- `MUSICBRAINZ_INDEXING_TIME` (HH:MM, 24-hour)
- `MUSICBRAINZ_INDEXING_DAY` (English day name)
- `MUSICBRAINZ_INDEXING_FREQUENCY` (daily | weekly | biweekly)
- `POSTGRES_SHARED_BUFFERS`
- `POSTGRES_SHM_SIZE`
- `SOLR_HEAP`

Advanced settings are below the divider in `.env` and generally do not need changes.

## Replication

Replication is controlled by three env vars:
- `MUSICBRAINZ_REPLICATION_ENABLED=true|false`
- `MUSICBRAINZ_REPLICATION_TIME=HH:MM`
- `MUSICBRAINZ_REPLICATION_TOKEN=...`

When enabled, the container generates its own cron entry. The token can be provided directly via env.

Manual replication:

```bash
admin/replicate-now
```

## Search indexing schedule

If live indexing is not enabled, scheduled reindexing keeps search fresh.

Env controls:
- `MUSICBRAINZ_INDEXING_ENABLED=true|false`
- `MUSICBRAINZ_INDEXING_TIME=HH:MM`
- `MUSICBRAINZ_INDEXING_DAY=Sunday` (ignored when frequency is daily)
- `MUSICBRAINZ_INDEXING_FREQUENCY=daily|weekly|biweekly`

Manual reindex:

```bash
admin/reindex-now
```

## Bootstrap behavior

Bootstrap runs once on first startup and writes marker files into the shared volumes. It will skip future runs unless markers are removed.

To reset bootstrap markers:

```bash
admin/bootstrap reset
```

## Helper scripts

- `admin/first-run` – create `.env` from `.env.example`
- `admin/validate-env` – validate key env values
- `admin/preflight` – first-run + validate + `docker compose config`
- `admin/bootstrap` – enable/disable/reset bootstrap override
- `admin/replicate-now` – run replication immediately
- `admin/reindex-now` – run search reindex immediately
- `admin/update-upstream` – pull changes from upstream

## Upstream updates

This repo is not a fork. Upstream is configured as:
- `origin` → your repo
- `upstream` → `metabrainz/musicbrainz-docker`

To update from upstream:

```bash
admin/update-upstream
```

## Notes

- First import and indexing can take hours and consume hundreds of GB.
- This setup keeps the official multi-service layout and adds automation.
- Solr and other service ports should not be exposed publicly without proper hardening.

