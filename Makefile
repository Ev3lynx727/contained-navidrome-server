.PHONY: help build up down logs clean test tailscale-start tailscale-stop

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

# Tailscale commands
tailscale-start: ## Start Tailscale and services
	./start-tailscale-navidrome.sh

tailscale-stop: ## Stop services (Tailscale remains connected)
	./stop-tailscale-navidrome.sh

tailscale-status: ## Check Tailscale status
	./tailscale-monitor.sh status

# Testing
test: ## Run basic tests
	./test-setup.sh

test-tailscale: ## Test Tailscale configuration
	./tailscale-monitor.sh status

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
	./install-tailscale.sh && ./setup-tailscale.sh

setup-systemd: ## Install systemd service
	sudo cp navidrome-tailscale.service /etc/systemd/system/ && sudo systemctl daemon-reload && sudo systemctl enable navidrome-tailscale

setup-monitor: ## Setup connection monitoring
	./tailscale-monitor.sh monitor

# Status
status: ## Show status of all components
	@echo "=== Docker Services ==="
	@docker-compose ps
	@echo ""
	@echo "=== Tailscale Status ==="
	@tailscale status 2>/dev/null || echo "Tailscale not available"
	@echo ""
	@echo "=== System Resources ==="
	@docker system df