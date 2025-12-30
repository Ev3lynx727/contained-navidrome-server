#!/bin/bash

# tailscale-monitor.sh - Monitor Tailscale connection health

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

# Check Tailscale status
check_status() {
    log_info "Checking Tailscale status..."

    if tailscale status | grep -q "Tailscale is up"; then
        log_success "Tailscale is connected"
        return 0
    else
        log_error "Tailscale is not connected"
        return 1
    fi
}

# Check network connectivity
check_connectivity() {
    log_info "Checking network connectivity..."

    # Try to ping Tailscale coordination server
    if timeout 5 tailscale ping controlplane.tailscale.com >/dev/null 2>&1; then
        log_success "Network connectivity OK"
        return 0
    else
        log_error "Network connectivity issues"
        return 1
    fi
}

# Show current IPs
show_ips() {
    log_info "Current Tailscale IPs:"
    tailscale ip -4
    tailscale ip -6
}

# Show peers
show_peers() {
    log_info "Tailscale peers:"
    tailscale status | grep -E "^[0-9]"
}

# Continuous monitoring
monitor() {
    log_info "Starting continuous monitoring (Ctrl+C to stop)..."

    while true; do
        echo ""
        echo "=== $(date) ==="

        if check_status && check_connectivity; then
            show_ips
        fi

        sleep 60
    done
}

# Main
main() {
    echo ""
    log_info "📊 Tailscale Monitor"
    echo "==================="

    case "${1:-status}" in
        status)
            check_status && check_connectivity && show_ips && show_peers
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