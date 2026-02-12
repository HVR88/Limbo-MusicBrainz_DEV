# MBMS_PLUS

MusicBrainz Mirror Server PLUS - Full stack with Lidarr API Bridge.

This repo provides a prebuilt, docker-compose based deployment of MBMS_PLUS.

## Quick start

1. Clone the repo:

```bash
git clone https://github.com/HVR88/MBMS_PLUS.git
cd MBMS_PLUS
```

2. Edit `.env` (Recommended section at the top):

- `MUSICBRAINZ_REPLICATION_TOKEN` (required for replication)
- `MUSICBRAINZ_WEB_SERVER_HOST` / `MUSICBRAINZ_WEB_SERVER_PORT` as needed
- Optional provider keys for LM-Bridge (FANART/LASTFM/SPOTIFY)

3. Start the stack:

```bash
docker compose up -d
```

## Notes

- First import and indexing can take hours and require large disk (hundreds of GB).
- This stack is intended for private use; do not expose services publicly without hardening.

## Reference

For full details, see the main project README in the source repo: https://github.com/HVR88/musicbrainz_stack-DEV
