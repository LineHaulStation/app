# LineHaul Station Documentation

Product Requirements Documents (PRDs) for the LineHaul Station platform.

---

## Quick Start

1. Read [`docs/overview/system-overview.md`](docs/overview/system-overview.md) first — this is the "bible"
2. Find the specific PRD for the feature you're working on in [`docs/prds/`](docs/prds/)
3. Use [`templates/prd-template.md`](templates/prd-template.md) when creating new PRDs

---

## Repository Structure

```
/linehaulstation-docs/
│
├── README.md                           # This file
│
├── /docs/
│   ├── /overview/
│   │   └── system-overview.md          # Platform bible
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
├── /templates/
│   └── prd-template.md                 # Standard PRD format
│
├── /assets/
│   └── (diagrams, images)
│
└── /changelog/
    └── CHANGELOG.md
```

---

## PRD Index

### Core Foundation
| # | Name | Description |
|---|------|-------------|
| 001 | Auth & Provisioning | Invite-only onboarding, login, passwords |
| 002 | User Account & Roles | User entity, Admin vs Member |
| 003 | Driver Profile | Driver identity, verification, skills |
| 004 | Carrier Profile | Carrier info, LineHaul List |
| 005 | Admin Portal | All admin capabilities |

### SPACE Economy
| # | Name | Description |
|---|------|-------------|
| 006 | Facilities | Terminal locations |
| 007 | SPACE Purchase | Package types, purchase flow |
| 008 | Tokens & Access | Token lifecycle, QR codes |

### Incentives
| # | Name | Description |
|---|------|-------------|
| 009 | Points System | Earning rules, redemption |
| 010 | Top 10 Truckers | Referral program, badges |
| 011 | Network Dividends | Post-Protect earnings |

### Engagement
| # | Name | Description |
|---|------|-------------|
| 012 | Driver Card | Shareable resume card |
| 013 | My Carriers | Driver's saved contacts |
| 014 | Social Hub | Shareables, content |
| 015 | Sweepstakes | Trucker's Two Cents |

### Governance
| # | Name | Description |
|---|------|-------------|
| 016 | Conduct & Enforcement | Code of Conduct, standing |
| 017 | Data Operations | Export, backup, import |

---

## Key Concepts

### Two User Classes
- **ADMIN:** Access to Driver + Carrier + Admin portals
- **MEMBER:** Access to Driver + Carrier portals only

### Profile Model
One user can have DriverProfile AND/OR CarrierProfile (supports owner-operators).

### Invite-Only
No public registration. All accounts are admin-provisioned.

### Points Economy
Backend-driven, state-based. No click-to-earn. Scarcity until Protect.

### Token System
Carriers purchase inventory → Assign to drivers → QR codes for terminal access.

---

## Development Workflow

1. **Find PRD** for the feature you're implementing
2. **Read System Overview** for cross-cutting rules
3. **Check Dependencies** listed in the PRD
4. **Generate Base44 prompt** from PRD requirements
5. **Update PRD** if implementation reveals gaps

---

## Key Numbers

| Metric | Value |
|--------|-------|
| Lead threshold | 10 referrals |
| Guide threshold | 100 referrals |
| Protect threshold | 1,000 referrals |
| Free Night cost | 100 points |
| Network dividend | 10 points/use |
| Daily Pass | $59 |
| Flex 30 | $8,500 |
| Dedicated 365 | $100,000 |
| Annual dues | $395/year |

---

## Contributing

1. Use the PRD template for new features
2. Include Impact Analysis for changes
3. Update System Overview if adding cross-cutting rules
4. All PRD changes require review before merge

---

*Last Updated: January 28, 2026*
