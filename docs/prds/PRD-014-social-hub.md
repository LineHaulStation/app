# PRD-014: Social Hub & Shareables

**Version:** 1.0  
**Status:** Draft  
**Last Updated:** January 28, 2026  

---

## 1. Feature Identity

### 1.1 Name
Social Hub & Shareables

### 1.2 Portal(s)
- [x] Driver (primary)
- [ ] Carrier
- [x] Admin (content management)

### 1.3 One-Line Summary
A content hub where drivers access platform announcements, personalized shareable graphics, and promotional assets for social media.

---

## 2. Content Structure

### 2.1 Featured Content (Global)

- Platform announcements
- Campaign graphics
- Network news
- Same for all drivers

### 2.2 Your Shareables (Personalized)

- Sweepstakes graphics (with driver's ideas)
- Top 10 Truckers promo content
- Outriders Avatar
- Custom profile graphics
- Referral code graphics

---

## 3. Data Model

```
ShareableContent
├── shareable_id (UUID, PK)
├── driver_profile_id (UUID, FK, nullable for global)
├── content_type (enum: PROFILE_GRAPHIC, TOP10_PROMO, SWEEPSTAKES, CAMPAIGN, AVATAR)
├── title (string)
├── description (text)
├── image_url (string)
├── is_featured (boolean)
├── is_active (boolean)
├── created_by_admin_id (UUID)
├── created_at (timestamp)
└── updated_at (timestamp)
```

---

## 4. Driver Actions

| Action | Points |
|--------|--------|
| Download shareable | 0 |
| Share (verified) | 1 (capped) |

---

## 5. Admin Controls

| Action | Description |
|--------|-------------|
| Create global content | Featured announcements |
| Create driver content | Personalized shareables |
| Upload Outriders avatar | To driver's profile |
| Deactivate content | Hide from hub |

---

## 6. Non-Goals

- ❌ User-generated content uploads
- ❌ Social feed functionality
- ❌ Comments or reactions
- ❌ Real-time share tracking

---

## 7. Changelog

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | Jan 28, 2026 | Product Team | Initial draft |
