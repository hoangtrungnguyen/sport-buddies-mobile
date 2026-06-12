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
      final results = await Future.wait([
        _repository.getTodayKpis(),
        _repository.getPendingRequests(),
        _repository.getUpcomingToday(),
        _repository.getWeeklyRevenue(),
        _repository.getCourtStatusToday(),
      ]);

      final kpis = results[0] as List<HomeKpi>;
      final requests = results[1] as List<PendingRequest>;
      final upcoming = results[2] as List<UpcomingSession>;
      final revenue = results[3] as List<RevenueDay>;
      final courtStatus = results[4] as List<CourtStatusRow>;

      emit(HomeState.loaded(
        kpis: kpis,
        requests: requests,
        upcoming: upcoming,
        weeklyRevenue: revenue,
        courtStatus: courtStatus,
      ));
    } catch (e) {
      emit(HomeState.failure(e.toString()));
    }
  }

  Future<void> _onRequestApproved(
      HomeRequestApproved event, Emitter<HomeState> emit) async {
    if (state is! HomeLoaded) return;
    final current = state as HomeLoaded;

    final updatedRequests = current.requests
        .where((r) => r.id != event.id)
        .toList();

    // Update pending KPI
    final updatedKpis = current.kpis.map((kpi) {
      if (kpi.id == 'pending') {
        return kpi.copyWith(value: updatedRequests.length.toString());
      }
      return kpi;
    }).toList();

    emit(HomeState.loaded(
      kpis: updatedKpis,
      requests: updatedRequests,
      upcoming: current.upcoming,
      weeklyRevenue: current.weeklyRevenue,
      courtStatus: current.courtStatus,
    ));

    try {
      await _repository.approveRequest(event.id);
    } catch (_) {
      // Restore on error
      emit(current);
    }
  }

  Future<void> _onRequestDeclined(
      HomeRequestDeclined event, Emitter<HomeState> emit) async {
    if (state is! HomeLoaded) return;
    final current = state as HomeLoaded;

    final updatedRequests = current.requests
        .where((r) => r.id != event.id)
        .toList();

    // Update pending KPI
    final updatedKpis = current.kpis.map((kpi) {
      if (kpi.id == 'pending') {
        return kpi.copyWith(value: updatedRequests.length.toString());
      }
      return kpi;
    }).toList();

    emit(HomeState.loaded(
      kpis: updatedKpis,
      requests: updatedRequests,
      upcoming: current.upcoming,
      weeklyRevenue: current.weeklyRevenue,
      courtStatus: current.courtStatus,
    ));

    try {
      await _repository.declineRequest(event.id);
    } catch (_) {
      // Restore on error
      emit(current);
    }
  }
}
