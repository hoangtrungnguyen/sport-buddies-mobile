# Epic [5]: CAPP-10: Player Notifications

- ref_key: `epic:5`
- type_id: `(none — type missing)`

## Description

  Real-time booking status updates for the player.

## Stories

### Story [5.0]: CAPP-090 — In-app notification centre `M`
- ref_key: `story:5.0`
- type_id: `(none — type missing)`

  As a player, I want to see all booking notifications so I don't miss updates.

Tasks:
- (5.0.0) Build bell icon with unread count badge
- (5.0.1) Build notification list screen
- (5.0.2) Implement mark-all-as-read action

### Story [5.1]: CAPP-092 — Push booking reminder `S`
- ref_key: `story:5.1`
- type_id: `(none — type missing)`

  > ⚙ **Rewritten:** SMS reminder → Push (FCM) via pg_cron + Django Celery
  
  As a player, I want a push notification reminder 1 hour before my court time so I don't forget.

Tasks:
- (5.1.0) Schedule pg_cron + Django Celery job at T-60min for each confirmed booking (BS-052, BS-090)
- (5.1.1) Integrate Firebase Cloud Messaging push
- (5.1.2) Use `reminder_sent` flag to prevent duplicates
- (5.1.3) Silent-skip + log when no FCM token registered

### Story [5.2]: CAPP-093 — Last-minute slot push notification `S`
- ref_key: `story:5.2`
- type_id: `(none — type missing)`

  > ⚙ **Rewritten:** Edge Function → pg_cron + Django Celery + FCM; rate-limit via `slot_push_log` table
  
  As a player, I want a push notification when a nearby court has a slot opening soon so I can book on the spot.

Tasks:
- (5.2.0) Build Django endpoint (BS-053) that queries players within 5 km via `earth_distance(ll_to_earth(...))`
- (5.2.1) Integrate FCM push
- (5.2.2) Deep-link to court detail with slot pre-selected
- (5.2.3) Enforce rate limit via `slot_push_log` table

## Epic comments

**Open questions:**
- **Online payments (CAPP-047):** Step 4 is cash-at-court only — when does the gateway (VNPay / MoMo) integration land, and which is the launch partner?
- **Cancellation deadlines (CAPP-052):** No time cutoff today; do we need one before any refund / no-show logic ships?
- **Account merge edge case (CAPP-011):** What happens if a user signs up with email + password using address X, then later does OAuth with a different Gmail Y? Today we merge on `email` match only.
- **Cancel-whole-series semantics (CAPP-055):** Does cancelling a series owner-notify each session individually, or auto-release all upcoming slots at once?
- **iOS push (post-mobile):** FCM covers Android + Web; APNs config and ownership for iOS launch is unspecified.
- **Recurring conflict UX (CAPP-049):** Behaviour with a high conflict count (e.g. 6/12 sessions conflicting) — auto-suggest swaps or just flag?

**Risks:**
- **Atomic booking RPC contention (CAPP-043):** Weekend prime-time slots could see concurrent `create_booking` calls; needs load test before launch.
- **Email deliverability (CAPP-010):** Resend → Vietnamese inboxes (Viettel, FPT, VNPT) has unknown bounce rate; SPF / DKIM / DMARC tuning may be needed.
- **Vietmap API rate limits (CAPP-030):** Peak-hour ceiling unknown; escalation path with provider not documented.
- **FCM silent-skip blind spot (CAPP-092):** Players who declined notifications miss reminders without any signal; needs analytics + a re-prompt UX.
- **Recurring conflict resolution (CAPP-049):** Long series with many conflicts may overwhelm users; design review needed before code freeze.
- **ARB string coverage (CAPP-014):** Legal copy, notification text, and error messages may be Vietnamese-only at launch; English fallback gaps possible.
