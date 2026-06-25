import 'package:dio/dio.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';

import '../../../core/env/env.dart';
import '../../../core/network/owner_api.dart';
import '../model/subscription.dart';

/// Predictable, user-facing failure from the subscription backend calls. The
/// server's raw error text is never surfaced.
class SubscriptionApiException implements Exception {
  const SubscriptionApiException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Dio client for the owner-subscription backend. Covers the read endpoint
/// `GET /api/owners/me/subscription`. The owner's Supabase session JWT is
/// forwarded as the Bearer credential.
class SubscriptionApiClient {
  SubscriptionApiClient({Dio? dio, String? Function()? accessToken})
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

  /// `GET /api/owners/me/subscription` — the current plan, status and trial
  /// window. Throws [SubscriptionApiException] on transport/HTTP failure.
  Future<Subscription> getSubscription() async {
    final token = _accessToken();
    final Response<dynamic> res;
    try {
      res = await _dio.get<dynamic>(
        '/api/owners/me/subscription',
        options: Options(
          validateStatus: (_) => true,
          headers: bearerHeader(token),
        ),
      );
    } on DioException {
      throw const SubscriptionApiException(
          'Không thể kết nối máy chủ — kiểm tra kết nối mạng và thử lại.');
    }

    final status = res.statusCode ?? 0;
    if (status == 200 && res.data is Map) {
      return Subscription.parse((res.data as Map).cast<String, dynamic>());
    }
    throw _mapFailure(status);
  }

  static SubscriptionApiException _mapFailure(int status) => switch (status) {
        401 => const SubscriptionApiException(
            'Phiên đăng nhập hết hạn — vui lòng đăng nhập lại.'),
        403 => const SubscriptionApiException(
            'Bạn không có quyền xem thông tin gói dịch vụ.'),
        404 => const SubscriptionApiException(
            'Không tìm thấy thông tin gói dịch vụ.'),
        502 || 503 => const SubscriptionApiException(
            'Máy chủ tạm thời gián đoạn — vui lòng thử lại sau.'),
        _ => const SubscriptionApiException('Có lỗi xảy ra — vui lòng thử lại.'),
      };
}
