# PRD-004: Carrier Profile

**Version:** 1.0  
**Status:** Draft  
**Last Updated:** January 28, 2026  

---

## 1. Feature Identity

### 1.1 Name
Carrier Profile

### 1.2 Portal(s)
- [ ] Driver (view via LineHaul List only)
- [x] Carrier (primary)
- [x] Admin (management)

### 1.3 One-Line Summary
Company or owner-operator profile that enables SPACE purchases, token management, and optional LineHaul List visibility for driver recruitment.

### 1.4 Business Value
- **For Carriers:** Purchase and manage terminal access for drivers
- **For Drivers:** Discover carriers offering SPACE access
- **For Platform:** Revenue through SPACE purchases, recruitment channel

---

## 2. System Context

### 2.1 Dependencies
- System Overview — Global conventions
- PRD-001: Auth & Provisioning — User must be authenticated
- PRD-002: User Account & Roles — Profile extends User entity

### 2.2 Dependents
- PRD-007: SPACE Purchase — Requires CarrierProfile
- PRD-008: Tokens & Access — Carrier owns token inventory
- PRD-013: My Carriers — Drivers save carrier contacts

### 2.3 Integration Points
| System | Interaction Type | Description |
|--------|-----------------|-------------|
| User Account | 1:1 FK | Profile belongs to one user |
| Access Balance | 1:many | Carrier owns token inventory |
| Token System | 1:many | Carrier issues tokens to drivers |
| LineHaul List | Reads | Public carrier listing |

---

## 3. Data Model

### 3.1 CarrierProfile Entity

```
CarrierProfile
├── carrier_profile_id (UUID, PK)
├── user_id (UUID, FK → User, UNIQUE)
│
├── ═══════════════════════════════════════
├── # BASIC INFORMATION
├── ═══════════════════════════════════════
├── company_name (string, required)
├── contact_name (string, required)
├── contact_email (string, required)
├── contact_phone (string, optional but recommended)
│
├── ═══════════════════════════════════════
├── # OWNER-OPERATOR SUPPORT
├── ═══════════════════════════════════════
├── is_owner_operator (boolean, default false)
│   # If true, company_name can be driver's personal name
│
├── ═══════════════════════════════════════
├── # LINEHAUL LIST SETTINGS
├── ═══════════════════════════════════════
├── is_listed (boolean, default false)
│   # Whether carrier appears on LineHaul List
├── offer_packages (JSON array: SINGLE_DAY, 30_DAY, 100_DAY, ANNUAL)
│   # Which SPACE packages they offer to drivers
├── additional_notes (string, max 160 chars)
│   # Brief description for listing
├── logo_url (string, optional)
│   # Company logo for listing display
│
├── ═══════════════════════════════════════
├── # RECRUITER INFORMATION
├── ═══════════════════════════════════════
├── recruiter_name (string, optional)
├── recruiter_email (string, optional)
├── recruiter_phone (string, optional)
├── recruitment_link_url (string, optional)
│   # External application link
│
├── ═══════════════════════════════════════
├── # INTERNAL FLAGS
├── ═══════════════════════════════════════
├── is_internal_promotional (boolean, default false)
│   # TRUE for admin-owned promo carrier
├── carrier_profile_complete (boolean, calculated)
│
├── created_at (timestamp)
└── updated_at (timestamp)
```

### 3.2 Profile Completeness

A carrier profile is complete when:

```javascript
function isCarrierProfileComplete(profile) {
  return (
    profile.company_name &&
    profile.contact_name &&
    profile.contact_email
    // contact_phone is recommended but not required
  );
}
```

**Minimum for purchasing SPACE:**
- company_name
- contact_name
- contact_email

---

## 4. Owner-Operator Support

### 4.1 The Problem

Many drivers are **owner-operators** who need BOTH:
- A Driver Profile (their professional identity)
- A Carrier Profile (to purchase SPACE for themselves)

### 4.2 The Solution

When creating a Carrier Profile, owner-operators can:
1. Check "I am an owner-operator"
2. Use their personal name as company_name
3. Use the same contact info as their driver profile

