# PRD-001: Auth & Provisioning

**Version:** 1.0  
**Status:** Draft  
**Last Updated:** January 28, 2026  

---

## 1. Feature Identity

### 1.1 Name
Authentication & User Provisioning

### 1.2 Portal(s)
- [x] Driver (login only)
- [x] Carrier (login only)
- [x] Admin (full provisioning controls)
- [x] Public (login page only)

### 1.3 One-Line Summary
Invite-only account creation, authentication, password management, and access control for a private membership platform.

### 1.4 Business Value
- **Security:** No unauthorized access; all accounts are admin-vetted
- **Quality Control:** Curated membership base of professional drivers and carriers
- **Compliance:** Full audit trail of account lifecycle
- **Scalability:** Bulk provisioning for efficient onboarding

---

## 2. System Context

### 2.1 Dependencies
- System Overview — Defines user classes (Admin vs Member)

### 2.2 Dependents
- PRD-002: User Account & Roles — Uses authentication state
- PRD-003: Driver Profile — Requires authenticated user
- PRD-004: Carrier Profile — Requires authenticated user
- PRD-005: Admin Portal — Requires admin authentication
- All other PRDs — Require authenticated session

### 2.3 Integration Points
| System | Interaction Type | Description |
|--------|-----------------|-------------|
| Email Service | Sends | Password invite links, notifications |
| Audit Log | Writes | All auth events logged |
| Session Management | Reads/Writes | Login/logout state |

---

## 3. Core Principle: Invite-Only

### 3.1 No Public Registration

**There is NO public sign-up form.**

- The `/signup` or `/register` route does NOT exist
- The login page shows only: Email + Password + Login button
- No "Create Account" or "Sign Up" links visible to public
- All accounts must be created by an Admin

### 3.2 Provisioning Authority

Only users with `is_admin = true` can:
- Create new accounts
- Import accounts in bulk
- Reset passwords
- Disable/enable accounts
- Delete accounts

---

## 4. Account Provisioning

### 4.1 Single Account Creation

**Admin Flow:**
1. Admin navigates to Admin Portal → Users → Add User
2. Admin enters:
   - Email (required, must be unique)
   - First Name (optional)
   - Last Name (optional)
   - User Class: Member or Admin
3. Admin selects password method:
   - **Option A:** Set initial password manually
   - **Option B:** Send invite link (user sets own password)
4. System creates account
5. System logs provisioning event

**Option A: Admin Sets Password**
```
Account created with:
- status: ACTIVE
- password_set: true
- must_change_password: true (recommended)

Admin provides password to user out-of-band
User must change password on first login
```

**Option B: Invite Link**
```
Account created with:
- status: PROVISIONED
- password_set: false
- invite_token: [random secure token]
- invite_expires_at: [48 hours from now]

System sends email with link:
https://linehaulstation.com/set-password?token=XXXXX

User clicks link, sets password
Account status changes to ACTIVE
```

### 4.2 Bulk Import

**Admin Flow:**
1. Admin navigates to Admin Portal → Users → Import Users
2. Admin uploads CSV or JSON file
3. System validates file format and data
4. System shows preview with validation results
5. Admin confirms import
6. System creates accounts + sends invite links (if selected)
7. System provides import report

**CSV Format:**
```csv
email,first_name,last_name,user_class,send_invite
john@example.com,John,Doe,MEMBER,true
jane@carrier.com,Jane,Smith,MEMBER,true
admin@linehaul.com,Admin,User,ADMIN,false
```

**JSON Format:**
```json
{
  "users": [
    {
      "email": "john@example.com",
      "first_name": "John",
      "last_name": "Jane",
      "user_class": "MEMBER",
      "send_invite": true
    }
  ]
}
```

**Validation Rules:**
| Field | Validation | Error Handling |
|-------|------------|----------------|
| email | Valid format, unique | Skip duplicate, log error |
| user_class | MEMBER or ADMIN | Default to MEMBER |
| send_invite | Boolean | Default to true |

**Import Limits:**
- Max 500 users per import
- Duplicate emails skipped (not error)
- Invalid rows logged, valid rows processed

---

## 5. Data Model

### 5.1 User Entity (Auth Fields)

