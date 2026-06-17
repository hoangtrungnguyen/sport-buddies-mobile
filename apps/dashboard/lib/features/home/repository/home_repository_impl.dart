import '../model/home_models.dart';
import 'home_api_client.dart';
import 'home_overview_mapper.dart';
import 'home_repository.dart';

/// Live [HomeRepository] backed by the Django `/api/home` endpoints. Reads come
/// from the consolidated overview call; approve/decline reuse the existing
/// booking-status and slot-join-request endpoints, dispatched by the item's
/// [PendingKind] (HOME_API_HANDOFF §3).
class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl(this._api);

  final HomeApiClient _api;

  @override
  Future<HomeOverview> getOverview({DateTime? date}) async {
    final json = await _api.getOverview(date: date == null ? null : _ymd(date));
    return mapHomeOverview(json);
  }

  @override
  Future<void> approveRequest(PendingRequest request) {
    return switch (request.kind) {
      PendingKind.booking => _api.updateBookingStatus(
          bookingId: request.id, status: 'confirmed'),
      PendingKind.joinRequest => _api.approveJoinRequest(request.id),
    };
  }

  @override
  Future<void> declineRequest(PendingRequest request) {
    return switch (request.kind) {
      PendingKind.booking => _api.updateBookingStatus(
          bookingId: request.id, status: 'cancelled'),
      PendingKind.joinRequest => _api.rejectJoinRequest(request.id),
    };
  }

  static String _ymd(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
