import 'package:dashboard/core/debug/app_logger.dart';
import 'package:dashboard/core/env/env.dart';
import 'package:dio/dio.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';

/// Predictable failure from the owner auth API. [code] is a stable key the UI
/// maps to a localized message (see `SignupScreen._mapError`); it deliberately
/// avoids leaking raw server text into the UI.
class OwnerSignupException implements Exception {
  const OwnerSignupException(this.code, {this.statusCode});

  /// Stable, UI-mappable key: `email_already_registered`, `invalid_input`,
  /// `service_unavailable`, `network`, or `unknown`.
  final String code;

  /// HTTP status that produced this failure, when one was received.
  final int? statusCode;

  @override
  String toString() => 'OwnerSignupException($code, status: $statusCode)';
}

/// Parsed `201` payload of `POST /auth/owner/signup`.
class OwnerSignupResult {
  const OwnerSignupResult({
    required this.userId,
    required this.email,
    required this.message,
    required this.requiresVerification,
  });

  final String userId;
  final String email;
  final String message;

  /// Whether the account still needs email verification before login. Derived
  /// from the response [message] so the UI adapts to either backend mode
  /// (auto-confirm "Owner account created" vs verify "Confirmation email sent").
  final bool requiresVerification;

  /// Heuristic: the auto-confirm message ("Owner account created") implies no
  /// verification; a confirmation/verification message implies it is needed.
  /// Unknown messages default to NOT requiring verification (the auto-confirm
  /// path), matching the documented owner-signup contract.
  static bool messageImpliesVerification(String message) {
    final m = message.toLowerCase();
    return m.contains('confirm') ||
        m.contains('verif') ||
        m.contains('email sent');
  }
}

/// Predictable failure from `POST /auth/owner/login`. [code] is a stable,
/// UI-mappable key — raw server text is never surfaced.
class OwnerLoginException implements Exception {
  const OwnerLoginException(this.code, {this.statusCode});

  /// One of: `invalid_credentials` (401), `email_not_verified` (403 — account
  /// exists but email is unconfirmed), `access_denied` (403 — other, e.g. not
  /// an owner), `invalid_input` (400), `service_unavailable` (502/503),
  /// `network`, or `unknown`.
  final String code;

  final int? statusCode;

  @override
  String toString() => 'OwnerLoginException($code, status: $statusCode)';
}

/// Parsed `200` payload of `POST /auth/owner/login`. The tokens are Supabase
/// JWTs — the caller hydrates the Supabase session with them.
class OwnerLoginResult {
  const OwnerLoginResult({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    required this.email,
  });

  final String accessToken;
  final String refreshToken;
  final String userId;
  final String email;
}