```
User
├── user_id (UUID, PK)
├── email (string, unique, required)
├── password_hash (string, nullable until set)
├── first_name (string, optional)
├── last_name (string, optional)
│
├── # Role
├── user_class (enum: MEMBER, ADMIN)
├── is_admin (boolean, computed: user_class == ADMIN)
│
├── # Account State
├── account_status (enum: PROVISIONED, ACTIVE, SUSPENDED, BANNED)
├── password_set (boolean)
├── must_change_password (boolean)
│
├── # Invite
├── invite_token (string, nullable)
├── invite_token_expires_at (timestamp, nullable)
├── invite_sent_at (timestamp, nullable)
│
├── # Password Reset
├── password_reset_token (string, nullable)
├── password_reset_expires_at (timestamp, nullable)
├── password_reset_requested_at (timestamp, nullable)
│
├── # Session
├── last_login_at (timestamp, nullable)
├── login_count (integer, default 0)
│
├── # Provisioning
├── provisioned_by_admin_id (UUID, FK → User)
├── provisioned_at (timestamp)
│
├── created_at (timestamp)
└── updated_at (timestamp)
```

### 5.2 Auth Event Log

```
AuthEvent
├── event_id (UUID, PK)
├── user_id (UUID, FK → User)
├── event_type (enum: see below)
├── ip_address (string)
├── user_agent (string)
├── admin_id (UUID, nullable, FK → User) # if admin-initiated
├── metadata (JSON) # additional context
├── created_at (timestamp)
```

**Event Types:**
- ACCOUNT_CREATED
- INVITE_SENT
- INVITE_ACCEPTED
- PASSWORD_SET
- PASSWORD_CHANGED
- PASSWORD_RESET_REQUESTED
- PASSWORD_RESET_COMPLETED
- LOGIN_SUCCESS
- LOGIN_FAILED
- LOGOUT
- ACCOUNT_SUSPENDED
- ACCOUNT_REINSTATED
- ACCOUNT_BANNED

---

## 6. States & Transitions

### 6.1 Account Status States

```
                    ┌─────────────────────────────────────────────┐
                    │                                             │
[PROVISIONED] ──(set password)──► [ACTIVE] ──(admin suspends)──► [SUSPENDED]
       │                              │                               │
       │                              │                               │
       │                              └──(admin bans)──► [BANNED]     │
       │                                                              │
       │                              (admin reinstates)◄─────────────┘
       │
       └──(invite expires, no action)──► [PROVISIONED] (stays, can resend)
```

### 6.2 State Definitions

| State | Description | Can Login? | Actions Available |
|-------|-------------|------------|-------------------|
| PROVISIONED | Account created, password not set | No | Set password via invite |
| ACTIVE | Normal operational state | Yes | All portal access |
| SUSPENDED | Temporarily blocked by admin | No | None (must contact admin) |
| BANNED | Permanently removed | No | None (cannot recover) |

### 6.3 Irreversible Transitions

⚠️ **Cannot be undone:**
- BANNED status is permanent (account cannot be unbanned)
- Deleted accounts cannot be recovered (use soft delete)

---

## 7. Authentication Flows

### 7.1 Login Flow

```
[Login Page] ──► [Enter Email + Password] ──► [Validate]
                                                  │
                    ┌─────────────────────────────┼─────────────────────┐
                    │                             │                     │
                    ▼                             ▼                     ▼
             [Invalid Credentials]         [Account Not Active]    [Success]
                    │                             │                     │
                    ▼                             ▼                     ▼
             "Invalid email or password"   "Account suspended"    [Check must_change_password]
                                           "Contact admin"              │
                                                              ┌────────┴────────┐
                                                              │                 │
                                                              ▼                 ▼
                                                        [Force Change]    [Dashboard]
                                                              │
                                                              ▼
                                                        [New Password Set]
                                                              │
                                                              ▼
                                                        [Dashboard]
```

