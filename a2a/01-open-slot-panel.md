# Task 01 — Wire Slot List Panel in Map Screen

**Priority:** High (unblocks tasks 03 and 04)
**Effort:** Small — repository already exists, just need a cubit + BlocBuilder

---

## What exists

`apps/customer/lib/features/map/map_screen.dart` contains a `_SlotListPanel` widget (around line 595) that shows slots for the currently selected court. It currently renders 3 hardcoded stub `_SlotRow` entries.

The repository is already fully implemented:
- Interface: `packages/spb_core/lib/repositories/open_slot_repository.dart`
- Implementation: `apps/customer/lib/features/slots/data/supabase_open_slot_repository.dart`

`OpenSlot` model fields (from `packages/spb_core/lib/models/open_slot.dart`):
```dart
final String id;
final DateTime startTime;
final DateTime endTime;
final String courtId;
final String courtName;
final String sportType;
final String accessPolicy;  // 'open' | 'closed'
final int maxPlayers;
final int currentPlayers;
bool get isFull => currentPlayers >= maxPlayers;
```

---

## What to build

### 1. Create `OpenSlotListCubit`

**File:** `apps/customer/lib/features/slots/cubit/open_slot_list_cubit.dart`

```dart
class OpenSlotListCubit extends Cubit<OpenSlotListState> {
  OpenSlotListCubit(this._repository) : super(const OpenSlotListInitial());
  final OpenSlotRepository _repository;

  Future<void> loadSlots(String courtId) async {
    emit(const OpenSlotListLoading());
    final result = await _repository.fetchOpenSlots(courtId);
    result.when(
      success: (slots) => emit(OpenSlotListLoaded(slots)),
      failure: (f) => emit(OpenSlotListError(f.toString())),
    );
  }

  void clear() => emit(const OpenSlotListInitial());
}
```

**File:** `apps/customer/lib/features/slots/cubit/open_slot_list_state.dart`

```dart
part of 'open_slot_list_cubit.dart'; // or separate sealed class

sealed class OpenSlotListState { const OpenSlotListState(); }
final class OpenSlotListInitial  extends OpenSlotListState { const OpenSlotListInitial(); }
final class OpenSlotListLoading  extends OpenSlotListState { const OpenSlotListLoading(); }
final class OpenSlotListLoaded   extends OpenSlotListState {
  const OpenSlotListLoaded(this.slots);
  final List<OpenSlot> slots;
}
final class OpenSlotListError    extends OpenSlotListState {
  const OpenSlotListError(this.message);
  final String message;
}
```

### 2. Provide `OpenSlotListCubit` at the `/` route

In `apps/customer/lib/core/router/app_router.dart`, add to the existing `MultiBlocProvider` providers list for the `/` route:

```dart
BlocProvider(
  create: (_) => OpenSlotListCubit(
    SupabaseOpenSlotRepository(client: Supabase.instance.client),
  ),
),
```

### 3. Wire `_SlotListPanel` in `map_screen.dart`

Currently the panel iterates a hardcoded list. Replace with a `BlocBuilder<OpenSlotListCubit, OpenSlotListState>`.

When `MapCubit` emits a `selectedCourt`, call:
```dart
context.read<OpenSlotListCubit>().loadSlots(selectedCourt.courtId);
```
When selection is cleared, call `context.read<OpenSlotListCubit>().clear()`.

The `BlocConsumer<MapCubit>` listener in `_buildMapArea` is the right place to trigger this.

Inside `_SlotListPanel`, replace hardcoded rows with:
```dart
BlocBuilder<OpenSlotListCubit, OpenSlotListState>(
  builder: (context, state) => switch (state) {
    OpenSlotListInitial() => const SizedBox.shrink(),
    OpenSlotListLoading() => const Center(child: CircularProgressIndicator()),
    OpenSlotListLoaded(:final slots) when slots.isEmpty =>
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text('Không có slot trống', style: TextStyle(color: Color(0xFF6B7280))),
        ),
    OpenSlotListLoaded(:final slots) =>
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: slots.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) => _SlotRow(slot: slots[i]),
        ),
    OpenSlotListError(:final message) =>
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(message, style: const TextStyle(color: Colors.red)),
        ),
  },
)
```

Update `_SlotRow` to accept an `OpenSlot` instead of hardcoded strings. Map fields:
- `slot.startTime` / `slot.endTime` → time display (use `DateFormat('HH:mm')` from `intl`)
- `slot.isFull` → show "Đã đủ người" badge or available count
- `slot.currentPlayers` / `slot.maxPlayers` → `${slot.currentPlayers}/${slot.maxPlayers}`
- On tap → `context.push('/slot/${slot.id}')`

---

## Bonus: GPS auto-center {#bonus-gps-center}

**File:** `apps/customer/lib/features/map/map_screen.dart`

Currently `FlutterMap.initialCenter` is always HCMC coordinates. After GPS loads, the map does not move.

Fix: add a `MapController` and listen to `LocationCubit` → on `LocationLoaded`, call `_mapController.move(position, zoom)`.

```dart
// In _MapScreenState:
late final MapController _mapController = MapController();

// In BlocListener for LocationCubit:
if (state is LocationLoaded && !_gpsCentered) {
  _gpsCentered = true;
  _mapController.move(
    LatLng(state.position.latitude, state.position.longitude),
    15.0,
  );
}

// Pass to FlutterMap:
FlutterMap(mapController: _mapController, ...)
```

---

## Tests to write

`apps/customer/test/features/slots/open_slot_list_cubit_test.dart`

- `loadSlots` on success → emits `Loading` then `Loaded(slots)`
- `loadSlots` on `Failure` → emits `Loading` then `Error`
- `clear` → emits `Initial`
