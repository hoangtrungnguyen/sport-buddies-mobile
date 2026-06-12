import 'package:dio/dio.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';

// `Headers` collides with dio's; we only need the Supabase client here.
import 'package:supabase_flutter/supabase_flutter.dart' hide Headers;

import '../../../core/env/env.dart';
import 'schedule_repository.dart';

/// Minimal parsed slot from a write endpoint (`POST /api/courts/slots`,
/// `PATCH .../block`, `PATCH .../unblock`).
///
/// [json] is the full response payload — the backend serializes the same
/// columns the schedule read path selects (`id, court_id, start_at, end_at,
/// status, blocked_reason, max_players`), so the repository can map it with
/// its existing row mapper instead of re-reading the database.
class ApiSlot {
  const ApiSlot({required this.id, required this.status, required this.json});

  factory ApiSlot.fromJson(Map<String, dynamic> json) => ApiSlot(
        id: json['id'] as String,
        status: json['status'] as String? ?? 'open',
        json: json,
      );

  final String id;
  final String status;
  final Map<String, dynamic> json;
}

/// Parsed result of `POST /api/courts/{court_id}/recurrence`.
///
/// NOTE (schema vs reality): the OpenAPI schema names the slot array
/// `results`, but the live backend returns it as `slots` (verified against
/// the local server) — both keys are accepted here.
class ApiRecurrenceResult {
  const ApiRecurrenceResult({required this.created, required this.slots});

  factory ApiRecurrenceResult.fromJson(Map<String, dynamic> json) {
    final raw = (json['slots'] ?? json['results']) as List? ?? const [];
    return ApiRecurrenceResult(
      created: (json['created'] as num?)?.toInt() ?? 0,
      slots: [for (final r in raw) (r as Map).cast<String, dynamic>()],
    );
  }

  /// Number of slots actually inserted. Occurrences that overlap an existing
  /// slot or fall outside operating hours are silently skipped server-side.
  final int created;

  /// The created slot payloads (same shape as [ApiSlot.json]).
  final List<Map<String, dynamic>> slots;
}

