#!/bin/bash

# stop-tailscale-navidrome.sh - Stop Tailscale container and Navidrome

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

# Stop services
stop_services() {
    log_info "Stopping Tailscale and Navidrome containers..."

    docker compose down

    log_success "Services stopped"
}

# Main
main() {
    echo ""
    log_info "🛑 Stopping Tailscale Container + Navidrome"
    echo "==========================================="

    stop_services

    echo ""
    log_success "✅ Services stopped successfully!"
}

main "$@"