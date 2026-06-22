import 'package:customer/features/auth/bloc/auth_bloc.dart';
import 'package:customer/features/auth/view/auth_app_bar.dart';
import 'package:customer/features/auth/view/resend_rate_limit_notifier.dart';
import 'package:customer/features/auth/view/sign_up_form.dart';
import 'package:customer/features/auth/view/verify_email_panel.dart';
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
    final l10n = AppLocalizations.of(context);
    final isVerifying = _pendingVerificationEmail != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AuthAppBar(
        title: isVerifying ? l10n.verifyEmailAppBarTitle : l10n.signUpTitle,
        isCloseButton: isVerifying,
        onLeadingPressed: () => context.go('/login'),
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
                ? VerifyEmailPanel(
                    email: _pendingVerificationEmail!,
                    rateLimitNotifier: _rateLimitNotifier,
                    onResend: () => _onResend(context),
                    onBackToLogin: () => context.go('/login'),
                  )
                : SignUpForm(
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
