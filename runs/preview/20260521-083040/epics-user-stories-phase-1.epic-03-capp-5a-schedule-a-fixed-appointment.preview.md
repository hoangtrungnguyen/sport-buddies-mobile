# Epic [3]: CAPP-5A: Schedule a Fixed Appointment

- ref_key: `epic:3`
- type_id: `(none — type missing)`

## Description

  Recurring bookings — set a pattern once, generate a series, manage the whole thing as a unit.

## Stories

### Story [3.0]: CAPP-048 — Recurring pattern picker `M`
- ref_key: `story:3.0`
- type_id: `(none — type missing)`

  As a player, I want to set up a recurring booking (daily / weekly / chosen weekdays) so I can lock in a regular session without rebooking each week.

Tasks:
- (3.0.0) Build pattern picker UI (Hằng ngày / Hằng tuần / Chọn thứ)
- (3.0.1) Build start-date and end-condition inputs
- (3.0.2) Wire live summary card

### Story [3.1]: CAPP-049 — Series preview before confirm `M`
- ref_key: `story:3.1`
- type_id: `(none — type missing)`

  As a player, I want to see every generated session before I commit so I can resolve conflicts and skip bad dates.

Tasks:
- (3.1.0) Generate session list from pattern
- (3.1.1) Render numbered list with per-row status (ok / conflict / skipped)
- (3.1.2) Build conflict callout with swap-court / change-time options
- (3.1.3) Wire per-session toggles to running total

### Story [3.2]: CAPP-049a — Series confirmation `S`
- ref_key: `story:3.2`
- type_id: `(none — type missing)`

  As a player, I want a clear summary + "how it works" explanation before submitting so I understand the commitment.

Tasks:
- (3.2.0) Build confirmation screen with pattern card
- (3.2.1) Surface cost breakdown, cash-per-session reminder, owner-approval explainer

### Story [3.3]: CAPP-049b — Series success state `S`
- ref_key: `story:3.3`
- type_id: `(none — type missing)`

  As a player, I want a confirmation that my series was submitted plus the next session highlighted so I know what's immediate.

Tasks:
- (3.3.0) Build success screen with series ID
- (3.3.1) Surface stat tiles and next-up session card
- (3.3.2) Show payment reminder

### Story [3.4]: CAPP-055 — Series detail screen `M`
- ref_key: `story:3.4`
- type_id: `(none — type missing)`

  As a player with a recurring booking, I want a dedicated screen to manage the whole series so I can track progress and cancel either one session or the entire series.

Tasks:
- (3.4.0) Build series detail screen
- (3.4.1) Implement progress bar and stats
- (3.4.2) Render full session list with per-session status badges
- (3.4.3) Wire cancel-whole-series CTA

### Story [3.5]: CAPP-056 — Booking type visible in list `S`
- ref_key: `story:3.5`
- type_id: `(none — type missing)`

  As a player, I want to tell recurring from one-off bookings at a glance so I know what I'm looking at.

Tasks:
- (3.5.0) Add type badge to every booking tile
- (3.5.1) Add series context line on recurring tiles
- (3.5.2) Add filter chips at top of list
- (3.5.3) Wire "Xem cả lịch" CTA on recurring tiles to series detail
