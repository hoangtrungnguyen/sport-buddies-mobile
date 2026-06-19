// Supabase-backed [SlotRepository] — reads only (writes go through the API).
//
// Slots carry no price column, so per-slot price is derived from the court's
// `price_per_hour` × duration. The center schedule is single-court until a real
// venue model exists (see [SupabaseCourtRepository]).

import 'package:customer/core/debug/app_logger.dart';
import 'package:customer/features/court/data/supabase_court_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/schedule.dart';
import '../domain/time_slot.dart';
import 'court_repository.dart';

class SupabaseBrowseSlotRepository implements SlotRepository {
  const SupabaseBrowseSlotRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<TimeSlot>> getSlots(String courtId, DateTime date) async {
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));
    final pricePerHour = await _courtPricePerHour(courtId);

    final rows = await _client
        .from('slots')
        .select('id, court_id, start_at, end_at, status')
        .eq('court_id', courtId)
        .gte('start_at', dayStart.toUtc().toIso8601String())
        .lt('start_at', dayEnd.toUtc().toIso8601String())
        .order('start_at');

    return (rows as List).map((r) {
      final start = DateTime.parse(r['start_at'] as String).toLocal();
      final end = DateTime.parse(r['end_at'] as String).toLocal();
      final hours = end.difference(start).inMinutes / 60.0;
      return TimeSlot(
        id: r['id'] as String,
        courtId: r['court_id'] as String,
        start: start,
        end: end,
        priceVnd: (pricePerHour * hours).round(),
        status: _cellStatus(r['status'] as String?),
      );
    }).toList();
  }

  @override
  Future<ScheduleDay> getCenterSchedule(String centerId, DateTime date) async {
    // No venue grouping → single-court schedule (centerId == courtId).
    final slots = await getSlots(centerId, date);
    return ScheduleDay(
      date: date,
      hourLabels: [for (final s in slots) _hm(s.start)],
      rows: {
        centerId: [for (final s in slots) s.status],
      },
    );
  }

  @override
  Future<List<OpenGroupSlot>> getOpenGroupSlots(String courtId) async {
    final now = DateTime.now().toUtc();
    final rows = await _client
        .from('slots')
        .select(
          'id, start_at, end_at, max_players, courts!inner(name, sport_types)',
        )
        .eq('court_id', courtId)
        .eq('access_policy', 'open')
        .gte('start_at', now.toIso8601String())
        .order('start_at')
        .limit(10);

    final list = (rows as List);
    final joinedBySlot = await _participantCounts([
      for (final r in list) r['id'] as String,
    ]);

    final result = list.map((r) {
      final court = (r['courts'] as Map<String, dynamic>?) ?? const {};
      final start = DateTime.parse(r['start_at'] as String).toLocal();
      final end = DateTime.parse(r['end_at'] as String).toLocal();
      final sports = parseSports(court['sport_types']);
      return OpenGroupSlot(
        id: r['id'] as String,
        courtLabel: (court['name'] as String?) ?? '',
        sport: sports.first,
        timeLabel: _timeLabel(start, end),
        joined: joinedBySlot[r['id']] ?? 0,
        max: (r['max_players'] as int?) ?? 0,
      );
    }).toList();

    // Not-full first (handoff doc 04 §2).
    result.sort((a, b) {
      if (a.isFull == b.isFull) return 0;
      return a.isFull ? 1 : -1;
    });
    return result;
  }

  Future<int> _courtPricePerHour(String courtId) async {
    try {
      final row = await _client
          .from('courts')
          .select('price_per_hour')
          .eq('id', courtId)
          .single();
      return num.tryParse('${row['price_per_hour']}')?.round() ?? 0;
    } catch (e, st) {
      appLogger.e(
        'SupabaseBrowseSlotRepository._courtPricePerHour',
        error: e,
        stackTrace: st,
      );
      return 0;
    }
  }

  /// slot_id → confirmed participant count.
  Future<Map<String, int>> _participantCounts(List<String> slotIds) async {
    if (slotIds.isEmpty) return const {};
    try {
      final rows = await _client
          .from('slot_participants')
          .select('slot_id')
          .inFilter('slot_id', slotIds);
      final counts = <String, int>{};
      for (final r in (rows as List)) {
        final id = r['slot_id'] as String;
        counts[id] = (counts[id] ?? 0) + 1;
      }
      return counts;
    } catch (e, st) {
      appLogger.e(
        'SupabaseBrowseSlotRepository._participantCounts',
        error: e,
        stackTrace: st,
      );
      return const {};
    }
  }
}

/// Real slot statuses are open/booked/blocked/owner/maintenance; the picker
/// grid only distinguishes bookable (open) from greyed (everything else).
CellStatus _cellStatus(String? status) => switch (status) {
  'open' => CellStatus.open,
  'booked' => CellStatus.booked,
  _ => CellStatus.blocked,
};

String _hm(DateTime t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

String _timeLabel(DateTime start, DateTime end) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final d = DateTime(start.year, start.month, start.day);
  final String day;
  if (d == today) {
    day = 'Hôm nay';
  } else if (d == today.add(const Duration(days: 1))) {
    day = 'Mai';
  } else {
    day =
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
  }
  return '$day · ${_hm(start)} – ${_hm(end)}';
}
