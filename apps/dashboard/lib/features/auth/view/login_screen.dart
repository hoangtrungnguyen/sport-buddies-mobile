import 'package:dashboard/features/auth/bloc/auth_bloc.dart';
import 'package:dashboard/features/auth/view/auth_scaffold.dart';
import 'package:dashboard/features/auth/view/contact_support_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart';
import 'package:spb_core/core/theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

// Dev credential pre-fill — pass via --dart-define=DEV_EMAIL=x --dart-define=DEV_PASSWORD=y
const _kDevEmail = String.fromEnvironment('DEV_EMAIL');
const _kDevPassword = String.fromEnvironment('DEV_PASSWORD');

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl =
      TextEditingController(text: _kDevEmail.isNotEmpty ? _kDevEmail : '');
  final _passCtrl = TextEditingController(
      text: _kDevPassword.isNotEmpty ? _kDevPassword : '');
  bool _obscure = true;
  String? _errorMsg;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() => _errorMsg = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<AuthBloc>().add(
          AuthEvent.loginSubmitted(
            email: _emailCtrl.text.trim(),
            password: _passCtrl.text,
          ),
        );
  }

  String _mapError(String key) => switch (key) {
        'invalid_credentials' => 'Email hoặc mật khẩu không đúng.',
        'email_not_verified' =>
          'Email của bạn chưa được xác minh. Vui lòng kiểm tra hộp thư và '
              'xác minh email trước khi đăng nhập.',
        'access_denied' =>
          'Tài khoản không có quyền truy cập bảng điều khiển chủ sân.',
        'invalid_input' => 'Thông tin đăng nhập không hợp lệ.',
        'service_unavailable' =>
          'Dịch vụ tạm thời không khả dụng. Vui lòng thử lại sau.',
        'network' =>
          'Không thể kết nối tới máy chủ. Vui lòng kiểm tra mạng và thử lại.',
        'login_failed' => 'Đăng nhập thất bại. Vui lòng thử lại.',
        'unknown' => 'Đã xảy ra lỗi. Vui lòng thử lại.',
        _ => key,
      };

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        switch (state) {
          case AuthRejected(:final message):
            setState(() => _errorMsg = _mapError(message));
          case AuthAuthenticated():
            context.go('/');
          default:
            break;
        }
      },
      child: AuthLayout(
        form: _FormPanel(
          formKey: _formKey,
          emailCtrl: _emailCtrl,
          passCtrl: _passCtrl,
          obscure: _obscure,
          onToggleObscure: () => setState(() => _obscure = !_obscure),
          errorMsg: _errorMsg,
          onSubmit: _submit,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Login form panel
// ---------------------------------------------------------------------------

class _FormPanel extends StatelessWidget {
  const _FormPanel({
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
                    label: 'login-email-field',
                    textField: true,
                    child: TextFormField(
                      controller: emailCtrl,
                      keyboardType: kIsWeb ? TextInputType.text : TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      style: GoogleFonts.plusJakartaSans(fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'chusan@example.com',
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Vui lòng nhập email.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Password
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const AuthFieldLabel(label: 'Mật khẩu'),
                      Semantics(
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
                    ],
                  ),
                  const SizedBox(height: 6),
                  Semantics(
                    label: 'login-password-field',
                    textField: true,
                    child: TextFormField(
                      controller: passCtrl,
                      obscureText: obscure,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      style: GoogleFonts.plusJakartaSans(fontSize: 14),
                      onFieldSubmitted: (_) => onSubmit(),
                      decoration: InputDecoration(
                        hintText: 'Nhập mật khẩu',
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 18,
                            color: AppColors.neutral400,
                          ),
                          onPressed: onToggleObscure,
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Vui lòng nhập mật khẩu.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit
                  BlocBuilder<AuthBloc, AuthState>(
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
                  ),

                  const SizedBox(height: 20),

                  // Sign-up link
                  Center(
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
                  ),

                  const SizedBox(height: 20),

                  // Footer
                  Center(
                    child: Text(
                      'Chỉ dành cho chủ sân SportBuddies.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        color: AppColors.neutral400,
                      ),
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
