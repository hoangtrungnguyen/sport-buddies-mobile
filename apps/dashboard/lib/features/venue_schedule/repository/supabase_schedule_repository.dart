import 'package:dashboard/core/debug/app_logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/models.dart';
import '../util/schedule_format.dart';
import 'schedule_api_client.dart';
import 'schedule_repository.dart';

/// Cached owner court: raw id + operating hours + the mapped [Venue].
typedef _OwnerCourt = ({String id, int openHour, int closeHour, Venue venue});

/// A `[start, end)` datetime range (local) — used by the block-gap math.
typedef _Range = ({DateTime start, DateTime end});

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
///   max_players)` — `SupabaseOwnerSlotRepository`; the write endpoints
///   return the same columns, so API responses reuse [_slotFromRow].
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

  /// Venue dot palette (design handoff) — assigned to courts by stable index
  /// (courts are ordered by name, so the colour is consistent across loads).
  static const List<int> _palette = [
    0xFF16A34A,
    0xFF0EA5E9,
    0xFFF97316,
    0xFFA855F7,
    0xFFEC4899,
  ];

  /// Owner courts, fetched once and reused by the read paths (`getVenues`
  /// refreshes it on every screen load). Keyed by [_courtsCacheUid] — the
  /// repository is a lazy singleton, so a cache built for one owner must be
  /// discarded when another signs in within the same app session.
  List<_OwnerCourt>? _courtsCache;

  /// `auth.uid()` the cache was built for (see [_courtsCache]).
  String? _courtsCacheUid;

  // ---------------------------------------------------------------------------
  // slots.status ↔ SlotState mapping
  // ---------------------------------------------------------------------------

  /// `slots.status` literals (Postgres enum:
  /// `open | booked | pending | owner | blocked | maintenance`).
  static const _statusOpen = 'open';
  static const _statusBooked = 'booked';
  static const _statusPending = 'pending';
  static const _statusOwner = 'owner';
  static const _statusBlocked = 'blocked';
  static const _statusMaintenance = 'maintenance';

  /// DB → display state. `fixed`/`open`/`private` never occur from real data
  /// (no DB representation yet — see [kMatchmakingEnabled]).
  ///
  /// NOTE: the slot-sync trigger (`trg_sync_slot_status_from_booking`,
  /// snb-backend-core migration 0017) marks a slot `booked` as soon as a
  /// booking is INSERTED — even while the booking is still pending — so a
  /// literal `pending` slot status is not expected from the backend. The
  /// mapping keeps the branch defensively; the authoritative pending
  /// detection happens in [_applyBooking] from `bookings.status`.
  static SlotState _stateFromStatus(String status) => switch (status) {
        _statusBooked => SlotState.confirmed,
        _statusPending => SlotState.pending,
        _statusOwner => SlotState.owner,
        _statusBlocked => SlotState.locked,
        _statusMaintenance => SlotState.maintenance,
        _ => SlotState.empty, // 'open' — bookable, no customer yet
      };

  /// Vietnamese state-label fallback when no real customer name exists —
  /// same vocabulary as the legacy schedule screen; never a fabricated name.
  static const Map<SlotState, String> _fallbackLabels = {
    SlotState.empty: 'Slot trống',
    SlotState.confirmed: 'Đã đặt',
    SlotState.pending: 'Chờ duyệt',
    SlotState.owner: 'Sân của tôi',
    SlotState.maintenance: 'Bảo trì',
    SlotState.locked: 'Đã khoá',
  };

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
      return _enrichFromBookings([
        for (final r in rows as List)
          _slotFromRow((r as Map).cast<String, dynamic>()),
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
      return _enrichFromBookings([
        for (final r in rows as List)
          _slotFromRow((r as Map).cast<String, dynamic>()),
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
            .inFilter('status', const [_statusBooked, _statusPending])
            .gte('start_at', gridStart.toUtc().toIso8601String())
            .lt('start_at', gridEnd.toUtc().toIso8601String());
        for (final r in rows as List) {
          final row = (r as Map).cast<String, dynamic>();
          final start = DateTime.parse(row['start_at'] as String).toLocal();
          final end = DateTime.parse(row['end_at'] as String).toLocal();
          final key = _dayKey(start);
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
        final key = _dayKey(date);
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
      final date = _resolveDate(req.date, req.weekday);
      // `POST /api/courts/slots`, status defaults to 'open' server-side.
      final created = await _api.createSlot(
        courtId: req.venueId,
        startAt: _atHour(date, req.startHour),
        endAt: _atHour(date, req.endHour),
      );
      return _slotFromRow(created.json);
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
      // Server-side batches: `POST /api/courts/{id}/recurrence`. The
      // endpoint expects UTC weekday keys / HH:MM times / YYYY-MM-DD dates,
      // so the local wall-clock session is converted instant-by-instant —
      // including the day shift when the local start maps to the previous
      // UTC day (UTC+7 sessions starting before 07:00 local).
      //
      // The local anchor window matches the old client-side loop:
      // [Monday of the anchor week, Monday + weeks*7 - 1] — clamped to
      // today so a mid-week anchor never back-fills past days, and PAST
      // today when today's session start has already elapsed (the server
      // creates past slots without complaint; the old loop skipped past
      // sessions by full datetime, as the recurring-block path still does).
      final anchorWeek = mondayOf(_resolveDate(req.date, req.weekday));
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      var fromLocal = anchorWeek.isBefore(today) ? today : anchorWeek;
      if (fromLocal == today && _atHour(today, req.startHour).isBefore(now)) {
        fromLocal = DateTime(today.year, today.month, today.day + 1);
      }
      final untilLocal = DateTime(
          anchorWeek.year, anchorWeek.month, anchorWeek.day + weeks * 7 - 1);
      if (untilLocal.isBefore(fromLocal)) {
        throw ScheduleRepositoryException(
            'Khoảng lặp lại đã trôi qua — hãy chọn tuần hiện tại hoặc sau.');
      }

      final startLocal = _atHour(fromLocal, req.startHour);
      final startUtc = startLocal.toUtc();
      final endUtc = _atHour(fromLocal, req.endHour).toUtc();
      // PRE-VALIDATION: the endpoint expresses a session as HH:MM times
      // within ONE UTC day, so a session that crosses UTC midnight — or
      // ends exactly on it, making end_time ("00:00") <= start_time — is
      // inexpressible and the server rejects it with 400. Locally (UTC+7)
      // that is any session spanning, or ending exactly at, 07:00. Throw a
      // specific reason instead of the generic invalid-input message; the
      // single-slot create handles these windows fine (full datetimes).
      if (endUtc.hour * 60 + endUtc.minute <=
          startUtc.hour * 60 + startUtc.minute) {
        final boundary = (startLocal.timeZoneOffset.inMinutes / 60.0 + 24) % 24;
        throw ScheduleRepositoryException(
            'Lịch lặp lại không hỗ trợ khung giờ kéo dài qua hoặc kết thúc '
            'đúng ${hourLabel(boundary)} (giới hạn máy chủ) — hãy tạo từng '
            'slot riêng lẻ.');
      }

      // Whole days between the local date and the UTC date of the same
      // instant (-1, 0 or +1) — applied to the weekday keys and date bounds.
      final dayShift = DateTime.utc(startUtc.year, startUtc.month, startUtc.day)
          .difference(
              DateTime.utc(startLocal.year, startLocal.month, startLocal.day))
          .inDays;
      const dayKeys = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
      final daysOfWeek = [
        for (final w in {...weekdays}) dayKeys[(w + dayShift + 7) % 7],
      ];
      final startTime = _hhmm(startUtc);
      final endTime = _hhmm(endUtc);

      // The endpoint caps one call at 90 days (`until_date - from_date`,
      // server `_MAX_RECURRENCE_DAYS = 90` → 400 beyond), so long
      // recurrences (weeks >= 14) are sent as consecutive ≤ 90-day windows.
      // Non-atomic across windows — same as the legacy per-session loop: a
      // mid-batch failure keeps what earlier windows created and surfaces a
      // partial-summary rejection; the bloc refreshes the grid so the
      // created slots show.
      const maxChunkDays = 90;
      var createdTotal = 0;
      var chunkStart = fromLocal;
      while (!chunkStart.isAfter(untilLocal)) {
        final cap = DateTime(
            chunkStart.year, chunkStart.month, chunkStart.day + maxChunkDays);
        final chunkEnd = cap.isAfter(untilLocal) ? untilLocal : cap;
        final ApiRecurrenceResult result;
        try {
          result = await _api.createRecurringSlots(
            courtId: req.venueId,
            daysOfWeek: daysOfWeek,
            startTime: startTime,
            endTime: endTime,
            fromDate: _ymd(DateTime(
                chunkStart.year, chunkStart.month, chunkStart.day + dayShift)),
            untilDate: _ymd(DateTime(
                chunkEnd.year, chunkEnd.month, chunkEnd.day + dayShift)),
          );
        } on ScheduleRepositoryException catch (e) {
          if (createdTotal == 0) rethrow;
          throw ScheduleRepositoryException(
              'Chỉ tạo được $createdTotal slot — ${e.message}');
        }
        createdTotal += result.created;
        chunkStart = DateTime(chunkEnd.year, chunkEnd.month, chunkEnd.day + 1);
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
      final date = _resolveDate(req.date, req.weekday);
      final startAt = _atHour(date, req.startHour);
      final endAt = _atHour(date, req.endHour);
      final note = req.note?.trim();
      // Exact API status per block kind — the block endpoint accepts
      // `status ∈ {blocked, maintenance, owner}` (default blocked), so every
      // row keeps its true kind and the note rides along verbatim.
      final kindStatus = switch (req.blockType) {
        SlotState.maintenance => _statusMaintenance,
        SlotState.owner => _statusOwner,
        _ => _statusBlocked,
      };

      // READ (direct DB): everything overlapping `[startAt, endAt)` on this
      // court, any status.
      final rows = await _client
          .from('slots')
          .select(_slotCols)
          .eq('court_id', req.venueId)
          .lt('start_at', endAt.toUtc().toIso8601String())
          .gt('end_at', startAt.toUtc().toIso8601String());
      final overlaps =
          [for (final r in rows as List) (r as Map).cast<String, dynamic>()];

      // Never block over a customer booking — the per-slot guard of
      // `SupabaseOwnerSlotRepository.blockSlot`, checked up front because one
      // range can span several slots. Kept client-side BEFORE any API call:
      // the backend's own 409 only fires per 'booked' slot, and 'pending'
      // bookings ride on slots the trigger already marked 'booked'.
      if (overlaps.any((r) =>
          r['status'] == _statusBooked || r['status'] == _statusPending)) {
        throw ScheduleRepositoryException(
            'Khung giờ này có lịch đã đặt hoặc chờ duyệt — không thể khoá.');
      }

      // An OPEN slot only partially inside the range would be flipped in its
      // ENTIRETY (a status flip cannot split a row), silently blocking hours
      // the owner did not select — reject instead and let them re-align.
      for (final r in overlaps) {
        if (r['status'] != _statusOpen) continue;
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

      // Flip overlapping OPEN slots via `PATCH .../block` (one call per
      // slot) with the exact kind status; the owner's note (when any) is the
      // stored reason. A slot booked between the select above and the PATCH
      // surfaces as the endpoint's 409 ("đã đặt... không thể khoá") — the
      // legacy race guard, enforced atomically server-side.
      //
      // NOTE: this fan-out (one read + N block PATCHes + M creates below,
      // sequential, multiplied by the bloc's recurring-block loop) replaced
      // 1-2 batched DB statements and is NON-ATOMIC: each call is bounded
      // by the client's 15s timeouts but a mid-loop failure leaves the
      // range half-blocked. Mitigated by the bloc's rejection toast +
      // grid refresh, which keeps the calendar truthful; a server-side
      // batch block endpoint would remove the window entirely.
      for (final r in overlaps) {
        if (r['status'] != _statusOpen) continue;
        await _api.blockSlot(
          r['id'] as String,
          status: kindStatus,
          blockedReason: note,
        );
      }

      // Create block slots over the sub-ranges no existing slot covers, so
      // the whole requested range reads as blocked on the grid. Gap rows
      // keep their exact status via the create `status` field ('owner'
      // implies `is_owner_slot` server-side) and carry the note verbatim —
      // no follow-up calls needed.
      for (final gap in _uncoveredRanges(startAt, endAt, overlaps)) {
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

  @override
  Future<Slot> approveSlot(String slotId) async {
    try {
      // READ: resolve the pending bookings row behind the slot.
      final bookingId = await _pendingBookingIdForSlot(slotId);
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
      final refreshed = await _enrichFromBookings([_slotFromRow(row)]);
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
      final bookingId = await _pendingBookingIdForSlot(slotId);
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
      switch (row['status'] as String? ?? _statusOpen) {
        case _statusBlocked || _statusOwner || _statusMaintenance:
          // "Mở khoá giờ này" — `PATCH .../unblock` restores 'open' and
          // clears the reason (accepts any non-booked status; verified live).
          await _api.unblockSlot(slotId);
        case _statusBooked || _statusPending:
          // "Huỷ" a booking: resolve the active bookings row (READ), then
          // pending/confirmed→cancelled. The SERVER restores the slot to
          // 'open' itself (verified live) — the legacy manual slot-restore
          // write is gone.
          final bookingId = await _activeBookingIdForSlot(slotId);
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
        venue: _venueFromCourt(
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

  /// Maps one `courts` row to the feature's [Venue] — every field derived
  /// from real columns; nothing invented.
  static Venue _venueFromCourt(
    Map<String, dynamic> row,
    int index, {
    int? openHour,
    int? closeHour,
  }) {
    final name = (row['name'] as String?)?.trim() ?? '';
    final sportTypes = _venueSportTypes(row['venues']);
    return Venue(
      id: row['id'] as String,
      name: name,
      shortCode: _shortCode(name),
      // The enum is non-null: derive it from the court's venues' sport_type
      // strings; football is the neutral default (it only drives the "MÔN"
      // chips — sportLabel below is the displayed text and stays real).
      sport: _sportFromLabels(sportTypes),
      sportLabel: sportTypes.join(' · '),
      colorValue: _palette[index % _palette.length],
      pricePerHour: _asInt(row['price_per_hour']) ?? 0,
      // Raw parsed values (no 06–22 fallback) — consumers decide their own
      // fallback so an absent operating window is never presented as real.
      openHour: openHour,
      closeHour: closeHour,
    );
  }

  /// Distinct `venues.sport_type` strings of a court's embedded venues.
  /// Tolerates both PostgREST shapes (list for one-to-many, map when single).
  static List<String> _venueSportTypes(Object? venues) {
    final list = venues is List ? venues : (venues is Map ? [venues] : const []);
    final out = <String>[];
    for (final v in list) {
      if (v is! Map) continue;
      final s = (v['sport_type'] as String?)?.trim();
      if (s != null && s.isNotEmpty && !out.contains(s)) out.add(s);
    }
    return out;
  }

  static SportType _sportFromLabels(List<String> labels) {
    final joined = labels.join(' ').toLowerCase();
    if (joined.contains('pickle')) return SportType.pickleball;
    if (joined.contains('tennis')) return SportType.tennis;
    return SportType.football;
  }

  /// "Sân 1" → "S1", "Pickleball A" → "PA", single word → first two letters.
  static String _shortCode(String name) {
    final words =
        name.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '';
    if (words.length == 1) {
      final w = words.first;
      return w.substring(0, w.length < 2 ? w.length : 2).toUpperCase();
    }
    return words.map((w) => w[0]).take(3).join().toUpperCase();
  }

  // ---------------------------------------------------------------------------
  // Slot mapping & enrichment
  // ---------------------------------------------------------------------------

  /// Maps one `slots` row to the feature's [Slot]. Times are converted to
  /// LOCAL for the decimal-hour grid; `weekday` is 0=Mon..6=Sun of the local
  /// date. `players`/`price`/`payment`/`bookingCode` start null — the DB has
  /// no such slot columns ([_enrichFromBookings] may fill label/price).
  static Slot _slotFromRow(Map<String, dynamic> row) {
    final start = DateTime.parse(row['start_at'] as String).toLocal();
    final end = DateTime.parse(row['end_at'] as String).toLocal();
    final state = _stateFromStatus(row['status'] as String? ?? _statusOpen);
    final date = DateTime(start.year, start.month, start.day);
    final blockedReason = (row['blocked_reason'] as String?)?.trim();
    return Slot(
      id: row['id'] as String,
      venueId: row['court_id'] as String,
      state: state,
      startHour: start.hour + start.minute / 60.0,
      durationHours: end.difference(start).inMinutes / 60.0,
      date: date,
      weekday: date.weekday - 1,
      // The owner's reason on a locked hour, else the state label.
      label: (state == SlotState.locked &&
              blockedReason != null &&
              blockedReason.isNotEmpty)
          ? blockedReason
          : _fallbackLabels[state]!,
      capacity: (row['max_players'] as num?)?.toInt(),
    );
  }

  /// Batched label/price enrichment for booked/pending slots: ONE `bookings`
  /// query per page load (never per slot). Fills the customer name as the
  /// block label and an explicit positive total as the price; both stay
  /// state-label / null when the row carries neither.
  ///
  /// Also the authoritative pending detection: the slot-sync trigger marks a
  /// slot `booked` on booking INSERT while the booking itself is still
  /// `pending` (see [_stateFromStatus]), so the display state is overridden
  /// from the resolved booking row — without this every awaiting-approval
  /// booking would render as "Đã đặt" and approve/reject would be dead.
  Future<List<Slot>> _enrichFromBookings(List<Slot> slots) async {
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
      final rows = await _client
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
        if (kept == null || (!_isActiveBooking(kept) && _isActiveBooking(row))) {
          bySlot[slotId] = row;
        }
      }
      return [for (final s in slots) _applyBooking(s, bySlot[s.id])];
    } catch (e, st) {
      // Enrichment is decoration only — a failure here (e.g. RLS on
      // bookings) must not blank the whole calendar. Logged, then the
      // un-enriched (still real) slots are returned.
      appLogger.e('SupabaseScheduleRepository._enrichFromBookings',
          error: e, stackTrace: st);
      return slots;
    }
  }

  /// Whether a bookings row is the live one behind its slot (vs. e.g. a
  /// leftover 'completed' row of an earlier booking).
  static bool _isActiveBooking(Map<String, dynamic> row) =>
      row['status'] == 'pending' || row['status'] == 'confirmed';

  /// Applies one bookings row onto its slot — same defensive parsing as
  /// `BookingRequest.fromRow` (`customer_name` for walk-ins; explicit
  /// `total_price`/`price`/`amount` only — no derived price math).
  ///
  /// `bookings.status` overrides the display state (see
  /// [_enrichFromBookings]): a pending booking shows "Chờ duyệt" even though
  /// the trigger already flipped the slot to `booked`.
  static Slot _applyBooking(Slot slot, Map<String, dynamic>? booking) {
    if (booking == null) return slot;
    final state = switch (booking['status']) {
      'pending' => SlotState.pending,
      'confirmed' => SlotState.confirmed,
      _ => slot.state,
    };
    final name = (booking['customer_name'] as String?)?.trim();
    final total = _asInt(
        booking['total_price'] ?? booking['price'] ?? booking['amount']);
    return slot.copyWith(
      state: state,
      label: (name != null && name.isNotEmpty)
          ? name
          // Re-derive the state label when the override changed the state
          // (the row label was computed from slots.status).
          : (state == slot.state ? slot.label : _fallbackLabels[state]!),
      price: (total != null && total > 0) ? total : null,
    );
  }

  /// Resolves the pending bookings row behind a pending slot. Throws a
  /// [ScheduleRepositoryException] when none exists (already handled, or the
  /// trigger/RLS hid it) so the UI shows a reason instead of a silent no-op.
  Future<String> _pendingBookingIdForSlot(String slotId) async {
    final rows = await _client
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
  /// for [cancelSlot] — same shape as [_pendingBookingIdForSlot], same
  /// wording as the legacy guarded cancel when nothing is active.
  Future<String> _activeBookingIdForSlot(String slotId) async {
    final rows = await _client
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

  // ---------------------------------------------------------------------------
  // Small helpers
  // ---------------------------------------------------------------------------

  /// Sub-ranges of `[start, end)` not covered by any of [rows] (slot rows with
  /// `start_at`/`end_at`) — the holes [blockTime] fills with inserts.
  static List<_Range> _uncoveredRanges(
    DateTime start,
    DateTime end,
    List<Map<String, dynamic>> rows,
  ) {
    final covered = <_Range>[];
    for (final r in rows) {
      final s = DateTime.parse(r['start_at'] as String).toLocal();
      final e = DateTime.parse(r['end_at'] as String).toLocal();
      final cs = s.isAfter(start) ? s : start;
      final ce = e.isBefore(end) ? e : end;
      if (ce.isAfter(cs)) covered.add((start: cs, end: ce));
    }
    covered.sort((a, b) => a.start.compareTo(b.start));
    final gaps = <_Range>[];
    var cursor = start;
    for (final c in covered) {
      if (c.start.isAfter(cursor)) gaps.add((start: cursor, end: c.start));
      if (c.end.isAfter(cursor)) cursor = c.end;
    }
    if (cursor.isBefore(end)) gaps.add((start: cursor, end: end));
    return gaps;
  }

  /// Defaults a missing date like the create/block sheets expect: weekday →
  /// that day of the current week, otherwise today.
  static DateTime _resolveDate(DateTime? date, int? weekday) {
    if (date != null) return DateTime(date.year, date.month, date.day);
    final now = DateTime.now();
    if (weekday != null) {
      final monday = mondayOf(now);
      return DateTime(monday.year, monday.month, monday.day + weekday);
    }
    return DateTime(now.year, now.month, now.day);
  }

  /// Local [date] at decimal [hour] (`19.5` → 19:30).
  static DateTime _atHour(DateTime date, double hour) => DateTime(
      date.year, date.month, date.day, hour.floor(), ((hour % 1) * 60).round());

  /// `HH:MM` of [d] — the recurrence endpoint's time format.
  static String _hhmm(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  /// `YYYY-MM-DD` of [d] — the recurrence endpoint's date format.
  static String _ymd(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static String _dayKey(DateTime d) => '${d.year}-${d.month}-${d.day}';

  static int? _asInt(Object? v) => v is num ? v.round() : null;
}
