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
HOMELAB_ROOT
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
| Seerr | Media request management |
| Tautulli | Jellyfin monitoring and statistics |

---

# Service Dependency Flow

The media stack follows this general workflow:

```text
Users
 |
 +----------------+
 |                |
Jellyfin      Seerr
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

Seerr provides a request interface, while Jellyfin remains the primary media consumption platform.

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

## VPN Network

Purpose:

The VPN network provides outbound VPN connectivity for download clients that require VPN protection.

**qBittorrent** uses Gluetun's network namespace and therefore routes its Internet traffic through the configured Mullvad VPN connection.

**SABnzbd does not use the VPN network.** SABnzbd operates on the normal `homelab-media-network` and connects directly to its configured Usenet providers. Usenet traffic is protected using the provider's TLS connection rather than the Mullvad VPN tunnel.

Media management services such as Prowlarr, Sonarr, Radarr, Lidarr, and Bazarr remain on the media network.

Example:

```text
                         Media Network

        +-----------+-----------+-----------+-----------+
        |           |           |           |           |
    Prowlarr     Sonarr      Radarr      Lidarr      Bazarr
        |           |           |           |           |
        |           +-----------+-----------+-----------+
        |                       |
        |                 Download Clients
        |                       |
        |                 +-----+-----+
        |                 |           |
        |             SABnzbd    qBittorrent
        |                 |           |
        |                 |       Gluetun
        |                 |           |
        |                 |      Mullvad VPN
        |                 |           |
        +-----------------+-----------+
                                  |
                               Internet
```

### qBittorrent

qBittorrent shares Gluetun's network namespace:

```yaml
network_mode: "service:gluetun"
```

As a result, qBittorrent's outbound network traffic is routed through Gluetun and the Mullvad VPN.

qBittorrent must not have direct Internet access outside the VPN tunnel.

### SABnzbd

SABnzbd is attached directly to:

```text
homelab-media-network
```

It does not use:

```yaml
network_mode: "service:gluetun"
```

and does not depend on Gluetun.

SABnzbd connects directly to its configured Usenet providers using their configured TLS ports.

SABnzbd is reachable by other media containers using Docker DNS:

```text
http://sabnzbd:8080
```

For host administration during development, SABnzbd's container port `8080` is published as host port `8081`:

```yaml
ports:
  - "8081:8080"
```

Therefore:

```text
Host:
http://localhost:8081

Docker media network:
http://sabnzbd:8080
```

SABnzbd's API key and hostname restrictions must permit requests from the media services. The configured `host_whitelist` includes the `sabnzbd` Docker hostname.

---

## VPN Gateway Port Exposure

Services that share Gluetun's network namespace cannot publish ports independently. Ports required by those services must be published by Gluetun.

This applies to qBittorrent.

Example:

```text
Gluetun
├── host port 8080
│   └── qBittorrent WebUI :8080
└── VPN network namespace
```

SABnzbd does **not** share Gluetun's network namespace and therefore does not use Gluetun for port exposure.

SABnzbd publishes its own WebUI port directly:

```text
SABnzbd
└── host port 8081 → container port 8080
```

This separation is intentional:

```text
qBittorrent
    │
    └── Gluetun network namespace
            │
            └── Mullvad VPN
                    │
                    └── Internet


SABnzbd
    │
    └── homelab-media-network
            │
            └── Direct Internet
                    │
                    └── Usenet provider via TLS
```

The media applications communicate with both download clients over the Docker media network using their service names and internal container ports.

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

Media acquisition and management containers receive the shared /data mount so that downloads and media exist within the same filesystem namespace and can use hardlinks. 

This is a deliberate exception to the principle of least privilege. These applications have access to storage outside their immediate functional directory, but this trade-off is accepted in order to support hardlink-based imports and avoid unnecessary file copying.

Host:

```text
E:\homelab
├── appdata
└── data
    ├── downloads
    └── media
```

Container paths:

```text
/config
/data
```

Example:

```text
/data
└── downloads
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
/data
└── media
    ├── movies
    ├── tv
    ├── music
    ├── music-videos
    └── books
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
├── seerr
└── tautulli
```

---

# Hardlink Strategy

Sonarr, Radarr, and Lidarr should use hardlinks when importing torrent downloads.

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
/data/downloads/qbittorrent/complete

Sonarr:
/data/downloads/qbittorrent/complete
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
- Seerr
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
/data
```

---

# Related Documentation

- `architecture.md`
- `storage-architecture.md`
- `container-platform.md`
- `decisions.md`