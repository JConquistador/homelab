# Architecture Decision Record (ADR)

## Purpose

This document records significant architectural decisions made during the design and implementation of the homelab.

Each decision includes the rationale so future changes can be made with full context.

---

## ADR-001

### Decision

Use Proxmox VE as the long-term host operating system.

### Status

Accepted

### Rationale

Proxmox provides virtualization, snapshots, flexible storage management, and simplified disaster recovery while aligning with the project's priorities of reliability, security, maintainability, and expandability.

---

## ADR-002

### Decision

Run Docker inside a dedicated Ubuntu Server LTS virtual machine.

### Status

Accepted

### Rationale

Separating the hypervisor from application workloads simplifies maintenance, improves isolation, and makes future migrations easier.

---

## ADR-003

### Decision

Use Docker Compose instead of Kubernetes.

### Status

Accepted

### Rationale

Docker Compose provides the required functionality with significantly lower operational complexity while remaining easy to maintain.

---

## ADR-004

### Decision

Store all runtime data beneath a single homelab root directory.

### Status

Accepted

### Rationale

A single root directory simplifies backups, migration, documentation, and future storage expansion.

---

## ADR-005

### Decision

Keep downloads and media on the same filesystem.

### Status

Accepted

### Rationale

This enables hardlinks, avoids duplicate storage consumption, and supports efficient torrent seeding.

---

## ADR-006

### Decision

Organize download directories by application (`qbittorrent` and `sabnzbd`).

### Status

Accepted

### Rationale

Application-specific directories make ownership and troubleshooting clearer while preserving hardlink compatibility.

---

## ADR-007

### Decision

Store anime within the standard `tv` and `movies` libraries.

### Status

Accepted

### Rationale

Anime is managed by Sonarr and Radarr like any other television series or movie. Keeping a single TV library and a single movie library reduces complexity and simplifies long-term maintenance.

---

## ADR-008

### Decision

Treat the Git repository as the authoritative source of truth.

### Status

Accepted

### Rationale

Version-controlled documentation and configuration improve reproducibility, disaster recovery, and long-term maintainability.

---

## ADR-009

### Decision

Use a dedicated media Compose project containing all media-related services.

### Status

Accepted

### Rationale

The media services form a tightly coupled application ecosystem:

- Indexers provide content sources.
- Media managers automate acquisition and organization.
- Download clients retrieve content.
- Jellyfin consumes the organized library.

Keeping these services together simplifies deployment, troubleshooting, upgrades, and disaster recovery.

Separate Compose projects would provide additional modularity but would increase network management and operational complexity without significant benefit for this environment.

---

## ADR-010

### Decision

Use dedicated Docker networks instead of relying on the default bridge network.

### Status

Accepted

### Rationale

Explicit Docker networks provide better isolation, clearer service relationships, and improved security.

Services should communicate through named Docker networks rather than relying on exposed host ports wherever possible.

The planned network separation includes:

- Media services
- Frontend services
- Proxy services
- Monitoring services
- VPN-routed services

---

## ADR-011

### Decision

Use a shared `/data` mount for media-related containers.

### Status

Accepted

### Rationale

All media management applications require a consistent filesystem view to support hardlinks, simplify configuration, and avoid remote path mappings.

The container path remains `/data` regardless of the underlying host operating system.

Development environment:

```text
E:\homelab
```

Production environment:

```text
/srv/homelab
```

---

## ADR-012

### Decision

Use a dedicated media service account for container file ownership.

### Status

Accepted

### Rationale

A shared UID/GID simplifies permissions between media containers while maintaining predictable ownership.

This approach improves compatibility between:

- qBittorrent
- SABnzbd
- Sonarr
- Radarr
- Lidarr
- Readarr
- Bazarr

Separate users per application would provide stronger isolation but would significantly complicate permissions and hardlink compatibility.

---

## ADR-013

### Decision

Store container configuration separately from media storage.

### Status

Accepted

### Rationale

Application configuration and media data have different backup, recovery, and lifecycle requirements.

Separating configuration into application-specific directories allows:

- easier backups,
- easier migration,
- simpler container replacement,
- reduced risk of accidental media changes.

---

## ADR-014

### Decision

Use environment files for configuration templates while keeping secrets out of Git.

### Status

Accepted

### Rationale

Infrastructure configuration should be version controlled, but sensitive information should not be committed.

The project will maintain:

- `.env.example` files containing required variables.
- Local `.env` files excluded from Git.
- Separate secret handling where required.

---

