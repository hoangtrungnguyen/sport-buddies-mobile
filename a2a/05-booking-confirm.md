# Task 05 — Wire Booking Confirm Screen

**Priority:** Medium (completes the single-booking flow)
**Effort:** Large — new cubit + Supabase write + profile data integration
**Depends on:** Task 03 (passes `slotIds` + `courtId` via GoRouter `extra`)

---

## What exists

**Screen:** `apps/customer/lib/features/booking/booking_screen.dart`

`BookingScreen` is a pure UI stub — `const BookingScreen()` with no constructor params. Everything is hardcoded:
- Court card: `'Pickle Hub Q1 · Sân A'`, `'123 Nguyễn Du, Q.1'`
- Slot lines: 3 static `_SlotLine` widgets with hardcoded times, dates, and prices
- Total duration: `'4 giờ'`, total price: `'610.000 đ'`
- Contact name: `'Trần Minh'`, phone: `'0903 123 456'`
- "Xác nhận đặt sân" CTA: `onPressed: () {}` (no-op)

**Route:**
```dart
GoRoute(
  path: '/booking',
  builder: (context, state) => const BookingScreen(),
),
```

---

## What to build

### 1. Update `BookingScreen` constructor

```dart
class BookingScreen extends StatelessWidget {
  const BookingScreen({
    super.key,
    required this.slotIds,
    required this.courtId,
  });

  final List<String> slotIds;
  final String courtId;
}
```

Update route (see task 03) to pass `slotIds` and `courtId` via `state.extra`.

### 2. Create `BookingConfirmCubit`

**File:** `apps/customer/lib/features/booking/cubit/booking_confirm_cubit.dart`

Responsibilities:
1. Load slot details for the selected `slotIds` (need times, prices, court sub-name)
2. Pre-fill contact name/phone from `ProfileCubit` (or read `Supabase.instance.client.auth.currentSession?.user`)
3. On confirm: insert `bookings` row(s), then emit `BookingConfirmSuccess`

```dart
class BookingConfirmCubit extends Cubit<BookingConfirmState> {
  BookingConfirmCubit(this._client) : super(const BookingConfirmLoading());
  final SupabaseClient _client;

  Future<void> load(List<String> slotIds) async {
    emit(const BookingConfirmLoading());
    try {
      final rows = await _client
          .from('slots')
          .select('id, start_time, end_time, court_id, courts!inner(name, address, price_per_hour)')
          .inFilter('id', slotIds)
          .order('start_time');

      final user = _client.auth.currentSession?.user;
      final meta = user?.userMetadata ?? {};

      emit(BookingConfirmLoaded(
        slots: rows.map(BookingSlotSummary.fromJson).toList(),
        contactName: (meta['full_name'] as String?) ?? '',
        contactPhone: (meta['phone'] as String?) ?? '',
      ));
    } catch (e) {
      emit(BookingConfirmError(e.toString()));
    }
  }

  Future<void> confirm({
    required List<String> slotIds,
    required String contactName,
    required String contactPhone,
    String? note,
  }) async {
    emit(const BookingConfirmSubmitting());
    try {
      final userId = _client.auth.currentSession?.user.id ?? '';
      final now = DateTime.now().toUtc().toIso8601String();

      // Insert one booking per slot (or a single booking referencing multiple slots
      // depending on backend schema — adjust as needed)
      for (final slotId in slotIds) {
        await _client.from('bookings').insert({
          'slot_id': slotId,
          'user_id': userId,
          'contact_name': contactName,
          'contact_phone': contactPhone,
          'note': note ?? '',
          'status': 'confirmed',
          'created_at': now,
        });
      }
      emit(const BookingConfirmSuccess());
    } on PostgrestException catch (e) {
      emit(BookingConfirmError(e.message));
    } catch (e) {
      emit(BookingConfirmError(e.toString()));
    }
  }
}
```

States:
```dart
sealed class BookingConfirmState { const BookingConfirmState(); }
final class BookingConfirmLoading    extends BookingConfirmState { const BookingConfirmLoading(); }
final class BookingConfirmLoaded     extends BookingConfirmState {
  const BookingConfirmLoaded({
    required this.slots,
    required this.contactName,
    required this.contactPhone,
  });
  final List<BookingSlotSummary> slots;
  final String contactName;
  final String contactPhone;
}
final class BookingConfirmSubmitting extends BookingConfirmState { const BookingConfirmSubmitting(); }
final class BookingConfirmSuccess    extends BookingConfirmState { const BookingConfirmSuccess(); }
final class BookingConfirmError      extends BookingConfirmState {
  const BookingConfirmError(this.message);
  final String message;
}
```

### 3. Local data class `BookingSlotSummary`

```dart
class BookingSlotSummary {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final String courtSubName;   // e.g. "Sân A"
  final String courtAddress;
  final int pricePerHour;

  int get durationMinutes => endTime.difference(startTime).inMinutes;

  factory BookingSlotSummary.fromJson(Map<String, dynamic> json) { ... }
}
```

### 4. Provide cubit in router

```dart
GoRoute(
  path: '/booking',
  builder: (context, state) {
    final extra = state.extra as Map<String, dynamic>? ?? {};
    final slotIds = (extra['slotIds'] as List?)?.cast<String>() ?? [];
    final courtId = extra['courtId'] as String? ?? '';
    return BlocProvider(
      create: (_) => BookingConfirmCubit(Supabase.instance.client)
        ..load(slotIds),
      child: BookingScreen(slotIds: slotIds, courtId: courtId),
    );
  },
),
```

### 5. Wire the screen

Replace `_CourtCard` with real court name/address from first slot summary.

Replace `_SlotLine` list with:
```dart
...state.slots.map((s) => _SlotLine(
  time: '${DateFormat('HH:mm').format(s.startTime)} – ${DateFormat('HH:mm').format(s.endTime)}',
  date: DateFormat('EEEE, dd/MM', 'vi_VN').format(s.startTime),
  sub: '${s.courtSubName} · ${s.durationMinutes ~/ 60} giờ',
  price: NumberFormat('#,###', 'vi_VN').format(s.pricePerHour * s.durationMinutes ~/ 60) + ' đ',
))
```

Replace total price summary row with computed total from `state.slots`.

Replace `_ContactForm` static display with actual `TextFormField` controllers. Pre-fill from `state.contactName` and `state.contactPhone`.

Replace CTA `onPressed`:
```dart
onPressed: () {
  final cubit = context.read<BookingConfirmCubit>();
  cubit.confirm(
    slotIds: widget.slotIds,
    contactName: _nameController.text,
    contactPhone: _phoneController.text,
    note: _noteController.text,
  );
}
```

Add `BlocListener` for `BookingConfirmSuccess` → navigate to `/bookings/upcoming` and show a success snackbar.

---

## Tests to write

`apps/customer/test/features/booking/booking_confirm_cubit_test.dart`

- `load` populates slots + contact pre-fill from user metadata
- `confirm` success → emits `Submitting` then `Success`
- `confirm` `PostgrestException` → emits `Submitting` then `Error`
