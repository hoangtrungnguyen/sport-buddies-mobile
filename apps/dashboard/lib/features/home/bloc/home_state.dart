import 'package:freezed_annotation/freezed_annotation.dart';
import '../model/home_models.dart';

part 'home_state.freezed.dart';

@freezed
sealed class HomeState with _$HomeState {
  const factory HomeState.initial() = HomeInitial;
  const factory HomeState.loading() = HomeLoading;
  const factory HomeState.loaded({
    required HomeSummary summary,
    required List<HomeKpi> kpis,
    required List<PendingRequest> requests,
    required int requestsTotal,
    required List<UpcomingSession> upcoming,
    required List<RevenueDay> weeklyRevenue,
    required List<CourtStatusRow> courtStatus,
  }) = HomeLoaded;
  const factory HomeState.failure(String message) = HomeFailure;
}
