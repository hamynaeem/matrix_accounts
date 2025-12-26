# Matrix Accounts - Laravel Sync Backend Project Plan

## Project Overview

**Purpose**: Cloud synchronization backend for Matrix Accounts Flutter application  
**Technology Stack**: Laravel 11, MySQL 8.0, Redis  
**Sync Strategy**: Delta sync with conflict resolution  
**Data Policy**: Sync transactional data only; keep reporting/analytics on client

---

## Core Principles

### ✅ What Gets Synced (Essential Data Only)
- Companies & Users
- Parties (Customers/Suppliers)
- Products & Inventory
- Invoices & Transactions
- Payments & Account Transactions
- Payment Accounts
- Stock Ledger

### ❌ What Stays on Client (Performance & Privacy)
- Reports & Analytics
- Dashboards & Charts
- Cached calculations
- UI preferences
- Temporary data

---

## Architecture Overview

```
┌─────────────────┐         ┌─────────────────┐         ┌─────────────────┐
│  Device A       │         │  Laravel API     │         │  Device B       │
│  (Isar DB)      │◄───────►│  (MySQL)         │◄───────►│  (Isar DB)      │
│                 │  HTTPS  │                  │  HTTPS  │                 │
│  Offline First  │  Sync   │  Delta Sync      │  Sync   │  Offline First  │
└─────────────────┘         └─────────────────┘         └─────────────────┘
         │                           │                           │
         │                    ┌──────▼──────┐                   │
         │                    │   Redis     │                   │
         │                    │   Cache     │                   │
         │                    └─────────────┘                   │
         │                                                       │
         └───────────────► Client-Side Reporting ◄──────────────┘
```

---

## Project Phases

### Phase 1: Foundation (Week 1-2)
- [ ] Laravel project setup
- [ ] Database design & migrations
- [ ] Authentication system (Sanctum)
- [ ] Basic CRUD APIs

### Phase 2: Sync Engine (Week 3-4)
- [ ] Sync change tracking
- [ ] Delta sync implementation
- [ ] Conflict detection & resolution
- [ ] Device management

### Phase 3: Data Sync (Week 5-6)
- [ ] Company & User sync
- [ ] Party sync
- [ ] Product sync
- [ ] Invoice sync
- [ ] Transaction sync

### Phase 4: Testing & Optimization (Week 7-8)
- [ ] Unit tests
- [ ] Integration tests
- [ ] Performance optimization
- [ ] Load testing
- [ ] Security audit

---

## Database Design Principles

### 1. **Multi-Tenancy**
- Company-based data isolation
- User belongs to company
- All data scoped by company_id

### 2. **Soft Deletes**
- All tables use soft deletes
- Sync deletions as updates
- Maintain audit trail

### 3. **Versioning**
- Global version counter for sync
- Per-record version tracking
- Timestamp-based ordering

### 4. **Audit Trail**
- Track all changes
- Who, what, when, where
- Support rollback if needed

---

## API Design Strategy

### RESTful Endpoints

```
Authentication:
POST   /api/auth/register
POST   /api/auth/login
POST   /api/auth/logout
GET    /api/auth/user

Sync Endpoints:
POST   /api/sync/pull       # Pull changes from server
POST   /api/sync/push       # Push changes to server
GET    /api/sync/status     # Get sync status
POST   /api/sync/resolve    # Resolve conflicts

Data Endpoints (for direct access):
GET    /api/companies
GET    /api/parties
GET    /api/products
GET    /api/invoices
GET    /api/transactions
```

### Sync API Contract

**Pull Request:**
```json
{
  "device_id": "uuid-1234",
  "last_version": 42,
  "tables": ["parties", "products", "invoices"]
}
```

**Pull Response:**
```json
{
  "success": true,
  "current_version": 50,
  "changes": [
    {
      "id": 43,
      "table": "parties",
      "record_id": 123,
      "operation": "UPDATE",
      "data": { "name": "John Doe", "..." },
      "version": 43,
      "timestamp": "2025-12-13T10:00:00Z"
    }
  ]
}
```

**Push Request:**
```json
{
  "device_id": "uuid-1234",
  "changes": [
    {
      "table": "invoices",
      "local_id": "temp_001",
      "operation": "INSERT",
      "data": { "..." },
      "timestamp": "2025-12-13T09:55:00Z"
    }
  ]
}
```

