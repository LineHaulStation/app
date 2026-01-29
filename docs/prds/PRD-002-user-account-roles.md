# PRD-002: User Account & Roles

**Version:** 1.0  
**Status:** Draft  
**Last Updated:** January 28, 2026  

---

## 1. Feature Identity

### 1.1 Name
User Account & Roles

### 1.2 Portal(s)
- [x] Driver
- [x] Carrier
- [x] Admin

### 1.3 One-Line Summary
Defines the user entity structure, the relationship between accounts and profiles, and the two-class role system (Admin vs Member).

### 1.4 Business Value
- **Simplicity:** Single account, multiple capabilities (no multiple logins)
- **Flexibility:** Owner-operators can be both Driver and Carrier
- **Security:** Clear separation between Admin and Member access
- **Scalability:** Profile-based access enables gradual feature rollout

---

## 2. System Context

### 2.1 Dependencies
- System Overview — Defines platform structure
- PRD-001: Auth & Provisioning — Creates user accounts

### 2.2 Dependents
- PRD-003: Driver Profile — Extends user with driver capabilities
- PRD-004: Carrier Profile — Extends user with carrier capabilities
- PRD-005: Admin Portal — Uses role checks for access
- All other PRDs — Reference user entity

### 2.3 Integration Points
| System | Interaction Type | Description |
|--------|-----------------|-------------|
| Auth System | Reads | Validates user exists and is active |
| Driver Profile | 1:1 | Optional extension of user |
| Carrier Profile | 1:1 | Optional extension of user |
| All Features | Reads | Permission checks based on role |

---

## 3. User Model

### 3.1 Two User Classes

LineHaul Station has exactly **two user classes**:

| Class | Value | Portal Access | Description |
|-------|-------|---------------|-------------|
| **ADMIN** | `user_class = 'ADMIN'` | Driver + Carrier + Admin | Platform operators |
| **MEMBER** | `user_class = 'MEMBER'` | Driver + Carrier | Standard users |

**Key Points:**
- There is NO "Driver-only" or "Carrier-only" role
- All Members have the same base permissions
- Portal access depends on profile existence, not role
- Only Admins can access Admin Portal

### 3.2 Profile Relationship

```
┌─────────────────────────────────────────────────────────────────┐
│                         User Account                            │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  user_id, email, user_class, account_status             │   │
│  └─────────────────────────────────────────────────────────┘   │
│                              │                                  │
│              ┌───────────────┴───────────────┐                  │
│              │                               │                  │
│              ▼                               ▼                  │
│  ┌─────────────────────┐       ┌─────────────────────┐         │
│  │   DriverProfile     │       │   CarrierProfile    │         │
│  │   (0 or 1)          │       │   (0 or 1)          │         │
│  └─────────────────────┘       └─────────────────────┘         │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

A user can have:
- **Neither profile** — Account exists but limited portal access
- **DriverProfile only** — Access to Driver Portal
- **CarrierProfile only** — Access to Carrier Portal
- **Both profiles** — Access to both portals (owner-operators)

### 3.3 is_admin Flag

The `is_admin` flag is a **computed/derived** field:

```
is_admin = (user_class == 'ADMIN')
```

This flag is used for quick permission checks throughout the system.

---

## 4. Data Model

### 4.1 User Entity (Complete)

```
User
├── user_id (UUID, PK)
├── email (string, unique, required)
├── password_hash (string, nullable)
│
├── # Identity
├── first_name (string, optional)
├── last_name (string, optional)
│
├── # Role
├── user_class (enum: MEMBER, ADMIN, required)
├── is_admin (boolean, computed: user_class == ADMIN)
│
├── # Account State (from PRD-001)
├── account_status (enum: PROVISIONED, ACTIVE, SUSPENDED, BANNED)
├── password_set (boolean)
├── must_change_password (boolean)
│
├── # Profile References (computed/cached)
├── has_driver_profile (boolean, computed)
├── has_carrier_profile (boolean, computed)
│
├── # Audit
├── provisioned_by_admin_id (UUID, FK → User)
├── provisioned_at (timestamp)
├── last_login_at (timestamp, nullable)
├── login_count (integer, default 0)
│
├── created_at (timestamp)
└── updated_at (timestamp)
```

### 4.2 Related Entities

```
DriverProfile
├── driver_profile_id (UUID, PK)
├── user_id (UUID, FK → User, UNIQUE)
└── ... (see PRD-003)

