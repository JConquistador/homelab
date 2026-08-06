# Media Stack Architecture

## Purpose

This document describes the architecture and deployment strategy for the homelab media stack.

The media stack provides automated media acquisition, organization, management, playback, and monitoring.

The primary goals are:

1. Reliability
2. Security
3. Maintainability
4. Expandability
5. Simple migration
6. Efficient storage usage

---

# Compose Organization

The media stack is deployed as a dedicated Docker Compose project.

Location:

```text
compose/
└── media/
    ├── compose.yaml
    ├── .env
    └── .env.example
```

The media stack is intentionally separate from infrastructure services such as:

- Homepage
- Uptime Kuma
- Caddy
- Future monitoring services

This allows the media environment to be managed independently.

---

# Environment Configuration

The media Compose project uses environment variables to avoid hardcoding deployment-specific values.

Example:

```text
compose/
└── media/
    ├── compose.yaml
    ├── .env
    └── .env.example
```

`.env.example` is committed to Git and documents required configuration.

`.env` contains local deployment values and is excluded from Git.

Expected variables include:

```text
PUID
PGID
TZ
MEDIA_ROOT
CONFIG_ROOT
```

Sensitive values such as VPN credentials and API tokens are never stored in Git.

---

# Service Overview

## Media Management

These services automate media discovery and organization.

| Service | Purpose |
|---|---|
| Sonarr | Television series management |
| Radarr | Movie management |
| Lidarr | Music management |
| Bazarr | Subtitle management |
| Prowlarr | Indexer management |

Media libraries are organized by type rather than source or genre.

Anime content managed by Sonarr and Radarr is stored within the existing television and movie libraries rather than creating separate top-level storage locations.

---

## Download Services

These services retrieve content.

| Service | Purpose |
|---|---|
| qBittorrent | Torrent downloads |
| SABnzbd | Usenet downloads |
| Gluetun | VPN gateway for privacy-sensitive traffic |

---

## Media Consumption

| Service | Purpose |
|---|---|
| Jellyfin | Media server |
| Jellyseerr | Media request management |
| Tautulli | Jellyfin monitoring and statistics |

---

# Service Dependency Flow

The media stack follows this general workflow:

```text
Users
 |
 +----------------+
 |                |
Jellyfin      Jellyseerr
                  |
        Sonarr / Radarr / Lidarr
                  |
              Prowlarr
                  |
          Download Clients
                  |
        Completed Downloads
                  |
            Media Import
                  |
              Jellyfin
```

Jellyseerr provides a request interface, while Jellyfin remains the primary media consumption platform.

---

# Docker Networks

The media stack uses explicit Docker networks.

Networks may be defined as external networks when shared between Compose projects.

Examples:

- `frontend` may be shared with the proxy stack.
- `monitoring` may be shared with monitoring services.

Media-specific networks should remain owned by this Compose project.

## media Network

Purpose:

Internal communication between media automation applications.

Examples:

- Sonarr
- Radarr
- Lidarr
- Prowlarr
- qBittorrent
- SABnzbd

---

## vpn Network

Purpose:

The VPN network provides outbound VPN connectivity for download clients. qBittorrent and SABnzbd share Gluetun's network namespace using network_mode: service:gluetun. 
Media management services (Prowlarr, Sonarr, Radarr, etc.) remain on the media network.

Example:

```text
                    Media Network

        +-----------+-----------+
        |           |           |
    Prowlarr     Sonarr      Radarr
        |
        |
        +----------------+
                         |
                  Download Clients
                         |
              +----------+----------+
              |                     |
          SABnzbd             qBittorrent
              |                     |
              +----------+----------+
                         |
                      Gluetun
                         |
                    Mullvad VPN
```

qBittorrent and SABnzbd must not have direct internet access outside the VPN tunnel.

---

## VPN Gateway Port Exposure

Services sharing the Gluetun network namespace cannot publish ports independently.

Example:

qBittorrent:
  internal port 8080

SABnzbd:
  internal port 8081

Both ports must be published by the Gluetun container.

---

## Frontend Network

Purpose:

Communication with reverse proxies, dashboards, and user-facing services.

Examples:

- Jellyfin
- Jellyseerr

Jellyfin participates in the frontend network for user access.

Jellyfin accesses organized media files through a read-only media mount. It does not communicate directly with automation services such as Sonarr or Radarr.

Media access is provided through the host media library:

Development:

