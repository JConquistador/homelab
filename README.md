# Homelab Infrastructure

Infrastructure as Code repository for my self-hosted media server.

## Goals

- Reliability
- Security
- Maintainability
- Expandability
- Disaster recovery

## Architecture

- Proxmox VE host
- Ubuntu Server LTS Docker VM
- Docker Compose
- ZFS storage
- Jellyfin media stack
- Caddy reverse proxy
- Cloudflare DNS
- Tailscale administration

## Repository Structure

    compose/      Docker Compose configurations
    docs/         Architecture documentation
    scripts/      Automation scripts
    templates/    Configuration templates

## Notes

Secrets and runtime application data are intentionally excluded from this repository.