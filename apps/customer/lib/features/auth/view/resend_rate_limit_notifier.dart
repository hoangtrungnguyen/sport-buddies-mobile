// ResendRateLimitNotifier — manages the 60-second rate-limit cooldown for
// the "Resend verification email" button (CAPP-010 / grava-144f.1.5).
//
// Usage:
//   final notifier = ResendRateLimitNotifier();
//   notifier.markSent();   // start/reset the countdown
//   notifier.isOnCooldown  // true while countdown > 0
//   notifier.remainingSeconds  // seconds left on the countdown
//   notifier.dispose();    // cancel internal timer

import 'dart:async';

import 'package:flutter/foundation.dart';

/// A [ChangeNotifier] that enforces a cooldown period after each resend.
///
/// [cooldownDuration] defaults to 60 seconds. Pass a lower value in tests
/// to keep them fast.
class ResendRateLimitNotifier extends ChangeNotifier {
  ResendRateLimitNotifier({this.cooldownDuration = 60});

  /// Total cooldown in seconds.
  final int cooldownDuration;

  int _remainingSeconds = 0;
  Timer? _timer;

  /// `true` while the user must wait before sending again.
  bool get isOnCooldown => _remainingSeconds > 0;

  /// Seconds remaining on the current cooldown (0 when not on cooldown).
  int get remainingSeconds => _remainingSeconds;

  /// Call this immediately after a resend attempt (successful or not) to start
  /// the countdown. Resets an existing countdown if called again mid-flight.
  void markSent() {
    _timer?.cancel();
    _remainingSeconds = cooldownDuration;
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds <= 0) {
        _timer?.cancel();
        return;
      }
      _remainingSeconds -= 1;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
