import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

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
  String toString() => 'JoinConflictException: ${detail ?? 'duplicate/private'}';
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
  })  : _supabase = supabase,
        _baseUrl = baseUrl.endsWith('/')
            ? baseUrl.substring(0, baseUrl.length - 1)
            : baseUrl,
        _http = httpClient ?? http.Client();

  final SupabaseClient _supabase;
  final String _baseUrl;
  final http.Client _http;

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
    final response = await _http.post(
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

  /// `POST /api/slots/{slotId}/join` — player requests to join an open
  /// slot. Creates a pending `slot_join_requests` row.
  ///
  /// Throws [JoinConflictException] on 409 (slot private or duplicate
  /// request), [BookingApiException] on other errors.
  Future<void> requestToJoin(String slotId) async {
    final response = await _http.post(
      Uri.parse('$_baseUrl/api/slots/$slotId/join'),
      headers: _headers(),
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

  /// `PATCH /api/slots/{slotId}/access` — booking owner opens the slot
  /// for play-together (or keeps it private).
  Future<void> updateSlotAccess({
    required String slotId,
    required String accessPolicy,
    int? maxPlayers,
  }) async {
    final response = await _http.patch(
      Uri.parse('$_baseUrl/api/slots/$slotId/access'),
      headers: _headers(),
      body: jsonEncode({
        'access_policy': accessPolicy,
        if (maxPlayers != null) 'max_players': maxPlayers,
      }),
    );

    if (response.statusCode == 200) return;
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
