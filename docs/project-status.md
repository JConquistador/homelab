# Project Status

## Current Phase

### 8.4 - Tailscale Integration

- Acquired `auroradorhq.com` through Cloudflare Registrar.
- Created DNS records:
  - `request.auroradorhq.com` → Seerr (Cloudflare proxied)
  - `watch.auroradorhq.com` → Jellyfin (DNS only)
- Configured Cloudflare API tokens with zone-scoped permissions:
  - Dynamic DNS updater
  - Caddy DNS-01 certificate validation
- Deployed `favonia/cloudflare-ddns` for automatic public IPv4 updates.
- Built a custom Caddy image with the Cloudflare DNS provider module.
- Configured Caddy to obtain Let's Encrypt certificates using DNS-01.
- Validated HTTPS access to both applications from the local network and external mobile data.

Next:

- Domain Acquisition 
  - Done: auroradorhq.com through Cloudflare
    Nameservers: hazel.ns.cloudflare.com, marek.ns.cloudflare.com
	Planned public hostnames: request and watch
- Configure Cloudflare DNS
- Configure Cloudflare proxying
- Validate DNS/TLS
- Validate external access
- Validate origin exposure and security

- Deploy/configure Tailscale
- Define private service access
- Restrict administrative services to Tailscale
- Validate remote administrative access
- Validate access from supported client devices

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
| Phase 7.1 – Media Stack Deployment (VPN Foundation) | ✅ Complete |
| Phase 7.2 – Media Stack Deployment (Download Services) | ✅ Complete |
| Phase 7.3 – Media Stack Deployment (Automation Services) | ✅ Complete |
| Phase 7.4 – Media Stack Deployment (Personalization and Validation) | ✅ Complete |
| Phase 8.1 – Secure Access & Reverse Proxy (Architecture & Design) | ✅ Complete |
| Phase 8.2 – Secure Access & Reverse Proxy (Caddy Implementation) | ✅ Complete |
| Phase 8.3 – Secure Access & Reverse Proxy (Cloudflare Integration) | ✅ Complete |

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

# Next Milestones

## Phase 8 – Secure Access & Reverse Proxy (Completed)

### 8.1 - Architecture & Design

- Review current Docker network architecture
- Define public vs. private services
- Define Caddy reverse proxy architecture
- Define Cloudflare DNS/proxy requirements
- Define Tailscale access architecture
- Define TLS/certificate strategy
- Define authentication and access-control requirements
- Document required network changes
- Record significant architectural decisions

### 8.2 - Caddy Implementation

- Deploy Caddy
- Configure Docker networking
- Configure reverse proxy routes
- Configure TLS
- Validate internal service access
- Validate public service access where applicable

### 8.3 - Cloudflare Integration

- Domain Acquisition
- Configure Cloudflare DNS
- Configure Cloudflare proxying
- Validate DNS/TLS
- Validate external access
- Validate origin exposure and security

## Phase 8 – Secure Access & Reverse Proxy (Next implementation stages)

### 8.4 - Tailscale Integration

- Deploy/configure Tailscale
- Define private service access
- Restrict administrative services to Tailscale
- Validate remote administrative access
- Validate access from supported client devices

### 8.5 - Access Layer Validation

- Functional testing
- Authentication testing
- Failure/restart testing
- Network isolation testing
- TLS/certificate validation
- Public/private access validation
- Documentation
- Commit
- Push

### Future Phases

- Hardware transcoding / Intel Quick Sync
- Backup strategy
- ZFS snapshots
- Disaster recovery
- Migration scripts from the Windows/WSL development environment
- Production Proxmox deployment
- Production hardlink and storage validation

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

---

# Reference Documentation

System overview:

* architecture.md

Storage design:

* design/storage-architecture.md

Architecture decisions:

* decisions.md
