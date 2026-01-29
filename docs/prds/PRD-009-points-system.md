# PRD-009: Points System

**Version:** 1.0  
**Status:** Draft  
**Last Updated:** January 28, 2026  

---

## 1. Feature Identity

### 1.1 Name
Points System

### 1.2 Portal(s)
- [x] Driver (view balance, earning, redemption)
- [ ] Carrier
- [x] Admin (configuration, adjustments)

### 1.3 One-Line Summary
A backend-driven, state-based points economy where drivers accumulate points through profile completion, engagement, and referrals, redeemable for services and gear.

### 1.4 Business Value
- **Engagement:** Reward meaningful platform participation
- **Retention:** Bank value that encourages return
- **Network Growth:** Points flow accelerates via referral completion

---

## 2. System Context

### 2.1 Dependencies
- PRD-003: Driver Profile — Points tied to driver
- PRD-010: Top 10 Truckers — Badge milestones award points

### 2.2 Dependents
- PRD-011: Network Dividends — Automatic point earning post-Protect

---

## 3. Core Design Principles

### 3.1 Backend-Driven, State-Based

- Points are awarded based on **account state**, not button clicks
- System observes what's true and awards automatically
- **No "claim" buttons** — no gamification UI

### 3.2 Points Are Banked Utility

- Points do NOT reduce prices, dues, or fees
- Points are redeemed for services/gear from **real inventory**
- Scarcity is intentional until Protect completion

---

## 4. Data Model

### 4.1 DriverPointsAccount

```
DriverPointsAccount
├── account_id (UUID, PK)
├── driver_profile_id (UUID, FK, unique)
├── current_balance (integer)
├── lifetime_earned (integer)
├── lifetime_redeemed (integer)
├── is_redemption_frozen (boolean)
├── last_calculated_at (timestamp)
├── created_at (timestamp)
└── updated_at (timestamp)
```

### 4.2 PointRule (Admin-Configurable)

```
PointRule
├── rule_id (UUID, PK)
├── rule_key (string, unique)
├── rule_name (string)
├── description (text)
├── points_value (integer)
├── is_one_time (boolean)
├── is_repeatable (boolean)
├── max_per_driver (integer, nullable)
├── max_per_day (integer, nullable)
├── is_enabled (boolean)
├── category (enum: PROFILE, ENGAGEMENT, REFERRAL, SWEEPSTAKES)
├── condition_field (string, nullable)
├── condition_value (string, nullable)
├── created_at (timestamp)
└── updated_at (timestamp)
```

### 4.3 PointAward (Tracks Awards)

```
PointAward
├── award_id (UUID, PK)
├── driver_profile_id (UUID, FK)
├── rule_id (UUID, FK)
├── points_awarded (integer)
├── source_event_id (UUID, nullable)
├── source_event_type (string)
├── awarded_at (timestamp)
```

### 4.4 PointsLedgerEntry (Audit Log)

```
PointsLedgerEntry
├── entry_id (UUID, PK)
├── driver_profile_id (UUID, FK)
├── delta_points (integer, +/-)
├── rule_id (UUID, FK, nullable)
├── event_type (enum: RULE_AWARD, ADMIN_ADJUSTMENT, REDEMPTION)
├── event_ref_id (UUID, nullable)
├── description (string)
├── created_by_admin_id (UUID, nullable)
├── created_at (timestamp)
```

---

## 5. Earning Rules (V1)

### 5.1 Profile Events (One-Time)

| Rule Key | Description | Points |
|----------|-------------|--------|
| PROFILE_APPROVED | Profile verified by admin | 5 |
| ID_PHOTO_UPLOADED | Identifying photo uploaded | 5 |
| PROFILE_COMPLETE | All required fields filled | 10 |
| CODE_OF_CONDUCT_ACCEPTED | CoC accepted | 5 |
| CUSTOM_AVATAR_RECEIVED | Outriders avatar uploaded | 10 |

**Total possible from profile: 35 points**

### 5.2 Engagement (Repeatable, Capped)

| Rule Key | Description | Points | Cap |
|----------|-------------|--------|-----|
| DAILY_LOGIN | Daily login bonus | 1 | 10 lifetime |
| CONTENT_SHARED | Verified share | 1 | 100 lifetime, 5/day |
| DRIVER_CARD_SENT | Card sent to carrier | 5 | 50 unique carriers |

### 5.3 Sweepstakes (One-Time per Entry)

| Rule Key | Description | Points |
|----------|-------------|--------|
| SWEEPSTAKES_SUBMITTED | Entry submitted | 25 |
| SWEEPSTAKES_APPROVED | Entry approved by admin | 25 |

### 5.4 Referral Badges (One-Time)

| Rule Key | Description | Points |
|----------|-------------|--------|
| LEAD_BADGE | 10 referrals | 25 |
| GUIDE_BADGE | 100 referrals | 50 |
| PROTECT_BADGE | 1,000 referrals | 500 |

See PRD-010 for referral details.

---

## 6. Point Calculation Engine

### 6.1 When Points Calculate

- On profile save
- On admin approval
- On event creation (share, sweepstakes, etc.)
- On manual admin recalculation

### 6.2 Calculation Logic

```javascript
async function calculateDriverPoints(driverId) {
  const driver = await getDriverProfile(driverId);
  const rules = await getEnabledRules();
  const existingAwards = await getAwards(driverId);
  
  for (const rule of rules) {
    // Skip if one-time rule already awarded
    if (rule.is_one_time && hasAward(existingAwards, rule)) {
      continue;
    }
    
    // Check if condition is met
    if (checkCondition(driver, rule)) {
      // Check caps for repeatable rules
      if (rule.is_repeatable && exceedsCap(existingAwards, rule)) {
        continue;
      }
      
      await awardPoints(driverId, rule);
    }
  }
}
```

---

## 7. Redemption Catalog

### 7.1 V1 Catalog

| Item | Points | Type | Requires Promo Token |
|------|--------|------|---------------------|
| Free Night | 100 | PASS | Yes |
| Lighthouse Hat | 150 | GEAR | No |
| Lighthouse T-Shirt | 250 | GEAR | No |
| Lighthouse Hoodie | 400 | GEAR | No |

### 7.2 Redemption Flow

1. Driver requests redemption
2. System validates: points, not frozen, item available
3. For PASS items: Check promo inventory
4. Create RedemptionRequest (PENDING)
5. Admin reviews and approves
6. Points deducted, item fulfilled
7. For PASS: Token assigned from promo carrier

---

## 8. Driver UI

### 8.1 Points Display

```
🏆 1,250 Points

[How to Earn More]
```

### 8.2 Earn Tab

Shows earned/not-earned status for each rule:
- ✅ Profile Approved (5 pts)
- ✅ ID Photo Uploaded (5 pts)
- ⬜ Outriders Avatar (10 pts)
- 🔒 Network Dividends (unlocks at Protect)

**No claim buttons** — informational only.

---

## 9. Admin Controls

| Action | Description |
|--------|-------------|
| View rules | List all point rules |
| Edit rule | Change points value, caps |
| Enable/Disable | Turn rules on/off |
| View driver points | Balance and ledger |
| Manual adjustment | Add/deduct with reason |
| Recalculate | Re-run for a driver |
| Freeze redemptions | Block driver from redeeming |

---

## 10. Non-Goals

- ❌ Click-to-earn mechanics
- ❌ Points expiration
- ❌ Points transfer between drivers
- ❌ Leaderboards
- ❌ Tiered redemption discounts

---

## 11. Changelog

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | Jan 28, 2026 | Product Team | Initial draft |
