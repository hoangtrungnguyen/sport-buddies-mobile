import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

/// The request never reached the server — device is offline or the host
/// is unreachable. UI should surface a "no internet" message.
class NoConnectionException implements Exception {
  const NoConnectionException();

  @override
  String toString() => 'NoConnectionException';
}

/// Slot already booked / not open — server returned 409.
class SlotUnavailableException implements Exception {
  const SlotUnavailableException(this.detail);

  final String? detail;

  @override
  String toString() => 'SlotUnavailableException: ${detail ?? 'slot taken'}';
}

/// Join request rejected with 409 — slot is private, or the player has
/// already requested to join.
class JoinConflictException implements Exception {
  const JoinConflictException(this.detail);

  final String? detail;

  @override
  String toString() =>
      'JoinConflictException: ${detail ?? 'duplicate/private'}';
}

/// The court schedule isn't available — server returned 404 (court doesn't
/// exist or isn't approved/public).
class ScheduleUnavailableException implements Exception {
  const ScheduleUnavailableException();

  @override
  String toString() => 'ScheduleUnavailableException';
}

/// Any non-2xx response from the core-engine API other than 409.
/// [code] is the machine-readable `error` key from the error envelope.
class BookingApiException implements Exception {
  const BookingApiException(this.statusCode, this.code, [this.detail]);

  final int statusCode;
  final String code;
  final String? detail;

  @override
  String toString() =>
      'BookingApiException($statusCode, $code${detail != null ? ', $detail' : ''})';
}

/// Core-engine REST client for booking writes.
///
/// Reads stay on Supabase; create/update actions go through the backend
/// API so business rules are enforced server-side.
class BookingApiClient {
  BookingApiClient({
    required SupabaseClient supabase,
    required String baseUrl,
    http.Client? httpClient,
  }) : _supabase = supabase,
       _baseUrl = baseUrl.endsWith('/')
           ? baseUrl.substring(0, baseUrl.length - 1)
           : baseUrl,
       _http = httpClient ?? http.Client();

  final SupabaseClient _supabase;
  final String _baseUrl;
  final http.Client _http;

  /// Hard ceiling for any single backend request. A server that hasn't
  /// responded within this window is treated as unreachable so the UI fails
  /// fast instead of hanging indefinitely.
  static const requestTimeout = Duration(seconds: 30);

  /// Runs an HTTP call, translating transport-level failures (offline,
  /// host unreachable, slow/hung server) into [NoConnectionException] so
  /// callers can show a "no internet" message instead of a raw exception
  /// string. Every request is bounded by [requestTimeout].
  Future<http.Response> _send(Future<http.Response> Function() call) async {
    try {
      return await call().timeout(requestTimeout);
    } on TimeoutException {
      throw const NoConnectionException();
    } on http.ClientException {
      throw const NoConnectionException();
    } on Exception catch (e) {
      // SocketException (dart:io) isn't always wrapped as ClientException;
      // match by name to stay web-safe (no dart:io import).
      if (e.runtimeType.toString() == 'SocketException') {
        throw const NoConnectionException();
      }
      rethrow;
    }
  }

