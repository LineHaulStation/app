# LineHaul Station — System Overview

**Version:** 2.0  
**Status:** Approved  
**Last Updated:** January 28, 2026  

---

## 1. Platform Identity

### 1.1 What is LineHaul Station?

LineHaul Station is a **private, invite-only** platform connecting professional truck drivers with carriers and premium terminal access. The platform operates as a membership network—think "country club for trucking infrastructure."

### 1.2 Core Value Proposition

| For | Value |
|-----|-------|
| **Drivers** | Portable professional identity, rewards for engagement, terminal access |
| **Carriers** | Flexible terminal access (SPACE), driver recruitment pipeline |
| **Platform** | Network growth via referrals, engaged professional community |

### 1.3 Platform Principles

1. **Invite-Only** — No public registration. All accounts are admin-provisioned.
2. **Professional Tone** — No gamification, no dopamine hacks. This is infrastructure.
3. **State-Based Logic** — Features respond to account state, not button clicks.
4. **Auditability** — All significant actions create immutable log entries.
5. **Scarcity by Design** — Points and tokens are finite, not auto-generated.

---

## 2. User Model

### 2.1 Two User Classes

LineHaul Station has exactly **two user classes**:

| Class | Description | Portal Access |
|-------|-------------|---------------|
| **Admin** | Platform operators with full system control | Driver + Carrier + Admin |
| **Member** | Standard platform users | Driver + Carrier only |

**There is no "Driver-only" or "Carrier-only" role.** All members have the same base access; what differs is which profiles they've created.

### 2.2 Profile Model

A single user account can have:
- **DriverProfile** — Enables Driver Portal features
- **CarrierProfile** — Enables Carrier Portal features
- **Both** — Common for owner-operators
- **Neither** — Account exists but no portal access yet

```
User Account (1)
    ├── DriverProfile (0 or 1)
    └── CarrierProfile (0 or 1)
```

### 2.3 Access Rules

| Portal | Requires | Admin Access |
|--------|----------|--------------|
| Driver Portal | DriverProfile exists | ✅ Always |
| Carrier Portal | CarrierProfile exists | ✅ Always |
| Admin Portal | `is_admin = true` | ✅ Only |

**For Members (non-admin):**
- Admin tab is **hidden** or **disabled** with helper text: "Admin Access Only"
- Optional: "Need help? Contact Admin" link that creates internal message/ticket

**For Admins:**
- All three tabs visible and enabled
- Can switch freely between portals

---

## 3. Portal Structure

### 3.1 Driver Portal

**Purpose:** Build and maintain professional driver identity

**Key Features:**
- Profile management (identity, photos, CDL, skills, intent)
- Driver Card (shareable resume)
- My Carriers (saved contacts for sharing)
- Points balance and earning
- Top 10 Truckers (referral program)
- SPACE access (view assigned tokens, QR codes)
- Social Hub (shareables, sweepstakes)

### 3.2 Carrier Portal

**Purpose:** Purchase terminal access and manage driver tokens

**Key Features:**
- SPACE purchase flow (packages, quantities)
- Access balance management
- Token assignment to drivers
- LineHaul List settings (recruitment visibility)
- Driver roster

### 3.3 Admin Portal

**Purpose:** Full platform control and operations

**Key Features:**
- User provisioning (create, import, disable accounts)
- User management (view, edit, suspend any user)
- Driver/Carrier profile management
- Points configuration and manual adjustments
- Token management (search, reassign, revoke)
- Conduct enforcement (warnings, strikes, suspensions)
- Content management (shareables, sweepstakes)
- Data operations (export, backup, restore)

---

## 4. Account Lifecycle

### 4.1 Invite-Only Provisioning

**There is NO public sign-up.** All accounts are created by Admin.

**Provisioning Methods:**
1. **Single Account** — Admin creates one account manually
2. **Bulk Import** — Admin uploads CSV/JSON of users to provision

**Account Creation Options:**
- **Option A:** Admin sets initial password → User changes after first login
- **Option B:** System sends "Set Your Password" invite link → User sets own password

### 4.2 Account States

```
[PROVISIONED] ──(user sets password)──► [ACTIVE] ──(admin suspends)──► [SUSPENDED]
                                              │                              │
                                              └──(admin bans)──► [BANNED]    │
                                                                              │
                                              (admin reinstates)◄─────────────┘
```

| State | Description | Can Login? |
|-------|-------------|------------|
| PROVISIONED | Account created, password not yet set | No |
| ACTIVE | Normal operational state | Yes |
| SUSPENDED | Temporarily blocked | No |
| BANNED | Permanently removed | No |

### 4.3 Password Lifecycle

