.PHONY: help build up down logs clean test vpn-start vpn-stop

# Default target
help: ## Show this help message
	@echo "Navidrome Server Management"
	@echo ""
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-15s %s\n", $$1, $$2}'

# Docker Compose commands
build: ## Build the services
	docker-compose build

up: ## Start all services
	docker-compose up -d

down: ## Stop all services
	docker-compose down

logs: ## Show logs from all services
	docker-compose logs -f

restart: ## Restart all services
	docker-compose restart

# VPN commands
vpn-start: ## Start VPN connection and services
	./start-vpn-navidrome.sh

vpn-stop: ## Stop VPN and services
	./stop-vpn-navidrome.sh

vpn-status: ## Check VPN status
	./host-ovpn-connect.sh status

# Testing
test: ## Run basic tests
	./test-setup.sh

test-vpn: ## Test VPN configuration
	./host-ovpn-connect.sh connect

# Cleanup
clean: ## Remove containers, networks, and volumes
	docker-compose down -v --remove-orphans

clean-all: ## Remove everything including images
	docker-compose down -v --remove-orphans --rmi all

# Development
shell: ## Open shell in navidrome container
	docker-compose exec navidrome sh

logs-navidrome: ## Show Navidrome logs
	docker-compose logs -f navidrome

# Setup
setup: ## Run initial setup
	./auto-setup-vpn.sh

setup-systemd: ## Install systemd service
	sudo ./install-vpn-service.sh

setup-cron: ## Install cron monitoring
	./setup-cron-monitoring.sh

# Status
status: ## Show status of all components
	@echo "=== Docker Services ==="
	@docker-compose ps
	@echo ""
	@echo "=== VPN Status ==="
	@./host-ovpn-connect.sh status 2>/dev/null || echo "VPN scripts not available"
	@echo ""
	@echo "=== System Resources ==="
	@docker system df