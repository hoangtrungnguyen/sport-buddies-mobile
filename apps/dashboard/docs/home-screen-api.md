# Home Screen API Spec

Backend contract for the owner **Home / Dashboard** screen.

- Frontend feature: `lib/features/home/`
- Consumer interface: `HomeRepository` (`lib/features/home/repository/home_repository.dart`)
- Current state: `HomeRepositoryImpl` returns **100% hardcoded mock data** — no backend wired yet.
- All money is **VND integers** (no decimals). All times are venue-local.
- Scope: data is for the **currently authenticated owner** and all courts/venues they own. Auth via the existing session token; no owner id in the path.

---

## Design decisions (resolved)

The screen loads **five read blocks in parallel** on open (`Future.wait` in `HomeBloc._onStarted`).

**DECIDED — build one consolidated endpoint** (not five split ones):

```
GET /home/overview?date=2026-06-17
```

Returns all blocks in one payload (see **Consolidated response** below). The split §1–§5 sections below remain the per-block field contract — they document what each `overview` sub-object must contain; they are not separate routes.

### Raw vs formatted values — DECIDED: raw

Backend returns **raw `int` / `float` / ISO values**; the client formats (currency, Vietnamese weekday/date labels). This matches every existing endpoint (`/api/analytics/revenue`, bookings, courts already return raw) — no reason to break the pattern. The "display string the UI currently expects" notes below are just the client-side target, **not** the backend contract.

---

## 1. Today KPIs

Maps to `Future<List<HomeKpi>> getTodayKpis()`.

```
GET /home/kpis?date=2026-06-17
```

Four KPI cards: revenue, bookings, occupancy, pending requests.

**Raw response (recommended):**

```json
{
  "revenue": {
    "today": 4250000,
    "delta_pct": 12,
    "delta_up": true,
    "compared_to": "yesterday"
  },
  "bookings": {
    "count": 18,
    "pending": 6
  },
  "occupancy": {
    "pct": 76
  },
  "pending_requests": {
    "count": 8,
    "overdue": 2
  }
}
```

**Field semantics:**

| Field | Type | Meaning |
|---|---|---|
| `revenue.today` | int (VND) | Confirmed revenue for `date` |
| `revenue.delta_pct` | int | % change vs previous day; sign in `delta_up` |
| `revenue.delta_up` | bool | true = trending up (green ▲), false = down |
| `bookings.count` | int | Total bookings created for `date` |
| `bookings.pending` | int | Of those, how many still awaiting action |
| `occupancy.pct` | int 0–100 | Booked court-hours ÷ operating-hours for `date` (see below) |
| `pending_requests.count` | int | Requests awaiting approval (drives the "pending" card + §6 panel count) |
| `pending_requests.overdue` | int | Requests past the overdue SLA — **see §8 (blocked on a product decision)** |

**Occupancy denominator — DECIDED: operating hours.** Denominator = the configured daily availability from `courts.operating_hours` (per-day JSON `open`/`close`), summed across the owner's active courts. An occupancy RPC already exists but is **monthly** (`get_month_occupancy`, `courts/views.py:2300`) — Home needs a **daily, owner-wide** variant (reuse the same booked-hours ÷ operating-hours math).

> Current UI mapping: each card becomes a `HomeKpi {id,label,value,delta,deltaUp,progress,tone,icon}`. `progress` is the occupancy %; `tone=warn` when `pending_requests.overdue > 0`. The `label`/`icon`/`tone` are client-side presentation — backend need not send them.

---

## 2. Pending requests

Maps to `Future<List<PendingRequest>> getPendingRequests()`. Panel shows the first 4; "Xem tất cả" deep-links to `/requests`.

> **"Pending request" is two distinct backend flows — pick one or union both (decide before building):**
> 1. **Pending bookings** — `bookings` rows with `status=pending`; owner confirms via the booking-status PATCH (`bookings/views.py`).
> 2. **Slot join requests** — approved/rejected via `PATCH /api/slot-join-requests/{id}/approve|reject` (`courts/views.py:3232`).
>
> The `overview.pending_requests` block should surface whichever set(s) the product wants on Home. Whichever it is, the `id` returned here **must route to the matching §6 action** (booking vs join-request), so include a `kind` discriminator if both are unioned.

