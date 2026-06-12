import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_models.freezed.dart';

enum KpiTone { primary, tertiary, secondary, warn }
enum SessionStatus { confirmed, walkin }
enum CourtState { active, draft }

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
