// Pure, framework-free helpers for the slot player roster (OWNER-33).
//
// Merges raw `slot_participants` + `bookings` rows into a [SlotPlayer] list and
// formats the count/labels — unit-testable without Supabase or Flutter.

import '../requests/model/booking_request.dart';
import 'model/slot_player.dart';

/// Fallback name when neither a walk-in name nor a (RLS-readable) profile name
/// is available for a player.
const String kAnonPlayerName = 'Người chơi';

/// Merges a slot's `slot_participants` rows with its non-cancelled `bookings`
/// rows into a roster, keyed by `user_id`:
/// - a participant carries the real `payment_status`; its booking (matched by
///   `user_id`) supplies the booking-status badge + walk-in name;
/// - a booking with no matching participant is still a player (payment
///   [PaymentStatus.unknown]).
///
/// Profile name/avatar are read from an embedded `customers`/`profiles` map
/// **when present** (forward-compatible once owner RLS allows it); today they
/// are absent, so names fall back to the booking's `customer_name`, then
/// [kAnonPlayerName].
List<SlotPlayer> mergeSlotRoster({
  required List<Map<String, dynamic>> participants,
  required List<Map<String, dynamic>> bookings,
}) {
  // Bookings queued per user_id so a participant consumes exactly one (multiple
  // walk-ins sharing a user_id each stay a distinct player rather than
  // collapsing). `consumed` tracks the exact booking rows a participant paired
  // with, by identity.
  final bookingsByUser = <String, List<Map<String, dynamic>>>{};
  for (final b in bookings) {
    final uid = b['user_id']?.toString();
    if (uid != null) bookingsByUser.putIfAbsent(uid, () => []).add(b);
  }

  final players = <SlotPlayer>[];
  final seenParticipants = <String>{};
  final consumed = <Map<String, dynamic>>{}; // identity set

  for (final p in participants) {
    final uid = p['user_id']?.toString();
    // De-dup duplicate participant rows for the same user.
    if (uid != null && !seenParticipants.add(uid)) continue;
    Map<String, dynamic>? booking;
    final queue = uid != null ? bookingsByUser[uid] : null;
    if (queue != null && queue.isNotEmpty) {
      booking = queue.removeAt(0);
      consumed.add(booking);
    }
    players.add(SlotPlayer(
      id: p['id']?.toString() ?? uid ?? 'p${players.length}',
      userId: uid,
      name: _name(profile: _profileOf(p), booking: booking),
      avatarUrl: _avatar(_profileOf(p)),
      bookingStatus: booking != null
          ? bookingStatusFromRaw(booking['status'] as String?)
          : null,
      paymentStatus: paymentStatusFromRaw(p['payment_status'] as String?),
      paymentMethod: (p['payment_method'] as String?)?.trim().isNotEmpty == true
          ? p['payment_method'] as String
          : null,
      expectedPrice: _asInt(booking?['total_price']),
    ));
  }

  // Every booking not paired with a participant is its own player row.
  for (final b in bookings) {
    if (consumed.contains(b)) continue;
    players.add(SlotPlayer(
      id: b['id']?.toString() ?? b['user_id']?.toString() ?? 'b${players.length}',
      userId: b['user_id']?.toString(),
      name: _name(profile: _profileOf(b), booking: b),
      avatarUrl: _avatar(_profileOf(b)),
      bookingStatus: bookingStatusFromRaw(b['status'] as String?),
      paymentStatus: PaymentStatus.unknown,
      expectedPrice: _asInt(b['total_price']),
    ));
  }

  return players;
}

int? _asInt(Object? v) => v is num ? v.round() : null;

Map<String, dynamic>? _profileOf(Map<String, dynamic> row) {
  final p = row['customers'] ?? row['profiles'];
  return p is Map ? p.cast<String, dynamic>() : null;
}

String _name({Map<String, dynamic>? profile, Map<String, dynamic>? booking}) {
  final full = (profile?['full_name'] as String?)?.trim();
  if (full != null && full.isNotEmpty) return full;
  final cn = (booking?['customer_name'] as String?)?.trim();
  if (cn != null && cn.isNotEmpty) return cn;
  return kAnonPlayerName;
}

String? _avatar(Map<String, dynamic>? profile) {
  final a = (profile?['avatar_url'] as String?)?.trim();
  return (a != null && a.isNotEmpty) ? a : null;
}

/// "3/4 người chơi" when capacity is known, else "3 người chơi".
String playerCountLabel(int count, int? capacity) =>
    (capacity != null && capacity > 0)
        ? '$count/$capacity người chơi'
        : '$count người chơi';

/// Known payment method values from `slot_participants.payment_method`.
const String kPayCash = 'cash';
const String kPayTransfer = 'transfer';
const String kPayWallet = 'app_wallet';

/// Localized display name for a payment method string (AC#4).
String paymentMethodLabel(String? method) => switch ((method ?? '').trim().toLowerCase()) {
      kPayCash => 'Tiền mặt',
      kPayTransfer => 'Chuyển khoản',
      kPayWallet => 'Ví ứng dụng',
      _ => '',
    };

/// Payment summary for the slot (AC#2).
class PaymentSummary {
  const PaymentSummary({
    required this.totalCollected,
    required this.totalExpected,
    required this.paidCount,
    required this.unpaidCount,
  });
  final int totalCollected; // sum of expectedPrice for paid players
  final int totalExpected; // sum of all expectedPrice (non-null)
  final int paidCount;
  final int unpaidCount; // pending or partial
}

/// Computes the payment summary from the player roster.
PaymentSummary computePaymentSummary(List<SlotPlayer> players) {
  var collected = 0;
  var expected = 0;
  var paid = 0;
  var unpaid = 0;
  for (final p in players) {
    final price = p.expectedPrice ?? 0;
    expected += price;
    if (p.hasPaid) {
      collected += price;
      paid++;
    } else {
      unpaid++;
    }
  }
  return PaymentSummary(
    totalCollected: collected,
    totalExpected: expected,
    paidCount: paid,
    unpaidCount: unpaid,
  );
}

/// Localized payment label for a chip. [unknown] reads as missing data
/// ("Chưa rõ") rather than a confirmed unpaid state — a booking-only player has
/// no participant payment row.
String paymentLabel(PaymentStatus status) => switch (status) {
      PaymentStatus.paid => 'Đã thanh toán',
      PaymentStatus.partial => 'Thanh toán một phần',
      PaymentStatus.unpaid => 'Chưa thanh toán',
      PaymentStatus.unknown => 'Chưa rõ',
    };
