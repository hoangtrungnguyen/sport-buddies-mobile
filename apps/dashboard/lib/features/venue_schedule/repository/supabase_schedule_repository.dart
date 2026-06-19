import 'package:dashboard/core/debug/app_logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/models.dart';
import '../util/schedule_format.dart';
import 'schedule_api_client.dart';
import 'schedule_booking_reads.dart';
import 'schedule_mappers.dart';
import 'schedule_repository.dart';
import 'schedule_time_utils.dart';

/// Cached owner court: raw id + operating hours + the mapped [Venue].
typedef _OwnerCourt = ({String id, int openHour, int closeHour, Venue venue});


/// Production [ScheduleRepository] — real data only.
///
/// **READS are direct-to-Supabase** (this class' original contract, byte-for
/// byte unchanged); **WRITES go through the Django backend** via
/// [ScheduleApiClient], so role enforcement, overlap checks, slot restore on
/// cancellation and player notifications all stay server-side. The repository
/// performs ZERO direct INSERT/UPDATE/DELETE on `slots` / `bookings`.
///
/// **Venue = court (for now).** `slots` rows carry only `court_id` — there is
/// no `venue_id` yet (backend pending) — so the schedule's resources are the
/// authenticated owner's COURTS mapped 1:1 into the feature's [Venue] model:
/// Day-view columns are courts, Week view is one court × 7 days, and
/// `Slot.venueId` carries a `court_id`. When the backend adds `slots.venue_id`
/// only this repository needs to change — no UI rework.
///
/// Column contracts mirror the verified repositories:
/// - `slots(id, court_id, start_at, end_at, status, blocked_reason,
///   max_players)`; the write endpoints
///   return the same columns, so API responses reuse [slotFromRow].
/// - `courts(id, name, operating_hours, price_per_hour)` + embedded
///   `venues(sport_type)` — `OwnerCourtRepository` / the requests read path.
/// - `bookings` rows are selected as `*` and parsed defensively, like
///   `BookingRequest.fromRow` (the exact bookings column set is not pinned).
///
/// Anything the DB cannot answer (players joined, payment status, booking
/// code) stays null so the UI hides the row — values are never fabricated.
class SupabaseScheduleRepository implements ScheduleRepository {
  SupabaseScheduleRepository(this._client, this._api);

  /// Reads only — venues/slots/bookings selects (never mutations).
  final SupabaseClient _client;

  /// All mutations — slot create/block/unblock + booking status transitions.
  final ScheduleApiClient _api;

  static const _slotCols =
      'id, court_id, start_at, end_at, status, blocked_reason, max_players';

  /// `price_per_hour` and the embedded `venues(sport_type)` are already read
  /// by the requests feature (`SupabaseBookingRequestRepository`), so both
  /// relations are known-good.
  static const _courtCols =
      'id, name, operating_hours, price_per_hour, venues(sport_type)';


  /// Owner courts, fetched once and reused by the read paths (`getVenues`
  /// refreshes it on every screen load). Keyed by [_courtsCacheUid] — the
  /// repository is a lazy singleton, so a cache built for one owner must be
  /// discarded when another signs in within the same app session.
  List<_OwnerCourt>? _courtsCache;

  /// `auth.uid()` the cache was built for (see [_courtsCache]).
  String? _courtsCacheUid;


  // ---------------------------------------------------------------------------
  // Reads
  // ---------------------------------------------------------------------------

