// Web UI e2e: the create-court flow, driven in a real Chrome browser via
// integration_test + patrol_finders (the `$` API).
//
// Self-contained — a fake [OwnerCourtRepository] stands in for the backend, so
// no login / Supabase / network is needed. This exercises the real
// CourtFormScreen widget tree, validation and router navigation as the browser
// renders them.
//
// Run (needs chromedriver on :4444 — see scripts/web_e2e.sh):
//   flutter drive \
//     --driver=test_driver/integration_test.dart \
//     --target=integration_test/create_court_test.dart \
//     -d chrome
import 'package:dashboard/features/courts/view/court_form_screen.dart';
import 'package:dashboard/features/setup/bloc/court_bloc.dart';
import 'package:dashboard/features/setup/model/owner_court.dart';
import 'package:dashboard/features/setup/repository/owner_court_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:patrol_finders/patrol_finders.dart';

/// Fake repo — only the two calls the create flow makes are real; the rest
/// routes through noSuchMethod (never invoked here).
class _FakeRepo implements OwnerCourtRepository {
  int createCalls = 0;

  @override
  Future<OwnerCourt> createCourt({
    required String name,
    required int openHour,
    required int closeHour,
    String? address,
    String? description,
    List<String> amenities = const [],
    double? lat,
    double? lng,
    Map<String, dynamic> additionalInfo = const {},
  }) async {
    createCalls++;
    return OwnerCourt(id: 'c1', name: name, isActive: true);
  }

  @override
  Future<List<OwnerCourt>> getCourts() async =>
      const [OwnerCourt(id: 'c1', name: 'Sân Test', isActive: true)];

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

Future<void> _pumpForm(PatrolTester $, _FakeRepo repo) async {
  final router = GoRouter(
    initialLocation: '/courts/new',
    routes: [
      GoRoute(
        path: '/courts',
        builder: (_, __) =>
            const Scaffold(body: Center(child: Text('COURTS LIST'))),
      ),
      GoRoute(
        path: '/courts/new',
        builder: (_, __) => const CourtFormScreen(),
      ),
    ],
  );

  await $.pumpWidget(
    RepositoryProvider<OwnerCourtRepository>.value(
      value: repo,
      child: BlocProvider<CourtBloc>(
        create: (_) => CourtBloc(repo),
        child: MaterialApp.router(routerConfig: router),
      ),
    ),
  );
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  patrolWidgetTest('create court: fill the form and submit lands on the list',
      ($) async {
    final repo = _FakeRepo();
    await _pumpForm($, repo);

    // Starts on the create form, not the list.
    expect($('Thêm sân mới'), findsOneWidget);
    expect($('COURTS LIST'), findsNothing);
    await binding.takeScreenshot('court-01-empty-form');

    // Field order: name(0), phone(1), address(2), lat(3), lng(4), maps(5).
    await $(TextFormField).at(0).enterText('Sân Pickleball Test');
    await $(TextFormField).at(2).enterText('123 Đường Test, Q1');
    await $.tester.pumpAndSettle();
    await binding.takeScreenshot('court-02-filled-form');

    await $('Tạo sân').tap();

    // Created exactly once and navigated to the list screen.
    expect(repo.createCalls, 1);
    expect($('COURTS LIST'), findsOneWidget);
    expect($('Thêm sân mới'), findsNothing);
    await binding.takeScreenshot('court-03-after-submit');
  });

  patrolWidgetTest('create court: missing required fields blocks submit',
      ($) async {
    final repo = _FakeRepo();
    await _pumpForm($, repo);

    // Submit with an empty form — validation should keep us on the form.
    await $('Tạo sân').tap();

    expect(repo.createCalls, 0);
    expect($('COURTS LIST'), findsNothing);
    expect($('Thêm sân mới'), findsOneWidget);
  });
}
