# 📦 Docker Setup Files Summary

Tóm tắt tất cả các files Docker đã được tạo cho ARC SaaS project.

## 📋 Danh Sách Files

### 1. **docker-compose.yml** ⭐
**Production docker-compose configuration**

- Chứa cấu hình cho tất cả services:
  - `postgres-tenant-management`: PostgreSQL cho Tenant Management
  - `postgres-subscription`: PostgreSQL cho Subscription
  - `redis`: Redis cache và session store
  - `tenant-management-service`: Tenant Management microservice
  - `subscription-service`: Subscription microservice
  - `pgadmin`: Database management UI
  - `redis-commander`: Redis management UI

**Cách dùng:**
```bash
docker-compose up -d
```

---

### 2. **docker-compose.dev.yml** 🛠️
**Development docker-compose configuration**

Khác biệt với production:
- Hot reload enabled
- Debug ports exposed (9229, 9230)
- Source code mounted as volumes
- Mailhog cho email testing
- Development passwords và configs

**Cách dùng:**
```bash
docker-compose -f docker-compose.dev.yml up -d
```

---

### 3. **.env.docker.example** 📝
**Environment variables template**

Template chứa tất cả environment variables cần thiết:
- Database credentials
- Redis configuration
- JWT secrets
- Service ports
- AWS configuration
- IDP (Identity Provider) settings

**Cách dùng:**
```bash
cp .env.docker.example .env.docker
# Sửa các giá trị trong .env.docker
```

---

### 4. **docker-start.sh** 🐧
**Bash script for Linux/Mac**

Script tiện ích với các commands:
- `start`: Start all services
- `start-db`: Start databases only
- `stop`: Stop services
- `logs`: View logs
- `migrate`: Run migrations
- `health`: Health check
- `shell`: Shell access
- `cleanup`: Remove all

**Cách dùng:**
```bash
chmod +x docker-start.sh
./docker-start.sh start
./docker-start.sh migrate
./docker-start.sh health
```

---

### 5. **docker-start.bat** 🪟
**Batch script for Windows**

Windows version của docker-start.sh với tất cả các commands tương tự.

**Cách dùng:**
```cmd
docker-start.bat start
docker-start.bat migrate
docker-start.bat health
```

---

### 6. **.dockerignore** 🚫
**Docker build optimization**

Loại trừ các files không cần thiết khỏi Docker build context:
- node_modules
- Test files
- Documentation
- IDE configs
- Git files
- Logs

**Lợi ích:**
- Giảm build time
- Giảm image size
- Faster builds

---

### 7. **Makefile** ⚙️
**Make commands for easy management**

Cross-platform commands sử dụng `make`:
```bash
make start          # Start services
make migrate        # Run migrations
make health         # Health check
make logs           # View logs
make shell-tenant   # Shell access
make quick-start    # Start + migrate + health
```

**Cách dùng:**
```bash
make help           # Show all commands
make quick-start    # Quick setup
make dev           # Development mode
```

---

### 8. **DOCKER_SETUP.md** 📚
**Comprehensive Docker documentation**

Chi tiết về:
- System requirements
- Setup instructions
- Service management
- Database migrations
- Troubleshooting
- Architecture overview
- Security notes
- Development tips

---

### 9. **QUICK_START.md** 🚀
**Quick start guide**

Hướng dẫn nhanh 5 phút để:
- Start services
- Run migrations
- Access APIs
- Common commands
- Troubleshooting quick fixes

---

## 🎯 Workflow Đề Xuất

### Production Deployment

```bash
# 1. Clone và setup
git clone https://github.com/sourcefuse/arc-saas.git
cd arc-saas

# 2. Configure environment
cp .env.docker.example .env.docker
# Edit .env.docker với production values

# 3. Start services
docker-compose up -d

# 4. Run migrations
docker-compose exec tenant-management-service npm run migrate
docker-compose exec subscription-service npm run migrate

# 5. Health check
curl http://localhost:3005/ping
curl http://localhost:3002/ping
```

### Development Workflow

```bash
# 1. Start development environment
docker-compose -f docker-compose.dev.yml up -d

# 2. Run migrations
docker-compose -f docker-compose.dev.yml exec tenant-management-service-dev npm run migrate
docker-compose -f docker-compose.dev.yml exec subscription-service-dev npm run migrate

# 3. View logs
docker-compose -f docker-compose.dev.yml logs -f

# 4. Debug
# Attach VS Code debugger to ports 9229 and 9230
```

### Using Helper Scripts

**Linux/Mac:**
```bash
chmod +x docker-start.sh
./docker-start.sh quick-start
```

**Windows:**
```cmd
docker-start.bat start
docker-start.bat migrate
docker-start.bat health
```

**Using Makefile:**
```bash
make quick-start
make logs-tenant
make shell-tenant
```

---

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                      ARC SaaS Stack                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌────────────────────┐        ┌────────────────────┐      │
│  │ Tenant Management  │        │ Subscription       │      │
│  │ Service            │        │ Service            │      │
│  │ :3005              │        │ :3002              │      │
│  └─────────┬──────────┘        └─────────┬──────────┘      │
│            │                              │                 │
│            ▼                              ▼                 │
│  ┌────────────────────┐        ┌────────────────────┐      │
│  │ PostgreSQL         │        │ PostgreSQL         │      │
│  │ tenant_management  │        │ subscription_db    │      │
│  │ :5432              │        │ :5433              │      │
│  └────────────────────┘        └────────────────────┘      │
│                                                             │
│            ┌────────────────────┐                           │
│            │ Redis              │                           │
│            │ :6379              │                           │
│            └────────────────────┘                           │
│                                                             │
│  ┌────────────────────┐        ┌────────────────────┐      │
│  │ pgAdmin            │        │ Redis Commander    │      │
│  │ :5050              │        │ :8081              │      │
│  └────────────────────┘        └────────────────────┘      │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔧 Port Mapping

