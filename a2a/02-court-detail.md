# Task 02 — Wire Court Detail Screen

**Priority:** High (user taps a map marker → navigates to this screen)
**Effort:** Medium — need a new repository + cubit

---

## What exists

**Screen:** `apps/customer/lib/features/courts/court_detail_screen.dart`

`CourtDetailScreen` accepts `courtId: String` (passed from route `/court/:id`). Everything displayed is hardcoded:
- Court name: `'Pickle Hub Q1'`
- Sport badges: `'Pickleball'`, `'Tennis'` (static)
- Rating: `'4.8'`, `'126 đánh giá'` (static)
- Distance: `'1.2 km'` (static)
- Price: `'180.000 đ/giờ'` (static)
- Open slots today: `'4 slot'` (static)
- Amenities: hardcoded `Wrap` of chips
- Description: hardcoded `Text`

**Route:** registered in `app_router.dart`:
```dart
GoRoute(
  path: '/court/:id',
  builder: (context, state) =>
      CourtDetailScreen(courtId: state.pathParameters['id']!),
),
```
No cubit is provided here — needs to be added.

---

## What to build

### 1. Create `CourtDetail` model (in spb_core or local)

If keeping it local to `apps/customer` (simpler for now):

**File:** `apps/customer/lib/features/courts/court_detail.dart`

```dart
@immutable
class CourtDetail {
  const CourtDetail({
    required this.id,
    required this.name,
    required this.sportTypes,   // List<String>
    required this.address,
    required this.lat,
    required this.lng,
    required this.pricePerHour,
    required this.rating,
    required this.reviewCount,
    required this.openSlotCount,
    this.amenities = const [],
    this.description = '',
    this.photoUrls = const [],
  });

  final String id;
  final String name;
  final List<String> sportTypes;
  final String address;
  final double lat;
  final double lng;
  final int pricePerHour;        // VND per hour
  final double rating;
  final int reviewCount;
  final int openSlotCount;
  final List<String> amenities;  // e.g. ['roof', 'lighting', 'racket_rental']
  final String description;
  final List<String> photoUrls;

  factory CourtDetail.fromJson(Map<String, dynamic> json) { ... }
}
```

Supabase `courts` table columns expected:
`id, name, sport_type (text), address, lat, lng, price_per_hour (int), amenities (text[]), description, photos (text[])`

Open slot count comes from a separate query or can be embedded in a `left join` aggregation.

### 2. Create `CourtDetailCubit`

**File:** `apps/customer/lib/features/courts/cubit/court_detail_cubit.dart`

```dart
class CourtDetailCubit extends Cubit<CourtDetailState> {
  CourtDetailCubit(this._client) : super(const CourtDetailLoading());
  final SupabaseClient _client;

  Future<void> load(String courtId) async {
    emit(const CourtDetailLoading());
    try {
      final now = DateTime.now().toUtc().toIso8601String();
      final row = await _client
          .from('courts')
          .select('id, name, sport_type, address, lat, lng, price_per_hour, amenities, description, photos')
          .eq('id', courtId)
          .single();

      // Fetch today's open slot count separately
      final slotsResult = await _client
          .from('slots')
          .select('id')
          .eq('court_id', courtId)
          .eq('status', 'open')
          .gt('start_time', now)
          .count(CountOption.exact);

      final detail = CourtDetail.fromJson({
        ...row,
        'open_slot_count': slotsResult.count,
      });
      emit(CourtDetailLoaded(detail));
    } on PostgrestException catch (e) {
      emit(CourtDetailError(e.message));
    } catch (e) {
      emit(CourtDetailError(e.toString()));
    }
  }
}
```

States:
```dart
sealed class CourtDetailState { const CourtDetailState(); }
final class CourtDetailLoading extends CourtDetailState { const CourtDetailLoading(); }
final class CourtDetailLoaded  extends CourtDetailState {
  const CourtDetailLoaded(this.detail);
  final CourtDetail detail;
}
final class CourtDetailError   extends CourtDetailState {
  const CourtDetailError(this.message);
  final String message;
}
```

### 3. Wire cubit in router

In `app_router.dart`, update the `/court/:id` route:
```dart
GoRoute(
  path: '/court/:id',
  builder: (context, state) => BlocProvider(
    create: (_) => CourtDetailCubit(Supabase.instance.client)
      ..load(state.pathParameters['id']!),
    child: CourtDetailScreen(courtId: state.pathParameters['id']!),
  ),
),
```

### 4. Replace hardcoded values in `CourtDetailScreen`

In `_CourtInfo`, consume the cubit:
```dart
BlocBuilder<CourtDetailCubit, CourtDetailState>(
  builder: (context, state) => switch (state) {
    CourtDetailLoading() => const _CourtInfoSkeleton(),
    CourtDetailLoaded(:final detail) => _CourtInfoBody(detail: detail),
    CourtDetailError(:final message) => _CourtInfoError(message: message),
  },
)
```

Replace all hardcoded strings in `_CourtInfoBody` with `detail.*` fields:
- `detail.name` → court name
- `detail.sportTypes` → map to `_SportBadge` list
- `detail.rating.toStringAsFixed(1)` → rating
- `detail.reviewCount` → review count
- Distance: compute from `detail.lat`/`detail.lng` vs user GPS using Haversine (`LatLng.isWithinRadius` or manual distance — `LocationCubit` is available in the widget tree from the root `MultiBlocProvider`)
- `detail.pricePerHour` → formatted price (`NumberFormat('#,###', 'vi_VN')`)
- `detail.openSlotCount` → slot count
- `detail.amenities` → map to `_AmenityChip` (map amenity key → emoji/label)
- `detail.description` → description text
- `detail.photoUrls` → `_PhotoCarousel` (replace gradient placeholder with `Image.network`)

Bottom CTA price: replace `'180k'` with `'${detail.pricePerHour ~/ 1000}k'`.

---

## Tests to write

`apps/customer/test/features/courts/court_detail_cubit_test.dart`

- `load` with valid id → emits `Loading` then `Loaded(detail)`
- `load` on `PostgrestException` → emits `Loading` then `Error`
- `CourtDetail.fromJson` round-trip test
