import '../model/home_models.dart';
import 'home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  @override
  Future<List<HomeKpi>> getTodayKpis() async {
    // Seed data from spec
    return [
      const HomeKpi(
        id: 'revenue',
        label: 'Doanh thu hôm nay',
        value: '4.250.000đ',
        delta: '+12%',
        deltaUp: true,
        sub: 'so với hôm qua',
        tone: KpiTone.primary,
        icon: 'payments',
      ),
      const HomeKpi(
        id: 'bookings',
        label: 'Lượt đặt hôm nay',
        value: '18',
        unit: 'lượt',
        delta: '6 đang chờ',
        sub: 'trên 8 sân con',
        tone: KpiTone.tertiary,
        icon: 'event_available',
      ),
      const HomeKpi(
        id: 'occupancy',
        label: 'Tỷ lệ lấp đầy',
        value: '76%',
        progress: 76,
        sub: 'giờ vàng 18–21h…',
        tone: KpiTone.secondary,
        icon: 'donut_large',
      ),
      const HomeKpi(
        id: 'pending',
        label: 'Yêu cầu chờ duyệt',
        value: '8',
        unit: 'yêu cầu',
        delta: '2 quá hạn',
        deltaUp: false,
        sub: 'cần phản hồi…',
        tone: KpiTone.warn,
        icon: 'inbox',
      ),
    ];
  }

  @override
  Future<List<PendingRequest>> getPendingRequests() async {
    // Seed data: 6 requests shown, "8 total"
    return [
      const PendingRequest(
        id: 'req1',
        name: 'Trần Quốc Bảo',
        initials: 'TQ',
        court: 'SnB Đại Lộc',
        venue: 'Sân 1',
        sport: 'Pickleball',
        when: 'Hôm nay · 18:00–19:30',
        price: 180000,
        regular: true,
      ),
      const PendingRequest(
        id: 'req2',
        name: 'Lê Thanh Long',
        initials: 'LT',
        court: 'SnB Phú Mỹ Hưng',
        venue: 'Sân A',
        sport: 'Tennis',
        when: 'Hôm nay · 17:00–18:00',
        price: 250000,
        regular: false,
      ),
      const PendingRequest(
        id: 'req3',
        name: 'Nguyễn Văn A',
        initials: 'NV',
        court: 'SnB Đại Lộc',
        venue: 'Sân 2',
        sport: 'Cầu lông',
        when: 'Hôm nay · 19:00–20:00',
        price: 120000,
        regular: true,
      ),
      const PendingRequest(
        id: 'req4',
        name: 'Phạm Minh Huy',
        initials: 'PM',
        court: 'Sân Thể Thao Tân Quy',
        venue: 'Sân C',
        sport: 'Bóng đá 5v5',
        when: 'Hôm nay · 20:00–21:30',
        price: 450000,
        regular: false,
      ),
      const PendingRequest(
        id: 'req5',
        name: 'Võ Quý Tân',
        initials: 'VQ',
        court: 'SnB Phú Mỹ Hưng',
        venue: 'Sân B',
        sport: 'Pickleball',
        when: 'Hôm nay · 16:00–17:00',
        price: 180000,
        regular: false,
      ),
      const PendingRequest(
        id: 'req6',
        name: 'Đỗ Hồng Giang',
        initials: 'ĐH',
        court: 'SnB Đại Lộc',
        venue: 'Sân 3',
        sport: 'Tennis',
        when: 'Hôm nay · 15:00–16:00',
        price: 250000,
        regular: true,
      ),
    ];
  }

  @override
  Future<List<UpcomingSession>> getUpcomingToday() async {
    // Seed data: 5 rows of today's sessions
    return [
      const UpcomingSession(
        id: 'sess1',
        time: '17:00',
        end: '18:00',
        name: 'Đặng Hoàng Long',
        where: 'Đại Lộc · Sân 1',
        status: SessionStatus.confirmed,
      ),
      const UpcomingSession(
        id: 'sess2',
        time: '18:00',
        end: '19:00',
        name: 'Khách vãng lai',
        where: 'Đại Lộc · Sân A',
        status: SessionStatus.walkin,
      ),
      const UpcomingSession(
        id: 'sess3',
        time: '19:00',
        end: '20:00',
        name: 'Nguyễn Văn B',
        where: 'Phú Mỹ Hưng · Sân B',
        status: SessionStatus.confirmed,
      ),
      const UpcomingSession(
        id: 'sess4',
        time: '20:00',
        end: '21:00',
        name: 'Trần Hữu C',
        where: 'Tân Quy · Sân C',
        status: SessionStatus.confirmed,
      ),
      const UpcomingSession(
        id: 'sess5',
        time: '21:00',
        end: '22:00',
        name: 'Lý Duy D',
        where: 'Đại Lộc · Sân 2',
        status: SessionStatus.walkin,
      ),
    ];
  }

  @override
  Future<List<RevenueDay>> getWeeklyRevenue() async {
    // Last 7 days + today
    return [
      const RevenueDay(day: 'T2', value: 3900000, today: false),
      const RevenueDay(day: 'T3', value: 3200000, today: false),
      const RevenueDay(day: 'T4', value: 4600000, today: false),
      const RevenueDay(day: 'T5', value: 5100000, today: false),
      const RevenueDay(day: 'T6', value: 3800000, today: false),
      const RevenueDay(day: 'T7', value: 4900000, today: false),
      const RevenueDay(day: 'Hôm nay', value: 4250000, today: true),
    ];
  }

  @override
  Future<List<CourtStatusRow>> getCourtStatusToday() async {
    return [
      const CourtStatusRow(
        id: 'court1',
        name: 'SnB Đại Lộc',
        venues: 5,
        occupancy: 82,
        status: CourtState.active,
      ),
      const CourtStatusRow(
        id: 'court2',
        name: 'SnB Phú Mỹ Hưng',
        venues: 2,
        occupancy: 64,
        status: CourtState.active,
      ),
      const CourtStatusRow(
        id: 'court3',
        name: 'Sân Thể Thao Tân Quy',
        venues: 1,
        occupancy: 28,
        status: CourtState.draft,
      ),
    ];
  }

  @override
  Future<void> approveRequest(String id) async {
    // Mock: just delay to simulate network
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<void> declineRequest(String id) async {
    // Mock: just delay to simulate network
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
