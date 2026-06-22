// Post-sign-up "check your email" panel with a rate-limited resend button.
// Extracted from sign_up_screen.dart; the screen owns the pending-email state.

import 'package:customer/features/auth/bloc/auth_bloc.dart';
import 'package:customer/features/auth/view/resend_rate_limit_notifier.dart';
import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VerifyEmailPanel extends StatelessWidget {
  const VerifyEmailPanel({
    super.key,
    required this.email,
    required this.rateLimitNotifier,
    required this.onResend,
    required this.onBackToLogin,
  });

  final String email;
  final ResendRateLimitNotifier rateLimitNotifier;
  final VoidCallback onResend;
  final VoidCallback onBackToLogin;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        const SizedBox(height: 40),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.green[50],
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.mark_email_unread_outlined,
              size: 40, color: Colors.green[700]),
        ),
        const SizedBox(height: 24),
        Text(
          l10n.verifyEmailTitle,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          l10n.verifyEmailBody(email),
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Colors.grey[700]),
        ),
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.verifyEmailNotReceived,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.verifyEmailTips,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ListenableBuilder(
          listenable: rateLimitNotifier,
          builder: (context, _) {
            final onCooldown = rateLimitNotifier.isOnCooldown;
            final remaining = rateLimitNotifier.remainingSeconds;
            return BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                final isLoading = state is AuthLoading;
                final isDisabled = onCooldown || isLoading;
                return OutlinedButton(
                  key: const Key('resendVerificationButton'),
                  onPressed: isDisabled ? null : onResend,
                  child: Text(
                    onCooldown
                        ? l10n.resendCooldown(_formatSeconds(remaining))
                        : l10n.resendVerification,
                  ),
                );
              },
            );
          },
        ),
        const SizedBox(height: 12),
        TextButton(
          key: const Key('backToLoginLink'),
          onPressed: onBackToLogin,
          child: Text(l10n.backToLogin),
        ),
      ],
    );
  }

  String _formatSeconds(int s) {
    final m = s ~/ 60;
    final sec = s % 60;
    return '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }
}