CarrierProfile
├── carrier_profile_id (UUID, PK)
├── user_id (UUID, FK → User, UNIQUE)
└── ... (see PRD-004)
```

### 4.3 Key Constraints

| Constraint | Description |
|------------|-------------|
| user_id unique | One account per email |
| DriverProfile.user_id unique | Max one driver profile per user |
| CarrierProfile.user_id unique | Max one carrier profile per user |
| At least one ADMIN | System must have at least one admin |

---

## 5. Portal Access Rules

### 5.1 Access Matrix

| Portal | Requires | Member | Admin |
|--------|----------|--------|-------|
| Driver Portal | DriverProfile exists | ✅ | ✅ |
| Carrier Portal | CarrierProfile exists | ✅ | ✅ |
| Admin Portal | is_admin = true | ❌ | ✅ |

### 5.2 Portal Access Logic

```javascript
function canAccessPortal(user, portal) {
  // Check account is active
  if (user.account_status !== 'ACTIVE') {
    return false;
  }
  
  switch (portal) {
    case 'DRIVER':
      return user.has_driver_profile;
      
    case 'CARRIER':
      return user.has_carrier_profile;
      
    case 'ADMIN':
      return user.is_admin;
      
    default:
      return false;
  }
}
```

### 5.3 Navigation Display

**For Members:**
```
┌─────────────────────────────────────────────────┐
│  [Driver]   [Carrier]                           │
└─────────────────────────────────────────────────┘
         ↑          ↑
    (if profile) (if profile)
```

**For Admins:**
```
┌─────────────────────────────────────────────────┐
│  [Driver]   [Carrier]   [Admin]                 │
└─────────────────────────────────────────────────┘
         ↑          ↑          ↑
    (if profile) (if profile) (always)
```

### 5.4 Missing Profile Behavior

When user clicks a portal tab but doesn't have the required profile:

**Option A: Redirect to Create Profile**
```
User clicks [Carrier] tab but has no CarrierProfile
→ Redirect to /carrier/create-profile
→ Show: "Set up your Carrier Profile to access this area"
```

**Option B: Disabled Tab with Prompt**
```
Tab shows as disabled with tooltip:
"Create a Carrier Profile to access this area"
[Create Profile] button
```

**Recommendation:** Option A (redirect) for cleaner UX.

---

## 6. Role Management

### 6.1 Changing User Class

**Who can change:**
- Only Admins can change user_class
- Admin cannot demote themselves (prevents lockout)
- System prevents removing last Admin

**Change Flow:**
```
[Admin Portal] → [User Detail] → [Edit Role]
                                      │
                                      ▼
                               [Select: Member / Admin]
                                      │
                                      ▼
                               [Confirmation Required]
                               "Change John Doe to Admin?"
                                      │
                                      ▼
                               [Save + Audit Log]
```

### 6.2 Role Change Effects

| Change | Effect |
|--------|--------|
| Member → Admin | Gains Admin Portal access immediately |
| Admin → Member | Loses Admin Portal access immediately |
| Admin → Member (last admin) | BLOCKED — must have at least one admin |

### 6.3 Audit Requirements

All role changes logged with:
- user_id (target)
- admin_id (who made change)
- old_class
- new_class
- timestamp
- reason (optional note)

---

## 7. Profile Creation

### 7.1 When Profiles Are Created

**DriverProfile:**
- User navigates to Driver Portal (first time)
- Clicks "Create Driver Profile" or auto-redirected
- Completes required fields
- Profile created and linked to user

**CarrierProfile:**
- User navigates to Carrier Portal (first time)
- Clicks "Create Carrier Profile" or auto-redirected
- Completes required fields
- Profile created and linked to user

### 7.2 Profile Creation Flow

```
[User logs in] 
      │
      ▼
[Check profile existence]
      │
      ├─── has_driver_profile? ───► [Driver Portal enabled]
      │
      ├─── has_carrier_profile? ──► [Carrier Portal enabled]
      │
      └─── neither? ────────────────► [Prompt to create profile]
                                      "Welcome! Choose your path:"
                                      [I'm a Driver] [I'm a Carrier] [Both]
