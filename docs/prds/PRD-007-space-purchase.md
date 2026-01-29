# PRD-007: SPACE Purchase Flow

**Version:** 1.0  
**Status:** Draft  
**Last Updated:** January 28, 2026  

---

## 1. Feature Identity

### 1.1 Name
SPACE Purchase Flow

### 1.2 Portal(s)
- [ ] Driver (redirect to Carrier portal)
- [x] Carrier (primary)
- [x] Admin (can purchase for promo carrier)

### 1.3 One-Line Summary
The workflow for carriers to purchase terminal access packages, creating token inventory that can be assigned to drivers.

### 1.4 Business Value
- **Revenue:** Primary revenue stream for platform
- **Flexibility:** Multiple package types for different needs
- **Simplicity:** Clear pricing, instant inventory

---

## 2. System Context

### 2.1 Dependencies
- PRD-004: Carrier Profile — Must be complete to purchase
- PRD-006: Facilities — Terminal selection

### 2.2 Dependents
- PRD-008: Tokens & Access — Purchase creates inventory

---

## 3. Package Types

| Package | Price | Passes | Annual Dues | Refundable |
|---------|-------|--------|-------------|------------|
| Dedicated 365 | $100,000 | 365/space | $395/year | Yes (85%) |
| Flex 30 | $8,500 | 30/space | $395/year | Yes (85%) |
| Daily Pass | $59 | 1/pass | None | No |

### 3.1 Refundable Membership

> "LineHaul Station operates like a country club for trucking infrastructure. Your one-time membership fee secures access to space at our terminal network. When you're ready to retire your membership, up to 85% of your total membership fee is refundable, once your space becomes available again."

---

## 4. Purchase Flow

### 4.1 Flow Steps

```
[SPACE Tab] → [Select Terminal] → [Select Packages] → [Review Order] → [Place Order] → [Inventory Created]
```

### 4.2 Package Selection UI

```
Purchase SPACE — West Memphis
════════════════════════════════════════

DEDICATED 365                    $100,000
365 passes per space per year    Refundable
Number of spaces: [─] 0 [+]      + $395/year in dues

FLEX 30                          $8,500
30 passes per space              Refundable
Number of spaces: [─] 0 [+]      + $395/year in dues

DAILY PASS                       $59
Single-day access                per pass
Number of passes: [─] 0 [+]

════════════════════════════════════════

ORDER SUMMARY

Total Passes:                    825
Refundable Membership Fee:       $225,795
Annual Dues:                     $1,975
────────────────────────────────────────
TOTAL DUE TODAY:                 $227,770

[PLACE MY ORDER]
```

### 4.3 Calculations

```javascript
totalPasses = (dedicated365_qty × 365) + (flex30_qty × 30) + (daily_qty × 1)

refundableFee = (dedicated365_qty × 100000) + (flex30_qty × 8500) + (daily_qty × 59)

annualDues = (dedicated365_qty + flex30_qty) × 395  // Daily Pass has no dues

totalDueToday = refundableFee + annualDues
```

---

## 5. Purchase Completion

### 5.1 Instant Inventory (Soft Launch)

For soft launch, purchases are **instant** (no payment processing):

1. Carrier clicks "Place My Order"
2. Button shows "⏳ Processing..."
3. System creates CarrierAccessBalance records
4. Toast: "✅ Purchased! Your passes are now available."
5. Redirect to Carrier Dashboard

### 5.2 What Gets Created

**CarrierAccessBalance:**
```
carrier_profile_id: [carrier]
terminal_id: [selected terminal]
terminal_name: "West Memphis"
package_type: DEDICATED_365 | FLEX_30 | DAILY_PASS
uses_total: [quantity × passes per package]
uses_remaining: [same as total]
purchased_at: [now]
```

One record per package type purchased.

---

## 6. Rules & Constraints

| Rule | Description |
|------|-------------|
| Profile complete | Carrier must have complete profile |
| Minimum selection | At least one package must be selected |
| Terminal active | Cannot purchase for deactivated terminals |
| Soft launch | No actual payment processing (v1) |

---

## 7. Driver Purchase Redirect

If a driver clicks "Purchase" in Driver portal:
1. Check if user has CarrierProfile
2. If no: Prompt to create Carrier Profile first
3. If yes: Redirect to Carrier Portal purchase flow

**Interstitial message:**
> "To purchase and manage SPACE access, you need to set up your Carrier profile. Owner-operators can use their personal name as their carrier name."

---

## 8. Admin Promo Purchases

Admin can purchase tokens for the internal promo carrier:
1. Navigate to internal carrier profile
2. Use same purchase flow
3. Creates promo inventory for redemption fulfillment

---

## 9. Non-Goals

- ❌ Payment processing (soft launch)
- ❌ Subscription billing
- ❌ Discount codes
- ❌ Multi-terminal cart (one terminal per purchase)
- ❌ Partial refunds (full refund process separate)

---

## 10. Changelog

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | Jan 28, 2026 | Product Team | Initial draft |