  @override
  Future<List<ScheduleCourt>> getCourts() async {
    try {
      final courts = await _ownerCourts(refresh: true);
      return [
        for (final c in courts) ScheduleCourt(id: c.id, name: c.venue.name),
      ];
    } on ScheduleRepositoryException {
      rethrow;
    } catch (e, st) {
      appLogger.e('SupabaseScheduleRepository.getCourts',
          error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<List<Venue>> getVenues(String courtId) async {
    try {
      // Refresh the cache on every screen load so newly created courts show.
      final courts = await _ownerCourts(refresh: true);
      return [for (final c in courts) c.venue];
    } on ScheduleRepositoryException {
      rethrow;
    } catch (e, st) {
      appLogger.e('SupabaseScheduleRepository.getVenues',
          error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<List<Slot>> getDaySlots(String courtId, DateTime day) async {
    try {
      final courts = await _ownerCourts();
      if (courts.isEmpty) return const [];
      final start = DateTime(day.year, day.month, day.day);
      final end = start.add(const Duration(days: 1));
      final rows = await _client
          .from('slots')
          .select(_slotCols)
          .inFilter('court_id', [for (final c in courts) c.id])
          .gte('start_at', start.toUtc().toIso8601String())
          .lt('start_at', end.toUtc().toIso8601String())
          .order('start_at');
      return enrichSlotsFromBookings(_client, [
        for (final r in rows as List)
          slotFromRow((r as Map).cast<String, dynamic>()),
      ]);
    } on ScheduleRepositoryException {
      rethrow;
    } catch (e, st) {
      appLogger.e('SupabaseScheduleRepository.getDaySlots',
          error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<List<Slot>> getWeekSlots(String venueId, DateTime weekStart) async {
    try {
      final start = mondayOf(weekStart);
      final end = start.add(const Duration(days: 7));
      // `venueId` IS a court id (see class doc) — one court × 7 days.
      final rows = await _client
          .from('slots')
          .select(_slotCols)
          .eq('court_id', venueId)
          .gte('start_at', start.toUtc().toIso8601String())
          .lt('start_at', end.toUtc().toIso8601String())
          .order('start_at');
      return enrichSlotsFromBookings(_client, [
        for (final r in rows as List)
          slotFromRow((r as Map).cast<String, dynamic>()),
      ]);
    } on ScheduleRepositoryException {
      rethrow;
    } catch (e, st) {
      appLogger.e('SupabaseScheduleRepository.getWeekSlots',
          error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<List<OccupancyDay>> getMonthOccupancy(
      String courtId, DateTime month) async {
    try {
      final courts = await _ownerCourts();
      final today = DateTime.now();
      final first = DateTime(month.year, month.month);
      final lastDay = DateTime(month.year, month.month + 1, 0);
      final gridStart = mondayOf(first);
      // Full weeks: Monday on/before the 1st → Sunday on/after the last day.
      final totalDays = lastDay.difference(gridStart).inDays + 1;
      final cellCount = ((totalDays + 6) ~/ 7) * 7;
      final gridEnd = DateTime(
          gridStart.year, gridStart.month, gridStart.day + cellCount);

      // One query: customer-occupied slots (booked/pending) of every owner
      // court across the whole visible grid.
      final busyHours = <String, double>{};
      final bookings = <String, int>{};
      if (courts.isNotEmpty) {
        final rows = await _client
            .from('slots')
            .select('court_id, start_at, end_at, status')
            .inFilter('court_id', [for (final c in courts) c.id])
            .inFilter('status', const [kStatusBooked, kStatusPending])
            .gte('start_at', gridStart.toUtc().toIso8601String())
            .lt('start_at', gridEnd.toUtc().toIso8601String());
        for (final r in rows as List) {
          final row = (r as Map).cast<String, dynamic>();
          final start = DateTime.parse(row['start_at'] as String).toLocal();
          final end = DateTime.parse(row['end_at'] as String).toLocal();
          final key = dayKey(start);
          busyHours[key] =
              (busyHours[key] ?? 0) + end.difference(start).inMinutes / 60.0;
          bookings[key] = (bookings[key] ?? 0) + 1;
        }
      }

      // Denominator: the summed daily operating window of all courts, parsed
      // from `courts.operating_hours` jsonb; 16h (06–22) when unusable.
      var operatingHours = 0.0;
      for (final c in courts) {
        final span = c.closeHour - c.openHour;
        operatingHours += span > 0 ? span : 16;
      }

      return List.generate(cellCount, (i) {
        final date =
            DateTime(gridStart.year, gridStart.month, gridStart.day + i);
        final inMonth = date.month == month.month && date.year == month.year;
        final key = dayKey(date);
        final occ = (!inMonth || operatingHours == 0)
            ? 0.0
            : ((busyHours[key] ?? 0) / operatingHours).clamp(0.0, 1.0);
        return OccupancyDay(
          date: date,
          occupancy: occ,
          bookings: inMonth ? (bookings[key] ?? 0) : 0,
          // Revenue needs a verified per-booking price column; the Month view
          // renders no revenue today — report 0 rather than a fabricated sum.
          revenue: 0,
          isToday: date.year == today.year &&
              date.month == today.month &&
              date.day == today.day,
          isCurrentMonth: inMonth,
        );
      });
    } on ScheduleRepositoryException {
      rethrow;
    } catch (e, st) {
      appLogger.e('SupabaseScheduleRepository.getMonthOccupancy',
          error: e, stackTrace: st);
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Mutations — all writes delegate to the backend API (`ScheduleApiClient`);
  // this class never INSERTs/UPDATEs `slots` or `bookings` directly.
  // ---------------------------------------------------------------------------

  @override
  Future<Slot> createSlot(CreateSlotRequest req) async {
    // Defensive: the create sheet only offers "Slot trống" while matchmaking
    // / private slots have no DB representation (see kMatchmakingEnabled).
    if (req.slotType != SlotState.empty) {
      throw ScheduleRepositoryException(
          'Loại slot này chưa được hỗ trợ trên dữ liệu thật.');
    }
    try {
      final date = resolveDate(req.date, req.weekday);
      // `POST /api/courts/slots`, status defaults to 'open' server-side.
      final created = await _api.createSlot(
        courtId: req.venueId,
        startAt: atHour(date, req.startHour),
        endAt: atHour(date, req.endHour),
      );
      return slotFromRow(created.json);
    } on ScheduleRepositoryException {
      rethrow;
    } catch (e, st) {
      appLogger.e('SupabaseScheduleRepository.createSlot',
          error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<int> createRecurringSlots(
    CreateSlotRequest req,
    List<int> weekdays,
    int weeks,
  ) async {
    // Same guard as createSlot — recurrence only generates "Slot trống".
    if (req.slotType != SlotState.empty) {
      throw ScheduleRepositoryException(
          'Loại slot này chưa được hỗ trợ trên dữ liệu thật.');
    }
    try {
      // Server-side batches: `POST /api/courts/{id}/recurrence`. The endpoint
      // expects UTC weekday keys / HH:MM times / YYYY-MM-DD dates, so the local
      // wall-clock session is planned into UTC windows up front (day-shift,
      // boundary guards and ≤90-day chunking all live in [planRecurrence]).
      final plan = planRecurrence(
        anchorWeek: mondayOf(resolveDate(req.date, req.weekday)),
        startHour: req.startHour,
        endHour: req.endHour,
        weekdays: weekdays,
        weeks: weeks,
        now: DateTime.now(),
      );

      // Windows are POSTed in sequence — non-atomic, like the legacy per-session
      // loop: a mid-batch failure keeps what earlier windows created and
      // surfaces a partial-summary rejection; the bloc refreshes the grid so the
      // created slots show.
      var createdTotal = 0;
      for (final window in plan.windows) {
        final ApiRecurrenceResult result;
        try {
          result = await _api.createRecurringSlots(
            courtId: req.venueId,
            daysOfWeek: plan.daysOfWeek,
            startTime: plan.startTime,
            endTime: plan.endTime,
            fromDate: window.fromDate,
            untilDate: window.untilDate,
          );
        } on ScheduleRepositoryException catch (e) {
          if (createdTotal == 0) rethrow;
          throw ScheduleRepositoryException(
              'Chỉ tạo được $createdTotal slot — ${e.message}');
        }
        createdTotal += result.created;
      }

      // The server silently skips overlapping / out-of-hours occurrences;
      // `created` (the response's REQUIRED field) is the real insert count
      // shown in the success toast — never the optional echoed slot array,
      // which a schema-conformant backend may omit.
      if (createdTotal == 0) {
        throw ScheduleRepositoryException(
            'Không tạo được slot nào — các phiên bị trùng hoặc ngoài giờ '
            'hoạt động.');
      }
      return createdTotal;
    } on RecurrencePlanException catch (e) {
      // Pure-planning reject (elapsed window / unexpressible UTC-boundary
      // session) → user-facing recoverable rejection.
      throw ScheduleRepositoryException(e.message);
    } on ScheduleRepositoryException {
      rethrow;
    } catch (e, st) {
      appLogger.e('SupabaseScheduleRepository.createRecurringSlots',
          error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<void> blockTime(BlockTimeRequest req) async {
    try {
      final date = resolveDate(req.date, req.weekday);
      final startAt = atHour(date, req.startHour);
      final endAt = atHour(date, req.endHour);
      final note = req.note?.trim();
      final kindStatus = _kindStatusFor(req.blockType);

      final overlaps = await _overlappingSlots(req.venueId, startAt, endAt);
      _assertBlockable(overlaps, startAt, endAt);

      // Flip overlapping OPEN slots via `PATCH .../block` (one call per slot)
      // with the exact kind status; the owner's note (when any) is the stored
      // reason. A slot booked between the read and the PATCH surfaces as the
      // endpoint's 409 — the race guard, enforced atomically server-side.
      //
      // NOTE: this fan-out (one read + N block PATCHes + M creates below,
      // sequential, multiplied by the bloc's recurring-block loop) is
      // NON-ATOMIC: a mid-loop failure leaves the range half-blocked.
      // Mitigated by the bloc's rejection toast + grid refresh; a server-side
      // batch block endpoint would remove the window entirely.
      for (final r in overlaps) {
        if (r['status'] != kStatusOpen) continue;
        await _api.blockSlot(
          r['id'] as String,
          status: kindStatus,
          blockedReason: note,
        );
      }

      // Create block slots over the sub-ranges no existing slot covers, so
      // the whole requested range reads as blocked on the grid. Gap rows keep
      // their exact status via the create `status` field ('owner' implies
      // `is_owner_slot` server-side) and carry the note verbatim.
      for (final gap in uncoveredRanges(startAt, endAt, overlaps)) {
        await _api.createSlot(
          courtId: req.venueId,
          startAt: gap.start,
          endAt: gap.end,
          status: kindStatus,
          blockedReason: note,
        );
      }
    } on ScheduleRepositoryException {
      rethrow;
    } catch (e, st) {
      appLogger.e('SupabaseScheduleRepository.blockTime',
          error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Block-endpoint status for a block kind — `{blocked, maintenance, owner}`
  /// (default blocked), so every row keeps its true kind.
  String _kindStatusFor(SlotState blockType) => switch (blockType) {
        SlotState.maintenance => kStatusMaintenance,
        SlotState.owner => kStatusOwner,
        _ => kStatusBlocked,
      };

  /// READ (direct DB): every slot overlapping `[startAt, endAt)` on this
  /// court, any status.
  Future<List<Map<String, dynamic>>> _overlappingSlots(
    String venueId,
    DateTime startAt,
    DateTime endAt,
  ) async {
    final rows = await _client
        .from('slots')
        .select(_slotCols)
        .eq('court_id', venueId)
        .lt('start_at', endAt.toUtc().toIso8601String())
        .gt('end_at', startAt.toUtc().toIso8601String());
    return [for (final r in rows as List) (r as Map).cast<String, dynamic>()];
  }

  /// Pre-flight guards for a block over `[startAt, endAt)`, both enforced
  /// client-side before any write so the UI shows a reason:
  /// - never block over a customer booking (the backend's own 409 only fires
  ///   per 'booked' slot; 'pending' rides on slots already marked 'booked');
  /// - never flip an OPEN slot that only partially overlaps — a status flip
  ///   can't split a row, so it would silently block unselected hours.
  void _assertBlockable(
    List<Map<String, dynamic>> overlaps,
    DateTime startAt,
    DateTime endAt,
  ) {
    if (overlaps.any((r) =>
        r['status'] == kStatusBooked || r['status'] == kStatusPending)) {
      throw ScheduleRepositoryException(
          'Khung giờ này có lịch đã đặt hoặc chờ duyệt — không thể khoá.');
    }
    for (final r in overlaps) {
      if (r['status'] != kStatusOpen) continue;
      final s = DateTime.parse(r['start_at'] as String).toLocal();
      final e = DateTime.parse(r['end_at'] as String).toLocal();
      if (s.isBefore(startAt) || e.isAfter(endAt)) {
        throw ScheduleRepositoryException(
            'Khung giờ chồng một phần slot trống '
            '${hourLabel(s.hour + s.minute / 60.0)}–'
            '${hourLabel(e.hour + e.minute / 60.0)} — '
            'hãy chọn trùng ranh giới slot.');
      }
    }
  }

  @override
  Future<Slot> approveSlot(String slotId) async {
    try {
      // READ: resolve the pending bookings row behind the slot.
      final bookingId = await pendingBookingIdForSlot(_client, slotId);
      // pending→confirmed via `PATCH /api/bookings/{id}/status`. A 409
      // (the request moved on between the lookup and the call) surfaces with
      // the same wording as the lookup miss — predictable, recoverable.
      await _api.updateBookingStatus(
        bookingId: bookingId,
        status: 'confirmed',
        conflictMessage:
            'Không tìm thấy yêu cầu chờ duyệt cho slot này — hãy tải lại lịch.',
      );
      // READ BACK: the slot (already 'booked' since the booking INSERT
      // trigger) + booking enrichment, so the UI gets the confirmed state.
      // `maybeSingle` (like cancelSlot): the approval SUCCEEDED — a row
      // vanished/RLS-hidden between the call and this read must surface as
      // a predictable "reload" rejection, not a full-screen failure.
      final row = await _client
          .from('slots')
          .select(_slotCols)
          .eq('id', slotId)
          .maybeSingle();
      if (row == null) {
        throw ScheduleRepositoryException(
            'Đã duyệt yêu cầu, nhưng slot không còn hiển thị — hãy tải lại '
            'lịch.');
      }
      final refreshed = await enrichSlotsFromBookings(
          _client, [slotFromRow(row)]);
      return refreshed.first;
    } on ScheduleRepositoryException {
      rethrow;
    } catch (e, st) {
      appLogger.e('SupabaseScheduleRepository.approveSlot',
          error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<void> rejectSlot(String slotId) async {
    try {
      // READ: resolve the pending bookings row behind the slot.
      final bookingId = await pendingBookingIdForSlot(_client, slotId);
      // pending→cancelled; the SERVER restores the linked slot to 'open'
      // itself (verified live) — no client-side slot write.
      await _api.updateBookingStatus(
        bookingId: bookingId,
        status: 'cancelled',
        conflictMessage:
            'Không tìm thấy yêu cầu chờ duyệt cho slot này — hãy tải lại lịch.',
      );
    } on ScheduleRepositoryException {
      rethrow;
    } catch (e, st) {
      appLogger.e('SupabaseScheduleRepository.rejectSlot',
          error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<void> cancelSlot(String slotId) async {
    try {
      // READ: current status decides which endpoint applies.
      final row = await _client
          .from('slots')
          .select(_slotCols)
          .eq('id', slotId)
          .maybeSingle();
      if (row == null) {
        throw ScheduleRepositoryException('Slot không còn tồn tại.');
      }
      switch (row['status'] as String? ?? kStatusOpen) {
        case kStatusBlocked || kStatusOwner || kStatusMaintenance:
          // "Mở khoá giờ này" — `PATCH .../unblock` restores 'open' and
          // clears the reason (accepts any non-booked status; verified live).
          await _api.unblockSlot(slotId);
        case kStatusBooked || kStatusPending:
          // "Huỷ" a booking: resolve the active bookings row (READ), then
          // pending/confirmed→cancelled. The SERVER restores the slot to
          // 'open' itself (verified live) — the legacy manual slot-restore
          // write is gone.
          final bookingId = await activeBookingIdForSlot(_client, slotId);
          await _api.updateBookingStatus(
            bookingId: bookingId,
            status: 'cancelled',
            conflictMessage: 'Slot đã đổi trạng thái — hãy tải lại lịch.',
          );
        default:
          // Already open — nothing to cancel.
          return;
      }
    } on ScheduleRepositoryException {
      rethrow;
    } catch (e, st) {
      appLogger.e('SupabaseScheduleRepository.cancelSlot',
          error: e, stackTrace: st);
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Courts → venues
  // ---------------------------------------------------------------------------

  /// The authenticated owner's active courts (cached). Query mirrors
  /// `OwnerCourtRepository.getCourts`.
  Future<List<_OwnerCourt>> _ownerCourts({bool refresh = false}) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) {
      throw ScheduleRepositoryException(
          'Chưa đăng nhập — không thể tải lịch sân.');
    }
    final cached = _courtsCache;
    // A cache built for a different owner is stale, never reusable — RLS
    // would silently return empty slot lists for its court ids.
    if (!refresh && cached != null && _courtsCacheUid == uid) return cached;
    final rows = await _client
        .from('courts')
        .select(_courtCols)
        .eq('owner_id', uid)
        .neq('status', 'inactive')
        .order('name');
    final courts = <_OwnerCourt>[];
    for (final r in rows as List) {
      final row = (r as Map).cast<String, dynamic>();
      final openHour =
          ((row['operating_hours'] as Map<String, dynamic>?)?['open'] as num?)
              ?.toInt();
      final closeHour =
          ((row['operating_hours'] as Map<String, dynamic>?)?['close'] as num?)
              ?.toInt();
      courts.add((
        id: row['id'] as String,
        openHour: openHour ?? 6,
        closeHour: closeHour ?? 22,
        venue: venueFromCourt(
          row,
          courts.length,
          openHour: openHour,
          closeHour: closeHour,
        ),
      ));
    }
    _courtsCache = courts;
    _courtsCacheUid = uid;
    return courts;
  }
}
