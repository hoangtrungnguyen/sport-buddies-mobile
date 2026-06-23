import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';

import '../../../core/env/env.dart';
import '../../../core/network/owner_api.dart';

/// Predictable, user-facing failure from the profile backend calls. The
/// server's raw error text is never surfaced.
class ProfileApiException implements Exception {
  const ProfileApiException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Dio client for the owner-profile backend. Today it covers the single live
/// owner endpoint — `POST /api/owners/me/avatar` (the rest of the screen is
/// still served in-memory until those endpoints land). The owner's Supabase
/// session JWT is forwarded as the Bearer credential.
class ProfileApiClient {
  ProfileApiClient({Dio? dio, String? Function()? accessToken})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: Env.apiBaseUrl,
                connectTimeout: const Duration(seconds: 20),
                receiveTimeout: const Duration(seconds: 20),
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

  /// `POST /api/owners/me/avatar` — multipart upload of a JPEG/PNG (max 2 MB)
  /// under the form field `avatar`. Returns the public `avatar_url`.
  Future<String> uploadAvatar(Uint8List bytes, {String filename = 'avatar.jpg'}) async {
    final form = FormData.fromMap({
      'avatar': MultipartFile.fromBytes(
        bytes,
        filename: filename,
        contentType: DioMediaType.parse(_mimeFor(filename)),
      ),
    });

    final token = _accessToken();
    final Response<dynamic> res;
    try {
      res = await _dio.post<dynamic>(
        '/api/owners/me/avatar',
        data: form,
        options: Options(
          validateStatus: (_) => true,
          headers: bearerHeader(token),
        ),
      );
    } on DioException {
      throw const ProfileApiException(
          'Không thể kết nối máy chủ — kiểm tra kết nối mạng và thử lại.');
    }

    final status = res.statusCode ?? 0;
    if (status == 200) {
      final data = res.data;
      final url = data is Map ? data['avatar_url'] as String? : null;
      if (url != null && url.isNotEmpty) return url;
      throw const ProfileApiException('Tải ảnh lên thất bại — vui lòng thử lại.');
    }
    throw _mapFailure(status);
  }

  static String _mimeFor(String filename) {
    final f = filename.toLowerCase();
    if (f.endsWith('.png')) return 'image/png';
    return 'image/jpeg';
  }

  static ProfileApiException _mapFailure(int status) => switch (status) {
        400 => const ProfileApiException(
            'Ảnh không hợp lệ — chỉ nhận JPEG/PNG tối đa 2 MB.'),
        401 => const ProfileApiException(
            'Phiên đăng nhập hết hạn — vui lòng đăng nhập lại.'),
        403 => const ProfileApiException(
            'Bạn không có quyền cập nhật ảnh đại diện.'),
        413 => const ProfileApiException('Ảnh quá lớn — tối đa 2 MB.'),
        502 || 503 => const ProfileApiException(
            'Máy chủ tạm thời gián đoạn — vui lòng thử lại sau.'),
        _ => const ProfileApiException('Có lỗi xảy ra — vui lòng thử lại.'),
      };
}
