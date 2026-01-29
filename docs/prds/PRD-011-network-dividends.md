# PRD-011: Network Dividends

**Version:** 1.0  
**Status:** Draft  
**Last Updated:** January 28, 2026  

---

## 1. Feature Identity

### 1.1 Name
Network Dividends

### 1.2 Portal(s)
- [x] Driver (passive earning display)
- [ ] Carrier
- [x] Admin (configuration, monitoring)

### 1.3 One-Line Summary
Automatic, uncapped point earning for Protect-level drivers whenever any driver in their referral network uses a LineHaul Station terminal.

### 1.4 Business Value
- **Incentive:** The ultimate reward for network building
- **Retention:** Creates permanent passive value
- **Growth:** Motivates early adopters to recruit aggressively

---

## 2. System Context

### 2.1 Dependencies
- PRD-003: Driver Profile — dividends_enabled flag
- PRD-008: Tokens & Access — Usage triggers dividends
- PRD-009: Points System — Awards dividend points
- PRD-010: Top 10 Truckers — Protect unlocks dividends

### 2.2 Dependents
None — This is the end of the incentive chain.

---

## 3. The Dividend Mechanism

### 3.1 How It Works

1. Driver A completes Protect (1,000 referrals)
2. `dividends_enabled = true` for Driver A
3. Driver B (in Driver A's network) uses terminal
4. System awards 10 points to Driver A
5. This repeats for every network usage, forever

### 3.2 Key Numbers

| Metric | Value | Notes |
|--------|-------|-------|
| Points per network use | 10 | Admin configurable |
| Free Night cost | 100 points | |
| Uses per Free Night | 10 | 10 × 10 = 100 |
| Daily cap | None | Uncapped after Protect |
| Monthly cap | None | Uncapped |
| Lifetime cap | None | Unlimited passive earning |

### 3.3 The Math

A Protector with 1,000 network members:
- If 10% use terminal monthly = 100 uses
- 100 uses × 10 points = 1,000 points/month
- 1,000 points = 10 Free Nights/month

**This is the "Oh My God" moment.**

---

## 4. Data Model

### 4.1 ProtectorDividendEvent

```
ProtectorDividendEvent
├── dividend_id (UUID, PK)
├── protector_driver_id (UUID, FK) — Who receives dividend
├── network_driver_id (UUID, FK) — Who used terminal
├── terminal_usage_event_id (UUID) — The usage event
├── terminal_id (UUID, FK)
├── points_awarded (integer)
├── created_at (timestamp)
```

### 4.2 Configuration

```
PointsConfig
├── points_per_network_use_after_protect (integer, default 10)
├── dividends_enabled_globally (boolean, default true)
```

---

## 5. Dividend Trigger Flow

### 5.1 When Terminal Used

```
[Driver uses terminal]
      │
      ▼
[Record usage event]
      │
      ▼
[Find all upstream Protectors]
      │
      ▼
[For each Protector:]
      ├── Check dividends_enabled = true
      ├── Create ProtectorDividendEvent
      ├── Award points
      └── Log to ledger
```

### 5.2 Finding Upstream Protectors

```javascript
async function findProtectorsInNetwork(driverId) {
  // Traverse referral tree upward
  // Return all drivers with:
  // - referral_badge = 'PROTECT'
  // - dividends_enabled = true
  // - Not the usage driver themselves
}
```

### 5.3 Multiple Protectors

If multiple Protectors are in the referral chain:
- **Each** Protector receives dividend
- Same usage can trigger multiple awards
- This encourages deep network building

---

## 6. Driver UI

### 6.1 Dividend Display (Pre-Protect)

```
Network Dividends
════════════════════════════════════════

🔒 LOCKED

Reach Protect status (1,000 referrals) to unlock
automatic dividend earnings.

Current Progress: 45/1,000 referrals

How it works:
Once you reach Protect, you'll earn 10 points every
time anyone in your network uses LineHaul Station.

10 network uses = 1 Free Night 🎉
```

### 6.2 Dividend Display (Post-Protect)

```
Network Dividends
════════════════════════════════════════

✅ ACTIVE

Points Earned This Month: 340 pts
Network Uses This Month: 34

Recent Dividend Activity:
────────────────────────────────────────
+10 pts  ROADKING55 used Memphis (2 hrs ago)
+10 pts  SIDEKICK_12 used Memphis (5 hrs ago)
+10 pts  NEWDRIVER_99 used Memphis (yesterday)
+10 pts  ...

Total Dividend Earnings: 2,450 pts (all time)
```

---

## 7. Audit & Transparency

### 7.1 Dividend Ledger Entry

Each dividend creates a PointsLedgerEntry:

```
event_type: 'NETWORK_DIVIDEND'
description: "Network dividend from ROADKING55 using Memphis terminal"
delta_points: +10
event_ref_id: [dividend_id]
```

### 7.2 Protector Can See

- Which network member triggered dividend
- Which terminal was used
- When it occurred
- Running totals

### 7.3 Protector Cannot See

- Exact usage details
- Other Protectors who received same dividend
- Network member's carrier info

---

## 8. Rules & Constraints

| Rule | Description |
|------|-------------|
| Protect required | Must have referral_badge = PROTECT |
| dividends_enabled | Must be true (can be admin-frozen) |
| Network only | Only usage by network members counts |
| Real usage | Only verified terminal usage triggers |
| No self-dividend | Cannot earn dividend from own usage |

---

## 9. Admin Controls

| Action | Description |
|--------|-------------|
| Configure rate | Set points per network use |
| Global enable/disable | Turn dividends on/off platform-wide |
| Freeze driver | Disable dividends for specific driver |
| View dividend log | See all dividend events |
| View Protector stats | Earnings by Protector |

---

## 10. Anti-Abuse

### 10.1 Safeguards

- Dividends only for **verified** terminal usage
- Cannot create fake network members (invite-only)
- Admin can freeze suspicious accounts
- Full audit trail for investigation

### 10.2 Monitoring

Admin dashboard shows:
- Unusual dividend spikes
- High-frequency network usage
- Concentration of earnings

---

## 11. Non-Goals

- ❌ Dividend caps (unlimited by design)
- ❌ Dividend decay over time
- ❌ Partial dividends for lower badges
- ❌ Cash payout of dividends
- ❌ Dividend sharing/splitting

---

## 12. Changelog

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | Jan 28, 2026 | Product Team | Initial draft |
