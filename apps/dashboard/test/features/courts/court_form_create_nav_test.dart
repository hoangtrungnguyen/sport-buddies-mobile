import 'package:dashboard/features/courts/view/court_form_screen.dart';
import 'package:dashboard/features/setup/bloc/court_bloc.dart';
import 'package:dashboard/features/setup/model/owner_court.dart';
import 'package:dashboard/features/setup/repository/owner_court_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// Fake repo — only the two calls the create flow makes are real; everything
/// else routes through noSuchMethod (never invoked here).
class _FakeRepo implements OwnerCourtRepository {
  int createCalls = 0;
  Map<String, dynamic>? lastAdditionalInfo;

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
    lastAdditionalInfo = additionalInfo;
    return OwnerCourt(id: 'c1', name: name, isActive: true);
  }

  @override
  Future<List<OwnerCourt>> getCourts() async =>
      const [OwnerCourt(id: 'c1', name: 'Sân Test', isActive: true)];

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

Future<void> _pumpForm(WidgetTester tester, _FakeRepo repo) async {
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

  await tester.pumpWidget(
    RepositoryProvider<OwnerCourtRepository>.value(
      value: repo,
      child: BlocProvider<CourtBloc>(
        create: (_) => CourtBloc(repo),
        child: MaterialApp.router(routerConfig: router),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('creating a court navigates to the courts list', (tester) async {
    final repo = _FakeRepo();
    await _pumpForm(tester, repo);

    // On the create form (not the list yet).
    expect(find.text('Thêm sân mới'), findsOneWidget);
    expect(find.text('COURTS LIST'), findsNothing);

    // Field order: name(0), phone(1), address(2), lat(3), lng(4), maps(5)…
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Sân Pickleball Test');
    await tester.enterText(fields.at(2), '123 Đường Test, Q1');

    // Submit.
    await tester.tap(find.text('Tạo sân'));
    await tester.pumpAndSettle();

    // Created exactly once and landed on the list screen.
    expect(repo.createCalls, 1);
    expect(find.text('COURTS LIST'), findsOneWidget);
    expect(find.text('Thêm sân mới'), findsNothing);
  });

  testWidgets('missing required fields blocks submit and stays on the form',
      (tester) async {
    final repo = _FakeRepo();
    await _pumpForm(tester, repo);

    // Tap create without filling name/address.
    await tester.tap(find.text('Tạo sân'));
    await tester.pumpAndSettle();

    expect(repo.createCalls, 0);
    expect(find.text('COURTS LIST'), findsNothing);
    expect(find.text('Thêm sân mới'), findsOneWidget);
  });
}
