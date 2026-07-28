# Storage Architecture

## Purpose

This document describes the storage architecture for the homelab media server and the reasoning behind each design decision.

The primary goals of this storage layout are:

1. Reliability
2. Security
3. Ease of maintenance
4. Expandability
5. Performance
6. Efficient use of disk space
7. Simple migration from the temporary Windows environment to the future Proxmox server

The directory structure is intentionally designed so that the Windows development environment closely mirrors the future Linux server. This minimizes the changes required during migration.

---

# Current Development Environment

Root storage location:

```text
E:\homelab
```

Future production location:

```text
/srv/homelab
```

Only the root path should change during migration. The directory layout should remain the same.

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

Persistent application configuration.

Examples:

* Jellyfin database
* Sonarr configuration
* Radarr configuration
* qBittorrent configuration
* Homepage configuration
* Uptime Kuma database

This directory contains application state and should be included in backups.

---

## media

The permanent media library consumed by Jellyfin.

Subdirectories are organized by media type rather than genre.

Examples:

* Movies
* Television series
* Music
* Books
* Music videos

Anime is stored within the existing `tv` and `movies` libraries because it is managed by Sonarr and Radarr like any other television series or movie.

---

## downloads

Temporary and active download storage.

Downloads are separated by application:

* qBittorrent
* SABnzbd

Each application has:

* `incomplete/`
* `complete/`

Torrent downloads may remain in the completed directory for extended periods while seeding.

Usenet downloads are generally temporary and are removed after a successful import.

---

## backups

Application backups and exported configuration.

This directory will later contain:

* database exports
* configuration archives
* backup manifests

---

## logs

Optional centralized log storage if required by future services.

---

## scripts

Administrative scripts used to automate maintenance, backups, updates, and other operational tasks.

---

## staging

Temporary working directory used during maintenance operations and large file transfers.

This directory is not intended for permanent storage.

---

# Hardlink Strategy

The media server is designed to use hardlinks whenever possible.

Hardlinks allow Sonarr and Radarr to import completed torrent downloads without duplicating file contents.

Benefits include:

* Reduced disk usage
* Instant imports
* Continued torrent seeding
* Less disk wear

For hardlinks to function correctly:

* Downloads and media must reside on the same filesystem.
* Containers must use consistent bind mounts.
* Permissions must allow both the downloader and media managers to access the same files.

These requirements influence both the directory layout and the Docker Compose configuration.

---

# Future ZFS Layout

The production server will use ZFS.

Initial configuration:

* One mirrored vdev consisting of two NAS-grade HDDs.

Future expansion:

* Additional mirrored vdevs will be added to increase capacity while maintaining redundancy.

The directory structure documented here should remain unchanged after migration to ZFS.

---

# Backup Considerations

The following directories contain irreplaceable or difficult-to-recreate data and should be backed up:

* appdata/
* scripts/
* documentation
* Git repository

The following directories can be recreated or re-downloaded if necessary:

* downloads/
* staging/

The media library backup strategy will depend on the total storage capacity and available backup infrastructure.

---

# Design Principles

The storage architecture follows several guiding principles:

* Keep configuration separate from application containers.
* Keep downloads and media on the same filesystem.
* Organize by media type rather than genre.
* Maintain consistent directory names across environments.
* Minimize migration effort.
* Favor simplicity and long-term maintainability over unnecessary complexity.
