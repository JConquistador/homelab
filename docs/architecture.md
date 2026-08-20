# Homelab Media Server Architecture

## Purpose

This repository documents the design, implementation, and operation of a self-hosted media server built with a strong emphasis on reliability, security, maintainability, and long-term expandability.

The project is intentionally developed using Infrastructure as Code principles wherever practical so that the complete environment can be recreated from version-controlled configuration.

---

# Project Goals

The primary design priorities are:

1. Reliability
2. Security
3. Ease of maintenance
4. Expandability
5. Performance
6. Low idle power consumption
7. Quiet operation

Every architectural decision should support one or more of these priorities.

---

# Current Project Status

The project is currently being developed in a temporary Windows 10 environment using Docker Desktop with the WSL 2 backend.

All configuration is written with Linux compatibility in mind so that migration to the future production server requires minimal changes.

Future production platform:

* Proxmox VE
* Ubuntu Server LTS virtual machine dedicated to Docker
* ZFS storage
* Intel Quick Sync hardware transcoding

---

# High-Level Architecture

```text
                        Internet
                            │
                     Cloudflare DNS
                            │
                        Cloudflare Proxy
                            │
                           Caddy
                    ┌────────┴────────┐
                    │                 │
             Public Services    Private Services
                    │                 │
                    │            Tailscale VPN
                    │                 │
                    └────────┬────────┘
                             │
                     Docker Compose
                             │
        ┌──────────────┬──────────────┬──────────────┐
        │              │              │              │
 Infrastructure     Media Stack     Monitoring     Future Services
        │
 Homepage • Uptime Kuma
        │
 Seerr → Sonarr/Radarr/Lidarr
        │
     Prowlarr
        │
 SABnzbd / qBittorrent (via Gluetun)
        │
     Media Library
        │
      Jellyfin
```

---

# Technology Stack

## Host Platform

* Proxmox VE
* Ubuntu Server LTS
* ZFS

## Container Platform

* Docker Engine
* Docker Compose

## Reverse Proxy

* Caddy

## DNS

* Cloudflare

## Remote Administration

* Tailscale

## Media Applications

* Jellyfin
* Seerr
* Sonarr
* Radarr
* Lidarr
* Bazarr
* Prowlarr
* SABnzbd
* qBittorrent
* Gluetun
* Tautulli

## Infrastructure

* Homepage
* Uptime Kuma

Optional future additions:

* Grafana
* Prometheus
* Chaptarr (a replacement for the deprecated Readarr currently in development)

---

# Design Principles

The homelab follows several guiding principles:

* Infrastructure should be reproducible.
* Configuration belongs in Git.
* Runtime data is stored separately from application definitions.
* Containers should avoid running as root whenever practical.
* Storage should support hardlinks for efficient media imports.
* Services should be isolated using Docker networking.
* Administrative access should be restricted to Tailscale.
* Public services should be exposed only through Caddy and Cloudflare.
* Backups and disaster recovery should be considered from the beginning rather than added later.

---

# Documentation

Detailed design documents are maintained separately.

Current documentation includes:

* `storage-architecture.md`
* `project-continuation-prompt.md`

Additional documents will be added as the project progresses.

---

# Repository Layout

```text
compose/
docs/
scripts/
templates/
```

Application runtime data is intentionally stored outside of the Git repository.

---

# Development Workflow

Each project phase follows the same workflow:

1. Design
2. Document
3. Implement
4. Validate
5. Commit
6. Push
7. Update documentation

This ensures the repository remains the authoritative source for both implementation and operational knowledge.

---

# Future Roadmap

The remaining major phases of the project include:

* Media stack deployment
* VPN networking
* Hardware transcoding
* Reverse proxy
* Cloudflare integration
* Tailscale configuration
* Monitoring
* Backup strategy
* Snapshots
* Disaster recovery
* Migration to the dedicated Proxmox server

Each phase will be documented as it is completed.