| Action | Who | When |
|--------|-----|------|
| Set initial password | Admin OR User (via invite link) | Account creation |
| Change password | User | Anytime while active |
| Reset password | Admin | On request or security concern |
| Force password change | Admin | After reset or policy |

---

## 5. Global Data Conventions

### 5.1 Identifiers

| Entity | ID Format | Example |
|--------|-----------|---------|
| User | UUID | `550e8400-e29b-41d4-a716-446655440000` |
| Driver Handle | 3-20 chars, alphanumeric + underscore | `IRONHAULER_77` |
| Referral Code | `LH-[HANDLE]-[XXXX]` | `LH-IRONHAUL-4F2A` |
| Token | UUID | `token_id` |
| QR Payload | `[TERMINAL]-[CARRIER]-[TOKEN]-[DRIVER]` | `WMEM-CAR12-TK8492-IRONHAUL` |

### 5.2 Timestamps

- All timestamps stored in **UTC**
- Display in user's local timezone (if detectable)
- Format: ISO 8601 (`2026-01-28T14:30:00Z`)

### 5.3 Soft Deletes

Most entities use soft delete (`is_deleted = true`, `deleted_at`) rather than hard delete. Exceptions:
- Audit logs (never deleted)
- Conduct records (never deleted)

### 5.4 Audit Requirements

**Always logged:**
- Account creation/modification
- Role/permission changes
- Verification status changes
- Conduct actions
- Token lifecycle events
- Points adjustments (manual)
- Data exports/imports

**Logged with admin attribution:**
- Any admin action on behalf of user
- Manual overrides

---

## 6. Cross-Cutting Rules

### 6.1 Verification

| Profile | Verification Required? | Who Verifies |
|---------|----------------------|--------------|
| Driver | Yes (for full access) | Admin |
| Carrier | No (self-service) | N/A |

Driver verification enables:
- Handle lock (permanent)
- Referral code generation
- Full points eligibility
- Token assignment eligibility

### 6.2 Standing System

Applies to **DriverProfile** only.

| Standing | Meaning | Restrictions |
|----------|---------|--------------|
| GOOD_STANDING | No issues | None |
| UNDER_REVIEW | Has active strike(s) | May have limited features |
| SUSPENDED | Account blocked | Cannot login |
| BANNED | Permanent removal | Cannot login, cannot recreate |

### 6.3 Points Economy

- Points are **banked utility**, not discounts
- Points do NOT reduce prices, dues, or fees
- Points are earned via state-based rules (backend)
- Points are redeemed for services/gear from **real inventory**
- Admin controls all point rules and can adjust manually

### 6.4 Token Economy

- Tokens represent terminal access passes
- Tokens are purchased by Carriers (creates inventory)
- Tokens are assigned to Drivers (generates QR)
- Promotional tokens come from **admin-owned internal carrier**
- Tokens have lifecycle: Purchased → Issued → Assigned → Active → Used

---

## 7. PRD Dependency Map

```
                    ┌─────────────────────────┐
                    │   System Overview       │
                    │   (this document)       │
                    └───────────┬─────────────┘
                                │
        ┌───────────────────────┼───────────────────────┐
        │                       │                       │
        ▼                       ▼                       ▼
┌───────────────┐    ┌─────────────────────┐    ┌─────────────────┐
│ Auth &        │    │ User Account &      │    │ Admin Portal    │
│ Provisioning  │───►│ Roles               │◄───│                 │
└───────────────┘    └──────────┬──────────┘    └────────┬────────┘
                                │                        │
                    ┌───────────┴───────────┐            │
                    │                       │            │
                    ▼                       ▼            │
            ┌───────────────┐      ┌───────────────┐     │
            │ Driver        │      │ Carrier       │     │
            │ Profile       │      │ Profile       │     │
            └───────┬───────┘      └───────┬───────┘     │
                    │                      │             │
    ┌───────────────┼──────────────────────┼─────────────┤
    │               │                      │             │
    ▼               ▼                      ▼             ▼
┌────────┐  ┌────────────┐  ┌────────────────┐  ┌─────────────┐
│ Points │  │ Top 10     │  │ SPACE &        │  │ Conduct &   │
│ System │  │ Truckers   │  │ Tokens         │  │ Enforcement │
└────────┘  └────────────┘  └────────────────┘  └─────────────┘
    │               │                │
    ▼               ▼                ▼
┌────────────────────────────────────────────┐
│ Data Operations (Export/Backup/Import)     │
└────────────────────────────────────────────┘
```

---

## 8. PRD Index

### Core Foundation
| PRD | Name | Description |
|-----|------|-------------|
| PRD-001 | Auth & Provisioning | Invite-only onboarding, login, password lifecycle |
| PRD-002 | User Account & Roles | User entity, admin vs member, profile relationships |
| PRD-003 | Driver Profile | Driver identity, verification, skills, intent |
| PRD-004 | Carrier Profile | Carrier info, LineHaul List settings |
| PRD-005 | Admin Portal | All admin capabilities and operations |

