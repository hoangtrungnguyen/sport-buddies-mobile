# Task 06 — Wire Recurring Booking Screen

**Priority:** Low (complex, do after single-booking flow is proven)
**Effort:** Large — full cubit state machine + backend RPC
**Depends on:** Task 05 (booking confirm pattern as reference), backend recurring-booking API endpoint

---

## What exists

**Screen:** `apps/customer/lib/features/recurring/recurring_booking_screen.dart`

`RecurringBookingScreen` is a pure UI stub — no constructor params, no cubit. Everything is hardcoded:
- Court chip: `'Pickle Hub Q1 · Sân B'`, `'180.000 đ/giờ · Pickleball'`
- Time slot grid: 4 static `_TimeSlotItem` objects (one pre-selected)
- Repeat chips: `'Hằng ngày'` / `'Hằng tuần'` / `'Chọn thứ'` — `'Chọn thứ'` appears active
- Day-of-week selector: T3 and T5 active (static `_DayItem` list)
- Start date row: `'Thứ ba, 14/05/2026'`
- End type chips: `'Sau N buổi'` active
- Session count: `'8'` (static `Text`)
- Summary text: `'8 buổi · kết thúc thứ năm, 11/06/2026'` (static)
- "Xem trước 8 buổi" CTA: `onPressed: () {}` (no-op)

**Route:**
```dart
GoRoute(
  path: '/booking/recurring',
  builder: (context, state) => const RecurringBookingScreen(),
),
```

---

## What to build

### 1. Add constructor params

The screen needs to know which court to book for. Either:
- Pass `courtId` via `state.extra` from wherever this screen is navigated to, OR
- Navigate with both `courtId` and optionally a pre-selected `slotTemplateId`

```dart
class RecurringBookingScreen extends StatelessWidget {
  const RecurringBookingScreen({
    super.key,
    required this.courtId,
  });
  final String courtId;
}
```

### 2. Create `RecurringBookingCubit`

**File:** `apps/customer/lib/features/recurring/cubit/recurring_booking_cubit.dart`

This cubit holds the full form state (what the user is configuring) and computes a preview of the generated sessions.

```dart
class RecurringBookingCubit extends Cubit<RecurringBookingState> {
  RecurringBookingCubit(this._client) : super(RecurringBookingState.initial());
  final SupabaseClient _client;

  // Load court + available time slots for the court
  Future<void> loadCourt(String courtId) async { ... }

  // Toggle a time slot selection
  void toggleTimeSlot(String slotTemplateId) { ... }

  // Set repeat mode: 'daily' | 'weekly' | 'custom'
  void setRepeatMode(String mode) { ... }

  // Toggle a day-of-week (0=Mon..6=Sun)
  void toggleDayOfWeek(int dow) { ... }

  // Set start date
  void setStartDate(DateTime date) { ... }

  // Set end condition: 'count' | 'date' | 'never'
  void setEndCondition(String condition) { ... }

  // Set session count (when endCondition == 'count')
  void setSessionCount(int count) { ... }

  // Set end date (when endCondition == 'date')
  void setEndDate(DateTime date) { ... }

  // Compute preview: derive list of (date, time) pairs from current config
  List<DateTime> computePreviewDates() { ... }

  // Submit: call backend RPC or insert bulk bookings
  Future<void> submit() async { ... }
}
```

### 3. Form state

```dart
class RecurringBookingState {
  final String? courtId;
  final String? courtName;
  final List<SlotTemplate> availableSlots;    // time slot options loaded from court
  final Set<String> selectedSlotIds;
  final String repeatMode;                    // 'daily' | 'weekly' | 'custom'
  final Set<int> daysOfWeek;                  // 0=Mon..6=Sun (only for 'custom')
  final DateTime startDate;
  final String endCondition;                  // 'count' | 'date' | 'never'
  final int sessionCount;
  final DateTime? endDate;
  final bool isSubmitting;
  final bool isSuccess;
  final String? error;

  factory RecurringBookingState.initial() => RecurringBookingState(
    repeatMode: 'custom',
    daysOfWeek: const {},
    startDate: DateTime.now(),
    endCondition: 'count',
    sessionCount: 8,
    ...
  );

  RecurringBookingState copyWith({...}) { ... }

  // Derived: compute end date from count + DOW pattern
  DateTime? get computedEndDate { ... }

  // Derived: total price
  int get totalPrice { ... }
}
```

`SlotTemplate` — a recurring time slot template for the court:
```dart
class SlotTemplate {
  final String id;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final int pricePerSession;
}
```

These likely come from a `slot_templates` or `court_schedules` table. If no such table exists, load open slots and present unique time pairs.

### 4. Backend submission

Two options depending on backend capability:

**Option A — Backend RPC (preferred):**
```dart
await _client.rpc('create_recurring_booking', params: {
  'court_id': courtId,
  'slot_template_ids': selectedSlotIds.toList(),
  'repeat_mode': repeatMode,
  'days_of_week': daysOfWeek.toList(),
  'start_date': startDate.toIso8601String(),
  'end_condition': endCondition,
  'session_count': sessionCount,
  'end_date': endDate?.toIso8601String(),
});
```

**Option B — Client-side bulk insert:**
Compute all session dates using `computePreviewDates()`, then insert one `bookings` row per session. Wrap in a Postgres transaction if possible (not directly supported by the REST API — use RPC instead).

**Recommendation:** implement the RPC on the Django backend first, then call it from the cubit.

### 5. Provide cubit in router

```dart
GoRoute(
  path: '/booking/recurring',
  builder: (context, state) {
    final extra = state.extra as Map<String, dynamic>? ?? {};
    final courtId = extra['courtId'] as String? ?? '';
    return BlocProvider(
      create: (_) => RecurringBookingCubit(Supabase.instance.client)
        ..loadCourt(courtId),
      child: RecurringBookingScreen(courtId: courtId),
    );
  },
),
```

### 6. Replace hardcoded UI

Replace all static data:
- `_CourtChip`: `state.courtName`, `state.priceLabel`, sport type
- `_TimeSlotGrid`: use `state.availableSlots`, toggle via `cubit.toggleTimeSlot(id)`
- `_RepeatChips`: reactive on `state.repeatMode`, call `cubit.setRepeatMode(mode)` on tap
- `_DowSelector`: reactive on `state.daysOfWeek`, call `cubit.toggleDayOfWeek(dow)` on tap
- Summary text: `state.sessionCount buổi · kết thúc ${state.computedEndDate}`
- CTA: `'Xem trước ${state.sessionCount} buổi'`

**Preview step:** when CTA tapped, show a bottom sheet or push a `/booking/recurring/preview` screen that lists all computed sessions (computed from `cubit.computePreviewDates()`). Add a "Xác nhận" button in the preview that calls `cubit.submit()`.

---

## Note on backend dependency

The recurring booking feature requires either:
1. A `create_recurring_booking` Postgres function (RPC) on the Django/Supabase backend, OR
2. A Django REST endpoint at `POST /api/bookings/recurring/`

Coordinate with the backend team before starting this task. The frontend cubit can be built and tested in isolation with a mock, but real end-to-end needs the backend endpoint.

---

## Tests to write

`apps/customer/test/features/recurring/recurring_booking_cubit_test.dart`

- Initial state has correct defaults
- `toggleDayOfWeek(2)` adds/removes from `daysOfWeek`
- `setSessionCount(5)` updates count
- `computePreviewDates()` with `repeatMode='custom'`, `daysOfWeek={1,3}`, `startDate=Monday`, `count=4` → returns correct 4 dates
- `submit` success → emits `isSuccess = true`
- `submit` failure → emits `error != null`
