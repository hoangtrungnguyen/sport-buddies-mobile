import 'package:http/http.dart' as http;

/// An [http.Client] decorator that bounds every request by [timeout].
///
/// Passed to `Supabase.initialize(httpClient: ...)` so all Supabase traffic
/// (PostgREST reads/writes, auth, storage) fails fast on a hung/slow server
/// instead of hanging indefinitely — the same 30s ceiling the REST
/// BookingApiClient enforces. A timed-out request throws a `TimeoutException`,
/// which surfaces through the repositories/cubits as a load error.
class TimeoutHttpClient extends http.BaseClient {
  TimeoutHttpClient(this._inner, {this.timeout = const Duration(seconds: 30)});

  final http.Client _inner;
  final Duration timeout;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) =>
      _inner.send(request).timeout(timeout);

  @override
  void close() => _inner.close();
}