```
GET /home/pending-requests?date=2026-06-17&limit=4
```

```json
{
  "total": 8,
  "items": [
    {
      "id": "req_01",
      "customer_name": "Nguyễn Văn A",
      "court_name": "SnB Đại Lộc",
      "venue_name": "Sân 1",
      "sport": "Pickleball",
      "start_at": "2026-06-17T18:00:00+07:00",
      "end_at": "2026-06-17T19:30:00+07:00",
      "price": 180000,
      "regular": true
    }
  ]
}
```

| Field | Type | Meaning |
|---|---|---|
| `total` | int | Full count (panel renders "first N of total") |
| `id` | string | Request id — used by §6 approve/decline |
| `customer_name` | string | UI derives `initials` client-side |
| `court_name` / `venue_name` | string | Court cluster + sub-court |
| `sport` | string | Sport label |
| `start_at` / `end_at` | ISO 8601 w/ offset | UI formats to `"Hôm nay · 18:00–19:30"` |
| `price` | int (VND) | Booking total |
| `regular` | bool | Returning customer → "Khách quen" badge |

---

## 3. Upcoming sessions today

Maps to `Future<List<UpcomingSession>> getUpcomingToday()`. "Lịch sân" deep-links to `/schedule`.

```
GET /home/upcoming?date=2026-06-17&from=now
```

Confirmed + walk-in sessions for the rest of today, ordered by start time.

```json
{
  "items": [
    {
      "id": "ses_01",
      "start_at": "2026-06-17T18:00:00+07:00",
      "end_at": "2026-06-17T19:30:00+07:00",
      "name": "Nguyễn Văn A",
      "court_name": "Đại Lộc",
      "venue_name": "Sân 1",
      "status": "confirmed"
    }
  ]
}
```

| Field | Type | Meaning |
|---|---|---|
| `id` | string | Session id |
| `start_at` / `end_at` | ISO 8601 | UI shows `time` (start) + `end` |
| `name` | string | Customer name, or "Khách vãng lai" for walk-ins |
| `court_name` / `venue_name` | string | UI joins to `"Đại Lộc · Sân 1"` |
| `status` | enum | `confirmed` \| `walkin` |

---

## 4. Weekly revenue (7-day)

Maps to `Future<List<RevenueDay>> getWeeklyRevenue()`. "Thống kê" deep-links to `/analytics`.

```
GET /home/revenue?range=7d&end=2026-06-17
```

Exactly 7 buckets ending on `end` (last = today). Bar chart.

```json
{
  "days": [
    { "date": "2026-06-11", "value": 3900000 },
    { "date": "2026-06-12", "value": 3200000 },
    { "date": "2026-06-13", "value": 4600000 },
    { "date": "2026-06-14", "value": 5100000 },
    { "date": "2026-06-15", "value": 3800000 },
    { "date": "2026-06-16", "value": 4900000 },
    { "date": "2026-06-17", "value": 4250000 }
  ]
}
```

| Field | Type | Meaning |
|---|---|---|
| `date` | ISO date | UI derives the weekday label (T2…CN / "Hôm nay") |
| `value` | int (VND) | Confirmed revenue that day |

> UI computes weekly total + daily average from the array; last entry flagged `today=true` client-side. Always return 7 entries (zero-fill empty days).

---

## 5. Court status today

Maps to `Future<List<CourtStatusRow>> getCourtStatusToday()`. "Quản lý" deep-links to `/courts`.

```
GET /home/court-status?date=2026-06-17
```

```json
{
  "items": [
    {
      "id": "court_01",
      "name": "SnB Đại Lộc",
      "venues_count": 5,
      "occupancy_pct": 82,
      "status": "active"
    }
  ]
}
```

