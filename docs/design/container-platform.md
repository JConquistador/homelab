# Container Platform

## Purpose

This document defines the standards used for container deployment throughout the homelab.

These standards are intended to provide consistency, simplify troubleshooting, improve security, and minimize migration effort between development and production environments.

---

# Design Goals

The container platform should:

* Maintain consistent filesystem paths.
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

Media-related containers receive a shared bind mount.

```text
Host
↓

Homelab Root

↓

/data
```

Application configuration is mounted individually.

```text
/config
```

This results in identical container paths regardless of the host operating system.

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

## Shared Data Mount

Media-related containers use a shared `/data` mount.

This provides consistent filesystem paths across all applications and enables hardlink-based imports.

The host path changes between environments.

Development:

```text
E:\homelab
```

Production:

```text
/srv/homelab
```

Container path:

```text
/data
```

---

## Least Privilege

Containers receive only the filesystem access required for their function.

### Containers Requiring `/data`

These containers interact directly with media files:

- Jellyfin
- Sonarr
- Radarr
- Lidarr
- Readarr
- Bazarr
- qBittorrent
- SABnzbd

These services require access to download locations and/or the media library.

---

### Containers Without `/data`

These containers do not require direct filesystem access:

- Homepage
- Uptime Kuma
- Caddy
- Gluetun
- Jellyseerr

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