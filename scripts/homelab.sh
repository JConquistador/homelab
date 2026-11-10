
#!/usr/bin/env bash

set -Eeuo pipefail

# Resolve repository root from this script's location.
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
HOMELAB_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"

# Compose project directories.
INFRA_DIR="${HOMELAB_ROOT}/compose/infrastructure"
MEDIA_DIR="${HOMELAB_ROOT}/compose/media"
PROXY_DIR="${HOMELAB_ROOT}/compose/proxy"

# External Docker networks required by the projects.
NETWORKS=(
    "frontend"
    "monitoring"
    "homelab-proxy-network"
)

usage() {
    cat <<EOF
Usage: $(basename "$0") <command>

Commands:
  up       Create required networks and start all projects.
  restart  Stop and start all projects.
  stop     Stop all projects in reverse dependency order.
  status   Show the status of all projects.
  help     Display this help message.
EOF
}

# Run Compose using the correct project directory.
compose() {
    local project_dir="$1"
    shift

    docker compose \
        --project-directory "$project_dir" \
        -f "${project_dir}/compose.yaml" \
        "$@"
}

# Verify Docker and all required project files.
check_requirements() {
    if ! command -v docker >/dev/null 2>&1; then
        echo "ERROR: Docker is not installed or not in PATH."
        exit 1
    fi

    if ! docker info >/dev/null 2>&1; then
        echo "ERROR: Docker daemon is not running or is inaccessible."
        exit 1
    fi

    for dir in "$INFRA_DIR" "$MEDIA_DIR" "$PROXY_DIR"; do
        if [[ ! -f "${dir}/compose.yaml" ]]; then
            echo "ERROR: Missing ${dir}/compose.yaml"
            exit 1
        fi

        if [[ ! -f "${dir}/.env" ]]; then
            echo "ERROR: Missing ${dir}/.env"
            exit 1
        fi
    done
}

# Create external networks only when they do not exist.
create_networks() {
    echo
    echo "Checking required Docker networks..."

    for network in "${NETWORKS[@]}"; do
        if docker network inspect "$network" >/dev/null 2>&1; then
            echo "  [EXISTS] $network"
        else
            echo "  [CREATE] $network"
            docker network create "$network"
        fi
    done
}

start_projects() {
    echo
    echo "Starting infrastructure..."
    compose "$INFRA_DIR" up -d

    echo
    echo "Starting media services..."
    compose "$MEDIA_DIR" up -d

    echo
    echo "Starting reverse proxy..."
    compose "$PROXY_DIR" up -d

    echo
    echo "All Homelab projects started."
}

stop_projects() {
    echo
    echo "Stopping reverse proxy..."
    compose "$PROXY_DIR" stop

    echo
    echo "Stopping media services..."
    compose "$MEDIA_DIR" stop

    echo
    echo "Stopping infrastructure..."
    compose "$INFRA_DIR" stop

    echo
    echo "All Homelab projects stopped."
}

show_status() {
    echo
    echo "===== Infrastructure ====="
    compose "$INFRA_DIR" ps

    echo
    echo "===== Media ====="
    compose "$MEDIA_DIR" ps

    echo
    echo "===== Proxy ====="
    compose "$PROXY_DIR" ps
}

main() {
    local command="${1:-help}"

    case "$command" in
        up)
            check_requirements
            create_networks
            start_projects
            ;;
        restart)
            check_requirements
            stop_projects
            create_networks
            start_projects
            ;;
        stop)
            check_requirements
            stop_projects
            ;;
        status)
            check_requirements
            show_status
            ;;
        help|-h|--help)
            usage
            ;;
        *)
            echo "ERROR: Unknown command: $command"
            usage
            exit 1
            ;;
    esac
}

main "$@"
