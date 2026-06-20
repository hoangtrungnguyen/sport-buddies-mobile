@Tags(['api-health'])
library;

/// Daily liveness check against a real backend (dev by default).
///
/// This is NOT a unit test — every case makes a live HTTP call and asserts the
/// endpoint answers with its expected status. Run it each morning to learn, at
/// a glance, which API is broken:
///
/// ```sh
/// flutter test test/api_health --tags api-health \
///   --dart-define-from-file=.dev.env
/// ```
///
/// or via the helper: `scripts/api_health.sh dev`.
///
/// A plain `flutter test` (no `--dart-define-from-file`) leaves [Env.apiBaseUrl]
/// at its `http://localhost:8010` default, so the whole group SKIPS rather than
/// flaking the CI suite with network calls. It only runs when pointed at a real
/// host.
///
/// Credentials: defaults to the dev bypass owner (`Env.bypassEmail` /
/// `Env.bypassPassword`). Override per-run with
/// `--dart-define=API_HEALTH_EMAIL=... --dart-define=API_HEALTH_PASSWORD=...`.
import 'package:dashboard/core/env/env.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Login owner — overridable so a CI account can be used without touching env.
const _email = String.fromEnvironment('API_HEALTH_EMAIL');
const _password = String.fromEnvironment('API_HEALTH_PASSWORD');

