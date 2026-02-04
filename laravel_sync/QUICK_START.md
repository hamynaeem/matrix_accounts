# Quick Start Guide - Matrix Accounts Sync Backend

## 📋 Prerequisites

- PHP 8.2+
- Composer
- MySQL 8.0+
- Git (optional)

## 🚀 5-Minute Setup

### Step 1: Navigate to Project
```bash
cd g:\Work-Flutter\matrix_accounts\laravel_sync
```

### Step 2: Install Laravel (if not already installed)

If you don't have Laravel installed yet:

```bash
composer create-project laravel/laravel . "11.*"
```

Or if the folder already has Laravel:

```bash
composer install
```

### Step 3: Configure Environment

Create `.env` file (or edit existing):

```bash
copy .env.example .env
```

Edit `.env`:
```env
APP_NAME="Matrix Accounts Sync"
APP_URL=http://localhost:8000

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=matrix_accounts_sync
DB_USERNAME=root
DB_PASSWORD=your_password_here
```

Generate app key:
```bash
php artisan key:generate
```

### Step 4: Create Database

```sql
mysql -u root -p
CREATE DATABASE matrix_accounts_sync CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
exit;
```

### Step 5: Run Migrations

```bash
php artisan migrate
```

You should see:
```
Migration table created successfully.
Migrating: 2026_01_01_000001_create_companies_table
Migrated:  2026_01_01_000001_create_companies_table
...
(22 migrations total)
```

### Step 6: Start Server

```bash
php artisan serve
```

Server runs at: `http://localhost:8000`

## ✅ Test the API

### Test 1: Health Check

Open browser: `http://localhost:8000`

You should see Laravel welcome page.

### Test 2: Register User

```bash
curl -X POST http://localhost:8000/api/auth/register ^
  -H "Content-Type: application/json" ^
  -d "{\"email\":\"admin@example.com\",\"full_name\":\"Admin User\",\"password\":\"password123\"}"
```

Response:
```json
{
  "success": true,
  "message": "User registered successfully",
  "user": {...},
  "token": "1|xxxxx..."
}
```

**Save the token!**

### Test 3: Login

```bash
curl -X POST http://localhost:8000/api/auth/login ^
  -H "Content-Type: application/json" ^
  -d "{\"email\":\"admin@example.com\",\"password\":\"password123\",\"device_id\":\"test-device-001\"}"
```

### Test 4: Create Company (using token)

First, you need to add a company to the database manually or via seed:

```sql
mysql -u root -p matrix_accounts_sync
INSERT INTO companies (subscriber_id, name, primary_currency, is_active, created_at, updated_at) 
VALUES (1, 'Test Company', 'USD', 1, NOW(), NOW());

INSERT INTO company_user (company_id, user_id, role, is_active, created_at, updated_at)
VALUES (1, 1, 'admin', 1, NOW(), NOW());
```

### Test 5: Sync Status

```bash
curl -X GET "http://localhost:8000/api/sync/status?company_id=1&device_id=test-device-001" ^
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

Response:
```json
{
  "success": true,
  "status": {
    "device_id": "test-device-001",
    "last_sync_version": 0,
    "current_version": 0,
    "pending_changes": 0,
    "is_synced": true
  }
}
```

### Test 6: Create Party

```bash
curl -X POST http://localhost:8000/api/parties ^
  -H "Authorization: Bearer YOUR_TOKEN_HERE" ^
  -H "Content-Type: application/json" ^
  -d "{\"company_id\":1,\"name\":\"Test Customer\",\"party_type\":\"customer\",\"phone\":\"1234567890\"}"
```

## 📁 Project Structure

```
laravel_sync/
├── app/
│   ├── Http/Controllers/Api/     # API Controllers
│   ├── Models/                   # Eloquent Models  
│   └── Services/                 # Business Logic
├── database/
│   └── migrations/               # Database Schema
├── routes/
│   └── api.php                   # API Routes
├── ARCHITECTURE.md               # Complete docs
├── INSTALLATION.md               # Detailed setup
└── IMPLEMENTATION_SUMMARY.md     # What was built
```

## 🔧 Common Issues

### Issue: Migration fails

**Solution**: Check database exists and credentials in `.env`

```bash
php artisan config:clear
php artisan migrate:fresh
```

### Issue: 500 error on API

**Solution**: Check Laravel logs

```bash
tail -f storage/logs/laravel.log
```

### Issue: Token not working

**Solution**: Ensure using correct header format

```
Authorization: Bearer YOUR_TOKEN_HERE
```

### Issue: CORS errors (if testing from browser)

**Solution**: Install and configure Laravel CORS

```bash
composer require fruitcake/laravel-cors
php artisan config:publish cors
```

## 🎯 What's Next?

### 1. Create Seed Data

Create `database/seeders/DatabaseSeeder.php`:

```php
public function run()
{
    // Create test company
    $company = Company::create([
        'subscriber_id' => 1,
        'name' => 'Demo Company',
        'primary_currency' => 'USD',
    ]);

    // Create test user
    $user = User::create([
        'email' => 'demo@example.com',
        'full_name' => 'Demo User',
        'password' => Hash::make('password'),
    ]);

    // Link user to company
    $company->users()->attach($user->id, [
        'role' => 'admin',
        'is_active' => true,
    ]);
}
```

Run: `php artisan db:seed`

### 2. Test Full Sync Flow

1. Create party on device A (Flutter app)
2. Push to server
3. Pull from device B
4. Verify party appears

### 3. Deploy to Production

- Set `APP_ENV=production` in `.env`
- Set `APP_DEBUG=false`
- Use production database
- Set up HTTPS
- Configure firewall

### 4. Add More Features

- Product CRUD controller
- Invoice controller
- Payment controllers
- Batch sync operations
- WebSocket for real-time sync

## 📚 Documentation

- [ARCHITECTURE.md](ARCHITECTURE.md) - Complete system design
- [INSTALLATION.md](INSTALLATION.md) - Detailed installation
- [IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md) - What was built
- [DATABASE_SCHEMA.md](DATABASE_SCHEMA.md) - Database design

## 🆘 Get Help

Check the logs:
```bash
# Laravel logs
tail -f storage/logs/laravel.log

# PHP errors
tail -f /var/log/php_errors.log
```

Clear caches:
```bash
php artisan config:clear
php artisan cache:clear
php artisan route:clear
```

## ✨ Features Ready

- ✅ User authentication (Sanctum)
- ✅ Multi-tenant (company-based)
- ✅ Delta sync (version tracking)
- ✅ Device management
- ✅ Party CRUD
- ✅ Conflict detection
- ✅ Soft deletes
- ✅ Audit trail

## 🎉 Success!

Your Laravel sync backend is ready to use!

API Base URL: `http://localhost:8000/api`

Start syncing your Flutter app! 🚀

---

**Version**: 1.0.0  
**Date**: January 12, 2026
