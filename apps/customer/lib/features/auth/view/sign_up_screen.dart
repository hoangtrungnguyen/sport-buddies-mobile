import 'package:customer/features/auth/bloc/auth_bloc.dart';
import 'package:customer/features/auth/view/resend_rate_limit_notifier.dart';
import 'package:customer/l10n/app_localizations.dart';
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
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  int _passwordStrength = 0;

  String? _pendingVerificationEmail;
  late final ResendRateLimitNotifier _rateLimitNotifier;

  @override
  void initState() {
    super.initState();
    _rateLimitNotifier = ResendRateLimitNotifier();
    _passwordController.addListener(_updateStrength);
  }

  void _updateStrength() {
    final s = _computeStrength(_passwordController.text);
    if (s != _passwordStrength) setState(() => _passwordStrength = s);
  }

  int _computeStrength(String p) {
    if (p.isEmpty) return 0;
    if (p.length < 8) return 1;
    final hasLetter = p.contains(RegExp(r'[a-zA-Z]'));
    final hasDigit = p.contains(RegExp(r'[0-9]'));
    return (hasLetter && hasDigit) ? 3 : 2;
  }

  @override
  void dispose() {
    _passwordController.removeListener(_updateStrength);
    _fullNameController.dispose();
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
              fullName: _fullNameController.text.trim(),
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
    context.read<AuthBloc>().add(ResendVerificationRequested(email: email));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            setState(() {
              _pendingVerificationEmail = _emailController.text.trim();
              _rateLimitNotifier.markSent();
            });
          } else if (state is VerificationEmailSent) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context).resendVerification),
              ),
            );
          } else if (state is AuthFailureState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            child: _pendingVerificationEmail != null
                ? _VerifyEmailPanel(
                    email: _pendingVerificationEmail!,
                    rateLimitNotifier: _rateLimitNotifier,
                    onResend: () => _onResend(context),
                    onBackToLogin: () => context.go('/login'),
                  )
                : _SignUpForm(
                    formKey: _formKey,
                    fullNameController: _fullNameController,
                    emailController: _emailController,
                    passwordController: _passwordController,
                    confirmPasswordController: _confirmPasswordController,
                    obscurePassword: _obscurePassword,
                    obscureConfirm: _obscureConfirm,
                    passwordStrength: _passwordStrength,
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

class _SignUpForm extends StatelessWidget {
  const _SignUpForm({
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
            l10n.signUpTitle,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
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

class _VerifyEmailPanel extends StatelessWidget {
  const _VerifyEmailPanel({
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
