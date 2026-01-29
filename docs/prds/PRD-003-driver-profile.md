# PRD-003: Driver Profile

**Version:** 1.0  
**Status:** Draft  
**Last Updated:** January 28, 2026  

---

## 1. Feature Identity

### 1.1 Name
Driver Profile

### 1.2 Portal(s)
- [x] Driver (primary)
- [ ] Carrier (view via shared card only)
- [x] Admin (management)

### 1.3 One-Line Summary
A professional identity snapshot that drivers build, maintain, and share with carriers—functioning as a portable driver resume.

### 1.4 Business Value
- **For Drivers:** Portable professional identity showcasing skills and experience
- **For Carriers:** Standardized view of driver qualifications for recruitment
- **For Platform:** Foundation for engagement features (points, referrals, access)

---

## 2. System Context

### 2.1 Dependencies
- System Overview — Global conventions
- PRD-001: Auth & Provisioning — User must be authenticated
- PRD-002: User Account & Roles — Profile extends User entity

### 2.2 Dependents
- PRD-008: Tokens & Access — Requires verified driver
- PRD-009: Points System — Awards points for profile completion
- PRD-010: Top 10 Truckers — Referral code from handle
- PRD-012: Driver Card — Renders profile as shareable card
- PRD-013: My Carriers — Links carriers to driver
- PRD-016: Conduct & Enforcement — Applies to driver standing

### 2.3 Integration Points
| System | Interaction Type | Description |
|--------|-----------------|-------------|
| User Account | 1:1 FK | Profile belongs to one user |
| Points System | Triggers | Profile events award points |
| Referral System | Reads | Generates referral code from handle |
| Conduct System | Writes | Standing status stored on profile |

---

## 3. Data Model

### 3.1 DriverProfile Entity

```
DriverProfile
├── driver_profile_id (UUID, PK)
├── user_id (UUID, FK → User, UNIQUE)
│
├── ═══════════════════════════════════════
├── # IDENTITY
├── ═══════════════════════════════════════
├── first_name (string, required)
├── last_name (string, required)
├── driver_handle (string, unique, 3-20 chars, locked after approval)
├── city (string, required)
├── state (string, required)
│
├── ═══════════════════════════════════════
├── # PHOTOS (3 slots)
├── ═══════════════════════════════════════
├── identifying_photo_url (string, required for verification)
├── personality_photo_url (string, optional)
├── outriders_avatar_url (string, admin-only upload)
│
├── ═══════════════════════════════════════
├── # CDL INFORMATION
├── ═══════════════════════════════════════
├── cdl_number (string, required)
├── cdl_issuing_state (string, required)
├── cdl_class (enum: A, B, C)
├── cdl_expiration_date (date, optional)
├── endorsements (JSON array: HAZMAT, TANKER, DOUBLES, TRIPLES, TWIC, etc.)
│
├── ═══════════════════════════════════════
├── # PROFESSIONAL HEADLINES
├── ═══════════════════════════════════════
├── years_of_experience (integer, required)
├── primary_equipment_types (JSON array, at least 1 required)
├── route_experience (JSON array: OTR, REGIONAL, LOCAL, DEDICATED, LINEHAUL)
├── special_certifications (JSON array)
├── one_line_bio (string, max 120 chars)
│
├── ═══════════════════════════════════════
├── # SKILLS SNAPSHOT (16 skills, each 1-5)
├── ═══════════════════════════════════════
├── skill_backing (integer 1-5)
├── skill_time_management (integer 1-5)
├── skill_route_planning (integer 1-5)
├── skill_communication (integer 1-5)
├── skill_safety_record (integer 1-5)
├── skill_equipment_handling (integer 1-5)
├── skill_load_securing (integer 1-5)
├── skill_documentation (integer 1-5)
├── skill_customer_service (integer 1-5)
├── skill_team_collaboration (integer 1-5)
├── skill_problem_solving (integer 1-5)
├── skill_adaptability (integer 1-5)
├── skill_technology_use (integer 1-5)
├── skill_fuel_efficiency (integer 1-5)
├── skill_regulatory_compliance (integer 1-5)
├── skill_night_driving (integer 1-5)
│
├── ═══════════════════════════════════════
├── # DRIVER INTENT
├── ═══════════════════════════════════════
├── open_to_opportunities (boolean)
├── preferred_work_styles (JSON array)
├── intent_headline (string, max 200 chars)
│
├── ═══════════════════════════════════════
├── # VERIFICATION
├── ═══════════════════════════════════════
├── verification_status (enum: PENDING, APPROVED, REJECTED)
├── verification_notes (string, admin-only)
├── verified_at (timestamp)
├── verified_by_admin_id (UUID, FK → User)
│
├── ═══════════════════════════════════════
├── # CODE OF CONDUCT
├── ═══════════════════════════════════════
├── code_of_conduct_accepted (boolean)
├── code_of_conduct_accepted_at (timestamp)
├── code_of_conduct_version (string)
│
├── ═══════════════════════════════════════
├── # MEMBERSHIP STANDING
├── ═══════════════════════════════════════
├── membership_standing (enum: GOOD_STANDING, UNDER_REVIEW, SUSPENDED, BANNED)
├── admin_internal_notes (text, admin-only)
│
├── ═══════════════════════════════════════
├── # TOP 10 TRUCKERS (see PRD-010)
├── ═══════════════════════════════════════
├── referral_code (string, unique, format: LH-[HANDLE]-[XXXX])
├── referred_by_driver_id (UUID, FK → DriverProfile)
├── referral_badge (enum: NEW_MEMBER, LEAD, GUIDE, PROTECT, OUTRIDER)
├── lead_count (integer)
├── guide_count (integer)
├── network_size (integer)
├── dividends_enabled (boolean)
│
├── ═══════════════════════════════════════
├── # CALCULATED
├── ═══════════════════════════════════════
├── profile_complete (boolean, calculated on save)
│
├── created_at (timestamp)
└── updated_at (timestamp)
```

