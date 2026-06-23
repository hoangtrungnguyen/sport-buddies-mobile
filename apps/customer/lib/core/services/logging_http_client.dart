import 'dart:async';

import 'package:customer/core/debug/app_logger.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:http/http.dart' as http;

/// An [http.Client] decorator that logs every outbound request to [apiLogger]
/// so you can see exactly which API endpoints the app calls, in order.
///
/// All `get`/`post`/`patch`/… convenience methods funnel through [send], so a
/// single override here captures every request — both Supabase traffic
/// (PostgREST reads/writes, auth, storage) and the REST `BookingApiClient`,
/// depending on where this is wrapped.
///
/// Each call logs two lines:
/// ```
/// → POST  https://api.example.com/api/bookings
/// ← 201   POST https://api.example.com/api/bookings (142ms)
/// ```
/// or, on a transport failure, a single `✗` line with the error.
///
/// Logging is debug-only: in release builds it delegates straight through.
/// Only the method and URL are logged — never headers or bodies — so auth
/// tokens and API keys never reach the console.
class LoggingHttpClient extends http.BaseClient {
  LoggingHttpClient(this._inner);

  final http.Client _inner;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    if (!kDebugMode) return _inner.send(request);
    return _logged(request);
  }

  Future<http.StreamedResponse> _logged(http.BaseRequest request) async {
    final method = request.method.padRight(5);
    final url = request.url;
    final sw = Stopwatch()..start();
    apiLogger.d('→ $method $url');
    try {
      final response = await _inner.send(request);
      sw.stop();
      apiLogger.d(
        '← ${response.statusCode} $method $url (${sw.elapsedMilliseconds}ms)',
      );
      return response;
    } catch (e) {
      sw.stop();
      apiLogger.w('✗ $method $url failed after ${sw.elapsedMilliseconds}ms: $e');
      rethrow;
    }
  }

  @override
  void close() => _inner.close();
}
