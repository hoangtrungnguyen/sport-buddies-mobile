# Plan: Court & Venue Management — Dashboard UI

## Context

Currently `courts` mixes facility-level and venue-level data, and management lives
inside a dialog on the Settings screen. This plan separates the two concepts into
dedicated screens and a proper Court → Venue hierarchy.

---

## New domain model (UI side)

```
OwnerCourt          (facility)
  id, name, address, lat, lng
  operatingHours, amenities, description
  autoApproveSingle, isActive

Venue               (playable area inside a court)
  id, courtId, name
  sportType, capacity, pricePerHour
  isActive
```

---

## New routes

| Route | Screen | Purpose |
|---|---|---|
| `/courts` | `CourtsScreen` | List all owner's courts; entry point |
| `/courts/:id` | `CourtDetailScreen` | Court info + venue list |
| `/courts/new` | `CourtFormScreen` | Create new court |
| `/courts/:id/edit` | `CourtFormScreen` | Edit court info |
| `/courts/:id/venues/new` | `VenueFormScreen` | Add venue to court |
| `/courts/:id/venues/:venueId/edit` | `VenueFormScreen` | Edit venue |

`/settings` keeps the auto-approve section (it references courts) but removes the
old `_CourtSection` card — replaced by a **"Quản lý sân"** link button pointing to
`/courts`.

---

## Screens

### `CourtsScreen` (`/courts`)

- Sidebar nav entry: rename "Cài đặt sân" → split into **"Cài đặt"** (`/settings`)
  and **"Sân của tôi"** (`/courts`) — or keep settings and add courts as a sub-link.
- List card per court: name, address, venue count badge, active/inactive chip.
- FAB / top-right button: **"Thêm sân mới"** → `/courts/new`.
- Tap a court card → `/courts/:id`.

### `CourtDetailScreen` (`/courts/:id`)

Two-panel layout (matches Settings style):

**Left panel — Court info card:**
- Name, address, lat/lng, operating hours, amenities, description.
- "Chỉnh sửa" button → `/courts/:id/edit`.
- Active/inactive toggle (calls `PATCH courts/:id { status }`).

**Right panel — Venue list:**
- One row per venue: name, sport type, capacity, price/hr, status dot.
- "Sửa" button per row → `/courts/:id/venues/:venueId/edit`.
- "Thêm khu sân" button → `/courts/:id/venues/new`.
- Empty state: "Chưa có khu sân nào — thêm khu sân đầu tiên để nhận booking."

### `CourtFormScreen` (`/courts/new`, `/courts/:id/edit`)

Full-page form (not a dialog) — room for all fields:

| Field | Input type | Validation |
|---|---|---|
| Tên sân | TextFormField | required |
| Địa chỉ | TextFormField | optional |
| Vĩ độ / Kinh độ | Two numeric fields side-by-side | ±90 / ±180 |
| Mô tả | Multiline TextFormField | optional |
| Tiện ích | FilterChip multi-select (`kAmenities`) | optional |
| Giờ hoạt động | Open/close hour dropdowns | close > open |

No sport type / capacity / price here — those move to Venue.

Save → `POST /courts` or `PATCH /courts/:id` → redirect to `/courts/:id`.

### `VenueFormScreen` (`/courts/:id/venues/new`, `.../edit`)

Full-page form:

| Field | Input type | Validation |
|---|---|---|
| Tên khu sân | TextFormField | required (e.g. "Sân 1", "Khu cầu lông A") |
| Môn thể thao | Single-select chip (one per venue) | required |
| Sức chứa | Numeric | ≥ 1 |
| Giá / giờ | Numeric | ≥ 0 |
| Trạng thái | Active toggle (edit only) | — |

Save → `POST /courts/:id/venues` or `PATCH /venues/:venueId` → back to
`/courts/:id`.

---

## BLoC changes

| BLoC | Change |
|---|---|
| `CourtBloc` | Strip venue fields (`sportTypes`, `capacity`, `pricePerHour`) from `OwnerCourt`; keep court CRUD |
| `VenueBloc` (new) | `loadRequested(courtId)`, `created`, `updated`, `deactivated` |
| `SettingsBloc` / `CourtBloc` in settings | Auto-approve section now reads court list from `CourtBloc`; no venue data needed |

---

## Model changes

### `OwnerCourt` — remove venue fields

```dart
// Remove:
final List<String> sportTypes;
final int capacity;
final int pricePerHour;

// Keep:
final String id, name;
final String? address, description;
final List<String> amenities;
final int openHour, closeHour;
final double? lat, lng;
final bool isActive, autoApproveSingle;
```

### New `Venue` model

```dart
@freezed
abstract class Venue with _$Venue {
  const factory Venue({
    required String id,
    required String courtId,
    required String name,
    required String sportType,
    required int capacity,
    required int pricePerHour,
    required bool isActive,
  }) = _Venue;

  factory Venue.fromJson(Map<String, dynamic> json) { ... }
}
```

---

## Settings screen changes

- Remove `_CourtSection` card entirely.
- Add a **"Quản lý sân & khu sân"** row at the bottom of the settings TOC linking
  to `/courts`.
- Auto-approve section: court selector drives off `CourtBloc` state (no change to
  logic, just model fields shrink).

---

## Sidebar nav

Add **"Sân của tôi"** entry in the main nav (or system nav) pointing to `/courts`.
Badge: total venue count across all active courts (optional, not urgent).

---

## Phased delivery

| Phase | Scope |
|---|---|
| 1 | `CourtFormScreen` replaces dialog. Route `/courts/new` and `/courts/:id/edit`. No venue model yet (keep existing `OwnerCourt` with venue fields). |
| 2 | `VenueFormScreen` + `CourtDetailScreen` + new `Venue` model. Requires backend migration to be complete first. |
| 3 | Remove venue fields from `OwnerCourt`. Update auto-approve + requests features to join via venue. |

Phase 1 is independent of the backend migration and can ship immediately.
Phases 2–3 are blocked on backend.