### 3.2 Profile Completeness Calculation

A profile is complete when ALL of these are true:

```javascript
function isProfileComplete(profile) {
  return (
    profile.first_name &&
    profile.last_name &&
    profile.driver_handle &&
    profile.city &&
    profile.state &&
    profile.identifying_photo_url &&
    profile.cdl_number &&
    profile.cdl_issuing_state &&
    profile.cdl_class &&
    profile.years_of_experience !== null &&
    profile.primary_equipment_types?.length > 0 &&
    profile.code_of_conduct_accepted === true
  );
}
```

---

## 4. Three Photo System

### 4.1 Identifying Photo (Required)

**Purpose:** Verification, Driver Card display

**Requirements:**
- Clear face photo
- No sunglasses or hat obscuring face
- Well-lit, in focus
- JPG or PNG, max 5MB
- Min resolution: 200x200px

**Used In:**
- Admin verification review
- Driver Card (primary image)
- Profile display

### 4.2 Personality Photo (Optional)

**Purpose:** Humanize the profile, showcase personality

**Suggestions:**
- With their rig
- On the road
- At a destination
- Anything they're proud of

**Requirements:**
- JPG or PNG, max 5MB

**Used In:**
- Profile showcase
- Social sharing options

### 4.3 Outriders Avatar (Admin-Uploaded)

**Purpose:** Custom branded avatar for shareables

**How It Works:**
- Driver cannot upload this
- Admin creates and uploads
- Appears as greyed placeholder until uploaded
- Once uploaded, becomes downloadable

**Used In:**
- Shareables
- Sweepstakes graphics
- Social Hub content

---

## 5. States & Transitions

### 5.1 Verification Status

```
[PENDING] ──(admin approves)──► [APPROVED]
    │                               │
    │                               └─── (permanent, cannot change)
    │
    └──(admin rejects)──► [REJECTED] ──(user updates)──► [PENDING]
```

