# Epic [2]: CAPP-5: Court Detail & Booking

- ref_key: `epic:2`
- type_id: `(none — type missing)`

## Description

  The golden path — tap pin → 4-step booking wizard → confirmed reservation.

## Stories

### Story [2.0]: CAPP-040 — Court detail screen `M`
- ref_key: `story:2.0`
- type_id: `(none — type missing)`

  As a player, I want to see a court's details so I can decide if it's the right court.

Tasks:
- (2.0.0) Build court detail screen with photo carousel, info, amenities
- (2.0.1) Ensure CTA visible without scrolling on mobile

### Story [2.1]: CAPP-045 — Sports center schedule overview `M`
- ref_key: `story:2.1`
- type_id: `(none — type missing)`

  As a player, I want to see a timetable of all courts in a sports center so I can compare availability and pick the best time.

Tasks:
- (2.1.0) Build sports center screen (accessible from map pin or court detail breadcrumb)
- (2.1.1) Build grid (courts × time slots) with date tabs
- (2.1.2) Wire tappable open slots → booking wizard

### Story [2.2]: CAPP-041 — Available slot picker `M`
- ref_key: `story:2.2`
- type_id: `(none — type missing)`

  As a player, I want to see available time slots so I can pick one that fits.

Tasks:
- (2.2.0) Build date tabs (today + 6 days)
- (2.2.1) Build slot list per selected date
- (2.2.2) Query open future slots for the court

### Story [2.3]: CAPP-042 — Booking wizard — Step 1: confirm details `M`
- ref_key: `story:2.3`
- type_id: `(none — type missing)`

  > ⚙ **Rewritten:** Single confirm + success screen → 4-step wizard (Step 1 confirm details, Step 2 awaiting owner via Realtime)
  
  As a player, I want to review court info and price before confirming so I don't make a mistake.

Tasks:
- (2.3.0) Build Step 1 screen with court info and price breakdown
- (2.3.1) Pre-fill name + phone from profile (editable)
- (2.3.2) Wire submit button → CAPP-043 RPC → advance to Step 2

### Story [2.4]: CAPP-043 — Atomic booking via RPC `M`
- ref_key: `story:2.4`
- type_id: `(none — type missing)`

  As a player, I want my booking to succeed or fail cleanly so I'm never double-booked.

Tasks:
- (2.4.0) Implement `create_booking(slot_id, user_id, notes)` RPC client call
- (2.4.1) Wire error handling and conflict toast
- (2.4.2) Add loading state on submit button

### Story [2.5]: CAPP-044 — Booking wizard — Step 2: awaiting owner confirmation `M`
- ref_key: `story:2.5`
- type_id: `(none — type missing)`

  > ⚙ **Rewritten:** Single confirm + success screen → 4-step wizard (Step 1 confirm details, Step 2 awaiting owner via Realtime)
  
  As a player, I want to see that my booking request was sent and is waiting for the owner so I know the next step.

Tasks:
- (2.5.0) Build Step 2 awaiting screen
- (2.5.1) Insert owner notification row on entry
- (2.5.2) Subscribe to `bookings.status` via Supabase Realtime; auto-advance on `confirmed`
- (2.5.3) Add always-visible escape hatch

### Story [2.6]: CAPP-046 — Booking wizard — Step 3: play-together access control `S`
- ref_key: `story:2.6`
- type_id: `(none — type missing)`

  As a player who booked a slot, I want to control who can join my session so I can play with people I choose.

Tasks:
- (2.6.0) Build Step 3 toggle ("Riêng tư" / "Mở") and max-players input
- (2.6.1) Save selection to `slots.access_policy` and `slots.max_players`
- (2.6.2) Implement skip-to-default behaviour

### Story [2.7]: CAPP-047 — Booking wizard — Step 4: payment `S`
- ref_key: `story:2.7`
- type_id: `(none — type missing)`

  As a player, I want to complete payment as the final booking step so my reservation is secured.

Tasks:
- (2.7.0) Build Step 4 summary screen
- (2.7.1) Add prominent cash-payment notice
- (2.7.2) Wire CTAs back to bookings list and map
