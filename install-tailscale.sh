#!/bin/bash

# install-tailscale.sh - Install Tailscale on the host system

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

# Detect OS
detect_os() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS=$ID
        VERSION=$VERSION_ID
    else
        log_error "Cannot detect OS"
        exit 1
    fi
}

# Install Tailscale
install_tailscale() {
    log_info "Installing Tailscale..."

    case $OS in
        ubuntu|debian)
            # Add Tailscale repository
            curl -fsSL https://pkgs.tailscale.com/stable/${OS}/${VERSION_ID}.noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
            curl -fsSL https://pkgs.tailscale.com/stable/${OS}/${VERSION_ID}.tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list

            # Update and install
            sudo apt-get update
            sudo apt-get install -y tailscale
            ;;

        centos|rhel|fedora)
            # Add Tailscale repository
            sudo dnf config-manager --add-repo https://pkgs.tailscale.com/stable/${OS}/${VERSION_ID}/tailscale.repo
            sudo dnf install -y tailscale
            ;;

        *)
            log_error "Unsupported OS: $OS"
            log_info "Please install Tailscale manually from https://tailscale.com/download"
            exit 1
            ;;
    esac

    log_success "Tailscale installed"
}

# Enable and start service
enable_service() {
    log_info "Enabling Tailscale service..."

    sudo systemctl enable tailscaled
    sudo systemctl start tailscaled

    log_success "Tailscale service enabled and started"
}

# Main
main() {
    echo ""
    log_info "🔧 Installing Tailscale VPN"
    echo "============================"

    detect_os
    log_info "Detected OS: $OS $VERSION"

    install_tailscale
    enable_service

    echo ""
    log_success "✅ Tailscale installation complete!"
    log_info "Next: Run ./setup-tailscale.sh to authenticate"
}

main "$@"