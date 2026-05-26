// Tests for ResendVerificationRequested event + rate-limit logic
// (CAPP-010 / grava-144f.1.5)
//
// Coverage:
// - AuthBloc handles ResendVerificationRequested event
// - Emits [AuthLoading, VerificationEmailSent] on success (no Supabase client)
// - Emits AuthValidationError when email is empty
// - ResendRateLimitNotifier tracks 60s cooldown
// - isOnCooldown is true immediately after send
// - isOnCooldown becomes false after cooldown expires
import 'package:bloc_test/bloc_test.dart';
import 'package:customer/features/auth/bloc/auth_bloc.dart';
import 'package:customer/features/auth/view/resend_rate_limit_notifier.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthBloc — ResendVerificationRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits AuthValidationError when email is empty',
      build: AuthBloc.new,
      act: (b) => b.add(const ResendVerificationRequested(email: '')),
      expect: () => [isA<AuthValidationError>()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, VerificationEmailSent] for valid email (no client)',
      build: AuthBloc.new,
      act: (b) => b.add(
        const ResendVerificationRequested(email: 'user@example.com'),
      ),
      expect: () => [isA<AuthLoading>(), isA<VerificationEmailSent>()],
    );
  });

  group('ResendRateLimitNotifier', () {
    test('isOnCooldown is false initially', () {
      final notifier = ResendRateLimitNotifier();
      expect(notifier.isOnCooldown, isFalse);
      notifier.dispose();
    });

    test('isOnCooldown is true immediately after markSent()', () {
      final notifier = ResendRateLimitNotifier();
      notifier.markSent();
      expect(notifier.isOnCooldown, isTrue);
      notifier.dispose();
    });

    test('remainingSeconds equals cooldownDuration immediately after markSent()',
        () {
      final notifier = ResendRateLimitNotifier(cooldownDuration: 60);
      notifier.markSent();
      // Allow up to 1 second of slack for test execution.
      expect(notifier.remainingSeconds, greaterThanOrEqualTo(59));
      expect(notifier.remainingSeconds, lessThanOrEqualTo(60));
      notifier.dispose();
    });

    test('isOnCooldown is false after cooldown expires (fake clock)', () async {
      // Use a short duration to keep tests fast.
      final notifier = ResendRateLimitNotifier(cooldownDuration: 1);
      notifier.markSent();
      expect(notifier.isOnCooldown, isTrue);

      // Wait for the 1-second cooldown to expire.
      await Future<void>.delayed(const Duration(seconds: 2));
      expect(notifier.isOnCooldown, isFalse);
      notifier.dispose();
    });

    test('markSent() resets countdown on repeated calls', () {
      final notifier = ResendRateLimitNotifier(cooldownDuration: 60);
      notifier.markSent();
      notifier.markSent(); // second call should reset
      expect(notifier.remainingSeconds, greaterThanOrEqualTo(59));
      notifier.dispose();
    });
  });
}
