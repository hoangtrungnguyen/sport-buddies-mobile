// Daily API health check — verifies the dev backend is up and every endpoint
// the customer app depends on is reachable. This is NOT a functional test: it
// proves the server is responding and each route is mounted (no transport
// failure, no 5xx), so a red test here means "this API is broken / the server
// is down", not "this feature has a bug".
//
// How to run (config is read from dart-defines, same as the app):
//
//   fvm flutter test --tags api --dart-define-from-file=.dev.env \
//       test/api_health/api_health_test.dart
//
// Tagged `api` and skipped automatically when API_BASE_URL is empty, so a plain
// `fvm flutter test` (no dart-defines) never runs or fails on it.
//
// Probes run UNAUTHENTICATED by default, which is the safest daily signal:
// requests are rejected at the auth gate (401) before touching any data, so
// nothing is created or mutated. A route that is up returns some HTTP status
// (typically 401/404/400); only a connection error or a 5xx counts as broken.
//
// Optional deeper check: set TEST_EMAIL and TEST_PASSWORD (a throwaway dev
// account) in .dev.env. The suite then signs in via Supabase and sends a real
// Bearer token, so read endpoints answer 200 instead of 401.

@Tags(['api'])
library;

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

const _apiBaseUrl = String.fromEnvironment('API_BASE_URL');
const _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const _supabaseKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
const _testEmail = String.fromEnvironment('TEST_EMAIL');
const _testPassword = String.fromEnvironment('TEST_PASSWORD');

const _timeout = Duration(seconds: 15);

/// A placeholder id for path params — real handlers answer 401/404 for it,
/// which still proves the route is mounted. Never a real resource.
const _fakeId = 'health-check-nonexistent';

