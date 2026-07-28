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
