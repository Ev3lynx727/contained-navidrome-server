#!/bin/bash

# tailscale-monitor.sh - Monitor Tailscale container connection health

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# Check if services are running
check_containers() {
    log_info "Checking container status..."

    if docker compose ps | grep -q "tailscale-navidrome.*Up"; then
        log_success "Tailscale container is running"
    else
        log_error "Tailscale container is not running"
        return 1
    fi

    if docker compose ps | grep -q "navidrome-server.*Up"; then
        log_success "Navidrome container is running"
    else
        log_error "Navidrome container is not running"
        return 1
    fi
}

# Check Tailscale status
check_status() {
    log_info "Checking Tailscale status..."

    if docker compose exec -T tailscale tailscale status | grep -q "Tailscale is up"; then
        log_success "Tailscale is connected"
        return 0
    else
        log_error "Tailscale is not connected"
        return 1
    fi
}

# Show current IPs
show_ips() {
    log_info "Current Tailscale IPs:"
    docker compose exec -T tailscale tailscale ip -4
    docker compose exec -T tailscale tailscale ip -6
}

# Show peers
show_peers() {
    log_info "Tailscale peers:"
    docker compose exec -T tailscale tailscale status | grep -E "^[0-9]"
}

# Check Navidrome accessibility
check_navidrome() {
    log_info "Checking Navidrome accessibility..."

    if curl -f -s http://localhost:4533/login > /dev/null 2>&1; then
        log_success "Navidrome is accessible"
        return 0
    else
        log_error "Navidrome is not responding"
        return 1
    fi
}

# Continuous monitoring
monitor() {
    log_info "Starting continuous monitoring (Ctrl+C to stop)..."

    while true; do
        echo ""
        echo "=== $(date) ==="

        if check_containers && check_status && check_navidrome; then
            show_ips
        fi

        sleep 60
    done
}

# Main
main() {
    echo ""
    log_info "📊 Tailscale Container Monitor"
    echo "=============================="

    case "${1:-status}" in
        status)
            check_containers && check_status && check_navidrome && show_ips && show_peers
            ;;
        monitor)
            monitor
            ;;
        *)
            log_error "Usage: $0 [status|monitor]"
            exit 1
            ;;
    esac
}

main "$@"