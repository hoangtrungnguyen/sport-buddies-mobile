import 'package:dio/dio.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';
// `Headers` collides with dio's; we only need the Supabase client here.
import 'package:supabase_flutter/supabase_flutter.dart' hide Headers;

import '../../../core/env/env.dart';

/// Predictable, user-facing failure from the Home backend calls. The server's
/// raw (English/internal) error text is never surfaced.
class HomeApiException implements Exception {
  const HomeApiException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Dio client for the Home / Dashboard backend. One read endpoint
/// (`GET /api/home/overview`) hydrates the whole screen; approve/decline reuse
/// the existing booking-status and slot-join-request endpoints (dispatched by
/// the item's `kind`, see HOME_API_HANDOFF §3). The owner's Supabase session
/// JWT is forwarded as the Bearer credential.
class HomeApiClient {
  HomeApiClient({Dio? dio, String? Function()? accessToken})
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
        _accessToken = accessToken ??
            (() => Supabase.instance.client.auth.currentSession?.accessToken) {
    _dio.interceptors.add(
      TalkerDioLogger(
        settings: const TalkerDioLoggerSettings(
          printResponseMessage: true,
        ),
      ),
    );
  }

  final Dio _dio;
  final String? Function() _accessToken;

  /// `GET /api/home/overview?date=YYYY-MM-DD` — the full screen in one call.
  /// [date] defaults to today (`Asia/Ho_Chi_Minh`) server-side when omitted.
  Future<Map<String, dynamic>> getOverview({String? date}) {
    return _send(
      'GET',
      '/api/home/overview',
      query: {if (date != null) 'date': date},
      okStatuses: const {200},
    );
  }

  /// `PATCH /api/bookings/{id}/status` — approve (`confirmed`) / decline
  /// (`cancelled`) a pending booking. 409 = the booking already moved on.
  Future<void> updateBookingStatus({
    required String bookingId,
    required String status,
  }) {
    return _send(
      'PATCH',
      '/api/bookings/$bookingId/status',
      body: {'status': status},
      okStatuses: const {200},
      conflictMessage: 'Yêu cầu đã được xử lý ở nơi khác — đang tải lại.',
    );
  }

  /// `POST /api/slot-join-requests/{id}/approve` (empty body). NB: approve is
  /// POST while reject is PATCH — verified against the live API schema (the
  /// handoff incorrectly listed both as PATCH).
  Future<void> approveJoinRequest(String id) {
    return _send(
      'POST',
      '/api/slot-join-requests/$id/approve',
      okStatuses: const {200, 201},
      conflictMessage: 'Yêu cầu đã được xử lý ở nơi khác — đang tải lại.',
    );
  }

  /// `PATCH /api/slot-join-requests/{id}/reject` (empty body).
  Future<void> rejectJoinRequest(String id) {
    return _send(
      'PATCH',
      '/api/slot-join-requests/$id/reject',
      okStatuses: const {200},
      conflictMessage: 'Yêu cầu đã được xử lý ở nơi khác — đang tải lại.',
    );
  }

  // ---------------------------------------------------------------------------
  // Transport + error mapping (mirrors ScheduleApiClient)
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    required Set<int> okStatuses,
    String? conflictMessage,
  }) async {
    final token = _accessToken();
    final Response<dynamic> res;
    try {
      res = await _dio.request<dynamic>(
        path,
        data: body,
        queryParameters: query,
        options: Options(
          method: method,
          validateStatus: (_) => true,
          headers: <String, dynamic>{
            if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          },
        ),
      );
    } on DioException {
      throw const HomeApiException(
          'Không thể kết nối máy chủ — kiểm tra kết nối mạng và thử lại.');
    }

    final status = res.statusCode ?? 0;
    if (okStatuses.contains(status)) {
      final data = res.data;
      // PATCH actions may return no/empty body; reads return an object.
      if (data is Map) return data.cast<String, dynamic>();
      return const <String, dynamic>{};
    }
    throw _mapFailure(status, conflictMessage: conflictMessage);
  }

  static HomeApiException _mapFailure(int status, {String? conflictMessage}) =>
      switch (status) {
        400 => const HomeApiException(
            'Dữ liệu không hợp lệ — vui lòng thử lại.'),
        401 => const HomeApiException(
            'Phiên đăng nhập hết hạn — vui lòng đăng nhập lại.'),
        403 => const HomeApiException(
            'Bạn không có quyền truy cập bảng điều khiển.'),
        404 => const HomeApiException(
            'Không tìm thấy dữ liệu trên máy chủ — hãy tải lại.'),
        409 => HomeApiException(
            conflictMessage ?? 'Dữ liệu đã thay đổi — hãy tải lại.'),
        502 || 503 => const HomeApiException(
            'Máy chủ tạm thời gián đoạn — vui lòng thử lại sau.'),
        _ => const HomeApiException('Có lỗi xảy ra — vui lòng thử lại.'),
      };
}
