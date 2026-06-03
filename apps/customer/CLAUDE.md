# Flutter Customer Application

App for booking sport slot and connect to buddies in Sai Gon (Ho Chi Minh city)


## Plane Integration

**Workspace:** sportbuddies · **Project:** CAPP (`7f970183-a7bf-4511-add1-f201313b37ea`)


## Conventions

### Freezed (state & event classes)

Use `freezed` + `freezed_annotation` for all BLoC state and event classes.

**Versions** (in `pubspec.yaml`):
```yaml
dependencies:
  freezed_annotation: ^3.1.0
dev_dependencies:
  freezed: ^3.2.3
```

**Pattern** — standalone files, NOT `part of` the bloc:

```dart
// auth_state.dart
import 'package:freezed_annotation/freezed_annotation.dart';
part 'auth_state.freezed.dart';

@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState.initial() = AuthInitial;
  const factory AuthState.loading() = AuthLoading;
  const factory AuthState.success() = AuthSuccess;

  /// Predictable server rejection — UI switches on [message] key.
  @With<AppExceptionMixin>()
  const factory AuthState.rejected(String message, {StackTrace? stackTrace}) = AuthRejected;

  /// Unexpected failure — non-recoverable, carries stack trace.
  const factory AuthState.failure(String message, {StackTrace? stackTrace}) = AuthFailureState;
}
```

**Rules:**
- `sealed class` with `with _$ClassName` — enables exhaustive `switch`
- `@With<Mixin>()` to apply a mixin to a specific generated class
- Freezed 3.x generates concrete classes directly (e.g. `AuthRejected`) — not the `_AuthRejected` private pattern from 2.x
- Part files (`_state.dart` / `_event.dart`) cannot have their own imports; add imports to the parent library if needed
- After any change: `fvm dart run build_runner build --delete-conflicting-outputs`

**Exception vs Failure distinction:**

| | Exception (`AuthRejected`) | Failure (`AuthFailureState`) |
|---|---|---|
| Nature | Predictable, anticipated | Unexpected, severe |
| Recoverability | Recoverable — UI shows reason | Non-recoverable — show generic dialog |
| Catch block | `on AuthException catch (e, st)` | `catch (e, st)` (bare) |
| Has stack trace | Yes — always forward from catch | Yes |

In BLoC handlers:
```dart
} on AuthException catch (e, stackTrace) {
  emit(AuthRejected('invalid_credentials', stackTrace: stackTrace));
} // No bare catch — unknown exceptions propagate to BlocObserver.onError
```
#### Command to generate freezed.g.dart file
```
fvm dart run build_runner build --delete-conflicting-outputs
```
---

### Logging

**Package:** `logger: ^2.7.0`

**Singleton** at `lib/core/debug/app_logger.dart`:
```dart
final appLogger = Logger(
  printer: PrettyPrinter(methodCount: 0, errorMethodCount: 8),
);
```

**Mixin** at `lib/core/mixins/app_exception_mixin.dart`:
```dart
mixin AppExceptionMixin {
  String get message;
  StackTrace? get stackTrace;

  void logError() {
    appLogger.e(message, error: message, stackTrace: stackTrace);
  }
}
```

Apply `@With<AppExceptionMixin>()` (freezed) or `with AppExceptionMixin` (manual) to all error states that carry a user-facing message.

**Observer** at `lib/core/debug/app_bloc_observer.dart` — wired in `main.dart`:

| Hook | Log level | Action |
|---|---|---|
| `onCreate` | `d` | Logs bloc creation |
| `onChange` | `d` | Logs state transition; calls `logError()` if next state is `AppExceptionMixin` |
| `onError` | `e` | Logs uncaught exception + stack trace; shows `AppExceptionDialog` |

**Dialog** at `lib/core/debug/app_exception_dialog.dart` — shown automatically by `AppBlocObserver.onError` for any uncaught exception escaping a bloc handler. Uses a `GlobalKey<NavigatorState>` registered in `sl` before DI init and shared with `GoRouter`.

**Setup in `main.dart`:**
```dart
final navigatorKey = GlobalKey<NavigatorState>();
GetIt.instance.registerSingleton<GlobalKey<NavigatorState>>(navigatorKey);
Bloc.observer = AppBlocObserver(navigatorKey: navigatorKey);
```


## Folder Structure
```text
lib/
├─ core/
│  ├─ debug/          # AppBlocObserver, AppExceptionDialog, app_logger.dart
│  ├─ env/            # env.dart, app_env.dart
│  ├─ geo/            # Services for location & maps
│  ├─ mixins/         # AppExceptionMixin
│  ├─ services/       # Repository interfaces & API clients
│  ├─ router/         # Router configuration
│  ├─ di/             # Dependency injection configuration
│  ├─ ui/             # Global UI components (dialogs, providers)
│  └─ utils/          # General utilities & extensions
├─ features/
│  ├─ auth/
│  │  ├─ data/          # Repositories & API
│  │  ├─ domain/        # State, events, DTOs, usecases
│  │  └─ presentation/ # UI & widgets
│  ├─ slot/
│  │  ├─ ...           # Follow same pattern
│  ├─ profile/
│  ├─ main/
│  └─ other-feature/
│
├─ app.dart           # Root widget
├─ main.dart          # DI setup + app bootstrap
└─ l10n/              # Generated L10N
```

### Screen indexed
- Home: home_screen.dart (id: 0)
- Courts Overview: court_overview_screen.dart (id: 1)
