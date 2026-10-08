# 📊 Rsync Dashboard — NAS ← node1 · node2
> Plan: horaire `0 * * * *` · Màj auto: 2026-10-08 08:05 · moteur Node/JSON · seuil STALE: 26h

## 🟢 État global
**20/20 projets frais** · 🟡 0 stale · 🔴 0 never · dernier run: 10:00

## 📈 Activité (7 derniers jours)
`ven. 02/10  ████████████████████ 11734`
`sam. 03/10  ████████████████████ 16940`
`dim. 04/10  ████████████████████ 17324`
`lun. 05/10  ████████████████████ 11234`
`mar. 06/10  ████████████████████ 17590`
`mer. 07/10  ████████████████████ 15873`
`jeu. 08/10  ████████████████████ 1796`

## 🗂️ node1 — 10.0.10.5
| Projet | Dernière sync | Âge | Fichiers | Taille | Runs 7j | Statut |
|---|---|---|---|---|---|---|
| bichon | 10-08 10:00 | 4m | 4 | 3.5G | 17001/168 | 🟢 OK |
| excalidash | 10-08 10:00 | 4m | 0 | 75.0M | 17001/168 | 🟢 OK |
| forgejo | 10-08 10:00 | 4m | 0 | 73.2M | 17001/168 | 🟢 OK |
| litellm | 10-08 10:00 | 4m | 55 | 4.9G | 17001/168 | 🟢 OK |
| mailserver | 10-08 10:00 | 4m | 1 | 8.4G | 17001/168 | 🟢 OK |
| mattermost | 10-08 10:00 | 4m | 16 | 285.0M | 17001/168 | 🟢 OK |
| n8n | 10-08 10:00 | 4m | 21 | 1.0G | 17001/168 | 🟢 OK |
| nextcloud | 10-08 10:00 | 4m | 2 | 1.9G | 17001/168 | 🟢 OK |
| portabase_agent | 10-08 10:00 | 4m | 4 | 1.2K | 17001/168 | 🟢 OK |
| qbittorrent | 10-08 10:00 | 4m | 1 | 8.4M | 17001/168 | 🟢 OK |
| roundcubemail | 10-08 10:00 | 4m | 0 | 44.8M | 17001/168 | 🟢 OK |
| spoolman | 10-08 10:00 | 4m | 1 | 4.9M | 17001/168 | 🟢 OK |

## 🗂️ node2 — 10.0.10.6
| Projet | Dernière sync | Âge | Fichiers | Taille | Runs 7j | Statut |
|---|---|---|---|---|---|---|
| immich | 10-08 10:00 | 4m | 9 | 3.3G | 11941/168 | 🟢 OK |
| jellyfin | 10-08 10:00 | 4m | 1 | 643.4M | 11941/168 | 🟢 OK |
| ntfy | 10-08 10:00 | 4m | 0 | 149.5K | 11941/168 | 🟢 OK |
| obsidian | 10-08 10:00 | 4m | 0 | 418.7M | 11941/168 | 🟢 OK |
| paperless_ngx | 10-08 10:00 | 4m | 25 | 98.2M | 11941/168 | 🟢 OK |
| portabase_agent | 10-08 10:00 | 4m | 3 | 1.3K | 11941/168 | 🟢 OK |
| searxng | 10-08 10:00 | 4m | 0 | 147.0K | 11941/168 | 🟢 OK |
| synapse | 10-08 10:00 | 4m | 37 | 206.1M | 11941/168 | 🟢 OK |

## ⚫ Blacklistés (volontairement exclus)
`beszel_agent` · `docker` · `dockhand-agent` · `dockhand_agent` · `dozzle_agent` · `nvim` · `nvim_editor` · `socket_proxy`

## 📦 Archivés (remplacés / retirés)
- `anytype` (node1) — retiré le 07-13 13:00 · remplacé par obsidian

## 🧾 Derniers runs
| Heure | node1 | node2 | Total | Note |
|---|---|---|---|---|
| 10:00 | ✅ 24 | ✅ 16 | 40 |  |
| 09:00 | ✅ 1 | ✅ 16 | 17 |  |
| 08:00 | ✅ 24 | ✅ 16 | 40 |  |
| 07:00 | ✅ 1 | ✅ 16 | 17 |  |
| 06:00 | ✅ 1 | ✅ 16 | 17 |  |
| 05:00 | ✅ 1 | ✅ 16 | 17 |  |
| 04:00 | ✅ 1 | ✅ 16 | 17 |  |
| 03:00 | ✅ 1 | ✅ 16 | 17 |  |
| 02:00 | ✅ 1 | ✅ 16 | 17 |  |
| 01:00 | ✅ 1 | ✅ 16 | 17 |  |

## ⚙️ Paramètres
- Seuil STALE: **26h** · Fréquence: horaire `0 * * * *`
- Parser cron (sidecar): `5 * * * *` · Rétention logs: 72j
- Sources: `/source/docker/rsync_pull_node/logs/*.log` → `/dashboard/state.json`
- Généré par `rsync_dashboard.js` le 2026-10-08 08:05
