import 'package:dashboard/features/requests/model/booking_request.dart';
import 'package:dashboard/features/slot_detail/model/slot_player.dart';
import 'package:dashboard/features/slot_detail/slot_roster_logic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('paymentStatusFromRaw', () {
    test('maps known values, else unknown', () {
      expect(paymentStatusFromRaw('paid'), PaymentStatus.paid);
      expect(paymentStatusFromRaw('unpaid'), PaymentStatus.unpaid);
      expect(paymentStatusFromRaw('partial'), PaymentStatus.partial);
      expect(paymentStatusFromRaw('PAID'), PaymentStatus.paid);
      expect(paymentStatusFromRaw(null), PaymentStatus.unknown);
      expect(paymentStatusFromRaw('weird'), PaymentStatus.unknown);
    });
  });

  group('mergeSlotRoster', () {
    test('participant carries payment; matched booking gives status + name', () {
      final roster = mergeSlotRoster(
        participants: [
          {'id': 'p1', 'user_id': 'u1', 'payment_status': 'paid'},
        ],
        bookings: [
          {'id': 'b1', 'user_id': 'u1', 'status': 'confirmed', 'customer_name': 'An'},
        ],
      );
      expect(roster, hasLength(1));
      final p = roster.single;
      expect(p.id, 'p1');
      expect(p.name, 'An');
      expect(p.hasPaid, isTrue);
      expect(p.paymentStatus, PaymentStatus.paid);
      expect(p.bookingStatus, BookingStatus.confirmed);
    });

    test('a booking with no participant is still a player (payment unknown)',
        () {
      final roster = mergeSlotRoster(
        participants: const [],
        bookings: [
          {'id': 'b9', 'user_id': 'u9', 'status': 'pending', 'customer_name': 'Bình'},
        ],
      );
      expect(roster, hasLength(1));
      expect(roster.single.name, 'Bình');
      expect(roster.single.paymentStatus, PaymentStatus.unknown);
      expect(roster.single.hasPaid, isFalse);
      expect(roster.single.bookingStatus, BookingStatus.pending);
    });

    test('participant + standalone booking are not double-counted', () {
      final roster = mergeSlotRoster(
        participants: [
          {'id': 'p1', 'user_id': 'u1', 'payment_status': 'unpaid'},
        ],
        bookings: [
          {'id': 'b1', 'user_id': 'u1', 'status': 'confirmed', 'customer_name': 'An'},
          {'id': 'b2', 'user_id': 'u2', 'status': 'confirmed', 'customer_name': 'Chi'},
        ],
      );
      expect(roster.map((p) => p.name).toList(), ['An', 'Chi']);
      expect(roster.first.paymentStatus, PaymentStatus.unpaid);
      expect(roster.last.paymentStatus, PaymentStatus.unknown);
    });

    test('falls back to the anon name when neither profile nor walk-in name',
        () {
      final roster = mergeSlotRoster(
        participants: [
          {'id': 'p1', 'user_id': 'u1', 'payment_status': 'paid'},
        ],
        bookings: const [],
      );
      expect(roster.single.name, kAnonPlayerName);
      expect(roster.single.avatarUrl, isNull);
    });

    test('uses an embedded profile name/avatar when present (forward-compat)',
        () {
      final roster = mergeSlotRoster(
        participants: [
          {
            'id': 'p1',
            'user_id': 'u1',
            'payment_status': 'paid',
            'customers': {'full_name': 'Dũng', 'avatar_url': 'http://x/a.png'},
          },
        ],
        bookings: const [],
      );
      expect(roster.single.name, 'Dũng');
      expect(roster.single.avatarUrl, 'http://x/a.png');
    });
  });

  group('labels', () {
    test('playerCountLabel shows X/Y, or just X without capacity', () {
      expect(playerCountLabel(3, 4), '3/4 người chơi');
      expect(playerCountLabel(2, null), '2 người chơi');
      expect(playerCountLabel(2, 0), '2 người chơi');
    });

    test('paymentLabel localizes each status (unknown reads as missing data)',
        () {
      expect(paymentLabel(PaymentStatus.paid), 'Đã thanh toán');
      expect(paymentLabel(PaymentStatus.partial), 'Thanh toán một phần');
      expect(paymentLabel(PaymentStatus.unpaid), 'Chưa thanh toán');
      expect(paymentLabel(PaymentStatus.unknown), 'Chưa rõ');
    });
  });

  group('computePaymentSummary (OWNER-35)', () {
    test('sums collected + expected, counts paid/unpaid', () {
      final players = [
        SlotPlayer(id: '1', name: 'A', paymentStatus: PaymentStatus.paid,
            bookingStatus: BookingStatus.confirmed, expectedPrice: 100000),
        SlotPlayer(id: '2', name: 'B', paymentStatus: PaymentStatus.unpaid,
            bookingStatus: BookingStatus.confirmed, expectedPrice: 150000),
        SlotPlayer(id: '3', name: 'C', paymentStatus: PaymentStatus.partial,
            bookingStatus: BookingStatus.confirmed, expectedPrice: 80000),
      ];
      final s = computePaymentSummary(players);
      expect(s.totalCollected, 100000);
      expect(s.totalExpected, 330000);
      expect(s.paidCount, 1);
      expect(s.unpaidCount, 2); // unpaid + partial
    });

    test('empty roster returns all zeroes', () {
      final s = computePaymentSummary([]);
      expect(s.totalCollected, 0);
      expect(s.totalExpected, 0);
    });
  });

  group('paymentMethodLabel (OWNER-35)', () {
    test('localizes known methods', () {
      expect(paymentMethodLabel('cash'), 'Tiền mặt');
      expect(paymentMethodLabel('transfer'), 'Chuyển khoản');
      expect(paymentMethodLabel('app_wallet'), 'Ví ứng dụng');
      expect(paymentMethodLabel(null), '');
      expect(paymentMethodLabel('unknown'), '');
    });
  });

  group('mergeSlotRoster edge cases', () {
    test('multiple walk-ins sharing a user_id stay distinct rows', () {
      final roster = mergeSlotRoster(
        participants: const [],
        bookings: [
          {'id': 'b1', 'user_id': 'owner', 'status': 'confirmed', 'customer_name': 'An'},
          {'id': 'b2', 'user_id': 'owner', 'status': 'pending', 'customer_name': 'Bình'},
        ],
      );
      expect(roster.map((p) => p.name).toList(), ['An', 'Bình']); // not collapsed
    });

    test('a participant consumes one matching booking; the rest stay rows', () {
      final roster = mergeSlotRoster(
        participants: [
          {'id': 'p1', 'user_id': 'owner', 'payment_status': 'paid'},
        ],
        bookings: [
          {'id': 'b1', 'user_id': 'owner', 'status': 'confirmed', 'customer_name': 'An'},
          {'id': 'b2', 'user_id': 'owner', 'status': 'pending', 'customer_name': 'Bình'},
        ],
      );
      expect(roster, hasLength(2));
      expect(roster.first.paymentStatus, PaymentStatus.paid); // participant + b1
      expect(roster.first.name, 'An');
      expect(roster.last.paymentStatus, PaymentStatus.unknown); // leftover b2
      expect(roster.last.name, 'Bình');
    });

    test('duplicate participant rows for one user are de-duplicated', () {
      final roster = mergeSlotRoster(
        participants: [
          {'id': 'p1', 'user_id': 'u1', 'payment_status': 'paid'},
          {'id': 'p2', 'user_id': 'u1', 'payment_status': 'unpaid'},
        ],
        bookings: const [],
      );
      expect(roster, hasLength(1));
      expect(roster.single.paymentStatus, PaymentStatus.paid);
    });

    test('paymentMethod and expectedPrice are threaded through', () {
      final roster = mergeSlotRoster(
        participants: [
          {'id': 'p1', 'user_id': 'u1', 'payment_status': 'paid',
           'payment_method': 'cash'},
        ],
        bookings: [
          {'id': 'b1', 'user_id': 'u1', 'status': 'confirmed',
           'customer_name': 'An', 'total_price': 200000},
        ],
      );
      expect(roster.single.paymentMethod, 'cash');
      expect(roster.single.expectedPrice, 200000);
    });

    test('a completed booking reads as a confirmed badge, not pending', () {
      final roster = mergeSlotRoster(
        participants: const [],
        bookings: [
          {'id': 'b1', 'user_id': 'u1', 'status': 'completed', 'customer_name': 'An'},
        ],
      );
      expect(roster.single.bookingStatus, BookingStatus.confirmed);
    });
  });
}