/// Talks to the SportBuddies REST backend (Django) for owner authentication
/// flows. Both signup and login are routed here so the backend can enforce the
/// owner role server-side (the role is not present in the Supabase JWT). The
/// login tokens returned are Supabase JWTs, which the caller uses to hydrate
/// the Supabase session for the rest of the app (RLS-backed repositories).
class OwnerAuthRepository {
  OwnerAuthRepository({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: Env.apiBaseUrl,
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 15),
                contentType: Headers.jsonContentType,
                responseType: ResponseType.json,
              ),
            ) {
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

  /// `POST /auth/owner/signup`.
  ///
  /// Returns the created account on `201`. Throws [OwnerSignupException] for
  /// every other outcome:
  /// - `409` → `email_already_registered`
  /// - `400` → `invalid_input`
  /// - `502`/`503` → `service_unavailable`
  /// - transport failure → `network`
  /// - anything else → `unknown`
  Future<OwnerSignupResult> signup({
    required String email,
    required String password,
  }) async {
    final Response<dynamic> res;
    try {
      res = await _dio.post<dynamic>(
        '/auth/owner/signup',
        data: <String, dynamic>{'email': email, 'password': password},
        // Map non-2xx responses to typed exceptions ourselves; only genuine
        // transport failures should surface as a thrown DioException. Set here
        // (not on BaseOptions) so the mapping holds for any injected Dio.
        options: Options(validateStatus: (_) => true),
      );
    } on DioException catch (e, stackTrace) {
      // Connection refused / DNS / TLS / timeout / cancellation.
      appLogger.e('DioException during signup', error: e, stackTrace: stackTrace);
      throw OwnerSignupException('network', statusCode: e.response?.statusCode);
    }

    final status = res.statusCode ?? 0;
    final data = res.data;
    final body = data is Map
        ? data.cast<String, dynamic>()
        : const <String, dynamic>{};

    if (status == 201) {
      final user = body['user'] is Map
          ? (body['user'] as Map).cast<String, dynamic>()
          : const <String, dynamic>{};
      final message = body['message']?.toString() ?? 'Owner account created';
      return OwnerSignupResult(
        userId: user['id']?.toString() ?? '',
        email: user['email']?.toString() ?? email,
        message: message,
        requiresVerification:
            OwnerSignupResult.messageImpliesVerification(message),
      );
    }

    switch (status) {
      case 409:
        // Per the contract a 409 always means the email is already registered.
        // Emit the stable key rather than echoing the server's `error` string,
        // so an unexpected value can never leak into the UI as raw text.
        throw const OwnerSignupException(
          'email_already_registered',
          statusCode: 409,
        );
      case 400:
        throw const OwnerSignupException('invalid_input', statusCode: 400);
      case 502:
      case 503:
        throw OwnerSignupException('service_unavailable', statusCode: status);
      default:
        throw OwnerSignupException('unknown', statusCode: status);
    }
  }

  /// `POST /auth/owner/login`.
  ///
  /// Returns the Supabase token pair + user on `200`. Throws
  /// [OwnerLoginException] otherwise:
  /// - `401` → `invalid_credentials`
  /// - `403` `{error: email_not_verified}` → `email_not_verified`
  /// - `403` (other) → `access_denied` (e.g. not an owner)
  /// - `400` → `invalid_input`
  /// - `502`/`503` → `service_unavailable`
  /// - `200` without usable tokens → `unknown`
  /// - transport failure → `network`
  Future<OwnerLoginResult> login({
    required String email,
    required String password,
  }) async {
    final Response<dynamic> res;
    try {
      res = await _dio.post<dynamic>(
        '/auth/owner/login',
        data: <String, dynamic>{'email': email, 'password': password},
        options: Options(validateStatus: (_) => true),
      );
    } on DioException catch (e) {
      throw OwnerLoginException('network', statusCode: e.response?.statusCode);
    }

    final status = res.statusCode ?? 0;
    final data = res.data;
    final body = data is Map
        ? data.cast<String, dynamic>()
        : const <String, dynamic>{};

    if (status == 200) {
      final accessToken = body['access_token']?.toString() ?? '';
      final refreshToken = body['refresh_token']?.toString() ?? '';
      if (accessToken.isEmpty || refreshToken.isEmpty) {
        // 200 but unusable — treat as an unexpected server contract violation.
        throw const OwnerLoginException('unknown', statusCode: 200);
      }
      final user = body['user'] is Map
          ? (body['user'] as Map).cast<String, dynamic>()
          : const <String, dynamic>{};
      return OwnerLoginResult(
        accessToken: accessToken,
        refreshToken: refreshToken,
        userId: user['id']?.toString() ?? '',
        email: user['email']?.toString() ?? email,
      );
    }

    switch (status) {
      case 400:
        throw const OwnerLoginException('invalid_input', statusCode: 400);
      case 401:
        throw const OwnerLoginException('invalid_credentials', statusCode: 401);
      case 403:
        // The backend distinguishes an unverified email from other 403s (e.g.
        // not an owner) via the `error` field. Whitelist the known key so an
        // unexpected value can't leak into the UI; everything else stays the
        // generic access_denied.
        throw OwnerLoginException(
          body['error']?.toString() == 'email_not_verified'
              ? 'email_not_verified'
              : 'access_denied',
          statusCode: 403,
        );
      case 502:
      case 503:
        throw OwnerLoginException('service_unavailable', statusCode: status);
      default:
        throw OwnerLoginException('unknown', statusCode: status);
    }
  }
}
