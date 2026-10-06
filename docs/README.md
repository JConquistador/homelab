# Homelab Documentation

## Purpose

This directory contains the design, implementation, and operational documentation for the homelab media server project.

The documentation is intended to make the environment reproducible, maintainable, and recoverable without relying on institutional knowledge or chat history.

---

# Documentation Philosophy

The repository is the authoritative source of truth for this project.

Documentation should explain both:

* **What** the system does.
* **Why** it was designed that way.

Whenever implementation and documentation disagree, the documentation should be updated to reflect the actual system.

---

# Document Structure

## Core Documentation

| Document          | Purpose                                                                          |
| ----------------- | -------------------------------------------------------------------------------- |
| architecture.md   | High-level system architecture and design principles.                            |
| project-status.md | Current project phase, completed work, and next steps.                           |
| decisions.md      | Architecture Decision Record (ADR) log documenting significant design decisions. |

---

## Design Documentation

* `design/networking.md` — Network architecture, trust boundaries, public/private access, Tailscale, and Docker networking.
* `design/reverse-proxy.md` — Caddy, Cloudflare, public ingress, and service exposure.
* `design/container-platform.md` — Docker Compose, container networking, storage mounts, and deployment standards.
* `design/storage-architecture.md` — Storage layout, filesystem strategy, hardlinks, and future ZFS architecture.
* `design/media-stack.md` — Media application architecture and service relationships.
* `design/permissions.md` — Container and filesystem permission strategy.
* `design/backup-strategy.md` — Backup architecture and retention.
* `design/disaster-recovery.md` — Recovery procedures and disaster scenarios.
* `design/migration.md` — Development-to-production migration strategy.

---

## Implementation Documentation

The `implementation/` directory contains operational procedures.

Examples include:

* migration.md
* maintenance.md
* hardware.md

---

## Archive

Historical planning documents and superseded documentation are stored in the `archive/` directory.

---

# Documentation Workflow

Each project phase should follow this workflow:

1. Design
2. Document
3. Implement
4. Validate
5. Commit
6. Push
7. Update documentation

This ensures the documentation remains synchronized with the implementation.