| Status | Description | Effects |
|--------|-------------|---------|
| PENDING | New or updated, awaiting review | Limited features |
| APPROVED | Verified by admin | Full features, handle locked |
| REJECTED | Needs corrections | User notified, can update |

**On APPROVED:**
- Handle becomes permanently locked
- Referral code generated
- Full points eligibility
- Token assignment eligibility

### 5.2 Membership Standing

See PRD-016 for full conduct system.

| Standing | Description | Effects |
|----------|-------------|---------|
| GOOD_STANDING | No issues | Full access |
| UNDER_REVIEW | Has active strike | May have warnings displayed |
| SUSPENDED | Account blocked | Cannot login (via User.account_status) |
| BANNED | Permanent removal | Cannot login (via User.account_status) |

---

## 6. Rules & Constraints

### 6.1 Business Rules

| ID | Rule | Enforcement |
|----|------|-------------|
| R1 | Driver handle must be 3-20 chars, alphanumeric + underscore | Validation |
| R2 | Driver handle is unique across all profiles | Database constraint |
| R3 | Driver handle is LOCKED after verification approval | Backend blocks update |
| R4 | Identifying photo required for verification approval | Admin UI enforces |
| R5 | Code of Conduct must be accepted for GOOD_STANDING | System enforces |
| R6 | Only admin can upload Outriders avatar | Permission check |
| R7 | Referral code auto-generated from handle | Backend generates |
| R8 | One DriverProfile per User | Database unique constraint |

### 6.2 Validation Rules

| Field | Validation | Error |
|-------|------------|-------|
| driver_handle | ^[A-Za-z0-9_]{3,20}$ | "3-20 characters, letters/numbers/underscores only" |
| identifying_photo_url | JPG/PNG, ≤5MB | "Must be JPG or PNG under 5MB" |
| years_of_experience | Integer 0-60 | "Enter valid years (0-60)" |
| one_line_bio | ≤120 chars | "Bio must be 120 characters or less" |
| skill_* | Integer 1-5 | "Rating must be 1-5" |

### 6.3 Field Limits

| Field | Limit |
|-------|-------|
| driver_handle | 3-20 characters |
| one_line_bio | 120 characters |
| intent_headline | 200 characters |
| Photo file size | 5MB |
| Avatar file size | 10MB |

---

## 7. User Experience

### 7.1 Profile Setup Flow

```
[Create Profile] → [Basic Info] → [Photos] → [CDL Info] → [Headlines] → [Skills] → [Intent] → [Code of Conduct] → [Submit]
```

**Step-by-step:**

1. **Basic Info**
   - First name, last name
   - City, state
   - Driver handle (with availability check)

2. **Photos**
   - Upload identifying photo (required)
   - Upload personality photo (optional)
   - Outriders avatar placeholder shown

3. **CDL Information**
   - CDL number, issuing state
   - Class (A/B/C)
   - Expiration date (optional)
   - Endorsements (multi-select)

4. **Professional Headlines**
   - Years of experience
   - Equipment types (multi-select)
   - Route experience (multi-select)
   - Certifications (multi-select)
   - One-line bio

5. **Skills Snapshot**
   - Rate 16 skills (1-5 stars)
   - Visual slider or star selector

6. **Driver Intent**
   - Open to opportunities? (yes/no)
   - Preferred work styles
   - Intent headline

7. **Code of Conduct**
   - Display full text
   - Checkbox acceptance
   - Cannot proceed without accepting

8. **Submit**
   - Review summary
   - Submit for verification
   - Status → PENDING

### 7.2 Empty States

| Condition | Display |
|-----------|---------|
| No photo uploaded | Placeholder with "Upload Photo" prompt |
| No skills rated | "Rate your skills to help carriers understand your strengths" |
| Incomplete profile | Progress indicator showing missing sections |
| Pending verification | "Your profile is under review" banner |
| Rejected | "Action Required: Please update your profile" with notes |

