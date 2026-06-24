# spb_core Migration Handoff — Customer & Dashboard

How to move shared model code into `packages/spb_core` and adopt it from
`apps/customer` and `apps/dashboard`. Read this before migrating any model.

---

## 1. Why & the guiding principle

`spb_core` is the shared, **pure-Dart** model package (no Flutter UI, no
Supabase). Both apps depend on it by path:

```yaml
# apps/<app>/pubspec.yaml
dependencies:
  spb_core:
    path: ../../packages/spb_core
```

**Principle:** reuse core *enums / value-objects* and project lean app classes
from a core entity — but **do not force-merge data classes whose wire shapes
genuinely diverge.** A model belongs in core only when both apps can use it
without losing data or rewriting many call sites. When merging would be lossy,
keep the class app-local and share only the parts that line up (usually the
status enums).

Decision flow for any duplicated model:

```
Same concept in both apps?
├─ No  → leave it; not a core candidate.
└─ Yes → Do the field sets + JSON shapes line up?
         ├─ Yes (clean subset/superset) → move entity to core; apps adopt or project via fromCore.
         ├─ Partly (status/enums match, data shape differs) → move ONLY the enums/value-objects to core; keep the data class local.
         └─ No (wire-incompatible) → keep app-local. Share nothing, or share enums only.
```

---

## 2. Conventions in core

- **Freezed** + `@JsonSerializable(fieldRename: FieldRename.snake)`.
- Status-like fields are **plain `String`s inside the data class** (not enums) so
  an unknown backend value never throws. Expose typed helpers separately:
  - a getter (`isConfirmed`, `isOpen`, …) on the model, and/or
  - a top-level `enum` + extension with `fromRaw(String?)` and `wireValue`.
- Helper getters need the private ctor: `const Booking._();`.
- Everything is re-exported from the barrel `lib/spb_core.dart`.

Run codegen from the package dir:

```bash
cd packages/spb_core && dart run build_runner build --delete-conflicting-outputs
```

(The `invalid_annotation_target` warning on the `@JsonSerializable` factory is
expected and harmless — same as the existing `Court`/`Slot` models.)

---

## 3. The three adoption patterns

### Pattern A — Full adoption (model lives only in core)

Use when the app's class is a clean match for the core model.
**Example shipped:** dashboard `AppNotification`.

1. Add the model to `packages/spb_core/lib/models/`, export from the barrel,
   run codegen.
2. Delete the app's local model file.
3. Repoint imports to `package:spb_core/spb_core.dart`.
4. Remove now-redundant imports the barrel already provides (e.g. `AppColors`).
5. `flutter analyze` the feature.

```dart
// before: import '../model/app_notification.dart';
// after:
import 'package:spb_core/spb_core.dart';
```

### Pattern B — `fromCore` projection (core is the hub, app keeps a lean view)

Use when the app needs a *subset* of core, possibly reshaped, and you want core
to be the real source of truth without changing the app's public API.
**Example shipped:** dashboard `BookingRequest`.

The Supabase row is parsed into a canonical `Booking` (all app-specific
resolution stays in the app), then the lean class is projected from it:

```dart
// apps/dashboard/lib/features/requests/model/booking_request.dart
factory BookingRequest.fromRow(Map<String, dynamic> row) =>
    BookingRequest.fromCore(_coreFromRow(row)); // public API unchanged

static Booking _coreFromRow(Map<String, dynamic> row) { /* resolution → core Booking */ }

factory BookingRequest.fromCore(Booking core) {
  final slot = core.slots.isNotEmpty ? core.slots.first : null;
  return BookingRequest(
    id: core.id,
    startAt: slot?.startTime ?? /* fallback */,
    status: bookingStatusFromRaw(core.status), // re-fold string → app enum
    revenue: core.totalPrice,
    // …only the fields this screen needs
  );
}
```

Callers (`repository.map(BookingRequest.fromRow)`, blocs, widgets) are untouched.
Avoid the trap: a `fromCore` that nothing produces is dead code — route the real
parse through it.

### Pattern C — Share enums only (data class stays app-local)

Use when the data shapes differ but the status/access vocabularies match.
**Example shipped:** customer wizard `Booking`.

The wizard keeps its plain class + `SlotSelection` slots (core `Slot` has no
per-slot price, so replacing would be lossy), but deletes its duplicate enums
and reuses core's. Because the barrel also exports `Booking`/`Slot`/`Court`
that **name-clash** with the app's own types, the import/export is `show`-limited:

```dart
// apps/customer/lib/features/booking/wizard/domain/booking.dart
import 'package:spb_core/spb_core.dart' show AccessPolicy, BookingStatus;
// re-export so the wizard's consumers keep seeing the enums transitively:
export 'package:spb_core/spb_core.dart'
    show AccessPolicy, AccessPolicyX, BookingStatus, BookingStatusX;
```

