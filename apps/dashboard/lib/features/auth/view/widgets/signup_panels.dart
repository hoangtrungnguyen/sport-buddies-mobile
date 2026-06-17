import 'package:dashboard/features/auth/auth_validators.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spb_core/core/theme/app_colors.dart';

import '../auth_scaffold.dart';

/// The signup form: email + password + confirm fields, error banner, submit
/// button and the back-to-login link. Stateless — the host screen owns the
/// controllers, obscure toggles and submit handler.
class SignupFormPanel extends StatelessWidget {
  const SignupFormPanel({
    super.key,
    required this.formKey,
    required this.emailCtrl,
    required this.passCtrl,
    required this.confirmCtrl,
    required this.obscurePass,
    required this.obscureConfirm,
    required this.onTogglePass,
    required this.onToggleConfirm,
    required this.errorMsg,
    required this.loading,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;
  final TextEditingController confirmCtrl;
  final bool obscurePass;
  final bool obscureConfirm;
  final VoidCallback onTogglePass;
  final VoidCallback onToggleConfirm;
  final String? errorMsg;
  final bool loading;
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
                  Text(
                    'Tạo tài khoản',
                    style: GoogleFonts.sora(
                      fontWeight: FontWeight.w800,
                      fontSize: 28,
                      letterSpacing: -0.5,
                      color: AppColors.neutral900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Đăng ký tài khoản chủ sân để bắt đầu với SportBuddies.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: AppColors.neutral500,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Error banner
                  if (errorMsg != null) ...[
                    AuthErrorBanner(message: errorMsg!),
                    const SizedBox(height: 16),
                  ],

                  // Email
                  const AuthFieldLabel(label: 'Email'),
                  const SizedBox(height: 6),
                  Semantics(
                    label: 'signup-email-field',
                    textField: true,
                    child: TextFormField(
                      controller: emailCtrl,
                      keyboardType: kIsWeb
                          ? TextInputType.text
                          : TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      style: GoogleFonts.plusJakartaSans(fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'chusan@example.com',
                      ),
                      validator: validateEmail,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Password
                  const AuthFieldLabel(label: 'Mật khẩu'),
                  const SizedBox(height: 6),
                  Semantics(
                    label: 'signup-password-field',
                    textField: true,
                    child: TextFormField(
                      controller: passCtrl,
                      obscureText: obscurePass,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.newPassword],
                      style: GoogleFonts.plusJakartaSans(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Ít nhất 8 ký tự, gồm chữ và số',
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePass
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 18,
                            color: AppColors.neutral400,
                          ),
                          onPressed: onTogglePass,
                        ),
                      ),
                      validator: validateSignupPassword,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Confirm password
                  const AuthFieldLabel(label: 'Xác nhận mật khẩu'),
                  const SizedBox(height: 6),
                  Semantics(
                    label: 'signup-confirm-password-field',
                    textField: true,
                    child: TextFormField(
                      controller: confirmCtrl,
                      obscureText: obscureConfirm,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.newPassword],
                      style: GoogleFonts.plusJakartaSans(fontSize: 14),
                      onFieldSubmitted: (_) => onSubmit(),
                      decoration: InputDecoration(
                        hintText: 'Nhập lại mật khẩu',
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureConfirm
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 18,
                            color: AppColors.neutral400,
                          ),
                          onPressed: onToggleConfirm,
                        ),
                      ),
                      validator: (v) =>
                          validateConfirmPassword(passCtrl.text, v),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit
                  Semantics(
                    label: 'signup-submit-btn',
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
                          : const Text('Đăng ký'),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Back-to-login link
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Đã có tài khoản? ',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: AppColors.neutral500,
                          ),
                        ),
                        Semantics(
                          label: 'signup-to-login-btn',
                          button: true,
                          child: TextButton(
                            onPressed: () => goToLogin(context),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Đăng nhập',
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Shown after a 201. Adapts to the backend mode: when the account needs email
/// verification, prompt the owner to check their inbox; when it is
/// auto-confirmed, tell them it is ready to log in.
class SignupSuccessPanel extends StatelessWidget {
  const SignupSuccessPanel({
    super.key,
    required this.email,
    required this.requiresVerification,
  });
  final String email;
  final bool requiresVerification;

  @override
  Widget build(BuildContext context) {
    final heading = requiresVerification
        ? 'Kiểm tra email của bạn'
        : 'Tạo tài khoản thành công!';
    final body = requiresVerification
        ? 'Chúng tôi đã gửi một liên kết xác minh tới $email. '
            'Vui lòng xác minh email trước khi đăng nhập.'
        : 'Tài khoản $email đã sẵn sàng. Đăng nhập để bắt đầu.';
    final icon = requiresVerification
        ? Icons.mark_email_unread_rounded
        : Icons.check_circle_rounded;

    return Container(
      color: AppColors.surface,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Semantics(
              label: 'signup-success',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withValues(alpha: 0.12),
                    ),
                    child: Icon(
                      icon,
                      color: AppColors.primary,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    heading,
                    style: GoogleFonts.sora(
                      fontWeight: FontWeight.w800,
                      fontSize: 24,
                      letterSpacing: -0.5,
                      color: AppColors.neutral900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    body,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: AppColors.neutral500,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Semantics(
                    label: 'signup-success-to-login-btn',
                    button: true,
                    child: ElevatedButton(
                      onPressed: () => goToLogin(context),
                      child: const Text('Đến trang đăng nhập'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Navigates back to login. Uses [GoRouter.go] to clear the signup route from
/// the stack so the back button doesn't return to the form.
void goToLogin(BuildContext context) => context.go('/login');
