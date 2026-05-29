import 'package:spb_core/spb_core.dart';

/// In-memory repository with hard-coded HCMC courts.
///
/// Used when MAP_PROVIDER=general so the map renders without Supabase.
class MockCourtAvailabilityRepository implements CourtAvailabilityRepository {
  const MockCourtAvailabilityRepository();

  static const _courts = [
    CourtAvailability(
      courtId: 'mock-001',
      name: 'Sân cầu lông Phú Nhuận',
      lat: 10.7993,
      lng: 106.6795,
      openSlotCount: 4,
      sportTypes: ['badminton'],
    ),
    CourtAvailability(
      courtId: 'mock-002',
      name: 'Sân bóng đá mini Gò Vấp',
      lat: 10.8380,
      lng: 106.6648,
      openSlotCount: 2,
      sportTypes: ['football'],
    ),
    CourtAvailability(
      courtId: 'mock-003',
      name: 'Sân pickleball Bình Thạnh',
      lat: 10.8141,
      lng: 106.7062,
      openSlotCount: 0,
      sportTypes: ['pickleball'],
    ),
    CourtAvailability(
      courtId: 'mock-004',
      name: 'Sân tennis Quận 3',
      lat: 10.7785,
      lng: 106.6894,
      openSlotCount: 1,
      sportTypes: ['tennis'],
    ),
    CourtAvailability(
      courtId: 'mock-005',
      name: 'Sân đa năng Thủ Đức',
      lat: 10.8526,
      lng: 106.7541,
      openSlotCount: 6,
      sportTypes: ['football', 'badminton', 'tennis', 'pickleball'],
    ),
    CourtAvailability(
      courtId: 'mock-006',
      name: 'Sân cầu lông Quận 7',
      lat: 10.7322,
      lng: 106.7187,
      openSlotCount: 3,
      sportTypes: ['badminton'],
    ),
    CourtAvailability(
      courtId: 'mock-007',
      name: 'Sân bóng đá Tân Bình',
      lat: 10.8017,
      lng: 106.6528,
      openSlotCount: 0,
      sportTypes: ['football'],
    ),
    CourtAvailability(
      courtId: 'mock-008',
      name: 'Sân pickleball Quận 1',
      lat: 10.7769,
      lng: 106.7009,
      openSlotCount: 5,
      sportTypes: ['pickleball'],
    ),
  ];

  @override
  Future<Result<List<CourtAvailability>>> fetchCourtsWithAvailability() async =>
      const Success(_courts);
}
