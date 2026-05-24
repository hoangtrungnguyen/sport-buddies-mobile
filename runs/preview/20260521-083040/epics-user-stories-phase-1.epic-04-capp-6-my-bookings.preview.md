# Epic [4]: CAPP-6: My Bookings

- ref_key: `epic:4`
- type_id: `(none — type missing)`

## Description

  Player's upcoming reservations and booking history.

## Stories

### Story [4.0]: CAPP-050 — Upcoming bookings `M`
- ref_key: `story:4.0`
- type_id: `(none — type missing)`

  As a player, I want to see upcoming bookings so I know where and when I'm playing.

Tasks:
- (4.0.0) Build upcoming bookings query and list screen
- (4.0.1) Add filter chips
- (4.0.2) Render status badges

### Story [4.1]: CAPP-051 — Booking history `S`
- ref_key: `story:4.1`
- type_id: `(none — type missing)`

  As a player, I want to see past bookings so I can rebook a court I liked.

Tasks:
- (4.1.0) Build history query and list screen
- (4.1.1) Wire "Đặt lại" shortcut to court detail

### Story [4.2]: CAPP-052 — Cancel a pending booking `M`
- ref_key: `story:4.2`
- type_id: `(none — type missing)`

  As a player, I want to cancel a booking I no longer need so the slot is freed.

Tasks:
- (4.2.0) Implement cancel action (status transitions + slot release)
- (4.2.1) Trigger owner notification on cancel
- (4.2.2) Show cancel CTA only for pending bookings

### Story [4.3]: CAPP-053 — Play-together participant management `S`
- ref_key: `story:4.3`
- type_id: `(none — type missing)`

  As a player who booked a slot, I want to see and approve people who want to join my session so I can find suitable playing partners.

Tasks:
- (4.3.0) Build "Yêu cầu tham gia" section in booking detail
- (4.3.1) Wire approve / reject actions to `slot_participants`
- (4.3.2) Render confirmed participant list

### Story [4.4]: CAPP-054 — Join slot request & status `S`
- ref_key: `story:4.4`
- type_id: `(none — type missing)`

  As a player, I want to request to join an open slot and track whether I'm approved so I know if I have a game.

Tasks:
- (4.4.0) Add "Đăng ký chơi cùng" CTA on slot detail (gated on `access_policy = open` and not full)
- (4.4.1) Create `slot_join_requests` row with `status = pending`
- (4.4.2) Surface request in My Bookings with status badge
