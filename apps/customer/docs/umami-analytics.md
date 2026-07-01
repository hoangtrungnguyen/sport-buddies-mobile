# Umami analytics — customer app

How to send product analytics from this app to our self-hosted **Umami**.

- **Umami URL:** `https://umami.ryudo.io.vn`
- **Collect endpoint:** `POST https://umami.ryudo.io.vn/api/send`
- **HTTP client:** `dio` (the app's existing stack)

> Native apps have no DOM, so the Umami browser `<script>` tracker can't run
> here. We talk to Umami's HTTP collect API (`/api/send`) directly — that's the
> same endpoint the web script calls under the hood.

---

## 1. Prerequisite — Website ID (one-time, in the Umami UI)

1. Open `https://umami.ryudo.io.vn` → log in.
2. **Settings → Websites → Add website.**
   - Name: `SportBuddies Customer (mobile)`
   - Domain: `app.sportbuddies` (any stable label — mobile has no real host;
     it only groups data and seeds the visitor hash).
3. Open it → **Edit** → copy the **Website ID** (UUID). That UUID is the only
   config the app needs.

Use a separate website per surface (customer mobile, owner dashboard, …) so
their stats don't mix.

---

## 2. The `/api/send` contract

```
POST https://umami.ryudo.io.vn/api/send
Content-Type: application/json
User-Agent: <non-empty>        ← REQUIRED. Umami returns 400 with no User-Agent.
```

Body:

```jsonc
{
  "type": "event",
  "payload": {
    "website":  "<WEBSITE_ID>",
    "hostname": "app.sportbuddies",
    "language": "vi-VN",
    "screen":   "1080x1920",
    "url":      "/courts/overview",     // treat screens as paths
    "referrer": "",
    "title":    "Courts Overview",      // optional
    "name":     "booking_created",      // OMIT for a plain screen view
    "data":     { "courtId": "c-123", "price": 120000 }  // optional custom props
  }
}
```

- **No `name`** → a **screen view** for `url`.
- **With `name`** → a **custom event** (still attributed to `url`).
- `data` values are primitives (string/number/bool). **No PII** (no email/phone/
  name) — use opaque ids.
- Response `200` with a short cache token you can ignore.

---

## 3. Drop-in Dart client — `lib/core/services/umami_analytics.dart`

Plain `dio`, no new deps (optionally `device_info_plus` + `package_info_plus`
for a better User-Agent — see gotchas).

```dart
import 'dart:ui' show PlatformDispatcher;
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

/// Fire-and-forget analytics to self-hosted Umami.
/// Never throws into callers — analytics must not break UX.
@singleton
class UmamiAnalytics {
  UmamiAnalytics()
      : _dio = Dio(BaseOptions(
          baseUrl: _host,
          connectTimeout: const Duration(seconds: 4),
          sendTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 4),
          // REQUIRED: Umami rejects requests with no User-Agent. Make it
          // identify the app so devices don't collapse into one visitor —
          // ideally build it from device_info_plus/package_info_plus.
          headers: {'User-Agent': 'SportBuddies/customer (Flutter)'},
        ));

  static const _host = String.fromEnvironment(
    'UMAMI_HOST',
    defaultValue: 'https://umami.ryudo.io.vn',
  );
  static const _websiteId = String.fromEnvironment(
    'UMAMI_WEBSITE_ID',
    defaultValue: '', // set via --dart-define; empty = analytics disabled
  );

  final Dio _dio;
  bool _optedOut = false;
  String? _currentPath;

  /// Honour user consent from a settings toggle.
  void setOptOut(bool value) => _optedOut = value;

  /// Let a route observer set the current path so events attribute correctly.
  set currentPath(String? p) => _currentPath = p;

  bool get _enabled => _websiteId.isNotEmpty && !_optedOut;

  /// A screen view. Call from a NavigatorObserver / screen initState.
  Future<void> screen(String path, {String? title}) =>
      _send(url: path, title: title);

  /// A custom event, e.g. track('booking_created', {'courtId': id}).
  Future<void> track(String name, [Map<String, Object?>? data]) =>
      _send(url: _currentPath ?? '/', name: name, data: data);

  Future<void> _send({
    required String url,
    String? name,
    String? title,
    Map<String, Object?>? data,
  }) async {
    if (!_enabled) return;
    final locale = PlatformDispatcher.instance.locale;
    try {
      await _dio.post('/api/send', data: {
        'type': 'event',
        'payload': {
          'website': _websiteId,
          'hostname': 'app.sportbuddies',
          'language': '${locale.languageCode}-${locale.countryCode ?? 'VN'}',
          'screen': '',
          'url': url,
          'referrer': '',
          if (title != null) 'title': title,
          if (name != null) 'name': name,
          if (data != null) 'data': data,
        },
      });
    } catch (_) {
      // Swallow — analytics is best-effort. Optionally appLogger.d(...) here.
    }
  }
}
```

### Wire into DI (injectable)

```bash
fvm dart run build_runner build --delete-conflicting-outputs
```

Then resolve anywhere via `sl<UmamiAnalytics>()`.

### Provide config at build time

```bash
flutter run \
  --dart-define=UMAMI_WEBSITE_ID=<the-uuid-from-step-1> \
  --dart-define=UMAMI_HOST=https://umami.ryudo.io.vn
```

Add the same `--dart-define`s to the app's build/deploy invocation.

---

## 4. Usage

**Screen views** — a `NavigatorObserver` so each navigation reports once:

```dart
class UmamiRouteObserver extends NavigatorObserver {
  UmamiRouteObserver(this._a);
  final UmamiAnalytics _a;

  void _report(Route<dynamic>? route) {
    final path = route?.settings.name;
    if (path == null) return;
    _a.currentPath = path;
    _a.screen(path);
  }

  @override
  void didPush(Route r, Route? p) => _report(r);
  @override
  void didReplace({Route? newRoute, Route? oldRoute}) => _report(newRoute);
}
```

**Custom events** — from cubits/usecases at the moment it happens:

```dart
final analytics = sl<UmamiAnalytics>();

analytics.track('booking_created', {
  'courtId': court.id,
  'slotCount': slots.length,
  'price': total,        // number, not "120.000đ"
});

analytics.track('checkout_started');
analytics.track('payment_succeeded', {'method': 'vnpay'});
```

Suggested first events: `booking_created`, `booking_cancelled`,
`search_performed`, `court_viewed`, `signup_completed`, `checkout_started`,
`payment_succeeded`.

---

## 5. Gotchas

| Gotcha | What to do |
|---|---|
| **User-Agent is mandatory** | No `User-Agent` → **400**. The client above always sets one. |
| **Visitor = hash(website + hostname + IP + User-Agent + daily salt)** | A static UA can collapse many users (carrier NAT) into one visitor, and the id **rotates daily by design** (privacy). Build a per-device UA (`SportBuddies/1.2.0 (Android 14; Pixel 7)`) via `device_info_plus`/`package_info_plus`. Umami has **no persistent user id** — for per-user retention cohorts you'd need a different tool. |
| **No PII** | Never put email/phone/name in `url`/`name`/`data`. Opaque ids only. |
| **Consent / opt-out** | Gate with `setOptOut(true)`. Empty `UMAMI_WEBSITE_ID` disables it (safe default for local/dev). |
| **Never blocking** | Sends are time-limited and try/catch-wrapped; don't `await` on the hot path — fire and move on. |
| **Client IP** | Umami is behind Caddy (forwards `X-Forwarded-For`), so attribution uses the real device IP. Nothing to do. |
| **Offline** | Events fired offline are dropped, not queued. Fine for product analytics. |

---

## 6. Verify

1. Run with `--dart-define=UMAMI_WEBSITE_ID=<uuid>`.
2. Navigate screens / trigger an event.
3. Umami UI → your website → **Realtime** — appears within seconds.
4. curl sanity check (expect `200`):

   ```bash
   curl -i https://umami.ryudo.io.vn/api/send \
     -H 'Content-Type: application/json' \
     -H 'User-Agent: SportBuddies/customer (Flutter)' \
     -d '{"type":"event","payload":{"website":"<uuid>","hostname":"app.sportbuddies","url":"/smoke-test","name":"handoff_smoke"}}'
   ```
