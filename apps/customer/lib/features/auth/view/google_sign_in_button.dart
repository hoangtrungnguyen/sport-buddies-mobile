// GoogleSignInButton — CAPP-011 / grava-144f.2.1
//
// Renders a "Sign in with Google" button that dispatches
// [GoogleSignInRequested] to the nearest [AuthBloc].
//
// Handles:
//   - AuthLoading  → shows CircularProgressIndicator, disables button
//   - AuthSuccess  → navigates to '/' via go_router
//   - AuthFailureState → shows SnackBar with error message

import 'package:customer/features/auth/bloc/auth_bloc.dart';
import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (_, current) =>
          current is AuthSuccess || current is AuthFailureState,
      listener: (context, state) {
        if (state is AuthSuccess) {
          context.go('/');
        } else if (state is AuthFailureState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      buildWhen: (previous, current) =>
          current is AuthLoading ||
          current is AuthInitial ||
          current is AuthSuccess ||
          current is AuthFailureState,
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return OutlinedButton(
          key: const Key('googleSignInButton'),
          onPressed: isLoading
              ? null
              : () => context
                  .read<AuthBloc>()
                  .add(const GoogleSignInRequested()),
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF111827),
            side: const BorderSide(color: Color(0xFFD1D5DB)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
            minimumSize: const Size.fromHeight(48),
            elevation: 0,
          ),
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF111827),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CustomPaint(
                      size: Size(18, 18),
                      painter: GoogleLogoPainter(),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      l10n.continueWithGoogle,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class GoogleLogoPainter extends CustomPainter {
  const GoogleLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Draw top arc (Red)
    final paintRed = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.square;
    canvas.drawArc(
      Rect.fromLTWH(0, 0, w, h),
      -3.14159 * 0.95,
      3.14159 * 0.9,
      false,
      paintRed,
    );

    // Draw bottom arc (Green)
    final paintGreen = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.square;
    canvas.drawArc(
      Rect.fromLTWH(0, 0, w, h),
      3.14159 * 0.05,
      3.14159 * 0.9,
      false,
      paintGreen,
    );

    // Draw left arc (Yellow)
    final paintYellow = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.square;
    canvas.drawArc(
      Rect.fromLTWH(0, 0, w, h),
      3.14159 * 0.75,
      3.14159 * 0.5,
      false,
      paintYellow,
    );

    // Draw right arc (Blue)
    final paintBlue = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.square;
    canvas.drawArc(
      Rect.fromLTWH(0, 0, w, h),
      -3.14159 * 0.25,
      3.14159 * 0.5,
      false,
      paintBlue,
    );

    // Draw horizontal bar (Blue)
    final paintBlueBar = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.square;
    canvas.drawLine(
      Offset(w / 2 - 1, h / 2),
      Offset(w - 1.5, h / 2),
      paintBlueBar,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
