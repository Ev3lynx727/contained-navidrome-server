#!/bin/bash

# stop-tailscale-navidrome.sh - Stop Navidrome and optionally Tailscale

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

# Stop Navidrome
stop_navidrome() {
    log_info "Stopping Navidrome..."

    docker compose down navidrome

    log_success "Navidrome stopped"
}

# Optionally disconnect Tailscale
disconnect_tailscale() {
    if [[ "$1" == "--disconnect" ]]; then
        log_info "Disconnecting Tailscale..."
        sudo tailscale down
        log_success "Tailscale disconnected"
    else
        log_info "Tailscale remains connected (use --disconnect to disconnect)"
    fi
}

# Main
main() {
    echo ""
    log_info "🛑 Stopping Tailscale + Navidrome"
    echo "==================================="

    stop_navidrome
    disconnect_tailscale "$1"

    echo ""
    log_success "✅ Services stopped successfully!"
}

main "$@"