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
- Sonarr/Radarr/Lidarr/Bazarr deployed and configured
- Validate automated acquisition workflow (\*arr → Prowlarr → SABnzbd/qbittorrent → Completed Downloads → \*arr import → \homelab\media\<subfolder>)
- Jellyfin deployed and configured. Validated jellyfin can find/play media files managed by the automation services.
- Seerr deployed and configured. Validated Seerr can make requests to Radarr/Sonarr and media appears in the Jellyfin library.

The next implementation step is deploying Tautulli.

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

Phase 7 - Media Stack Deployment (Part 3 – Automation Services)
- Deploy Tautulli

Phase 7 - Media Stack Deployment (Part 4 – Operational Integration, UX, and Validation)
7.4A  Operational integration
      ├─ Homepage
      ├─ Uptime Kuma
      ├─ Tautulli integration
      └─ Monitoring/alerting baseline

7.4B  Indexer reliability
      ├─ Investigate Prowlarr Cloudflare failures
      ├─ 1337x
      ├─ Anidex
      ├─ Evaluate challenge-solving options if required
      └─ Validate from Prowlarr

7.4C  Jellyfin / Seerr UX integration (The goal should be one coherent user experience, not necessarily one application. Users should just be able to: Find something → Request it → Eventually watch it)
      ├─ Evaluate SeerrFin
      ├─ Evaluate Jellyfin Enhanced
      ├─ Evaluate Custom Tab approach
      ├─ Test supported Jellyfin clients
      ├─ Test user authentication/permissions
      └─ Select and document one approach

7.4D  Phase validation
      ├─ Functional testing
      ├─ Failure/restart testing
      ├─ Documentation
      ├─ Commit
      └─ Push

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
- Radarr
- Lidarr
- Bazarr
- Jellyfin
- Seerr

Pending:

- Tautulli

---

# Reference Documentation

System overview:

* architecture.md

Storage design:

* design/storage-architecture.md

Architecture decisions:

* decisions.md
