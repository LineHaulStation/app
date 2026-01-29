# PRD-017: Data Operations

**Version:** 1.0  
**Status:** Draft  
**Last Updated:** January 28, 2026  

---

## 1. Feature Identity

### 1.1 Name
Data Import, Export & Backup

### 1.2 Portal(s)
- [ ] Driver
- [ ] Carrier
- [x] Admin (exclusive)

### 1.3 One-Line Summary
Admin-only capabilities to export, backup, import, and restore platform data for operational continuity, auditing, and disaster recovery.

---

## 2. Capabilities Overview

| Operation | Description | Access |
|-----------|-------------|--------|
| Export | Download data as JSON/CSV | Admin |
| Backup | Create restorable snapshot | Admin |
| Import | Add/update data from file | Admin |
| Restore | Recover from backup | Super Admin |

---

## 3. Export

### 3.1 Export Types

| Type | Description |
|------|-------------|
| Full Export | All platform data |
| Entity Export | Single entity type |
| Filtered Export | Date range, status filters |

### 3.2 Exportable Entities

- Users (no password hashes)
- Driver Profiles
- Carrier Profiles
- Tokens
- Points (accounts, ledger, rules)
- Conduct Logs
- Referral Trees
- Sweepstakes Entries
- Shareables
- Redemption Requests

### 3.3 Formats

- **JSON:** Full fidelity, suitable for re-import
- **CSV:** Flat structure, for spreadsheet analysis

---

## 4. Backup

### 4.1 Backup Types

| Type | Description | Retention |
|------|-------------|-----------|
| Manual | Admin-triggered | 90 days |
| Scheduled | Automatic (configurable) | 90 days |
| Pre-Import | Before any import | 30 days |

### 4.2 Schedule Options

- Daily (2 AM UTC default)
- Weekly (Sunday)
- Monthly (1st)

---

## 5. Import

### 5.1 Import Types

| Type | Description | Risk |
|------|-------------|------|
| Additive | Add new records only | Low |
| Upsert | Add new, update existing | Medium |
| Replace | Delete all, import fresh | High |

### 5.2 Process

1. Upload file (JSON/CSV)
2. Validate schema
3. Validate data
4. Preview changes
5. Create pre-import backup
6. Process import
7. Generate report

### 5.3 Error Handling

- Duplicate keys: Skip and log
- Invalid data: Skip and log
- System error: Automatic rollback

---

## 6. Restore

### 6.1 Access

**Super Admin only** — not available to regular admins

### 6.2 Process

1. Select backup to restore
2. Validate backup integrity
3. Create pre-restore backup
4. Confirm with typed phrase
5. Clear existing data
6. Import backup data
7. Validate restore

### 6.3 Warning

⚠️ **DESTRUCTIVE OPERATION**

Restore deletes all data created after the backup was taken.

---

## 7. Data Model

### 7.1 DataExport

```
DataExport
├── export_id (UUID, PK)
├── export_type (enum: FULL, PARTIAL, ENTITY)
├── entity_types (JSON array)
├── format (enum: JSON, CSV)
├── file_url (string)
├── file_size_bytes (integer)
├── record_count (integer)
├── status (enum: PENDING, PROCESSING, COMPLETED, FAILED)
├── requested_by_admin_id (UUID)
├── completed_at (timestamp)
├── expires_at (timestamp)
├── created_at (timestamp)
```

### 7.2 DataBackup

```
DataBackup
├── backup_id (UUID, PK)
├── backup_type (enum: FULL, INCREMENTAL)
├── trigger_type (enum: MANUAL, SCHEDULED, PRE_IMPORT)
├── file_url (string)
├── file_size_bytes (integer)
├── checksum (string)
├── status (enum: PENDING, COMPLETED, FAILED, RESTORED)
├── created_by_admin_id (UUID)
├── restored_at (timestamp, nullable)
├── created_at (timestamp)
```

### 7.3 DataImport

```
DataImport
├── import_id (UUID, PK)
├── import_type (enum: ADDITIVE, UPSERT, REPLACE)
├── entity_type (string)
├── total_records (integer)
├── successful_records (integer)
├── failed_records (integer)
├── status (enum: PENDING, VALIDATING, PROCESSING, COMPLETED, FAILED, ROLLED_BACK)
├── pre_import_backup_id (UUID, FK)
├── requested_by_admin_id (UUID)
├── created_at (timestamp)
```

---

## 8. Security

| Requirement | Implementation |
|-------------|----------------|
| Encryption at rest | AES-256 |
| Encryption in transit | TLS 1.3 |
| Access control | Admin-only |
| Audit logging | All operations logged |
| No password export | password_hash excluded |

---

## 9. Retention

| Data Type | Retention |
|-----------|-----------|
| Exports | 7 days |
| Manual backups | 90 days |
| Scheduled backups | 90 days |
| Pre-import backups | 30 days |
| Import files | Deleted after processing |

---

## 10. Admin UI

```
Data Operations
════════════════════════════════════════

BACKUPS
Last Backup: Jan 28, 2026 02:00 UTC ✅
Next Scheduled: Jan 29, 2026 02:00 UTC
Available: 12 backups

[Create Backup]  [View All]

EXPORTS
Recent: Full Export (Jan 27) — [Download]

[New Export]

IMPORTS
Recent: Users (Jan 26) — 150 records ✅

[New Import]
```

---

## 11. Non-Goals

- ❌ Real-time replication
- ❌ Driver self-service export (future GDPR)
- ❌ Media file backup (URLs only)
- ❌ External backup service integration

---

## 12. Changelog

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | Jan 28, 2026 | Product Team | Initial draft |
