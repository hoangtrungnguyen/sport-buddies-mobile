import 'package:dashboard/core/debug/app_logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/models.dart';
import 'schedule_mappers.dart';
import 'schedule_repository.dart';

/// Direct-to-Supabase `bookings` reads for the schedule repository: slot
/// label/price enrichment + the booking-id lookups behind approve / reject /
/// cancel. Extracted from `SupabaseScheduleRepository` — read-only, never
/// mutates, and depends only on the [SupabaseClient] + the pure mappers, so
/// the bookings-read rules live in one testable place.

/// Batched label/price enrichment for booked/pending slots: ONE `bookings`
/// query per page load (never per slot). Fills the customer name as the
/// block label and an explicit positive total as the price; both stay
/// state-label / null when the row carries neither.
///
/// Also the authoritative pending detection: the slot-sync trigger marks a
/// slot `booked` on booking INSERT while the booking itself is still
/// `pending` (see [stateFromStatus]), so the display state is overridden
/// from the resolved booking row — without this every awaiting-approval
/// booking would render as "Đã đặt" and approve/reject would be dead.
Future<List<Slot>> enrichSlotsFromBookings(
  SupabaseClient client,
  List<Slot> slots,
) async {
  final ids = [
    for (final s in slots)
      if (s.state == SlotState.confirmed || s.state == SlotState.pending)
        s.id,
  ];
  if (ids.isEmpty) return slots;
  try {
    // Newest first: a re-opened, re-booked slot can carry several
    // non-cancelled rows (e.g. an old 'completed' one) — the current
    // booking is the newest, mirroring the customer payment lookup
    // (`order created_at desc, limit 1`).
    final rows = await client
        .from('bookings')
        .select('*')
        .inFilter('slot_id', ids)
        .neq('status', 'cancelled')
        .order('created_at', ascending: false);
    final bySlot = <String, Map<String, dynamic>>{};
    for (final r in rows as List) {
      final row = (r as Map).cast<String, dynamic>();
      final slotId = row['slot_id']?.toString();
      if (slotId == null) continue;
      final kept = bySlot[slotId];
      // First (= newest) row wins; an active pending/confirmed row beats
      // an inactive (completed) one regardless of age.
      if (kept == null || (!isActiveBooking(kept) && isActiveBooking(row))) {
        bySlot[slotId] = row;
      }
    }
    return [for (final s in slots) applyBooking(s, bySlot[s.id])];
  } catch (e, st) {
    // Enrichment is decoration only — a failure here (e.g. RLS on
    // bookings) must not blank the whole calendar. Logged, then the
    // un-enriched (still real) slots are returned.
    appLogger.e('enrichSlotsFromBookings', error: e, stackTrace: st);
    return slots;
  }
}

/// Resolves the pending bookings row behind a pending slot. Throws a
/// [ScheduleRepositoryException] when none exists (already handled, or the
/// trigger/RLS hid it) so the UI shows a reason instead of a silent no-op.
Future<String> pendingBookingIdForSlot(
  SupabaseClient client,
  String slotId,
) async {
  final rows = await client
      .from('bookings')
      .select('id')
      .eq('slot_id', slotId)
      .eq('status', 'pending')
      // Deterministic under multiple pending rows: act on the newest.
      .order('created_at', ascending: false)
      .limit(1);
  if ((rows as List).isEmpty) {
    throw ScheduleRepositoryException(
        'Không tìm thấy yêu cầu chờ duyệt cho slot này — hãy tải lại lịch.');
  }
  return (rows.first as Map)['id'].toString();
}

/// Resolves the live (pending/confirmed) bookings row behind a booked slot
/// for cancel — same shape as [pendingBookingIdForSlot], same wording as the
/// legacy guarded cancel when nothing is active.
Future<String> activeBookingIdForSlot(
  SupabaseClient client,
  String slotId,
) async {
  final rows = await client
      .from('bookings')
      .select('id')
      .eq('slot_id', slotId)
      .inFilter('status', const ['pending', 'confirmed'])
      // Deterministic under multiple rows: act on the newest.
      .order('created_at', ascending: false)
      .limit(1);
  if ((rows as List).isEmpty) {
    throw ScheduleRepositoryException(
        'Không tìm thấy lượt đặt đang hoạt động cho slot này.');
  }
  return (rows.first as Map)['id'].toString();
}
