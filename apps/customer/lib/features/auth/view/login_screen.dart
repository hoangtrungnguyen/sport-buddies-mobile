import 'package:customer/core/env/env.dart';
import 'package:customer/features/auth/bloc/auth_bloc.dart';
import 'package:customer/features/auth/view/court_lines_painter.dart';
import 'package:customer/features/auth/view/google_sign_in_button.dart';
import 'package:customer/features/auth/view/resend_rate_limit_notifier.dart';
import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:spb_core/core/theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController =
      TextEditingController(text: kDebugMode ? Env.bypassEmail : '');
  final _passwordController =
      TextEditingController(text: kDebugMode ? Env.bypassPassword : '');
  bool _obscurePassword = true;

  late final ResendRateLimitNotifier _resendRateLimitNotifier;

  @override
  void initState() {
    super.initState();
    _resendRateLimitNotifier = ResendRateLimitNotifier();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _resendRateLimitNotifier.dispose();
    super.dispose();
  }

  void _onSubmit(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            LoginSubmitted(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }

  void _onResendVerification(BuildContext context) {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).errorEmailEmpty)),
      );
      return;
    }
    _resendRateLimitNotifier.markSent();
    context.read<AuthBloc>().add(ResendVerificationRequested(email: email));
  }

  String _formatSeconds(int s) {
    final m = s ~/ 60;
    final sec = s % 60;
    return '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            context.go('/');
          } else if (state is VerificationEmailSent) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.resendVerification)),
            );
          } else if (state is AuthFailureState) {
            final String displayMessage;
            if (state.message == 'invalid_credentials') {
              displayMessage = l10n.errorInvalidCredentials;
            } else if (state.message == 'email_not_confirmed') {
              displayMessage = l10n.errorEmailNotConfirmed;
            } else {
              displayMessage = state.message;
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(displayMessage)),
            );
          }
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _HeroBanner(heroTitle: l10n.loginHeroTitle),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.loginTitle,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.loginSubtitle,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        key: const Key('loginEmailField'),
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: l10n.labelEmail,
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.email_outlined),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: (v) => validateEmail(v,
                            emptyMessage: l10n.errorEmailEmpty),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        key: const Key('loginPasswordField'),
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: l10n.labelPassword,
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                            onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _onSubmit(context),
                        validator: (v) => validatePassword(v,
                            weakMessage: l10n.errorPasswordWeak),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ListenableBuilder(
                            listenable: _resendRateLimitNotifier,
                            builder: (context, _) {
                              final onCooldown =
                                  _resendRateLimitNotifier.isOnCooldown;
                              final remaining =
                                  _resendRateLimitNotifier.remainingSeconds;
                              return TextButton(
                                key: const Key('resendVerificationLink'),
                                onPressed: onCooldown
                                    ? null
                                    : () => _onResendVerification(context),
                                child: Text(
                                  onCooldown
                                      ? l10n.resendCooldown(
                                          _formatSeconds(remaining))
                                      : l10n.resendVerification,
                                  style: TextStyle(
                                    color: onCooldown
                                        ? Colors.grey
                                        : AppColors.primary,
                                  ),
                                ),
                              );
                            },
                          ),
                          TextButton(
                            key: const Key('forgotPasswordLink'),
                            onPressed: () => context.push('/forgot-password'),
                            child: Text(l10n.forgotPasswordQuestion),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          final isLoading = state is AuthLoading;
                          return FilledButton(
                            key: const Key('loginButton'),
                            onPressed:
                                isLoading ? null : () => _onSubmit(context),
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(l10n.loginButton),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              l10n.orDivider,
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const GoogleSignInButton(),
                      const SizedBox(height: 16),
                      Center(
                        child: TextButton(
                          key: const Key('goToSignUpLink'),
                          onPressed: () => context.go('/signup'),
                          child: RichText(
                            text: TextSpan(
                              style: Theme.of(context).textTheme.bodyMedium,
                              children: [
                                TextSpan(text: '${l10n.noAccountPrompt} '),
                                TextSpan(
                                  text: l10n.signUpNow,
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.heroTitle});

  final String heroTitle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF16A34A),
                    Color(0xFF15803D),
                  ],
                ),
              ),
            ),
          ),
          const Positioned.fill(
            child: CustomPaint(
              painter: CourtLinesPainter(),
            ),
          ),
          Positioned(
            left: 24,
            bottom: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SPORTBUDDIES',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  heroTitle.replaceAll('\n', ' '),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
