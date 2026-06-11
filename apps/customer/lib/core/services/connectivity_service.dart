import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Observable online/offline status — the **Subject** in an observer setup.
///
/// `connectivity_plus` alone only reports whether a network *interface*
/// exists, which lies in common cases (iOS simulator, captive portals, a
/// connected Wi-Fi with no actual route). So this service treats the
/// interface signal only as a *trigger* and decides "online" from a real
/// reachability probe. While offline it keeps re-probing, so the moment the
/// internet is back it notifies its observers (e.g. the offline banner) to
/// dismiss themselves.
///
/// Observers subscribe via [addListener] and read [isOnline].
class ConnectivityService extends ChangeNotifier {
  ConnectivityService({
    Uri? probeUrl,
    http.Client? httpClient,
    Duration retryInterval = const Duration(seconds: 4),
    Duration probeTimeout = const Duration(seconds: 3),
  })  : _probeUrl =
            probeUrl ?? Uri.parse('https://clients3.google.com/generate_204'),
        _http = httpClient ?? http.Client(),
        _retryInterval = retryInterval,
        _probeTimeout = probeTimeout;

  final Uri _probeUrl;
  final http.Client _http;
  final Duration _retryInterval;
  final Duration _probeTimeout;

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _sub;
  Timer? _retry;
  bool _started = false;

  // Optimistic until the first probe resolves, so the banner doesn't flash
  // on a healthy cold start.
  bool _isOnline = true;
  bool get isOnline => _isOnline;

  /// Starts observing connectivity. Idempotent.
  void start() {
    if (_started) return;
    _started = true;
    _sub = _connectivity.onConnectivityChanged.listen((_) => _evaluate());
    _evaluate();
  }

  Future<void> _evaluate() async {
    final online = await _isInternetReachable();
    _set(online);

    // Only poll while offline — once online we wait for the next interface
    // event instead of busy-probing a healthy connection.
    _retry?.cancel();
    if (!online) {
      _retry = Timer(_retryInterval, _evaluate);
    }
  }

  Future<bool> _isInternetReachable() async {
    // Web: a cross-origin probe is blocked by CORS, and the browser's
    // navigator.onLine (surfaced by connectivity_plus) is reliable there.
    if (kIsWeb) {
      final results = await _connectivity.checkConnectivity();
      return results.isNotEmpty &&
          results.any((r) => r != ConnectivityResult.none);
    }

    try {
      final resp = await _http.get(_probeUrl).timeout(_probeTimeout);
      return resp.statusCode >= 200 && resp.statusCode < 400;
    } catch (_) {
      return false;
    }
  }

  void _set(bool online) {
    if (online != _isOnline) {
      _isOnline = online;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _retry?.cancel();
    _http.close();
    super.dispose();
  }
}
