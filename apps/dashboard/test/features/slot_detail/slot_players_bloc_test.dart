import 'package:dashboard/features/requests/model/booking_request.dart';
import 'package:dashboard/features/slot_detail/bloc/slot_players_bloc.dart';
import 'package:dashboard/features/slot_detail/model/slot_player.dart';
import 'package:dashboard/features/slot_detail/repository/slot_players_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepo implements SlotPlayersRepository {
  _FakeRepo({this.players = const [], this.throwIt = false});
  final List<SlotPlayer> players;
  final bool throwIt;
  String? lastSlotId;

  @override
  Future<List<SlotPlayer>> fetchPlayers({required String slotId}) async {
    lastSlotId = slotId;
    if (throwIt) throw Exception('boom');
    return players;
  }
}

SlotPlayer _p(String id, {PaymentStatus pay = PaymentStatus.unpaid}) =>
    SlotPlayer(id: id, name: 'P$id', paymentStatus: pay,
        bookingStatus: BookingStatus.confirmed);

void main() {
  test('started loads the roster for the bloc slot', () async {
    final repo = _FakeRepo(players: [_p('1', pay: PaymentStatus.paid), _p('2')]);
    final bloc = SlotPlayersBloc(repository: repo, slotId: 'slot-x');
    addTearDown(bloc.close);

    final loaded = bloc.stream.firstWhere((s) => s is SlotPlayersLoaded);
    bloc.add(const SlotPlayersEvent.started());
    final s = await loaded as SlotPlayersLoaded;

    expect(repo.lastSlotId, 'slot-x');
    expect(s.players, hasLength(2));
    expect(s.players.first.hasPaid, isTrue);
  });

  test('empty roster still loads (not a failure)', () async {
    final bloc = SlotPlayersBloc(repository: _FakeRepo(), slotId: 's');
    addTearDown(bloc.close);
    final loaded = bloc.stream.firstWhere((s) => s is SlotPlayersLoaded);
    bloc.add(const SlotPlayersEvent.started());
    expect((await loaded as SlotPlayersLoaded).players, isEmpty);
  });

  test('a repository error surfaces a failure', () async {
    final bloc =
        SlotPlayersBloc(repository: _FakeRepo(throwIt: true), slotId: 's');
    addTearDown(bloc.close);
    final failed = bloc.stream.firstWhere((s) => s is SlotPlayersFailure);
    bloc.add(const SlotPlayersEvent.started());
    expect((await failed as SlotPlayersFailure).message,
        contains('Không thể tải danh sách'));
  });
}