  Map<String, String> _headers() {
    final token = _supabase.auth.currentSession?.accessToken;
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// `POST /api/bookings` — atomically books an open slot.
  ///
  /// Returns the created booking id. Throws [SlotUnavailableException]
  /// on 409 (slot not open), [BookingApiException] on other errors.
  Future<String> createBooking({
    required String slotId,
    String? customerName,
    String? customerPhone,
    String? notes,
  }) async {
    final response = await _send(
      () => _http.post(
        Uri.parse('$_baseUrl/api/bookings'),
        headers: _headers(),
        body: jsonEncode({
          'slot_id': slotId,
          if (customerName != null && customerName.isNotEmpty)
            'customer_name': customerName,
          if (customerPhone != null && customerPhone.isNotEmpty)
            'customer_phone': customerPhone,
          if (notes != null && notes.isNotEmpty) 'notes': notes,
        }),
      ),
    );

    final body = _decode(response);
    if (response.statusCode == 201) {
      return body['id'] as String;
    }
    if (response.statusCode == 409) {
      throw SlotUnavailableException(body['detail'] as String?);
    }
    throw BookingApiException(
      response.statusCode,
      body['error'] as String? ?? 'unknown',
      body['detail'] as String?,
    );
  }

  /// `POST /api/bookings/batch` — atomically books multiple slots at once.
  ///
  /// Returns map of slot_id → booking_id for successful bookings.
  /// Throws [SlotUnavailableException] if any slot fails with 409,
  /// [BookingApiException] on other errors.
  Future<Map<String, String>> createBatchBooking({
    required List<String> slotIds,
    String? customerName,
    String? customerPhone,
    String? notes,
  }) async {
    final response = await _send(
      () => _http.post(
        Uri.parse('$_baseUrl/api/bookings/batch'),
        headers: _headers(),
        body: jsonEncode({
          'slot_ids': slotIds,
          if (customerName != null && customerName.isNotEmpty)
            'customer_name': customerName,
          if (customerPhone != null && customerPhone.isNotEmpty)
            'customer_phone': customerPhone,
          if (notes != null && notes.isNotEmpty) 'notes': notes,
        }),
      ),
    );

    if (response.statusCode != 201) {
      final body = _decode(response);
      if (response.statusCode == 409) {
        throw SlotUnavailableException(body['detail'] as String?);
      }
      throw BookingApiException(
        response.statusCode,
        body['error'] as String? ?? 'unknown',
        body['detail'] as String?,
      );
    }

    // Parse per-slot results — response is an array of per-slot result objects
    try {
      final decoded = jsonDecode(response.body);
      final resultList = decoded is List<dynamic> ? decoded : [decoded];
      final bookingMap = <String, String>{};
      final failedSlots = <String>[];

      for (final item in resultList) {
        if (item is! Map<String, dynamic>) continue;
        final slotId = item['slot_id'] as String?;
        final status = item['status'] as String?;
        final booking = item['booking'] as Map<String, dynamic>?;

        if (slotId != null) {
          if (status == 'success' && booking != null) {
            final bookingId = booking['id'] as String?;
            if (bookingId != null) {
              bookingMap[slotId] = bookingId;
            }
          } else if (status == 'error') {
            failedSlots.add(slotId);
          }
        }
      }

      // If any slots failed, throw error with list of failed slot IDs
      if (failedSlots.isNotEmpty) {
        throw SlotUnavailableException(
          'Failed slots: ${failedSlots.join(", ")}',
        );
      }

      return bookingMap;
    } catch (e) {
      if (e is SlotUnavailableException) rethrow;
      throw BookingApiException(
        response.statusCode,
        'parse_error',
        'Failed to parse batch booking response',
      );
    }
  }

  /// `POST /api/slots/{slotId}/join` — player requests to join an open
  /// slot. Creates a pending `slot_join_requests` row.
  ///
  /// Throws [JoinConflictException] on 409 (slot private or duplicate
  /// request), [BookingApiException] on other errors.
  Future<void> requestToJoin(String slotId) async {
    final response = await _send(
      () => _http.post(
        Uri.parse('$_baseUrl/api/slots/$slotId/join'),
        headers: _headers(),
      ),
    );

    if (response.statusCode == 201) return;
    final body = _decode(response);
    if (response.statusCode == 409) {
      throw JoinConflictException(body['detail'] as String?);
    }
    throw BookingApiException(
      response.statusCode,
      body['error'] as String? ?? 'unknown',
      body['detail'] as String?,
    );
  }

  /// `PATCH /api/slot-join-requests/{id}/approve` — slot owner approves a
  /// pending join request; the server adds a `slot_participants` row.
  Future<void> approveJoinRequest(String joinRequestId) =>
      _patchJoinRequest(joinRequestId, 'approve');

  /// `PATCH /api/slot-join-requests/{id}/reject` — slot owner rejects a
  /// pending join request.
  Future<void> rejectJoinRequest(String joinRequestId) =>
      _patchJoinRequest(joinRequestId, 'reject');

  Future<void> _patchJoinRequest(String id, String action) async {
    final response = await _send(
      () => _http.patch(
        Uri.parse('$_baseUrl/api/slot-join-requests/$id/$action'),
        headers: _headers(),
      ),
    );

    if (response.statusCode == 200) return;
    final body = _decode(response);
    throw BookingApiException(
      response.statusCode,
      body['error'] as String? ?? 'unknown',
      body['detail'] as String?,
    );
  }

  /// `PATCH /api/slots/{slotId}/access` — booking owner opens the slot
  /// for play-together (or keeps it private).
  Future<void> updateSlotAccess({
    required String slotId,
    required String accessPolicy,
    int? maxPlayers,
  }) async {
    final response = await _send(
      () => _http.patch(
        Uri.parse('$_baseUrl/api/slots/$slotId/access'),
        headers: _headers(),
        body: jsonEncode({
          'access_policy': accessPolicy,
          if (maxPlayers != null) 'max_players': maxPlayers,
        }),
      ),
    );

    if (response.statusCode == 200) return;
    final body = _decode(response);
    throw BookingApiException(
      response.statusCode,
      body['error'] as String? ?? 'unknown',
      body['detail'] as String?,
    );
  }

  /// `GET /api/slots/{slotId}/participants` — fetch confirmed participants and
  /// pending join requests for a slot.
  ///
  /// Returns { confirmed: [...], pending: [...], maxPlayers: int }.
  /// Throws [BookingApiException] on errors.
  Future<Map<String, dynamic>> getSlotParticipants(String slotId) async {
    final response = await _send(
      () => _http.get(
        Uri.parse('$_baseUrl/api/slots/$slotId/participants'),
        headers: _headers(),
      ),
    );

    if (response.statusCode == 200) {
      return _decode(response);
    }
    final body = _decode(response);
    throw BookingApiException(
      response.statusCode,
      body['error'] as String? ?? 'unknown',
      body['detail'] as String?,
    );
  }

  /// `GET /api/slots/{slotId}/join-status` — fetch the current player's join
  /// request status for the slot.
  ///
  /// Returns { status: 'none' | 'pending' | 'approved' | 'rejected' }.
  /// Throws [BookingApiException] on errors.
  Future<String> getSlotJoinStatus(String slotId) async {
    final response = await _send(
      () => _http.get(
        Uri.parse('$_baseUrl/api/slots/$slotId/join-status'),
        headers: _headers(),
      ),
    );

    if (response.statusCode == 200) {
      final body = _decode(response);
      return body['status'] as String? ?? 'none';
    }
    final body = _decode(response);
    throw BookingApiException(
      response.statusCode,
      body['error'] as String? ?? 'unknown',
      body['detail'] as String?,
    );
  }

  /// `POST /api/slots/{slotId}/last-minute` — slot owner signals last-minute
  /// capacity is available for additional players to join quickly.
  ///
  /// Throws [BookingApiException] on errors.
  Future<void> signalLastMinuteCapacity(String slotId) async {
    final response = await _send(
      () => _http.post(
        Uri.parse('$_baseUrl/api/slots/$slotId/last-minute'),
        headers: _headers(),
      ),
    );

    if (response.statusCode == 200) return;
    final body = _decode(response);
    throw BookingApiException(
      response.statusCode,
      body['error'] as String? ?? 'unknown',
      body['detail'] as String?,
    );
  }

  /// `GET /api/courts/{courtId}/schedule` — public court availability.
  ///
  /// Pass exactly one of [weekStart] (returns that day + the next 6) or [date]
  /// (single day). The day is sent as a local `YYYY-MM-DD` (UTC+7 calendar
  /// day) — pass the local day the user is viewing.
  ///
  /// Returns `{ court_id, week_start|date, venues: [ { id, name, sport_type,
  /// slots: [...] } ] }`. Public — no auth header is sent. Throws
  /// [ScheduleUnavailableException] on 404 (court missing/unapproved) and
  /// [BookingApiException] on other errors (e.g. 503).
  Future<Map<String, dynamic>> getCourtSchedule(
    String courtId, {
    DateTime? weekStart,
    DateTime? date,
  }) async {
    assert(
      (weekStart == null) != (date == null),
      'Pass exactly one of weekStart or date.',
    );
    final day = (weekStart ?? date)!;
    final ymd =
        '${day.year.toString().padLeft(4, '0')}-'
        '${day.month.toString().padLeft(2, '0')}-'
        '${day.day.toString().padLeft(2, '0')}';
    final uri = Uri.parse('$_baseUrl/api/courts/$courtId/schedule').replace(
      queryParameters: {weekStart != null ? 'week_start' : 'date': ymd},
    );

    final response = await _send(() => _http.get(uri));

    if (response.statusCode == 200) {
      return _decode(response);
    }
    if (response.statusCode == 404) {
      throw const ScheduleUnavailableException();
    }
    final body = _decode(response);
    throw BookingApiException(
      response.statusCode,
      body['error'] as String? ?? 'unknown',
      body['detail'] as String?,
    );
  }

  static Map<String, dynamic> _decode(http.Response response) {
    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      return const {};
    }
  }
}
