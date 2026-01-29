# PRD-005: Admin Portal

**Version:** 1.0  
**Status:** Draft  
**Last Updated:** January 28, 2026  

---

## 1. Feature Identity

### 1.1 Name
Admin Portal

### 1.2 Portal(s)
- [ ] Driver
- [ ] Carrier
- [x] Admin (exclusive)

### 1.3 One-Line Summary
Centralized administrative interface for platform operations including user provisioning, profile management, token operations, points configuration, conduct enforcement, and data operations.

### 1.4 Business Value
- **Control:** Full visibility and control over platform operations
- **Efficiency:** Bulk operations, quick search, streamlined workflows
- **Compliance:** Audit trails, data export, accountability
- **Support:** Resolve user issues without code changes

---

## 2. Access Control

**Only users with `is_admin = true` can access the Admin Portal.**

For Members: Admin tab is hidden or shows "Admin Access Only"
For Admins: Full access to all admin functions

---

## 3. Admin Capabilities Summary

### 3.1 User Management
| Action | Description |
|--------|-------------|
| View all users | List with search/filter |
| Add single user | Manual account creation |
| Import users | Bulk CSV/JSON upload |
| Edit user | Change email, name, class |
| Suspend/Reinstate | Block/unblock login |
| Ban user | Permanent removal |
| Reset password | Force password change |
| Resend invite | New invite link |

### 3.2 Driver Management
| Action | Description |
|--------|-------------|
| View all drivers | List with search/filter |
| View pending verification | Queue of awaiting approval |
| Approve/Reject driver | Verification decision |
| Edit any field | Override driver data |
| Upload Outriders avatar | Custom avatar for driver |
| View/Edit conduct | Warnings, strikes, standing |
| View points | Balance and ledger |

### 3.3 Carrier Management
| Action | Description |
|--------|-------------|
| View all carriers | List with search/filter |
| Edit any field | Override carrier data |
| Toggle listing | Force list/unlist |
| Manage promo carrier | Internal promotional inventory |
| View access balances | Token inventory |

### 3.4 Token Management
| Action | Description |
|--------|-------------|
| Search tokens | By ID, QR, driver, carrier |
| View token detail | Full lifecycle info |
| Reassign token | Move to different driver |
| Revoke token | Cancel token access |
| Regenerate QR | New QR code |
| Adjust balance | Add/remove carrier inventory |

### 3.5 Points Management
| Action | Description |
|--------|-------------|
| Configure rules | Edit point values, caps |
| Enable/disable rules | Turn rules on/off |
| View driver points | Balance and ledger |
| Manual adjustment | Add/deduct with reason |
| Recalculate | Re-run point calculation |
| Freeze redemptions | Block driver redemptions |

### 3.6 Redemption Management
| Action | Description |
|--------|-------------|
| View pending requests | Queue awaiting approval |
| Approve/Deny request | Process redemption |
| Manage catalog | Add/edit/disable items |
| View promo inventory | Available fulfillment tokens |

### 3.7 Conduct Management
| Action | Description |
|--------|-------------|
| Issue warning | Add warning to driver |
| Issue strike | Escalate to strike |
| Suspend driver | Block account access |
| Reinstate driver | Restore from suspension |
| View conduct log | Full history per driver |
| Create notice | Visible alert to driver |

### 3.8 Content Management
| Action | Description |
|--------|-------------|
| Manage shareables | Create/edit/delete |
| Review sweepstakes | Approve/reject entries |
| Upload driver content | Avatars, graphics |

### 3.9 Data Operations
| Action | Description |
|--------|-------------|
| Export data | Full or filtered export |
| Create backup | Manual backup |
| Configure schedules | Automatic backups |
| Import data | Additive or upsert |
| Restore backup | Super Admin only |

---

## 4. Admin UI Patterns

### 4.1 List Views
- Paginated tables (50 items default)
- Search across multiple fields
- Filterable by status, type, date
- Sortable columns
- Quick actions per row

### 4.2 Detail Views
- Full entity information
- Related entities linked
- Action buttons with confirmation
- Audit history section

### 4.3 Confirmations
- Destructive actions require confirmation
- Some actions require typed phrase (ban, restore)
- Required notes for conduct actions

### 4.4 Audit Trail
- All admin actions logged
- Visible in entity detail views
- Exportable for compliance

---

## 5. Non-Goals

- ❌ Public-facing admin features
- ❌ Role-based admin permissions (all admins equal)
- ❌ Self-service admin account creation
- ❌ API access management (future)

---

## 6. Impact Analysis Guidance

Admin Portal implements controls defined in other PRDs. When those PRDs change, corresponding admin UI must be updated.

---

## 7. Changelog

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | Jan 28, 2026 | Product Team | Initial draft |