# ADR-015

## Status

Accepted

## Date

2026-07-28

## Context

The media stack requires a VPN gateway for privacy-sensitive download services.

The VPN solution must:

- Integrate with Docker Compose.
- Support Gluetun.
- Provide WireGuard connectivity.
- Prevent download services from bypassing the VPN tunnel.
- Minimize operational complexity.

Potential providers considered:

- Mullvad VPN
- Proton VPN
- AirVPN

## Decision

The homelab will use Mullvad VPN with WireGuard through Gluetun.

The qBittorrent networking architecture will be:

    qBittorrent
          |
          |
    network_mode: service:gluetun
          |
          |
       Gluetun
          |
          |
    Mullvad WireGuard

This ensures torrent traffic cannot bypass the VPN tunnel.

## Rationale

Mullvad was selected because:

- Reliability and simplicity are prioritized over maximum torrent optimization.
- There is currently no private tracker usage.
- Port forwarding is not currently a requirement.
- WireGuard performance is excellent.
- Gluetun integration is mature.
- The configuration is simple to maintain.

## Alternatives Considered

### Proton VPN

Advantages:

- Supports port forwarding.
- Strong privacy reputation.
- Good WireGuard support.

Rejected for now because:

- Port forwarding is not currently required.
- Additional configuration complexity provides limited benefit for current requirements.

### AirVPN

Advantages:

- Strong torrent-focused feature set.
- Port forwarding support.
- Advanced configuration options.

Rejected for now because:

- Greater configuration complexity.
- Advanced features are not currently required.

## Consequences

### Positive

- Simple VPN architecture.
- Strong traffic isolation.
- Minimal ongoing maintenance.
- Easy future provider replacement.

### Negative

- No inbound torrent port forwarding.
- Potentially reduced torrent seeding efficiency.

Future migration to another VPN provider should only require environment and Gluetun configuration changes.

## ADR-016

### Status

Accepted

### Date

2026-07-28

### Context

The first production media services have now been deployed using the architecture defined in the design documentation.

This milestone validates:

- Dedicated media Compose project.
- Dedicated Docker networks.
- Gluetun VPN gateway.
- qBittorrent and SABnzbd using `network_mode: service:gluetun`.
- Shared `/data` storage strategy.
- Environment variable configuration through `.env`.
- Git exclusion of deployment-specific secrets.

### Decision

The project will use Gluetun as the shared VPN gateway for torrent download services.

Applications requiring VPN protection will join the Gluetun network namespace using:

```yaml
network_mode: service:gluetun
```

This architecture prevents protected services from communicating directly with the Docker bridge network or the host network.

### Rationale

Using a shared network namespace provides:

- Automatic kill-switch behavior through Gluetun.
- No additional firewall rules within application containers.
- Simplified networking.
- Consistent outbound routing through WireGuard.

Verification confirmed that outbound traffic from qBittorrent exits through the Mullvad VPN endpoint rather than the host's public IP address.

### Consequences

#### Positive

- Torrent traffic cannot bypass the VPN tunnel.
- The networking model is simple and reproducible.
- Additional VPN-protected services can be added with minimal configuration.

#### Negative

- Services sharing the Gluetun namespace cannot expose ports independently.
- All exposed ports must be published by the Gluetun container.

## ADR-017

# VPN Routing Scope for Media Services

## Status

Accepted

## Date

2026-07-29

## Context

The media stack requires VPN protection for services that communicate directly with external download sources.

Potential candidates include:

- qBittorrent
- SABnzbd
- Sonarr
- Radarr
- Prowlarr
- Jellyfin

Routing every media service through the VPN would increase complexity and potentially complicate service communication.

## Decision

Only download clients and services that directly communicate with external download infrastructure will use the VPN gateway.

VPN-routed services:

- qBittorrent
- SABnzbd

Non-VPN services:

- Prowlarr
- Sonarr
- Radarr
- Lidarr
- Readarr
- Bazarr
- Jellyfin
- Jellyseerr

## Rationale

The VPN provides privacy benefits primarily for download traffic.

Automation services do not require VPN routing and benefit from normal network connectivity for:

- service communication,
- API integrations,
- local management,
- troubleshooting.

Keeping automation services outside the VPN simplifies networking while maintaining privacy where it matters.

## Consequences

Positive:

- Simpler Docker networking.
- Easier service discovery.
- Fewer routing issues.
- Reduced VPN dependency.

Negative:

- Automation services communicate over the normal network path.
- Future changes may require revisiting service boundaries.