# Task 04 — Wire Slot Detail Screen

**Priority:** Medium (reached via map panel "Ghép" flow)
**Effort:** Medium — new cubit, re-use `OpenSlotRepository` for slot, separate join-request query
**Depends on:** Task 01 (`OpenSlotListCubit` pattern as reference)

---

## What exists

**Screen:** `apps/customer/lib/features/slots/slot_detail_screen.dart`

`SlotDetailScreen` accepts `slotId: String` and optional `isFull: bool`. Everything is hardcoded:
- `_players` — static `const List<_PlayerData>` with 3 players (initials, color, name, sub, isHost)
- `_joined = 3`, `_max = 6` — static constants
- Court name, address: hardcoded `'Pickle Hub Q1 · Sân B'`
- Time card: hardcoded `'19:00 – 20:30'`, `'Thứ tư, 14/05'`
- Price per person: hardcoded `'50k'`
- Host message: hardcoded `'"Mình tìm 3 bạn chơi...'`

"Đăng ký chơi cùng · 50k" CTA calls `onPressed: () {}` (no-op).

**Route:**
```dart
GoRoute(
  path: '/slot/:id',
  builder: (context, state) =>
      SlotDetailScreen(slotId: state.pathParameters['id']!),
),
```

---

## What to build

### 1. Create `SlotDetailCubit`

**File:** `apps/customer/lib/features/slots/cubit/slot_detail_cubit.dart`

Loads:
1. The `OpenSlot` for `slotId` from the `slots` table
2. The list of players who have joined (from `bookings` or `join_requests` table — check schema)

```dart
class SlotDetailCubit extends Cubit<SlotDetailState> {
  SlotDetailCubit(this._client) : super(const SlotDetailLoading());
  final SupabaseClient _client;

  Future<void> load(String slotId) async {
    emit(const SlotDetailLoading());
    try {
      // Load slot + court info
      final row = await _client
          .from('slots')
          .select('''
            id, start_time, end_time, court_id, access_policy,
            max_players, current_players, host_message,
            courts!inner(name, address, sport_type)
          ''')
          .eq('id', slotId)
          .single();

      // Load joined players
      final playersRows = await _client
          .from('join_requests')
          .select('user_id, status, users(full_name, avatar_url)')
          .eq('slot_id', slotId)
          .eq('status', 'accepted');

      emit(SlotDetailLoaded(
        slot: SlotDetail.fromJson(row),
        players: playersRows.map(SlotPlayer.fromJson).toList(),
      ));
    } on PostgrestException catch (e) {
      emit(SlotDetailError(e.message));
    } catch (e) {
      emit(SlotDetailError(e.toString()));
    }
  }

  Future<void> joinSlot(String slotId) async {
    // POST to join_requests: {slot_id, user_id, status: 'pending'}
    // Emit success/error state
  }
}
```

States:
```dart
sealed class SlotDetailState { const SlotDetailState(); }
final class SlotDetailLoading extends SlotDetailState { const SlotDetailLoading(); }
final class SlotDetailLoaded  extends SlotDetailState {
  const SlotDetailLoaded({required this.slot, required this.players});
  final SlotDetail slot;
  final List<SlotPlayer> players;
}
final class SlotDetailError   extends SlotDetailState {
  const SlotDetailError(this.message);
  final String message;
}
final class SlotDetailJoining extends SlotDetailState { const SlotDetailJoining(); }
final class SlotDetailJoined  extends SlotDetailState { const SlotDetailJoined(); }
```

### 2. Create local data classes

**`SlotDetail`** (local to feature):
```dart
class SlotDetail {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final String courtId;
  final String courtName;
  final String courtAddress;
  final String sportType;
  final String accessPolicy;
  final int maxPlayers;
  final int currentPlayers;
  final String hostMessage;
  bool get isFull => currentPlayers >= maxPlayers;

  factory SlotDetail.fromJson(Map<String, dynamic> json) { ... }
}
```

**`SlotPlayer`**:
```dart
class SlotPlayer {
  final String userId;
  final String fullName;
  final String? avatarUrl;
  final bool isHost;

  factory SlotPlayer.fromJson(Map<String, dynamic> json) { ... }
}
```

Note: determine `isHost` by comparing `userId` with `slot.hostUserId` (add `host_user_id` to the slots query if available in the DB schema).

### 3. Provide cubit in router

```dart
GoRoute(
  path: '/slot/:id',
  builder: (context, state) {
    final slotId = state.pathParameters['id']!;
    return BlocProvider(
      create: (_) => SlotDetailCubit(Supabase.instance.client)..load(slotId),
      child: SlotDetailScreen(slotId: slotId),
    );
  },
),
```

### 4. Replace hardcoded data in screen

In `SlotDetailScreen.build`, consume the cubit:
```dart
BlocConsumer<SlotDetailCubit, SlotDetailState>(
  listener: (context, state) {
    if (state is SlotDetailJoined) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đăng ký thành công!')),
      );
    }
  },
  builder: (context, state) => switch (state) {
    SlotDetailLoading() || SlotDetailJoining() =>
        const Center(child: CircularProgressIndicator()),
    SlotDetailLoaded(:final slot, :final players) =>
        _SlotBody(slot: slot, players: players),
    SlotDetailError(:final message) =>
        Center(child: Text(message)),
    SlotDetailJoined() => _SlotBody(...), // keep showing data
  },
)
```

Replace in `_HeroSection`: `slot.courtName`, `slot.courtAddress`, `slot.sportType`, `slot.accessPolicy`.

Replace in `_TimeCard`:
- Time: `DateFormat('HH:mm').format(slot.startTime) + ' – ' + DateFormat('HH:mm').format(slot.endTime)`
- Date: `DateFormat('EEEE, dd/MM', 'vi_VN').format(slot.startTime)`
- Duration: `slot.endTime.difference(slot.startTime).inMinutes / 60` → `'X giờ'`
- Price per person: `slot.maxPlayers > 0 ? priceTotal ~/ slot.maxPlayers : 0` (price total not in model — leave static or add to DB query)

Replace in `_FullnessCard`: use `players` list from state instead of `_PlayerData`. Replace `_PlayerRow` to accept `SlotPlayer`.

Replace in `_HostMessageCard`: `slot.hostMessage` (show/hide card if empty).

Replace in `_StickyCtaBar`:
```dart
FilledButton(
  onPressed: () => context.read<SlotDetailCubit>().joinSlot(slot.id),
  child: const Text('Đăng ký chơi cùng'),
)
```

---

## Tests to write

`apps/customer/test/features/slots/slot_detail_cubit_test.dart`

- `load` success → emits `Loading` then `Loaded`
- `load` `PostgrestException` → emits `Loading` then `Error`
- `joinSlot` success → emits `Joining` then `Joined`
- `joinSlot` failure → emits `Joining` then `Error`