/// Dio client for the schedule WRITE endpoints of the Django backend. Reads
/// stay direct-to-Supabase (see `SupabaseScheduleRepository`); every mutation
/// of `slots` / `bookings` goes through here so role enforcement, overlap
/// checks and notifications stay server-side.
///
/// Auth/transport: the owner's Supabase
/// session access token is sent as the Bearer credential, all non-2xx
/// responses are mapped to [ScheduleRepositoryException] with Vietnamese
/// user-facing messages (raw server text is never surfaced).
class ScheduleApiClient {
  ScheduleApiClient({
    Dio? dio,
    String? Function()? accessToken,
  })  : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: Env.apiBaseUrl,
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 15),
                contentType: Headers.jsonContentType,
                responseType: ResponseType.json,
              ),
            ),
        _accessToken = accessToken ??
            (() => Supabase.instance.client.auth.currentSession?.accessToken) {
    _dio.interceptors.add(
      TalkerDioLogger(
        settings: const TalkerDioLoggerSettings(
          printRequestHeaders: true,
          printResponseHeaders: true,
          printResponseMessage: true,
        ),
      ),
    );
  }

  final Dio _dio;
  final String? Function() _accessToken;

  /// `POST /api/courts/slots` — creates one slot over the **local** window
  /// [startAt]–[endAt] (sent as UTC ISO 8601, the format the schedule grid
  /// already stores). [status] is one of `open | blocked | maintenance |
  /// owner` (defaults to `open` server-side). `is_owner_slot: true` and
  /// `status: owner` imply each other server-side (the invariant is enforced
  /// at create). [blockedReason] is stored verbatim when given — so blocked /
  /// maintenance gap rows can carry the owner's note without a follow-up
  /// block call.
  ///
  /// [venueId] is a REAL `venues.id` uuid only (the server validates it
  /// exists → 404, belongs to [courtId] → 400, and is active → 400) — pass
  /// null for the venue-less "Chung (cả sân)" lane so the field is omitted
  /// and the row keeps `venue_id IS NULL`. Callers decode the client-side
  /// `general:<courtId>` sentinel BEFORE calling; it must never be sent.
  ///
  /// 409 = an overlapping slot already exists on the same lane (same
  /// `venue_id`, or both NULL — venue lanes and the NULL lane never conflict
  /// with each other).
  Future<ApiSlot> createSlot({
    required String courtId,
    required DateTime startAt,
    required DateTime endAt,
    String? venueId,
    String? status,
    bool isOwnerSlot = false,
    String? blockedReason,
  }) async {
    final data = await _send(
      'POST',
      '/api/courts/slots',
      body: {
        'court_id': courtId,
        'start_at': startAt.toUtc().toIso8601String(),
        'end_at': endAt.toUtc().toIso8601String(),
        if (venueId != null) 'venue_id': venueId,
        if (status != null) 'status': status,
        if (isOwnerSlot) 'is_owner_slot': true,
        if (blockedReason != null && blockedReason.isNotEmpty)
          'blocked_reason': blockedReason,
      },
      okStatuses: const {200, 201},
      conflictMessage: 'Khung giờ bị trùng với slot khác — hãy tải lại lịch.',
    );
    return ApiSlot.fromJson(data);
  }

  /// `POST /api/courts/{court_id}/recurrence` — generates weekly OPEN slots.
  ///
  /// [daysOfWeek] are `mon..sun` keys, [startTime]/[endTime] are `HH:MM` and
  /// [fromDate]/[untilDate] are `YYYY-MM-DD` — all in **UTC** (the backend
  /// builds the occurrence datetimes with `tzinfo=utc`); callers convert
  /// from local wall-clock first. Max range 90 days (400 beyond that).
  ///
  /// [venueId] — same contract as [createSlot]: real `venues.id` uuid only
  /// (validated once up front server-side, persisted on every generated
  /// slot); null = venue-less Chung lane, field omitted.
  Future<ApiRecurrenceResult> createRecurringSlots({
    required String courtId,
    required List<String> daysOfWeek,
    required String startTime,
    required String endTime,
    required String fromDate,
    required String untilDate,
    String? venueId,
  }) async {
    final data = await _send(
      'POST',
      '/api/courts/$courtId/recurrence',
      body: {
        'days_of_week': daysOfWeek,
        'start_time': startTime,
        'end_time': endTime,
        'from_date': fromDate,
        'until_date': untilDate,
        if (venueId != null) 'venue_id': venueId,
      },
      okStatuses: const {200},
    );
    return ApiRecurrenceResult.fromJson(data);
  }

  /// `PATCH /api/courts/slots/{slot_id}/block` — sets the slot to [status]
  /// (`blocked | maintenance | owner`, server default `blocked`) and stores
  /// [blockedReason] when one is given. A null/empty reason OMITS the field;
  /// whether the server keeps or clears a pre-existing reason on omission is
  /// unspecified, and no current caller re-blocks an already-reasoned slot
  /// expecting a clear. The server keeps `is_owner_slot` in sync with the
  /// chosen status.
  ///
  /// 409 = the slot is currently booked (enforced atomically server-side).
  Future<ApiSlot> blockSlot(
    String slotId, {
    String? status,
    String? blockedReason,
  }) async {
    final data = await _send(
      'PATCH',
      '/api/courts/slots/$slotId/block',
      body: {
        if (status != null) 'status': status,
        if (blockedReason != null && blockedReason.isNotEmpty)
          'blocked_reason': blockedReason,
      },
      okStatuses: const {200},
      conflictMessage:
          'Khung giờ này có lịch đã đặt hoặc chờ duyệt — không thể khoá.',
    );
    return ApiSlot.fromJson(data);
  }

  /// `PATCH /api/courts/slots/{slot_id}/unblock` — restores `status: open`,
  /// clears the block reason and resets `is_owner_slot`. Accepts `blocked`,
  /// `maintenance` and `owner` slots alike.
  ///
  /// 409 = the slot has an active booking (cannot be freed by unblocking).
  Future<ApiSlot> unblockSlot(String slotId) async {
    final data = await _send(
      'PATCH',
      '/api/courts/slots/$slotId/unblock',
      okStatuses: const {200},
      conflictMessage:
          'Slot này có lịch đang hoạt động — không thể mở khoá.',
    );
    return ApiSlot.fromJson(data);
  }

  /// `PATCH /api/bookings/{booking_id}/status` — transitions a booking
  /// (`confirmed` to approve, `cancelled` to reject/cancel, `completed`).
  /// On cancellation the server restores the linked slot to `open` itself.
  ///
  /// Returns the updated booking status. 409 = illegal transition (the
  /// booking moved on) — surfaced with [conflictMessage].
  Future<String> updateBookingStatus({
    required String bookingId,
    required String status,
    required String conflictMessage,
  }) async {
    final data = await _send(
      'PATCH',
      '/api/bookings/$bookingId/status',
      body: {'status': status},
      okStatuses: const {200},
      conflictMessage: conflictMessage,
    );
    return data['status'] as String? ?? status;
  }

  // ---------------------------------------------------------------------------
  // Transport + error mapping
  // ---------------------------------------------------------------------------

  /// Sends one request and returns the decoded JSON object on success.
  /// Non-2xx statuses are mapped to [ScheduleRepositoryException] by
  /// [_mapFailure]; transport failures surface as a network rejection.
  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Object? body,
    required Set<int> okStatuses,
    String? conflictMessage,
  }) async {
    final token = _accessToken();

    final Response<dynamic> res;
    try {
      res = await _dio.request<dynamic>(
        path,
        data: body,
        // Map non-2xx to typed exceptions ourselves; only genuine transport
        // failures should surface as a thrown DioException.
        options: Options(
          method: method,
          validateStatus: (_) => true,
          headers: <String, dynamic>{
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
        ),
      );
    } on DioException {
      throw ScheduleRepositoryException(
          'Không thể kết nối máy chủ — kiểm tra kết nối mạng và thử lại.');
    }

    final status = res.statusCode ?? 0;
    if (okStatuses.contains(status)) {
      final data = res.data;
      if (data is Map) return data.cast<String, dynamic>();
      // A success without a JSON object body is unexpected for these
      // endpoints — treat as a server fault rather than fabricate fields.
      throw ScheduleRepositoryException(
          'Máy chủ trả về dữ liệu không hợp lệ — hãy tải lại lịch.');
    }
    throw _mapFailure(status, conflictMessage: conflictMessage);
  }

  /// HTTP status → predictable Vietnamese rejection. The backend's `error`
  /// body text is intentionally NOT surfaced (it is English/internal); the
  /// taxonomy mirrors `ManualBookingException`'s codes:
  /// 400 invalid_input · 401 unauthorized · 403 not_owner · 404 not_found ·
  /// 409 conflict (per-endpoint wording) · 502/503 service_unavailable ·
  /// anything else unknown.
  static ScheduleRepositoryException _mapFailure(
    int status, {
    String? conflictMessage,
  }) =>
      switch (status) {
        400 => ScheduleRepositoryException(
            'Dữ liệu không hợp lệ — vui lòng kiểm tra và thử lại.'),
        401 => ScheduleRepositoryException(
            'Phiên đăng nhập hết hạn — vui lòng đăng nhập lại.'),
        403 => ScheduleRepositoryException(
            'Bạn không có quyền thực hiện thao tác này.'),
        404 => ScheduleRepositoryException(
            'Không tìm thấy dữ liệu trên máy chủ — hãy tải lại lịch.'),
        409 => ScheduleRepositoryException(
            conflictMessage ?? 'Dữ liệu đã thay đổi — hãy tải lại lịch.'),
        502 || 503 => ScheduleRepositoryException(
            'Máy chủ tạm thời gián đoạn — vui lòng thử lại sau.'),
        _ => ScheduleRepositoryException(
            'Có lỗi xảy ra — vui lòng thử lại.'),
      };
}
