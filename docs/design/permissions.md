# Permissions Architecture

## Purpose

This document defines the filesystem and container permission model used by the homelab.

The goal is to provide predictable access between containers while minimizing unnecessary privileges.

---

# Design Goals

The permissions model should:

- Support hardlink-based media imports.
- Provide consistent ownership across media services.
- Avoid unnecessary root privileges.
- Remain compatible with Docker Compose.
- Minimize migration effort between Windows/WSL2 and Ubuntu Server.
- Simplify troubleshooting.
- Support future ZFS storage.

---

# Media Service Account

Media-related containers use a shared UID/GID.

The current development environment uses:

```text
PUID=1000
PGID=1000
```

The shared identity is used by services that need to read and modify media and download files.

This includes:

- qBittorrent
- SABnzbd
- Sonarr
- Radarr
- Lidarr
- Bazarr

Using a common identity avoids ownership conflicts between services.

---

# Shared Storage

Media acquisition and management services receive the shared:

```text
/data
```

mount.

This provides access to:

```text
/data/downloads
/data/media
```

The shared filesystem view is required for hardlink-based imports.

---

# Jellyfin

Jellyfin uses read-only media mounts.

Examples:

```text
/data/media/movies -> /movies:ro
/data/media/tv -> /tv:ro
/data/media/music -> /music:ro
/data/media/books -> /books:ro
```

Jellyfin does not receive write access to the media library.

This reduces the impact of application compromise or accidental modification.

---

# Configuration

Application configuration is normally stored in:

```text
appdata/<application>
```

and mounted as:

```text
/config
```

Configuration directories are owned and accessed according to the requirements of the individual container.

## Named Volume Exceptions

SABnzbd and Seerr currently use Docker-managed named volumes for configuration in the Windows/WSL2 development environment.

This was necessary because bind-mounted configuration directories produced filesystem compatibility problems in the development environment.

Current volumes:

```text
homelab-media_sabnzbd-config
homelab-media_seerr-config
```

These are development-environment exceptions.

After migration to Ubuntu Server, configuration is intended to move to:

```text
appdata/sabnzbd
appdata/seerr
```

This will restore the standard configuration mount strategy.

---

# Least Privilege

Containers should receive only the privileges required for their function.

Examples:

- Jellyfin receives read-only media access.
- Prowlarr does not require media storage access.
- Seerr does not require media storage access.
- Homepage does not require media storage access.
- Uptime Kuma does not require media storage access.
- Gluetun requires `NET_ADMIN` and access to `/dev/net/tun` because it provides the VPN network namespace.

The shared `/data` mount used by media acquisition and management services is an intentional exception.

---

# Docker Privileges

Containers should avoid running as root whenever practical.

Required capabilities should be explicitly documented when an application needs elevated privileges.

The current known exception is Gluetun, which requires:

```yaml
cap_add:
  - NET_ADMIN
```

and:

```text
/dev/net/tun
```

for VPN operation.

---

# Permission Validation

Permissions should be validated during major deployment phases.

Validation should include:

- Container startup.
- Read access.
- Write access where required.
- Hardlink creation.
- Media import.
- Jellyfin read-only behavior.
- Application configuration persistence.
- Container recreation.

Production validation will be repeated after migration to Ubuntu Server and ZFS.

---

# Future ZFS Considerations

The future ZFS layout must preserve the filesystem relationship between:

```text
/data/downloads
/data/media
```

Hardlinks cannot cross filesystem boundaries.

Therefore, the final ZFS dataset design must ensure that downloads and media remain within the same filesystem/dataset boundary if hardlink-based imports are to remain supported.

---

# Related Documentation

- `storage-architecture.md`
- `container-platform.md`
- `architecture.md`
- `decisions.md`
- `migration.md`
