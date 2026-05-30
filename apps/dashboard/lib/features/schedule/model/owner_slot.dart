import 'package:freezed_annotation/freezed_annotation.dart';

part 'owner_slot.freezed.dart';

/// Slot lifecycle states as stored in `slots.status`.
///
/// The customer-facing slot picker only ever queries `status = 'open'`
/// (see `apps/customer/.../supabase_slot_repository.dart`), so **any** value
/// other than `open` is automatically hidden from players. That is what makes
/// [owner] (and [blocked]) block the time from customer booking for free —
/// no customer-app change is required (OWNER-81).
abstract final class SlotStatus {
  SlotStatus._();

  /// Bookable availability window (visible to customers).
  static const String open = 'open';

  /// A confirmed customer booking.
  static const String booked = 'booked';

  /// A booking awaiting owner approval.
  static const String pending = 'pending';

  /// Owner reserved the court for themselves — no payment, not customer
  /// bookable. The subject of OWNER-19.
  static const String owner = 'owner';

  /// Owner manually closed the time (OWNER-25 "Block a time slot").
  static const String blocked = 'blocked';

  /// Court is down for maintenance.
  static const String maintenance = 'maintenance';
}

/// A single time slot on a court, as seen by the **owner** dashboard.
///
/// Distinct from `spb_core`'s [Slot] (the customer read model) because the
/// owner needs the raw [status] — the customer model never exposes it since
/// its query is hard-filtered to `open`.
@freezed
abstract class OwnerSlot with _$OwnerSlot {
  const OwnerSlot._();

  const factory OwnerSlot({
    required String id,
    required String courtId,
    required DateTime startAt,
    required DateTime endAt,
    @Default(SlotStatus.open) String status,

    /// Owner-supplied reason shown on a blocked slot (OWNER-25). Maps to
    /// `slots.blocked_reason`; null unless [status] is [SlotStatus.blocked].
    String? blockedReason,
  }) = _OwnerSlot;

  /// True when this slot is the owner's own reservation (OWNER-19).
  bool get isOwnerSlot => status == SlotStatus.owner;

  /// True when the owner has manually closed this time (OWNER-25).
  bool get isBlocked => status == SlotStatus.blocked;

  /// True when this slot is bookable/free — the only state that can be blocked.
  bool get isOpen => status == SlotStatus.open;

  /// True when a customer has booked this time — must never be blocked.
  bool get isBooked => status == SlotStatus.booked;

  /// Length of the slot in (possibly fractional) hours — drives the calendar
  /// block height (1h == 56px in the design).
  double get durationHours => endAt.difference(startAt).inMinutes / 60.0;

  /// Maps a Supabase `slots` row to an [OwnerSlot].
  ///
  /// Column contract mirrors the verified customer read path:
  /// `id, court_id, start_at, end_at, status`. Named `fromRow` (not `fromJson`)
  /// so freezed does not try to wire `json_serializable`, which the dashboard
  /// does not depend on.
  factory OwnerSlot.fromRow(Map<String, dynamic> json) => OwnerSlot(
        id: json['id'] as String,
        courtId: json['court_id'] as String,
        startAt: DateTime.parse(json['start_at'] as String),
        endAt: DateTime.parse(json['end_at'] as String),
        status: json['status'] as String? ?? SlotStatus.open,
        blockedReason: json['blocked_reason'] as String?,
      );
}
