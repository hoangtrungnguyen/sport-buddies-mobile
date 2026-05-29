import 'dart:async';

import 'package:dashboard/features/requests/bloc/requests_bloc.dart';
import 'package:dashboard/features/requests/model/booking_request.dart';
import 'package:dashboard/features/requests/model/requests_action.dart';
import 'package:dashboard/features/requests/repository/booking_action_repository.dart';
import 'package:dashboard/features/requests/repository/booking_request_repository.dart';
import 'package:flutter_test/flutter_test.dart';

BookingRequest _req(String id, int hour, {DateTime? day}) {
  final d = day ?? DateTime(2026, 5, 29);
  final start = DateTime(d.year, d.month, d.day, hour);
  return BookingRequest(
    id: id,
    code: '#$id',
    customerName: 'Khách $id',
    courtName: 'Sân 1',
    startAt: start,
    endAt: start.add(const Duration(hours: 1)),
    status: BookingStatus.pending,
    revenue: 100000,
  );
}

/// In-memory repo. Returns [byDay] keyed by `yyyy-MM-dd`, records the days it was
/// asked for, and can be told to throw.
class _FakeRepo implements BookingRequestRepository {
  _FakeRepo({this.byDay = const {}, this.throwIt = false});

  final Map<String, List<BookingRequest>> byDay;
  bool throwIt;
  final List<DateTime> calls = [];

  static String key(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Future<List<BookingRequest>> fetchForDay({required DateTime day}) async {
    calls.add(day);
    if (throwIt) throw Exception('boom');
    return byDay[key(day)] ?? const [];
  }
}

/// Repo whose fetches resolve only when the test completes their per-day gate —
/// lets us force out-of-order completion to exercise the load-token guard.
class _GatedRepo implements BookingRequestRepository {
  final Map<String, Completer<List<BookingRequest>>> gates = {};
  final List<DateTime> calls = [];

  Completer<List<BookingRequest>> gate(DateTime d) =>
      gates.putIfAbsent(_FakeRepo.key(d), () => Completer());

  @override
  Future<List<BookingRequest>> fetchForDay({required DateTime day}) {
    calls.add(day);
    return gate(day).future;
  }
}

/// Records approve/reject/undo calls and can be told to throw. When
/// [approveGate] is set, approve() suspends on it so the test can keep a call
/// "in flight" and exercise the bloc's re-tap guard.
class _FakeActionRepo implements BookingActionRepository {
  _FakeActionRepo({this.throwIt = false, this.approveGate});
  bool throwIt;
  final Completer<void>? approveGate;
  final List<String> log = [];

  @override
  Future<void> approve({required String bookingId}) async {
    log.add('approve:$bookingId');
    if (approveGate != null) await approveGate!.future;
    if (throwIt) throw Exception('boom');
  }

  @override
  Future<void> reject({required String bookingId, String? reason}) async {
    log.add('reject:$bookingId:$reason');
    if (throwIt) throw Exception('boom');
  }

