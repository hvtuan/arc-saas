@echo off
REM ARC SaaS Docker Management Script for Windows
REM Usage: docker-start.bat [command]

setlocal enabledelayedexpansion

REM Check if docker is running
docker info >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker is not running. Please start Docker first.
    exit /b 1
)

REM Check if docker-compose is installed
docker-compose version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] docker-compose is not installed. Please install it first.
    exit /b 1
)

REM Get command (default: start)
set "COMMAND=%~1"
if "%COMMAND%"=="" set "COMMAND=start"

if "%COMMAND%"=="start" goto START_ALL
if "%COMMAND%"=="start-db" goto START_DB
if "%COMMAND%"=="start-services" goto START_SERVICES
if "%COMMAND%"=="stop" goto STOP_ALL
if "%COMMAND%"=="restart" goto RESTART_ALL
if "%COMMAND%"=="status" goto SHOW_STATUS
if "%COMMAND%"=="logs" goto SHOW_LOGS
if "%COMMAND%"=="migrate" goto RUN_MIGRATIONS
if "%COMMAND%"=="build" goto BUILD_SERVICES
if "%COMMAND%"=="cleanup" goto CLEANUP
if "%COMMAND%"=="health" goto HEALTH_CHECK
if "%COMMAND%"=="shell" goto SHELL_ACCESS
if "%COMMAND%"=="help" goto SHOW_HELP
if "%COMMAND%"=="--help" goto SHOW_HELP
if "%COMMAND%"=="-h" goto SHOW_HELP

echo [ERROR] Unknown command: %COMMAND%
goto SHOW_HELP

:START_ALL
echo [INFO] Starting all ARC SaaS services...
docker-compose up -d
echo [SUCCESS] All services started!
echo [INFO] Run 'docker-start.bat status' to check service status
goto END

:START_DB
echo [INFO] Starting databases (PostgreSQL and Redis)...
docker-compose up -d postgres-tenant-management postgres-subscription redis
echo [SUCCESS] Databases started!
goto END

:START_SERVICES
echo [INFO] Starting application services...
docker-compose up -d tenant-management-service subscription-service
echo [SUCCESS] Services started!
goto END

:STOP_ALL
echo [INFO] Stopping all services...
docker-compose stop
echo [SUCCESS] All services stopped!
goto END

:RESTART_ALL
echo [INFO] Restarting all services...
docker-compose restart
echo [SUCCESS] All services restarted!
goto END

:SHOW_STATUS
echo [INFO] Service status:
docker-compose ps
goto END

:SHOW_LOGS
if "%~2"=="" (
    echo [INFO] Showing logs for all services (Ctrl+C to exit)...
    docker-compose logs -f
) else (
    echo [INFO] Showing logs for %~2 (Ctrl+C to exit)...
    docker-compose logs -f %~2
)
goto END

:RUN_MIGRATIONS
echo [INFO] Running database migrations...

echo [INFO] Running Tenant Management Service migrations...
docker-compose exec tenant-management-service npm run migrate

echo [INFO] Running Subscription Service migrations...
docker-compose exec subscription-service npm run migrate

echo [SUCCESS] Migrations completed!
goto END

:BUILD_SERVICES
echo [INFO] Building services...
docker-compose build --no-cache
echo [SUCCESS] Build completed!
goto END

:CLEANUP
echo [WARNING] This will remove all containers and volumes. Are you sure? (Y/N)
set /p response=
if /i "%response%"=="Y" (
    echo [INFO] Cleaning up...
    docker-compose down -v
    echo [SUCCESS] Cleanup completed!
) else (
    echo [INFO] Cleanup cancelled.
)
goto END

:HEALTH_CHECK
echo [INFO] Checking service health...
echo.

echo [INFO] Tenant Management Service:
curl -s http://localhost:3005/ping >nul 2>&1
if errorlevel 1 (
    echo [ERROR] X Tenant Management Service is not responding
) else (
    echo [SUCCESS] √ Tenant Management Service is healthy
)

echo.
echo [INFO] Subscription Service:
curl -s http://localhost:3002/ping >nul 2>&1
if errorlevel 1 (
    echo [ERROR] X Subscription Service is not responding
) else (
    echo [SUCCESS] √ Subscription Service is healthy
)

echo.
echo [INFO] PostgreSQL (Tenant):
docker-compose exec -T postgres-tenant-management pg_isready -U postgres >nul 2>&1
if errorlevel 1 (
    echo [ERROR] X PostgreSQL Tenant DB is not ready
) else (
    echo [SUCCESS] √ PostgreSQL Tenant DB is ready
)

echo.
echo [INFO] PostgreSQL (Subscription):
docker-compose exec -T postgres-subscription pg_isready -U postgres >nul 2>&1
if errorlevel 1 (
    echo [ERROR] X PostgreSQL Subscription DB is not ready
) else (
    echo [SUCCESS] √ PostgreSQL Subscription DB is ready
)

echo.
echo [INFO] Redis:
docker-compose exec -T redis redis-cli ping >nul 2>&1
if errorlevel 1 (
    echo [ERROR] X Redis is not ready
) else (
    echo [SUCCESS] √ Redis is ready
)
goto END

:SHELL_ACCESS
if "%~2"=="" (
    echo [ERROR] Please specify a service: tenant-management-service, subscription-service, postgres-tenant-management, postgres-subscription, redis
    exit /b 1
)

echo [INFO] Opening shell for %~2...
docker-compose exec %~2 sh
goto END

:SHOW_HELP
echo ARC SaaS Docker Management Script for Windows
echo.
echo Usage: docker-start.bat [command]
echo.
echo Commands:
echo   start               Start all services (default)
echo   start-db            Start only databases (PostgreSQL and Redis)
echo   start-services      Start only application services
echo   stop                Stop all services
echo   restart             Restart all services
echo   status              Show service status
echo   logs [service]      Show logs (optionally for specific service)
echo   migrate             Run database migrations
echo   build               Build/rebuild services
echo   cleanup             Remove all containers and volumes
echo   health              Check service health
echo   shell ^<service^>     Open shell in service container
echo   help                Show this help message
echo.
echo Examples:
echo   docker-start.bat start
echo   docker-start.bat logs tenant-management-service
echo   docker-start.bat shell postgres-tenant-management
echo   docker-start.bat migrate
echo.
goto END

:END
endlocal
