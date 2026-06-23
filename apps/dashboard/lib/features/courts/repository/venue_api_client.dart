import 'package:dio/dio.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';

import '../../../core/env/env.dart';
import '../../../core/network/owner_api.dart';

/// Predictable, user-facing failure from the venue (sân con) backend calls.
class VenueApiException implements Exception {
  const VenueApiException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Dio client for the owner venue (sân con) write endpoints of the Django
/// backend. Replaces the previous direct-to-Supabase venue insert — the API
/// owns the venue model + ownership checks server-side, mirroring how
/// `ScheduleApiClient` handles slot writes. The owner's Supabase session JWT
/// is forwarded as the Bearer credential.
///
/// Contract note: the venue endpoints are live (`POST /api/courts/{court_id}
/// /venues`, owner-only) but are NOT yet in the published OpenAPI schema, so
/// the request body mirrors the `venues` table columns (snake_case). `indoor`
/// is intentionally omitted — that column does not exist in the DB yet.
class VenueApiClient {
  VenueApiClient({Dio? dio, String? Function()? accessToken})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: Env.apiBaseUrl,
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 15),
                contentType: Headers.jsonContentType,
                responseType: ResponseType.json,
              ),
            ),
        _accessToken = accessToken ?? ownerAccessToken {
    _dio.interceptors.add(
      TalkerDioLogger(
        settings: const TalkerDioLoggerSettings(printResponseMessage: true),
      ),
    );
  }

  final Dio _dio;
  final String? Function() _accessToken;

  /// `POST /api/courts/{courtId}/venues` (owner only) — create a sub-court.
  /// Returns the created venue row (same column shape the list path reads).
  Future<Map<String, dynamic>> createVenue({
    required String courtId,
    required String name,
    required String sportType,
    required int capacity,
    required int pricePerHour,
  }) {
    return _send(
      'POST',
      '/api/courts/$courtId/venues',
      body: {
        'name': name,
        'sport_type': sportType,
        'capacity': capacity,
        // The API types price_per_hour as a decimal STRING (OpenAPI:
        // type:string, format:decimal, pattern ^-?\d{0,10}(?:\.\d{0,2})?$),
        // not a JSON number — send it as a string to satisfy validation.
        'price_per_hour': pricePerHour.toString(),
      },
      okStatuses: const {200, 201},
      conflictMessage: 'Sân con này đã tồn tại — hãy tải lại danh sách.',
    );
  }

  // ---------------------------------------------------------------------------
  // Transport + error mapping (mirrors ScheduleApiClient)
  // ---------------------------------------------------------------------------

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
        options: Options(
          method: method,
          validateStatus: (_) => true,
          headers: bearerHeader(token),
        ),
      );
    } on DioException {
      throw const VenueApiException(
          'Không thể kết nối máy chủ — kiểm tra kết nối mạng và thử lại.');
    }

    final status = res.statusCode ?? 0;
    if (okStatuses.contains(status)) {
      final data = res.data;
      if (data is Map) return data.cast<String, dynamic>();
      throw const VenueApiException(
          'Máy chủ trả về dữ liệu không hợp lệ — hãy tải lại.');
    }
    throw _mapFailure(status, conflictMessage: conflictMessage);
  }

  static VenueApiException _mapFailure(int status, {String? conflictMessage}) =>
      switch (status) {
        400 => const VenueApiException(
            'Dữ liệu sân con không hợp lệ — vui lòng kiểm tra và thử lại.'),
        401 => const VenueApiException(
            'Phiên đăng nhập hết hạn — vui lòng đăng nhập lại.'),
        403 => const VenueApiException(
            'Bạn không có quyền thêm sân con cho cụm sân này.'),
        404 => const VenueApiException(
            'Không tìm thấy cụm sân trên máy chủ — hãy tải lại.'),
        409 => VenueApiException(
            conflictMessage ?? 'Dữ liệu đã thay đổi — hãy tải lại.'),
        502 || 503 => const VenueApiException(
            'Máy chủ tạm thời gián đoạn — vui lòng thử lại sau.'),
        _ => const VenueApiException('Có lỗi xảy ra — vui lòng thử lại.'),
      };
}
