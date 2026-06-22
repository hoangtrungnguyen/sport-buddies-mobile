// Sign-up form body (name / email / password / confirm + strength meter and
// submit). Extracted from sign_up_screen.dart; the screen owns the controllers
// and state, this widget is pure presentation driven by callbacks.

import 'package:customer/features/auth/bloc/auth_bloc.dart';
import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignUpForm extends StatelessWidget {
  const SignUpForm({
    super.key,
    required this.formKey,
    required this.fullNameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.obscurePassword,
    required this.obscureConfirm,
    required this.passwordStrength,
    required this.onTogglePassword,
    required this.onToggleConfirm,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController fullNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool obscurePassword;
  final bool obscureConfirm;
  final int passwordStrength;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirm;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.signUpSubtitle,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          TextFormField(
            key: const Key('signUpFullNameField'),
            controller: fullNameController,
            decoration: InputDecoration(
              labelText: l10n.labelFullName,
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.person_outline),
            ),
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            validator: (v) =>
                validateFullName(v, emptyMessage: l10n.errorFullNameEmpty),
          ),
          const SizedBox(height: 16),
          TextFormField(
            key: const Key('signUpEmailField'),
            controller: emailController,
            decoration: InputDecoration(
              labelText: l10n.labelEmail,
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.email_outlined),
            ),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: (v) =>
                validateEmail(v, emptyMessage: l10n.errorEmailEmpty),
          ),
          const SizedBox(height: 16),
          TextFormField(
            key: const Key('signUpPasswordField'),
            controller: passwordController,
            decoration: InputDecoration(
              labelText: l10n.labelPassword,
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: onTogglePassword,
              ),
            ),
            obscureText: obscurePassword,
            textInputAction: TextInputAction.next,
            validator: (v) =>
                validatePassword(v, weakMessage: l10n.errorPasswordWeak),
          ),
          const SizedBox(height: 8),
          _PasswordStrengthBar(strength: passwordStrength),
          const SizedBox(height: 4),
          Text(
            l10n.passwordHint,
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 8),
          TextFormField(
            key: const Key('signUpConfirmPasswordField'),
            controller: confirmPasswordController,
            decoration: InputDecoration(
              labelText: l10n.labelConfirmPassword,
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  obscureConfirm
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: onToggleConfirm,
              ),
            ),
            obscureText: obscureConfirm,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => onSubmit(),
            validator: (value) => validateConfirmPassword(
              passwordController.text,
              value ?? '',
              mismatchMessage: l10n.errorPasswordMismatch,
            ),
          ),
          const SizedBox(height: 28),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final isLoading = state is AuthLoading;
              return FilledButton(
                key: const Key('signUpButton'),
                onPressed: isLoading ? null : onSubmit,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(l10n.signUpButton),
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            l10n.signUpTerms,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Password strength bar
// ---------------------------------------------------------------------------

class _PasswordStrengthBar extends StatelessWidget {
  const _PasswordStrengthBar({required this.strength});

  final int strength; // 0–3

  static Color _barColor(int barIndex, int s) {
    if (barIndex + 1 > s) return const Color(0xFFE5E7EB);
    return switch (s) {
      1 => const Color(0xFFEF4444),
      2 => const Color(0xFFEAB308),
      _ => const Color(0xFF22C55E),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < 3; i++) ...[
          if (i > 0) const SizedBox(width: 4),
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 4,
              decoration: BoxDecoration(
                color: _barColor(i, strength),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
