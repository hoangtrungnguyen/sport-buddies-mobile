import 'package:dashboard/features/auth/bloc/auth_bloc.dart';
import 'package:dashboard/features/auth/view/auth_scaffold.dart';
import 'package:dashboard/features/auth/view/widgets/login_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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
        form: LoginFormPanel(
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
