# PRD-012: Driver Card & Sharing

**Version:** 1.0  
**Status:** Draft  
**Last Updated:** January 28, 2026  

---

## 1. Feature Identity

### 1.1 Name
Driver Card & Sharing

### 1.2 Portal(s)
- [x] Driver (view and share)
- [x] Carrier (receives shared cards)
- [x] Admin (view any card)

### 1.3 One-Line Summary
A license-style, shareable resume card that renders driver profile data in a premium visual format for sharing with carriers.

### 1.4 Business Value
- **Professional Identity:** Portable, branded driver resume
- **Recruitment:** Easy sharing with potential employers
- **Engagement:** Tangible output from profile completion

---

## 2. System Context

### 2.1 Dependencies
- PRD-003: Driver Profile — Card renders profile data

### 2.2 Dependents
- PRD-013: My Carriers — Card shared via saved carriers

---

## 3. Card Design

### 3.1 Visual Format

- **Shape:** Landscape (like ID/license)
- **Size:** 480×300px (desktop), responsive
- **Background:** Black (#000000)
- **Accent:** Orange (#FF6600)
- **Border:** Dark gray, 16px radius

### 3.2 Layout

```
┌──────────────────────────────────────────────────────────────┐
│ [LOGO]                    [OPEN] [VERIFIED] [CDL A]          │
│                                                              │
│ ┌────────┐  JOHN DOE                                         │
│ │        │  @IRONHAULER_77                        [AVATAR]   │
│ │ PHOTO  │  15-Year OTR Linehaul Professional               │
│ │        │                                                   │
│ └────────┘  ─────────────────────────────────────────────── │
│                                                              │
│ CDL         CLASS A • TENNESSEE • EXP 12/2027               │
│ ENDORSE     HAZMAT • TANKER • DOUBLES/TRIPLES • TWIC        │
│ EXPERIENCE  15 Years • OTR Linehaul                          │
│ HOME BASE   Memphis, TN                                      │
│                                                              │
│ ─────────────────────────────────────────────────────────── │
│                                                              │
│ [Backing] [Time Mgmt] [Route Plan] [Safety] [Communication] │
│ [+6 more skills]                                             │
│                                                              │
│ ─────────────────────────────────────────────────────────── │
│ This is the card carriers receive        [Share with Carrier]│
└──────────────────────────────────────────────────────────────┘
```

### 3.3 Elements

| Element | Source | Display |
|---------|--------|---------|
| Logo | Platform asset | Top-left, 24px |
| Status badges | Profile flags | Top-right, pill style |
| Photo | identifying_photo_url | 80×80px, rounded |
| Name | first_name + last_name | Large, uppercase |
| Handle | driver_handle | Orange, with @ |
| Headline | one_line_bio | Muted gray |
| Avatar | outriders_avatar_url | Small circle (if exists) |
| CDL | cdl_class, cdl_issuing_state | License format |
| Endorsements | endorsements array | Pipe-separated |
| Experience | years + route_experience | Combined |
| Location | city, state | Home base |
| Skills | skill_* fields | Top 5-6 chips |

### 3.4 Status Badges

| Badge | Condition | Color |
|-------|-----------|-------|
| OPEN TO OPPORTUNITIES | open_to_opportunities = true | Orange |
| VERIFIED | verification_status = APPROVED | Green |
| CDL A/B/C | cdl_class value | Gray |

Max 3 badges displayed.

---

## 4. View Card Flow

### 4.1 Entry Point

Driver Portal → Profile → [View Card] button

### 4.2 Modal Display

```
[Full-screen dark modal]
      │
      ├── Card centered with subtle glow
      │
      └── Actions below:
          [Share with Carrier]  [Download Card]
```

### 4.3 Download

- Generates PNG image
- High resolution (1080×675px)
- Filename: `driver-card-[HANDLE].png`

---

## 5. Share Flow

See PRD-013 for "My Carriers" integration.

### 5.1 Share Button

Click "Share with Carrier" → Opens carrier selection

### 5.2 What Gets Sent

**Email:**
- Subject: "Driver Card from [HANDLE]"
- Card image preview (embedded)
- Profile summary text
- Link to full profile
- Driver's optional note

**SMS:**
- Compact message
- Short link to profile
- Brief summary

---

## 6. Data Collapse Rules

| Field | If Missing |
|-------|------------|
| Endorsements | Hide row |
| Availability | Hide row |
| Outriders avatar | Hide badge |
| Headline | Show "Driver" |
| Skills | Show "Complete profile" |

---

## 7. Rules & Constraints

| Rule | Description |
|------|-------------|
| Profile complete | Card requires minimum fields |
| Photo required | identifying_photo_url must exist |
| Handle required | Must have handle for card |
| Verification not required | Can view card pre-verification |

---

## 8. Non-Goals

- ❌ Public card URLs (invite-only platform)
- ❌ Card customization (colors, layouts)
- ❌ Video on card
- ❌ Real-time verification badge

---

## 9. Changelog

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | Jan 28, 2026 | Product Team | Initial draft |
