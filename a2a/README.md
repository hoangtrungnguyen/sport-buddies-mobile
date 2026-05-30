# A2A Handoff — Customer App Integration Backlog

**Project:** sport-buddies-mobile / `apps/customer`
**Stack:** Flutter Web · `flutter_bloc ^8` · `supabase_flutter ^2` · `go_router ^14`
**Run commands via `fvm`** — e.g. `cd apps/customer && fvm flutter test`

---

## Status summary

| Screen | File | Status | Handoff doc |
|--------|------|--------|-------------|
| Map screen | `lib/features/map/map_screen.dart` | ✅ Fully wired | — |
| Upcoming bookings | `lib/features/bookings/upcoming_bookings_screen.dart` | ✅ Fully wired | — |
| Booking history | `lib/features/bookings/booking_history_screen.dart` | ✅ Fully wired | — |
| Booking detail | `lib/features/bookings/booking_detail_screen.dart` | ✅ Fully wired | — |
| Profile | `lib/features/profile/profile_screen.dart` | ✅ Fully wired | — |
| **Slot list panel** (inside map) | `lib/features/map/map_screen.dart` ~line 595 | ❌ Stub | [01-open-slot-panel.md](01-open-slot-panel.md) |
| **Court detail** | `lib/features/courts/court_detail_screen.dart` | ❌ Stub | [02-court-detail.md](02-court-detail.md) |
| **Slot picker** | `lib/features/courts/slot_picker_screen.dart` | ❌ Stub | [03-slot-picker.md](03-slot-picker.md) |
| **Slot detail** | `lib/features/slots/slot_detail_screen.dart` | ❌ Stub | [04-slot-detail.md](04-slot-detail.md) |
| **Booking confirm** | `lib/features/booking/booking_screen.dart` | ❌ Stub | [05-booking-confirm.md](05-booking-confirm.md) |
| **Recurring booking** | `lib/features/recurring/recurring_booking_screen.dart` | ❌ Stub | [06-recurring-booking.md](06-recurring-booking.md) |

**Bonus (small):** Map GPS auto-center — see note in [01-open-slot-panel.md](01-open-slot-panel.md#bonus-gps-center).

---

## Recommended implementation order

```
01 → 02 → 03 → 04 → 05 → 06
```

Tasks 01–04 share the same repository (`SupabaseOpenSlotRepository`) and cubit pattern, so do them in sequence. Task 05 depends on slots selected in 03. Task 06 is independent but most complex — defer until the single-booking flow (05) is proven.

---

## Shared conventions

### BLoC pattern
- Cubit lives in `lib/features/<feature>/cubit/<feature>_cubit.dart`
- States in `lib/features/<feature>/cubit/<feature>_state.dart` (sealed class with `part of`)
- Repository injected via constructor, not `Supabase.instance` directly
- Provide cubit in `app_router.dart` route builder using `BlocProvider`

### Repository convention
- Abstract interface in `packages/spb_core/lib/repositories/`
- Supabase implementation in `apps/customer/lib/features/<feature>/data/`
- Return `Result<T>` (`Success<T>` / `Failure`) from `packages/spb_core/lib/core/result.dart`

### Existing repositories already implemented
| Repository | Interface | Implementation |
|-----------|-----------|----------------|
| `OpenSlotRepository` | `packages/spb_core/lib/repositories/open_slot_repository.dart` | `apps/customer/lib/features/slots/data/supabase_open_slot_repository.dart` |
| `CourtAvailabilityRepository` | `packages/spb_core/lib/repositories/court_availability_repository.dart` | `apps/customer/lib/features/map/data/supabase_court_availability_repository.dart` |

### Testing
- Unit tests for cubits in `test/features/<feature>/`
- Use `bloc_test` package (`blocTest` helper)
- Mock repositories with `mocktail`
- Run: `cd apps/customer && fvm flutter test`
