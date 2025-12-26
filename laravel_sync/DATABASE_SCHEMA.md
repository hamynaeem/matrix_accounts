# Database Schema Documentation

## Overview
This document defines the MySQL database schema for the Matrix Accounts sync backend.

---

## Core Sync Tables

### sync_changes
Tracks all changes across devices for delta sync.

```sql
CREATE TABLE sync_changes (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    company_id INT UNSIGNED NOT NULL,
    user_id INT UNSIGNED NOT NULL,
    device_id VARCHAR(255) NOT NULL,
    table_name VARCHAR(100) NOT NULL,
    record_id BIGINT UNSIGNED NOT NULL,
    operation ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL,
    data JSON NOT NULL,
    version BIGINT UNSIGNED NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_company_version (company_id, version),
    INDEX idx_table_record (table_name, record_id),
    INDEX idx_device (device_id, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### device_sync_status
Tracks sync status for each device.

```sql
CREATE TABLE device_sync_status (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    company_id INT UNSIGNED NOT NULL,
    device_id VARCHAR(255) NOT NULL,
    device_name VARCHAR(255),
    last_sync_version BIGINT UNSIGNED DEFAULT 0,
    last_sync_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    UNIQUE KEY unique_device (company_id, device_id),
    INDEX idx_last_sync (last_sync_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

## Business Data Tables

### companies
```sql
CREATE TABLE companies (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    address TEXT,
    phone VARCHAR(50),
    email VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    
    INDEX idx_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### users
```sql
CREATE TABLE users (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    company_id INT UNSIGNED NOT NULL,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    password VARCHAR(255) NOT NULL,
    role ENUM('admin', 'user') DEFAULT 'user',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    
    UNIQUE KEY unique_email (email),
    INDEX idx_company (company_id),
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### parties
```sql
CREATE TABLE parties (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    company_id INT UNSIGNED NOT NULL,
    name VARCHAR(255) NOT NULL,
    party_type ENUM('customer', 'supplier', 'both') NOT NULL,
    phone VARCHAR(50),
    email VARCHAR(255),
    address TEXT,
    opening_balance DECIMAL(15, 2) DEFAULT 0,
    current_balance DECIMAL(15, 2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    
    INDEX idx_company (company_id),
    INDEX idx_name (name),
    INDEX idx_type (party_type),
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### products
```sql
CREATE TABLE products (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    company_id INT UNSIGNED NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    sale_price DECIMAL(15, 2) DEFAULT 0,
    purchase_price DECIMAL(15, 2) DEFAULT 0,
    current_stock DECIMAL(15, 3) DEFAULT 0,
    unit VARCHAR(50),
    category VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    
    INDEX idx_company (company_id),
    INDEX idx_name (name),
    INDEX idx_category (category),
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### invoices
```sql
CREATE TABLE invoices (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    company_id INT UNSIGNED NOT NULL,
    transaction_id INT UNSIGNED NOT NULL,
    invoice_type ENUM('sale', 'purchase') NOT NULL,
    party_id INT UNSIGNED NOT NULL,
    invoice_date DATE NOT NULL,
    due_date DATE,
    grand_total DECIMAL(15, 2) NOT NULL,
    status VARCHAR(50) DEFAULT 'Pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    
    INDEX idx_company (company_id),
    INDEX idx_transaction (transaction_id),
    INDEX idx_party (party_id),
    INDEX idx_date (invoice_date),
    INDEX idx_type (invoice_type),
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    FOREIGN KEY (party_id) REFERENCES parties(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### transactions
```sql
CREATE TABLE transactions (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    company_id INT UNSIGNED NOT NULL,
    type ENUM('sale', 'purchase', 'expense', 'receipt', 'payment') NOT NULL,
    date DATE NOT NULL,
    reference_no VARCHAR(100) NOT NULL,
    party_id INT UNSIGNED,
    total_amount DECIMAL(15, 2) NOT NULL,
    is_posted BOOLEAN DEFAULT TRUE,
    created_by_user_id INT UNSIGNED,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    
    INDEX idx_company (company_id),
    INDEX idx_type (type),
    INDEX idx_date (date),
    INDEX idx_reference (reference_no),
    INDEX idx_party (party_id),
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### transaction_lines
```sql
CREATE TABLE transaction_lines (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    transaction_id INT UNSIGNED NOT NULL,
    product_id INT UNSIGNED,
    description TEXT,
    quantity DECIMAL(15, 3) DEFAULT 0,
    unit_price DECIMAL(15, 2) DEFAULT 0,
    line_amount DECIMAL(15, 2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_transaction (transaction_id),
    INDEX idx_product (product_id),
    FOREIGN KEY (transaction_id) REFERENCES transactions(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### accounts
```sql
CREATE TABLE accounts (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    company_id INT UNSIGNED NOT NULL,
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) NOT NULL,
    account_type ENUM('asset', 'liability', 'equity', 'revenue', 'expense') NOT NULL,
    parent_account_id INT UNSIGNED,
    description TEXT,
    opening_balance DECIMAL(15, 2) DEFAULT 0,
    current_balance DECIMAL(15, 2) DEFAULT 0,
    is_system BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    
    INDEX idx_company (company_id),
    INDEX idx_code (code),
    INDEX idx_type (account_type),
    UNIQUE KEY unique_company_code (company_id, code),
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### account_transactions
```sql
CREATE TABLE account_transactions (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    company_id INT UNSIGNED NOT NULL,
    account_id INT UNSIGNED NOT NULL,
    transaction_type ENUM('saleInvoice', 'paymentIn', 'purchaseInvoice', 'paymentOut', 'journalEntry') NOT NULL,
    reference_id INT UNSIGNED NOT NULL,
    transaction_date DATE NOT NULL,
    debit DECIMAL(15, 2) DEFAULT 0,
    credit DECIMAL(15, 2) DEFAULT 0,
    running_balance DECIMAL(15, 2) DEFAULT 0,
    description TEXT,
    reference_no VARCHAR(100),
    party_id INT UNSIGNED,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_company (company_id),
    INDEX idx_account (account_id),
    INDEX idx_type (transaction_type),
    INDEX idx_reference (reference_id),
    INDEX idx_date (transaction_date),
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    FOREIGN KEY (account_id) REFERENCES accounts(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### payment_accounts
```sql
CREATE TABLE payment_accounts (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    company_id INT UNSIGNED NOT NULL,
    account_name VARCHAR(255) NOT NULL,
    account_type ENUM('cash', 'bank', 'cheque') NOT NULL,
    icon VARCHAR(50),
    bank_name VARCHAR(255),
    account_number VARCHAR(100),
    ifsc_code VARCHAR(50),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    
    INDEX idx_company (company_id),
    INDEX idx_type (account_type),
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### stock_ledger
```sql
CREATE TABLE stock_ledger (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    company_id INT UNSIGNED NOT NULL,
    product_id INT UNSIGNED NOT NULL,
    date DATE NOT NULL,
    movement_type ENUM('inPurchase', 'outSale', 'inAdjustment', 'outAdjustment') NOT NULL,
    quantity_delta DECIMAL(15, 3) NOT NULL,
    transaction_id INT UNSIGNED,
    invoice_id INT UNSIGNED,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_company (company_id),
    INDEX idx_product (product_id),
    INDEX idx_date (date),
    INDEX idx_transaction (transaction_id),
    INDEX idx_invoice (invoice_id),
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

## Relationships Diagram

```
companies
    ├── users (1:N)
    ├── parties (1:N)
    ├── products (1:N)
    ├── invoices (1:N)
    ├── transactions (1:N)
    ├── accounts (1:N)
    └── payment_accounts (1:N)

invoices
    ├── transaction (1:1)
    └── party (N:1)

transactions
    └── transaction_lines (1:N)

account_transactions
    ├── account (N:1)
    └── party (N:1)

stock_ledger
    ├── product (N:1)
    ├── transaction (N:1)
    └── invoice (N:1)
```

---

## Notes

1. **All tables use soft deletes** (`deleted_at` column)
2. **Multi-tenancy** via `company_id` on all business tables
3. **Timestamps** are used for sync ordering
4. **Decimal precision** for financial data (15,2)
5. **Indexes** on all foreign keys and frequently queried columns
6. **UTF8MB4** for emoji and international character support

---

**Version**: 1.0  
**Last Updated**: December 13, 2025
