# 🚀 ARC SaaS Quick Start Guide

Quick start guide để chạy ARC SaaS Control Plane với Docker trong 5 phút.

## ⚡ Quick Start (Windows/Linux/Mac)

### 1️⃣ Prerequisites

```bash
# Kiểm tra Docker
docker --version
docker-compose --version
```

Nếu chưa có, cài đặt [Docker Desktop](https://www.docker.com/products/docker-desktop).

### 2️⃣ Clone & Setup

```bash
# Clone repository
git clone https://github.com/sourcefuse/arc-saas.git
cd arc-saas

# Copy environment file (optional)
cp .env.docker.example .env.docker
```

### 3️⃣ Start Services

**Windows:**
```cmd
docker-start.bat start
```

**Linux/Mac:**
```bash
chmod +x docker-start.sh
./docker-start.sh start
```

**Hoặc dùng docker-compose trực tiếp:**
```bash
docker-compose up -d
```

### 4️⃣ Run Migrations

**Windows:**
```cmd
docker-start.bat migrate
```

**Linux/Mac:**
```bash
./docker-start.sh migrate
```

**Hoặc:**
```bash
docker-compose exec tenant-management-service npm run migrate
docker-compose exec subscription-service npm run migrate
```

### 5️⃣ Verify Services

**Check status:**
```bash
# Windows
docker-start.bat status

# Linux/Mac
./docker-start.sh status

# Or
docker-compose ps
```

**Health check:**
```bash
curl http://localhost:3005/ping
curl http://localhost:3002/ping
```

## 🎯 Access Points

| Service | URL | Credentials |
|---------|-----|-------------|
| **Tenant Management API** | http://localhost:3005 | - |
| **Subscription API** | http://localhost:3002 | - |
| **Tenant Management Swagger** | http://localhost:3005/explorer | - |
| **Subscription Swagger** | http://localhost:3002/explorer | - |
| **pgAdmin** | http://localhost:5050 | admin@example.com / admin |
| **Redis Commander** | http://localhost:8081 | - |

## 📊 Database Connections (pgAdmin)

### Tenant Management Database
- **Host**: `postgres-tenant-management`
- **Port**: `5432`
- **Database**: `tenant_management_db`
- **Username**: `postgres`
- **Password**: `postgres_password`

### Subscription Database
- **Host**: `postgres-subscription`
- **Port**: `5432`
- **Database**: `subscription_db`
- **Username**: `postgres`
- **Password**: `postgres_password`

## 🛠️ Common Commands

### Windows (docker-start.bat)

```cmd
REM Start all services
docker-start.bat start

REM Start only databases
docker-start.bat start-db

REM Stop services
docker-start.bat stop

REM Restart services
docker-start.bat restart

REM View logs
docker-start.bat logs
docker-start.bat logs tenant-management-service

REM Run migrations
docker-start.bat migrate

REM Health check
docker-start.bat health

REM Rebuild services
docker-start.bat build

REM Shell access
docker-start.bat shell tenant-management-service

REM Cleanup (remove all)
docker-start.bat cleanup
```

### Linux/Mac (docker-start.sh)

```bash
# Start all services
./docker-start.sh start

# Start only databases
./docker-start.sh start-db

# Stop services
./docker-start.sh stop

# Restart services
./docker-start.sh restart

# View logs
./docker-start.sh logs
./docker-start.sh logs tenant-management-service

# Run migrations
./docker-start.sh migrate

# Health check
./docker-start.sh health

# Rebuild services
./docker-start.sh build

# Shell access
./docker-start.sh shell tenant-management-service

# Cleanup (remove all)
./docker-start.sh cleanup
```

### Docker Compose Direct

```bash
# Start
docker-compose up -d

# Stop
docker-compose down

# Logs
docker-compose logs -f [service-name]

# Restart
docker-compose restart [service-name]

# Rebuild
docker-compose build --no-cache

# Remove all (including volumes)
docker-compose down -v
```

## 🔍 Troubleshooting

### Services không start?

```bash
# Check logs
docker-compose logs tenant-management-service
docker-compose logs subscription-service

# Check container status
docker-compose ps
```

### Database connection error?

```bash
# Verify databases are running
docker-compose exec postgres-tenant-management pg_isready -U postgres
docker-compose exec postgres-subscription pg_isready -U postgres

# Check Redis
docker-compose exec redis redis-cli ping
```

### Port already in use?

Sửa ports trong `docker-compose.yml`:
```yaml
ports:
  - "3015:3005"  # Change 3005 to 3015
```

### Need to reset everything?

```bash
# Windows
docker-start.bat cleanup

# Linux/Mac
./docker-start.sh cleanup

# Or
docker-compose down -v
docker-compose up -d
docker-start.bat migrate  # or ./docker-start.sh migrate
```

## 📚 API Examples

### Create a Lead (Tenant Management)

```bash
curl -X POST http://localhost:3005/leads \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "John",
    "lastName": "Doe",
    "email": "john.doe@example.com",
    "companyName": "Acme Corp"
  }'
```

### Get All Plans (Subscription)

```bash
curl http://localhost:3002/plans
```

### Create a Tenant

```bash
curl -X POST http://localhost:3005/tenants \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "name": "Acme Corporation",
    "key": "acme-corp",
    "status": 0
  }'
```

## 🎓 Development Mode

Để chạy với hot reload và debugging:

```bash
# Start development environment
docker-compose -f docker-compose.dev.yml up -d

# Services will be available at:
# - Tenant Management: http://localhost:3005 (debugger: 9229)
# - Subscription: http://localhost:3002 (debugger: 9230)
# - Mailhog UI: http://localhost:8025
```

### Debug với VS Code

Add to `.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "node",
      "request": "attach",
      "name": "Docker: Tenant Management",
      "remoteRoot": "/home/node/app/services/tenant-management-service",
      "localRoot": "${workspaceFolder}/services/tenant-management-service",
      "protocol": "inspector",
      "port": 9229,
      "restart": true,
      "sourceMaps": true
    },
    {
      "type": "node",
      "request": "attach",
      "name": "Docker: Subscription",
      "remoteRoot": "/home/node/app/services/subscription-service",
      "localRoot": "${workspaceFolder}/services/subscription-service",
      "protocol": "inspector",
      "port": 9230,
      "restart": true,
      "sourceMaps": true
    }
  ]
}
```

## 📖 Next Steps

- [Full Docker Setup Guide](./DOCKER_SETUP.md) - Chi tiết về cấu hình và architecture
- [Tenant Management Service](./services/tenant-management-service/README.md) - API documentation
- [Subscription Service](./services/subscription-service/README.md) - API documentation
- [ARC SaaS Documentation](https://sourcefuse.github.io/arc-docs/arc-api-docs) - Official docs

## 🆘 Need Help?

- Check logs: `docker-compose logs -f`
- Health check: `./docker-start.sh health` or `docker-start.bat health`
- Issues: https://github.com/sourcefuse/arc-saas/issues

## 🎉 Success!

Nếu bạn thấy:
- ✅ Tenant Management API: http://localhost:3005/explorer
- ✅ Subscription API: http://localhost:3002/explorer
- ✅ pgAdmin: http://localhost:5050
- ✅ Redis Commander: http://localhost:8081

**Chúc mừng! ARC SaaS đã sẵn sàng!** 🚀
