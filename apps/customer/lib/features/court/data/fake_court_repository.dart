// EPIC-5 fake CourtRepository — seed data from the prototype (handoff doc 04
// §3). Artificial latency so loading states are visible.

import '../domain/court.dart';
import 'court_repository.dart';

/// Switchable edge datasets (handoff doc 04 §3).
enum FakeDataset { normal, noOpenSlots, noGroupSlots, noPhotos }

const _kCenterId = 'center-1';

const _amenities = <String>[
  'Có mái che',
  'Đèn đêm',
  'Thuê vợt',
  'Wifi',
  'Đồ uống',
  'Bãi giữ xe',
];

const _description =
    'Sân pickleball trong nhà mới khai trương, sàn nhựa chuyên dụng, lưới đạt '
    'chuẩn. Có sẵn vợt cho thuê và nước uống miễn phí. Khu vực để xe rộng rãi, '
    'gần phố đi bộ Nguyễn Huệ.';

class FakeCourtRepository implements CourtRepository {
  FakeCourtRepository({this.dataset = FakeDataset.normal});

  final FakeDataset dataset;

  static const _delay = Duration(milliseconds: 450);

  List<String> get _photos =>
      dataset == FakeDataset.noPhotos ? const [] : const ['1', '2', '3', '4', '5'];

  Court _court({
    required String id,
    required String name,
    required List<Sport> sports,
    int openSlotsToday = 4,
  }) =>
      Court(
        id: id,
        centerId: _kCenterId,
        name: name,
        address: '123 Nguyễn Du, Phường Bến Nghé, Quận 1',
        sports: sports,
        pricePerHourVnd: 180000,
        rating: 4.8,
        reviewCount: 126,
        distanceKm: 1.2,
        photoUrls: _photos,
        amenities: _amenities,
        description: _description,
        openSlotsToday: openSlotsToday,
        lat: 10.7769,
        lng: 106.7009,
      );

  @override
  Future<Court> getCourt(String courtId) async {
    await Future.delayed(_delay);
    // The detailed court (screen 07) is "Pickle Hub Q1".
    return _court(
      id: courtId,
      name: 'Pickle Hub Q1',
      sports: const [Sport.pickleball, Sport.tennis],
    );
  }

  @override
  Future<SportsCenter> getCenter(String centerId) async {
    await Future.delayed(_delay);
    return SportsCenter(
      id: _kCenterId,
      name: 'Pickle Hub Sài Gòn',
      courts: [
        _court(id: 'court-a', name: 'Sân A', sports: const [Sport.pickleball]),
        _court(id: 'court-b', name: 'Sân B', sports: const [Sport.pickleball]),
        _court(id: 'court-c', name: 'Sân C', sports: const [Sport.tennis]),
      ],
    );
  }
}
