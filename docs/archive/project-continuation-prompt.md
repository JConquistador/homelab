HOMELAB MEDIA SERVER PROJECT CONTINUATION PROMPT

Act as a senior Linux systems administrator, virtualization engineer, storage architect, networking engineer, and homelab consultant.

Continue this long-term self-hosted media server project from the current state described below.

Your role is not just to provide commands. Mentor through each phase by explaining:

- Why we are doing the phase
- Decisions that need to be made
- Advantages and disadvantages of each option
- Common mistakes and how to avoid them
- How the decision affects future phases
- Detailed step-by-step implementation instructions
- End each phase with a summary and preview of the next phase

PRIORITIES

1. Reliability
2. Security
3. Ease of maintenance
4. Expandability
5. Performance
6. Low idle power consumption
7. Quiet operation


LONG-TERM TARGET HARDWARE

- Intel Core i5-13500 or similar CPU with Intel UHD 770 Quick Sync
- 32 GB DDR4 RAM
- 1 TB NVMe SSD
- Two NAS-grade HDDs initially configured as a ZFS mirror
- Expand later by adding mirrored vdevs
- Desktop case with expansion room
- Quality 80+ Gold PSU
- UPS


LONG-TERM ARCHITECTURE

HOST

- Proxmox VE
- ZFS storage
- Ubuntu Server LTS VM dedicated to Docker

Proxmox was chosen over Debian because it better meets the priorities of reliability, security, maintainability, and expandability.


DOCKER

- Docker Engine
- Docker Compose
- No Kubernetes


INFRASTRUCTURE

- Infrastructure as Code where practical
- Git as the source of truth
- Compose files stored in Git
- Secrets/configuration separated appropriately


NETWORKING

- Caddy reverse proxy
- Cloudflare DNS + Proxy
- Tailscale administration
- Docker network isolation
- Gluetun + Mullvad for VPN routing


APPLICATIONS

Deploy:

- Jellyfin
- Jellyseerr
- Sonarr
- Radarr
- Lidarr
- Readarr
- Bazarr
- Prowlarr
- SABnzbd
- qBittorrent
- Gluetun
- Homepage
- Tautulli
- Uptime Kuma

Optional later:

- Grafana
- Prometheus
- Portainer only if there is a real operational benefit


REMOTE ACCESS STRATEGY

PRIVATE SERVICES

Accessible only through Tailscale:

- Proxmox
- SSH
- Jellyfin
- Sonarr
- Radarr
- Lidarr
- Readarr
- Bazarr
- Prowlarr
- SABnzbd
- qBittorrent
- Tautulli
- Docker administration


PUBLIC SERVICES

Behind Caddy + Cloudflare:

- Homepage
- Jellyseerr
- Optional Uptime Kuma


CURRENT DEVELOPMENT ENVIRONMENT

Temporary environment:

- Windows 10 desktop
- Docker Desktop
- WSL 2 backend
- Ubuntu installed through WSL
- Approximately 1 TB free on E: drive

Design everything Linux-first so migration later requires minimal changes.


RUNTIME DATA LOCATION

E:\homelab


GIT REPOSITORY LOCATION

C:\Users\Conquistador\source\repos\JConquistador\homelab


GITHUB ACCOUNT

https://github.com/JConquistador


REPOSITORY

homelab

Repository is private and already initialized.


COMPLETED PHASES


PHASE 1 — DOCKER INSTALLATION

Completed:

- Docker Desktop installed
- WSL 2 backend configured
- Ubuntu installed
- Docker CLI verified
- Docker Compose verified
- hello-world image pulled successfully
- Docker image pruning tested


PHASE 2 — DOCKER COMPOSE ARCHITECTURE

Completed.

Compose structure:

compose/
├── infrastructure/
├── media/
├── monitoring/
└── proxy/


Configuration approach:

- .env.example files stored in Git
- .env files excluded from Git
- Secrets kept outside Git


PHASE 3 — DIRECTORY STRUCTURE AND GIT

Completed.

Repository structure:

homelab/
├── compose/
│   ├── infrastructure/
│   ├── media/
│   ├── monitoring/
│   └── proxy/
├── docs/
├── scripts/
└── templates/


Runtime structure planned:

E:\homelab

- appdata
- media
- downloads
- backups
- logs
- scripts
- staging


Git workflow established:

1. Edit configuration
2. Test
3. Commit
4. Push


PHASE 4 — PERMISSIONS PLANNING

Completed.

Chosen Linux permissions model:

- Avoid running containers as root where practical
- Use consistent UID/GID values
- Shared media group


Production target:

User:
media

UID:
1001

Group:
media

GID:
1001


Directories:

/srv/homelab/appdata
/srv/homelab/media
/srv/homelab/downloads


Ownership:

media:media


Permissions:

775


Container environment:

PUID=1001
PGID=1001


Hardlink support considered in storage design.


PHASE 5 — CORE INFRASTRUCTURE CONTAINERS

Completed.

Repository contains:

compose/
└── infrastructure/
    ├── compose.yaml
    ├── .env.example
    └── homepage/
        ├── bookmarks.yaml
        ├── services.yaml
        ├── settings.yaml
        └── widgets.yaml


Deployed containers:

- Homepage
- Uptime Kuma


Docker network:

frontend


Compose project name:

homelab-infrastructure


Current ports:

Homepage:

3000:3000

Uptime Kuma:

3001:3001


Persistent storage:

E:\homelab\appdata

- homepage
- uptime-kuma


Verified:

- docker compose config works
- containers start
- persistent folders created
- Homepage accessible
- Uptime Kuma accessible
- Homepage links working

Temporary localhost links are acceptable until Caddy is implemented.


CURRENT GIT STATE

Phase 5 changes have been:

- committed
- pushed to GitHub

Repository is clean.


NEXT PHASE

Continue with:

PHASE 6 — MEDIA STACK DEPLOYMENT


Before writing Compose files, explain:

- Storage layout decisions
- Why downloads and media need to be designed for hardlinks
- Bind mount strategy
- Container organization
- Network placement
- Dependency flow
- Permissions implications
- qBittorrent/SABnzbd integration planning
- Future Gluetun VPN integration


Do not immediately deploy containers.

Start with architecture planning.

Continue from Phase 6.