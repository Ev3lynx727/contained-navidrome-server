#!/bin/bash

# setup-tailscale.sh - Set up and authenticate Tailscale

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

# Check if Tailscale is installed
check_tailscale() {
    if ! command -v tailscale &> /dev/null; then
        log_error "Tailscale is not installed. Run ./install-tailscale.sh first"
        exit 1
    fi

    if ! systemctl is-active --quiet tailscaled; then
        log_error "Tailscale daemon is not running"
        exit 1
    fi
}

# Authenticate with Tailscale
authenticate() {
    log_info "Authenticating with Tailscale..."

    # Check for auth key in environment
    if [[ -n "$TS_AUTHKEY" ]]; then
        log_info "Using auth key from environment"
        sudo tailscale up --auth-key="$TS_AUTHKEY"
    else
        log_info "No auth key found. Starting interactive authentication..."
        log_info "Follow the URL that will be displayed to authenticate this device"
        sudo tailscale up
    fi

    log_success "Tailscale authenticated"
}

# Configure hostname and options
configure() {
    log_info "Configuring Tailscale..."

    # Set hostname if provided
    if [[ -n "$TS_HOSTNAME" ]]; then
        sudo tailscale set --hostname="$TS_HOSTNAME"
        log_info "Hostname set to: $TS_HOSTNAME"
    fi

    # Advertise routes if provided
    if [[ -n "$TS_ROUTES" ]]; then
        sudo tailscale set --advertise-routes="$TS_ROUTES"
        log_info "Advertised routes: $TS_ROUTES"
    fi

    # Accept DNS if requested
    if [[ "$TS_ACCEPT_DNS" == "true" ]]; then
        sudo tailscale set --accept-dns=true
        log_info "DNS configuration accepted"
    fi
}

# Verify connection
verify() {
    log_info "Verifying Tailscale connection..."

    # Wait for connection
    timeout=30
    while [[ $timeout -gt 0 ]]; do
        if tailscale status | grep -q "Tailscale is up"; then
            break
        fi
        sleep 2
        timeout=$((timeout - 2))
    done

    if [[ $timeout -le 0 ]]; then
        log_error "Tailscale failed to connect within 30 seconds"
        exit 1
    fi

    # Show status
    tailscale status
    tailscale ip -4
    tailscale ip -6

    log_success "Tailscale is connected"
}

# Main
main() {
    echo ""
    log_info "🔐 Setting up Tailscale VPN"
    echo "==========================="

    check_tailscale
    authenticate
    configure
    verify

    echo ""
    log_success "✅ Tailscale setup complete!"
    log_info "Your Navidrome server is now accessible via Tailscale"
    log_info "Use 'tailscale ip' to get the Tailscale IP address"
}

main "$@"