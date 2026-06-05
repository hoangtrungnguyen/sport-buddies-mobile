// Mock open-slot data for "Slot trống" screen.
// Used as fallback when Supabase returns an empty list.
// TODO: remove fallback once slots are seeded in the dev/staging database

import 'package:spb_core/spb_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final _now = DateTime.now();

String? get _currentUserId =>
    Supabase.instance.client.auth.currentSession?.user.id;

// TODO: replace with SlotListCubit real data from Supabase (fetchAllGroupSlots)
List<Slot> get mockOpenSlots {
  final today = DateTime(_now.year, _now.month, _now.day);
  final tomorrow = today.add(const Duration(days: 1));

  return [
    Slot(
      id: 'mock-slot-001',
      startTime: today.copyWith(hour: 19, minute: 0),
      endTime: today.copyWith(hour: 21, minute: 0),
      courtId: 'mock-court-pickle-q3',
      courtName: 'Pickle Hub Q3 · Sân B',
      sportType: 'pickleball',
      accessPolicy: 'open',
      maxPlayers: 4,
      currentPlayers: 2,
      hostId: _currentUserId,
    ),
    Slot(
      id: 'mock-slot-002',
      startTime: today.copyWith(hour: 20, minute: 0),
      endTime: today.copyWith(hour: 21, minute: 30),
      courtId: 'mock-court-tao-dan',
      courtName: 'Sân Tao Đàn · Bóng 7v7',
      sportType: 'football',
      accessPolicy: 'open',
      maxPlayers: 14,
      currentPlayers: 9,
    ),
    Slot(
      id: 'mock-slot-003',
      startTime: today.copyWith(hour: 18, minute: 0),
      endTime: today.copyWith(hour: 19, minute: 30),
      courtId: 'mock-court-bt',
      courtName: 'CLB Cầu Lông Bình Thạnh · Sân 2',
      sportType: 'badminton',
      accessPolicy: 'open',
      maxPlayers: 4,
      currentPlayers: 1,
    ),
    Slot(
      id: 'mock-slot-004',
      startTime: tomorrow.copyWith(hour: 6, minute: 0),
      endTime: tomorrow.copyWith(hour: 7, minute: 30),
      courtId: 'mock-court-tennis-phu-nhuan',
      courtName: 'Sân Tennis Phú Nhuận · Sân A',
      sportType: 'tennis',
      accessPolicy: 'open',
      maxPlayers: 4,
      currentPlayers: 2,
    ),
    Slot(
      id: 'mock-slot-005',
      startTime: tomorrow.copyWith(hour: 19, minute: 30),
      endTime: tomorrow.copyWith(hour: 21, minute: 0),
      courtId: 'mock-court-pickle-q1',
      courtName: 'Pickle Hub Q1 · Sân A',
      sportType: 'pickleball',
      accessPolicy: 'open',
      maxPlayers: 4,
      currentPlayers: 3,
    ),
    Slot(
      id: 'mock-slot-006',
      startTime: tomorrow.copyWith(hour: 20, minute: 0),
      endTime: tomorrow.copyWith(hour: 22, minute: 0),
      courtId: 'mock-court-nguyen-du',
      courtName: 'Sân Nguyễn Du · Sân 5v5',
      sportType: 'football',
      accessPolicy: 'open',
      maxPlayers: 10,
      currentPlayers: 6,
    ),
  ];
}
