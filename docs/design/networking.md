# Networking Architecture

## Purpose

This document defines the network architecture for the homelab, including Docker network segmentation, service exposure, administrative access, and the planned production network topology.

The networking design prioritizes:

1. Security
2. Reliability
3. Simplicity
4. Maintainability
5. Isolation of services
6. Minimal exposure of administrative interfaces
7. Transparent operation for non-technical users

The network should allow users to interact with the media system without needing to understand or interact with the underlying infrastructure.

---

# Network Architecture

The homelab uses multiple layers of network isolation:

- Physical and host networking
- Docker bridge networks
- VPN-routed container networking
- Reverse proxy access
- Tailscale administrative access

The architecture separates public user-facing services from internal infrastructure and administrative services.

---

# Service Exposure Model

Only two applications are intended to be directly accessible by normal users:

- Seerr
- Jellyfin

These services provide the complete user-facing media workflow:

```text
Find media
    |
    v
Seerr
    |
    v
Request media
    |
    v
Automation / Download / Import
    |
    v
Jellyfin
    |
    v
Watch media
```

Users should not need direct access to:

- Sonarr
- Radarr
- Lidarr
- Bazarr
- Prowlarr
- SABnzbd
- qBittorrent
- Gluetun
- Homepage
- Uptime Kuma
- Docker
- Host administration

These services operate autonomously or are managed by an administrator through private administrative access.

---

# Public Services

The public-facing architecture is:

```text
Internet
   |
   v
Cloudflare
   |
   v
Caddy
   |
   +------> Seerr
   |
   +------> Jellyfin
```

Only Seerr and Jellyfin should be exposed through the public reverse-proxy path.

Users should interact with the services through DNS names rather than host ports.

The public URLs are intentionally the only infrastructure details that normal users need to know.

---

# Administrative Services

Administrative services should not be publicly exposed.

Administrative access will use Tailscale and/or the private network.

The intended model is:

```text
Administrator
     |
     v
Tailscale
     |
     v
Private Homelab Network
     |
     +----> Homepage
     +----> Uptime Kuma
     +----> Prowlarr
     +----> Sonarr
     +----> Radarr
     +----> Lidarr
     +----> Bazarr
     +----> SABnzbd
     +----> qBittorrent
     +----> Docker / Host Administration
```

This allows administrative interfaces to remain inaccessible from the public Internet.

---

# Docker Network Segmentation

Docker services are separated using dedicated networks.

Current networks include:

- `frontend`
- `homelab-media-network`
- `monitoring`
- `homelab-vpn-network`

The networks serve different purposes and should not be treated as interchangeable.

---

## Frontend Network

The `frontend` network is used by infrastructure services that provide user-facing or administrative web interfaces.

Currently:

- Homepage
- Uptime Kuma

The network is externally managed so that it can be shared between Compose projects when required.

The frontend network is not intended to provide public Internet exposure by itself.

---

## Media Network

The `homelab-media-network` is the primary internal network for the media stack.

Services connected to this network include:

- Seerr
- Jellyfin
- Prowlarr
- Sonarr
- Radarr
- Lidarr
- Bazarr
- SABnzbd
- Gluetun

The network allows media applications to communicate using Docker DNS and internal container ports.

Host port exposure is not required for container-to-container communication.

---

## Monitoring Network

The `monitoring` network is a host-level shared Docker bridge network.

It allows Uptime Kuma to monitor selected services belonging to other Compose projects without requiring additional public or host-level exposure.

Currently monitored media services include:

- Jellyfin
- Seerr
- Prowlarr
- Sonarr
- Radarr
- Lidarr
- Bazarr
- SABnzbd

The monitoring network is intentionally limited to services that require monitoring.

---

## VPN Network

The `homelab-vpn-network` is used by Gluetun.

qBittorrent uses Gluetun's network namespace:

```text
qBittorrent
    |
    v
network_mode: service:gluetun
    |
    v
Gluetun
    |
    v
VPN
```

qBittorrent therefore does not independently attach to the monitoring or media networks.

This prevents qBittorrent from bypassing the VPN namespace.

The VPN architecture has been previously validated and is accepted as part of the completed media stack deployment.

---

# Network Isolation Principles

Services should only be connected to networks required for their function.

The preferred model is:

```text
Service
   |
   +---- required application network
   |
   +---- optional monitoring network
```

Services should not be attached to networks solely for convenience.

In particular:

- Public services should not require administrative networks.
- Administrative services should not require public exposure.
- Monitoring access should use the dedicated monitoring network.
- VPN-routed services should remain within the VPN network architecture.

---

# Host Port Exposure

Host ports should only be exposed when there is a specific operational requirement.

Current development deployments expose application ports for local administration and testing.

In production, public access should instead follow:

```text
Internet
   |
Cloudflare
   |
Caddy
   |
Docker service
```

Administrative applications should be accessed through Tailscale/private networking rather than public host ports.

---

# User Experience

The networking architecture deliberately hides infrastructure complexity from normal users.

Users should only need to understand:

- Where to request media.
- Where to watch media.

The intended user experience is:

```text
Seerr
  |
  | Request
  v
Media automation
  |
  | Download / Import
  v
Jellyfin
  |
  | Watch
  v
User device
```

The underlying Docker networks, VPN, reverse proxy, Cloudflare configuration, download clients, and automation services should be invisible to the user.

This design supports a variety of clients including:

- Android TV
- Smartphones
- Tablets
- Web browsers
- Other supported Jellyfin clients

The validated Android TV workflow uses SeerrTV for requesting media and Jellyfin for playback.

---

# Security Model

The networking architecture follows a simple trust model.

### Public users

Users receive access only to:

- Seerr
- Jellyfin

### Administrators

Administrators receive additional private access through:

- Tailscale
- Private network access
- Host administration mechanisms

### Internal services

Containers communicate through dedicated Docker networks and service APIs.

No unnecessary service should be publicly reachable.

---

# Future Production Topology

The intended production topology is:

```text
                         Internet
                            |
                            v
                       Cloudflare
                            |
                            v
                          Caddy
                       /          \
                      /            \
                     v              v
                  Seerr          Jellyfin
                    |               |
                    +-------+-------+
                            |
                     Docker Networks
                            |
       +--------------------+--------------------+
       |                    |                    |
   Media Network       Monitoring Network    VPN Network
       |                    |                    |
   Arr Services         Uptime Kuma          Gluetun
   Prowlarr                                  |
   SABnzbd                                  qBittorrent
```

Administrative access is separate:

```text
Administrator
      |
      v
   Tailscale
      |
      v
Private Access
      |
      +---- Infrastructure
      +---- Docker
      +---- Media Administration
      +---- Monitoring
      +---- Host
```

---

# Design Principles

The networking architecture follows these principles:

- Only Seerr and Jellyfin are public user-facing services.
- Administrative services remain private.
- Docker networks provide service isolation.
- Tailscale provides remote administrative access.
- Caddy provides the public reverse-proxy boundary.
- Cloudflare provides the external DNS/proxy layer.
- VPN-routed services remain isolated from normal application networking.
- Users should not need knowledge of the underlying network architecture.
- Host port exposure should be minimized in production.
- Network access should follow least privilege.

---

# Related Documentation

- `architecture.md`
- `container-platform.md`
- `reverse-proxy.md`
- `storage-architecture.md`
- `decisions.md`
- `project-status.md`
