# ARC SaaS Makefile
# Cross-platform commands for Docker management

.PHONY: help start start-db start-services stop restart status logs logs-tenant logs-subscription \
        migrate build clean health shell-tenant shell-subscription shell-postgres-tenant \
        shell-postgres-subscription shell-redis test dev prod pgadmin redis-commander

# Default target
.DEFAULT_GOAL := help

# Colors for output
GREEN  := \033[0;32m
YELLOW := \033[1;33m
BLUE   := \033[0;34m
NC     := \033[0m # No Color

##@ General

help: ## Display this help message
	@echo "$(BLUE)ARC SaaS Docker Management$(NC)"
	@echo ""
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make $(YELLOW)<target>$(NC)\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2 } /^##@/ { printf "\n$(BLUE)%s$(NC)\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Docker Compose Commands

start: ## Start all services
	@echo "$(BLUE)[INFO]$(NC) Starting all ARC SaaS services..."
	docker-compose up -d
	@echo "$(GREEN)[SUCCESS]$(NC) All services started!"

start-db: ## Start only databases (PostgreSQL and Redis)
	@echo "$(BLUE)[INFO]$(NC) Starting databases..."
	docker-compose up -d postgres-tenant-management postgres-subscription redis
	@echo "$(GREEN)[SUCCESS]$(NC) Databases started!"

start-services: ## Start only application services
	@echo "$(BLUE)[INFO]$(NC) Starting application services..."
	docker-compose up -d tenant-management-service subscription-service
	@echo "$(GREEN)[SUCCESS]$(NC) Services started!"

stop: ## Stop all services
	@echo "$(BLUE)[INFO]$(NC) Stopping all services..."
	docker-compose stop
	@echo "$(GREEN)[SUCCESS]$(NC) All services stopped!"

down: ## Stop and remove containers
	@echo "$(BLUE)[INFO]$(NC) Stopping and removing containers..."
	docker-compose down
	@echo "$(GREEN)[SUCCESS]$(NC) Containers removed!"

restart: ## Restart all services
	@echo "$(BLUE)[INFO]$(NC) Restarting all services..."
	docker-compose restart
	@echo "$(GREEN)[SUCCESS]$(NC) All services restarted!"

restart-tenant: ## Restart tenant management service
	docker-compose restart tenant-management-service

restart-subscription: ## Restart subscription service
	docker-compose restart subscription-service

status: ## Show service status
	@echo "$(BLUE)[INFO]$(NC) Service status:"
	docker-compose ps

##@ Logs

logs: ## Show logs for all services
	docker-compose logs -f

logs-tenant: ## Show logs for tenant management service
	docker-compose logs -f tenant-management-service

logs-subscription: ## Show logs for subscription service
	docker-compose logs -f subscription-service

logs-postgres-tenant: ## Show logs for tenant PostgreSQL
	docker-compose logs -f postgres-tenant-management

logs-postgres-subscription: ## Show logs for subscription PostgreSQL
	docker-compose logs -f postgres-subscription

logs-redis: ## Show logs for Redis
	docker-compose logs -f redis

##@ Database Operations

migrate: ## Run database migrations
	@echo "$(BLUE)[INFO]$(NC) Running database migrations..."
	@echo "$(BLUE)[INFO]$(NC) Tenant Management Service migrations..."
	docker-compose exec tenant-management-service npm run migrate
	@echo "$(BLUE)[INFO]$(NC) Subscription Service migrations..."
	docker-compose exec subscription-service npm run migrate
	@echo "$(GREEN)[SUCCESS]$(NC) Migrations completed!"

migrate-tenant: ## Run tenant management migrations only
	docker-compose exec tenant-management-service npm run migrate

migrate-subscription: ## Run subscription service migrations only
	docker-compose exec subscription-service npm run migrate

db-shell-tenant: ## Open PostgreSQL shell for tenant database
	docker-compose exec postgres-tenant-management psql -U postgres -d tenant_management_db

db-shell-subscription: ## Open PostgreSQL shell for subscription database
	docker-compose exec postgres-subscription psql -U postgres -d subscription_db

##@ Build & Development

build: ## Build/rebuild all services
	@echo "$(BLUE)[INFO]$(NC) Building services..."
	docker-compose build --no-cache
	@echo "$(GREEN)[SUCCESS]$(NC) Build completed!"

build-tenant: ## Build tenant management service only
	docker-compose build --no-cache tenant-management-service

build-subscription: ## Build subscription service only
	docker-compose build --no-cache subscription-service

dev: ## Start development environment
	@echo "$(BLUE)[INFO]$(NC) Starting development environment..."
	docker-compose -f docker-compose.dev.yml up -d
	@echo "$(GREEN)[SUCCESS]$(NC) Development environment started!"

dev-logs: ## Show logs for development environment
	docker-compose -f docker-compose.dev.yml logs -f

dev-down: ## Stop development environment
	docker-compose -f docker-compose.dev.yml down

prod: start ## Start production environment (alias for start)

##@ Shell Access

shell-tenant: ## Open shell in tenant management service
	docker-compose exec tenant-management-service sh

shell-subscription: ## Open shell in subscription service
	docker-compose exec subscription-service sh

shell-postgres-tenant: ## Open shell in tenant PostgreSQL
	docker-compose exec postgres-tenant-management sh

shell-postgres-subscription: ## Open shell in subscription PostgreSQL
	docker-compose exec postgres-subscription sh

shell-redis: ## Open shell in Redis
	docker-compose exec redis sh

##@ Testing

test-tenant: ## Run tests for tenant management service
	docker-compose exec tenant-management-service npm test

test-subscription: ## Run tests for subscription service
	docker-compose exec subscription-service npm test

test-all: ## Run tests for all services
	docker-compose exec tenant-management-service npm test
	docker-compose exec subscription-service npm test

coverage-tenant: ## Run coverage for tenant management service
	docker-compose exec tenant-management-service npm run coverage

coverage-subscription: ## Run coverage for subscription service
	docker-compose exec subscription-service npm run coverage

##@ Health & Monitoring

health: ## Check service health
	@echo "$(BLUE)[INFO]$(NC) Checking service health..."
	@echo ""
	@echo "$(BLUE)[INFO]$(NC) Tenant Management Service:"
	@curl -sf http://localhost:3005/ping > /dev/null && echo "$(GREEN)✓$(NC) Tenant Management Service is healthy" || echo "$(YELLOW)✗$(NC) Tenant Management Service is not responding"
	@echo ""
	@echo "$(BLUE)[INFO]$(NC) Subscription Service:"
	@curl -sf http://localhost:3002/ping > /dev/null && echo "$(GREEN)✓$(NC) Subscription Service is healthy" || echo "$(YELLOW)✗$(NC) Subscription Service is not responding"
	@echo ""
	@echo "$(BLUE)[INFO]$(NC) PostgreSQL (Tenant):"
	@docker-compose exec -T postgres-tenant-management pg_isready -U postgres > /dev/null 2>&1 && echo "$(GREEN)✓$(NC) PostgreSQL Tenant DB is ready" || echo "$(YELLOW)✗$(NC) PostgreSQL Tenant DB is not ready"
	@echo ""
	@echo "$(BLUE)[INFO]$(NC) PostgreSQL (Subscription):"
	@docker-compose exec -T postgres-subscription pg_isready -U postgres > /dev/null 2>&1 && echo "$(GREEN)✓$(NC) PostgreSQL Subscription DB is ready" || echo "$(YELLOW)✗$(NC) PostgreSQL Subscription DB is not ready"
	@echo ""
	@echo "$(BLUE)[INFO]$(NC) Redis:"
	@docker-compose exec -T redis redis-cli ping > /dev/null 2>&1 && echo "$(GREEN)✓$(NC) Redis is ready" || echo "$(YELLOW)✗$(NC) Redis is not ready"

stats: ## Show Docker stats
	docker stats $(shell docker-compose ps -q)

##@ Management Tools

pgadmin: ## Open pgAdmin in browser
	@echo "$(BLUE)[INFO]$(NC) Opening pgAdmin..."
	@echo "URL: http://localhost:5050"
	@echo "Email: admin@arc-saas.local"
	@echo "Password: admin"

redis-commander: ## Open Redis Commander in browser
	@echo "$(BLUE)[INFO]$(NC) Opening Redis Commander..."
	@echo "URL: http://localhost:8081"

swagger-tenant: ## Open Tenant Management Swagger UI
	@echo "$(BLUE)[INFO]$(NC) Opening Tenant Management Swagger..."
	@echo "URL: http://localhost:3005/explorer"

swagger-subscription: ## Open Subscription Swagger UI
	@echo "$(BLUE)[INFO]$(NC) Opening Subscription Swagger..."
	@echo "URL: http://localhost:3002/explorer"

##@ Cleanup

clean: ## Remove all containers and volumes
	@echo "$(YELLOW)[WARNING]$(NC) This will remove all containers and volumes!"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		echo "$(BLUE)[INFO]$(NC) Cleaning up..."; \
		docker-compose down -v; \
		echo "$(GREEN)[SUCCESS]$(NC) Cleanup completed!"; \
	else \
		echo "$(BLUE)[INFO]$(NC) Cleanup cancelled."; \
	fi

clean-images: ## Remove Docker images
	docker-compose down --rmi all

clean-all: ## Remove everything (containers, volumes, images)
	docker-compose down -v --rmi all

prune: ## Prune Docker system
	docker system prune -af --volumes

##@ Quick Commands

quick-start: start migrate health ## Quick start: Start all services and run migrations
	@echo "$(GREEN)[SUCCESS]$(NC) ARC SaaS is ready!"
	@echo ""
	@echo "$(BLUE)Access Points:$(NC)"
	@echo "  - Tenant Management API: http://localhost:3005/explorer"
	@echo "  - Subscription API: http://localhost:3002/explorer"
	@echo "  - pgAdmin: http://localhost:5050"
	@echo "  - Redis Commander: http://localhost:8081"

quick-dev: dev ## Quick start development environment
	@echo "$(GREEN)[SUCCESS]$(NC) Development environment is ready!"

reset: down start migrate ## Reset: Stop, start fresh, and run migrations
	@echo "$(GREEN)[SUCCESS]$(NC) Environment reset complete!"
