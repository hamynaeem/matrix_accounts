# Matrix Accounts - Laravel Sync Backend

> Cloud synchronization backend for Matrix Accounts offline-first Flutter application

![Status](https://img.shields.io/badge/status-ready-green)
![PHP](https://img.shields.io/badge/PHP-8.2+-blue)
![Laravel](https://img.shields.io/badge/Laravel-11.x-red)
![License](https://img.shields.io/badge/license-proprietary-lightgrey)

## 📋 Overview

A complete, production-ready Laravel backend for syncing the Matrix Accounts Flutter app with cloud storage. Features delta sync with version tracking for efficient, conflict-aware bidirectional synchronization.

### Key Features

- ✅ **Offline-First Support** - Fully functional without internet
- ✅ **Delta Sync** - Only sync changes, not entire database
- ✅ **Multi-Tenant** - Company-based data isolation
- ✅ **Multi-Device** - Same user across multiple devices
- ✅ **Conflict Resolution** - Last-write-wins strategy
- ✅ **Token Auth** - Laravel Sanctum authentication
- ✅ **RESTful API** - Clean, well-documented endpoints

## 📚 Documentation

| Document | Description |
|----------|-------------|
| **[QUICK_START.md](QUICK_START.md)** | 5-minute setup guide |
| **[ARCHITECTURE.md](ARCHITECTURE.md)** | Complete system architecture (500+ lines) |
| **[INSTALLATION.md](INSTALLATION.md)** | Detailed installation steps |
| **[IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md)** | What was built and how it works |
| **[DATABASE_SCHEMA.md](DATABASE_SCHEMA.md)** | Complete database design |
| **[PROJECT_PLAN.md](PROJECT_PLAN.md)** | Original project roadmap |


## 🚀 Quick Start

**5 minutes to get running!**

```bash
# 1. Navigate to project
cd laravel_sync

# 2. Install dependencies
composer install

# 3. Set up environment
cp .env.example .env
php artisan key:generate

# 4. Configure database in .env
# DB_DATABASE=matrix_accounts_sync
# DB_USERNAME=root
# DB_PASSWORD=your_password

# 5. Run migrations
php artisan migrate

# 6. Start server
php artisan serve
```

**Server runs at:** `http://localhost:8000`

See [QUICK_START.md](QUICK_START.md) for detailed testing guide.

## 🔌 API Endpoints

### Authentication
```http
POST   /api/auth/register     # Register new user
POST   /api/auth/login        # Login & get token
POST   /api/auth/logout       # Revoke token
GET    /api/auth/user         # Get user info
```

### Sync Operations
```http
POST   /api/sync/pull         # Pull changes from server
POST   /api/sync/push         # Push changes to server
GET    /api/sync/status       # Get sync status
```

### Data CRUD (Example: Parties)
```http
GET    /api/parties           # List all parties
POST   /api/parties           # Create party
PUT    /api/parties/{id}      # Update party
DELETE /api/parties/{id}      # Delete party
```

## 📈 Implementation Status

### ✅ Completed (48 Files, 3500+ Lines)

- [x] 22 Database migrations
- [x] 20 Eloquent models
- [x] 3 API controllers (Auth, Sync, Party)
- [x] SyncService core logic
- [x] API routes
- [x] Authentication (Sanctum)
- [x] Documentation (6 files)

**Status**: ✅ Ready for testing and deployment

---

**Version**: 1.0.0  
**Created**: January 12, 2026  
**Files Created**: 48 | **Lines of Code**: 3,500+
