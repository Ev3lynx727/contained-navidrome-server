#!/bin/bash

# setup-tailscale.sh - Configure Tailscale authentication key

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

# Check if .env exists
check_env() {
    if [ ! -f .env ]; then
        log_error ".env file not found. Run ./install-tailscale.sh first"
        exit 1
    fi
}

# Setup auth key
setup_auth() {
    log_info "Configuring Tailscale authentication..."

    if grep -q "^TS_AUTHKEY=" .env; then
        log_info "TS_AUTHKEY is already configured in .env"
    else
        log_warn "TS_AUTHKEY not found in .env"
        log_info "Please add your Tailscale auth key to .env:"
        log_info "TS_AUTHKEY=tskey-auth-..."
        log_info ""
        log_info "Get an auth key from: https://login.tailscale.com/admin/settings/keys"
        exit 1
    fi

    log_success "Auth key configured"
}

# Main
main() {
    echo ""
    log_info "🔑 Configuring Tailscale Authentication"
    echo "======================================="

    check_env
    setup_auth

    echo ""
    log_success "✅ Tailscale authentication configured!"
    log_info "Run ./start-tailscale-navidrome.sh to start the services"
}

main "$@"