# Task 03 — Wire Slot Picker Screen

**Priority:** High (booking flow entry point)
**Effort:** Medium — shares `OpenSlotListCubit` from task 01
**Depends on:** Task 01 (`OpenSlotListCubit` must exist)

---

## What exists

**Screen:** `apps/customer/lib/features/courts/slot_picker_screen.dart`

`SlotPickerScreen` accepts `courtId: String` (route `/court/:id/slots`). Everything is hardcoded:
- `_dates` — static list of 7 `_DateItem` objects with hardcoded dates
- `_slots` — static list of `_SlotItem` objects with hardcoded times and prices
- Multi-select state kept in `_SelectedState._selected` (local `StatefulWidget`)
- "Xác nhận N slot đã chọn" CTA button calls `context.push('/booking')` with no arguments

**Route:**
```dart
GoRoute(
  path: '/court/:id/slots',
  builder: (context, state) =>
      SlotPickerScreen(courtId: state.pathParameters['id']!),
),
```

---

## What to build

### 1. Reuse `OpenSlotListCubit` from task 01

Do **not** create a new cubit. Provide `OpenSlotListCubit` at the `/court/:id/slots` route and call `loadSlots(courtId)` on creation.

In `app_router.dart`:
```dart
GoRoute(
  path: '/court/:id/slots',
  builder: (context, state) {
    final courtId = state.pathParameters['id']!;
    return BlocProvider(
      create: (_) => OpenSlotListCubit(
        SupabaseOpenSlotRepository(client: Supabase.instance.client),
      )..loadSlots(courtId),
      child: SlotPickerScreen(courtId: courtId),
    );
  },
),
```

### 2. Group slots by date

The screen shows a horizontal date selector at the top, then a grid of slots for the selected date. `OpenSlot` has `startTime: DateTime` — group by `DateUtils.dateOnly(slot.startTime)`.

Add a helper in the screen or a utility:
```dart
Map<DateTime, List<OpenSlot>> groupByDate(List<OpenSlot> slots) {
  final map = <DateTime, List<OpenSlot>>{};
  for (final s in slots) {
    final day = DateUtils.dateOnly(s.startTime);
    (map[day] ??= []).add(s);
  }
  return map;
}
```

### 3. Replace `_DateItem` list with real dates

Convert `_dates` from a static const list to a derived list from grouped slots. The date selector shows only dates that have at least one open slot.

Replace `_DateItem` data class usage with `DateTime` keys from the grouped map.

### 4. Replace `_SlotItem` grid with real slots

Replace the hardcoded `_slots` list with `slotsForDate[selectedDate] ?? []`. Each `_SlotTile` needs:
- Time: `DateFormat('HH:mm').format(slot.startTime) + ' – ' + DateFormat('HH:mm').format(slot.endTime)`
- Price: `slot.maxPlayers > 1 ? '${slot.pricePerHour ~/ 1000}k' : '—'` (price-per-player is not in the model yet — show total court price or omit for now)
- `isFull`: disable the tile if `slot.isFull`
- Selection: use slot id in `_selected` set instead of index

### 5. Pass selected slot IDs to booking screen

When the user confirms, pass selected slot ids via `GoRouter` `extra` or query params:

```dart
// In confirm button handler:
final ids = _selected.toList();
context.push('/booking', extra: {'slotIds': ids, 'courtId': widget.courtId});
```

In `app_router.dart` update the `/booking` route to read `extra`:
```dart
GoRoute(
  path: '/booking',
  builder: (context, state) {
    final extra = state.extra as Map<String, dynamic>? ?? {};
    final slotIds = (extra['slotIds'] as List?)?.cast<String>() ?? [];
    final courtId = extra['courtId'] as String? ?? '';
    return BookingScreen(slotIds: slotIds, courtId: courtId);
  },
),
```

Add `slotIds` and `courtId` constructor params to `BookingScreen` (currently has none — it's `const BookingScreen()`).

### 6. Empty state

When `OpenSlotListLoaded` has 0 slots for all dates, show:
```
Không có slot trống cho sân này.
Thử lại sau hoặc chọn sân khác.
```

---

## Tests to write

`apps/customer/test/features/courts/slot_picker_screen_test.dart`

- Renders date tabs for dates returned by cubit
- Selecting a date shows that date's slots
- Tapping a slot adds it to selection (CTA counter increments)
- Tapping a full slot is a no-op
- CTA disabled when nothing selected
- Empty state shown when loaded with empty list