void main() {
  // Only run when aimed at a real backend. The localhost default means the
  // suite was launched without `--dart-define-from-file=.<env>.env`.
  final baseUrl = Env.apiBaseUrl;
  final isLocalDefault =
      baseUrl.contains('localhost') || baseUrl.contains('127.0.0.1');
  final skip = isLocalDefault
      ? 'API health check skipped: API_BASE_URL is the localhost default. '
          'Run with --dart-define-from-file=.dev.env to probe the dev server.'
      : false;

  final email = _email.isNotEmpty ? _email : Env.bypassEmail;
  final password = _password.isNotEmpty ? _password : Env.bypassPassword;

  group('Dev API health [$baseUrl]', () {
    late Dio dio;

    // Populated by the login probe in setUpAll and reused as the Bearer token
    // for every authenticated probe below.
    String? accessToken;
    // A real court id harvested from the overview payload, for the venues probe.
    String? courtId;

    setUpAll(() async {
      dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 20),
          // Never throw on status — each probe asserts the code itself, so a
          // 4xx/5xx surfaces as a readable failure, not a DioException.
          validateStatus: (_) => true,
        ),
      );

      // Authenticate once. A failure here cascades (the authed probes report
      // "no token"), which is the correct signal: if login is down, the rest
      // is unusable anyway.
      try {
        final res = await dio.post<dynamic>(
          '/auth/owner/login',
          data: {'email': email, 'password': password},
        );
        if (res.statusCode == 200 && res.data is Map) {
          accessToken = _nz((res.data as Map)['access_token']?.toString() ?? '');
        }
      } on DioException {
        // Swallowed — the dedicated login test reports the transport failure.
      }
    });

    Options authed() => Options(
          headers: {
            if (accessToken != null) 'Authorization': 'Bearer $accessToken',
          },
        );

    // ---- Liveness -------------------------------------------------------

    test('GET /health — backend is up', () async {
      final res = await dio.get<dynamic>('/health');
      expect(res.statusCode, inInclusiveRange(200, 299),
          reason: 'Backend /health returned ${res.statusCode}.');
    }, skip: skip);

    test('GET supabase /auth/v1/health — GoTrue is up', () async {
      // Supabase lives on its own origin (Env.supabaseUrl), not API_BASE_URL.
      final res = await dio.get<dynamic>(
        '${Env.supabaseUrl}/auth/v1/health',
        options: Options(headers: {'apikey': Env.supabaseClientKey}),
      );
      expect(res.statusCode, inInclusiveRange(200, 299),
          reason: 'Supabase auth health returned ${res.statusCode}.');
    }, skip: skip);

    // ---- Auth -----------------------------------------------------------

    test('POST /auth/owner/login — returns a JWT', () async {
      final res = await dio.post<dynamic>(
        '/auth/owner/login',
        data: {'email': email, 'password': password},
      );
      expect(res.statusCode, 200,
          reason: 'Login as "$email" returned ${res.statusCode}. '
              'Check API_HEALTH_EMAIL/PASSWORD or the dev account.');
      expect(res.data, isA<Map>());
      expect(_nz((res.data as Map)['access_token']?.toString() ?? ''),
          isNotNull,
          reason: 'Login 200 but no access_token in body.');
    }, skip: skip);

    // ---- Authenticated reads -------------------------------------------

    test('GET /api/home/overview — dashboard payload', () async {
      expect(accessToken, isNotNull,
          reason: 'No token — login failed in setUpAll.');
      final res = await dio.get<dynamic>('/api/home/overview',
          options: authed());
      expect(res.statusCode, 200,
          reason: '/api/home/overview returned ${res.statusCode}.');

      // Opportunistically grab a court id for the venues probe.
      final data = res.data;
      if (data is Map) {
        final items = ((data['court_status'] as Map?)?['items']) as List?;
        if (items != null && items.isNotEmpty && items.first is Map) {
          courtId = _nz((items.first as Map)['id']?.toString() ?? '');
        }
      }
    }, skip: skip);

    test('GET /api/owner/feature-flags — owner overrides', () async {
      expect(accessToken, isNotNull,
          reason: 'No token — login failed in setUpAll.');
      final res = await dio.get<dynamic>('/api/owner/feature-flags',
          options: authed());
      expect(res.statusCode, 200,
          reason: '/api/owner/feature-flags returned ${res.statusCode}.');
    }, skip: skip);

    test('GET /api/plans/free/feature-flags — plan flags', () async {
      expect(accessToken, isNotNull,
          reason: 'No token — login failed in setUpAll.');
      final res = await dio.get<dynamic>('/api/plans/free/feature-flags',
          options: authed());
      expect(res.statusCode, 200,
          reason: '/api/plans/free/feature-flags returned ${res.statusCode}.');
    }, skip: skip);

    test('GET /api/courts/{id}/venues — venues for a court', () async {
      expect(accessToken, isNotNull,
          reason: 'No token — login failed in setUpAll.');
      if (courtId == null) {
        markTestSkipped('No court id in overview payload — nothing to probe.');
        return;
      }
      final res = await dio.get<dynamic>('/api/courts/$courtId/venues',
          options: authed());
      expect(res.statusCode, 200,
          reason: '/api/courts/$courtId/venues returned ${res.statusCode}.');
    }, skip: skip);

    // ---- Write route, probed WITHOUT side effects -----------------------

    test('POST /api/courts/{id}/venues — create route is alive', () async {
      // A health check must be idempotent, so we never create a real venue.
      // Instead POST an empty body: DRF validates the serializer BEFORE any DB
      // write, so a live route answers 400/422 (missing required fields) and
      // nothing is persisted. 404 = route gone, 401/403 = auth broke, 5xx =
      // server down — all real failures we want surfaced.
      expect(accessToken, isNotNull,
          reason: 'No token — login failed in setUpAll.');
      if (courtId == null) {
        markTestSkipped('No court id in overview payload — nothing to probe.');
        return;
      }
      final res = await dio.post<dynamic>(
        '/api/courts/$courtId/venues',
        data: const <String, dynamic>{},
        options: authed(),
      );
      expect(res.statusCode, anyOf(400, 422),
          reason: 'POST /api/courts/$courtId/venues with an empty body '
              'returned ${res.statusCode}; expected a 400/422 validation '
              'error (route alive, nothing written).');
    }, skip: skip);
  });
}

/// Treats an empty token/string as absent, so `?? ` / null-checks read true.
String? _nz(String s) => s.isEmpty ? null : s;
