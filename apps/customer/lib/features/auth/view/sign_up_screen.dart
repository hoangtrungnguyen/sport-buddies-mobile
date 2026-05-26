// SignUpScreen — CAPP-010 / grava-144f.1.1 + grava-144f.1.5
//
// Provides:
//  - Email field
//  - Password field (≥ 8 chars)
//  - Confirm password field (must match)
//  - Sign up button
//  - After sign-up success: "Check your email" panel with resend button
//    + 60-second rate-limit countdown
//
// Uses flutter_bloc + AuthBloc for state management.
// Navigates to '/' only after the user is fully authenticated (not on sign-up).

import 'package:customer/features/auth/bloc/auth_bloc.dart';
import 'package:customer/features/auth/view/resend_rate_limit_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  /// Set to the submitted email address when sign-up succeeds; drives the
  /// "check your email" view.
  String? _pendingVerificationEmail;

  late final ResendRateLimitNotifier _rateLimitNotifier;

  @override
  void initState() {
    super.initState();
    _rateLimitNotifier = ResendRateLimitNotifier();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _rateLimitNotifier.dispose();
    super.dispose();
  }

  void _onSubmit(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            SignUpSubmitted(
              email: _emailController.text.trim(),
              password: _passwordController.text,
              confirmPassword: _confirmPasswordController.text,
            ),
          );
    }
  }

  void _onResend(BuildContext context) {
    final email = _pendingVerificationEmail;
    if (email == null) return;
    _rateLimitNotifier.markSent();
    context
        .read<AuthBloc>()
        .add(ResendVerificationRequested(email: email));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            // Sign-up succeeded — show "check your email" panel instead of
            // navigating away immediately.
            setState(() {
              _pendingVerificationEmail = _emailController.text.trim();
              _rateLimitNotifier.markSent();
            });
          } else if (state is VerificationEmailSent) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Verification email resent. Check your inbox.'),
              ),
            );
          } else if (state is AuthFailureState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: _pendingVerificationEmail != null
                ? _CheckEmailPanel(
                    email: _pendingVerificationEmail!,
                    rateLimitNotifier: _rateLimitNotifier,
                    onResend: () => _onResend(context),
                  )
                : _SignUpForm(
                    formKey: _formKey,
                    emailController: _emailController,
                    passwordController: _passwordController,
                    confirmPasswordController: _confirmPasswordController,
                    obscurePassword: _obscurePassword,
                    obscureConfirm: _obscureConfirm,
                    onTogglePassword: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    onToggleConfirm: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                    onSubmit: () => _onSubmit(context),
                  ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sign-up form widget (pure presentation)
// ---------------------------------------------------------------------------

class _SignUpForm extends StatelessWidget {
  const _SignUpForm({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.obscurePassword,
    required this.obscureConfirm,
    required this.onTogglePassword,
    required this.onToggleConfirm,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool obscurePassword;
  final bool obscureConfirm;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirm;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            key: const Key('signUpEmailField'),
            controller: emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: validateEmail,
          ),
          const SizedBox(height: 16),
          TextFormField(
            key: const Key('signUpPasswordField'),
            controller: passwordController,
            decoration: InputDecoration(
              labelText: 'Password',
              border: const OutlineInputBorder(),
              helperText: 'At least 8 characters',
              suffixIcon: IconButton(
                icon: Icon(
                  obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: onTogglePassword,
              ),
            ),
            obscureText: obscurePassword,
            textInputAction: TextInputAction.next,
            validator: validatePassword,
          ),
          const SizedBox(height: 16),
          TextFormField(
            key: const Key('signUpConfirmPasswordField'),
            controller: confirmPasswordController,
            decoration: InputDecoration(
              labelText: 'Confirm password',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(
                  obscureConfirm ? Icons.visibility_off : Icons.visibility,
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
            ),
          ),
          const SizedBox(height: 32),
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
                    : const Text('Create account'),
              );
            },
          ),
          const SizedBox(height: 16),
          TextButton(
            key: const Key('goToLoginLink'),
            onPressed: () => GoRouter.of(context).go('/login'),
            child: const Text('Already have an account? Sign in'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// "Check your email" panel (shown after successful sign-up)
// ---------------------------------------------------------------------------

class _CheckEmailPanel extends StatelessWidget {
  const _CheckEmailPanel({
    required this.email,
    required this.rateLimitNotifier,
    required this.onResend,
  });

  final String email;
  final ResendRateLimitNotifier rateLimitNotifier;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.mark_email_unread_outlined, size: 64),
        const SizedBox(height: 24),
        Text(
          'Check your email',
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'We sent a verification link to $email.\nClick the link to activate your account.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
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
                        ? 'Resend in ${remaining}s'
                        : 'Resend verification email',
                  ),
                );
              },
            );
          },
        ),
        const SizedBox(height: 16),
        TextButton(
          key: const Key('backToLoginLink'),
          onPressed: () => GoRouter.of(context).go('/login'),
          child: const Text('Back to sign in'),
        ),
      ],
    );
  }
}
