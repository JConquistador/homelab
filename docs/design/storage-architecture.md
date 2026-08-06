# Storage Architecture

## Purpose

This document describes the storage architecture for the homelab media server and the reasoning behind the major storage design decisions.

The storage design prioritizes:

1. Reliability
2. Security
3. Ease of maintenance
4. Expandability
5. Performance
6. Efficient disk usage
7. Simple migration from the development environment to the future production server

The temporary Windows development environment intentionally mirrors the future Linux deployment so that migration requires minimal changes.

---

# Environment Paths

## Development Environment

```text
E:\homelab
```

## Future Production Environment

```text
/srv/homelab
```

Only the host storage path should change during migration. The internal directory structure and container paths should remain consistent.

---

# Directory Layout

```text
homelab/
├── appdata/
├── backups/
├── downloads/
│   ├── qbittorrent/
│   │   ├── complete/
│   │   └── incomplete/
│   └── sabnzbd/
│       ├── complete/
│       └── incomplete/
├── logs/
├── media/
│   ├── books/
│   ├── movies/
│   ├── music/
│   ├── music-videos/
│   └── tv/
├── scripts/
└── staging/
```

---

# Directory Purposes

## appdata

Contains persistent application configuration and state. 

Examples:

* Jellyfin database
* Sonarr configuration
* Radarr configuration
* qBittorrent configuration
* Homepage configuration
* Uptime Kuma database

This directory is critical and should be included in backups.

Development Note: SABnzbd configuration is stored in a Docker named volume due to Windows filesystem permission limitations. This will be migrated to appdata/sabnzbd after moving to Ubuntu Server.

---

## media

Contains the permanent media library consumed by Jellyfin.

Media is organized by type rather than genre.

Examples:

* Movies
* Television series
* Music
* Books
* Music videos

Anime remains within the standard `tv` and `movies` libraries because it is managed by Sonarr and Radarr like other media types. Separate anime libraries would add complexity without providing significant operational benefit.

---

## downloads

Contains active and completed downloads.

Downloads are separated by application:

* qBittorrent
* SABnzbd

Each application maintains:

* `complete/`
* `incomplete/`

Torrent downloads may remain in `complete/` while seeding.

Usenet downloads are generally removed after successful import.

---

## backups

Contains exported configuration, database backups, and backup metadata.

Examples:

* Application database exports
* Configuration archives
* Backup manifests

---

## logs

Reserved for optional centralized logging.

Not all applications will use this directory.

---

## scripts

Contains administrative automation.

Examples:

* Backup scripts
* Maintenance scripts
* Update helpers

---

## staging

Temporary working space for:

* Large file transfers
* Maintenance operations
* Migration activities

This directory does not contain permanent data.

---

# Hardlink Strategy

The media server is designed to use hardlinks whenever possible.

Hardlinks allow media management applications (Sonarr, Radarr, and Lidarr) to import completed downloads without creating duplicate copies of the media files.

Benefits:

* Reduced disk usage
* Faster imports
* Continued torrent seeding
* Reduced disk activity

Hardlinks require:

* Downloads and media to exist on the same filesystem.
* Consistent paths between downloader and media management containers.
* Correct filesystem permissions.

The storage layout and container mount strategy are designed specifically to support these requirements.

Development Note: Hardlink behavior cannot be fully validated in the Windows/WSL2 development environment because Docker bind mounts traverse the Windows NTFS filesystem layer. Production validation will occur after migration to Ubuntu Server with ZFS storage.

---

# Container Mount Strategy

## Design Goal

Media-related containers use consistent container paths for the storage they require regardless of the host operating system.

The host path is abstracted behind a consistent container mount.

Host:

```text
E:\homelab
```

or:

```text
/srv/homelab
```

Container paths may include:

```text
/config
/downloads
/movies
/tv
/music
/books
```

Additional administrative paths such as:

```
/backups
/logs
/scripts
/staging
```

are only mounted where required.

This ensures the same application configuration works across:

* Windows development environment
* WSL 2
* Ubuntu Server
* Future Proxmox deployment

---

## Standard Mount Layout

Media-related containers receive:

```text
Host

homelab/media/movies
homelab/media/tv
homelab/media/music
homelab/media/music-videos
homelab/media/books

↓

Container

/movies
/tv
/music
/music-videos
/books
```

Application configuration is separated:

```text
Host

homelab/appdata/<application>

↓

Container

/config
```

This keeps application state isolated while allowing controlled access to shared storage.

---

## Shared Container View

Media-related containers receive only the storage required for their role. Download clients receive the downloads directory, while media managers additionally receive the appropriate media library.

This follows the principle of least privilege.

Because download clients and media management applications use matching container paths for shared download locations, remote path mappings are avoided.

---

## Storage Access Principles

Storage access should follow the principle of least privilege.

Applications should only receive access to the storage required for their function.

Media storage is intentionally separated from application configuration so that:

- Application state can be backed up independently.
- Services without media requirements do not receive unnecessary filesystem access.
- The impact of application compromise or misconfiguration is reduced.

The specific container mount assignments are documented in `container-platform.md`.

---

# Future ZFS Layout

The production server will use ZFS storage.

Initial configuration:

* Two NAS-grade HDDs configured as a mirrored vdev.

Future expansion:

* Additional mirrored vdevs added as capacity requirements increase.

The logical directory structure remains unchanged when moving to ZFS.

Hardlink support requires downloads and media to remain within the same ZFS filesystem/dataset. Future ZFS dataset design must preserve this requirement.

---

# Backup Considerations

The following contain important data and should be backed up:

* `appdata/`
* `backups/` (backup metadata and exported recovery data)
* `scripts/`
* Documentation
* Git repository

The following can generally be recreated:

* `downloads/`
* `staging/`

The media library backup strategy will depend on available backup capacity and recovery requirements.

---

# Design Principles

The storage architecture follows these principles:

* Keep configuration separate from application containers.
* Keep downloads and media on the same filesystem.
* Use consistent paths across environments.
* Organize media by type rather than genre.
* Minimize migration complexity.
* Favor reliability and maintainability over unnecessary complexity.

---

# Related Documentation

* `architecture.md`
* `container-platform.md`
* `project-status.md`
