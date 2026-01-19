#!/bin/bash

# ARC SaaS Docker Management Script
# Usage: ./docker-start.sh [command]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        print_error "Docker is not running. Please start Docker first."
        exit 1
    fi
}

# Check if docker-compose is installed
check_docker_compose() {
    if ! command -v docker-compose &> /dev/null; then
        print_error "docker-compose is not installed. Please install it first."
        exit 1
    fi
}

# Start all services
start_all() {
    print_info "Starting all ARC SaaS services..."
    docker-compose up -d
    print_success "All services started!"
    print_info "Run './docker-start.sh status' to check service status"
}

# Start only databases
start_databases() {
    print_info "Starting databases (PostgreSQL and Redis)..."
    docker-compose up -d postgres-tenant-management postgres-subscription redis
    print_success "Databases started!"
}

# Start services only
start_services() {
    print_info "Starting application services..."
    docker-compose up -d tenant-management-service subscription-service
    print_success "Services started!"
}

# Stop all services
stop_all() {
    print_info "Stopping all services..."
    docker-compose stop
    print_success "All services stopped!"
}

# Restart services
restart_all() {
    print_info "Restarting all services..."
    docker-compose restart
    print_success "All services restarted!"
}

# Show status
show_status() {
    print_info "Service status:"
    docker-compose ps
}

# Show logs
show_logs() {
    if [ -z "$1" ]; then
        print_info "Showing logs for all services (Ctrl+C to exit)..."
        docker-compose logs -f
    else
        print_info "Showing logs for $1 (Ctrl+C to exit)..."
        docker-compose logs -f "$1"
    fi
}

# Run migrations
run_migrations() {
    print_info "Running database migrations..."

    print_info "Running Tenant Management Service migrations..."
    docker-compose exec tenant-management-service npm run migrate

    print_info "Running Subscription Service migrations..."
    docker-compose exec subscription-service npm run migrate

    print_success "Migrations completed!"
}

# Build services
build_services() {
    print_info "Building services..."
    docker-compose build --no-cache
    print_success "Build completed!"
}

# Clean up (remove containers and volumes)
cleanup() {
    print_warning "This will remove all containers and volumes. Are you sure? (y/N)"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        print_info "Cleaning up..."
        docker-compose down -v
        print_success "Cleanup completed!"
    else
        print_info "Cleanup cancelled."
    fi
}

# Health check
health_check() {
    print_info "Checking service health..."

    echo ""
    print_info "Tenant Management Service:"
    if curl -s http://localhost:3005/ping > /dev/null 2>&1; then
        print_success "✓ Tenant Management Service is healthy"
    else
        print_error "✗ Tenant Management Service is not responding"
    fi

    echo ""
    print_info "Subscription Service:"
    if curl -s http://localhost:3002/ping > /dev/null 2>&1; then
        print_success "✓ Subscription Service is healthy"
    else
        print_error "✗ Subscription Service is not responding"
    fi

    echo ""
    print_info "PostgreSQL (Tenant):"
    if docker-compose exec -T postgres-tenant-management pg_isready -U postgres > /dev/null 2>&1; then
        print_success "✓ PostgreSQL Tenant DB is ready"
    else
        print_error "✗ PostgreSQL Tenant DB is not ready"
    fi

    echo ""
    print_info "PostgreSQL (Subscription):"
    if docker-compose exec -T postgres-subscription pg_isready -U postgres > /dev/null 2>&1; then
        print_success "✓ PostgreSQL Subscription DB is ready"
    else
        print_error "✗ PostgreSQL Subscription DB is not ready"
    fi

    echo ""
    print_info "Redis:"
    if docker-compose exec -T redis redis-cli ping > /dev/null 2>&1; then
        print_success "✓ Redis is ready"
    else
        print_error "✗ Redis is not ready"
    fi
}

# Shell access
shell_access() {
    if [ -z "$1" ]; then
        print_error "Please specify a service: tenant-management-service, subscription-service, postgres-tenant-management, postgres-subscription, redis"
        exit 1
    fi

    print_info "Opening shell for $1..."
    docker-compose exec "$1" sh
}

# Show help
show_help() {
    cat << EOF
ARC SaaS Docker Management Script

Usage: ./docker-start.sh [command]

Commands:
  start               Start all services (default)
  start-db            Start only databases (PostgreSQL and Redis)
  start-services      Start only application services
  stop                Stop all services
  restart             Restart all services
  status              Show service status
  logs [service]      Show logs (optionally for specific service)
  migrate             Run database migrations
  build               Build/rebuild services
  cleanup             Remove all containers and volumes
  health              Check service health
  shell <service>     Open shell in service container
  help                Show this help message

Examples:
  ./docker-start.sh start
  ./docker-start.sh logs tenant-management-service
  ./docker-start.sh shell postgres-tenant-management
  ./docker-start.sh migrate

EOF
}

# Main script
main() {
    check_docker
    check_docker_compose

    case "${1:-start}" in
        start)
            start_all
            ;;
        start-db)
            start_databases
            ;;
        start-services)
            start_services
            ;;
        stop)
            stop_all
            ;;
        restart)
            restart_all
            ;;
        status)
            show_status
            ;;
        logs)
            show_logs "$2"
            ;;
        migrate)
            run_migrations
            ;;
        build)
            build_services
            ;;
        cleanup)
            cleanup
            ;;
        health)
            health_check
            ;;
        shell)
            shell_access "$2"
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            print_error "Unknown command: $1"
            show_help
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