**Push Response:**
```json
{
  "success": true,
  "conflicts": [],
  "id_mappings": {
    "temp_001": 456
  },
  "current_version": 51
}
```

---

## Data Sync Rules

### What to Sync
| Table | Direction | Priority | Notes |
|-------|-----------|----------|-------|
| companies | Bidirectional | High | Single company per sync |
| users | Bidirectional | High | Company users only |
| parties | Bidirectional | High | Customers & Suppliers |
| products | Bidirectional | High | With categories |
| invoices | Bidirectional | Critical | Sales & Purchase |
| transactions | Bidirectional | Critical | Linked to invoices |
| transaction_lines | Bidirectional | Critical | Invoice items |
| account_transactions | Bidirectional | Critical | Accounting entries |
| payment_accounts | Bidirectional | Medium | Cash/Bank accounts |
| stock_ledger | Bidirectional | High | Inventory movements |

### What NOT to Sync
- ❌ Reports data (generate on-demand)
- ❌ Dashboard aggregates (calculate client-side)
- ❌ Chart data (compute locally)
- ❌ Temporary calculations
- ❌ UI state/preferences
- ❌ Cached queries

---

## Conflict Resolution Strategy

### Priority Rules
1. **Invoices**: Server wins (last write with audit)
2. **Payments**: Server wins (financial integrity)
3. **Products**: Merge (combine updates)
4. **Parties**: Latest timestamp wins
5. **Settings**: Manual resolution

### Conflict Detection
```php
function hasConflict($serverRecord, $clientChange) {
    // Check if record modified after client's last sync
    if ($serverRecord->updated_at > $clientChange['last_sync_at']) {
        return true;
    }
    return false;
}
```

---

## Security Measures

1. **Authentication**
   - Laravel Sanctum tokens
   - Device-specific tokens
   - Token rotation

2. **Authorization**
   - Company-based access control
   - Role-based permissions
   - Per-device capabilities

3. **Data Validation**
   - Request validation
   - Business rule validation
   - Accounting integrity checks

4. **Rate Limiting**
   - Per-user limits
   - Per-endpoint limits
   - Sync throttling

5. **Encryption**
   - HTTPS only
   - Database encryption for sensitive data
   - Token encryption

---

## Performance Optimization

### 1. Database Indexing
```sql
-- Critical indexes
CREATE INDEX idx_sync_version ON sync_changes(company_id, version);
CREATE INDEX idx_device_sync ON device_sync_status(company_id, device_id);
CREATE INDEX idx_company_data ON invoices(company_id, deleted_at);
```

### 2. Redis Caching
- Cache user sessions
- Cache company data
- Cache sync metadata
- Queue jobs for async processing

### 3. Query Optimization
- Eager loading relationships
- Pagination for large datasets
- Chunk processing for bulk operations

### 4. API Response Optimization
- Compress responses (gzip)
- Limit response size
- Use API resources for transformation

---

## Monitoring & Logging

### Metrics to Track
- Sync frequency per device
- Average sync duration
- Conflict rate
- Error rate
- API response times

### Logging
- All sync operations
- Conflicts and resolutions
- Authentication attempts
- Data modifications
- Errors and exceptions

---

## Deployment Strategy

### Development
- Local MySQL + Redis
- Laravel Sail (Docker)
- Postman for API testing

### Staging
- AWS/DigitalOcean
- MySQL RDS
- Redis ElastiCache
- CI/CD pipeline

### Production
- Load balancer
- Auto-scaling
- Database replication
- Regular backups
- Monitoring (New Relic/DataDog)

---

## Success Criteria

- [ ] 99.9% API uptime
- [ ] < 2 second sync for typical changes
- [ ] < 1% conflict rate
- [ ] Support 100+ concurrent users
- [ ] < 5 second API response time (p95)
- [ ] Zero data loss
- [ ] Complete audit trail

---

## Risk Management

| Risk | Impact | Mitigation |
|------|--------|------------|
| Data conflicts | High | Robust conflict resolution + audit |
| Data loss | Critical | Transaction wrapping + backups |
| Performance degradation | Medium | Caching + indexing + monitoring |
| Security breach | Critical | Authentication + encryption + audit |
| Network failures | Medium | Retry logic + offline queue |

---

## Next Steps

1. Review and approve this plan
2. Set up development environment
3. Begin Phase 1 implementation
4. Weekly progress reviews
5. Iterative testing and refinement

---

**Created**: December 13, 2025  
**Version**: 1.0  
**Status**: Planning Phase