void main() {
  final baseUrl = _apiBaseUrl.endsWith('/')
      ? _apiBaseUrl.substring(0, _apiBaseUrl.length - 1)
      : _apiBaseUrl;
  final apiSkip = _apiBaseUrl.isEmpty
      ? 'API_BASE_URL not set — run with --dart-define-from-file=.dev.env'
      : null;
  final supaSkip = _supabaseUrl.isEmpty
      ? 'SUPABASE_URL not set — run with --dart-define-from-file=.dev.env'
      : null;

  final client = http.Client();
  String? authToken;

  setUpAll(() async {
    if (_supabaseUrl.isEmpty) return;
    // Opt-in authenticated probing: trade test creds for a real JWT.
    if (_testEmail.isNotEmpty && _testPassword.isNotEmpty) {
      try {
        final res = await client
            .post(
              Uri.parse('$_supabaseUrl/auth/v1/token?grant_type=password'),
              headers: {'apikey': _supabaseKey, 'Content-Type': 'application/json'},
              body: jsonEncode({'email': _testEmail, 'password': _testPassword}),
            )
            .timeout(_timeout);
        if (res.statusCode == 200) {
          authToken = jsonDecode(res.body)['access_token'] as String?;
          // ignore: avoid_print
          print('✓ authenticated as $_testEmail — probing with Bearer token');
        } else {
          // ignore: avoid_print
          print('⚠ TEST_EMAIL sign-in failed (${res.statusCode}); '
              'probing unauthenticated');
        }
      } catch (e) {
        // ignore: avoid_print
        print('⚠ TEST_EMAIL sign-in errored ($e); probing unauthenticated');
      }
    }
  });

  tearDownAll(() => client.close());

  /// Sends one request and returns its status, or null + the transport error.
  Future<({int? status, String? error})> probe(
    String method,
    String path, {
    Object? body,
  }) async {
    final url = Uri.parse('$baseUrl$path');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (authToken != null) 'Authorization': 'Bearer $authToken',
    };
    try {
      final http.Response res;
      switch (method) {
        case 'GET':
          res = await client.get(url, headers: headers).timeout(_timeout);
        case 'POST':
          res = await client
              .post(url, headers: headers, body: body == null ? null : jsonEncode(body))
              .timeout(_timeout);
        case 'PATCH':
          res = await client
              .patch(url, headers: headers, body: body == null ? null : jsonEncode(body))
              .timeout(_timeout);
        default:
          throw ArgumentError('Unsupported method: $method');
      }
      return (status: res.statusCode, error: null);
    } catch (e) {
      return (status: null, error: e.toString());
    }
  }

  /// Passes if the server answered with any non-5xx HTTP status (route is up);
  /// fails loudly on a transport error (server down) or a 5xx (handler broken).
  void expectReachable(({int? status, String? error}) r, String label) {
    if (r.error != null) {
      fail('$label → UNREACHABLE (server down / DNS / timeout): ${r.error}');
    }
    // ignore: avoid_print
    print('$label → HTTP ${r.status}');
    expect(
      r.status,
      lessThan(500),
      reason: '$label → SERVER ERROR ${r.status} (endpoint is broken)',
    );
  }

  group('REST API health · $_apiBaseUrl', () {
    test('GET  /api/sports-centers/{id}/schedule', () async {
      expectReachable(
        await probe('GET', '/api/sports-centers/$_fakeId/schedule'),
        'sports-center schedule',
      );
    });

    test('GET  /api/slots/{id}/participants', () async {
      expectReachable(
        await probe('GET', '/api/slots/$_fakeId/participants'),
        'slot participants',
      );
    });

    test('GET  /api/slots/{id}/join-status', () async {
      expectReachable(
        await probe('GET', '/api/slots/$_fakeId/join-status'),
        'slot join-status',
      );
    });

    test('POST /api/slots/{id}/join', () async {
      expectReachable(
        await probe('POST', '/api/slots/$_fakeId/join'),
        'request to join slot',
      );
    });

    test('POST /api/slots/{id}/last-minute', () async {
      expectReachable(
        await probe('POST', '/api/slots/$_fakeId/last-minute'),
        'signal last-minute capacity',
      );
    });

    test('PATCH /api/slots/{id}/access', () async {
      expectReachable(
        await probe('PATCH', '/api/slots/$_fakeId/access', body: {'access_policy': 'open'}),
        'update slot access',
      );
    });

    test('PATCH /api/slot-join-requests/{id}/approve', () async {
      expectReachable(
        await probe('PATCH', '/api/slot-join-requests/$_fakeId/approve'),
        'approve join request',
      );
    });

    test('PATCH /api/slot-join-requests/{id}/reject', () async {
      expectReachable(
        await probe('PATCH', '/api/slot-join-requests/$_fakeId/reject'),
        'reject join request',
      );
    });

    test('POST /api/bookings', () async {
      // Invalid slot id + (usually) no auth → 400/401/404, never a real booking.
      expectReachable(
        await probe('POST', '/api/bookings', body: {'slot_id': _fakeId}),
        'create booking',
      );
    });

    test('POST /api/bookings/batch', () async {
      expectReachable(
        await probe('POST', '/api/bookings/batch', body: {'slot_ids': <String>[_fakeId]}),
        'create batch booking',
      );
    });
  }, skip: apiSkip);

  group('Supabase health · $_supabaseUrl', () {
    test('GET  /auth/v1/health', () async {
      try {
        final res = await client
            .get(
              Uri.parse('$_supabaseUrl/auth/v1/health'),
              headers: {'apikey': _supabaseKey},
            )
            .timeout(_timeout);
        // ignore: avoid_print
        print('Supabase auth health → HTTP ${res.statusCode}');
        expect(res.statusCode, 200, reason: 'Supabase auth service is unhealthy');
      } catch (e) {
        fail('Supabase auth → UNREACHABLE: $e');
      }
    });

    test('GET  /rest/v1/courts (table readable)', () async {
      try {
        final res = await client
            .get(
              Uri.parse('$_supabaseUrl/rest/v1/courts?select=id&limit=1'),
              headers: {
                'apikey': _supabaseKey,
                'Authorization': 'Bearer ${authToken ?? _supabaseKey}',
              },
            )
            .timeout(_timeout);
        // ignore: avoid_print
        print('Supabase courts select → HTTP ${res.statusCode}');
        expect(
          res.statusCode,
          200,
          reason: 'courts table not readable (RLS / schema / DB down) — '
              'status ${res.statusCode}: ${res.body}',
        );
      } catch (e) {
        fail('Supabase REST → UNREACHABLE: $e');
      }
    });
  }, skip: supaSkip);
}
