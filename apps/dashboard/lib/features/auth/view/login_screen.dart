import 'package:dashboard/features/auth/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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
        'not_owner' =>
          'Tài khoản này không có quyền truy cập vào bảng điều khiển chủ sân.',
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
      child: Scaffold(
        backgroundColor: AppColors.neutral50,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;
            if (isWide) {
              return Row(
                children: [
                  Expanded(child: _BrandPanel()),
                  SizedBox(
                    width: 480,
                    child: _FormPanel(
                      formKey: _formKey,
                      emailCtrl: _emailCtrl,
                      passCtrl: _passCtrl,
                      obscure: _obscure,
                      onToggleObscure: () =>
                          setState(() => _obscure = !_obscure),
                      errorMsg: _errorMsg,
                      onSubmit: _submit,
                    ),
                  ),
                ],
              );
            }
            return SingleChildScrollView(
              child: Column(
                children: [
                  _MobileBrandHeader(),
                  _FormPanel(
                    formKey: _formKey,
                    emailCtrl: _emailCtrl,
                    passCtrl: _passCtrl,
                    obscure: _obscure,
                    onToggleObscure: () =>
                        setState(() => _obscure = !_obscure),
                    errorMsg: _errorMsg,
                    onSubmit: _submit,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Brand panel (desktop left column)
// ---------------------------------------------------------------------------

class _BrandPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF052E16), Color(0xFF14532D), Color(0xFF166534)],
        ),
      ),
      child: Stack(
        children: [
          // Decorative radial glow
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryMid.withValues(alpha: 0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -40,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(56),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Brand mark
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.primary, AppColors.primaryDark],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'S',
                          style: GoogleFonts.sora(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SportBuddies',
                          style: GoogleFonts.sora(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          'Bảng điều khiển chủ sân',
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFF86EFAC),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const Spacer(),

                // Tagline
                Text(
                  'Quản lý sân\nthông minh hơn.',
                  style: GoogleFonts.sora(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 40,
                    height: 1.15,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Duyệt đặt sân, xem lịch, theo dõi\ndoanh thu — tất cả trong một nơi.',
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF86EFAC),
                    fontSize: 15,
                    height: 1.6,
                    fontWeight: FontWeight.w400,
                  ),
                ),

                const SizedBox(height: 40),

                // Feature pills
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: const [
                    _FeaturePill('Duyệt đặt sân tức thì'),
                    _FeaturePill('Lịch sân 7 ngày'),
                    _FeaturePill('Thống kê doanh thu'),
                    _FeaturePill('Quản lý khách hàng'),
                  ],
                ),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  const _FeaturePill(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99),
        color: Colors.white.withValues(alpha: 0.1),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryMid,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileBrandHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 56, 24, 32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF052E16), Color(0xFF14532D)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                ),
                child: Center(
                  child: Text(
                    'S',
                    style: GoogleFonts.sora(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'SportBuddies',
                style: GoogleFonts.sora(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Quản lý sân\nthông minh hơn.',
            style: GoogleFonts.sora(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 28,
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),
        ],
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
                    _ErrorBanner(message: errorMsg!),
                    const SizedBox(height: 16),
                  ],

                  // Email
                  _FieldLabel(label: 'Email'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    style: GoogleFonts.plusJakartaSans(fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'chusân@example.com',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Vui lòng nhập email.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _FieldLabel(label: 'Mật khẩu'),
                      TextButton(
                        onPressed: () => context.push('/forgot-password'),
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
                    ],
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
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
                  const SizedBox(height: 24),

                  // Submit
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final loading = state is AuthLoading;
                      return ElevatedButton(
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
                      );
                    },
                  ),

                  const SizedBox(height: 32),

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

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.neutral700,
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.dangerBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 16, color: AppColors.danger),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppColors.dangerDark,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
