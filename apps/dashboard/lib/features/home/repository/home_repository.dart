import '../model/home_models.dart';

abstract class HomeRepository {
  Future<List<HomeKpi>> getTodayKpis();
  Future<List<PendingRequest>> getPendingRequests();
  Future<List<UpcomingSession>> getUpcomingToday();
  Future<List<RevenueDay>> getWeeklyRevenue();
  Future<List<CourtStatusRow>> getCourtStatusToday();
  Future<void> approveRequest(String id);
  Future<void> declineRequest(String id);
}
