# API Reference Documentation

**Base URL:** `http://localhost:8010` (local) / `Env.apiBaseUrl` (production)

**Authentication:** Bearer token in `Authorization` header from Supabase session

---

## Booking APIs

### POST /api/bookings
Single slot booking.

**Request:**
```json
{
  "slot_id": "uuid",
  "customer_name": "string (optional)",
  "customer_phone": "string (optional)",
  "notes": "string (optional)"
}
```

**Response:** 201 Created
```json
{
  "id": "uuid"
}
```

**Errors:**
- 409: `SlotUnavailableException` — slot already booked
- 4xx/5xx: `BookingApiException`

---

### POST /api/bookings/batch
Multiple slots booked atomically.

**Request:**
```json
{
  "slot_ids": ["uuid", "uuid", ...],
  "customer_name": "string (optional)",
  "customer_phone": "string (optional)",
  "notes": "string (optional)"
}
```

**Response:** 201 Created
```json
[
  {
    "slot_id": "uuid",
    "status": "success|error",
    "booking": {
      "id": "uuid",
      "slot_id": "uuid | null",
      "court_id": "uuid | null",
      "user_id": "uuid | null",
      "status": "pending | confirmed | cancelled | completed",
      "customer_name": "string | null",
      "customer_phone": "string | null",
      "notes": "string | null",
      "booking_series_id": "uuid | null",
      "created_at": "ISO8601"
    },
    "error": null
  },
  ...
]
```

**Errors:**
- Per-slot results included in response array
- If any slot fails, returns array with mixed success/error
- 409/4xx/5xx: `SlotUnavailableException` or `BookingApiException` if request-level error

**Implementation:** Returns `Map<String, String>` (slot_id → booking_id). Throws `SlotUnavailableException` if any slot fails.

---

## Slot APIs

### GET /api/slots/{slotId}/participants
Fetch confirmed participants and pending join requests.

**Response:** 200 OK
```json
{
  "confirmed": [
    {
      "id": "uuid",
      "name": "string",
      "avatar_color": "#RRGGBB",
      "initials": "XX",
      "subtitle": "string (optional)",
      "is_host": boolean
    },
    ...
  ],
  "pending": [
    {
      "id": "uuid",
      "name": "string",
      "avatar_color": "#RRGGBB",
      "initials": "XX",
      "rating": number,
      "games_played": integer,
      "time_ago": "string",
      "note": "string (optional)"
    },
    ...
  ],
  "max_players": integer,
  "slot": {
    "court_name": "string",
    "sport_type": "string",
    "start_at": "ISO8601",
    "end_at": "ISO8601"
  }
}
```

**Usage:** `ParticipantManagementCubit.loadParticipants(slotId)`

---

### GET /api/slots/{slotId}/join-status
Fetch current player's join request status.

**Response:** 200 OK
```json
{
  "status": "none | pending | approved | rejected"
}
```

**Usage:** `SlotDetailCubit._fetchJoinStatus(slotId)` — returns `SlotJoinStatus` enum

---

### POST /api/slots/{slotId}/join
Player requests to join slot.

**Request:** (no body)

**Response:** 201 Created (no response body)

**Errors:**
- 409: `JoinConflictException` — slot private or duplicate request
- 4xx/5xx: `BookingApiException`

---

### POST /api/slots/{slotId}/last-minute
Slot owner signals last-minute capacity available.

**Request:** (no body)

**Response:** 200 OK (no response body)

**Usage:** `SlotDetailCubit.signalLastMinuteCapacity(slotId)`

**Errors:**
- 4xx/5xx: `BookingApiException`

---

### PATCH /api/slots/{slotId}/access
Update slot access policy and max players.

**Request:**
```json
{
  "access_policy": "open | private",
  "max_players": integer (optional)
}
```

**Response:** 200 OK (no response body)

**Errors:**
- 4xx/5xx: `BookingApiException`

---

### PATCH /api/slot-join-requests/{joinRequestId}/approve
Approve pending join request.

