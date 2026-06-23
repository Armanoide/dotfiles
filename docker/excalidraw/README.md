# Excalidraw Self-Hosted

Self-hosted Excalidraw instance with persistent storage and live collaboration.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Traefik (Reverse Proxy)                   │
│  draw.armanoide.net      → excalidraw (frontend)            │
│  room.draw.armanoide.net → excalidraw_room (WebSocket)      │
│  storage.draw.armanoide.net → excalidraw_storage (nginx)    │
└─────────────────────────────────────────────────────────────┘
                              │
              ┌───────────────┼───────────────┐
              ▼               ▼               ▼
        ┌──────────┐  ┌────────────┐  ┌──────────────┐
        │ Frontend │  │ Room (WS)  │  │ Storage (API)│
        │ nginx    │  │ WebSocket  │  │ nginx +      │
        │ (patched)│  │            │  │ backend      │
        └──────────┘  └────────────┘  └──────┬───────┘
              │                              │
              ▼                              ▼
        ┌──────────┐                  ┌──────────┐
        │  /tmp     │                  │ MongoDB  │
        │ (ephemeral)│                 │ (named   │
        └──────────┘                  │ volumes) │
                                      └──────────┘
```

## Services

| Service | Image | Port | Purpose |
|---------|-------|------|---------|
| `excalidraw` | `excalidraw/excalidraw:latest` | 80 | Frontend (patched with sed) |
| `excalidraw_room` | `excalidraw/excalidraw-room:sha-03ff435` | 80 | Live collaboration (WebSocket) |
| `excalidraw_storage` | `nginx:alpine` | 80 | API proxy |
| `excalidraw_storage_backend` | `excalidraw-storage-backend:latest` | 8080 | Scene/room/file storage |
| `excalidraw_db` | `mongo:7` | 27017 | Persistent storage |

## Volumes (for ZéroBytes backup)

| Volume | Path | Purpose |
|--------|------|---------|
| `excalidraw_mongo_data` | `/data/db` | MongoDB data |
| `excalidraw_mongo_configdb` | `/data/configdb` | MongoDB config |

## Custom Image

`excalidraw-storage-backend:latest` is built from `alswl/excalidraw-storage-backend:v2023.11.11` with a patch to handle MongoDB Buffer serialization:

```dockerfile
FROM alswl/excalidraw-storage-backend:v2023.11.11
USER root
RUN sed -i 's/stream\.push(data);/if (typeof data === "object" && data.data) { stream.push(Buffer.from(data.data)); } else if (Buffer.isBuffer(data)) { stream.push(data); } else { stream.push(JSON.stringify(data)); }/' /app/dist/scenes/scenes.controller.js
USER node
```

## Frontend Patching

The frontend is patched at startup with `sed` to redirect API calls:
- `https://oss-collab.excalidraw.com` → `https://room.draw.armanoide.net`
- `https://json.excalidraw.com/api/v2/post/` → `https://storage.draw.armanoide.net/api/v2/scenes/`
- `https://json.excalidraw.com/api/v2/` → `https://storage.draw.armanoide.net/api/v2/scenes/`

## Backup

All persistent data is in named Docker volumes:
- `excalidraw_mongo_data`
- `excalidraw_mongo_configdb`

ZéroBytes can backup these volumes directly.

## Share Links

Share links are persistent (stored in MongoDB, no expiration).

Format: `https://draw.armanoide.net/#json=<scene_id>,<encryption_key>`

## Live Collaboration

Live collaboration rooms are ephemeral (stored in memory, lost on restart).

Format: `https://draw.armanoide.net/#room=<room_id>,<session_key>`
