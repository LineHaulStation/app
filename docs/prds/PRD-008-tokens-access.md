# PRD-008: Tokens & Access

**Version:** 1.0  
**Status:** Draft  
**Last Updated:** January 28, 2026  

---

## 1. Feature Identity

### 1.1 Name
Tokens & Access

### 1.2 Portal(s)
- [x] Driver (view assigned tokens, QR codes)
- [x] Carrier (manage inventory, assign tokens)
- [x] Admin (full token management)

### 1.3 One-Line Summary
The token system that tracks carrier access inventory, enables assignment to drivers, and generates QR codes for terminal entry.

### 1.4 Business Value
- **Access Control:** Track who has access to what
- **Accountability:** Full audit trail of token lifecycle
- **Flexibility:** Multiple assignment and usage patterns

---

## 2. System Context

### 2.1 Dependencies
- PRD-004: Carrier Profile — Carrier owns inventory
- PRD-003: Driver Profile — Driver receives tokens
- PRD-006: Facilities — Tokens tied to terminals
- PRD-007: SPACE Purchase — Creates inventory

### 2.2 Dependents
- PRD-011: Network Dividends — Token usage triggers dividends

---

## 3. Data Model

### 3.1 CarrierAccessBalance (Inventory)

```
CarrierAccessBalance
├── access_balance_id (UUID, PK)
├── carrier_profile_id (UUID, FK)
├── terminal_id (UUID, FK)
├── terminal_name (string, snapshot)
├── package_type (enum: DEDICATED_365, FLEX_30, DAILY_PASS)
├── uses_total (integer)
├── uses_remaining (integer)
├── purchased_at (timestamp)
├── created_at (timestamp)
└── updated_at (timestamp)
```

### 3.2 DriverAccessToken (Individual Pass)

```
DriverAccessToken
├── token_id (UUID, PK)
├── carrier_profile_id (UUID, FK)
├── driver_profile_id (UUID, FK, nullable until assigned)
├── terminal_id (UUID, FK)
├── terminal_name (string, snapshot)
├── package_type (enum)
├── status (enum: UNISSUED, ISSUED, ASSIGNED, ACTIVE, USED, EXPIRED, REVOKED)
├── token_source (enum: CARRIER_PURCHASED, PROMOTIONAL, ADMIN_GRANT)
├── uses_remaining (integer, for Flex packages)
├── qr_payload_string (string, unique)
├── qr_code_image_url (string)
├── issued_at (timestamp)
├── assigned_at (timestamp)
├── activated_at (timestamp)
├── used_at (timestamp)
├── expires_at (timestamp, optional)
├── created_at (timestamp)
└── updated_at (timestamp)
```

---

## 4. Token Lifecycle

### 4.1 State Diagram

```
[PURCHASED] ──► [ISSUED] ──► [ASSIGNED] ──► [ACTIVE] ──► [USED]
    │              │              │              │
    │              │              │              └──► [EXPIRED]
    │              │              │
    │              │              └──────────────────► [REVOKED]
    │              │
    │              └──────────────────────────────────► [REVOKED]
```

### 4.2 State Definitions

| State | Description | QR Code? |
|-------|-------------|----------|
| UNISSUED | In carrier inventory pool | No |
| ISSUED | Token created, not assigned | No |
| ASSIGNED | Assigned to driver | Yes |
| ACTIVE | Driver has used/activated | Yes |
| USED | All uses consumed | No |
| EXPIRED | Past expiration date | No |
| REVOKED | Admin/carrier cancelled | No |

---

## 5. Token Assignment Flow

### 5.1 Carrier Assigns to Driver

1. Carrier views Access Balance
2. Clicks "Assign to Driver"
3. Selects driver from roster or enters handle
4. Selects quantity (for Daily Pass)
5. System creates DriverAccessToken
6. System generates QR payload and image
7. System decrements carrier balance
8. Driver receives token in their SPACE page

### 5.2 QR Payload Format

```
[TERMINAL]-[CARRIER]-[TOKEN]-[DRIVER]
```

**Example:** `WMEM-CAR12-TK8492-IRONHAUL`

- TERMINAL: Facility code (4 chars)
- CARRIER: Carrier short ID
- TOKEN: Token identifier
- DRIVER: Driver handle (truncated)

---

## 6. Driver Token View

### 6.1 My Passes

```
My Passes
════════════════════════════════════════

Active Passes (2)

┌────────────────────────────────────────┐
│ West Memphis Terminal                  │
│ Flex 30 — 28 uses remaining            │
│ From: ABC Trucking                     │
│                                        │
│ [View QR Code]                         │
└────────────────────────────────────────┘

┌────────────────────────────────────────┐
│ West Memphis Terminal                  │
│ Daily Pass                             │
│ Redeemed: Free Night (100 pts)         │
│                                        │
│ [View QR Code]                         │
└────────────────────────────────────────┘
```

### 6.2 QR Code Modal

- Fullscreen display option
- Download as PNG
- Brightness maximized for scanning

---

## 7. Rules & Constraints

| Rule | Description |
|------|-------------|
| Verified driver | Only verified drivers can receive tokens |
| Single assignment | Token can only be assigned to one driver |
| Balance check | Cannot assign more than available balance |
| QR on assignment | QR generated only when assigned |
| Revocation | Carrier or admin can revoke anytime |

---

## 8. Admin Token Management

| Action | Description |
|--------|-------------|
| Search tokens | By ID, QR, driver, carrier |
| View detail | Full lifecycle and audit |
| Reassign | Move to different driver |
| Revoke | Cancel token |
| Regenerate QR | New QR code (same token) |
| Adjust balance | Add/remove carrier inventory |

---

## 9. Token Sources

| Source | Description | Use Case |
|--------|-------------|----------|
| CARRIER_PURCHASED | Normal carrier purchase | Standard flow |
| PROMOTIONAL | From internal promo carrier | Point redemptions |
| ADMIN_GRANT | Admin manual grant | Support, comp |

---

## 10. Non-Goals

- ❌ Real-time gate integration (future)
- ❌ Automatic expiration processing (manual for now)
- ❌ Token trading/transfer between drivers
- ❌ Multi-terminal tokens (one terminal per token)

---

## 11. Changelog

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | Jan 28, 2026 | Product Team | Initial draft |
