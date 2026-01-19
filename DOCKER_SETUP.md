# ARC SaaS Docker Setup Guide

Hướng dẫn chạy ARC SaaS Control Plane bằng Docker Compose.

## 📋 Yêu Cầu Hệ Thống

- Docker Engine 20.10+
- Docker Compose 2.0+
- RAM: Tối thiểu 4GB (khuyến nghị 8GB)
- Disk: Tối thiểu 10GB free space

## 🚀 Cách Sử Dụng

### 1. Clone Repository

```bash
git clone https://github.com/sourcefuse/arc-saas.git
cd arc-saas
```

### 2. Cấu Hình Environment Variables

Tạo file `.env.docker` từ file mẫu:

```bash
cp .env.docker.example .env.docker
```

Chỉnh sửa các biến môi trường trong `.env.docker`:

```bash
# Quan trọng: Thay đổi các giá trị sau trong production
- JWT_SECRET: Secret key cho JWT (tối thiểu 32 ký tự)
- POSTGRES_*_PASSWORD: Mật khẩu databases
- REDIS_PASSWORD: Mật khẩu Redis
```

### 3. Build và Chạy Services

#### Option A: Chạy tất cả services

```bash
docker-compose up -d
```

#### Option B: Chạy từng service cụ thể

```bash
# Chỉ chạy databases
docker-compose up -d postgres-tenant-management postgres-subscription redis

# Chạy tenant management service
docker-compose up -d tenant-management-service

# Chạy subscription service
docker-compose up -d subscription-service
```

#### Option C: Build lại images

```bash
# Build lại tất cả
docker-compose build

# Build specific service
docker-compose build tenant-management-service
```

### 4. Kiểm Tra Logs

```bash
# Xem logs tất cả services
docker-compose logs -f

# Xem logs specific service
docker-compose logs -f tenant-management-service
docker-compose logs -f subscription-service
docker-compose logs -f postgres-tenant-management
docker-compose logs -f redis
```

### 5. Chạy Database Migrations

#### Tenant Management Service Migrations

```bash
# Enter vào container
docker-compose exec tenant-management-service sh

# Chạy migrations
npm run migrate

# Exit container
exit
```

#### Subscription Service Migrations

```bash
# Enter vào container
docker-compose exec subscription-service sh

# Chạy migrations
npm run migrate

# Exit container
exit
```

**Hoặc chạy trực tiếp:**

```bash
docker-compose exec tenant-management-service npm run migrate
docker-compose exec subscription-service npm run migrate
```

## 🔍 Kiểm Tra Services

### Health Check Endpoints

```bash
# Tenant Management Service
curl http://localhost:3005/ping

# Subscription Service
curl http://localhost:3002/ping
```

### API Documentation (Swagger)

- **Tenant Management API**: http://localhost:3005/explorer
- **Subscription API**: http://localhost:3002/explorer

### Management Tools

- **pgAdmin**: http://localhost:5050
  - Email: `admin@example.com`
  - Password: `admin`

- **Redis Commander**: http://localhost:8081

## 📊 Quản Lý Database với pgAdmin

1. Mở http://localhost:5050
2. Login với credentials từ docker-compose
3. Add New Server:

**Tenant Management Database:**
- Name: `Tenant Management DB`
- Host: `postgres-tenant-management`
- Port: `5432`
- Username: `postgres`
- Password: `postgres_password`
- Database: `tenant_management_db`

**Subscription Database:**
- Name: `Subscription DB`
- Host: `postgres-subscription`
- Port: `5432`
- Username: `postgres`
- Password: `postgres_password`
- Database: `subscription_db`

## 🛑 Dừng và Xóa Services

### Dừng services (giữ nguyên data)

```bash
docker-compose stop
```

### Dừng và xóa containers (giữ nguyên volumes)

```bash
docker-compose down
```

### Xóa tất cả (bao gồm volumes - MẤT DATA!)

```bash
docker-compose down -v
```

### Xóa images

```bash
docker-compose down --rmi all
```

## 🔧 Troubleshooting

### 1. Service không start được

```bash
# Kiểm tra logs
docker-compose logs <service-name>

# Kiểm tra health check
docker-compose ps
```

### 2. Database connection failed

```bash
# Kiểm tra Postgres có chạy không
docker-compose exec postgres-tenant-management pg_isready -U postgres

# Kiểm tra Redis có chạy không
docker-compose exec redis redis-cli ping
```

### 3. Port đã bị sử dụng

Sửa ports trong `docker-compose.yml`:

```yaml
services:
  tenant-management-service:
    ports:
      - "3005:3005"  # Thay 3005 thành port khác, ví dụ "3015:3005"
```

### 4. Out of memory

Tăng memory cho Docker:
- Docker Desktop: Settings → Resources → Memory