```text
E:\homelab\media
```

Production:

```text
/srv/homelab/media
```

The frontend layer consumes finalized media files only. Download directories and application configuration directories remain isolated from frontend services.

---

# Port Exposure Strategy

Services should not expose ports to the host unless direct host access is required.

Preferred communication:

```text
Container
    |
Docker Network
    |
Container
```

Avoid:

```text
Container
    |
Host Port
    |
Container
```

Host port exposure is reserved for:

- Temporary administration.
- Local testing.
- Services requiring browser access before reverse proxy deployment.

---

# Storage Layout

All media containers use consistent container paths.

## Shared Media Mounts

Media containers use consistent container paths while keeping downloads and media libraries separated at the host level.

Host:

```text
E:\homelab
├── downloads
├── media
└── appdata
```

Container paths:

```text
/downloads
/media
/config
```

Example:

```text
/downloads
├── qbittorrent
│   ├── incomplete
│   └── complete
│
└── sabnzbd
    ├── incomplete
    └── complete
```

Media libraries:

```text
/media
├── movies
├── tv
├── music
├── music-videos
├── books
├── audiobooks
└── photos
```

The host paths may change between development and production environments, but container paths remain consistent.

---

## Application Configuration

Each application receives its own configuration directory.

Host:

```text
E:\homelab
└── appdata
    └── <application>
```

Container:

```text
/config
```

Example:

```text
appdata/
├── gluetun
├── qbittorrent
├── sabnzbd
├── prowlarr
├── sonarr
├── radarr
├── lidarr
├── bazarr
├── jellyfin
├── jellyseerr
└── tautulli
```

---

# Hardlink Strategy

Sonarr and Radarr should use hardlinks when importing torrent downloads.

Requirements:

- Downloads and media must exist on the same filesystem.
- Containers must see identical download paths.
- Permissions must allow shared access.

Example:

Incorrect:

```text
qBittorrent:
/downloads

Sonarr:
/data/downloads
```

Correct:

```text
qBittorrent:
/downloads/qbittorrent/complete

Sonarr:
/downloads/qbittorrent/complete
```

The download client and media managers must see the same container path structure. This allows hardlinks to be created without remote path mappings.

---

# VPN Design

## qBittorrent

qBittorrent must route exclusively through Gluetun.

Required behavior:

- No direct internet access.
- VPN disconnect blocks traffic.
- VPN provider capabilities determine whether incoming peer connections are available.

---

## Gluetun

Gluetun provides:

- Mullvad VPN connection.
- Network gateway.
- Kill switch behavior.

Other applications should not share this network unless their traffic should also be VPN-routed.

---

## VPN Configuration Storage

Gluetun stores VPN-related runtime data separately from media configuration.

Example:

```text
appdata/
└── gluetun/
    └── servers/
```

This directory is managed by Gluetun and should be preserved during migrations.

---

# Permissions

All media containers use the same service identity.

Future Linux deployment:

```text
User:
media

UID:
1000

GID:
1000
```

This allows:

- shared ownership,
- hardlinks,
- predictable permissions,
- easier recovery.

---

# Deployment Order

Services will be deployed incrementally.

## Stage 1

Network foundation:

- Docker networks
- Environment files

## Stage 2

VPN and download layer:

- Gluetun
- qBittorrent
- SABnzbd

## Stage 3

Automation layer:

- Prowlarr
- Sonarr
- Radarr
- Lidarr
- Bazarr

## Stage 4

Consumption layer:

- Jellyfin
- Jellyseerr
- Tautulli

Each stage must be validated before continuing.

---

# Security Considerations

The media stack follows these principles:

- No unnecessary host port exposure.
- VPN-sensitive traffic is isolated.
- Containers receive only required storage access.
- Secrets are excluded from Git.
- Public access is handled through Caddy and Cloudflare.
- Administrative access uses Tailscale.

---

# Migration Considerations

The media stack is designed so that migration requires only host-level changes.

The following should remain unchanged:

- Container names.
- Container paths.
- Compose structure.
- Environment variable names.
- Application configuration locations.

The primary migration changes are:

- Host operating system.
- Storage backend.
- Host storage mount paths.
- Hardware acceleration configuration.

The following container paths should remain unchanged:

```text
/config
/downloads
/media
```

---

# Related Documentation

- `architecture.md`
- `storage-architecture.md`
- `container-platform.md`
- `decisions.md`