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

---

## ADR-007

### Decision

Treat the Git repository as the authoritative source of truth.

### Status

Accepted

### Rationale

Version-controlled documentation and configuration improve reproducibility, disaster recovery, and long-term maintainability.

---

## ADR-008

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

## ADR-009

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

## ADR-010

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

## ADR-011

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

## ADR-012

### Status

Accepted

### Date

2026-07-28

### Context

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

### Decision

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

### Rationale

Mullvad was selected because:

- Reliability and simplicity are prioritized over maximum torrent optimization.
- There is currently no private tracker usage.
- Port forwarding is not currently a requirement.
- WireGuard performance is excellent.
- Gluetun integration is mature.
- The configuration is simple to maintain.

### Alternatives Considered

#### Proton VPN

Advantages:

- Supports port forwarding.
- Strong privacy reputation.
- Good WireGuard support.

Rejected for now because:

- Port forwarding is not currently required.
- Additional configuration complexity provides limited benefit for current requirements.

#### AirVPN

Advantages:

- Strong torrent-focused feature set.
- Port forwarding support.
- Advanced configuration options.

Rejected for now because:

- Greater configuration complexity.
- Advanced features are not currently required.

### Consequences

#### Positive

- Simple VPN architecture.
- Strong traffic isolation.
- Minimal ongoing maintenance.
- Easy future provider replacement.

#### Negative

- No inbound torrent port forwarding.
- Potentially reduced torrent seeding efficiency.

Future migration to another VPN provider should only require environment and Gluetun configuration changes.

---

## ADR-013

### Decision

Do not include Readarr in the media stack as the project has been discontinued.

### Status

Accepted

### Rationale

Readarr has been retired upstream and is no longer under active development. The homelab will not adopt retired software as a core component. Book and audiobook automation is deferred until a mature, actively maintained replacement demonstrates long-term stability and community adoption.

---

## ADR-014

### Decision

Store the downloads and media directories under a shared data directory beneath the homelab root.

The shared directory is exposed to media management applications through a common /data container mount.

### Status

Accepted

### Rationale

The Arr applications were previously given separate container mounts for the downloads and media directories. This caused the applications to treat the paths as separate filesystem locations, preventing hardlinks between completed downloads and the media library.

As a result, imports were performed as file copies rather than hardlinks, causing unnecessarily high disk I/O and significantly increasing import times for large media files.

The shared /data mount provides the download and media directories within the same filesystem view, allowing hardlinks to be created during imports.

### Consequences

Positive:

- Hardlink-based imports are enabled.
- Media imports are near instantaneous compared with copy-based imports.
- Disk space usage is reduced because downloaded files and imported media can reference the same underlying data.
- Torrent files can continue seeding without requiring a second physical copy.
- The container path structure is consistent across development and production environments.

Negative:

- This introduces a limited exception to the principle of least privilege.
- Media management applications that require hardlink-based imports must have access to the shared /data filesystem rather than only their individual media library.
- The shared filesystem boundary must be preserved when designing the future ZFS dataset layout.

---

## ADR-015 – Supplemental Indexer Reliability and Cloudflare Protection

### Status

Accepted

### Date

2026-08-25

### Context

During Phase 7.4B, additional torrent indexers were evaluated for use with
Prowlarr.

The primary candidates were:

* 1337x
* Anidex

Prowlarr was unable to successfully test these indexers because their
websites employ automated traffic protection.

Testing directly from the media Docker network confirmed that the
protection is not limited to Prowlarr configuration.

The existing Prowlarr deployment already has multiple functional torrent
and Usenet indexers. The additional indexers therefore provide
supplementary rather than essential functionality.

### Decision

Do not introduce challenge-solving infrastructure or other specialized
bypass mechanisms solely to support 1337x or Anidex at this time.

The existing indexer configuration will remain the primary source of
indexer functionality.

1337x and Anidex may be reconsidered in the future if:

* their protection requirements change;
* Prowlarr gains reliable native support for their protection mechanisms;
* a stable, well-maintained integration becomes available; or
* the additional indexer functionality becomes sufficiently valuable to 
  justify the operational complexity.

No current production dependency will be placed on either indexer.

### Rationale

The purpose of Phase 7.4B is to improve indexer reliability, not to add
fragile infrastructure.

Because the current Prowlarr deployment already has functional indexers,
the operational cost and reliability risk outweigh the benefit of adding
these supplementary sources.

This decision also follows the project's general principle of keeping the
media stack as simple and reliable as practical.

### Consequences

#### Positive

* No additional challenge-solving infrastructure is required.
* The media stack remains simpler.
* Prowlarr remains dependent primarily on stable indexer integrations.
* No additional service needs to be maintained or monitored.
* Existing functional indexers remain unaffected.

#### Negative

* 1337x will not be available through the current Prowlarr deployment.
* Anidex will not be available through the current Prowlarr deployment.
* Some searches may have fewer supplementary results.

### Alternatives Considered

#### Use alternate 1337x domains

The available 1337x domains were tested conceptually as alternatives to
the primary `.to` domain.

Because the protection mechanism is applied at the website/network level,
switching domains does not provide sufficient evidence of a stable
integration.

No alternate domain will be adopted solely to bypass the protection.

#### Add challenge-solving infrastructure

A dedicated challenge-solving solution could potentially allow protected
indexers to be accessed.

This was rejected because the operational complexity is not justified by
the relatively small benefit provided by these supplementary indexers.