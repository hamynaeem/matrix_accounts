# Matrix Accounts - Laravel Sync Backend

Cloud synchronization backend for Matrix Accounts Flutter application.

## 📋 Documentation

- [Project Plan](PROJECT_PLAN.md) - Complete project overview and architecture
- [Tasks & Checklist](TASKS.md) - Detailed task list with progress tracking
- [Database Schema](DATABASE_SCHEMA.md) - Complete database design
- [API Documentation](API_DOCUMENTATION.md) - API endpoints and usage (coming soon)

## 🚀 Quick Start

### Prerequisites

- PHP 8.2+
- Composer
- MySQL 8.0+
- Redis
- Node.js & NPM (for assets)

### Installation

```bash
# Clone repository
cd laravel_sync

# Install dependencies
composer install

# Copy environment file
cp .env.example .env

# Generate application key
php artisan key:generate

# Configure database in .env
# DB_DATABASE=matrix_accounts
# DB_USERNAME=root
# DB_PASSWORD=

# Run migrations
php artisan migrate

# Seed database (optional)
php artisan db:seed

# Start development server
php artisan serve
```

## 📦 Project Structure

```
laravel_sync/
├── app/
│   ├── Http/
│   │   ├── Controllers/
│   │   │   └── Api/
│   │   │       ├── SyncController.php
│   │   │       ├── AuthController.php
│   │   │       └── ...
│   │   └── Resources/
│   ├── Models/
│   │   ├── Company.php
│   │   ├── User.php
│   │   ├── SyncChange.php
│   │   └── ...
│   └── Services/
│       └── SyncService.php
├── database/
│   └── migrations/
├── routes/
│   └── api.php
└── tests/
```

## 🔧 Configuration

Key environment variables:

```env
APP_URL=http://localhost:8000
DB_CONNECTION=mysql
DB_DATABASE=matrix_accounts
REDIS_HOST=127.0.0.1
SANCTUM_STATEFUL_DOMAINS=localhost
```

## 📱 API Endpoints

### Authentication
```
POST /api/auth/register
POST /api/auth/login
POST /api/auth/logout
```

### Sync
```
POST /api/sync/pull
POST /api/sync/push
GET  /api/sync/status
```

### Data
```
GET /api/companies
GET /api/parties
GET /api/products
GET /api/invoices
```

See [API Documentation](API_DOCUMENTATION.md) for details.

## 🧪 Testing

```bash
# Run all tests
php artisan test

# Run specific test suite
php artisan test --testsuite=Feature

# With coverage
php artisan test --coverage
```

## 📊 Current Status

**Phase**: Planning  
**Progress**: 0%  
**Next Milestone**: Phase 1 - Foundation Setup

See [TASKS.md](TASKS.md) for detailed progress.

## 🤝 Contributing

This is a private project for Matrix Accounts application.

## 📝 License

Proprietary - All rights reserved

---

**Created**: December 13, 2025  
**Version**: 1.0.0