**Login Validation:**
1. Find user by email (case-insensitive)
2. If not found → "Invalid email or password" (don't reveal which)
3. If found, check account_status:
   - PROVISIONED → "Please check your email for invite link"
   - SUSPENDED → "Your account has been suspended. Contact admin."
   - BANNED → "Invalid email or password" (don't reveal banned)
   - ACTIVE → Continue
4. Verify password hash
5. If invalid → "Invalid email or password"
6. If valid → Create session, log event, redirect

**Post-Login Checks:**
- If `must_change_password = true` → Redirect to change password
- If `must_change_password = false` → Redirect to appropriate portal

### 7.2 Set Password (Invite) Flow

```
[Receive Invite Email] ──► [Click Link] ──► [Validate Token]
                                                  │
                            ┌─────────────────────┼─────────────────┐
                            │                     │                 │
                            ▼                     ▼                 ▼
                     [Token Invalid]       [Token Expired]     [Token Valid]
                            │                     │                 │
                            ▼                     ▼                 ▼
                     "Invalid link"        "Link expired"     [Set Password Form]
                     "Contact admin"       "Contact admin"          │
                                                                    ▼
                                                             [Enter Password]
                                                             [Confirm Password]
                                                                    │
                                                                    ▼
                                                             [Validate]
                                                                    │
                                                                    ▼
                                                             [Account ACTIVE]
                                                             [Redirect to Login]
```

**Token Validation:**
- Token must match `invite_token`
- Current time must be before `invite_token_expires_at`
- Account status must be PROVISIONED

**Password Requirements:**
- Minimum 8 characters
- At least one uppercase letter
- At least one lowercase letter
- At least one number
- At least one special character (!@#$%^&*)

### 7.3 Change Password Flow (Logged In)

```
[Profile Settings] ──► [Change Password] ──► [Enter Current Password]
                                                      │
                                                      ▼
                                               [Validate Current]
                                                      │
                                    ┌─────────────────┴─────────────────┐
                                    │                                   │
                                    ▼                                   ▼
                             [Invalid]                            [Valid]
                                    │                                   │
                                    ▼                                   ▼
                             "Incorrect password"              [Enter New Password]
                                                               [Confirm New Password]
                                                                        │
                                                                        ▼
                                                               [Validate + Save]
                                                                        │
                                                                        ▼
                                                               "Password changed"
                                                               [Clear must_change_password]
```

### 7.4 Password Reset Flow (Admin-Initiated)

**There is NO self-service "Forgot Password" flow.**

Password resets are admin-initiated only:

```
[Admin Portal] ──► [Find User] ──► [Reset Password]
                                          │
                         ┌────────────────┴────────────────┐
                         │                                 │
                         ▼                                 ▼
                  [Set New Password]              [Send Reset Link]
                         │                                 │
                         ▼                                 ▼
                  [Set must_change = true]         [Generate Token]
                  [Notify Admin Complete]          [Send Email]
                                                          │
                                                          ▼
                                                   [User Clicks Link]
                                                   [Sets New Password]
```

**Admin Reset Options:**
1. **Set password directly** — Admin enters new password, user must change on login
2. **Send reset link** — Similar to invite flow, user sets own password

---

## 8. Rules & Constraints

### 8.1 Business Rules

| ID | Rule | Enforcement |
|----|------|-------------|
| R1 | No public registration | No signup routes exist |
| R2 | All accounts created by Admin | provisioned_by_admin_id required |
| R3 | Email must be unique (case-insensitive) | Database constraint |
| R4 | Invite links expire after 48 hours | Token expiration check |
| R5 | Password reset links expire after 24 hours | Token expiration check |
| R6 | BANNED accounts cannot be recovered | State transition blocked |
| R7 | Admin cannot ban themselves | Validation check |
| R8 | Must be at least one Admin account | Prevent last admin deletion |

### 8.2 Password Rules

| Rule | Value | Configurable? |
|------|-------|---------------|
| Minimum length | 8 characters | Yes |
| Require uppercase | Yes | Yes |
| Require lowercase | Yes | Yes |
| Require number | Yes | Yes |
| Require special char | Yes | Yes |
| Password history | None (v1) | Future |
| Max login attempts | 5 (then lockout) | Yes |
| Lockout duration | 15 minutes | Yes |

### 8.3 Session Rules

| Rule | Value | Configurable? |
|------|-------|---------------|
| Session timeout (inactive) | 24 hours | Yes |
| Session timeout (absolute) | 7 days | Yes |
| Concurrent sessions | Unlimited | Yes |
| Remember me option | No (v1) | Future |

---

## 9. Admin Controls

### 9.1 User Management Actions

| Action | Description | Confirmation? | Note Required? |
|--------|-------------|---------------|----------------|
| Create user | Add single account | No | No |
| Import users | Bulk add accounts | Yes | No |
| View user | See account details | No | No |
| Edit user | Change email, name, class | No | No (audit logged) |
| Reset password | Force password change | Yes | Optional |
| Resend invite | New invite link | No | No |
| Suspend user | Block login | Yes | Yes |
| Reinstate user | Restore from suspended | Yes | Yes |
| Ban user | Permanent removal | Yes (typed phrase) | Yes |
| Delete user | Soft delete account | Yes | Yes |

### 9.2 Admin Dashboard Widgets

**User Stats:**
- Total accounts
- Active accounts
- Pending invites (not yet accepted)
- Suspended accounts

**Recent Activity:**
- Recent logins
- Recent provisioning
- Recent suspensions

---

## 10. User Interface

### 10.1 Public Login Page

```
┌────────────────────────────────────────────────┐
│                                                │
│            [LineHaul Station Logo]             │
│                                                │
│         ─────────────────────────────          │
│                                                │
│         Email                                  │
│         [_________________________________]    │
│                                                │
│         Password                               │
│         [_________________________________]    │
│                                                │
│         [        Log In        ]               │
│                                                │
│         ─────────────────────────────          │
│                                                │
│         Need an account?                       │
│         LineHaul Station is invite-only.       │
│         Contact your administrator.            │
│                                                │
└────────────────────────────────────────────────┘
```

**No "Sign Up" or "Forgot Password" links visible.**

### 10.2 Set Password Page (Invite)

```
┌────────────────────────────────────────────────┐
│                                                │
│            [LineHaul Station Logo]             │
│                                                │
│            Welcome to LineHaul Station         │
│            Set your password to get started    │
│                                                │
│         ─────────────────────────────          │
│                                                │
│         Email: john@example.com (readonly)     │
│                                                │
│         Password                               │
│         [_________________________________]    │
│         • 8+ characters                        │
│         • Uppercase and lowercase              │
│         • At least one number                  │
│         • At least one special character       │
│                                                │
│         Confirm Password                       │
│         [_________________________________]    │
│                                                │
│         [      Set Password      ]             │
│                                                │
└────────────────────────────────────────────────┘
```

### 10.3 Force Change Password Page

```
┌────────────────────────────────────────────────┐
│                                                │
│            Password Change Required            │
│                                                │
│         Your administrator requires you        │
│         to change your password.               │
│                                                │
│         ─────────────────────────────          │
│                                                │
│         New Password                           │
│         [_________________________________]    │
│                                                │
│         Confirm Password                       │
│         [_________________________________]    │
│                                                │
│         [      Change Password      ]          │
│                                                │
└────────────────────────────────────────────────┘
```

### 10.4 Admin Tab (Non-Admin View)

For Members (non-admin users), the Admin tab should be:

**Option A: Hidden**
- Admin tab simply not rendered in navigation
- Cleanest approach

**Option B: Disabled with Helper**
```
┌─────────────────────────────────────────────────────────┐
│  [Driver]   [Carrier]   [Admin 🔒]                      │
└─────────────────────────────────────────────────────────┘

On hover/click of disabled Admin tab:
┌────────────────────────────────────┐
│ Admin Access Only                  │
│                                    │
│ This area is restricted to         │
│ platform administrators.           │
│                                    │
│ Need help? [Contact Admin]         │
└────────────────────────────────────┘
```

"Contact Admin" opens message form or mailto link.

---

## 11. Events & Side Effects

### 11.1 Triggered Events

| Trigger | Event | Side Effects |
|---------|-------|--------------|
| Account created | ACCOUNT_CREATED | Audit log, optional invite email |
| Invite accepted | INVITE_ACCEPTED | Account → ACTIVE, audit log |
| Login success | LOGIN_SUCCESS | Update last_login_at, increment login_count |
| Login failed | LOGIN_FAILED | Increment fail counter, possible lockout |
| Password changed | PASSWORD_CHANGED | Clear must_change_password, audit log |
| Account suspended | ACCOUNT_SUSPENDED | Invalidate sessions, audit log |
| Account banned | ACCOUNT_BANNED | Invalidate sessions, audit log |

### 11.2 Email Notifications

| Trigger | Recipient | Template |
|---------|-----------|----------|
| Account created (invite) | New user | invite_set_password |
| Password reset (link) | User | password_reset_link |
| Account suspended | User | account_suspended |
| Account reinstated | User | account_reinstated |

### 11.3 Audit Logging

All auth events logged with:
- user_id
- event_type
- timestamp
- ip_address
- user_agent
- admin_id (if admin-initiated)

Retention: Permanent (never deleted)

---

## 12. Non-Goals

This feature explicitly does NOT:
- ❌ Provide public self-registration
- ❌ Provide self-service "Forgot Password" (admin-only reset)
- ❌ Support social login (Google, Facebook, etc.)
- ❌ Support SSO/SAML (future consideration)
- ❌ Support 2FA/MFA (future consideration)
- ❌ Support biometric login
- ❌ Support "Remember Me" persistent sessions (v1)

---

## 13. Impact Analysis Guidance

**When changing this PRD, check:**

| Change | Affected PRDs | Notes |
|--------|---------------|-------|
| User entity fields | PRD-002 | User Account inherits from here |
| Role definitions | PRD-005 | Admin Portal relies on is_admin |
| Session rules | All PRDs | All authenticated features affected |
| Password rules | None | Self-contained |
| Provisioning flow | PRD-017 | Data import may create users |

---

## 14. Open Questions

| Question | Status | Resolution |
|----------|--------|------------|
| Self-service forgot password in future? | Open | Security review needed |
| 2FA requirement for admins? | Deferred | v2 consideration |
| IP allowlist for admin access? | Deferred | v2 consideration |

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
| Security | | | ☐ |
