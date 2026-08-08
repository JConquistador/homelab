# Container Platform

## Purpose

This document defines the standards used for container deployment throughout the homelab.

These standards are intended to provide consistency, simplify troubleshooting, improve security, and minimize migration effort between development and production environments.

---

# Design Goals

The container platform should:

* Maintain consistent required paths.
* Minimize container privileges.
* Separate configuration from application data.
* Support Infrastructure as Code.
* Simplify migration between Windows and Linux.
* Support future expansion with minimal changes.

---

# Compose Organization

Containers are grouped by functional area.

```text
compose/
├── infrastructure/
│   └── compose.yaml
├── media/
│   └── compose.yaml
├── monitoring/
│   └── compose.yaml
└── proxy/
    └── compose.yaml
```

Each Compose project is independently deployable while remaining part of the overall homelab.

This allows services to be updated, restarted, or migrated independently.

---

# Filesystem Layout

Media-related containers receive consistent bind mounts for the storage required by their role.

Development:

```text
E:\homelab
```

Production:

```text
/srv/homelab
```

The host-side path changes between environments, but the container-side paths remain consistent.

Media-related containers use:

```text
/data
```

Application configuration is mounted individually:

```text
/config
```

This results in consistent container paths regardless of the host operating system.

The `/data` mount contains:

```text
/data/
├── downloads/
└── media/
```

Applications access the specific subdirectories required for their function.


---

# Configuration Storage

Each container stores persistent configuration beneath:

```text
appdata/<application>
```

Examples include:

* Jellyfin
* Sonarr
* Radarr
* qBittorrent
* Homepage
* Uptime Kuma

Configuration directories are backed up independently of application containers.

---

# Environment Variables

Common settings are stored in `.env`.

Sensitive values are excluded from Git.

A corresponding `.env.example` file is maintained within the repository.

The goal is to make a fresh deployment possible with minimal manual configuration.

---

# Networking

Containers are connected only to the networks required for their function.

Examples include:

* frontend
* media
* proxy
* monitoring

Network access should follow the principle of least privilege.

Containers should communicate through Docker networks whenever possible rather than exposing unnecessary host ports.

Future networking documentation will define these networks in detail.

---

# Restart Policy

Long-running services should restart automatically after:

* Host reboot
* Docker restart
* Unexpected container failure

Restart policies should avoid unnecessary restarts for intentionally stopped containers.

---

# Naming Conventions

Container names should remain:

* short
* descriptive
* consistent

Examples:

* jellyfin
* sonarr
* radarr
* qbittorrent
* gluetun

Compose project names identify logical groups rather than individual applications.

---

# Security Principles

The container platform follows several guiding principles.

* Prefer non-root containers whenever practical.
* Mount only the directories required by each application.
* Avoid unnecessary privilege escalation.
* Separate configuration from runtime data.
* Restrict public exposure through reverse proxies.
* Prefer internal Docker networking over host networking.

---

# Storage Mount Strategy

## Media Storage Mounts

Media acquisition and management services use a shared `/data` mount.

The shared mount provides a consistent filesystem view of downloads and media libraries across download clients and media management applications. This is required to support hardlink-based imports.

Download clients:

* qBittorrent
* SABnzbd

receive:

```text
/data
```

Media management:

* Sonarr
* Radarr
* Lidarr
* Bazarr

receive:

```text
/data
```

This allows both groups of services to access the same relative paths:

```text
/data/downloads
/data/media
```

and ensures that downloads and media remain on the same filesystem from the containers' perspective.

Jellyfin receives read-only access to the individual finalized media libraries:

```text
/data/media/movies
/data/media/tv
/data/media/music
/data/media/music-videos
/data/media/books
```

Jellyfin does not require access to `/data/downloads`.

---

## Least Privilege

Containers receive only the filesystem access required for their function.

The shared `/data` mount represents a deliberate exception to strict least privilege for download clients and media management applications. This is necessary to provide a consistent filesystem view and enable hardlinks between downloads and media libraries.

### Containers Requiring `/data`

Download clients:

* qBittorrent
* SABnzbd

require:

```text
/data
```

Media management:

* Sonarr
* Radarr
* Lidarr
* Bazarr

require:

```text
/data
```

These services require access to both:

```text
/data/downloads
/data/media
```

so that completed downloads can be imported into the appropriate media library while preserving hardlinks.

### Containers Requiring Read-Only Media Access

Media consumption:

* Jellyfin

requires read-only access to the finalized media libraries:

```text
/data/media/movies
/data/media/tv
/data/media/music
/data/media/music-videos
/data/media/books
```

Jellyfin does not receive access to the downloads directory.

---

## Containers Without Media Storage

These containers do not require direct filesystem access:

* Prowlarr
* Homepage
* Uptime Kuma
* Caddy
* Gluetun
* Jellyseerr

These services communicate through APIs, web interfaces, or networking rather than directly accessing media files.

---

## Configuration Mounts

Application configuration is exposed to containers through the `/config` mount.

Example:

Host:

```text
appdata/<application>
```

Container:

```text
/config
```

This keeps application state isolated from shared media storage and allows configuration to be backed up independently.

SABnzbd is currently an exception during the Windows/WSL2 development environment because its configuration is stored in a Docker-managed named volume due to filesystem permission limitations. This will be migrated to `appdata/sabnzbd` after migration to Ubuntu Server.

---

# Development and Production

The Windows development environment intentionally mirrors the future Ubuntu Server deployment.

Only the host-side bind mount changes during migration.

Container configuration should remain unchanged.

---

# Related Documentation

* `architecture.md`
* `storage-architecture.md`
* `permissions.md` (future)
* `networking.md` (future)