  @override
  Future<void> restorePending({
    required String bookingId,
    String? slotId,
  }) async {
    log.add('restore:$bookingId:$slotId');
    if (throwIt) throw Exception('boom');
  }
}

/// Yields several microtasks so queued events reach their first `await`.
Future<void> _settle() async {
  for (var i = 0; i < 6; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  final today = DateTime(2026, 5, 29);
  DateTime nowFixed() => DateTime(2026, 5, 29, 9, 30);

  RequestsBloc bloc(_FakeRepo repo, [BookingActionRepository? actions]) =>
      RequestsBloc(
        repository: repo,
        actionRepository: actions ?? _FakeActionRepo(),
        now: nowFixed,
      );

  test('started loads today, sorted ascending by start time', () async {
    final repo = _FakeRepo(byDay: {
      _FakeRepo.key(today): [_req('b', 10), _req('a', 8)],
    });
    final b = bloc(repo);
    addTearDown(b.close);

    final loaded = b.stream.firstWhere((s) => s is RequestsLoaded);
    b.add(const RequestsEvent.started());
    final state = await loaded as RequestsLoaded;

    expect(state.day, today); // defaulted to today (date-only)
    expect(state.requests.map((r) => r.id).toList(), ['a', 'b']);
    expect(state.page, 0);
    expect(repo.calls.single, today);
  });

  test('empty day still loads (empty list, not a failure)', () async {
    final b = bloc(_FakeRepo());
    addTearDown(b.close);

    final loaded = b.stream.firstWhere((s) => s is RequestsLoaded);
    b.add(const RequestsEvent.started());
    final state = await loaded as RequestsLoaded;

    expect(state.requests, isEmpty);
  });

  test('dateChanged fetches the new day and resets the page', () async {
    final tomorrow = DateTime(2026, 5, 30);
    final repo = _FakeRepo(byDay: {
      _FakeRepo.key(today): List.generate(6, (i) => _req('$i', 6 + i)),
      _FakeRepo.key(tomorrow): [_req('x', 7)],
    });
    final b = bloc(repo);
    addTearDown(b.close);

    b.add(const RequestsEvent.started());
    await b.stream.firstWhere((s) => s is RequestsLoaded);

    // Move to page 1, then change day → page must reset to 0.
    b.add(const RequestsEvent.pageChanged(1));
    await b.stream
        .firstWhere((s) => s is RequestsLoaded && (s).page == 1);

    final reloaded = b.stream.firstWhere(
        (s) => s is RequestsLoaded && (s).day == tomorrow && !s.busy);
    b.add(RequestsEvent.dateChanged(tomorrow));
    final state = await reloaded as RequestsLoaded;

    expect(state.requests.map((r) => r.id).toList(), ['x']);
    expect(state.page, 0);
    expect(repo.calls.last, tomorrow);
  });

  test('pageChanged clamps into range and is a no-op when unchanged', () async {
    final repo = _FakeRepo(byDay: {
      _FakeRepo.key(today): List.generate(10, (i) => _req('$i', 6 + i)),
    });
    final b = bloc(repo);
    addTearDown(b.close);

    b.add(const RequestsEvent.started());
    await b.stream.firstWhere((s) => s is RequestsLoaded);

    // 10 items / 4 per page = 3 pages (max index 2); request 9 → clamps to 2.
    b.add(const RequestsEvent.pageChanged(9));
    final state = await b.stream
            .firstWhere((s) => s is RequestsLoaded && (s).page == 2)
        as RequestsLoaded;
    expect(state.page, 2);
  });

  test('repository error surfaces a failure carrying the day', () async {
    final b = bloc(_FakeRepo(throwIt: true));
    addTearDown(b.close);

    final failed = b.stream.firstWhere((s) => s is RequestsFailure);
    b.add(const RequestsEvent.started());
    final state = await failed as RequestsFailure;

    expect(state.message, 'Không thể tải danh sách đơn đặt sân.');
    expect(state.day, today);
  });

  test('refreshed after a failure retries the same day and can recover',
      () async {
    final repo = _FakeRepo(throwIt: true);
    final b = bloc(repo);
    addTearDown(b.close);

    b.add(const RequestsEvent.started());
    await b.stream.firstWhere((s) => s is RequestsFailure);

    // Backend recovers; retry the day from the failure state.
    repo.throwIt = false;
    final loaded = b.stream.firstWhere((s) => s is RequestsLoaded);
    b.add(const RequestsEvent.refreshed());
    final state = await loaded as RequestsLoaded;

    expect(state.day, today);
    expect(repo.calls.last, today);
  });

  test('dateChanged to the day already shown is a no-op (no page reset/refetch)',
      () async {
    final repo = _FakeRepo(byDay: {
      _FakeRepo.key(today): List.generate(8, (i) => _req('$i', 6 + i)),
    });
    final b = bloc(repo);
    addTearDown(b.close);

    b.add(const RequestsEvent.started());
    await b.stream.firstWhere((s) => s is RequestsLoaded);
    b.add(const RequestsEvent.pageChanged(1));
    await b.stream.firstWhere((s) => s is RequestsLoaded && (s).page == 1);

    final callsBefore = repo.calls.length;
    b.add(RequestsEvent.dateChanged(today)); // same day → nothing should happen
    await _settle();

    final state = b.state as RequestsLoaded;
    expect(state.page, 1); // page preserved
    expect(repo.calls.length, callsBefore); // no refetch
  });

  test('pageChanged is a no-op when the page is unchanged', () async {
    final repo = _FakeRepo(byDay: {
      _FakeRepo.key(today): List.generate(10, (i) => _req('$i', 6 + i)),
    });
    final b = bloc(repo);
    addTearDown(b.close);

    b.add(const RequestsEvent.started());
    await b.stream.firstWhere((s) => s is RequestsLoaded);

    final pages = <int>[];
    final sub = b.stream
        .listen((s) => s is RequestsLoaded ? pages.add(s.page) : null);
    b.add(const RequestsEvent.pageChanged(0)); // already on 0 → no emit
    b.add(const RequestsEvent.pageChanged(2)); // real change
    await _settle();
    await sub.cancel();

    expect(pages, [2]); // only the genuine change was emitted
  });

  test('out-of-order day loads: the latest day wins (load-token guard)',
      () async {
    final t2 = DateTime(2026, 5, 30);
    final t3 = DateTime(2026, 5, 31);
    final repo = _GatedRepo();
    final b = RequestsBloc(
      repository: repo,
      actionRepository: _FakeActionRepo(),
      now: nowFixed,
    );
    addTearDown(b.close);

    // Three loads in flight: today (started), then t2, then t3.
    b.add(const RequestsEvent.started());
    await _settle();
    b.add(RequestsEvent.dateChanged(t2));
    await _settle();
    b.add(RequestsEvent.dateChanged(t3));
    await _settle();

    // Resolve in reverse start order — the newest (t3) first, oldest last.
    repo.gate(t3).complete([_req('c', 7, day: t3)]);
    repo.gate(t2).complete([_req('b', 7, day: t2)]);
    repo.gate(today).complete([_req('a', 7, day: today)]);
    await _settle();

    final state = b.state as RequestsLoaded;
    expect(state.day, t3); // stale t1/t2 emits were dropped
    expect(state.requests.single.id, 'c');
  });

  group('approve / reject / undo', () {
    BookingRequest pending(String id, {String? slotId, String? phone}) =>
        BookingRequest(
          id: id,
          code: '#$id',
          customerName: 'Khách $id',
          courtName: 'Sân 1',
          startAt: DateTime(2026, 5, 29, 8),
          endAt: DateTime(2026, 5, 29, 9),
          status: BookingStatus.pending,
          revenue: 100000,
          slotId: slotId,
          customerPhone: phone,
        );

    Future<(RequestsBloc, _FakeActionRepo)> loadedWith(
      List<BookingRequest> items, {
      _FakeActionRepo? act,
    }) async {
      final actions = act ?? _FakeActionRepo();
      final repo = _FakeRepo(byDay: {_FakeRepo.key(today): items});
      final b = bloc(repo, actions);
      b.add(const RequestsEvent.started());
      await b.stream.firstWhere((s) => s is RequestsLoaded);
      return (b, actions);
    }

    test('approve confirms the request and emits an approved action', () async {
      final req = pending('a', phone: '+84900000000');
      final (b, actions) = await loadedWith([req]);
      addTearDown(b.close);

      final done = b.stream.firstWhere(
          (s) => s is RequestsLoaded && s.lastAction is RequestApproved);
      b.add(RequestsEvent.approved(req));
      final s = await done as RequestsLoaded;

      expect(actions.log, ['approve:a']);
      final updated = s.requests.single;
      expect(updated.status, BookingStatus.confirmed);
      expect(updated.revealedPhone, '+84900000000'); // revealed after approval
      expect((s.lastAction as RequestApproved).request.id, 'a');
    });

    test('reject cancels the request, frees the slot, passes the reason',
        () async {
      final req = pending('b', slotId: 'slot-b');
      final (b, actions) = await loadedWith([req]);
      addTearDown(b.close);

      final done = b.stream.firstWhere(
          (s) => s is RequestsLoaded && s.lastAction is RequestRejected);
      b.add(RequestsEvent.rejected(req, reason: 'Trùng lịch'));
      final s = await done as RequestsLoaded;

      // Slot is freed by the DB trigger, not by an explicit reject slot write.
      expect(actions.log, ['reject:b:Trùng lịch']);
      expect(s.requests.single.status, BookingStatus.cancelled);
      expect((s.lastAction as RequestRejected).reason, 'Trùng lịch');
    });

    test('undo restores a request to pending', () async {
      final req = pending('c', slotId: 'slot-c');
      final (b, actions) = await loadedWith([req]);
      addTearDown(b.close);

      // approve, then undo
      b.add(RequestsEvent.approved(req));
      final approved = await b.stream.firstWhere(
              (s) => s is RequestsLoaded && s.lastAction is RequestApproved)
          as RequestsLoaded;
      final confirmed = approved.requests.single;

      final undone = b.stream.firstWhere(
          (s) => s is RequestsLoaded && s.lastAction is RequestUndone);
      b.add(RequestsEvent.undoRequested(confirmed));
      final s = await undone as RequestsLoaded;

      expect(actions.log, ['approve:c', 'restore:c:slot-c']);
      expect(s.requests.single.status, BookingStatus.pending);
    });

    test('a failed approve keeps the row unchanged and emits a failure action',
        () async {
      final req = pending('d');
      final (b, _) = await loadedWith([req], act: _FakeActionRepo(throwIt: true));
      addTearDown(b.close);

      final done = b.stream.firstWhere(
          (s) => s is RequestsLoaded && s.lastAction is RequestActionFailed);
      b.add(RequestsEvent.approved(req));
      final s = await done as RequestsLoaded;

      expect(s.requests.single.status, BookingStatus.pending); // unchanged
      expect((s.lastAction as RequestActionFailed).message,
          contains('Không thể duyệt'));
    });

    test('reject and undo failures surface their own localized messages',
        () async {
      final req = pending('f', slotId: 'slot-f');
      final (b, _) = await loadedWith([req], act: _FakeActionRepo(throwIt: true));
      addTearDown(b.close);

      final rejFail = b.stream.firstWhere(
          (s) => s is RequestsLoaded && s.lastAction is RequestActionFailed);
      b.add(RequestsEvent.rejected(req, reason: 'x'));
      final r = await rejFail as RequestsLoaded;
      expect(r.requests.single.status, BookingStatus.pending); // unchanged
      expect((r.lastAction as RequestActionFailed).message,
          contains('Không thể từ chối'));

      b.add(const RequestsEvent.actionConsumed());
      final undoFail = b.stream.firstWhere(
          (s) => s is RequestsLoaded && s.lastAction is RequestActionFailed);
      b.add(RequestsEvent.undoRequested(req));
      final u = await undoFail as RequestsLoaded;
      expect((u.lastAction as RequestActionFailed).message,
          contains('Không thể hoàn tác'));
    });

    test('a re-tap while an action is in flight is ignored (no duplicate)',
        () async {
      final req = pending('g');
      final gate = Completer<void>();
      final actions = _FakeActionRepo(approveGate: gate);
      final repo = _FakeRepo(byDay: {_FakeRepo.key(today): [req]});
      final b = bloc(repo, actions);
      addTearDown(b.close);
      b.add(const RequestsEvent.started());
      await b.stream.firstWhere((s) => s is RequestsLoaded);

      // First approve is held in flight by the gate; the second must be dropped.
      b.add(RequestsEvent.approved(req));
      await _settle();
      b.add(RequestsEvent.approved(req));
      await _settle();
      gate.complete();
      await _settle();

      expect(actions.log, ['approve:g']); // second tap never reached the repo
    });

    test('actionConsumed clears the transient lastAction', () async {
      final req = pending('e');
      final (b, _) = await loadedWith([req]);
      addTearDown(b.close);

      b.add(RequestsEvent.approved(req));
      await b.stream.firstWhere(
          (s) => s is RequestsLoaded && s.lastAction is RequestApproved);

      final cleared = b.stream
          .firstWhere((s) => s is RequestsLoaded && s.lastAction == null);
      b.add(const RequestsEvent.actionConsumed());
      expect((await cleared as RequestsLoaded).lastAction, isNull);
    });
  });
}
