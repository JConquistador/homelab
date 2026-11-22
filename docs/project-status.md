# Project Status

## Current Phase

### 8.4 - Tailscale Integration

**Complete:**
- Deployed a dedicated private Caddy service with separate configuration and persistent volumes, connected to the required administrative Docker networks.
- Installed and enabled Tailscale on WSL Ubuntu.
- Authenticated the WSL host as `homelab-wsl` and verified connectivity with the mobile device over the tailnet.
- Enabled Tailscale HTTPS certificates and configured Tailscale Serve to forward tailnet HTTPS traffic to private Caddy.
- Established `homelab-wsl.tail4a5327.ts.net` as the private MagicDNS hostname.
- Validated remote access to private Caddy and Homepage from a mobile device over cellular data.
- Established Homepage as the root application of the private hostname.
- Configured private Caddy path-based routing and validated remote access to Prowlarr, Sonarr, Radarr, Lidarr, Bazarr, and SABnzbd.
- Configured qBittorrent access through private Caddy at `/qbittorrent/`, including reverse-proxy support and trusted proxy configuration.
- Added a permanent redirect from `/qbittorrent` to `/qbittorrent/` to ensure relative WebUI resources and authentication requests resolve correctly.
- Validated qBittorrent authentication, session handling, and remote WebUI access through Tailscale.
- Configured Uptime Kuma access through a separate Tailscale Serve HTTPS endpoint on port `8443`.
- Updated application URL Base settings and verified successful integration tests for Prowlarr connections to Sonarr, Radarr, and Lidarr.
- Updated Bazarr integrations with Sonarr and Radarr URL Bases.
- Updated Sonarr, Radarr, and Lidarr download-client configurations with the SABnzbd URL Base.
- Updated Seerr integrations with Sonarr and Radarr URL Bases.
- Validated the end-to-end media request and library workflow from Seerr through the *arr applications and into Jellyfin.
- Confirmed that Homepage configuration review is deferred until local Windows Tailscale access is established and direct administrative host-port publications are removed.

**Next:**
- Review any remaining administrative services and determine whether additional private Caddy routes or application configuration changes are required.
- Configure and verify Tailscale on the local Windows computer, accounting for the existing WSL Tailscale installation.
- Confirm Homepage and all administrative services work locally and remotely through MagicDNS.
- Remove direct host-port publications for administrative services together after Tailscale access is fully validated.
- Perform final access-control and security validation.
- Prepare migration documentation and scripts for the future Proxmox-hosted Ubuntu Server VM deployment.


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
