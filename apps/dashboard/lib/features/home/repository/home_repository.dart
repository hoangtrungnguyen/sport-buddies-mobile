import '../model/home_models.dart';

abstract class HomeRepository {
  /// Hydrates the whole screen in one call (`GET /api/home/overview`).
  /// [date] defaults to today server-side when null.
  Future<HomeOverview> getOverview({DateTime? date});

  /// Approve a pending request — routes by [request.kind] (booking-status
  /// PATCH vs slot-join-request approve).
  Future<void> approveRequest(PendingRequest request);

  /// Decline a pending request — routes by [request.kind].
  Future<void> declineRequest(PendingRequest request);
}