- The **`export`** is load-bearing: it preserves transitive visibility for the
  ~8 files that imported the enums through this file. Drop it and you must add an
  spb_core import to each of them.
- The **`import`** shows only the enum *types* this file references (its fields);
  the `X` extensions go in the `export` (used by consumers, not here) — otherwise
  you get `unused_shown_name` warnings.

---

## 4. Step-by-step recipe (any model)

1. **Classify** with the §1 decision flow → pick Pattern A / B / C.
2. **Author** the core model/enum, export from `lib/spb_core.dart`, run codegen.
3. **Check name clashes first:**
   ```bash
   # files importing the app file that will re-export, that ALSO pull a clashing name
   for f in $(grep -rln "<app file you edit>" lib); do
     grep -qE "package:spb_core|<other file defining same name>" "$f" && echo "CLASH: $f"
   done
   ```
   If any clash, use `show` / `hide` / `as` prefix.
4. **Apply** the pattern (delete/repoint, or add `fromCore`, or swap enums).
5. **Regenerate** the app's codegen (freezed defaults that referenced a moved
   enum must be rebuilt):
   ```bash
   cd apps/<app> && fvm dart run build_runner build --delete-conflicting-outputs
   ```
6. **Analyze** the touched features, then the whole app:
   ```bash
   fvm flutter analyze lib
   ```
   Ignore pre-existing `lib/core/env/env.g.dart` (envied) errors in the
   dashboard — they are unrelated noise.
7. **Do NOT add tests** unless the user explicitly asks (project rule in both
   `CLAUDE.md` files).

---

## 5. Status: done vs. remaining

| Model | Pattern | Customer | Dashboard | Notes |
|-------|---------|----------|-----------|-------|
| `AppNotification` | A | ⬜ todo | ✅ done | customer still local (`title`/`body`/`NotifType` enum/`NotifDay` bucket → map `title→text`, `body→meta`, `unread→!isRead`, enum→string) |
| `Booking` enums (`BookingStatus`,`AccessPolicy`) | C | ✅ wizard | ✅ via `fromCore` | — |
| `Booking` entity | B | ⬜ n/a | ✅ `BookingRequest.fromCore` | — |
| `Participant` / `JoinRequest` | A/C | ⬜ todo | ⬜ todo | core classes exist + exported but **not yet wired**. Customer `SlotParticipant`/`JoinRequest`, dashboard `SlotPlayer` are candidates. |
| customer bookings DTOs (`booking_model.dart`) | — | ❌ **keep local** | n/a | wire-incompatible: singular nested `slot`, `start_at` vs `start_time`, `sport_types` list vs flat `sportType`. Do not migrate. |

### Next recommended steps
1. **Customer `AppNotification`** (Pattern A, with an enum→string + `NotifDay`
   relocation into the view layer). Smallest remaining surface.
2. **`Participant`/`JoinRequest`** — wire the already-present core classes into
   both apps, or delete them from core if not adopted (don't leave them unused
   long-term).

---

## 6. Gotchas (bite list)

- **Barrel name clashes.** `spb_core` exports `Booking`/`Slot`/`Court`; both apps
  define their own. Any spb_core import in a file using those names needs
  `show`/`hide`/`as`. A bare `import 'package:spb_core/spb_core.dart'` there won't
  compile.
- **`export` vs `import`.** To preserve transitive visibility for consumers, the
  re-exporting file needs an `export` (not just `import`). Show only the *types*
  on the `import`, the extensions on the `export`.
- **Codegen after enum moves.** A freezed `@Default(SomeEnum.x)` bakes the symbol
  into `*.freezed.dart`; rebuild after the enum changes source.
- **`fromRow` → `fromRaw` behavior shift.** Core's `BookingStatusX.fromRaw` is
  more lenient than the wizard's old `fromRow` (folds `rejected`/`canceled`/
  `completed`, case-insensitive). In the wizard this is a *bug-fix* (a rejected
  booking now correctly becomes terminal-negative instead of hanging on Step 3) —
  call it out in the commit, don't claim pure equivalence.
- **`fvm`.** Both apps use `fvm`; prefix dart/flutter commands (`fvm dart …`).
- **No tests without sign-off** (both `CLAUDE.md`).

---

## 7. Verification checklist (per migration)

- [ ] `cd packages/spb_core && dart analyze lib` — only `invalid_annotation_target`.
- [ ] App codegen rebuilt (`fvm dart run build_runner build --delete-conflicting-outputs`).
- [ ] `fvm flutter analyze lib` on the app — 0 errors related to the model/spb_core
      (dashboard `env.g.dart` noise excepted).
- [ ] No unintended files staged (exclude untracked `docs/` artifacts).
- [ ] Commit message notes any behavior change (e.g. status-folding).
