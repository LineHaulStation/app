# PRD-006: Facilities (Terminals)

**Version:** 1.0  
**Status:** Draft  
**Last Updated:** January 28, 2026  

---

## 1. Feature Identity

### 1.1 Name
Facilities (Terminals)

### 1.2 Portal(s)
- [x] Driver (view available terminals)
- [x] Carrier (purchase access)
- [x] Admin (manage facilities)

### 1.3 One-Line Summary
Physical terminal locations where drivers can access parking, amenities, and services using their SPACE tokens.

### 1.4 Business Value
- **Infrastructure:** Core asset of the platform—physical locations
- **Scalability:** Framework for adding new terminals
- **Clarity:** Single source of truth for location data

---

## 2. System Context

### 2.1 Dependencies
- System Overview — Global conventions

### 2.2 Dependents
- PRD-007: SPACE Purchase — Terminal selection for purchases
- PRD-008: Tokens & Access — Tokens tied to terminals
- PRD-011: Network Dividends — Usage tracked per terminal

---

## 3. Data Model

```
Facility
├── facility_id (UUID, PK)
├── name (string, required) — "West Memphis"
├── code (string, unique, required) — "WMEM"
├── address (string)
├── city (string, required)
├── state (string, required)
├── zip (string)
├── latitude (decimal, optional)
├── longitude (decimal, optional)
├── is_active (boolean, default true)
├── amenities (JSON array) — parking, showers, lounge, etc.
├── capacity (integer, optional) — total spaces
├── description (text, optional)
├── image_url (string, optional)
├── created_at (timestamp)
└── updated_at (timestamp)
```

---

## 4. Current Facilities

### V1 Launch

| Name | Code | Location | Status |
|------|------|----------|--------|
| West Memphis | WMEM | West Memphis, AR | Active |

Additional terminals will be added as the network expands.

---

## 5. Rules & Constraints

| Rule | Description |
|------|-------------|
| Code unique | Each facility has unique short code |
| Code in QR | Facility code appears in QR payload |
| Deactivation | Deactivated facilities reject new purchases |
| Existing tokens | Remain valid if facility deactivated |

---

## 6. Admin Controls

| Action | Description |
|--------|-------------|
| Add facility | Create new terminal |
| Edit facility | Update details |
| Activate/Deactivate | Control availability |
| View usage | Tokens used at facility |

---

## 7. Non-Goals

- ❌ Real-time capacity tracking
- ❌ Reservation system
- ❌ Dynamic pricing per facility
- ❌ Facility-specific rules (uniform rules for now)

---

## 8. Changelog

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | Jan 28, 2026 | Product Team | Initial draft |
