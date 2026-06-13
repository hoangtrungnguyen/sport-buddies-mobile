import 'package:dashboard/core/env/env.dart';
import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Headers;
import 'package:talker_dio_logger/talker_dio_logger.dart';

/// Fetches feature-flag overrides from the SportBuddies backend. Two sources,
/// both flat `{ "<flag_name>": <bool> }` maps, both authenticated with the
/// owner's Supabase JWT (forwarded as the Bearer token):
///
///   • `GET /api/plans/{plan}/feature-flags` — subscription-tier flags.
///   • `GET /api/owner/feature-flags`        — per-owner overrides (win over plan).
///
/// Read-only and offline-safe: any failure (offline, non-2xx, malformed body)
/// yields an empty map so [FeatureFlagService] keeps the lower-priority value.
class FeatureFlagApiClient {
  FeatureFlagApiClient({
    Dio? dio,
    String? Function()? accessToken,
  })  : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: Env.apiBaseUrl,
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
                contentType: Headers.jsonContentType,
                responseType: ResponseType.json,
              ),
            ),
        _accessToken = accessToken ??
            (() => Supabase.instance.client.auth.currentSession?.accessToken) {
    _dio.interceptors.add(
      TalkerDioLogger(
        settings: const TalkerDioLoggerSettings(printResponseMessage: true),
      ),
    );
  }

  final Dio _dio;
  final String? Function() _accessToken;

  static const String ownerPath = '/api/owner/feature-flags';
  static String planPath(String plan) => '/api/plans/$plan/feature-flags';

  /// Subscription-tier flags for [plan] (e.g. `free`/`pro`/`enterprise`).
  Future<Map<String, bool>> fetchPlanFlags(String plan) =>
      _getFlags(planPath(plan));

  /// Per-owner overrides (highest priority).
  Future<Map<String, bool>> fetchOwnerOverrides() => _getFlags(ownerPath);

  /// GETs [path] and returns `{flagName: enabled}`, or an empty map on any
  /// failure (offline / non-2xx / malformed body).
  Future<Map<String, bool>> _getFlags(String path) async {
    final token = _accessToken();
    try {
      final res = await _dio.get<dynamic>(
        path,
        options: Options(
          validateStatus: (_) => true,
          headers: <String, dynamic>{
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
        ),
      );
      final status = res.statusCode ?? 0;
      if (status < 200 || status >= 300) return const {};
      return _parse(res.data);
    } on DioException {
      return const {}; // transport failure — fall back to YAML
    } catch (_) {
      return const {};
    }
  }

  /// Tolerant parse of the flags payload. Primary shape is a flat
  /// `{name: bool}` map; `{name: {enabled: bool}}` is also accepted so a future
  /// richer payload doesn't break the client.
  static Map<String, bool> _parse(Object? data) {
    if (data is! Map) return const {};
    final out = <String, bool>{};
    for (final entry in data.entries) {
      final value = entry.value;
      if (value is bool) {
        out[entry.key.toString()] = value;
      } else if (value is Map && value['enabled'] is bool) {
        out[entry.key.toString()] = value['enabled'] as bool;
      }
    }
    return out;
  }
}
