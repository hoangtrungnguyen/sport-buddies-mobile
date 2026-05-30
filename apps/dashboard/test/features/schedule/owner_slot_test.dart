import 'package:dashboard/features/schedule/model/owner_slot.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OwnerSlot.fromRow', () {
    test('maps the slots-row column contract', () {
      final slot = OwnerSlot.fromRow({
        'id': 's1',
        'court_id': 'c1',
        'start_at': '2026-05-14T19:00:00+07:00',
        'end_at': '2026-05-14T21:00:00+07:00',
        'status': 'owner',
      });

      expect(slot.id, 's1');
      expect(slot.courtId, 'c1');
      expect(slot.status, SlotStatus.owner);
      expect(slot.isOwnerSlot, isTrue);
      expect(slot.durationHours, 2.0);
    });

    test('defaults a missing status to open', () {
      final slot = OwnerSlot.fromRow({
        'id': 's2',
        'court_id': 'c1',
        'start_at': '2026-05-14T08:00:00Z',
        'end_at': '2026-05-14T09:30:00Z',
      });

      expect(slot.status, SlotStatus.open);
      expect(slot.isOwnerSlot, isFalse);
      expect(slot.isOpen, isTrue);
      expect(slot.durationHours, 1.5);
    });

    test('maps a blocked slot with its reason (OWNER-25)', () {
      final slot = OwnerSlot.fromRow({
        'id': 's3',
        'court_id': 'c1',
        'start_at': '2026-05-14T08:00:00Z',
        'end_at': '2026-05-14T09:00:00Z',
        'status': 'blocked',
        'blocked_reason': 'Bảo trì sân',
      });

      expect(slot.status, SlotStatus.blocked);
      expect(slot.isBlocked, isTrue);
      expect(slot.blockedReason, 'Bảo trì sân');
    });

    test('blocked_reason is null when absent', () {
      final slot = OwnerSlot.fromRow({
        'id': 's4',
        'court_id': 'c1',
        'start_at': '2026-05-14T08:00:00Z',
        'end_at': '2026-05-14T09:00:00Z',
        'status': 'blocked',
      });

      expect(slot.blockedReason, isNull);
    });
  });
}
