import 'package:dashboard/features/auth/bloc/signup_bloc.dart';
import 'package:dashboard/features/auth/view/auth_scaffold.dart';
import 'package:dashboard/features/auth/view/widgets/signup_panels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  String? _errorMsg;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() => _errorMsg = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<SignupBloc>().add(
          SignupEvent.submitted(
            email: _emailCtrl.text.trim(),
            password: _passCtrl.text,
            confirmPassword: _confirmCtrl.text,
          ),
        );
  }

  String _mapError(String key) => switch (key) {
        'email_already_registered' =>
          'Email này đã được đăng ký. Vui lòng đăng nhập.',
        'invalid_input' =>
          'Thông tin đăng ký không hợp lệ. Vui lòng kiểm tra lại.',
        'service_unavailable' =>
          'Dịch vụ tạm thời không khả dụng. Vui lòng thử lại sau.',
        'network' =>
          'Không thể kết nối tới máy chủ. Vui lòng kiểm tra mạng và thử lại.',
        'unknown' => 'Đã xảy ra lỗi không mong muốn. Vui lòng thử lại.',
        _ => key, // client-side validation messages pass through verbatim
      };

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SignupBloc, SignupState>(
      listener: (context, state) {
        if (state is SignupRejected) {
          setState(() => _errorMsg = _mapError(state.message));
        }
      },
      builder: (context, state) {
        return AuthLayout(
          form: switch (state) {
            SignupSuccess(:final email, :final requiresVerification) =>
              SignupSuccessPanel(
                email: email,
                requiresVerification: requiresVerification,
              ),
            _ => SignupFormPanel(
                formKey: _formKey,
                emailCtrl: _emailCtrl,
                passCtrl: _passCtrl,
                confirmCtrl: _confirmCtrl,
                obscurePass: _obscurePass,
                obscureConfirm: _obscureConfirm,
                onTogglePass: () =>
                    setState(() => _obscurePass = !_obscurePass),
                onToggleConfirm: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
                errorMsg: _errorMsg,
                loading: state is SignupSubmitting,
                onSubmit: _submit,
              ),
          },
        );
      },
    );
  }
}
