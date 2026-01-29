# PRD-013: My Carriers (Driver CRM)

**Version:** 1.0  
**Status:** Draft  
**Last Updated:** January 28, 2026  

---

## 1. Feature Identity

### 1.1 Name
My Carriers

### 1.2 Portal(s)
- [x] Driver (primary)
- [ ] Carrier
- [x] Admin (view)

### 1.3 One-Line Summary
A personal contact list where drivers save carrier information for easy Driver Card sharing via email and SMS.

### 1.4 Business Value
- **Efficiency:** One-tap sharing to saved carriers
- **Organization:** Drivers manage their own contacts
- **Engagement:** Repeated sharing encouraged

---

## 2. System Context

### 2.1 Dependencies
- PRD-003: Driver Profile — Belongs to driver
- PRD-012: Driver Card — Card is what gets shared

### 2.2 Dependents
None.

---

## 3. Data Model

### 3.1 DriverCarrierRecord

```
DriverCarrierRecord
├── record_id (UUID, PK)
├── driver_profile_id (UUID, FK)
├── carrier_name (string, required)
├── is_current (boolean, default false)
├── contact_name (string, optional)
├── contact_email (string, required if no phone)
├── contact_phone (string, required if no email)
├── preferred_method (enum: EMAIL, SMS, BOTH)
├── notes (text, optional)
├── last_sent_at (timestamp, nullable)
├── send_count (integer, default 0)
├── created_at (timestamp)
└── updated_at (timestamp)
```

### 3.2 DriverCardSendEvent

```
DriverCardSendEvent
├── event_id (UUID, PK)
├── driver_profile_id (UUID, FK)
├── carrier_record_id (UUID, FK)
├── method (enum: EMAIL, SMS, BOTH)
├── email_sent (boolean)
├── email_success (boolean)
├── sms_sent (boolean)
├── sms_success (boolean)
├── note_included (text)
├── created_at (timestamp)
```

---

## 4. My Carriers Section

### 4.1 Location

Driver Profile page → My Carriers section

### 4.2 UI Layout

```
My Carriers
════════════════════════════════════════

Add your carrier(s) to send your Driver Card in one tap.

┌────────────────────────────────────────────────┐
│ ABC Trucking                      [CURRENT]    │
│ Sarah Johnson                                  │
│ sarah@abctrucking.com • (555) 123-4567        │
│                                                │
│ Last sent: Jan 25, 2026                        │
│                                                │
│ [Send Card]  [Edit]                            │
└────────────────────────────────────────────────┘

┌────────────────────────────────────────────────┐
│ XYZ Transport                                  │
│ Mike Smith                                     │
│ recruiting@xyz.com                             │
│                                                │
│ Never sent                                     │
│                                                │
│ [Send Card]  [Edit]                            │
└────────────────────────────────────────────────┘

[+ Add Carrier]
```

### 4.3 Empty State

```
📋 No Carriers Added Yet

Add your carrier(s) to send your Driver Card in one tap.

[+ Add Carrier]
```

---

## 5. Add Carrier Form

### 5.1 Fields

| Field | Required | Validation |
|-------|----------|------------|
| Carrier Name | Yes | 1-200 chars |
| Is Current Carrier | No | Checkbox |
| Contact Name | No | Optional |
| Contact Email | If no phone | Valid email |
| Contact Phone | If no email | Valid phone |
| Preferred Method | Yes | EMAIL, SMS, BOTH |
| Default Note | No | Max 500 chars |

### 5.2 Validation

- Must have at least email OR phone
- Only ONE carrier can be marked "current"

### 5.3 Actions

- **Save Carrier** — Save and return to list
- **Save & Send Card** — Save then immediately send

---

## 6. Send Card Flow

### 6.1 Trigger

- Click "Send Card" on carrier record
- Or click carrier from Driver Card share sheet

### 6.2 Confirmation Modal

```
Send Driver Card
════════════════════════════════════════

Sending to:
ABC Trucking
Sarah Johnson

☑ Email: sarah@abctrucking.com
☑ Text: (555) 123-4567

Add a Note (Optional):
[________________________________]

Your card will include:
✓ Profile photo & handle
✓ CDL info & endorsements
✓ Skills & experience
✓ Open to Opportunities status

[Cancel]              [Send Card]
```

### 6.3 What Gets Sent

**Email:**
```
Subject: Driver Card from IRONHAULER_77

Hi Sarah,

IRONHAULER_77 has shared their Driver Card with you.

[CARD IMAGE]

DRIVER SUMMARY
Name: John Doe (@IRONHAULER_77)
Experience: 15 Years
CDL: Class A, Tennessee
Status: Open to Opportunities ✓

DRIVER'S NOTE
"Hi Sarah, sharing my updated profile..."

View Full Profile: [link]
```

**SMS:**
```
LineHaul Station Driver Card

IRONHAULER_77 shared their profile with you.
15yr CDL-A driver • Open to opportunities

View: https://lh.st/d/IRONHAULER_77

"Hi Sarah, sharing my profile..."
```

---

## 7. Points Integration

### 7.1 Earning Points

First send to each unique carrier earns points:

| Action | Points | Rule Key |
|--------|--------|----------|
| First send to carrier | 5 | DRIVER_CARD_SENT |

**Cap:** 50 unique carriers lifetime

### 7.2 Logic

```javascript
async function onCardSent(driverId, carrierRecordId) {
  const previousSends = await countSends(driverId, carrierRecordId);
  
  if (previousSends === 0) {
    await awardPoints(driverId, 'DRIVER_CARD_SENT');
  }
}
```

---

## 8. Rules & Constraints

| Rule | Description |
|------|-------------|
| Contact required | Email or phone must exist |
| One current | Only one carrier marked current |
| No duplicates | Same carrier can exist once per driver |
| Send logs | All sends are logged |

---

## 9. Admin Controls

| Action | Description |
|--------|-------------|
| View driver's carriers | See saved carrier list |
| View send history | See all card sends |

---

## 10. Non-Goals

- ❌ Carrier response tracking
- ❌ In-app messaging to carriers
- ❌ Automatic follow-up sends
- ❌ Carrier verification

---

## 11. Changelog

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | Jan 28, 2026 | Product Team | Initial draft |
