import 'package:dashboard/features/venue_schedule/model/models.dart';
import 'package:dashboard/features/venue_schedule/repository/schedule_mappers.dart';
import 'package:flutter_test/flutter_test.dart';

/// Builds a `slots` row with UTC ISO times derived from local wall-clock, so
/// assertions on the local-converted output are timezone-independent.
Map<String, dynamic> _slotRow({
  String id = 's1',
  String courtId = 'c1',
  required DateTime startLocal,
  required Duration duration,
  String status = kStatusOpen,
  String? blockedReason,
  int? maxPlayers,
}) =>
    {
      'id': id,
      'court_id': courtId,
      'start_at': startLocal.toUtc().toIso8601String(),
      'end_at': startLocal.add(duration).toUtc().toIso8601String(),
      'status': status,
      'blocked_reason': blockedReason,
      'max_players': maxPlayers,
    };

void main() {
  group('stateFromStatus', () {
    test('maps each known status', () {
      expect(stateFromStatus(kStatusBooked), SlotState.confirmed);
      expect(stateFromStatus(kStatusPending), SlotState.pending);
      expect(stateFromStatus(kStatusOwner), SlotState.owner);
      expect(stateFromStatus(kStatusBlocked), SlotState.locked);
      expect(stateFromStatus(kStatusMaintenance), SlotState.maintenance);
      expect(stateFromStatus(kStatusOpen), SlotState.empty);
    });

    test('unknown status falls back to empty', () {
      expect(stateFromStatus('something_new'), SlotState.empty);
    });
  });

  group('slotFromRow', () {
    test('maps ids, decimal hours, duration and weekday', () {
      final start = DateTime(2026, 6, 15, 18, 30); // Monday 18:30 local
      final slot = slotFromRow(_slotRow(
        startLocal: start,
        duration: const Duration(minutes: 90),
        status: kStatusBooked,
        maxPlayers: 4,
      ));

      expect(slot.id, 's1');
      expect(slot.venueId, 'c1');
      expect(slot.state, SlotState.confirmed);
      expect(slot.startHour, 18.5);
      expect(slot.durationHours, 1.5);
      expect(slot.weekday, start.weekday - 1);
      expect(slot.capacity, 4);
      // No customer yet → state-label fallback.
      expect(slot.label, kFallbackLabels[SlotState.confirmed]);
    });

    test('a locked slot uses its blocked_reason as the label', () {
      final slot = slotFromRow(_slotRow(
        startLocal: DateTime(2026, 6, 15, 8),
        duration: const Duration(hours: 1),
        status: kStatusBlocked,
        blockedReason: 'Bảo trì mặt sân',
      ));
      expect(slot.state, SlotState.locked);
      expect(slot.label, 'Bảo trì mặt sân');
    });

    test('a locked slot with no reason uses the fallback label', () {
      final slot = slotFromRow(_slotRow(
        startLocal: DateTime(2026, 6, 15, 8),
        duration: const Duration(hours: 1),
        status: kStatusBlocked,
      ));
      expect(slot.label, kFallbackLabels[SlotState.locked]);
    });
  });

  group('isActiveBooking', () {
    test('pending and confirmed are active', () {
      expect(isActiveBooking({'status': 'pending'}), isTrue);
      expect(isActiveBooking({'status': 'confirmed'}), isTrue);
    });
    test('anything else is inactive', () {
      expect(isActiveBooking({'status': 'completed'}), isFalse);
      expect(isActiveBooking({'status': 'cancelled'}), isFalse);
      expect(isActiveBooking(const {}), isFalse);
    });
  });

  group('applyBooking', () {
    final base = slotFromRow({
      'id': 's1',
      'court_id': 'c1',
      'start_at': DateTime(2026, 6, 15, 18).toUtc().toIso8601String(),
      'end_at': DateTime(2026, 6, 15, 19).toUtc().toIso8601String(),
      'status': kStatusBooked,
    });

    test('null booking leaves the slot unchanged', () {
      expect(applyBooking(base, null), same(base));
    });

    test('pending booking overrides the display state + relabels', () {
      final out = applyBooking(base, {'status': 'pending'});
      expect(out.state, SlotState.pending);
      expect(out.label, kFallbackLabels[SlotState.pending]);
    });

    test('customer name becomes the label; price taken from total_price', () {
      final out = applyBooking(base, {
        'status': 'confirmed',
        'customer_name': 'Anh Minh',
        'total_price': 240000,
      });
      expect(out.label, 'Anh Minh');
      expect(out.price, 240000);
    });

    test('non-positive or missing price stays null', () {
      expect(applyBooking(base, {'status': 'confirmed', 'price': 0}).price,
          isNull);
      expect(applyBooking(base, {'status': 'confirmed'}).price, isNull);
    });
  });

  group('venueFromCourt', () {
    test('maps name, palette colour, price and sport', () {
      final venue = venueFromCourt(
        {
          'id': 'c1',
          'name': 'Sân Pickleball A',
          'price_per_hour': 120000,
          'venues': [
            {'sport_type': 'Pickleball'},
          ],
        },
        0,
        openHour: 6,
        closeHour: 22,
      );
      expect(venue.id, 'c1');
      expect(venue.name, 'Sân Pickleball A');
      expect(venue.shortCode, 'SPA');
      expect(venue.sport, SportType.pickleball);
      expect(venue.sportLabel, 'Pickleball');
      expect(venue.colorValue, kPalette[0]);
      expect(venue.pricePerHour, 120000);
      expect(venue.openHour, 6);
      expect(venue.closeHour, 22);
    });

    test('palette wraps by index', () {
      final v = venueFromCourt({'id': 'x', 'name': 'A'}, kPalette.length);
      expect(v.colorValue, kPalette[0]);
    });
  });

  group('venueSportTypes', () {
    test('reads a list, a single map, dedups, and handles absence', () {
      expect(
        venueSportTypes([
          {'sport_type': 'Tennis'},
          {'sport_type': 'Tennis'},
          {'sport_type': 'Pickleball'},
        ]),
        ['Tennis', 'Pickleball'],
      );
      expect(venueSportTypes({'sport_type': 'Cầu lông'}), ['Cầu lông']);
      expect(venueSportTypes(null), isEmpty);
    });
  });

  group('sportFromLabels', () {
    test('classifies by keyword, defaulting to football', () {
      expect(sportFromLabels(['Pickleball']), SportType.pickleball);
      expect(sportFromLabels(['Tennis']), SportType.tennis);
      expect(sportFromLabels(['Bóng đá 5v5']), SportType.football);
      expect(sportFromLabels(const []), SportType.football);
    });
  });

  group('shortCode', () {
    test('initials / first two letters', () {
      expect(shortCode('Sân 1'), 'S1');
      expect(shortCode('Pickleball'), 'PI');
      expect(shortCode('Sân Trung Tâm Lớn'), 'STT'); // max 3 initials
      expect(shortCode('   '), '');
    });
  });

  group('asInt', () {
    test('rounds nums, rejects non-nums', () {
      expect(asInt(3), 3);
      expect(asInt(3.6), 4);
      expect(asInt('5'), isNull);
      expect(asInt(null), isNull);
    });
  });
}
