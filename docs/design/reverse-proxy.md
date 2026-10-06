# Reverse Proxy Architecture

## Purpose

This document defines the planned reverse proxy architecture for public access to the homelab's user-facing services.

The reverse proxy exists to provide a controlled boundary between the public Internet and internal Docker services.

---

# Design Goals

The reverse proxy should:

- Provide HTTPS access to public services.
- Hide internal Docker ports from users.
- Provide a single controlled entry point for public traffic.
- Simplify DNS and service addressing.
- Prevent administrative applications from being publicly exposed.
- Integrate with Cloudflare.
- Support future expansion without changing the underlying container architecture.

---

# Public Services

Only the following applications are intended to be publicly accessible:

- Seerr
- Jellyfin

The reverse proxy should expose these services using dedicated DNS names.

Conceptually:

```text
seerr.example.com
       |
       v
     Caddy
       |
       v
     Seerr
```

```text
jellyfin.example.com
       |
       v
     Caddy
       |
       v
   Jellyfin
```

The actual domain names will be documented when the production DNS configuration is implemented.

---

# Traffic Flow

The planned public traffic path is:

```text
User Device
     |
     v
Internet
     |
     v
Cloudflare
     |
     v
Caddy
     |
     +----> Seerr
     |
     +----> Jellyfin
```

Caddy is the internal reverse proxy and TLS termination point.

Cloudflare provides the external DNS and proxy layer.

---

# Internal Services

The following services should not be exposed through the public reverse proxy:

- Homepage
- Uptime Kuma
- Prowlarr
- Sonarr
- Radarr
- Lidarr
- Bazarr
- SABnzbd
- qBittorrent

These services are administrative or infrastructure components.

They should instead be accessed through Tailscale/private networking when remote administration is required.

---

# Docker Integration

Caddy will communicate with public services over Docker networking.

The preferred model is:

```text
Caddy
  |
  +---- Docker network ----> Seerr
  |
  +---- Docker network ----> Jellyfin
```

The reverse proxy should not require public host-port exposure for internal container-to-container communication.

---

# Security Boundary

Caddy represents the primary application-layer boundary between public traffic and the Docker environment.

The intended security model is:

```text
Internet
   |
Cloudflare
   |
Caddy
   |
Public Application
```

Administrative services remain outside this public path.

---

# User Experience

The reverse proxy should make the underlying infrastructure invisible to users.

Users should not need to know:

- Docker container names
- Host IP addresses
- Internal ports
- Docker network names
- Reverse proxy configuration
- Cloudflare configuration

They should only need the public service URLs.

---

# Administrative Access

Administrative applications will use Tailscale/private networking rather than the public reverse proxy.

This provides a clear separation:

```text
Public
  |
  +---- Seerr
  +---- Jellyfin


Private
  |
  +---- Homepage
  +---- Uptime Kuma
  +---- Sonarr
  +---- Radarr
  +---- Lidarr
  +---- Bazarr
  +---- Prowlarr
  +---- SABnzbd
  +---- qBittorrent
```

---

# Future Implementation

Reverse proxy implementation will be performed after the networking architecture has been documented and validated.

The implementation phase will include:

- Caddy deployment
- Docker network integration
- Cloudflare DNS configuration
- TLS configuration
- Seerr proxy configuration
- Jellyfin proxy configuration
- Public access testing
- Administrative access isolation
- Failure and restart testing

---

# Related Documentation

- `networking.md`
- `container-platform.md`
- `architecture.md`
- `decisions.md`
- `project-status.md`