**UI Helper Text:**
> "If you're an owner-operator, you can use your name as your carrier name. This lets you purchase SPACE access for yourself."

### 4.3 Self-Assignment

When a user has both profiles, they can:
- Purchase SPACE as their carrier
- Assign tokens to themselves as a driver
- "Assign to myself" option in token assignment flow

---

## 5. LineHaul List

### 5.1 What is LineHaul List?

A directory of carriers who offer SPACE access to drivers. Drivers can browse carriers and apply for positions/access.

### 5.2 Visibility Toggle

```
LineHaul List Visibility
────────────────────────────────────────

☐ List my company on the LineHaul List

When enabled, drivers can find your company and
apply for SPACE access through your recruitment link.
```

**When `is_listed = true`:**
- Carrier appears in LineHaul List
- Shows offer_packages badges
- Shows additional_notes
- Apply button links to recruitment_link_url

**When `is_listed = false`:**
- Carrier does NOT appear in list
- Carrier can still purchase and assign tokens manually

### 5.3 Offer Packages

Carriers select which SPACE packages they offer:

| Package | Badge | Description |
|---------|-------|-------------|
| SINGLE_DAY | "Single-Day" | Daily passes |
| 30_DAY | "30-Day" | Flex 30 packages |
| 100_DAY | "100-Day" | Medium-term access |
| ANNUAL | "Annual" | Dedicated 365 packages |

**Display:**
```
ABC Trucking
[30-Day] [Annual]
"Growing fleet looking for experienced OTR drivers..."
[Apply]
```

### 5.4 Internal Promotional Carrier

**Special Case:** Admin creates one internal carrier for promo fulfillment

```
company_name: "Lighthouse Station – Internal"
is_internal_promotional: true
is_listed: false (never public)
```

**Behavior:**
- NOT visible to drivers
- Holds promotional token inventory
- Used to fulfill point redemptions (Free Night)
- Admin purchases tokens through normal flow
- Admin assigns tokens as redemption fulfillment

---

## 6. States & Transitions

### 6.1 Profile Status

Carrier profiles are simpler than driver profiles:

```
[CREATED] ──(profile_complete = true)──► [ACTIVE]
```

| Status | Description | Can Purchase? | Can List? |
|--------|-------------|---------------|-----------|
| INCOMPLETE | Missing required fields | No | No |
| ACTIVE | All required fields present | Yes | Yes (if is_listed) |

### 6.2 No Verification Required

Unlike Driver Profiles, Carrier Profiles:
- Do NOT require admin verification
- Become active immediately when complete
- Can purchase SPACE immediately

---

## 7. Rules & Constraints

### 7.1 Business Rules

| ID | Rule | Enforcement |
|----|------|-------------|
| R1 | company_name required | Validation |
| R2 | contact_email required, valid format | Validation |
| R3 | One CarrierProfile per User | Database constraint |
| R4 | Must be complete to purchase SPACE | Business logic check |
| R5 | is_listed requires offer_packages | UI validation |
| R6 | Internal promo carrier never listed | System enforced |

### 7.2 Validation Rules

| Field | Validation | Error |
|-------|------------|-------|
| company_name | 1-200 chars | "Company name required" |
| contact_email | Valid email | "Please enter valid email" |
| additional_notes | ≤160 chars | "Notes limited to 160 characters" |
| recruitment_link_url | Valid URL or empty | "Please enter valid URL" |

### 7.3 Field Limits

| Field | Limit |
|-------|-------|
| company_name | 200 characters |
| additional_notes | 160 characters |
| Logo file size | 2MB |
| Logo dimensions | Min 100x100px |

---

## 8. User Experience

### 8.1 Profile Creation Flow

```
[Create Carrier Profile] → [Company Info] → [Contact Info] → [LineHaul List (Optional)] → [Complete]
```

**Step 1: Company Information**
```
Company Name *
[_________________________________]

☐ I am an owner-operator
  (Use your personal name as company name)
```

**Step 2: Contact Information**
```
Contact Name *
[_________________________________]

Contact Email *
[_________________________________]

Contact Phone (Recommended)
[_________________________________]
```

