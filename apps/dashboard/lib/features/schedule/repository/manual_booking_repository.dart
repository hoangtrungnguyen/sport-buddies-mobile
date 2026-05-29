import 'package:dio/dio.dart';
// `Headers` collides with dio's; we only need the Supabase client here.
import 'package:supabase_flutter/supabase_flutter.dart' hide Headers;

import '../../../core/env/env.dart';
import '../booking_logic.dart';

/// Predictable failure from `POST /api/bookings/manual`. [code] is a stable,
/// UI-mappable key — raw server text is never surfaced (mirrors
/// `OwnerAuthRepository`'s exception style).
class ManualBookingException implements Exception {
  const ManualBookingException(this.code, {this.statusCode});

  /// One of: `overlap` (409 — the window is already taken), `invalid_input`
  /// (400 — bad fields / phone / time), `unauthorized` (401 — session expired),
  /// `not_owner` (403 — not the court's owner), `court_not_found` (404),
  /// `service_unavailable` (502/503), `network` (transport), or `unknown`.
  final String code;

  final int? statusCode;

  @override
  String toString() => 'ManualBookingException($code, status: $statusCode)';
}

/// Records a walk-in/manual booking for the owner. Routes through the Django
/// backend (`POST /api/bookings/manual`) rather than inserting into Supabase
/// directly, so role enforcement, slot creation, pricing and notifications all
/// stay server-side and atomic.
abstract interface class ManualBookingRepository {
  /// Creates a confirmed walk-in booking for [courtId] over the **local**
  /// window [startAt]–[endAt]. [customerPhone] must already be E.164-normalized
  /// (see [normalizeVietnamPhone]) or `null`.
  ///
  /// Completes on `200`/`201`; throws [ManualBookingException] otherwise.
  Future<void> createManualBooking({
    required String courtId,
    required DateTime startAt,
    required DateTime endAt,
    String? customerName,
    String? customerPhone,
    String? notes,
    int? pricePerHourOverride,
  });
}

/// Dio-backed [ManualBookingRepository]. The owner's Supabase access token (set
/// up at login by `OwnerAuthRepository` + the Supabase session) is sent as the
/// Bearer credential the backend validates.
class HttpManualBookingRepository implements ManualBookingRepository {
  HttpManualBookingRepository({
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
            (() => Supabase.instance.client.auth.currentSession?.accessToken);

  final Dio _dio;
  final String? Function() _accessToken;

  @override
  Future<void> createManualBooking({
    required String courtId,
    required DateTime startAt,
    required DateTime endAt,
    String? customerName,
    String? customerPhone,
    String? notes,
    int? pricePerHourOverride,
  }) async {
    final body = buildManualBookingPayload(
      courtId: courtId,
      startAtLocal: startAt,
      endAtLocal: endAt,
      customerName: customerName,
      customerPhone: customerPhone,
      notes: notes,
      pricePerHourOverride: pricePerHourOverride,
    );

    final token = _accessToken();

    final Response<dynamic> res;
    try {
      res = await _dio.post<dynamic>(
        '/api/bookings/manual',
        data: body,
        // Map non-2xx to typed exceptions ourselves; only genuine transport
        // failures should surface as a thrown DioException.
        options: Options(
          validateStatus: (_) => true,
          headers: <String, dynamic>{
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
        ),
      );
    } on DioException catch (e) {
      throw ManualBookingException('network',
          statusCode: e.response?.statusCode);
    }

    final status = res.statusCode ?? 0;
    if (status == 200 || status == 201) return;

    switch (status) {
      case 400:
        throw const ManualBookingException('invalid_input', statusCode: 400);
      case 401:
        throw const ManualBookingException('unauthorized', statusCode: 401);
      case 403:
        throw const ManualBookingException('not_owner', statusCode: 403);
      case 404:
        throw const ManualBookingException('court_not_found', statusCode: 404);
      case 409:
        throw const ManualBookingException('overlap', statusCode: 409);
      case 502:
      case 503:
        throw ManualBookingException('service_unavailable', statusCode: status);
      default:
        throw ManualBookingException('unknown', statusCode: status);
    }
  }
}
