# Gap Analysis — Schedule screen vs `design_handoff_lich_san`

> Generated 2026-06-06 by multi-agent audit (9 dimensions, every finding adversarially
> verified against the actual code — 78 confirmed, 0 refuted).
> Handoff: `docs/SnB - Owner Dashboard - Schedule/design_handoff_lich_san/README.md`
> Code audited: `lib/features/schedule/`, `lib/features/slot_detail/`, `lib/features/courts/`, `lib/core/theme/`

## Executive summary

The current screen is a **week-only, court-scoped schedule built on `SfCalendar`**.
The handoff specifies a **3-view (Day/Week/Month), venue-scoped, custom-grid calendar**.
These differ at every layer — this is closer to "the specced screen does not exist yet"
than "polish the existing one". The existing code is a working v1 for a narrower scope
(one court, one week, open/owner/blocked slots, walk-in manual booking).

### The five structural gaps everything else hangs off

1. **No venue dimension.** `OwnerSlot` has only `courtId` (`owner_slot.dart:46`); the
   `slots` query filters by `court_id`. `Venue` exists in `features/courts/` but is never
   referenced by the schedule. Day view (venues as columns) and Week view (one venue ×
   7 days) are impossible with the current domain model. ⚠️ Extends to the DB contract:
   the customer app's slot queries also carry only `court_id`.
2. **Week view only.** No `ScheduleView` enum, no `viewChanged` event, no view switcher.
   **Day view and Month view (occupancy heatmap + `OccupancyDay` model) are entirely
   missing.**
3. **6 string slot statuses vs 9-value enum, with semantic drift.** `SlotStatus` is an
   `abstract final class` of raw strings (`open, booked, pending, owner, blocked,
   maintenance`). Spec's `fixed`, `private` are missing; code's `open` means the spec's
   `empty` (bookable, no customer); spec's `open` (public matchmaking) is unrepresented.
   ⚠️ **Backend-driven:** the DB `slots.status` enum is `open|booked|blocked|maintenance`
   (+`owner` via ALTER TYPE); `pending/confirmed` live on `bookings.status` with a
   trigger sync. Closing this gap needs a backend decision, not just a model rename —
   or a handoff revision.
4. **No slot detail sheet / unified create-block drawer.** Tapping a slot opens a
   block/unblock actions dialog; there is no 480px right drawer, no state banner, no
   per-state footer actions (Duyệt/Từ chối, Huỷ/Dời lịch/Gọi, Mở ghép/Đặt sân), no
   recurrence ("Lặp lại nhiều buổi"), no block-mode type picker (khoá/bảo trì/sân của
   tôi), no capacity/price extras for open slots. Approve/reject logic *does* exist but
   lives in `features/requests/` — not wired into the schedule.
5. **No filters, no drag-to-block.** "MÔN" sport chips, "TRẠNG THÁI" state chips, and
   the drag-to-block gesture (30-min snap, striped indigo band) are all absent.

### What already aligns (don't rebuild)

- BLoC + Freezed + repository pattern in place; `OwnerSlot` is freezed.
- Week grid with empty-cell tap-to-create (whole-hour snap; spec wants 30-min).
- `slot_detail/` roster dialog already fetches players/payment/price per slot
  (covers part of the detail-sheet data needs).
- Approve/reject + undo with Supabase backing exists in `features/requests/`.
- Sidebar collapse at 1024px exists at app-shell level (`app_shell.dart:128`).
- `VenueRepository.fetchForCourt()` exists — just not wired to the schedule.

### Build-order suggestion (dependency order)

1. Domain: add `venueId` to slots (DB + model), `SlotState`/`ScheduleView`/`SportType`
   enums, `OccupancyDay`, slot display fields (label, players, price, payment, code).
   ← requires backend schema decision (item 3 above).
2. Repository/service: abstract `ScheduleRepository` per spec (getDaySlots,
   getMonthOccupancy, createRecurringSlots, blockTime, approve/reject/cancel) +
   `ScheduleService`.
3. BLoC: single-state contract with view/filters/focusedDate/toast.
4. Views: custom grid (60px/hr, 64px gutter) → Day view, Week venue scoping, Month
   heatmap; slot block widget with exact state styling table.
5. Drawers: detail sheet + two-mode create/block sheet with recurrence.
6. Interactions: drag-to-block, filters, toast, responsive 1024/640.

### Severity histogram

| Severity | Count | Meaning |
|---|---|---|
| HIGH | 31 | core feature missing or fundamentally divergent |
| MEDIUM | 22 | partial implementation or structural divergence |
| LOW | 25 | cosmetic / naming / token drift |

Dimension counts: domain-models 10 · bloc-contract 11 · slot-styling 10 ·
toolbar-filters 10 · sheets 10 · interactions 9 · views 7 · architecture 7 ·
design-tokens 4.

---

# Appendix — all 78 confirmed findings

## HIGH (31)

### [Architecture] Schedule data layer is court-scoped, not venue-scoped — the Venue dimension is entirely absent from the schedule architecture
**Kind:** divergent
**Handoff:** README 'Terminology — READ FIRST': the screen is always scoped to one Court; the resource columns/chips are its Venues; Flutter classes must be Venue/venueId. Domain model: Slot requires `String venueId` (README domain models, Slot). Repository: getVenues(courtId) returns the court's venues; getWeekSlots takes a venueId (one venue, one week); getDaySlots returns slots across all venues of one day.
**Current:** OwnerSlot has `required String courtId` and no venueId field (owner_slot.dart:44-59, fromRow at 83-91 maps `court_id`), and OwnerSlotRepository.fetchWeekSlots takes courtId and queries `slots.court_id` (owner_slot_repository.dart:26-29, 95). The schedule feature contains zero references to Venue (grep over lib/features/schedule finds none); the existing Venue model + VenueRepository (lib/features/courts/model/venue.dart, lib/features/courts/repository/venue_repository.dart:13-27 fetchForCourt) are never consumed by the schedule bloc/views. Instead the bloc inverts the specced scoping: ScheduleEvent.started() takes no courtId (schedule_event.dart:8), the bloc loads the owner's full courts list and manages court tabs in state (schedule_bloc.dart:49-80; schedule_state.dart:18-30 ScheduleLoaded.courts/activeCourtId), whereas the spec scopes the screen to one court 'selected elsewhere / from session' and iterates venues. On this contract the Day view's per-venue resource columns and Week view's per-venue selection are architecturally impossible.