**Step 3: LineHaul List (Optional)**
```
LineHaul List Visibility
────────────────────────────────────────

☐ List my company on the LineHaul List

If listed, complete the following:

Packages Offered
☐ Single-Day  ☐ 30-Day  ☐ 100-Day  ☐ Annual

Company Logo
[Upload Logo]

About Your Company (160 chars)
[_________________________________]

Recruitment Link
[_________________________________]
(Where should interested drivers apply?)

Recruiter Contact (Optional)
Name: [_______________]
Email: [_______________]
Phone: [_______________]
```

### 8.2 Carrier Dashboard

After profile completion, carrier sees:

```
Carrier Dashboard
────────────────────────────────────────

Welcome, ABC Trucking!

MY SPACE ACCESS
────────────────────────────────────────
West Memphis Terminal
• Flex 30: 25 passes remaining
• Daily Passes: 10 remaining

[Purchase More]  [Assign to Driver]

────────────────────────────────────────

LINEHAUL LIST
────────────────────────────────────────
Status: Listed ✅
Packages: 30-Day, Annual
[Edit Listing]

────────────────────────────────────────

RECENT ACTIVITY
────────────────────────────────────────
• Token assigned to IRONHAULER_77
• 30 Daily Passes purchased
```

---

## 9. Admin Controls

### 9.1 Admin Actions

| Action | Description | Confirmation? | Note? |
|--------|-------------|---------------|-------|
| View profile | See all fields | No | No |
| Edit any field | Override carrier data | No | Audit logged |
| Toggle is_listed | Force list/unlist | No | No |
| Create internal carrier | For promo inventory | Yes | Yes |

### 9.2 Admin View

```
Carrier Profile: ABC Trucking
────────────────────────────────────────

User: jane@abctrucking.com
Profile Complete: ✅ Yes
Created: Jan 15, 2026

Company: ABC Trucking
Contact: Jane Smith
Email: jane@abctrucking.com
Phone: (555) 123-4567

Owner-Operator: No
Internal Promo: No

LineHaul List: ✅ Listed
Packages: 30-Day, Annual
Recruitment: https://abctrucking.com/apply

────────────────────────────────────────

ACCESS BALANCES
────────────────────────────────────────
West Memphis | Flex 30 | 25/30 remaining
West Memphis | Daily   | 10/10 remaining

[Edit Profile]  [View Tokens]
```

---

## 10. Events & Side Effects

### 10.1 Triggered Events

| Trigger | Event | Side Effects |
|---------|-------|--------------|
| Profile created | CARRIER_PROFILE_CREATED | User flag updated |
| Profile completed | CARRIER_PROFILE_COMPLETED | Enable purchase |
| Listed on LineHaul | CARRIER_LISTED | Visible to drivers |
| Unlisted | CARRIER_UNLISTED | Hidden from list |

### 10.2 No Points for Carrier Profile

Unlike Driver Profile, there are **no points** for carrier profile actions. Points are driver-focused.

---

## 11. Non-Goals

This PRD explicitly does NOT cover:
- ❌ Driver profile fields (see PRD-003)
- ❌ SPACE purchase flow (see PRD-007)
- ❌ Token management (see PRD-008)
- ❌ Driver roster management
- ❌ Carrier verification/vetting
- ❌ Payment processing
- ❌ Multiple users per carrier (one profile per user)

---

## 12. Impact Analysis Guidance

**When changing this PRD, check:**

| Change | Affected PRDs | Notes |
|--------|---------------|-------|
| Required fields | PRD-007 | Purchase eligibility |
| LineHaul List fields | PRD-003 (driver view) | Display in list |
| Internal promo flag | PRD-009 | Redemption fulfillment |
| Owner-operator support | PRD-003 | Cross-profile features |

---

## 13. Changelog

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | Jan 28, 2026 | Product Team | Initial draft |

---

## 14. Sign-Off

| Role | Name | Date | Approved |
|------|------|------|----------|
| Product | | | ☐ |
| Engineering | | | ☐ |