| Service | Internal Port | External Port | Purpose |
|---------|---------------|---------------|---------|
| Tenant Management | 3005 | 3005 | REST API |
| Subscription | 3002 | 3002 | REST API |
| PostgreSQL (Tenant) | 5432 | 5432 | Database |
| PostgreSQL (Subscription) | 5432 | 5433 | Database |
| Redis | 6379 | 6379 | Cache |
| pgAdmin | 80 | 5050 | DB UI |
| Redis Commander | 8081 | 8081 | Redis UI |
| Tenant Debug | 9229 | 9229 | Debug (dev) |
| Subscription Debug | 9229 | 9230 | Debug (dev) |
| Mailhog SMTP | 1025 | 1025 | Email (dev) |
| Mailhog UI | 8025 | 8025 | Email UI (dev) |

---

## 📊 Environment Variables

### Critical Variables (MUST CHANGE)

```bash
# Security
JWT_SECRET=<change-this-256-bit-random-string>
POSTGRES_*_PASSWORD=<strong-password>
REDIS_PASSWORD=<strong-password>

# Database
DB_HOST=postgres-tenant-management
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=<your-password>
DB_DATABASE=tenant_management_db

# Redis
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_PASSWORD=<your-password>
```

### Optional Variables

```bash
# AWS (if using EventBridge/SQS)
AWS_REGION=us-east-1
AWS_ACCESS_KEY_ID=<your-key>
AWS_SECRET_ACCESS_KEY=<your-secret>

# Identity Providers
KEYCLOAK_HOST=<keycloak-url>
AUTH0_DOMAIN=<auth0-domain>
GOOGLE_CLIENT_ID=<google-client-id>
```

---

## 🔐 Security Checklist

### Before Production Deployment

- [ ] Change all default passwords
- [ ] Set strong JWT_SECRET (min 32 characters)
- [ ] Use environment-specific .env files
- [ ] Disable management tools (pgAdmin, Redis Commander)
- [ ] Enable SSL/TLS for databases
- [ ] Configure firewall rules
- [ ] Set up volume backups
- [ ] Use secrets management (AWS Secrets Manager, Vault)
- [ ] Review and restrict network access
- [ ] Enable container security scanning

---

## 🧪 Testing Setup

```bash
# Run tests in containers
docker-compose exec tenant-management-service npm test
docker-compose exec subscription-service npm test

# Run with coverage
docker-compose exec tenant-management-service npm run coverage
docker-compose exec subscription-service npm run coverage

# Using helper scripts
./docker-start.sh shell tenant-management-service
npm test

# Using Makefile
make test-all
make coverage-tenant
```

---

## 📈 Monitoring

### Health Endpoints

```bash
# Tenant Management
curl http://localhost:3005/ping

# Subscription
curl http://localhost:3002/ping

# Or use helper
./docker-start.sh health
make health
```

### Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f tenant-management-service

# Using helpers
./docker-start.sh logs tenant-management-service
make logs-tenant
```

### Stats

```bash
docker stats
make stats
```

---

## 🎓 Learning Resources

| Resource | Description |
|----------|-------------|
| [QUICK_START.md](./QUICK_START.md) | 5-minute quick start |
| [DOCKER_SETUP.md](./DOCKER_SETUP.md) | Comprehensive guide |
| [Tenant Management README](./services/tenant-management-service/README.md) | Service docs |
| [Subscription README](./services/subscription-service/README.md) | Service docs |
| [LoopBack 4 Docs](https://loopback.io/doc/en/lb4/) | Framework docs |

---

## 🤝 Contributing

Khi thêm features mới:

1. Update docker-compose.yml nếu cần services mới
2. Update .env.docker.example với variables mới
3. Update DOCKER_SETUP.md với instructions
4. Test với cả production và dev configs
5. Update Makefile với commands mới

---

## 📝 Notes

### Why Multiple Setup Options?

- **docker-compose.yml**: Production, simple, direct
- **docker-start.sh/.bat**: User-friendly scripts
- **Makefile**: Developer-friendly, IDE integration

### When to Use Which?

- **Quick test**: `docker-compose up -d`
- **Production**: `docker-compose.yml` với custom .env
- **Development**: `docker-compose.dev.yml`
- **CI/CD**: `docker-compose.yml` + environment injection
- **Daily use**: Helper scripts hoặc Makefile

---

## ✅ Checklist

### Initial Setup
- [ ] Docker và Docker Compose installed
- [ ] .env.docker configured
- [ ] Services started: `make start`
- [ ] Migrations run: `make migrate`
- [ ] Health check passed: `make health`

### Verification
- [ ] Tenant Management API accessible: http://localhost:3005/explorer
- [ ] Subscription API accessible: http://localhost:3002/explorer
- [ ] pgAdmin accessible: http://localhost:5050
- [ ] Redis Commander accessible: http://localhost:8081
- [ ] Can create leads và tenants
- [ ] Can create subscriptions và plans

---

## 🎉 Summary

Tất cả các files đã được setup để:
- ✅ Chạy production environment
- ✅ Chạy development environment với hot reload
- ✅ Easy management với helper scripts
- ✅ Database migrations
- ✅ Health checks
- ✅ Monitoring và debugging
- ✅ Cross-platform support (Windows/Linux/Mac)

**Bạn đã sẵn sàng để chạy ARC SaaS!** 🚀