### [Architecture] Specced ScheduleRepository contract mostly missing: no getVenues, getDaySlots, getMonthOccupancy, createRecurringSlots, approveSlot, rejectSlot, cancelSlot
**Kind:** missing
**Handoff:** README 'Repository (abstract) + Service' defines abstract ScheduleRepository with: getVenues(courtId), getDaySlots(courtId, day), getWeekSlots(venueId, weekStart), getMonthOccupancy(courtId, month), createSlot(CreateSlotRequest), createRecurringSlots(req, weekdays, weeks), blockTime(BlockTimeRequest), approveSlot(slotId), rejectSlot(slotId), cancelSlot(slotId).
**Current:** The schedule data layer is `abstract interface class OwnerSlotRepository` (owner_slot_repository.dart:21-60) exposing only fetchWeekSlots({courtId, weekStart}), createOwnerSlot, createOpenSlot, blockSlot({slotId, reason}), unblockSlot({slotId}). 7 of the 10 specced methods are absent: getVenues, getDaySlots (Day view has no data path), getMonthOccupancy (Month heatmap has no data path), createRecurringSlots (no recurrence support), approveSlot, rejectSlot, cancelSlot (no approval/cancel lifecycle reachable from the schedule — ScheduleEvent in schedule_event.dart:5-61 has no approve/reject/cancel events). Approve/reject exist only in the separate requests feature as BookingActionRepository.approve/reject keyed by bookingId (lib/features/requests/repository/booking_action_repository.dart:20-33), not wired to the schedule screen, and there is no cancel anywhere.
**Verifier note:** One nuance: a functional getVenues equivalent does exist in the codebase — VenueRepository.fetchForCourt(courtId) at lib/features/courts/repository/venue_repository.dart:13 returns List<Venue> per court. But it belongs to the venue-management feature (VenueBloc / venue_form_screen), is not wired to the schedule, and the schedule has no venue dimension at all (OwnerSlotRepository.fetchWeekSlots queries slots by court_id, vs the spec's getWeekSlots(venueId, ...)). So getVenues is missing from the schedule contract as claimed, though not absent from the codebase entirely. Also trivial: BookingActionRepository's abstract interface spans lines 20-34 (not 20-33) and additionally has restorePending (undo), which doesn't affect the claim.

### [BLoC contract] Day/Week/Month view dimension absent from bloc contract
**Kind:** missing
**Handoff:** README §BLoC: event `viewChanged(ScheduleView)` (line 156) switches Day/Week/Month; state carries `@Default(ScheduleView.day) ScheduleView view` plus three datasets `daySlots`, `weekSlots`, `monthCells` (lines 172, 178–180); domain defines `enum ScheduleView { day, week, month }` (line 74).
**Current:** The bloc is week-only. No `viewChanged` event and no `ScheduleView` enum exist anywhere in the feature (grep over lib/features/schedule returns nothing). schedule_event.dart:15-16 only has `weekChanged(DateTime weekStart)`; schedule_state.dart:21-22 holds a single `weekStart` + one `List<OwnerSlot> slots` — no daySlots/weekSlots/monthCells split and no month occupancy data. schedule_bloc.dart:67-69 only ever calls `fetchWeekSlots`.

### [BLoC contract] Sport and slot-state filter events/state missing
**Kind:** missing
**Handoff:** README §BLoC: events `sportFilterToggled(SportType)` and `stateFilterToggled(SlotState)` — multi-select, empty set ⇒ all (lines 159–160); state fields `Set<SportType> sportFilter` and `Set<SlotState> stateFilter` (lines 176–177); "Filtering ... happens in the BLoC/Service against the loaded lists — mirror the toggleSet/filter logic in schedule-page.jsx" (line 186).
**Current:** No filter events, no Set fields, no `SportType`/filter logic anywhere in the feature — grep for sportFilter/stateFilter/Venue over lib/features/schedule returns zero hits. schedule_event.dart (full file, lines 1-61) defines only started/courtSelected/weekChanged/todayPressed/ownerSlotCreated/openSlotCreated/manualBookingCreated/bookingResultCleared/slotBlocked/slotUnblocked.

### [BLoC contract] Venue layer absent from contract: no venues/selectedVenueId/venueSelected; court-tab model instead
**Kind:** divergent
**Handoff:** README §Terminology (lines 14–24) + §BLoC: state must hold `venues: List<Venue>` and `selectedVenueId` (lines 173–174); event `venueSelected(String venueId)` switches the Week-view venue (line 158); `started(courtId)` scopes the whole screen to ONE Court selected elsewhere (line 156, line 22: "The whole screen is always scoped to one Court").
**Current:** No `Venue` type is referenced anywhere in the schedule feature. Instead the bloc models facility-level court tabs: `ScheduleEvent.courtSelected(String courtId)` (schedule_event.dart:11-12), state fields `courts: List<OwnerCourt>` + `activeCourtId` (schedule_state.dart:19-20). `started()` takes no courtId (schedule_event.dart:8) — the bloc loads ALL courts via an injected `CourtsLoader` and auto-picks the first (schedule_bloc.dart:55, 66), the opposite scoping of the spec. Slots are fetched per courtId with no per-venue resource dimension (schedule_bloc.dart:67-69).
**Verifier note:** Two minor precisions: (1) handoff `started(courtId)` is at README line 155, not 156 (lines 154-165 are the Events list); (2) "No Venue type referenced anywhere in the schedule feature" is true, but a Venue model does exist elsewhere in the codebase — lib/features/courts/model/venue.dart (id, courtId, name, sportType, capacity, pricePerHour) with VenueBloc/VenueRepository/venue_form_screen for venue CRUD — it is simply never imported by or wired into the schedule feature.

### [BLoC contract] approve / reject / cancel events missing
**Kind:** missing
**Handoff:** README §BLoC line 165: `approve(slotId)`, `reject(slotId)`, `cancel(slotId)` events; repository contract includes `approveSlot`/`rejectSlot`/`cancelSlot` (lines 137–139); detail-sheet footer requires Từ chối/Duyệt for pending and Huỷ for confirmed/fixed/open/private (lines 299–301).
**Current:** No approve, reject, or cancel event exists. schedule_bloc.dart:32-41 registers only ten handlers, none for booking lifecycle approval; the closest events are `slotBlocked`/`slotUnblocked` (schedule_event.dart:53-60), which are status toggles on open/blocked slots, not pending-booking moderation or booking cancellation.
**Verifier note:** The mismatch is real for the schedule screen, but the blanket statement "No approve, reject, or cancel event exists" overstates: approve/reject pending-booking moderation DOES exist in the codebase — features/requests has RequestsEvent.approved / RequestsEvent.rejected / RequestsEvent.undoRequested (lib/features/requests/bloc/requests_event.dart) handled by RequestsBloc and backed by Supabase via BookingActionRepository.approve/reject/restorePending (lib/features/requests/repository/booking_action_repository.dart, OWNER-28/29). What is actually missing: (1) these actions are not wired into the schedule screen's slot detail sheet / ScheduleBloc as README lines 165 and 299-301 require — the schedule's slot_actions_dialog.dart offers only block/unblock/view-players; and (2) cancel ("Huỷ") of confirmed/fixed/open/private bookings exists nowhere in the dashboard — the only status→cancelled write is the reject path, guarded on from=pending. Severity for approve/reject is arguably a screen-placement gap rather than absent functionality; severity for cancel stands as high.

### [BLoC contract] createSlotSubmitted contract partial: no private type, no recurrence, no capacity/price payload
**Kind:** partial
**Handoff:** README line 165 `createSlotSubmitted(...)` backed by `createSlot(CreateSlotRequest)` and `createRecurringSlots(req, weekdays, weeks)` (lines 134–135); Create sheet offers three types — empty, open (ghép), private — with open-slot extras `capacity` + `price/person` and a repeat mode of weekday toggles × number of weeks (lines 307–311).
**Current:** Two separate flat events replace it: `ownerSlotCreated(startAt, endAt)` (schedule_event.dart:22-25) and `openSlotCreated(startAt, endAt)` (schedule_event.dart:28-31). There is no `private` slot type, no capacity or price field on the open-slot event, and no recurrence parameters (weekdays/weeks) on any event; handlers create exactly one slot then refetch (schedule_bloc.dart:113-162). No `CreateSlotRequest` or `createRecurringSlots` equivalent exists.

### [Domain models] 9-value SlotState enum replaced by 6 string constants with semantic drift
**Kind:** divergent
**Handoff:** README 'Domain models (Freezed)' specifies `enum SlotState { confirmed, pending, fixed, open, private, empty, owner, maintenance, locked }` where `open` = public matchmaking slot and `empty` = created bookable slot with no customer yet (README lines 61-71; mirrored by SC_STATES in schedule-data.jsx lines 21-31).
**Current:** owner_slot.dart:12-33 defines `abstract final class SlotStatus` holding 6 raw String constants: open, booked, pending, owner, blocked, maintenance. It is not a Dart enum; OwnerSlot stores it as `String status` (owner_slot.dart:49), so no exhaustive switch is possible. Three spec states are entirely missing: `fixed` (recurring), `private` (held, unlisted), and a distinct `empty` — the code's `open` ('bookable availability window, visible to customers') is semantically the spec's `empty`, while the spec's `open` (public matchmaking, players join until full) has no representation. Naming also drifts: `booked` vs spec `confirmed`, `blocked` vs spec `locked`, class named SlotStatus vs spec SlotState.

### [Domain models] OccupancyDay model missing entirely
**Kind:** missing
**Handoff:** README 'Domain models (Freezed)' (lines 112-122) specifies `@freezed class OccupancyDay { DateTime date; double occupancy (0.0-1.0); int bookings; int revenue; bool isToday; bool isCurrentMonth; }` backing the Month occupancy heatmap (MONTH_CELLS in schedule-data.jsx lines 159-188).
**Current:** No OccupancyDay (or any occupancy/month-cell/heatmap) type exists anywhere under lib/ — grep for 'Occupancy', 'MonthCell', 'heatmap' returns zero Dart hits. The Month view's domain model is absent.

### [Domain models] ScheduleView enum (day/week/month) missing — domain is week-only
**Kind:** missing
**Handoff:** README line 74: `enum ScheduleView { day, week, month }`, with ScheduleState holding `@Default(ScheduleView.day) ScheduleView view` (lines 171-173) and viewChanged event.
**Current:** No ScheduleView enum exists anywhere in lib/ (grep returns nothing). ScheduleLoaded carries only `weekStart` and a flat slot list (schedule_state.dart:21-22), and events offer only weekChanged/todayPressed (schedule_event.dart:15-19) — the domain model has no concept of Day or Month views.

### [Domain models] Slot display/booking fields missing (label, subtitle, players, price, payment, bookingCode)
**Kind:** partial
**Handoff:** README Slot model (lines 91-110) requires `label` (customer/team name or 'Slot trống'/'Bảo trì'), `subtitle`, `players`, `capacity`, `price` (VND), `payment` (PaymentStatus?), `bookingCode` ('SPB-060149'), plus `startHour` as 24h decimal and `durationHours`. schedule-data.jsx DAY_SLOTS (lines 37-72) shows every slot carrying label/sub/players/cap/price/paid/mid.
**Current:** OwnerSlot (owner_slot.dart:44-59) carries only id, courtId, startAt, endAt, status, blockedReason, maxPlayers. Covered: capacity≈maxPlayers (line 58), durationHours as a derived getter (line 75); startHour/weekday are derivable from the absolute startAt/endAt DateTimes (an acceptable structural substitute). Missing with no equivalent: label, subtitle, players (joined count), price, payment, bookingCode — so slot blocks and the detail sheet cannot render the specced customer name, capacity badge numerator, price, payment badge, or booking code from this model.
**Verifier note:** The model-level claim is correct, but "Missing with no equivalent: ... players, price, payment" overstates the detail-sheet half. The slot detail roster (lib/features/slot_detail/, OWNER-33) fetches per-slot data independently of OwnerSlot via SlotPlayersRepository (slot_players_repository.dart:39,44 selects slot_participants.payment_status and bookings.customer_name/total_price) and DOES render: "X/Y" player count with capacity (capacity passed from slot.maxPlayers at slot_actions_dialog.dart:82), per-player customer names, paid/partial/unpaid payment chips (slot_player.dart:17, slot_roster_logic.dart:165-169), and VND prices including totalCollected/totalExpected (slot_players_dialog.dart:566,575). Genuinely missing with no equivalent anywhere: (1) on calendar slot blocks — customer name/label, subtitle, players/cap badge, price, payment badge (blocks render only a generic status label: schedule_screen.dart:566 'subject: _styleFor(s.status).label'); (2) slot-level subtitle and bookingCode anywhere in the schedule/slot-detail flow (a booking code exists only in the unrelated requests feature, booking_request.dart:54); (3) a slot-level aggregate payment badge (only per-player chips exist).

### [Domain models] Slot model is court-scoped — no venueId; schedule feature has no venue concept
**Kind:** missing
**Handoff:** README 'Terminology — READ FIRST' (lines 14-24): slots/resource columns belong to Venues (playing surfaces); the screen is scoped to one Court (facility). The Slot model requires `required String venueId` (README line 94), and Day view renders venues as resource columns.
**Current:** OwnerSlot's only ownership field is `courtId` (owner_slot.dart:46), mapped from `slots.court_id` which references the Court facility (SupabaseOwnerSlotRepository._cols at owner_slot_repository.dart:81-82, query .eq('court_id', courtId) at line 95). There is no venueId on the slot, and grep shows zero occurrences of 'venue' anywhere in features/schedule/ or features/slot_detail/. The existing Venue model (features/courts/model/venue.dart) is never referenced by the schedule feature, so per-venue slot placement (Day view columns, Week view venue chips) is impossible with the current domain model. Note this is not the prototype's court-misnomer (the code's courtId genuinely means the facility) — the venue dimension is simply absent from the slot domain.

### [Interactions] Day/Week/Month view switcher (with crossfade) missing — Week view only
**Kind:** missing
**Handoff:** README 'Interactions & Behavior' #1: segmented view switcher updates state.view between Day/Week/Month with an optional ~120ms cross-fade; #7: tapping a Month cell jumps to Day view on that date. BLoC spec includes viewChanged(ScheduleView) and monthDayTapped(DateTime) events and a ScheduleView enum.
**Current:** Only a single Week view exists: schedule_screen.dart:585 hardcodes `view: CalendarView.week` on SfCalendar and there is no view-switch segmented control anywhere in the widget tree (toolbar is _WeekNav, schedule_screen.dart:446-519, date-nav + 'Hôm nay' + slot count only). schedule_event.dart:5-61 defines no viewChanged or monthDayTapped events; schedule_state.dart:18-30 has no `view` field. Day view (venue resource columns) and Month occupancy heatmap views — and therefore the month-day-tap-to-Day interaction and any view crossfade — do not exist.

### [Interactions] Drag-to-block gesture (30-min snap, striped indigo band → Block sheet) missing
**Kind:** missing
**Handoff:** README #5: pointer-down on empty grid + vertical drag draws a translucent indigo band (45° stripes, 1.5px dashed #6366F1) with a live HH:MM–HH:MM label, snapping to 30-minute increments (`hour = 6 + floor(relY/60 × 2)/2`, see DayView/WeekView handlers in schedule-views.jsx:111-138, 199-213); on release with range ≥ 0.5h, the Block sheet opens prefilled. BLoC spec: dragBlockRequested(venueId, startHour, endHour, [weekday]). The page header also has a 'Khoá giờ' button opening the Block sheet directly.
**Current:** No drag interaction exists anywhere in the schedule feature — grep finds no onPan/pointer/long-press drag handlers (only chip GestureDetectors), and SfCalendar's onTap (schedule_screen.dart:631-647) is the only grid gesture; no drag band painter and no dragBlockRequested event (schedule_event.dart:5-61). There is no range-based Block sheet at all: the header's closest equivalent 'Khoá nhiều giờ' button is a coming-soon stub showing a '… sẽ có trong epic Đặt Slot.' snackbar (schedule_screen.dart:276-279 via _soon at 223-231). Blocking is only possible by tapping an already-existing open slot (slot_actions_dialog.dart:64-68).

### [Interactions] Live sport ('MÔN') and slot-state ('TRẠNG THÁI') filters missing
**Kind:** missing
**Handoff:** README #6 + 'Filters': two filter rows — multi-select sport chips filtering which venues appear/are selectable, and per-slot-state chips filtering which slots render; deselecting all = show all; filtering is live with no refetch (mirror toggleSet/filter in schedule-page.jsx:300-310). BLoC spec: sportFilterToggled(SportType), stateFilterToggled(SlotState) with Set-based state fields.
**Current:** No filter chips of either kind exist; the only chip row is _CourtTabs (schedule_screen.dart:348-442) which switches the active court and triggers a full refetch (ScheduleCourtSelected → _reload, schedule_bloc.dart:82-89, 294-321). schedule_event.dart has no sportFilterToggled/stateFilterToggled events and ScheduleLoaded (schedule_state.dart:18-30) has no sportFilter/stateFilter sets — slots always render unfiltered (schedule_screen.dart:561-570). The 'Kéo trên lưới để khoá giờ' drag hint is also absent.

### [Interactions] Tap on a booking slot opens block/unblock actions dialog instead of the Slot detail sheet
**Kind:** divergent
**Handoff:** README #3 + 'Slot detail sheet': tapping any booking slot opens a 480px right-side detail drawer with state banner, detail rows (code, venue, time, players, price, payment) and state-dependent footer actions — pending: Từ chối/Duyệt; empty: Mở ghép/Đặt sân; confirmed/fixed/open/private: Huỷ/Dời lịch/Gọi; locked/maintenance/owner: Mở khoá giờ này. BLoC spec includes slotTapped(Slot), approve(slotId), reject(slotId), cancel(slotId).
**Current:** Tapping a slot routes to showSlotActionsDialog (schedule_screen.dart:125-132 and onTap at 631-641), a centered Dialog whose sole purpose is block/unblock (slot_actions_dialog.dart:11-121): open → block with reason, blocked → unblock, booked → disabled-block error + 'Xem danh sách người chơi' (slot_actions_dialog.dart:321-411), everything else → 'Chỉ có thể khoá khung giờ còn trống' (117-121). There is no detail sheet (no state banner, booking code, price, payment rows) and no approve/reject/cancel/reschedule/call interactions; the bloc only has slotBlocked/slotUnblocked (schedule_event.dart:53-60, schedule_bloc.dart:224-237).

### [Sheets/drawers] No unified two-mode Create/Block drawer; block mode (type picker locked/maintenance/owner, range blocking) absent
**Kind:** divergent
**Handoff:** README 'Create / Block sheet (create_slot_sheet.dart)': ONE sheet with two modes — Create ('Tạo slot mới') and Block ('Khoá / chặn giờ') — each with a 3-card radio type picker (Create: Slot trống/Slot mở (ghép)/Slot riêng; Block: Khoá giờ/Bảo trì/Sân của tôi), opened from the page-header 'Khoá giờ' button or drag-to-block (schedule-page.jsx:143-278, 339).
**Current:** Three separate single-purpose centered dialogs exist instead: create_open_slot_dialog.dart, create_owner_slot_dialog.dart, create_manual_booking_dialog.dart — none has a type picker. There is no block-mode sheet: blocking only exists as a status flip on an existing open slot via slot_actions_dialog.dart:64-68 (ScheduleEvent.slotBlocked), maintenance blocks cannot be created at all, and the header's 'Khoá nhiều giờ' button just shows a 'sẽ có trong epic Đặt Slot' snackbar (schedule_screen.dart:275-279 via _soon at 223-231). Owner blocks are a separate dialog (create_owner_slot_dialog.dart) rather than a block-mode card.

### [Sheets/drawers] Open-matchmaking and private slot creation missing; no capacity ('Số người tối đa') / price ('Giá / người') extras
**Kind:** missing
**Handoff:** README 'Create / Block sheet': create-mode type picker offers Slot trống (empty), Slot mở (ghép) (open matchmaking), Slot riêng (private); when 'Slot mở (ghép)' is selected the sheet shows 'Số người tối đa' and 'Giá / người' number fields (schedule-page.jsx:159-163, 224-235).
**Current:** Only an empty bookable slot ('open' status, create_open_slot_dialog.dart) and an owner reservation (create_owner_slot_dialog.dart) can be created. There is no private-slot kind and no public matchmaking slot: create_open_slot_dialog.dart has no capacity or price inputs anywhere, and ScheduleEvent.openSlotCreated carries only startAt/endAt (schedule_event.dart:28-31). SlotStatus in owner_slot.dart:12-33 has no private/public-matchmaking value to create.

### [Sheets/drawers] Per-state footer actions missing: no Duyệt/Từ chối, no Huỷ/Dời lịch/Gọi, no Mở ghép/Đặt sân, unblock limited to 'blocked'
**Kind:** missing
**Handoff:** README 'Slot detail sheet' footer actions by state: pending → Từ chối (danger) + Duyệt (primary); empty → Mở ghép + Đặt sân; confirmed/fixed/open/private → Huỷ + Dời lịch + Gọi; locked/maintenance/owner → Mở khoá giờ này (schedule-page.jsx:117-134).
**Current:** slot_actions_dialog.dart offers only: open → 'Khoá giờ' (lines 124-186), blocked → 'Bỏ khoá' (lines 189-249), booked → disabled block + 'Xem danh sách người chơi' (lines 321-411). pending, owner and maintenance all fall to the catch-all 'Không thể khoá' info body (lines 117-121), so owner/maintenance slots cannot be unblocked and pending bookings cannot be approved/rejected from the sheet. Booked slots have no Huỷ/Dời lịch/Gọi. The bloc has no approve/reject/cancel/reschedule events at all — schedule_event.dart:5-61 only defines started/courtSelected/weekChanged/todayPressed/ownerSlotCreated/openSlotCreated/manualBookingCreated/bookingResultCleared/slotBlocked/slotUnblocked.

### [Sheets/drawers] Recurrence ('Lặp lại nhiều buổi') entirely missing — no weekday toggles, weeks field, preview card, or count-aware submit label
**Kind:** missing
**Handoff:** README 'Create / Block sheet': a BẬT/TẮT repeat pill toggle; when on, 7 weekday toggle buttons (T2…CN, primary-filled when active), a 'Số tuần' number field, and a preview card computing sessions = weekdays × weeks ('Sẽ tạo N slot · T3, T5 · 4 tuần · HH:MM–HH:MM') with batch chips; primary submit label reflects mode/count: 'Tạo slot' / 'Tạo N slot' / 'Khoá giờ' (schedule-page.jsx:237-265, 268-274); repository must expose createRecurringSlots (README 'Repository' section).
**Current:** No create dialog has any recurrence UI: create_open_slot_dialog.dart and create_owner_slot_dialog.dart contain only date chips + hour + duration (no toggle, weekday buttons, weeks field, or preview card). No recurring event exists in schedule_event.dart:5-61 and no createRecurringSlots in the repository layer. Submit labels are fixed single-slot strings: 'Mở slot' (create_open_slot_dialog.dart:338) and 'Tạo slot' (create_owner_slot_dialog.dart:340).

### [Sheets/drawers] Slot detail sheet replaced by a block/unblock action dialog — no state banner, detail rows, or contextual info cards
**Kind:** divergent
**Handoff:** README 'Slot detail sheet (slot_detail_sheet.dart)': a 480px right-side drawer with header (title = slot label, subtitle = 'venue · HH:MM–HH:MM'), a full-width state-tinted banner (bannerBg/bannerFg maps in schedule-page.jsx:79-80), detail rows — Mã (booking code, mono), Sân, Thời gian, Ghi chú, Người chơi (players/capacity), Giá (VND in primary-dark Sora), Thanh toán (payment badge) — plus contextual info cards for 'open' and 'empty' states (schedule-page.jsx:94-115).
**Current:** Tapping a slot opens slot_actions_dialog.dart, a 420px-max centered Dialog (slot_actions_dialog.dart:93-97) whose body only switches on whether the slot can be blocked (slot_actions_dialog.dart:113-121). There is no state banner, no Mã/Giá/Thanh toán/Người chơi/Ghi chú detail rows, and no contextual info cards. A partial detail header (court, sport, date/time chips, notes) exists only inside slot_players_dialog.dart:123-272, which is reachable solely for booked slots via the 'Xem danh sách người chơi' button (slot_actions_dialog.dart:359-379), and it still lacks booking code, slot price, payment badge, and state banner.

### [Slot styling] Slot name row shows the state label instead of the slot label (customer/team name)
**Kind:** divergent
**Handoff:** README 'Slot block' Contents: 'Name row: state icon (12px) + label (700 weight)', where Slot.label is 'customer/team name OR "Slot trống"/"Bảo trì"' (domain model, README Slot class). Prototype SlotBlock renders slot.label with a per-state icon from the stateIcon map (schedule-views.jsx:53,66).
**Current:** Appointment.subject is set to the state's display name — `subject: _styleFor(s.status).label` at schedule_screen.dart:566 — and rendered at schedule_screen.dart:700-711, so every block shows e.g. 'Đã đặt'/'Chờ duyệt' instead of who booked. OwnerSlot has no label/subtitle fields (owner_slot.dart:44-59). State icons are rendered only for owner and blocked at 11px (schedule_screen.dart:688-699); the check/clock/wrench/plus icons for booked/pending/maintenance/open are absent.

### [Slot styling] Slot styles missing for fixed, open (public matchmaking), and private states
**Kind:** missing
**Handoff:** README 'Slot-state styling (EXACT)' table defines 9 states including fixed (#EDE9FE bg / #A855F7 border / #5B21B6 text, 3px purple left accent bar, refresh icon), open/public (#CCFBF1 / #14B8A6 / #115E59, globe icon), and private (#E0E7FF / #6366F1 / #3730A3, dashed border, eye-off icon). Mirrored in schedule-styles.css .st-fixed (incl. ::before 3px accent, lines 84-87), .st-public (88), .st-private (89).
**Current:** _styleFor at schedule_screen.dart:32-45 only handles owner, booked, pending, maintenance, blocked plus a default fallback; the SlotStatus catalogue (owner_slot.dart:12-33) has no fixed/private/public-matchmaking values at all. The code's 'open' status hits the default branch and is styled like the spec's 'empty' state ('Còn trống', surface/neutral200/neutral500), so the teal matchmaking style, the indigo private style, and the purple fixed style with 3px left accent exist nowhere in the rendering.

### [Toolbar & filters] "MÔN" sport filter chip row is missing
**Kind:** missing
**Handoff:** README "Filters (two rows)" Row 1: label "MÔN" (uppercase 11px/700 --n-400) followed by sport chips `Bóng đá`, `Pickleball`, `Tennis` — multi-toggle; empty selection ⇒ all. BLoC event `sportFilterToggled(SportType)`; sport chips filter which venues appear (Day) / are selectable (Week). Chip style: white bg, 1px --n-200, pill, 7×13px padding, 12.5/600 --n-700; active = --n-900 bg + white text.
**Current:** No sport filter exists. schedule_screen.dart contains no "MÔN" label or sport chips; grep over lib/features/schedule/ finds no `SportType`/`sportFilter` references and schedule_event.dart has no `sportFilterToggled` event. The only chip row on screen is the court-tab row `_CourtTabs` (schedule_screen.dart:348-442), which is a venue/court selector, not a sport filter.

### [Toolbar & filters] "TRẠNG THÁI" slot-state filter chip row is missing
**Kind:** missing
**Handoff:** README "Filters (two rows)" Row 2: label "TRẠNG THÁI" + one chip per slot state, each showing a 10px colour swatch + short label (Đã đặt, Chờ duyệt, Cố định, Mở ghép, Riêng, Trống, Sân chủ, Bảo trì, Khoá — per SC_STATES in schedule-data.jsx:21-31). Multi-select; deselecting all = show all; live filtering of rendered slots via `stateFilterToggled(SlotState)`.
**Current:** No state filter row exists. Slot states appear only as a non-interactive legend strip under the calendar (`_Legend`, schedule_screen.dart:748-798) with 6 statuses (booked/pending/owner/maintenance/blocked/open). There is no chip row above the grid, no swatch+short-label toggle chips, and no `stateFilterToggled` event in schedule_event.dart — slots cannot be filtered by state at all.

### [Toolbar & filters] Header "Khoá giờ" action is a non-functional stub renamed "Khoá nhiều giờ"
**Kind:** partial
**Handoff:** README "Page header": right-aligned secondary button "Khoá giờ" (white, 1px --n-200 border, lock icon) that opens the Block sheet (type picker Khoá giờ / Bảo trì / Sân của tôi, README "Create / Block sheet").
**Current:** The header renders a secondary button labelled "Khoá nhiều giờ" (schedule_screen.dart:275-279) whose onTap calls `_soon(context, 'Khoá nhiều giờ')` — a placeholder that just shows a SnackBar "Khoá nhiều giờ sẽ có trong epic Đặt Slot." (schedule_screen.dart:223-231). No Block sheet opens from the header; blocking is only reachable by tapping an already-existing slot (slot_actions_dialog via `_openSlotActions`, schedule_screen.dart:125-132).

### [Toolbar & filters] Toolbar 3-segment view switcher (Ngày / Tuần / Tháng) is missing
**Kind:** missing
**Handoff:** README "Toolbar": after the date navigator and "Hôm nay" button comes a segmented view switcher — pill container bg --n-100, padding 3px, radius 10px; each button 13px/600, icon + label (`▦ Ngày`, `📅 Tuần`, `▦ Tháng`); active = white bg + --shadow-sm + --n-900 text, inactive --n-600; labels hide <640px. Drives `viewChanged(ScheduleView)` (README BLoC events) and the per-view stats text.
**Current:** No view switcher exists anywhere. The toolbar `_WeekNav` (schedule_screen.dart:446-519) renders only the date-nav pill, the "Hôm nay" button, a Spacer, and a slot-count text. The calendar is hard-pinned to week view (`view: CalendarView.week`, schedule_screen.dart:585) and `schedule_event.dart` has no `viewChanged` event (events are started/courtSelected/weekChanged/todayPressed/slot CRUD only). Day and Month views — and their toolbar stats variants ("<N> đã đặt · <N> còn mở · <P>% lấp đầy", "Lấp đầy TB tháng <P>%") — are consequently absent.

### [Toolbar & filters] Venue chip row selects Court facilities (OwnerCourt), not Venues — terminology/structure violation
**Kind:** naming
**Handoff:** README "⚠️ Terminology — READ FIRST" + "Filters": the screen is always scoped to ONE Court (facility); the chips in Week view are "SÂN" venue chips that select a Venue (an individual playing surface) via `venueSelected(String venueId)`. Flutter classes must use `Venue`/`venueId` naming and must not carry the `court` misnomer.
**Current:** The chip row `_CourtTabs` (schedule_screen.dart:348-442) iterates `List<OwnerCourt>` (the facility model from features/setup/model/owner_court.dart) and dispatches `ScheduleEvent.courtSelected(c.id)` (schedule_screen.dart:366-368; event defined in schedule_event.dart "Owner picked a different court tab"). `ScheduleLoaded` holds `courts`/`activeCourtId` (schedule_state.dart). The schedule screen has no Venue dimension at all, even though a `Venue` model (id, courtId, name, sportType…) already exists at lib/features/courts/model/venue.dart:6-18 and is unused here — the chips switch whole facilities rather than playing surfaces within one facility.

### [Views] Day view (venue resource columns) is entirely missing
**Kind:** missing
**Handoff:** README section '1) Day view (day_view.dart) — resource columns': all venues for focusedDate shown side by side; sticky header row with grid '[64px time-gutter] + N equal venue columns', each venue header cell showing a 9px coloured dot + venue name (Sora 14/700) + sport (11px n-500) + right-aligned '<N> slot' count (mono 11px); body 17 hours x 60px = 1020px with hour gridlines; a 'Now' line — 2px --danger (#EF4444) spanning all venue columns at top = (nowHour - 6) x 60px with an 8px dot, using real DateTime.now() and rendered only if today is visible within 6:00-22:00 (prototype DayView in schedule-views.jsx lines 107-192, day-now at line 188).
**Current:** No Day view exists at all. The only calendar rendered is a Syncfusion SfCalendar locked to CalendarView.week (schedule_screen.dart:583-585). There are no per-venue resource columns (the Venue model at lib/features/courts/model/venue.dart is never referenced anywhere in lib/features/schedule/), no venue header cells with dot/name/sport/slot-count, and no --danger now-line anywhere in the feature. The view/ directory contains only schedule_screen.dart plus dialogs — no day_view.dart.

### [Views] Month view (occupancy heatmap) is entirely missing
**Kind:** missing
**Handoff:** README section '3) Month view (month_view.dart) — occupancy heatmap': 7-column full-week grid; cells >= 96px with day number (today in a 26px --primary filled circle, white text; other-month days n-50 bg / n-300 number, not interactive); a full-cell heat tint at opacity = occ x 0.18 + 0.04; occupancy colour scale o<0.35 -> #BBF7D0, <0.55 -> #4ADE80, <0.70 -> #FCD34D, <0.85 -> #FB923C, else #EF4444 (occColor in schedule-views.jsx:257); bottom '<P>%' + '<N> slot' + 6px progress bar; footer scale bar 'Ty le lap day' + 160x10px gradient pill + 'thap -> cao' + hint 'Nhap vao ngay de xem chi tiet'; tap a day -> switch to Day view (monthDayTapped event). Domain model OccupancyDay and repo method getMonthOccupancy specified in the README Architecture section.
**Current:** No Month view, heatmap, or occupancy concept exists. The model directory has no OccupancyDay (only owner_slot.dart and manual_booking_result.dart); ScheduleLoaded state holds only courts/activeCourtId/weekStart/slots (schedule_state.dart:18-30) with no monthCells; events have no monthDayTapped or month navigation (schedule_event.dart:6-61); the repository layer has no month-occupancy fetch. occColor thresholds, today circle, and gradient scale bar appear nowhere.
**Verifier note:** Two trivial imprecisions, neither substantive: (1) ScheduleLoaded also carries `busy` and `bookingResult` fields beyond courts/activeCourtId/weekStart/slots; (2) the model directory also contains generated owner_slot.freezed.dart alongside owner_slot.dart and manual_booking_result.dart. Neither changes the finding — no month/occupancy data exists anywhere.

### [Views] Week view is scoped to a whole Court (facility), not a single Venue — no venue dimension at all
**Kind:** divergent
**Handoff:** README section '2) Week view — one venue, 7 days': 'Venue chosen via the venue filter chips' (Filters row 1: 'SAN' label + venue chips each with a coloured dot); state carries selectedVenueId and repo exposes getWeekSlots(venueId, weekStart). The terminology section stresses the prototype's 'court'/'weekCourt' = Venue, and the screen is always scoped to one Court whose Venues are the resources.
**Current:** The week grid shows every slot of the active OwnerCourt (the facility): _CourtTabs (schedule_screen.dart:348-442) switches between OwnerCourt records via ScheduleEvent.courtSelected, state holds activeCourtId not selectedVenueId (schedule_state.dart:19-21), and OwnerSlot carries only courtId with no venueId field (owner_slot.dart:46). The existing Venue model (lib/features/courts/model/venue.dart) is never imported by the schedule feature, so slots from all venues of a court are flattened into one 7-day grid where same-time slots on different venues would collide, and there is no way to view a single venue's week as specified.


## MEDIUM (22)

### [Architecture] No ScheduleService layer — bloc depends on repositories and an ad-hoc callback directly
**Kind:** missing
**Handoff:** README 'Architecture (target Flutter app)' + 'Repository (abstract) + Service': dependency direction must be 'Bloc → Service → Repository(abstract) ← RepositoryImpl → DataSource', with domain/services/schedule_service.dart — 'class ScheduleService { final ScheduleRepository _repo; ... }' holding the logic (occupancy %, peak detection, recurrence expansion preview, slot overlap validation). The Overview also mandates 'a service layer for business logic' as an established convention.
**Current:** No Service class exists anywhere in the dashboard (grep for 'class .*Service' across lib/ returns nothing). ScheduleBloc injects OwnerSlotRepository, ManualBookingRepository, and a bare typedef callback `CourtsLoader = Future<List<OwnerCourt>> Function()` directly (schedule_bloc.dart:17, 22-30), wired in the router as `loadCourts: () => sl<OwnerCourtRepository>().getCourts()` (app_router.dart:142-146). Business logic lives as free top-level functions in schedule_logic.dart (mondayOf, hasConflict, intervalsOverlap) and booking_logic.dart (normalizeVietnamPhone, buildManualBookingPayload, crossesUtcDateBoundary) called straight from the bloc and view dialogs — there is no class that owns a repository. Specced service responsibilities 'occupancy %', 'peak detection', and 'recurrence expansion preview' have no implementation at all; only slot overlap validation exists (schedule_logic.dart:53-58).

### [Architecture] blockTime(range, kind) replaced by status-flip of a pre-existing open slot; no maintenance block path
**Kind:** divergent
**Handoff:** README repository contract: `Future<void> blockTime(BlockTimeRequest req)  // locked/maintenance/owner` — block an arbitrary time range with one of three block kinds. The Create/Block sheet section lists block types Khoá giờ (locked), Bảo trì (maintenance), Sân của tôi (owner), and drag-to-block produces a free start+duration range.
**Current:** OwnerSlotRepository.blockSlot({slotId, reason}) only mutates an existing slot row from status 'open' to 'blocked' (owner_slot_repository.dart:159-179, guard `.eq('status', SlotStatus.open)` at line 170), so blocking presupposes an already-created open slot with exactly matching boundaries — there is no range-based block API. Owner-use is a separate insert path (createOwnerSlot, lines 110-132), and there is no creation path for maintenance at all (SlotStatus.maintenance is a dead constant, owner_slot.dart:31-32). The bloc mirrors this: ScheduleSlotBlocked carries a slotId, not a range (schedule_event.dart:53-56; schedule_bloc.dart:224-237).
**Verifier note:** One minor imprecision: 'SlotStatus.maintenance is a dead constant' overstates slightly — the constant is consumed read-side in schedule_screen.dart (_styleFor at line 39 and the legend at line 757), so maintenance rows fetched from the DB would render with Bảo trì styling. The substantive point stands: there is no write/creation path for maintenance anywhere in the dashboard.

### [BLoC contract] Interaction events slotTapped / emptyCellTapped / dragBlockRequested / monthDayTapped missing — sheet routing lives in the view layer
**Kind:** missing
**Handoff:** README §BLoC: "ScheduleBloc is the only state holder for the screen" (line 152) with events `slotTapped(Slot)` (open detail sheet), `emptyCellTapped(venueId, startHour, [weekday])`, `dragBlockRequested(venueId, startHour, endHour, [weekday])`, `monthDayTapped(DateTime)` (lines 161–164).
**Current:** None of these four events exist (schedule_event.dart:1-61). Tap handling and dialog opening are done directly in widgets: schedule_screen.dart:105-137 wires dialog launchers with the bloc passed in, schedule_screen.dart:367 and :628 dispatch terminal events from UI callbacks, and slot_actions_dialog.dart:66 dispatches `slotBlocked` from inside the dialog. Drag-to-block has no event at all, and month-day tap has no counterpart (no month view).

### [BLoC contract] State is a sealed 4-variant union, not the specified single class with a status enum
**Kind:** divergent
**Handoff:** README §BLoC state (lines 167–185): a single `@freezed` class `ScheduleState` (`_ScheduleState`) holding all fields with `@Default(ScheduleStatus.loading) ScheduleStatus status` — view, filters, and loaded data persist across load cycles in one object.
**Current:** schedule_state.dart:11-35 defines `sealed class ScheduleState` with four variants: `ScheduleInitial`, `ScheduleLoading`, `ScheduleLoaded`, `ScheduleFailure`, plus a `busy` flag on Loaded (line 23) instead of a status enum. On any load error the whole loaded state is discarded for `ScheduleFailure` (schedule_bloc.dart:78, 264, 319), losing courts/weekStart context. Note: the union style follows the project CLAUDE.md Freezed convention (sealed unions, @With<AppExceptionMixin> on failure — correctly applied at schedule_state.dart:32-34), so this is a README-vs-house-style conflict rather than a convention violation; the freezed style itself matches CLAUDE.md.

### [BLoC contract] blockSubmitted semantics divergent: mutates an existing slot by id instead of blocking a time range with a type
**Kind:** divergent
**Handoff:** README line 165 `blockSubmitted(...)` backed by `blockTime(BlockTimeRequest)` for locked/maintenance/owner (line 136); the Block sheet takes venue + start + duration + one of three block types (lines 306–307) and drag-to-block prefills an arbitrary range (line 287).
**Current:** `ScheduleEvent.slotBlocked(String slotId, {String? reason})` (schedule_event.dart:53-56) flips an already-existing open slot's status to `blocked` with a free-text reason (schedule_bloc.dart:224-231 → blockSlot in owner_slot_repository.dart:49); it cannot block an arbitrary venue/time range and supports only one block type (`blocked`) — `maintenance` exists only as a status constant (owner_slot.dart:32) with no event to set it, and `owner` is reachable only through the separate ownerSlotCreated creation flow. The `reason` payload and the companion `slotUnblocked(slotId)` event (schedule_event.dart:59-60) are not in the README event list (unblock is only a detail-sheet footer action, line 302).
**Verifier note:** Minor citation drift only: the Block-sheet venue/start/duration + type-picker spec is at README lines 307-309, not 306-307 (306 is the mode header line); and `blockSlot` in owner_slot_repository.dart is declared at line 54 with implementation at line 159 — line 49 cited in the claim is the start of its doc comment. Substance of the claim is unchanged.

### [BLoC contract] toast field missing — only manual booking gets a transient success/failure signal
**Kind:** partial
**Handoff:** README state field `String? toast` (line 182) — "transient success message", auto-dismiss 3500ms (line 186); Interaction 8 (line 290): "every successful action (approve, reject, cancel, create, block, open-for-matchmaking, unlock) shows a dark toast".
**Current:** No `toast` field or string anywhere in the feature (grep returns nothing). The only transient signal is `ManualBookingResult? bookingResult` (schedule_state.dart:29), set exclusively by the manual-booking handler (schedule_bloc.dart:198-206, 211-214) and cleared via `bookingResultCleared`. Successful owner-slot create, open-slot create, block, and unblock emit no success signal at all — they just silently refresh slots with `bookingResult: null` (schedule_bloc.dart:132, 157, 262).
**Verifier note:** Substantively correct; two refinements. (1) "only manual booking gets a transient success/failure signal" is precise for SUCCESS but slightly understates failure handling: any ScheduleFailure (including failed create/block) triggers a red SnackBar via the BlocConsumer listener at schedule_screen.dart:68-77 — though that path also replaces the loaded view with a failure screen, so it is destructive, not the spec's transient toast. The real gap is success feedback for owner-slot create, open-slot create, block, and unblock. (2) Approve/reject success toasts exist but live in the Requests feature (requests_screen.dart:47-81, dark neutral800 snackbars with undo), not the Schedule screen — partially covering Interaction 8's approve/reject items on a different screen. Interaction 8 cite is line ~289 rather than 290 (off by one).

### [Design tokens] JetBrains Mono typography role missing — times/codes/capacity use Plus Jakarta Sans
**Kind:** missing
**Handoff:** README §Typography: "Mono (times, codes, capacity): JetBrains Mono — 400/500" loaded via google_fonts. Applied throughout the spec: slot block time "HH:MM–HH:MM, JetBrains Mono 10px" (§Slot block), Day-view time gutter "mono 10.5px --n-400" and venue header slot count "mono 11px" (§Day view), capacity badge "mono 9.5/800", detail-sheet booking code "Mã (booking code, mono)" (§Slot detail sheet).
**Current:** No monospace font is used anywhere in lib/ (grep for mono/jetBrainsMono/fontFamily returns zero font hits). The theme defines only Plus Jakarta Sans + Sora (app_theme.dart:18-19) with no mono text style. Slot-block time rows render in GoogleFonts.plusJakartaSans 10px (schedule_screen.dart:714-722); the calendar time-gutter timeTextStyle is GoogleFonts.plusJakartaSans 11px (schedule_screen.dart:603-606, spec says mono 10.5px). google_fonts ^6.2.1 is already a dependency (pubspec.yaml:29) so GoogleFonts.jetBrainsMono is available but never called.

### [Design tokens] Venue dot palette not applied in schedule — single fixed green dot for all venues, palette buried as private map in courts feature
**Kind:** divergent
**Handoff:** README §Venue dot palette: "one per venue — Football #16A34A / #0EA5E9, Pickleball #F97316 / #A855F7, Tennis #EC4899"; the Venue domain model carries "required int colorValue // venue dot colour (see palette)" (§Domain models), and the dot appears on Day-view venue headers (9px), Week-view venue chips (8px circle), and filter chips.
**Current:** The schedule screen's tab dots ignore venue identity entirely: every tab's 8px dot is `active ? AppColors.primaryMid : AppColors.primary` (schedule_screen.dart:382-390). The Venue model has no colorValue field (venue.dart:9-17). A near-matching palette does exist but only as a private screen-local constant `_kSportColors` keyed by sport-label string in the courts feature (court_detail_screen.dart:16-24, includes #16A34A/#0EA5E9/#F97316/#A855F7/#EC4899) — it is not a shared token and is never imported by the schedule feature.

### [Domain models] SportType enum missing — sport is stringly-typed
**Kind:** divergent
**Handoff:** README line 75: `enum SportType { football, pickleball, tennis }` (Bóng đá / Pickleball / Tennis), used as Venue.sport and as the type of the sportFilter Set.
**Current:** No SportType enum exists in lib/. Venue.sportType is a raw `required String sportType` (venue.dart:13) parsed from `sport_type` with '' fallback (venue.dart:24), and the only sport catalogue is `kSportTypes`, a const List<String> of 8 Vietnamese display strings in owner_court.dart:6-15. There is no typed sport value to drive the multi-select sport filter specced in ScheduleState.

### [Domain models] Venue model missing shortCode, colorValue, and sport/sportLabel split
**Kind:** partial
**Handoff:** README Venue model (lines 77-88) requires `shortCode` ('S1'), `sport` (SportType enum), `sportLabel` ('Bóng đá 5v5'), and `colorValue` (venue dot colour from the palette: Football #16A34A/#0EA5E9, Pickleball #F97316/#A855F7, Tennis #EC4899 — README 'Venue dot palette'), plus id, name, pricePerHour. Matches SC_COURTS shape (schedule-data.jsx lines 5-11: short, sport, group, color, price).
**Current:** Venue (venue.dart:9-17) has id, courtId, name, sportType (single raw String doing duty for both sport and sportLabel), capacity, pricePerHour, isActive. Missing: shortCode, colorValue (no venue dot colour anywhere), and the typed sport vs display sportLabel distinction. id/name/pricePerHour match; courtId/capacity/isActive are persistence extras not in the spec but unobjectionable. Freezed usage is correct.
**Verifier note:** Core claim stands, with one refinement: "no venue dot colour anywhere" is slightly overstated. court_detail_screen.dart:16-25 defines a _kSportColors map (sport-label String -> Color: 'Bóng đá 5v5' #16A34A, 'Pickleball' #F97316, 'Tennis' #EC4899, 'Cầu lông' #A855F7, 'Đa năng' #0EA5E9) and renders a 9px venue dot (lines 668-684). But this is a per-SPORT UI lookup keyed on the raw sportType string, not a per-VENUE colorValue on the model as the spec requires (SC_COURTS gives same-sport venues distinct dots, e.g. Sân 1 #16A34A vs Sân 2 #0EA5E9 — impossible with a sport-keyed map), and it appears only in the court-detail screen, not in the schedule feature the handoff covers. shortCode, the SportType enum, and the sport/sportLabel split are confirmed absent from the entire codebase.

### [Interactions] Empty-cell tap prefill diverges: whole-hour snap only and 90-min default instead of 1h
**Kind:** partial
**Handoff:** README #4: tap an empty grid area → Create sheet prefilled with the venue + snapped start hour (30-min snap math shared with drag, schedule-views.jsx:111-115 / onClick at 169-173 passes `dur: 1`) and default duration 1h. Create sheet start dropdown offers 30-min steps 06:00–22:30 (schedule-page.jsx:214-216).
**Current:** The tap-to-create wiring exists (schedule_screen.dart:642-646 onTapEmpty → _openCreate with `at`, 101-111), but SfCalendar's default 60-minute cells mean the prefilled time is snapped to whole hours only — half-hour starts (e.g. 18:30) are impossible: create_open_slot_dialog.dart:73 takes `init?.hour ?? 18` (minutes dropped) and the start dropdown only lists whole hours 06:00–21:00 (create_open_slot_dialog.dart:199-205). The default duration is 90 minutes (`int _duration = 90;`, create_open_slot_dialog.dart:59) instead of the specified 1h, for both header-create and empty-cell tap.
**Verifier note:** The core mismatch is real and correctly cited, but the duration part is narrower than claimed: the handoff specifies the 1h default only for the empty-cell-tap prefill (README #4; schedule-views.jsx Day onClick :169-173 / Week :236 pass `dur: 1`). For header-create, the prototype itself defaults to 1.5h (schedule-page.jsx:148 `useState(init.dur || 1.5)`; the header button at :340 passes no dur), so Flutter's 90-min default (create_open_slot_dialog.dart:59) matches the prototype on the header path. The 90-min-vs-1h divergence applies to the empty-cell-tap path only.

### [Interactions] Responsive breakpoints (1024/640) not implemented
**Kind:** missing
**Handoff:** README 'Responsive': ≤1024px — Day/Week grids gain horizontal scroll (min-width ~720-760px) and detail/create drawers go full-width; ≤640px — view-switch buttons become icon-only and month cells shrink. 'Flutter web: use LayoutBuilder/MediaQuery breakpoints at 1024 and 640; wrap the grids in horizontal SingleChildScrollView under 1024.'
**Current:** Grep finds no MediaQuery or LayoutBuilder usage in lib/features/schedule/. The page is a fixed-padding vertical SingleChildScrollView only (schedule_screen.dart:164-165, EdgeInsets.fromLTRB(28, 26, 28, 60)) with a fixed-height calendar (schedule_screen.dart:581-582); there is no horizontal scroll wrapper for narrow widths. Dialogs are width-capped centered Dialogs (create_open_slot_dialog.dart:102-103 maxWidth 460; slot_actions_dialog.dart:96-97 maxWidth 420) with no full-width small-screen behavior, and there is no view switcher to collapse to icons.
**Verifier note:** Minor nuance only: the first clause of the README's <=1024 rule (sidebar collapsing to off-canvas drawer) IS implemented at lib/shell/app_shell.dart:128 via MediaQuery width >= 1024, but the README marks that as pre-existing app behaviour and the claim correctly scopes itself to the schedule-specific items (grid horizontal scroll, full-width drawers, icon-only view buttons, month-cell shrink), all of which are absent.

### [Interactions] Success toast behavior divergent: SnackBars, and most successful actions give no feedback
**Kind:** divergent
**Handoff:** README #8: every successful action (approve, reject, cancel, create, block, open-for-matchmaking, unlock) shows a dark toast at bottom-centre (--n-900 bg, white text, check icon, radius 10px) auto-dismissing after 3500ms; state spec has a transient `toast` field (README BLoC section, and Toast component in schedule-page.jsx:281-285 with setTimeout 3500).
**Current:** ScheduleState has no toast field (schedule_state.dart:18-30) and the bloc emits nothing on success for open-slot create, owner-slot create, block, or unblock — it silently reloads (schedule_bloc.dart:132, 157, 252-262), so those actions produce zero user feedback. The only success feedback is a green floating Material SnackBar after a manual booking, shown imperatively by the view (schedule_screen.dart:145-157) with the default 4s duration; failures use a red floating SnackBar (schedule_screen.dart:68-77). No dark bottom-center 3500ms toast exists anywhere.
**Verifier note:** The claim is correct for the schedule feature, but the blanket statement "most successful actions give no feedback" needs one scope note: approve/reject (two of the seven actions in README #8) are handled in the separate requests feature, and requests_screen.dart:49-79 DOES show success SnackBars for them ('Đã duyệt đơn…' / 'Đã từ chối đơn…') — dark AppColors.neutral800 bg, floating, 5s duration, with an Undo action. That is still divergent from the spec'd toast (floating SnackBar vs fixed bottom-centre, 5000ms vs 3500ms, no check icon, neutral800 vs n-900) but it is not zero feedback. Within the schedule feature itself the claim is exactly right: open-slot create, owner-slot create, block, and unblock produce no success feedback at all.

### [Sheets/drawers] All sheets are centered modal Dialogs, not 480px right-side drawers with scrim
**Kind:** divergent
**Handoff:** README 'Slot detail sheet' / 'Create / Block sheet': right-side drawer, 480px wide (full-width <1024px), white, left border --n-200, --shadow-xl, slides in ~140ms, behind a rgba(17,24,39,.4) blurred scrim with head/body/foot chrome (styles.css:865-890, drawer-foot on --n-50 background).
**Current:** Every surface is a centered rounded Material Dialog: slot_actions_dialog.dart:93-97 (maxWidth 420), create_open_slot_dialog.dart:99-103 (maxWidth 460), create_owner_slot_dialog.dart:100-104 (maxWidth 460), create_manual_booking_dialog.dart:186-191 (maxWidth 480), slot_players_dialog.dart:69-73 (maxWidth 480). None uses the drawer head/body/foot structure, side-anchored slide-in, or full-width-under-1024 responsive rule.

### [Sheets/drawers] Start/duration controls diverge: 1-hour-step start dropdown, minute chips without 2.5h, no 'Kết thúc lúc HH:MM' hint
**Kind:** partial
**Handoff:** README 'Create / Block sheet': start-hour dropdown in 30-minute steps 06:00–22:30, duration dropdown of 1/1.5/2/2.5/3 giờ, and a live hint 'Kết thúc lúc HH:MM' under the row (schedule-page.jsx:211-222).
**Current:** create_open_slot_dialog.dart:199-205 and create_owner_slot_dialog.dart:200-206 offer whole hours only (for h = kOpenHour; h < kCloseHour; h++ → ':00' items, no :30 starts). Duration is a chip row of [60, 90, 120, 180] minutes (_kDurations, create_open_slot_dialog.dart:35) — 150 min/2.5h is missing and it is chips, not a dropdown. There is no end-time hint; instead a combined summary row 'HH:MM – HH:MM · day dd/MM' renders below validation (create_open_slot_dialog.dart:287-302). Only the manual-booking dialog uses 30-minute steps (_kStep = 30, create_manual_booking_dialog.dart:44).

### [Sheets/drawers] Venue selector missing from create dialogs; manual-booking dropdown lacks 'name · sport' format (sport shown as '—')
**Kind:** partial
**Handoff:** README 'Create / Block sheet': a 'Sân' select listing all venues formatted 'name · sport' (schedule-page.jsx:204-209: SC_COURTS.map(c => `${c.name} · ${c.sport}`)).
**Current:** create_open_slot_dialog.dart and create_owner_slot_dialog.dart have no venue selector at all — they are bound to the single pre-selected court, shown only as static header text (create_open_slot_dialog.dart:139-142). The manual-booking dialog does have a dropdown but items show name only (create_manual_booking_dialog.dart:452-454) and the adjacent 'Môn' field is a hard-coded '—' placeholder (create_manual_booking_dialog.dart:467-484).
**Verifier note:** Only trivial citation drift: static header text in create_open_slot_dialog.dart starts at line 138 (not 139), and the manual-booking dropdown items span lines 452-455 (not 452-454). Additionally, the gap is deeper than formatting: the dropdown iterates OwnerCourt facilities (which have no sport field), and the Venue model that does carry sportType is never referenced by the schedule feature.

### [Slot styling] Capacity badge missing from slot block
**Kind:** missing
**Handoff:** README 'Slot block' Contents: 'Capacity badge (if capacity != null, bottom-right): players/capacity, mono 9.5px/800, on a translucent white rounded chip'. Prototype: .s-cap (schedule-styles.css:76-80) and SlotBlock renders {slot.players}/{slot.cap} when height > 30 (schedule-views.jsx:69).
**Current:** _buildAppointment (schedule_screen.dart:656-737) renders no capacity badge at all, even though OwnerSlot.maxPlayers exists (owner_slot.dart:58) and the slot_detail feature tracks joined players; the players/capacity count is never surfaced on the block.

### [Slot styling] Dashed borders and striped fills not implemented for any state
**Kind:** missing
**Handoff:** README styling table: pending, private, and empty have DASHED borders; empty fill = 135° diagonal stripes #FFF/--n-50 at 7px/14px; locked fill = 45° stripes --n-100/--n-200 at 6px/12px (schedule-styles.css:83, 89, 90-93, 98-101). README explicitly instructs modelling this as a SlotStateStyle lookup with a dashed flag and using a custom BoxDecoration painter / dotted_border + CustomPainter for stripes.
**Current:** Every slot renders with a solid 1px `Border.all(color: style.border)` and a flat background color (schedule_screen.dart:676-681). pending is solid (line 37-38), blocked is flat neutral100 with no stripes (lines 41-42), the empty/default branch is flat surface with no stripes or dashes (lines 43-44). There is no CustomPainter, dashed-border, or SlotStateStyle dashed/accent flag anywhere in the file.

### [Slot styling] Grid scale & position math: SfCalendar at 56px/hour instead of spec 60px/hour formulas
**Kind:** divergent
**Handoff:** README 'Slot block' Position: 'top = (startHour − 6) × 60px + 2, height = max(durationHours × 60 − 4, 22)px'; Design Tokens: 'Grid: 60px per hour, time gutter 64px' (--hour-px: 60px in schedule-styles.css:7; SlotBlock top/height math in schedule-views.jsx:62,176).
**Current:** Slot positioning is delegated entirely to syncfusion SfCalendar with `timeIntervalHeight: 56` (schedule_screen.dart:601) and card height `17 * 56.0 + 60` (line 582) — 56px per hour, not 60 — and there is no min-height-22 clamp or −4px height inset. The OwnerSlot doc comment even asserts '1h == 56px in the design' (owner_slot.dart:73-75), directly contradicting the handoff token.
**Verifier note:** Claim is accurate as stated. Only trivial fix: the handoff jsx citation 'schedule-views.jsx:62,176' should be 'schedule-views.jsx:62 (slot clamp), 167/180-181 (HPX grid and drag math)'.

### [Slot styling] Legend: wrong placement/structure and missing state entries
**Kind:** partial
**Handoff:** README 'Legend (slot_legend.dart)': a standalone white card (1px --n-200 border, radius 14px, padding 13×18px, margin-top 14) shown UNDER Day & Week views, with a swatch+label pair for EVERY slot state (all 9 from SC_STATES); swatch = 13px rounded square using the state's border/bg, with a dashed swatch border for dashed states (pending/private/empty) (schedule-views.jsx:96-102; schedule-styles.css:104-114). Legend uses the full labels, e.g. 'Sân chủ / cá nhân', 'Khoá / đóng cửa', 'Slot trống'.
**Current:** _Legend (schedule_screen.dart:748-798) is a footer strip embedded inside the calendar card with neutral50 bg and a top hairline (lines 761-767) — not a separate white card with its own border/radius/margin. It lists only 6 entries (booked, pending, owner, maintenance, blocked, open — lines 753-760), omitting fixed, private, and the open(ghép)/empty distinction. Swatches are 12px with an always-solid default-width border (lines 777-786) — no dashed swatch for pending. Labels drift: 'Sân chủ' (line 773) vs 'Sân chủ / cá nhân', 'Đã khoá' vs 'Khoá / đóng cửa', 'Còn trống' vs 'Slot trống'.

### [Toolbar & filters] Extra header action buttons not in the spec
**Kind:** extra
**Handoff:** README "Page header" specifies exactly two right-aligned actions: "Khoá giờ" (secondary) and "Tạo slot mới" (primary). The prototype page-head (schedule-page.jsx:338-341) confirms only these two buttons.
**Current:** The header `_Header` renders five buttons: "Slot của tôi" (schedule_screen.dart:265-269), "Lịch cố định" — also a stub showing a coming-soon SnackBar (schedule_screen.dart:270-274), "Khoá nhiều giờ" (275-279), a green success-coloured "Đặt tại quầy" filled button (280-296), and "Tạo slot mới" (297-313). Three of these have no equivalent in the handoff header.
**Verifier note:** All facts check out; one addition: "Khoá nhiều giờ" (schedule_screen.dart:275-279) is ALSO a coming-soon stub calling the same _soon() SnackBar as "Lịch cố định" — so the spec's "Khoá giờ" counterpart is present but non-functional, in addition to the three extra buttons.

### [Views] No multi-view architecture: ScheduleView state, viewChanged event, and Day/Tuan/Thang switcher absent
**Kind:** missing
**Handoff:** README Overview + BLoC section: the screen offers three views switched by a segmented control ('view-switch' in schedule-views.jsx Toolbar, lines 84-88); state carries '@Default(ScheduleView.day) ScheduleView view' and a 'viewChanged(ScheduleView)' event; date navigation deltas are per-view (1 day / 1 week / 1 month). Architecture section specifies separate view files: schedule_page.dart, day_view.dart, week_view.dart, month_view.dart.
**Current:** There is no ScheduleView enum anywhere in the feature (grep for 'ScheduleView' only matches CalendarView.week at schedule_screen.dart:585). ScheduleState.loaded has no view field (schedule_state.dart:18-30); ScheduleEvent has only started/courtSelected/weekChanged/todayPressed plus slot-mutation events (schedule_event.dart:6-61) — no viewChanged. No segmented Ngay/Tuan/Thang control is rendered; navigation is week-only via SfCalendar backward/forward (schedule_screen.dart:475, 491) and 'Hom nay' (schedule_screen.dart:498). The whole screen is one monolithic schedule_screen.dart instead of day_view/week_view/month_view widgets.
**Verifier note:** Trivial citation nit only: grep for 'ScheduleView' actually returns ZERO matches in lib/ — the schedule_screen.dart:585 hit ('view: CalendarView.week') matches 'CalendarView', not 'ScheduleView'. Substance unchanged: no ScheduleView enum exists anywhere.


## LOW (25)

### [Architecture] ManualBookingRepository (Django HTTP walk-in booking) is an extra data-layer component not in the handoff architecture
**Kind:** extra
**Handoff:** README architecture defines a single abstract ScheduleRepository for this screen, whose only write paths are createSlot/createRecurringSlots/blockTime/approveSlot/rejectSlot/cancelSlot; the closest specced behaviour is the detail-sheet 'Đặt sân (book at counter)' footer action for empty slots, with no dedicated repository or HTTP service specified.
**Current:** The schedule feature carries a second repository, ManualBookingRepository / HttpManualBookingRepository, that bypasses Supabase and posts to a Django backend (`POST /api/bookings/manual`) over Dio with bearer-token auth (manual_booking_repository.dart:32-47, 52-144), plus a payload-builder/phone-normalization module (booking_logic.dart:75-104) and dedicated bloc events/state (ScheduleManualBookingCreated, ManualBookingResult — schedule_bloc.dart:164-222). This comes from tracker scope (OWNER-20), not the handoff; it needs reconciling with the spec's 'Đặt sân' action rather than standing as a parallel architecture.
**Verifier note:** Substantively correct; three trivial imprecisions: (1) HttpManualBookingRepository spans manual_booking_repository.dart:52-145, not 52-144. (2) ScheduleManualBookingCreated is declared in schedule_event.dart (~line 33) and ManualBookingResult in model/manual_booking_result.dart; schedule_bloc.dart:164-222 is the handler (_onManualBookingCreated) that consumes/emits them, not where they are declared. (3) Tracker provenance is OWNER-20 plus OWNER-23 (confirm/cancel flow), not OWNER-20 alone.

### [Architecture] No DataSource layer beneath repository impls (no remote/mock datasources)
**Kind:** missing
**Handoff:** README architecture tree: data/repositories/schedule_repository_impl.dart (concrete; talks to a data source) plus data/datasources/schedule_remote_datasource.dart and schedule_mock_datasource.dart; dependency direction '... RepositoryImpl → DataSource' so 'the data source can be swapped (mock ↔ REST ↔ GraphQL) without touching the service or BLoC'.
**Current:** Concrete repositories embed their transport directly: SupabaseOwnerSlotRepository holds a SupabaseClient and issues queries itself (owner_slot_repository.dart:76-107); HttpManualBookingRepository constructs its own Dio and reads the Supabase session internally (manual_booking_repository.dart:52-77). No datasource abstraction and no mock datasource exist anywhere (no datasources/ directory in lib/). The swap-ability intent is partially preserved at the repository-interface level, since OwnerSlotRepository and ManualBookingRepository are abstract and DI-registered against the interface (injection.dart:30-36).

### [Architecture] Venue and OwnerCourt repositories are concrete classes, not abstract interfaces, in DI
**Kind:** divergent
**Handoff:** README 'About the Design Files': use the app's established convention of 'abstract repositories (injected, swappable data sources)'; the venues read (getVenues) belongs on the abstract ScheduleRepository (README repository contract).
**Current:** VenueRepository is a concrete class bound directly to Supabase with no interface (venue_repository.dart:6-8) and registered as itself in DI (injection.dart:26-28); OwnerCourtRepository — which the schedule bloc consumes via the CourtsLoader callback — is likewise concrete (owner_court_repository.dart:5; injection.dart:22-24). The schedule feature's own repositories (OwnerSlotRepository, ManualBookingRepository, SlotPlayersRepository) do follow the abstract-interface + impl pattern, so this drift is limited to the venue/court data access the specced getVenues would replace.

### [BLoC contract] Extra events outside the handoff contract: manualBookingCreated, bookingResultCleared, courtSelected
**Kind:** extra
**Handoff:** README §BLoC lists exactly: started, viewChanged, dateMoved/todayPressed, venueSelected, sportFilterToggled, stateFilterToggled, slotTapped, emptyCellTapped, dragBlockRequested, monthDayTapped, createSlotSubmitted, blockSubmitted, approve, reject, cancel (lines 155–165). No manual walk-in-booking event or result-clearing event is specified (the detail sheet's "Đặt sân" action has no defined bloc event).
**Current:** Three events have no spec counterpart: `manualBookingCreated(startAt, endAt, customerName, customerPhone, notes, pricePerHourOverride)` (schedule_event.dart:36-43) with a full handler + error-code mapping (schedule_bloc.dart:164-222, 279-290), `bookingResultCleared()` (schedule_event.dart:48-49), and `courtSelected(courtId)` (schedule_event.dart:11-12, also covered under the venue-layer finding). These drive the ManualBookingResult/`busy` machinery that substitutes for the spec's toast.
**Verifier note:** Minor nuance only: the handoff does loosely sanction a clear-type event — README line 186 says the toast can be dismissed 'with a timer, or emit a clear event'. So bookingResultCleared has a weak spec antecedent as an optional implementation detail, though it is absent from the §BLoC event contract and clears the unspecced ManualBookingResult rather than the spec's toast string. The core finding stands.

### [BLoC contract] dateMoved(int delta) replaced by weekChanged(DateTime weekStart) — absolute-date, week-anchored payload
**Kind:** divergent
**Handoff:** README line 157: `dateMoved(int delta)` — relative navigation, "delta = ±1 day/week/month per view" — paired with a generic `focusedDate` state field (line 175).
**Current:** `ScheduleEvent.weekChanged(DateTime weekStart)` (schedule_event.dart:15-16) carries an absolute Monday-midnight date, normalized via `mondayOf` and deduped against the current week (schedule_bloc.dart:97-99); state stores `weekStart` rather than `focusedDate` (schedule_state.dart:21). `todayPressed` itself matches the spec (schedule_event.dart:19, schedule_bloc.dart:103-111).

### [Design tokens] Shadow tokens (sm/md/lg/xl) and 3px focus ring not implemented
**Kind:** missing
**Handoff:** README §Spacing / radius / elevation: shadow scale "sm 0 1px 2px rgba(17,24,39,.04), md 0 4px 12px rgba(17,24,39,.06), lg 0 12px 24px rgba(17,24,39,.08), xl 0 24px 48px rgba(17,24,39,.10)" and focus ring "0 0 0 3px rgba(22,163,74,.18)" (used by active view-switch button --shadow-sm, slot hover --shadow-md, drawers --shadow-xl).
**Current:** No shadow token constants exist anywhere in the dashboard; the theme is fully flat (cardTheme elevation: 0, app_theme.dart:86; elevated buttons elevation: 0, app_theme.dart:73). The only BoxShadow usages are ad-hoc one-offs outside schedule (auth_scaffold.dart:120, app_shell.dart:626). Focus state is a 1.5px solid primary border on inputs (app_theme.dart:48-51) rather than the spec's 3px translucent green ring; no focus-ring token is defined.

### [Design tokens] Short VND formatter (4.2tr / 70k) missing; full-VND formatting duplicated and not shared with schedule
**Kind:** partial
**Handoff:** README §Formatting helpers (replicate): "VND: thousands-grouped + đ (vi-VN), e.g. 525.000đ. Short: 4.2tr, 70k" — mirroring scfmt.vnd / scfmt.vndShort in reference/schedule-data.jsx:191-196 (vndShort: >=1M → '4.2tr', >=1k → '70k').
**Current:** The full format exists and is correct — formatVnd produces '525.000đ' (requests_logic.dart:169-178) — but no short-form helper exists anywhere in lib/ (no hits for 'tr'/'k' suffixing or /1000000 division). The formatter also lives in the requests feature, not a shared location: slot_detail imports it cross-feature (slot_players_dialog.dart:9), and the courts feature rolls its own parallel formatter NumberFormat('#,###', 'vi_VN') (court_detail_screen.dart:667). The schedule feature itself renders no prices at all, so neither helper is wired in there.

### [Domain models] ManualBookingResult is an extra, non-Freezed model outside the spec
**Kind:** extra
**Handoff:** README 'About the Design Files' (line 29) and the architecture section (line 48) state all domain models are @freezed; the specced model set is Venue, Slot, OccupancyDay plus the four enums. No manual-booking result model is specced (the counter-booking action 'Đặt sân' exists only as a detail-sheet footer action, README 'Footer actions').
**Current:** manual_booking_result.dart:11-41 defines a plain sealed class hierarchy (ManualBookingResult / ManualBookingSucceeded / ManualBookingFailed) with intentional identity equality and no Freezed (rationale documented at lines 8-10). It is a transient signal carried on ScheduleLoaded.bookingResult (schedule_state.dart:29) — additional domain surface not present in the handoff and an exception to the all-@freezed model convention.

### [Domain models] Model class named OwnerSlot instead of Slot
**Kind:** naming
**Handoff:** README architecture (line 48) names the domain model file `slot.dart` and the Freezed class `Slot` (line 91).
**Current:** The schedule slot model is `OwnerSlot` in owner_slot.dart:41. The rename is deliberately documented (doc comment at owner_slot.dart:35-39: distinct from spb_core's customer-facing Slot read model), so it is defensible drift, but it does not match the handoff's class name.

### [Domain models] PaymentStatus has extra `unknown` member and lives at player level, not on Slot
**Kind:** divergent
**Handoff:** README line 73: `enum PaymentStatus { paid, partial, unpaid }`, attached to the Slot as the nullable `payment` field (line 105) — slot-level, with absence expressed via null (DAY_SLOTS uses `paid: null`).
**Current:** The only PaymentStatus is `enum PaymentStatus { paid, unpaid, partial, unknown }` at slot_player.dart:17 in the slot_detail feature — an extra `unknown` member standing in for the spec's null, and it is applied per roster player (`slot_participants.payment_status`, slot_player.dart:53), not on the slot. OwnerSlot has no payment field at all (covered in the field-coverage finding); the enum itself diverges in shape and location.

### [Interactions] Date navigation only steps by week; bloc todayPressed/dateMoved wiring diverges from spec
**Kind:** partial
**Handoff:** README #2 + BLoC spec: ‹/› step by 1 day (Day) / 1 week (Week) / 1 month (Month) via a dateMoved(int delta) event, with todayPressed() resetting to today ('In the prototype these are stubs — implement for real').
**Current:** Week stepping and 'Hôm nay' do work, but only for the week view: arrows call the SfCalendar controller directly (`calendar.backward!()` / `calendar.forward!()`, schedule_screen.dart:475, 491) and 'Hôm nay' sets `calendar.displayDate = DateTime.now()` (schedule_screen.dart:498), with the bloc learning of the change only via onViewChanged → ScheduleEvent.weekChanged(monday) (schedule_screen.dart:622-630). There is no per-view dateMoved(delta) event — the bloc models navigation as weekChanged(DateTime weekStart) (schedule_event.dart:14-16) — and the bloc's ScheduleTodayPressed handler (schedule_bloc.dart:103-111) is dead code never dispatched from the UI. Day/month stepping is impossible because those views do not exist.

### [Interactions] Extra header interaction entry points not in the handoff (manual booking, standalone owner-slot dialog, stub buttons)
**Kind:** extra
**Handoff:** README 'Page header': exactly two right-aligned actions — 'Khoá giờ' (secondary, opens Block sheet) and 'Tạo slot mới' (primary, opens Create sheet). Counter booking exists only as the 'Đặt sân' footer action inside the empty-slot detail sheet, and owner personal use ('Sân của tôi') is a type inside the Block sheet (schedule-page.jsx:164-168).
**Current:** The header carries three additional interactive flows beyond the spec: 'Đặt tại quầy' opens a dedicated manual-booking dialog with customer name/phone/notes/price-override plus a bookingResult round-trip in the bloc state (schedule_screen.dart:134-158, 280-296; create_manual_booking_dialog.dart; schedule_event.dart:36-49; schedule_state.dart:25-29); 'Slot của tôi' opens a standalone owner-reservation dialog (schedule_screen.dart:113-122, 265-269; create_owner_slot_dialog.dart) instead of owner-use being a Block-sheet type; and 'Lịch cố định' / 'Khoá nhiều giờ' are placeholder buttons that just show a 'sẽ có trong epic Đặt Slot' snackbar (schedule_screen.dart:270-279, _soon at 223-231).
**Verifier note:** One detail overstated: the manual-booking dialog UI collects customer name/phone/notes only — there is no price-override input field. `pricePerHourOverride` exists solely as plumbing (schedule_event.dart:42, schedule_bloc.dart:192, booking_logic.dart:82-101, manual_booking_repository.dart:45-99); the dialog's submit at create_manual_booking_dialog.dart:680-688 passes only customerName/customerPhone/notes and leaves pricePerHourOverride null. Everything else in the claim is exact.

### [Sheets/drawers] Extra UI in create sheets not in the spec: 7-day date-chip picker and dirty-form cancel confirmation
**Kind:** extra
**Handoff:** README 'Create / Block sheet' defines the sheet fields as: type picker, venue select, start+duration, open-slot extras, and recurrence (with weekday buttons handling multi-day) — there is no per-sheet date picker; the date comes prefilled from the tapped cell/current view (README Interactions item 4). The cancel footer button is a plain secondary 'Huỷ' (schedule-page.jsx:269).
**Current:** Both create dialogs add a 7-day date-chip row spanning the visible week (create_open_slot_dialog.dart:156-172, create_owner_slot_dialog.dart:156-173), and the manual-booking dialog adds a dirty-check confirmation AlertDialog on cancel/close (create_manual_booking_dialog.dart:694-724) plus customer name/phone/notes fields — none of which appear in the handoff's sheet spec.
**Verifier note:** Two minor refinements: (1) create_owner_slot_dialog.dart date chips are at lines 157-173, not 156-173 (off by one). (2) The dirty-form confirmation is not an unexplained invention — create_manual_booking_dialog.dart:691-693 explicitly cites requirement 'OWNER-23: Huỷ discards the form, with a confirmation dialog if any field has been filled', so it is intentional per a tracked Plane work item, just absent from the README handoff. Also, the manual-booking customer name/phone/notes fields belong to the 'Đặt sân' (book-at-counter) flow, which the README mentions only as a detail-sheet footer button and never specs as a form — so those fields are an unspec'd screen rather than a direct contradiction of the Create/Block sheet field list.

### [Sheets/drawers] Sheets carry the 'court' misnomer (OwnerCourt/courtId) for the playing surface instead of Venue
**Kind:** naming
**Handoff:** README '⚠️ Terminology — READ FIRST': in the prototype 'court'/'courtId' means Venue (a playing surface inside a Court facility); 'Name your Flutter classes Venue, VenueSchedule, venueId… Do not carry the court misnomer into the Flutter code.'
**Current:** All schedule sheets type the playing surface as OwnerCourt and courtId: slot_actions_dialog.dart:24 (required OwnerCourt court), create_open_slot_dialog.dart:17, create_owner_slot_dialog.dart:17, create_manual_booking_dialog.dart:155-158 (state.courts/activeCourtId), and OwnerSlot.courtId (owner_slot.dart:46). A correctly named Venue model already exists at lib/features/courts/model/venue.dart:6 but is not used by any schedule sheet.
**Verifier note:** All citations are exact and the schedule feature does use OwnerCourt/courtId with the existing Venue model unused. One framing nuance: the Flutter naming is not a copied prototype misnomer — it mirrors the production Supabase schema, where slots.court_id references the courts (facility) table and no slots.venue_id exists (owner_slot_repository.dart:82,95). OwnerCourt genuinely models the courts facility table (address, amenities, operating_hours), and the implemented schedule operates at Court granularity via court tabs (schedule_screen.dart:175-177). So renaming OwnerCourt to Venue would be incorrect; the underlying mismatch is that venue-level scheduling (the handoff's per-venue resource columns/chips) is absent from both code and schema — a data-model/granularity gap surfaced as naming, not merely a naming slip.

### [Slot styling] Height-gated content visibility rules divergent
**Kind:** divergent
**Handoff:** README 'Slot block' Contents: time row only if block height > 40px; subtitle only if height > 56px (and present); prototype additionally gates the cap badge at height > 30 (schedule-views.jsx:67-69).
**Current:** The time row is always rendered regardless of block height (schedule_screen.dart:714-722). The only subtitle-equivalent is blockedReason, gated by slot DURATION >= 90 minutes (schedule_screen.dart:667) rather than pixel height > 56px, and it exists only for blocked slots — generic subtitles ('Cố định T3·T5', 'Đang ghép đội') have no rendering path.

### [Slot styling] Hover effects missing on slot blocks
**Kind:** missing
**Handoff:** README 'Slot block' Hover: 'translateY(−1px), --shadow-md, slight saturate, raise z-index' (.sc-slot:hover, schedule-styles.css:71); empty-state hover swaps to --primary border + --primary-50 bg + --primary-dark text (.st-empty:hover, schedule-styles.css:95).
**Current:** _buildAppointment returns a plain Container (schedule_screen.dart:676-737) with no MouseRegion, hover state, elevation change, or empty-state hover recolor; no hover treatment exists anywhere in schedule_screen.dart.

### [Slot styling] Slot box cosmetics drift (radius, border width, padding, font sizes)
**Kind:** divergent
**Handoff:** README 'Slot block' Box: radius 8px, 1.5px solid border, padding 6px vertical × 8px horizontal (.sc-slot, schedule-styles.css:60-64, base font 11.5px; week-view compact: 10.5px name / 9px time, schedule-styles.css:212-213).
**Current:** Block renders with BorderRadius.circular(6) (schedule_screen.dart:679), Border.all at default 1.0 width (line 680), and padding 7px horizontal × 5px vertical (line 682); name text is 11px (line 707) and time 10px (line 719) — neither the 11.5px base nor the 10.5/9px week-compact scale.
**Verifier note:** Two minor citation fixes: (1) name fontSize: 11 is at schedule_screen.dart line 706, not 707 (TextStyle spans 705-709). (2) The time text at 10px actually MATCHES the base spec — .s-time base is 10px (schedule-styles.css:74); the mismatch is only vs the week-compact 9px scale, which is the applicable one since the calendar is fixed to CalendarView.week (line 585). The claim's 'neither the 11.5px base nor the 10.5/9px week-compact' phrasing is fully correct only for the name text.

### [Slot styling] Slot-state naming drift: booked/blocked vs confirmed/locked, and 'open' semantic collision
**Kind:** naming
**Handoff:** README domain model defines `enum SlotState { confirmed, pending, fixed, open, private, empty, owner, maintenance, locked }` where 'open' = public matchmaking slot ('public' in the HTML) and 'empty' = created bookable slot with no customer yet.
**Current:** SlotStatus (owner_slot.dart:12-33) uses string constants 'booked' (spec: confirmed) and 'blocked' (spec: locked), and its 'open' means a bookable availability window — i.e. the spec's 'empty' — while the spec's 'open' (matchmaking, teal) has no representation. The _styleFor default branch labels code-'open' as 'Còn trống' (schedule_screen.dart:43-44), confirming the collision; this naming overlap risks mis-mapping when matchmaking slots are added.
**Verifier note:** Claim is accurate within the dashboard's scope; one repo-wide nuance: the spec's open-vs-private (matchmaking) distinction does partially exist in the customer read model as a separate `accessPolicy` field (`@Default('open')`, with maxPlayers/currentPlayers/hostId) in packages/spb_core/lib/models/slot.dart — but it is a different axis (access policy, not slot lifecycle status), and the owner dashboard's SlotStatus vocabulary and _styleFor styling have no matchmaking state or teal style at all.

### [Toolbar & filters] Drag-to-block hint "Kéo trên lưới để khoá giờ" missing from filter row
**Kind:** missing
**Handoff:** README "Filters" Row 1, far right: a muted hint "⤧ Kéo trên lưới để khoá giờ" (move icon + 12px --n-500/500-weight text; `.drag-tip` in schedule-styles.css:305-309, rendered in schedule-page.jsx:370).
**Current:** No such hint exists anywhere in schedule_screen.dart — there is no filter row to host it and no "Kéo" text or move-icon hint in the toolbar/chip area (schedule_screen.dart:348-519).

### [Toolbar & filters] Page header title and subtitle text diverge from spec
**Kind:** divergent
**Handoff:** README "Page header": title "Lịch sân" (Sora 800, 26px, −0.02em, --n-900); subtitle "Xem theo ngày, tuần hoặc tháng · tạo slot, mở ghép đội, khoá giờ." (13.5px, --n-500).
**Current:** Title is "Lịch sân tuần này" (schedule_screen.dart:243) and subtitle is "Quản lý slot, khoá giờ và đặt sân cho riêng bạn theo từng sân." (schedule_screen.dart:253). Typography (Sora 26/800 ≈ −0.5px tracking, 13.5px n-500 subtitle) matches the spec; only the copy differs.

### [Toolbar & filters] Toolbar stats text diverges from Week-view spec format and styling
**Kind:** divergent
**Handoff:** README "Toolbar" stats (12.5px --n-600, numbers in Sora --n-900, highlight in primary-dark): Week format is "<N> slot · <venue name> · tuần này" (prototype: schedule-page.jsx:320, .sc-stat styles schedule-styles.css:20-28).
**Current:** Stats render as plain "'$slotCount slot trong tuần'" in Plus Jakarta Sans 12.5 neutral600 (schedule_screen.dart:511-514) — the venue/court name segment is omitted, the count is not in Sora/n-900, and there is no primary-dark "tuần này" highlight.

### [Toolbar & filters] Venue chip row cosmetic drift: no "SÂN" label, uniform green dots, extra "Thêm sân" chip
**Kind:** partial
**Handoff:** README "Filters" Row 1 (Week view): a "SÂN" label (uppercase 11px/700 --n-400) precedes the venue chips; each chip carries an 8px coloured dot using the per-venue palette (#16A34A / #0EA5E9 / #F97316 / #A855F7 / #EC4899 — README "Venue dot palette"; prototype uses `c.color`, schedule-page.jsx:363).
**Current:** The chip row has no "SÂN" (or any) row label (schedule_screen.dart:355-441). The 8px dot is hardcoded to the same green for every chip — `active ? AppColors.primaryMid : AppColors.primary` (schedule_screen.dart:389) — losing the per-venue colour identity. An extra "Thêm sân" chip routing to /settings is appended (schedule_screen.dart:407-438), which is not in the spec. Active-chip styling itself (n-900 bg, white text, pill, 1px n-200 border) matches (schedule_screen.dart:372-377, 397).

### [Views] Grid hours hardcoded 6-22 globally instead of configurable per court
**Kind:** partial
**Handoff:** README section '1) Day view': 'Hours range: 6 -> 22 inclusive (operating hours). Make this configurable per court.'
**Current:** The grid uses global compile-time constants kOpenHour = 6 / kCloseHour = 22 (schedule_logic.dart:10-11) fed into TimeSlotViewSettings.startHour/endHour (schedule_screen.dart:599-600). The active court's own operating hours are ignored even though OwnerCourt already exposes openHour/closeHour getters backed by the courts.operating_hours column (owner_court.dart:76-77), so a court operating outside 6-22 would have slots clipped off the grid.

### [Views] Week grid metrics drift: 56px hour rows instead of 60px, no 64px gutter, non-mono time labels, oversized compact slot text
**Kind:** divergent
**Handoff:** README Design Tokens: 'Grid: 60px per hour, time gutter 64px, hours 6-22' (schedule-styles.css --hour-px: 60px); gutter labels JetBrains Mono 10.5px n-400; Week-view slot blocks render compact text — 10.5px name, 9px time (schedule-styles.css .week-col .sc-slot rules, lines 212-213).
**Current:** timeIntervalHeight is 56 (schedule_screen.dart:601) and the card height is computed as '17 hour rows @56px' (schedule_screen.dart:582); owner_slot.dart:74 even documents '1h == 56px in the design', contradicting the handoff's 60px. timeRulerSize is left at SfCalendar's auto default — no 64px gutter. Time labels use Plus Jakarta Sans 11px (schedule_screen.dart:603-606) instead of JetBrains Mono 10.5px. Slot blocks render the name at 11px (schedule_screen.dart:706) and time at 10px (schedule_screen.dart:719) instead of 10.5px/9px.

### [Views] Week view today-column treatment missing (header highlight + green column wash)
**Kind:** partial
**Handoff:** README section '2) Week view': 'Today column header gets --primary-light bg + --primary-dark text' and 'Today's column gets a faint green wash (rgba(34,197,94,.03))' (schedule-styles.css .week-dcell.today lines 202-203, .week-col.today line 211).
**Current:** The only today styling is todayHighlightColor: AppColors.primary on SfCalendar (schedule_screen.dart:592), which tints the date number; the viewHeaderStyle (schedule_screen.dart:608-619) applies one uniform style to all day cells with no primary-light background for today, and no green wash is applied to today's body column.
