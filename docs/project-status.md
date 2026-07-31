# Project Status

## Current Phase

**Phase 7 – Media Stack Deployment (Part 3 – Automation Services)**

The Download services have been successfully deployed.

Completed implementation:

- Gluetun deployed
- qBittorrent deployed
- SABnzbd deployed
- VPN routing validated
- Prowlarr deployed
- Usenet indexer configured
- Torrent trackers configured
- Sonarr deployed and partially configured
- Validate automated acquisition workflow (Sonarr → SABnzbd → Prowlarr)

The next implementation step is deploying Sonarr followed by the binding all the services into one fully automated workflow.

---

# Completed Phases

| Phase | Status |
| --- | --- |
| Phase 1 – Docker Installation | ✅ Complete |
| Phase 2 – Docker Compose Architecture | ✅ Complete |
| Phase 3 – Repository & Directory Structure | ✅ Complete |
| Phase 4 – Permissions Strategy | ✅ Complete |
| Phase 5 – Core Infrastructure Containers | ✅ Complete |
| Phase 6 – Media Architecture & Design | ✅ Complete |
| Phase 7 – Media Stack Deployment (Part 1 – VPN Foundation) | ✅ Complete |
| Phase 7 – Media Stack Deployment (Part 2 – Download Services) | ✅ Complete |

---

# Current Environment

Development:

* Windows 10
* Docker Desktop
* WSL 2
* Ubuntu

Future Production:

* Proxmox VE
* Ubuntu Server LTS VM
* ZFS storage

---

# Repository Status

Current state:

- Working tree clean.
- All changes committed.
- All changes pushed to GitHub.
- Documentation synchronized with implementation.
- Windows and WSL Git configurations aligned.
- Development environment verified under both PowerShell and WSL.

---

# Next Milestone

Continue deployment of the media stack.

Next implementation stages:

- Finish configuring Sonarr settings (Profiles, Quality Defaults, etc)
- Deploy and connect the rest of the automation layer (Radarr, Lidarr, Readarr, Bazarr).
- Validate indexer and download client integration.
- Validate automated imports and hardlink behavior.
- Deploy the media consumption layer (Jellyfin, Jellyseerr, Tautulli).

---

# Current Deployment

Infrastructure:

- Homepage
- Uptime Kuma

Media:

- Gluetun
- qBittorrent
- SABnzbd
- Prowlarr
- Sonarr

Pending:

- Radarr
- Lidarr
- Readarr
- Bazarr
- Jellyfin
- Jellyseerr
- Tautulli

---

# Reference Documentation

System overview:

* architecture.md

Storage design:

* design/storage-architecture.md

Architecture decisions:

* decisions.md
