# Laravel Sync Backend - Installation Guide

## Prerequisites

- PHP 8.2 or higher
- Composer
- MySQL 8.0 or higher
- Git

## Installation Steps

### 1. Install Composer Dependencies

```bash
cd laravel_sync
composer install
```

If you don't have a `composer.json` file yet, create one:

```bash
composer init
```

Then install Laravel and required packages:

```bash
composer require laravel/framework:^11.0
composer require laravel/sanctum
composer require guzzlehttp/guzzle
```

### 2. Create Environment File

```bash
cp .env.example .env
```

Or create `.env` manually with these settings:

```env
APP_NAME="Matrix Accounts Sync"
APP_ENV=local
APP_KEY=
APP_DEBUG=true
APP_URL=http://localhost:8000

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=matrix_accounts_sync
DB_USERNAME=root
DB_PASSWORD=

CACHE_DRIVER=file
QUEUE_CONNECTION=sync
SESSION_DRIVER=file
SESSION_LIFETIME=120

SANCTUM_STATEFUL_DOMAINS=localhost,127.0.0.1
```

### 3. Generate Application Key

```bash
php artisan key:generate
```

### 4. Create Database

```sql
CREATE DATABASE matrix_accounts_sync CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

### 5. Run Migrations

```bash
php artisan migrate
```

### 6. Publish Sanctum Configuration (if needed)

```bash
php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"
```

### 7. Start Development Server

```bash
php artisan serve
```

The API will be available at: `http://localhost:8000`

## Testing the API

### 1. Register a User

```bash
curl -X POST http://localhost:8000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "full_name": "Test User",
    "password": "password123"
  }'
```

### 2. Login

```bash
curl -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123",
    "device_id": "test-device-001"
  }'
```

Save the token from the response.

### 3. Test Sync Status

```bash
curl -X GET "http://localhost:8000/api/sync/status?company_id=1&device_id=test-device-001" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

## Project Structure

```
laravel_sync/
├── app/
│   ├── Http/
│   │   └── Controllers/
│   │       └── Api/
│   │           ├── AuthController.php
│   │           ├── SyncController.php
│   │           └── PartyController.php
│   ├── Models/
│   │   ├── Company.php
│   │   ├── User.php
│   │   ├── Party.php
│   │   ├── Product.php
│   │   ├── SyncChange.php
│   │   ├── SyncVersion.php
│   │   └── DeviceSyncStatus.php
│   └── Services/
│       └── SyncService.php
├── database/
│   └── migrations/
│       ├── 2026_01_01_000001_create_companies_table.php
│       ├── 2026_01_01_000002_create_users_table.php
│       ├── ... (18+ migration files)
│       ├── 2026_01_01_000020_create_sync_changes_table.php
│       └── 2026_01_01_000021_create_device_sync_status_table.php
├── routes/
│   └── api.php
├── .env
├── composer.json
└── artisan
```

## API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login
- `POST /api/auth/logout` - Logout
- `GET /api/auth/user` - Get current user

### Sync
- `POST /api/sync/pull` - Pull changes from server
- `POST /api/sync/push` - Push changes to server
- `GET /api/sync/status` - Get sync status

### Data (Example: Parties)
- `GET /api/parties` - List all parties
- `POST /api/parties` - Create party
- `PUT /api/parties/{id}` - Update party
- `DELETE /api/parties/{id}` - Delete party

## Next Steps

1. **Create seed data** for testing
2. **Add more controllers** for Products, Invoices, etc.
3. **Implement conflict resolution** in SyncService
4. **Add validation rules** for all requests
5. **Write tests** for API endpoints
6. **Set up Redis** for caching (optional)
7. **Configure queues** for background sync (optional)

## Troubleshooting

### Migration Errors

If you get foreign key errors, ensure migrations run in the correct order (they're numbered).

### Authentication Issues

Make sure to:
1. Run `php artisan migrate` to create tables
2. Include the token in the `Authorization: Bearer {token}` header

### Database Connection

Check your `.env` file has correct database credentials.

## Documentation

See the following files for more details:
- [ARCHITECTURE.md](ARCHITECTURE.md) - Complete system architecture
- [PROJECT_PLAN.md](PROJECT_PLAN.md) - Project roadmap
- [DATABASE_SCHEMA.md](DATABASE_SCHEMA.md) - Database design

---

**Last Updated**: January 12, 2026
