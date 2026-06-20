@Tags(['e2e'])
library;

/// End-to-end: create a court against a real backend (dev by default).
///
/// Drives the ACTUAL [OwnerCourtRepository] against a live, authenticated
/// Supabase session — no fakes — so it exercises the real insert, RLS scoping
/// and row mapping. The court it creates is cleaned up in tearDown, so the test
/// is repeatable and leaves no junk on the server.
///
/// ```sh
/// flutter test test/e2e --tags e2e --dart-define-from-file=.dev.env
/// ```
///
/// or via the helper: `scripts/e2e.sh dev`.
///
/// A plain `flutter test` leaves [Env.apiBaseUrl] at its localhost default, so
/// the group SKIPS rather than hitting the network. It only runs when pointed
/// at a real host. Credentials default to the dev bypass owner; override with
/// `--dart-define=API_HEALTH_EMAIL=... --dart-define=API_HEALTH_PASSWORD=...`.
import 'package:dashboard/core/env/env.dart';
import 'package:dashboard/features/setup/repository/owner_court_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _email = String.fromEnvironment('API_HEALTH_EMAIL');
const _password = String.fromEnvironment('API_HEALTH_PASSWORD');

void main() {
  final baseUrl = Env.apiBaseUrl;
  final isLocalDefault =
      baseUrl.contains('localhost') || baseUrl.contains('127.0.0.1');
  final Object skip = (isLocalDefault || Env.supabaseUrl.isEmpty)
      ? 'E2E skipped: run with --dart-define-from-file=.dev.env to hit a real '
          'backend with Supabase credentials.'
      : false;

  final email = _email.isNotEmpty ? _email : Env.bypassEmail;
  final password = _password.isNotEmpty ? _password : Env.bypassPassword;

  group('E2E create court [${Env.supabaseUrl}]', () {
    late SupabaseClient client;
    late OwnerCourtRepository repo;
    // The court created in the first test; verified by the second, removed in
    // tearDownAll.
    String? createdId;

    setUpAll(() async {
      if (skip != false) return; // localhost default — tests are skipped anyway.
      // Raw client (no Supabase.initialize → no Flutter plugins needed).
      client = SupabaseClient(Env.supabaseUrl, Env.supabaseClientKey);
      await client.auth.signInWithPassword(email: email, password: password);
      repo = OwnerCourtRepository(client);
    });

    tearDownAll(() async {
      if (skip != false) return;
      // Best-effort cleanup so re-runs don't pile up test courts.
      if (createdId != null) {
        // Hard-delete when an RLS DELETE policy permits it...
        try {
          await client.from('courts').delete().eq('id', createdId!);
        } catch (_) {}
        // ...and soft-hide regardless, so it drops out of the owner's list
        // even if the row survived (no DELETE policy).
        try {
          await repo.deactivateCourt(createdId!);
        } catch (_) {}
      }
      await client.dispose();
    });

    test('createCourt inserts a row and returns the mapped court', () async {
      final name = 'E2E Court ${DateTime.now().millisecondsSinceEpoch}';
      final court = await repo.createCourt(
        name: name,
        openHour: 6,
        closeHour: 22,
      );
      createdId = court.id;

      expect(court.id, isNotEmpty, reason: 'createCourt returned no id.');
      expect(court.name, name);
      expect(court.isActive, isTrue,
          reason: 'A freshly created court should be active.');
    }, skip: skip);

    test('the created court is returned by getCourts', () async {
      expect(createdId, isNotNull,
          reason: 'Create step did not run or failed — nothing to look up.');
      final courts = await repo.getCourts();
      expect(courts.any((c) => c.id == createdId), isTrue,
          reason: 'Created court $createdId not found in getCourts().');
    }, skip: skip);
  });
}