```

### 7.3 Admin Profile Management

Admins can:
- View any user's profiles
- Edit any user's profiles
- Create profiles on behalf of users
- Delete profiles (soft delete)

---

## 8. States & Transitions

### 8.1 User Account States

See PRD-001 for full account state diagram.

| State | Driver Portal | Carrier Portal | Admin Portal |
|-------|---------------|----------------|--------------|
| PROVISIONED | ❌ | ❌ | ❌ |
| ACTIVE | If profile exists | If profile exists | If is_admin |
| SUSPENDED | ❌ | ❌ | ❌ |
| BANNED | ❌ | ❌ | ❌ |

### 8.2 Profile Existence States

```
User Account
├── No profiles → Limited access
├── DriverProfile only → Driver Portal
├── CarrierProfile only → Carrier Portal
└── Both profiles → Both portals
```

---

## 9. Rules & Constraints

### 9.1 Business Rules

| ID | Rule | Enforcement |
|----|------|-------------|
| R1 | User can have max 1 DriverProfile | Database unique constraint |
| R2 | User can have max 1 CarrierProfile | Database unique constraint |
| R3 | is_admin computed from user_class | Application logic |
| R4 | System must have ≥1 Admin | Prevent demotion/deletion of last admin |
| R5 | Admin cannot demote self | Validation on role change |
| R6 | Profiles cannot be transferred between users | No user_id updates allowed |

### 9.2 Validation Rules

| Field | Validation | Error Message |
|-------|------------|---------------|
| email | Valid email format | "Please enter a valid email" |
| email | Unique (case-insensitive) | "This email is already registered" |
| user_class | MEMBER or ADMIN | "Invalid user class" |

---

## 10. Admin Controls

### 10.1 User Management (Role-Specific)

| Action | Description | Confirmation? | Audit? |
|--------|-------------|---------------|--------|
| View user | See account + profile status | No | No |
| Change to Admin | Promote to admin class | Yes | Yes |
| Change to Member | Demote to member class | Yes | Yes |
| Create profile for user | Add Driver/Carrier profile | No | Yes |

### 10.2 Admin User List View

```
Users
────────────────────────────────────────────────────────────────

[Search: _______________] [Filter: All / Admin / Member ▼]

Name              Email                 Class    Profiles    Status
─────────────────────────────────────────────────────────────────
John Doe          john@example.com      Member   [D] [C]     Active
Jane Smith        jane@carrier.com      Member   [C]         Active
Admin User        admin@linehaul.com    Admin    [D] [C]     Active
New Driver        new@driver.com        Member   [D]         Active
Pending User      pending@example.com   Member   —           Provisioned

[D] = Has DriverProfile
[C] = Has CarrierProfile
```

---

## 11. Events & Side Effects

### 11.1 Triggered Events

| Trigger | Event | Side Effects |
|---------|-------|--------------|
| User class changed | USER_CLASS_CHANGED | Audit log, session refresh |
| DriverProfile created | DRIVER_PROFILE_CREATED | Update has_driver_profile, points account created |
| CarrierProfile created | CARRIER_PROFILE_CREATED | Update has_carrier_profile |
| Profile deleted | PROFILE_DELETED | Update has_*_profile flag |

### 11.2 Computed Field Updates

When profiles change, update cached flags:
```javascript
await User.update({
  has_driver_profile: await DriverProfile.exists({ user_id }),
  has_carrier_profile: await CarrierProfile.exists({ user_id })
});
```

---

## 12. Non-Goals

This feature explicitly does NOT:
- ❌ Support multiple driver profiles per user
- ❌ Support multiple carrier profiles per user
- ❌ Support granular permissions beyond Admin/Member
- ❌ Support role-based feature toggles (beyond portal access)
- ❌ Support organization/company accounts (users are individuals)
- ❌ Support profile sharing between users

---

## 13. Impact Analysis Guidance

**When changing this PRD, check:**

| Change | Affected PRDs | Notes |
|--------|---------------|-------|
| User entity fields | PRD-001, PRD-003, PRD-004 | All reference User |
| Role definitions | PRD-005 | Admin Portal access rules |
| Profile relationship | PRD-003, PRD-004 | One-to-one constraints |
| Access rules | All PRDs | Permission checks throughout |

---

## 14. Open Questions

| Question | Status | Resolution |
|----------|--------|------------|
| Should admins auto-have both profiles? | Open | Consider auto-creating |
| Profile deletion vs deactivation? | Open | Soft delete recommended |

---

## 15. Changelog

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | Jan 28, 2026 | Product Team | Initial draft |

---

## 16. Sign-Off

| Role | Name | Date | Approved |
|------|------|------|----------|
| Product | | | ☐ |
| Engineering | | | ☐ |
