# Matrix Accounts - System Architecture & Sync Design

## Table of Contents
1. [Offline-First Application Overview](#offline-first-application-overview)
2. [Data Models](#data-models)
3. [Application Architecture](#application-architecture)
4. [Sync Strategy](#sync-strategy)
5. [Laravel Backend Design](#laravel-backend-design)

---

## Offline-First Application Overview

### Technology Stack
- **Frontend**: Flutter with Riverpod for state management
- **Local Database**: Isar (NoSQL embedded database)
- **Backend**: Laravel 11 with MySQL
- **Sync**: RESTful API with delta sync

### Key Characteristics
1. **Offline-First**: App works fully without internet connection
2. **Local-First Data**: All data stored in Isar database on device
3. **Background Sync**: Sync when connection available
4. **Multi-Device**: Same user can use multiple devices
5. **Multi-Tenant**: Multiple companies, each isolated

---

## Data Models

### Core Entities

#### 1. Company
```dart
- id (auto-increment)
- subscriberId (int)
- name (unique, indexed)
- primaryCurrency (string)
- financialYearStartMonth (int)
- createdAt (DateTime)
- isActive (bool)
```

#### 2. User
```dart
- id (auto-increment)
- email (unique, indexed)
- fullName (string)
- passwordHash (string)
- isActive (bool)
- createdAt (DateTime)
```

#### 3. CompanyUser (Many-to-Many)
```dart
- id (auto-increment)
- companyId (indexed)
- userId (indexed)
- role (indexed)
- userGroupId (nullable)
- isActive (bool)
```

#### 4. Party (Customers/Suppliers)
```dart
- id (auto-increment)
- companyId (indexed)
- name (indexed)
- partyType (enum: customer, supplier, both)
- customerClass (enum: retailer, wholesaler, other)
- phone, email, address
- openingBalance (double)
- creditLimit (double)
- paymentTermsDays (int)
- createdAt, isActive
```

#### 5. Product
```dart
- id (auto-increment)
- companyId (indexed)
- sku (indexed)
- name (indexed)
- categoryId (nullable)
- uomId (nullable)
- isTracked (bool)
- lastCost, salePrice (double)
- openingQty (double)
- isActive (bool)
```

#### 6. UnitOfMeasure
```dart
- id (auto-increment)
- name (indexed)
- abbrev (string)
```

#### 7. ItemCategory
```dart
- id (auto-increment)
- companyId (indexed)
- name (indexed)
- parentCategoryId (nullable)
```

#### 8. Transaction
```dart
- id (auto-increment)
- companyId (indexed)
- type (enum: sale, purchase, expense, receipt, payment, saleReturn, purchaseReturn)
- date (indexed)
- referenceNo (indexed)
- partyId (nullable)
- cashBankAccount (string)
- totalAmount (double)
- isPosted (bool)
- createdByUserId, createdAt
```

#### 9. TransactionLine
```dart
- id (auto-increment)
- transactionId (indexed)
- productId, expenseCategoryId, partyId (nullable)
- description
- quantity, unitPrice, lineAmount (double)
```

#### 10. Invoice
```dart
- id (auto-increment)
- companyId (indexed)
- transactionId (indexed)
- invoiceType (enum: sale, purchase)
- partyId (indexed)
- invoiceDate (indexed)
- dueDate (nullable)
- grandTotal (double)
- status (string)
```

#### 11. StockLedger
```dart
- id (auto-increment)
- companyId (indexed)
- productId (indexed)
- date (indexed)
- movementType (enum: inPurchase, outSale, inAdjustment, outAdjustment)
- quantityDelta, unitCost, totalCost (double)
- transactionId, invoiceId (nullable)
```

#### 12. Account
```dart
- id (auto-increment)
- companyId (indexed)
- name, code (indexed)
- accountType (enum: asset, liability, equity, revenue, expense)
- parentAccountId (nullable)
- description
- openingBalance, currentBalance (double)
- isSystem, isActive (bool)
- createdAt
```

#### 13. AccountTransaction
```dart
- id (auto-increment)
- companyId (indexed)
- accountId (indexed)
- transactionType (enum: multiple types)
- referenceId (indexed)
- transactionDate (indexed)
- debit, credit (double)
- runningBalance (double)
- description, referenceNo
- partyId (nullable)
- createdAt
```

#### 14. PaymentAccount
```dart
- id (auto-increment)
- companyId (indexed)
- accountType (enum: cash, bank)
- accountName
- bankName, accountNumber, ifscCode (nullable)
- icon
- isActive (indexed), isDefault (bool)
- createdAt, updatedAt
```

#### 15. PaymentIn
```dart
- id (auto-increment)
- companyId (indexed)
- receiptNo
- receiptDate
- partyId (indexed)
- totalAmount (double)
- description, attachmentPath
- createdAt, updatedAt
- createdByUserId
```

#### 16. PaymentInLine
```dart
- id (auto-increment)
- paymentInId (indexed)
- paymentAccountId (indexed)
- amount (double)
- referenceNo
- createdAt
```

#### 17. PaymentOut
```dart
- id (auto-increment)
- companyId (indexed)
- voucherNo
- voucherDate
- partyId (indexed)
- totalAmount (double)
- description, attachmentPath
- createdAt, updatedAt
- createdByUserId
```

#### 18. PaymentOutLine
```dart
- id (auto-increment)
- paymentOutId (indexed)
- paymentAccountId (indexed)
- amount (double)
- referenceNo
- createdAt
```

---

## Application Architecture

### Layer Structure

```
┌─────────────────────────────────────────────────────┐
│                 Presentation Layer                   │
│  (Screens, Widgets, UI Components)                  │
└─────────────────┬───────────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────────┐
│              Business Logic Layer                    │
│  (Providers, Services, State Management - Riverpod) │
└─────────────────┬───────────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────────┐
│                Data Access Layer                     │
│  (DAOs - Data Access Objects)                       │
└─────────────────┬───────────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────────┐
│              Isar Database Layer                     │
│  (Embedded NoSQL Database)                          │
└─────────────────────────────────────────────────────┘
```

### Key Components

#### 1. IsarService
- Singleton service managing Isar database instance
- Initializes all collections
- Provides access to Isar instance throughout app

#### 2. DAOs (Data Access Objects)
- **PartyDao**: CRUD for parties, opening balance management
- **ProductDao**: Product queries and operations
- **SalesDao**: Sales invoice operations
- **PurchaseDao**: Purchase invoice operations
- **PaymentDao**: Payment in/out operations
- **AccountDao**: Chart of accounts management
- **ExpenseDao**: Expense tracking

#### 3. Providers (Riverpod)
- Singleton providers for services and DAOs
- State management for UI
- Dependency injection

#### 4. Services
- **AuthService**: User authentication with SharedPreferences
- **BiometricService**: Biometric authentication
- **SettingsProvider**: App settings management

### Data Flow

```
User Action → Widget → Provider → DAO → Isar → Database File
                ↓
            UI Update
```

---

## Sync Strategy

### Delta Sync Approach

#### Concept
Instead of syncing entire database, only sync **changes** since last sync.

#### Key Components

1. **Version Counter**: Global version number increments with each change
2. **Change Log Table**: Tracks all INSERT, UPDATE, DELETE operations
3. **Device Tracking**: Each device knows its last synced version
4. **Conflict Resolution**: Last-write-wins with timestamp

#### Sync Flow

```
┌──────────────┐                    ┌──────────────┐
│   Device A   │                    │   Server     │
│              │                    │              │
│ Last Ver: 42 │────Pull Changes───►│ Current: 50  │
│              │◄──Changes 43-50────│              │
│              │                    │              │
│ Apply Changes│                    │              │
│ Now Ver: 50  │                    │              │
│              │                    │              │
│ Local Changes│────Push Changes───►│              │
│ (3 records)  │◄──Confirm + Map───│ Now Ver: 53  │
│              │                    │              │
└──────────────┘                    └──────────────┘
```

#### Pull Sync (Device → Server)

**Request:**
```json
{
  "device_id": "uuid-abc123",
  "company_id": 1,
  "last_version": 42,
  "tables": ["parties", "products", "invoices"]
}
```

**Response:**
```json
{
  "success": true,
  "current_version": 50,
  "changes": [
    {
      "version": 43,
      "table": "parties",
      "record_id": 10,
      "operation": "UPDATE",
      "data": {
        "id": 10,
        "name": "Updated Party Name",
        "phone": "1234567890"
      },
      "timestamp": "2026-01-12T10:30:00Z"
    },
    {
      "version": 44,
      "table": "products",
      "record_id": 25,
      "operation": "INSERT",
      "data": {
        "id": 25,
        "name": "New Product",
        "sku": "PROD-25"
      },
      "timestamp": "2026-01-12T11:00:00Z"
    }
  ]
}
```

#### Push Sync (Device → Server)

**Request:**
```json
{
  "device_id": "uuid-abc123",
  "company_id": 1,
  "changes": [
    {
      "table": "invoices",
      "local_id": "temp_001",
      "operation": "INSERT",
      "data": {
        "invoiceDate": "2026-01-12",
        "partyId": 5,
        "grandTotal": 1500.00
      },
      "timestamp": "2026-01-12T12:00:00Z"
    },
    {
      "table": "parties",
      "record_id": 8,
      "operation": "UPDATE",
      "data": {
        "id": 8,
        "phone": "9876543210"
      },
      "timestamp": "2026-01-12T12:05:00Z"
    }
  ]
}
```

**Response:**
```json
{
  "success": true,
  "current_version": 53,
  "conflicts": [],
  "id_mappings": {
    "temp_001": 127
  }
}
```

#### Conflict Resolution

**Strategy: Last-Write-Wins**

1. Compare timestamps
2. Most recent change wins
3. Notify user of conflicts
4. Allow manual resolution

**Example Conflict:**
- Device A updates Party #5 at 10:00 AM
- Device B updates Party #5 at 10:05 AM
- Device B's change wins (later timestamp)
- Device A receives update on next pull

---

## Laravel Backend Design

### Project Structure

```
laravel_sync/
├── app/
│   ├── Http/
│   │   ├── Controllers/
│   │   │   └── Api/
│   │   │       ├── AuthController.php
│   │   │       ├── SyncController.php
│   │   │       ├── CompanyController.php
│   │   │       ├── PartyController.php
│   │   │       └── ProductController.php
│   │   ├── Middleware/
│   │   │   └── EnsureCompanyAccess.php
│   │   └── Resources/
│   │       ├── PartyResource.php
│   │       └── ProductResource.php
│   ├── Models/
│   │   ├── Company.php
│   │   ├── User.php
│   │   ├── CompanyUser.php
│   │   ├── Party.php
│   │   ├── Product.php
│   │   ├── Invoice.php
│   │   ├── Transaction.php
│   │   ├── Account.php
│   │   ├── PaymentAccount.php
│   │   ├── PaymentIn.php
│   │   ├── PaymentOut.php
│   │   ├── SyncChange.php
│   │   └── DeviceSyncStatus.php
│   └── Services/
│       ├── SyncService.php
│       ├── ConflictResolver.php
│       └── VersionManager.php
├── database/
│   └── migrations/
│       ├── 2026_01_01_000001_create_companies_table.php
│       ├── 2026_01_01_000002_create_users_table.php
│       ├── 2026_01_01_000003_create_company_user_table.php
│       ├── 2026_01_01_000004_create_parties_table.php
│       ├── 2026_01_01_000005_create_products_table.php
│       ├── 2026_01_01_000010_create_sync_changes_table.php
│       └── 2026_01_01_000011_create_device_sync_status_table.php
├── routes/
│   └── api.php
└── tests/
    ├── Feature/
    │   ├── AuthTest.php
    │   └── SyncTest.php
    └── Unit/
        └── SyncServiceTest.php
```

### Database Schema Highlights

#### sync_changes Table
```sql
- id (bigint, PK)
- company_id (int, indexed)
- user_id (int)
- device_id (varchar, indexed)
- table_name (varchar, indexed)
- record_id (bigint, indexed)
- operation (enum: INSERT, UPDATE, DELETE)
- data (JSON)
- version (bigint, indexed)
- created_at (timestamp)
```

#### device_sync_status Table
```sql
- id (bigint, PK)
- company_id (int)
- device_id (varchar)
- device_name (varchar)
- last_sync_version (bigint)
- last_sync_at (timestamp)
- created_at, updated_at
- UNIQUE(company_id, device_id)
```

### API Endpoints

```
POST   /api/auth/register
POST   /api/auth/login
POST   /api/auth/logout
GET    /api/auth/user

POST   /api/sync/pull
POST   /api/sync/push
GET    /api/sync/status
POST   /api/sync/resolve-conflict

GET    /api/companies
POST   /api/companies

GET    /api/parties
POST   /api/parties
PUT    /api/parties/{id}
DELETE /api/parties/{id}

GET    /api/products
POST   /api/products
PUT    /api/products/{id}
DELETE /api/products/{id}

GET    /api/invoices
POST   /api/invoices
PUT    /api/invoices/{id}

GET    /api/payments/in
POST   /api/payments/in
GET    /api/payments/out
POST   /api/payments/out
```

### Security

1. **Authentication**: Laravel Sanctum (Token-based)
2. **Authorization**: Company-based access control
3. **Multi-Tenancy**: All queries scoped by company_id
4. **Encryption**: HTTPS for all API calls
5. **Validation**: Comprehensive input validation

### Performance Optimizations

1. **Indexing**: All foreign keys and query columns
2. **Caching**: Redis for frequently accessed data
3. **Pagination**: Large datasets paginated
4. **Eager Loading**: Prevent N+1 queries
5. **Database Optimization**: Query optimization, proper indexes

---

## Implementation Roadmap

### Phase 1: Foundation (Week 1-2)
- ✅ Understand Flutter app structure
- ✅ Map all data models
- ✅ Design sync strategy
- ⬜ Create Laravel project
- ⬜ Set up database migrations
- ⬜ Implement authentication

### Phase 2: Core Sync Engine (Week 3-4)
- ⬜ Build SyncService
- ⬜ Implement change tracking
- ⬜ Create pull/push endpoints
- ⬜ Device management
- ⬜ Version control

### Phase 3: Data Models (Week 5-6)
- ⬜ Party sync
- ⬜ Product sync
- ⬜ Invoice sync
- ⬜ Payment sync
- ⬜ Account sync
- ⬜ Transaction sync

### Phase 4: Testing & Polish (Week 7-8)
- ⬜ Unit tests
- ⬜ Integration tests
- ⬜ Performance testing
- ⬜ Security audit
- ⬜ Documentation

---

## Next Steps

1. Create Laravel project structure
2. Generate migrations for all tables
3. Create Eloquent models
4. Implement SyncService
5. Build API controllers
6. Add authentication
7. Test sync endpoints
8. Integrate with Flutter app

---

**Document Version**: 1.0  
**Last Updated**: January 12, 2026  
**Author**: AI Assistant