---

## 8. Admin Controls

### 8.1 Admin Actions on Driver Profile

| Action | Description | Confirmation? | Note Required? |
|--------|-------------|---------------|----------------|
| View profile | See all fields including internal | No | No |
| Edit any field | Override driver-entered data | No | Audit logged |
| Approve verification | Set status to APPROVED | Yes | No |
| Reject verification | Set status to REJECTED | Yes | Yes (reason) |
| Upload Outriders avatar | Add custom avatar | No | No |
| Download ID photo | Get copy for verification | No | No |
| Edit internal notes | Admin-only notes | No | No |

### 8.2 Admin Verification UI

```
Driver Verification: IRONHAULER_77
────────────────────────────────────────

Status: ⏳ PENDING

[Photo Preview]  Name: John Doe
                 Handle: IRONHAULER_77
                 Location: Memphis, TN
                 
CDL: Class A, Tennessee, #12345678
Endorsements: HAZMAT, TANKER, TWIC

Profile Complete: ✅ Yes
Code of Conduct: ✅ Accepted

────────────────────────────────────────

Admin Notes (internal):
[__________________________________]

[Reject with Reason]  [Approve Driver]
```

---

## 9. Events & Side Effects

### 9.1 Triggered Events

| Trigger | Event | Side Effects |
|---------|-------|--------------|
| Profile created | DRIVER_PROFILE_CREATED | Points account created, user flag updated |
| Profile saved | DRIVER_PROFILE_SAVED | Recalculate profile_complete, check points |
| Verification approved | DRIVER_VERIFIED | Lock handle, generate referral code, award points |
| Code of Conduct accepted | COC_ACCEPTED | Award points, update standing |
| Avatar uploaded | AVATAR_UPLOADED | Award points, notify driver |

### 9.2 Points Events

| Action | Points | Rule Key | One-Time? |
|--------|--------|----------|-----------|
| Profile approved | +5 | PROFILE_APPROVED | Yes |
| ID photo uploaded | +5 | ID_PHOTO_UPLOADED | Yes |
| Profile complete | +10 | PROFILE_COMPLETE | Yes |
| Code of Conduct accepted | +5 | CODE_OF_CONDUCT_ACCEPTED | Yes |
| Outriders avatar received | +10 | CUSTOM_AVATAR_RECEIVED | Yes |

See PRD-009 for full points rules.

### 9.3 Notifications

| Trigger | Recipient | Channel | Template |
|---------|-----------|---------|----------|
| Profile approved | Driver | Email + In-app | welcome_approved |
| Profile rejected | Driver | Email + In-app | profile_rejected |
| Avatar uploaded | Driver | In-app | avatar_ready |

---

## 10. Non-Goals

This PRD explicitly does NOT cover:
- ❌ Carrier profile fields (see PRD-004)
- ❌ Points system rules (see PRD-009)
- ❌ Referral program mechanics (see PRD-010)
- ❌ Conduct enforcement details (see PRD-016)
- ❌ Driver Card rendering (see PRD-012)
- ❌ CDL verification against DMV (manual admin review)
- ❌ Public profile URLs (invite-only platform)
- ❌ Profile visibility controls for drivers
- ❌ Employment history (not a traditional resume)

---

## 11. Impact Analysis Guidance

**When changing this PRD, check:**

| Change | Affected PRDs | Notes |
|--------|---------------|-------|
| Handle format | PRD-010 | Referral code uses handle |
| Verification states | PRD-008 | Token eligibility rules |
| Skills list | PRD-012 | Driver Card displays skills |
| Standing values | PRD-016 | Conduct enforcement |
| Photo fields | PRD-012, PRD-014 | Card and shareables |

---

## 12. Changelog

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | Jan 28, 2026 | Product Team | Initial draft |

---

## 13. Sign-Off

| Role | Name | Date | Approved |
|------|------|------|----------|
| Product | | | ☐ |
| Engineering | | | ☐ |
