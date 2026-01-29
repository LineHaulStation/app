# PRD-015: Sweepstakes (Trucker's Two Cents)

**Version:** 1.0  
**Status:** Draft  
**Last Updated:** January 28, 2026  

---

## 1. Feature Identity

### 1.1 Name
Sweepstakes — Trucker's Two Cents

### 1.2 Portal(s)
- [x] Driver (submit and share)
- [ ] Carrier
- [x] Admin (review and manage)

### 1.3 One-Line Summary
An ideas program where drivers submit two suggestions to improve trucking, approved entries become shareable graphics, and member voting determines winners.

### 1.4 Hashtag
**#LetsFixTrucking**

---

## 2. Entry Flow

### 2.1 Driver Submits

1. Driver enters Idea #1 (required)
2. Driver enters Idea #2 (required)
3. Driver submits entry
4. Entry status: SUBMITTED

### 2.2 Admin Reviews

1. Admin views pending entries
2. Admin approves or rejects
3. If approved: Admin creates shareable graphic
4. Driver notified

### 2.3 Driver Shares

1. Driver sees approved entry in Social Hub
2. Driver downloads/shares graphic
3. Members vote via reactions (👍 = Idea #1, ❤️ = Idea #2)

### 2.4 Winner Selection

1. Finalists selected by admin
2. Member voting period
3. Winners announced

---

## 3. Data Model

```
TwoCentsSweepstakes
├── entry_id (UUID, PK)
├── driver_profile_id (UUID, FK)
├── idea_one (text, required)
├── idea_two (text, required)
├── status (enum: DRAFT, SUBMITTED, APPROVED, REJECTED, FINALIST, WINNER)
├── shareable_image_url (string, admin-uploaded)
├── admin_notes (text)
├── reviewed_by_admin_id (UUID)
├── reviewed_at (timestamp)
├── created_at (timestamp)
└── updated_at (timestamp)
```

---

## 4. Points

| Action | Points |
|--------|--------|
| Submission accepted | 25 |
| Entry approved | +25 |
| First verified share | 10 (one-time) |

---

## 5. Rules & Constraints

| Rule | Description |
|------|-------------|
| Two ideas required | Both fields must be filled |
| One entry per driver | Per campaign period |
| Admin approval | Required before shareable |
| Graphic creation | Admin creates, not auto-generated |

---

## 6. Admin Controls

| Action | Description |
|--------|-------------|
| View pending | Queue of submitted entries |
| Approve/Reject | Process entry |
| Upload graphic | Create shareable for driver |
| Select finalists | Move to finalist status |
| Declare winners | Final selection |

---

## 7. Non-Goals

- ❌ Automated graphic generation
- ❌ Public voting page
- ❌ Cash prizes
- ❌ Multiple entries per campaign

---

## 8. Changelog

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | Jan 28, 2026 | Product Team | Initial draft |
