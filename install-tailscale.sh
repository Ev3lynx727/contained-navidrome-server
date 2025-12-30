#!/bin/bash

# install-tailscale.sh - Prepare environment for Tailscale container

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

# Create necessary directories
create_directories() {
    log_info "Creating necessary directories..."

    mkdir -p data music tailscale-state

    log_success "Directories created"
}

# Check Docker and Docker Compose
check_docker() {
    log_info "Checking Docker installation..."

    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed"
        exit 1
    fi

    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        log_error "Docker Compose is not installed"
        exit 1
    fi

    log_success "Docker and Docker Compose are available"
}

# Setup .env file
setup_env() {
    log_info "Setting up environment file..."

    if [ ! -f .env ]; then
        cp .env.example .env
        log_success "Created .env from .env.example"
    else
        log_info ".env already exists"
    fi

    log_warn "Please edit .env to add your TS_AUTHKEY for Tailscale authentication"
}

# Main
main() {
    echo ""
    log_info "🔧 Preparing environment for Tailscale container"
    echo "==============================================="

    check_docker
    create_directories
    setup_env

    echo ""
    log_success "✅ Environment preparation complete!"
    log_info "Next steps:"
    log_info "1. Edit .env and set TS_AUTHKEY=<your-auth-key>"
    log_info "2. Run ./start-tailscale-navidrome.sh to start services"
}

main "$@"