### 5. Build lỗi

```bash
# Clean build
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### 6. Migrations failed

```bash
# Kiểm tra database schema
docker-compose exec postgres-tenant-management psql -U postgres -d tenant_management_db -c "\dn"

# Xem migration history
docker-compose exec postgres-tenant-management psql -U postgres -d tenant_management_db -c "SELECT * FROM migrations;"
```

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                     ARC SaaS Stack                      │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌──────────────────┐      ┌──────────────────┐       │
│  │ Tenant Mgmt      │      │ Subscription     │       │
│  │ Service          │      │ Service          │       │
│  │ Port: 3005       │      │ Port: 3002       │       │
│  └────────┬─────────┘      └────────┬─────────┘       │
│           │                         │                  │
│           │                         │                  │
│  ┌────────▼─────────┐      ┌────────▼─────────┐       │
│  │ PostgreSQL       │      │ PostgreSQL       │       │
│  │ (Tenant DB)      │      │ (Subscription DB)│       │
│  │ Port: 5432       │      │ Port: 5433       │       │
│  └──────────────────┘      └──────────────────┘       │
│                                                         │
│           ┌──────────────────┐                         │
│           │ Redis Cache      │                         │
│           │ Port: 6379       │                         │
│           └──────────────────┘                         │
│                                                         │
│  ┌──────────────────┐      ┌──────────────────┐       │
│  │ pgAdmin          │      │ Redis Commander  │       │
│  │ Port: 5050       │      │ Port: 8081       │       │
│  └──────────────────┘      └──────────────────┘       │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## 📦 Services Port Mapping

| Service | Internal Port | External Port | Description |
|---------|---------------|---------------|-------------|
| Tenant Management Service | 3005 | 3005 | Tenant & Lead Management API |
| Subscription Service | 3002 | 3002 | Subscription & Billing API |
| PostgreSQL (Tenant) | 5432 | 5432 | Tenant DB |
| PostgreSQL (Subscription) | 5432 | 5433 | Subscription DB |
| Redis | 6379 | 6379 | Cache & Session Store |
| pgAdmin | 80 | 5050 | Database Management UI |
| Redis Commander | 8081 | 8081 | Redis Management UI |

## 🔐 Security Notes

### Production Deployment

**QUAN TRỌNG: Trong môi trường production:**

1. **Thay đổi tất cả passwords mặc định**
   ```bash
   JWT_SECRET=<random-256-bit-string>
   POSTGRES_*_PASSWORD=<strong-password>
   REDIS_PASSWORD=<strong-password>
   ```

2. **Disable management tools** (pgAdmin, Redis Commander)
   ```yaml
   # Comment out trong docker-compose.yml
   # pgadmin:
   # redis-commander:
   ```

3. **Sử dụng secrets management**
   - AWS Secrets Manager
   - HashiCorp Vault
   - Docker Secrets

4. **Enable TLS/SSL**
   - PostgreSQL SSL mode
   - Redis TLS
   - HTTPS cho services

5. **Restrict network access**
   ```yaml
   networks:
     arc-saas-network:
       internal: true  # Chỉ internal communication
   ```

6. **Volume backups**
   ```bash
   # Backup PostgreSQL
   docker-compose exec postgres-tenant-management pg_dump -U postgres tenant_management_db > backup.sql

   # Backup Redis
   docker-compose exec redis redis-cli --rdb /data/dump.rdb
   ```

## 📝 Development Tips

### Hot Reload (Development Mode)

Để enable hot reload cho development:

1. Mount source code vào container:
   ```yaml
   services:
     tenant-management-service:
       volumes:
         - ./services/tenant-management-service/src:/home/node/app/services/tenant-management-service/src
       command: npm run dev
   ```

2. Install nodemon đã có sẵn trong package.json

### Debug Mode

```yaml
services:
  tenant-management-service:
    environment:
      LOG_LEVEL: debug
      NODE_ENV: development
    ports:
      - "3005:3005"
      - "9229:9229"  # Node debugger port
    command: node --inspect=0.0.0.0:9229 .
```

## 🧪 Testing

```bash
# Run tests trong container
docker-compose exec tenant-management-service npm test
docker-compose exec subscription-service npm test

# Run coverage
docker-compose exec tenant-management-service npm run coverage
```

## 📚 Additional Resources

- [ARC SaaS Documentation](https://sourcefuse.github.io/arc-docs/arc-api-docs)
- [LoopBack 4 Documentation](https://loopback.io/doc/en/lb4/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)

## 🤝 Contributing

Xem [CONTRIBUTING.md](https://github.com/sourcefuse/arc-saas/blob/master/.github/CONTRIBUTING.md)

## 📄 License

MIT License - xem [LICENSE](./LICENSE)
