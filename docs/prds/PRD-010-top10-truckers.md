# PRD-010: Top 10 Truckers & Referrals

**Version:** 1.0  
**Status:** Draft  
**Last Updated:** January 28, 2026  

---

## 1. Feature Identity

### 1.1 Name
Top 10 Truckers & Referral Network

### 1.2 Portal(s)
- [x] Driver (primary)
- [ ] Carrier
- [x] Admin (view network data)

### 1.3 One-Line Summary
A tiered referral program where drivers earn badges and points by building their network, culminating in automatic "dividend" earnings after reaching Protect status.

### 1.4 Business Value
- **Network Growth:** Primary driver acquisition channel
- **Engagement:** Long-term goal with progressive rewards
- **Retention:** Protect status creates permanent value

---

## 2. System Context

### 2.1 Dependencies
- PRD-003: Driver Profile — Referral code from handle
- PRD-009: Points System — Badge milestones award points

### 2.2 Dependents
- PRD-011: Network Dividends — Unlocks at Protect

---

## 3. Badge Ladder

### 3.1 Thresholds

| Badge | Referrals Required | Points Awarded |
|-------|-------------------|----------------|
| NEW_MEMBER | 0 (default) | 0 |
| LEAD | 10 | 25 |
| GUIDE | 100 | 50 |
| PROTECT | 1,000 | 500 |
| OUTRIDER | Special | Special |

### 3.2 Badge Progression

```
[NEW_MEMBER] ──(10)──► [LEAD] ──(100)──► [GUIDE] ──(1,000)──► [PROTECT]
                                                                   │
                                                                   ▼
                                                         [Dividends Enabled]
```

**OUTRIDER** is a special designation (admin-granted) for exceptional contributors.

---

## 4. Referral Code

### 4.1 Format

```
LH-[HANDLE]-[XXXX]
```

**Example:** `LH-IRONHAUL-4F2A`

- LH: Platform prefix
- HANDLE: Driver handle (truncated to 10 chars)
- XXXX: Random alphanumeric suffix

### 4.2 Generation

- Generated automatically when driver is **verified**
- Cannot be changed after generation
- Unique across all drivers

---

## 5. Data Model

### 5.1 DriverProfile Fields (Referral)

```
# Top 10 Truckers fields on DriverProfile
├── referral_code (string, unique)
├── referred_by_driver_id (UUID, FK → DriverProfile)
├── referral_badge (enum: NEW_MEMBER, LEAD, GUIDE, PROTECT, OUTRIDER)
├── lead_count (integer) — direct referrals who reached Lead
├── guide_count (integer) — direct referrals who reached Guide
├── network_size (integer) — total downstream network
├── dividends_enabled (boolean) — true after Protect
```

### 5.2 ReferralTree

```
ReferralTree
├── referral_id (UUID, PK)
├── referrer_driver_id (UUID, FK)
├── referred_driver_id (UUID, FK)
├── created_at (timestamp)
```

---

## 6. Referral Counting

### 6.1 Direct Referrals

A referral counts when:
- New driver signs up with referral code
- New driver's profile gets **verified** (APPROVED)

### 6.2 Network Size

Network includes:
- Direct referrals (your referrals)
- Indirect referrals (referrals of your referrals, recursively)

Used for dividend eligibility, not badge calculation.

---

## 7. Badge Unlock Flow

### 7.1 Trigger

When a referred driver gets verified:
1. System increments referrer's direct count
2. System checks badge thresholds
3. If threshold crossed, upgrade badge
4. Award corresponding points
5. Notify driver of badge unlock

### 7.2 Points Awards

| Badge | Points | Notification |
|-------|--------|--------------|
| LEAD | 25 | "🎉 You've reached Lead! 10 drivers in your network." |
| GUIDE | 50 | "🎉 You've reached Guide! 100 drivers strong." |
| PROTECT | 500 | "🎉 PROTECT UNLOCKED! Dividends are now active!" |

---

## 8. The Protect Unlock

### 8.1 What Happens

When a driver reaches 1,000 verified referrals:
1. Badge changes to PROTECT
2. 500 points awarded
3. `dividends_enabled` set to TRUE
4. Network dividends begin flowing (see PRD-011)

### 8.2 The "Oh My God" Moment

> "Every time anyone in your network uses LineHaul Station, you earn 10 points automatically. 10 uses = 1 Free Night."

This is the incentive that drives network building.

---

## 9. Driver UI

### 9.1 Top 10 Truckers Page

```
Top 10 Truckers
════════════════════════════════════════

Your Referral Code
LH-IRONHAUL-4F2A
[Copy Code] [Share]

════════════════════════════════════════

Progress

Current Badge: LEAD 🥉

[██████████░░░░░░░░░░] 45/100 to GUIDE

════════════════════════════════════════

Badge Ladder

🥉 LEAD (10 referrals)     ✅ Unlocked — 25 pts
🥈 GUIDE (100 referrals)   ⬜ 45/100
🥇 PROTECT (1,000)         🔒 Unlocks Dividends

════════════════════════════════════════

Your Network

Direct Referrals: 45
Network Size: 127 drivers
```

### 9.2 Referral Grid

Visual display of direct referrals:
- Photo/avatar
- Handle
- Badge status
- Joined date

---

## 10. Sharing Tools

### 10.1 Share Options

- Copy referral code
- Copy referral link
- Share to Facebook
- Share to LinkedIn
- Share via SMS
- Share via Email

### 10.2 Referral Link

```
https://linehaulstation.com/join?ref=LH-IRONHAUL-4F2A
```

When clicked → invitation request flow (invite-only platform)

---

## 11. Rules & Constraints

| Rule | Description |
|------|-------------|
| Verified only | Referrals count only when referred driver is verified |
| One referrer | Driver can only have one referring driver |
| No self-referral | Cannot use own code |
| Permanent attribution | Referral link persists even if referrer leaves |
| Badge progression | Badges never decrease |

---

## 12. Admin Controls

| Action | Description |
|--------|-------------|
| View referral tree | Network visualization |
| Edit badge | Manual badge assignment |
| Grant OUTRIDER | Special badge |
| View referral stats | Platform-wide metrics |

---

## 13. Non-Goals

- ❌ Cash payouts for referrals
- ❌ Multi-level commission structures
- ❌ Referral code customization
- ❌ Time-limited referral campaigns
- ❌ Referral leaderboards (public)

---

## 14. Changelog

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | Jan 28, 2026 | Product Team | Initial draft |