| Field | Type | Meaning |
|---|---|---|
| `id` | string | Court id |
| `name` | string | Court cluster name |
| `venues_count` | int | Sub-courts ("5 sân con") |
| `occupancy_pct` | int 0–100 | Today's occupancy for that court |
| `status` | enum | `active` \| `draft` |

---

## 6. Approve / decline a request

Maps to `Future<void> approveRequest(String id)` / `declineRequest(String id)`. UI updates optimistically, then calls these; on success the request leaves the list.

**DECIDED — reuse the existing endpoints; do NOT build new `/home/requests/*` routes.** Which one depends on what §2 surfaces (route by the item's `kind`):

| §2 source | Approve | Decline |
|---|---|---|
| Pending **booking** | booking-status PATCH → `confirmed` (`bookings/views.py`) | booking-status PATCH → `cancelled` |
| Slot **join request** | `PATCH /api/slot-join-requests/{id}/approve` | `PATCH /api/slot-join-requests/{id}/reject` (`courts/views.py:3232`) |

- The schedule feature already wraps the booking-status PATCH flow (`SupabaseScheduleRepository.approveSlot` / `rejectSlot`) — mirror it.
- Idempotency: a second approve/decline on an already-resolved item should return `409` (or `200` no-op); the UI does not re-sync, so a clear error it can surface is preferred.

---

## 7. Greeting header (currently hardcoded)

`lib/features/home/view/widgets/greeting_header.dart` hardcodes the owner name and counts:

```dart
const greeting = 'Chào buổi sáng, anh Minh';
const date = 'Thứ Sáu, 12/06/2026 · 5 cụm sân đang hoạt động · 12 sân con';
```

Needs:

| Field | Type | Meaning |
|---|---|---|
| `owner_name` | string | For "Chào buổi sáng, anh {name}" (greeting prefix is time-based, client-side) |
| `active_courts` | int | "5 cụm sân đang hoạt động" |
| `total_venues` | int | "12 sân con" |

Fold these into `GET /home/overview` (a `summary` block) or expose `GET /home/summary`. Owner name may already be available from the auth/profile endpoint — reuse if so.

---

## Consolidated response

`GET /home/overview?date=2026-06-17` — single payload combining all blocks:

```json
{
  "summary": { "owner_name": "Minh", "active_courts": 5, "total_venues": 12 },
  "kpis": { "...": "see §1" },
  "pending_requests": { "total": 8, "items": ["...see §2"] },
  "upcoming": { "items": ["...see §3"] },
  "weekly_revenue": { "days": ["...see §4"] },
  "court_status": { "items": ["...see §5"] }
}
```

Write actions (§6) reuse the existing booking-status / slot-join-request endpoints — see §6.

---

## 8. Resolved decisions & remaining blocker

| # | Question | Decision |
|---|---|---|
| 1 | Raw vs formatted | **Raw.** Backend sends `int`/`float`/ISO; client formats. Matches `/api/analytics/revenue`, bookings, courts. |
| 2 | Occupancy denominator | **Operating hours** from `courts.operating_hours`. Existing `get_month_occupancy` RPC is monthly — build a **daily, owner-wide** variant. |
| 3 | Overdue SLA | ⛔ **BLOCKED — product decision.** No existing concept. Needs a concrete threshold (e.g. "pending > 2h = overdue") before `pending_requests.overdue` (§1) can be built. |
| 4 | Timezone | **Single venue-local tz** is safe for now. `operating_hours` stored as naive `HH:MM`; slot times are ISO + offset. No per-court tz infra. |
| 5 | Requests domain | **Reuse, don't rebuild.** Two flows: pending bookings (booking-status PATCH) + slot-join-requests (`/api/slot-join-requests/{id}/approve\|reject`). See §2 + §6. |
| 6 | Consolidated vs split | **Build `/home/overview`** (one payload). |

**Only open item: #3 (overdue SLA).** Everything else is ready to build. Until #3 is set, ship `pending_requests.count` and omit/zero `overdue` (the `warn` tint just won't trigger).
