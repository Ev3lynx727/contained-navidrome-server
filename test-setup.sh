#!/bin/bash

# test-setup.sh - Basic tests for Navidrome setup

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

# Test Docker Compose configuration
test_docker_compose() {
    log_info "Testing Docker Compose configuration..."
    if docker compose config --quiet; then
        log_success "Docker Compose configuration is valid"
    else
        log_error "Docker Compose configuration is invalid"
        exit 1
    fi
}

# Test Navidrome accessibility
test_navidrome() {
    log_info "Testing Navidrome accessibility..."

    # Check if container is running
    if ! docker compose ps | grep -q "navidrome-server.*Up"; then
        log_warn "Navidrome container is not running, starting it..."
        docker compose up -d navidrome
        sleep 10
    fi

    # Test HTTP endpoint
    if curl -f -s http://localhost:4533/login > /dev/null; then
        log_success "Navidrome is accessible"
    else
        log_error "Navidrome is not responding"
        exit 1
    fi
}

# Test Tailscale configuration
test_tailscale_config() {
    log_info "Testing Tailscale configuration..."

    if command -v tailscale &> /dev/null; then
        log_success "Tailscale is installed"

        if systemctl is-active --quiet tailscaled; then
            log_success "Tailscale daemon is running"

            if tailscale status | grep -q "Tailscale is up"; then
                log_success "Tailscale is connected"
                tailscale ip -4
            else
                log_warn "Tailscale is not connected (expected for CI)"
            fi
        else
            log_error "Tailscale daemon is not running"
            exit 1
        fi
    else
        log_warn "Tailscale is not installed"
    fi
}

# Test script permissions
test_scripts() {
    log_info "Testing script permissions..."

    local scripts=("install-tailscale.sh" "setup-tailscale.sh" "start-tailscale-navidrome.sh" "stop-tailscale-navidrome.sh" "tailscale-monitor.sh")

    for script in "${scripts[@]}"; do
        if [ -f "$script" ] && [ -x "$script" ]; then
            log_success "Script $script is executable"
        elif [ -f "$script" ] && [ -x "$script" ]; then
            log_warn "Script $script exists but is not executable"
        else
            log_warn "Script $script not found"
        fi
    done
}

# Run all tests
main() {
    echo ""
    log_info "🧪 Running Navidrome Setup Tests"
    echo "================================="

    test_docker_compose
    test_scripts
    test_tailscale_config
    test_navidrome

    echo ""
    log_success "✅ All tests passed!"
}

main "$@"