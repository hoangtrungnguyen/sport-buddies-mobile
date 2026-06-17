import 'package:flutter_bloc/flutter_bloc.dart';
import '../model/home_models.dart';
import '../repository/home_repository.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({required HomeRepository repository})
      : _repository = repository,
        super(const HomeState.initial()) {
    on<HomeStarted>(_onStarted);
    on<HomeRequestApproved>(_onRequestApproved);
    on<HomeRequestDeclined>(_onRequestDeclined);
  }

  final HomeRepository _repository;

  Future<void> _onStarted(HomeStarted event, Emitter<HomeState> emit) async {
    emit(const HomeState.loading());
    try {
      final o = await _repository.getOverview();
      emit(HomeState.loaded(
        summary: o.summary,
        kpis: o.kpis,
        requests: o.requests,
        requestsTotal: o.requestsTotal,
        upcoming: o.upcoming,
        weeklyRevenue: o.weeklyRevenue,
        courtStatus: o.courtStatus,
      ));
    } catch (e) {
      emit(HomeState.failure(e.toString()));
    }
  }

  Future<void> _onRequestApproved(
      HomeRequestApproved event, Emitter<HomeState> emit) {
    return _resolve(emit, event.request, _repository.approveRequest);
  }

  Future<void> _onRequestDeclined(
      HomeRequestDeclined event, Emitter<HomeState> emit) {
    return _resolve(emit, event.request, _repository.declineRequest);
  }

  /// Optimistically drop [request] from the list + pending counters, then call
  /// [action]. On failure re-fetch the overview to re-sync (a 409 means the
  /// item was already resolved elsewhere — HOME_API_HANDOFF §3).
  Future<void> _resolve(
    Emitter<HomeState> emit,
    PendingRequest request,
    Future<void> Function(PendingRequest) action,
  ) async {
    if (state is! HomeLoaded) return;
    final current = state as HomeLoaded;

    final updatedRequests =
        current.requests.where((r) => r.id != request.id).toList();
    final newTotal =
        current.requestsTotal > 0 ? current.requestsTotal - 1 : 0;
    final updatedKpis = [
      for (final kpi in current.kpis)
        kpi.id == 'pending' ? kpi.copyWith(value: '$newTotal') : kpi,
    ];

    emit(current.copyWith(
      requests: updatedRequests,
      requestsTotal: newTotal,
      kpis: updatedKpis,
    ));

    try {
      await action(request);
    } catch (_) {
      add(const HomeEvent.started());
    }
  }
}