**Request:** (no body)

**Response:** 200 OK (no response body)

**Usage:** `ParticipantManagementCubit.approve(request)`

**Errors:**
- 4xx/5xx: `BookingApiException`

---

### PATCH /api/slot-join-requests/{joinRequestId}/reject
Reject pending join request.

**Request:** (no body)

**Response:** 200 OK (no response body)

**Usage:** `ParticipantManagementCubit.reject(request)`

**Errors:**
- 4xx/5xx: `BookingApiException`

---

## Schedule APIs

### GET /api/sports-centers/{scId}/schedule
Fetch 7-day schedule for a sports center.

**Response:** 200 OK
```json
{
  "dates": ["ISO8601", ...],
  "courts": [
    {
      "id": "uuid",
      "name": "string",
      "sport": "string"
    },
    ...
  ],
  "slots": {
    "YYYY-MM-DD": {
      "courtId|hour": {
        "status": "open | booked | closed",
        "price": integer,
        "endLabel": "HH:MM"
      },
      ...
    },
    ...
  }
}
```

**Usage:** `CourtScheduleOverviewCubit._loadFromApi(scId)` — parses and emits loaded state

**Errors:**
- 4xx/5xx: `BookingApiException` — falls back to mock data on error

---

## Exception Classes

### NoConnectionException
Device is offline or host unreachable. UI should surface "no internet" message.

---

### SlotUnavailableException
Slot already booked or not open. Returned on 409 response.

**Fields:**
- `detail`: String (optional) — user-facing message

---

### JoinConflictException
Slot is private or player already requested. Returned on 409 response for join endpoint.

**Fields:**
- `detail`: String (optional) — user-facing message

---

### BookingApiException
Non-2xx response (except 409) from API.

**Fields:**
- `statusCode`: int
- `code`: String — machine-readable error key
- `detail`: String (optional) — user-facing message

---

## Error Handling Pattern

```dart
try {
  final result = await _api.someEndpoint(...);
  // Handle success
} on NoConnectionException {
  // Show "no internet" error
} on SlotUnavailableException {
  // Show "slot taken" error
} on JoinConflictException {
  // Show "already requested or private" error
} on BookingApiException catch (e) {
  // Show server error with e.code and e.detail
}
```

---

## Implementation Files

**API Client:** `lib/core/services/booking_api_client.dart`

**Slot Management:** 
- Cubit: `apps/customer/lib/features/slots/cubit/participant_management_cubit.dart`
- State: `apps/customer/lib/features/slots/cubit/participant_management_state.dart`
- Screen: `apps/customer/lib/features/slots/participant_management_screen.dart`

**Slot Detail:**
- Cubit: `apps/customer/lib/features/slots/cubit/slot_detail_cubit.dart`
- State: `apps/customer/lib/features/slots/cubit/slot_detail_state.dart`

**Schedule:**
- Cubit: `apps/customer/lib/features/courts/schedule/cubit/court_schedule_overview_cubit.dart`
- State: `apps/customer/lib/features/courts/schedule/cubit/court_schedule_overview_state.dart`

**Booking:**
- Repository: `apps/customer/lib/features/booking/wizard/data/api_booking_repository.dart`

---

## Testing

**Test File:** `apps/customer/test/core/services/booking_api_client_batch_booking_test.dart`

**Coverage:**
- Multi-slot batch success
- Single-slot success
- Per-slot error handling
- Failed slot ID collection
- Null booking ID filtering
- Complex UUID handling
- Full booking object parsing

**Run Tests:**
```bash
cd apps/customer
fvm flutter test test/core/services/booking_api_client_batch_booking_test.dart
```

---

## Notes

- All datetimes are ISO8601 format
- Batch booking uses per-slot results array (not atomic all-or-nothing at API level)
- Slot creation via dashboard supports recurring slots with conflict skip behavior
- Bearer token from Supabase auth.currentSession?.accessToken
- Vietnamese error messages in user-facing responses
