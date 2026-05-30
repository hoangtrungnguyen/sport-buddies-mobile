// UNUSED — kept for reference only. Superseded by the contact-admin dialog
// (showContactSupportDialog in contact_support_dialog.dart): the login screen's
// "Quên mật khẩu?" no longer routes here, so this self-service Supabase reset
// screen is reachable only by direct URL. Tracking: Plane OWNER-55 (Cancelled).
import 'package:dashboard/features/auth/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart';
import 'package:spb_core/core/theme/app_colors.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  String? _errorMsg;
  bool _sent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() => _errorMsg = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<AuthBloc>().add(
          AuthEvent.forgotPasswordRequested(email: _emailCtrl.text.trim()),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        switch (state) {
          case PasswordResetSent():
            setState(() => _sent = true);
          case AuthRejected(:final message):
            setState(() => _errorMsg = message);
          default:
            break;
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.neutral50,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, size: 20),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Đặt lại mật khẩu',
            style: GoogleFonts.sora(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: AppColors.neutral900,
            ),
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: _sent ? _SuccessView() : _FormView(
                formKey: _formKey,
                emailCtrl: _emailCtrl,
                errorMsg: _errorMsg,
                onSubmit: _submit,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FormView extends StatelessWidget {
  const _FormView({
    required this.formKey,
    required this.emailCtrl,
    required this.errorMsg,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final String? errorMsg;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Đặt lại mật khẩu',
            style: GoogleFonts.sora(
              fontWeight: FontWeight.w800,
              fontSize: 26,
              letterSpacing: -0.4,
              color: AppColors.neutral900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Nhập email tài khoản của bạn. Chúng tôi sẽ gửi link đặt lại mật khẩu.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: AppColors.neutral500,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),

          if (errorMsg != null) ...[
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.dangerBg,
                borderRadius: BorderRadius.circular(10),
                border:
                    Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
              ),
              child: Text(
                errorMsg!,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 13, color: AppColors.dangerDark),
              ),
            ),
            const SizedBox(height: 16),
          ],

          Text(
            'Email',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.neutral700,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: emailCtrl,
            keyboardType: kIsWeb ? TextInputType.text : TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => onSubmit(),
            style: GoogleFonts.plusJakartaSans(fontSize: 14),
            decoration:
                const InputDecoration(hintText: 'chusân@example.com'),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Vui lòng nhập email.';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

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
                    : const Text('Gửi link đặt lại'),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.successBg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.mark_email_read_outlined,
              size: 30, color: AppColors.primary),
        ),
        const SizedBox(height: 20),
        Text(
          'Đã gửi link đặt lại',
          style: GoogleFonts.sora(
            fontWeight: FontWeight.w800,
            fontSize: 22,
            color: AppColors.neutral900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Kiểm tra hộp thư của bạn và bấm vào link trong email để đặt lại mật khẩu.',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: AppColors.neutral500,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 28),
        OutlinedButton(
          onPressed: () => context.go('/login'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.neutral200),
            minimumSize: const Size.fromHeight(44),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text('Quay lại đăng nhập'),
        ),
      ],
    );
  }
}
