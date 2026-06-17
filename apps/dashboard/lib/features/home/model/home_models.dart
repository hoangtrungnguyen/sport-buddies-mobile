import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_models.freezed.dart';

enum KpiTone { primary, tertiary, secondary, warn }
enum SessionStatus { confirmed, walkin }
enum CourtState { active, draft }

/// Which backend flow a pending request belongs to — decides the approve /
/// decline route (`booking` → booking-status PATCH, `joinRequest` →
/// slot-join-request approve/reject). See HOME_API_HANDOFF §3.
enum PendingKind { booking, joinRequest }

@freezed
abstract class HomeKpi with _$HomeKpi {
  const factory HomeKpi({
    required String id,
    required String label,
    required String value,
    String? unit,
    String? delta,
    bool? deltaUp,
    String? sub,
    int? progress,
    required KpiTone tone,
    required String icon,
  }) = _HomeKpi;
}

@freezed
abstract class PendingRequest with _$PendingRequest {
  const factory PendingRequest({
    required String id,
    required PendingKind kind,
    required String name,
    required String initials,
    required String court,
    required String venue,
    required String sport,
    required String when,
    required int price,
    @Default(false) bool regular,
  }) = _PendingRequest;
}

@freezed
abstract class UpcomingSession with _$UpcomingSession {
  const factory UpcomingSession({
    required String id,
    required String time,
    required String end,
    required String name,
    required String where,
    required SessionStatus status,
  }) = _UpcomingSession;
}

@freezed
abstract class RevenueDay with _$RevenueDay {
  const factory RevenueDay({
    required String day,
    required int value,
    @Default(false) bool today,
  }) = _RevenueDay;
}

@freezed
abstract class CourtStatusRow with _$CourtStatusRow {
  const factory CourtStatusRow({
    required String id,
    required String name,
    required int venues,
    required int occupancy,
    required CourtState status,
  }) = _CourtStatusRow;
}

/// Greeting-header context: the owner's name + their active-court / sub-court
/// counts (`summary` block of the overview payload).
@freezed
abstract class HomeSummary with _$HomeSummary {
  const factory HomeSummary({
    String? ownerName,
    @Default(0) int activeCourts,
    @Default(0) int totalVenues,
  }) = _HomeSummary;
}

/// The whole Home screen in one payload — every block of `/api/home/overview`,
/// parsed and ready for the bloc. [requestsTotal] is the full pending count
/// (the panel may render fewer items).
class HomeOverview {
  const HomeOverview({
    required this.summary,
    required this.kpis,
    required this.requests,
    required this.requestsTotal,
    required this.upcoming,
    required this.weeklyRevenue,
    required this.courtStatus,
  });

  final HomeSummary summary;
  final List<HomeKpi> kpis;
  final List<PendingRequest> requests;
  final int requestsTotal;
  final List<UpcomingSession> upcoming;
  final List<RevenueDay> weeklyRevenue;
  final List<CourtStatusRow> courtStatus;
}