### SPACE Economy
| PRD | Name | Description |
|-----|------|-------------|
| PRD-006 | Facilities | Terminal definitions and management |
| PRD-007 | SPACE Purchase | Package types, pricing, purchase flow |
| PRD-008 | Tokens & Access | Token lifecycle, assignment, QR codes |

### Incentives
| PRD | Name | Description |
|-----|------|-------------|
| PRD-009 | Points System | Earning rules, redemption, admin controls |
| PRD-010 | Top 10 Truckers | Referral program, badges, network |
| PRD-011 | Network Dividends | Post-Protect automatic earning |

### Engagement
| PRD | Name | Description |
|-----|------|-------------|
| PRD-012 | Driver Card | License-style resume, sharing |
| PRD-013 | My Carriers | Driver's saved carrier contacts |
| PRD-014 | Social Hub | Shareables, content distribution |
| PRD-015 | Sweepstakes | Two Cents program, voting |

### Governance
| PRD | Name | Description |
|-----|------|-------------|
| PRD-016 | Conduct & Enforcement | Code of Conduct, warnings, strikes |
| PRD-017 | Data Operations | Export, backup, import, restore |

---

## 9. Change Management

### 9.1 Impact Analysis Requirement

**Every PRD change must include an Impact Analysis:**

```markdown
## Impact Analysis

### Affected PRDs
- PRD-XXX: [What changes needed]
- PRD-YYY: [What changes needed]

### System Overview Updates
- [ ] Section X.X needs update
- [ ] New cross-cutting rule needed

### Base44 Changes Required
- [ ] Entity changes: [list]
- [ ] UI changes: [list]
- [ ] Logic changes: [list]
```

### 9.2 Version Control

- PRDs use semantic versioning: `v1.0`, `v1.1`, `v2.0`
- Major version = breaking changes (states, rules, permissions)
- Minor version = additions, clarifications
- All changes logged in PRD changelog

### 9.3 Conflict Resolution

If two PRDs contain conflicting rules:
1. System Overview takes precedence over individual PRDs
2. Lower-numbered PRDs take precedence (unless explicitly overridden)
3. Conflicts must be resolved before implementation

---

## 10. GitHub Repository Structure

```
/linehaulstation-docs/
│
├── README.md                           # Repo overview + quick start
│
├── /docs/
│   ├── /overview/
│   │   └── system-overview.md          # This document (the bible)
│   │
│   └── /prds/
│       ├── PRD-001-auth-provisioning.md
│       ├── PRD-002-user-account-roles.md
│       ├── PRD-003-driver-profile.md
│       ├── PRD-004-carrier-profile.md
│       ├── PRD-005-admin-portal.md
│       ├── PRD-006-facilities.md
│       ├── PRD-007-space-purchase.md
│       ├── PRD-008-tokens-access.md
│       ├── PRD-009-points-system.md
│       ├── PRD-010-top10-truckers.md
│       ├── PRD-011-network-dividends.md
│       ├── PRD-012-driver-card.md
│       ├── PRD-013-my-carriers.md
│       ├── PRD-014-social-hub.md
│       ├── PRD-015-sweepstakes.md
│       ├── PRD-016-conduct-enforcement.md
│       └── PRD-017-data-operations.md
│
├── /assets/
│   ├── /diagrams/                      # Mermaid, draw.io exports
│   └── /images/                        # Screenshots, mockups
│
├── /changelog/
│   └── CHANGELOG.md                    # System-wide change log
│
└── /templates/
    └── prd-template.md                 # Standard PRD format
```

---

## 11. Quick Reference

### Key Numbers

| Metric | Value | Source PRD |
|--------|-------|------------|
| Lead threshold | 10 referrals | PRD-010 |
| Guide threshold | 100 referrals | PRD-010 |
| Protect threshold | 1,000 referrals | PRD-010 |
| Free Night cost | 100 points | PRD-009 |
| Network dividend | 10 points/use | PRD-011 |
| Daily Pass price | $59 | PRD-007 |
| Flex 30 price | $8,500 | PRD-007 |
| Dedicated 365 price | $100,000 | PRD-007 |
| Annual dues | $395/year | PRD-007 |

### Key Formulas

```
Profile Setup Points = 25 (total possible)
Free Night = 100 points
10 network uses = 100 points = 1 Free Night (for Protectors)

Dedicated 365: $100,000 + $395/year = 365 passes
Flex 30: $8,500 + $395/year = 30 passes  
Daily Pass: $59 = 1 pass (no dues)
```

---

*Document Version: 2.0*  
*System Status: Pre-Launch / Beta*  
*Last Reviewed: January 28, 2026*
