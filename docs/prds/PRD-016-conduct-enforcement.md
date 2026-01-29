# PRD-016: Conduct & Enforcement

**Version:** 1.0  
**Status:** Draft  
**Last Updated:** January 28, 2026  

---

## 1. Feature Identity

### 1.1 Name
Conduct & Enforcement

### 1.2 Portal(s)
- [x] Driver (view own standing, notices)
- [ ] Carrier
- [x] Admin (full enforcement)

### 1.3 One-Line Summary
The Code of Conduct framework and progressive enforcement system for maintaining professional standards among platform members.

---

## 2. Code of Conduct

### 2.1 Core Principle

**RESPECT**
- Respect for Yourself
- Respect for Others
- Respect for Property

### 2.2 One-Strike Rules

| Violation | Consequence |
|-----------|-------------|
| Improper waste disposal | Immediate suspension |
| Violence/threats | Immediate ban |
| Harassment | Immediate suspension |

### 2.3 Acceptance Required

- Full text displayed during profile setup
- Checkbox acceptance required
- Timestamp and version recorded
- Required for GOOD_STANDING

---

## 3. Standing Levels

| Standing | Description | Can Login? |
|----------|-------------|------------|
| GOOD_STANDING | No active issues | Yes |
| UNDER_REVIEW | Has active strike | Yes (limited) |
| SUSPENDED | Account blocked | No |
| BANNED | Permanent removal | No |

---

## 4. Enforcement Actions

### 4.1 Warning

- Informational notice
- No standing change
- Visible to driver
- Expires or admin-dismisses

### 4.2 Strike

- Standing changes to UNDER_REVIEW
- Logged permanently
- Visible to driver
- Multiple strikes may lead to suspension

### 4.3 Suspension

- Account access blocked
- Standing: SUSPENDED
- User status: SUSPENDED
- Can be reinstated by admin

### 4.4 Ban

- Permanent removal
- Standing: BANNED
- User status: BANNED
- Cannot be undone

---

## 5. Data Model

### 5.1 ConductLogEntry (Immutable)

```
ConductLogEntry
├── log_entry_id (UUID, PK)
├── driver_profile_id (UUID, FK)
├── type (enum: WARNING, STRIKE, SUSPENSION, BAN, REINSTATEMENT, AMENDMENT)
├── category (string) — violation type
├── driver_visible_message (text)
├── internal_notes (text, admin-only)
├── issued_by_admin_id (UUID, FK)
├── issued_at (timestamp)
├── amended_by_entry_id (UUID, nullable)
```

### 5.2 DriverNotice (Active Alerts)

```
DriverNotice
├── notice_id (UUID, PK)
├── driver_profile_id (UUID, FK)
├── title (string)
├── message (text)
├── severity (enum: INFO, WARNING)
├── is_active (boolean)
├── expires_at (timestamp, nullable)
├── created_by_admin_id (UUID, FK)
├── created_at (timestamp)
```

---

## 6. Violation Categories

- Restroom Misuse
- Waste Disposal
- Property Damage
- Harassment
- Threats/Violence
- Fraud
- Policy Violation
- Other

---

## 7. Driver UI

### 7.1 Standing Display

```
Membership Standing: GOOD STANDING ✅

Your membership is in good standing.
```

### 7.2 Warning Alert (If Active)

```
⚠️ Notice from LineHaul Station

You have received a warning regarding [category].

[Message from admin]

Please review the Code of Conduct.
```

Persistent banner on dashboard and profile until resolved.

---

## 8. Admin Controls

| Action | Confirmation | Note Required |
|--------|--------------|---------------|
| Issue warning | No | Yes |
| Issue strike | Yes | Yes |
| Suspend driver | Yes | Yes |
| Reinstate driver | Yes | Yes |
| Ban driver | Yes (typed phrase) | Yes |
| Create notice | No | No |
| Deactivate notice | No | No |

---

## 9. Rules & Constraints

| Rule | Description |
|------|-------------|
| Conduct log immutable | Entries cannot be deleted |
| Amendment only | Can add amendment entry, not edit |
| Admin attribution | All actions logged with admin ID |
| Standing sync | Standing syncs with User account_status |

---

## 10. Non-Goals

- ❌ Driver-to-driver reporting
- ❌ Automated violation detection
- ❌ Appeal workflow (manual admin process)
- ❌ Public conduct history

---

## 11. Changelog

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | Jan 28, 2026 | Product Team | Initial draft |
