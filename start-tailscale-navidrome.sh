#!/bin/bash

# start-tailscale-navidrome.sh - Start Tailscale container and Navidrome

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

# Check if auth key is configured
check_auth() {
    if [ ! -f .env ] || ! grep -q "^TS_AUTHKEY=" .env; then
        log_error "Tailscale auth key not configured. Run ./setup-tailscale.sh first"
        exit 1
    fi
}

# Start services
start_services() {
    log_info "Starting Tailscale and Navidrome containers..."

    docker compose up -d

    log_success "Services started"
}

# Verify Tailscale connection
verify_tailscale() {
    log_info "Verifying Tailscale connection..."

    # Wait for Tailscale to connect
    timeout=60
    while [[ $timeout -gt 0 ]]; do
        if docker compose exec -T tailscale tailscale status | grep -q "Tailscale is up"; then
            break
        fi
        sleep 5
        timeout=$((timeout - 5))
    done

    if [[ $timeout -le 0 ]]; then
        log_error "Tailscale failed to connect within 60 seconds"
        log_info "Check container logs: docker compose logs tailscale"
        exit 1
    fi

    log_success "Tailscale is connected"
}

# Verify Navidrome is accessible
verify_navidrome() {
    log_info "Verifying Navidrome accessibility..."

    # Wait for Navidrome to be ready
    timeout=60
    while [[ $timeout -gt 0 ]]; do
        if curl -f -s http://localhost:4533/login > /dev/null 2>&1; then
            break
        fi
        sleep 2
        timeout=$((timeout - 2))
    done

    if [[ $timeout -le 0 ]]; then
        log_error "Navidrome failed to start within 60 seconds"
        log_info "Check container logs: docker compose logs navidrome"
        exit 1
    fi

    log_success "Navidrome is responding"
}

# Show access information
show_access() {
    echo ""
    log_info "🌐 Access Information"
    echo "===================="

    TAILSCALE_IP=$(docker compose exec -T tailscale tailscale ip -4 2>/dev/null || echo "N/A")

    log_info "Local access: http://localhost:4533"
    log_info "Tailscale access: http://${TAILSCALE_IP}:4533"
    log_info "Admin login: admin / (password from .env or empty)"

    if [[ "$TAILSCALE_IP" != "N/A" ]]; then
        log_success "✅ Ready for remote access via Tailscale"
    fi
}

# Main
main() {
    echo ""
    log_info "🚀 Starting Tailscale Container + Navidrome"
    echo "==========================================="

    check_auth
    start_services
    verify_tailscale
    verify_navidrome
    show_access

    echo ""
    log_success "✅ Services started successfully!"
}

main "$@"