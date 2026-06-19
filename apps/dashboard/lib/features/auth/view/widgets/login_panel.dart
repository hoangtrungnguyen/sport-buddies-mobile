import 'package:dashboard/features/auth/bloc/auth_bloc.dart';
import 'package:dashboard/features/auth/view/auth_scaffold.dart';
import 'package:dashboard/features/auth/view/contact_support_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spb_core/core/theme/app_colors.dart';

/// The login form: email + password fields, "Quên mật khẩu?" / sign-up links,
/// and a submit button that watches [AuthBloc] for its loading state. Stateless
/// — the host screen owns the controllers, obscure toggle and submit handler.
class LoginFormPanel extends StatelessWidget {
  const LoginFormPanel({
    super.key,
    required this.formKey,
    required this.emailCtrl,
    required this.passCtrl,
    required this.obscure,
    required this.onToggleObscure,
    required this.errorMsg,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;
  final bool obscure;
  final VoidCallback onToggleObscure;
  final String? errorMsg;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _header(),
                  const SizedBox(height: 32),
                  if (errorMsg != null) ...[
                    AuthErrorBanner(message: errorMsg!),
                    const SizedBox(height: 16),
                  ],
                  _emailField(),
                  const SizedBox(height: 16),
                  _passwordField(context),
                  const SizedBox(height: 24),
                  _submitButton(),
                  const SizedBox(height: 20),
                  _signupLink(context),
                  const SizedBox(height: 20),
                  _footer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// "Đăng nhập" title + subtitle.
  Widget _header() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Đăng nhập',
          style: GoogleFonts.sora(
            fontWeight: FontWeight.w800,
            fontSize: 28,
            letterSpacing: -0.5,
            color: AppColors.neutral900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Quản lý sân của bạn với SportBuddies.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: AppColors.neutral500,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _emailField() {
    return AuthFieldGroup(
      label: 'Email',
      semanticsLabel: 'login-email-field',
      child: TextFormField(
        controller: emailCtrl,
        keyboardType:
            kIsWeb ? TextInputType.text : TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        autofillHints: const [AutofillHints.email],
        style: GoogleFonts.plusJakartaSans(fontSize: 14),
        decoration: const InputDecoration(hintText: 'chusan@example.com'),
        validator: (v) {
          if (v == null || v.trim().isEmpty) return 'Vui lòng nhập email.';
          return null;
        },
      ),
    );
  }

  /// Label row (with the "Quên mật khẩu?" support link) + the obscured
  /// password field.
  Widget _passwordField(BuildContext context) {
    return AuthFieldGroup(
      label: 'Mật khẩu',
      semanticsLabel: 'login-password-field',
      labelTrailing: Semantics(
        label: 'login-forgot-password-btn',
        button: true,
        child: TextButton(
          onPressed: () => showContactSupportDialog(context),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Quên mật khẩu?',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
      child: AuthObscureField(
        controller: passCtrl,
        obscure: obscure,
        onToggle: onToggleObscure,
        hint: 'Nhập mật khẩu',
        textInputAction: TextInputAction.done,
        autofillHints: const [AutofillHints.password],
        onSubmitted: onSubmit,
        validator: (v) {
          if (v == null || v.isEmpty) return 'Vui lòng nhập mật khẩu.';
          return null;
        },
      ),
    );
  }

  /// Submit button — watches [AuthBloc] for the loading spinner.
  Widget _submitButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final loading = state is AuthLoading;
        return Semantics(
          label: 'login-submit-btn',
          button: true,
          child: ElevatedButton(
            onPressed: loading ? null : onSubmit,
            child: loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Đăng nhập'),
          ),
        );
      },
    );
  }

  Widget _signupLink(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Chưa có tài khoản? ',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: AppColors.neutral500,
            ),
          ),
          Semantics(
            label: 'login-to-signup-btn',
            button: true,
            child: TextButton(
              onPressed: () => context.push('/signup'),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Đăng ký',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _footer() {
    return Center(
      child: Text(
        'Chỉ dành cho chủ sân SportBuddies.',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12.5,
          color: AppColors.neutral400,
        ),
      ),
    );
  }
}
