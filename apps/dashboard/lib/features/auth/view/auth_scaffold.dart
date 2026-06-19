// Shared chrome for the auth screens (login, signup). Extracted so both
// screens render an identical brand panel / responsive layout and reuse the
// same field-label and banner styling.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spb_core/core/theme/app_colors.dart';

import 'auth_brand_panel.dart';

/// Responsive auth shell: a branded left panel beside [form] on wide screens,
/// or a compact brand header stacked above [form] on narrow ones.
class AuthLayout extends StatelessWidget {
  const AuthLayout({super.key, required this.form});

  /// The fully-styled form panel (e.g. login or signup form).
  final Widget form;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;
          if (isWide) {
            return Row(
              children: [
                const Expanded(child: AuthBrandPanel()),
                SizedBox(width: 480, child: form),
              ],
            );
          }
          return SingleChildScrollView(
            child: Column(
              children: [
                const AuthMobileBrandHeader(),
                form,
              ],
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reusable form bits
// ---------------------------------------------------------------------------

class AuthFieldLabel extends StatelessWidget {
  const AuthFieldLabel({super.key, required this.label});
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

class AuthErrorBanner extends StatelessWidget {
  const AuthErrorBanner({super.key, required this.message});
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

/// Field scaffold shared by the auth forms: an [AuthFieldLabel], a 6px gap,
/// then [child] wrapped in its [semanticsLabel] [Semantics] node. Pass
/// [labelTrailing] to put a widget at the right of the label row (e.g. the
/// login screen's "Quên mật khẩu?" link).
class AuthFieldGroup extends StatelessWidget {
  const AuthFieldGroup({
    super.key,
    required this.label,
    required this.semanticsLabel,
    required this.child,
    this.labelTrailing,
  });

  final String label;
  final String semanticsLabel;
  final Widget child;
  final Widget? labelTrailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (labelTrailing == null)
          AuthFieldLabel(label: label)
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [AuthFieldLabel(label: label), labelTrailing!],
          ),
        const SizedBox(height: 6),
        Semantics(label: semanticsLabel, textField: true, child: child),
      ],
    );
  }
}

/// Obscured password [TextFormField] with a visibility-toggle suffix — the
/// input shared by the login and signup password fields. The label/semantics
/// are the caller's responsibility (usually via [AuthFieldGroup]).
class AuthObscureField extends StatelessWidget {
  const AuthObscureField({
    super.key,
    required this.controller,
    required this.obscure,
    required this.onToggle,
    required this.hint,
    required this.textInputAction,
    required this.autofillHints,
    required this.validator,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;
  final String hint;
  final TextInputAction textInputAction;
  final List<String> autofillHints;
  final FormFieldValidator<String> validator;
  final VoidCallback? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      style: GoogleFonts.plusJakartaSans(fontSize: 14),
      onFieldSubmitted: onSubmitted == null ? null : (_) => onSubmitted!(),
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: IconButton(
          icon: Icon(
            obscure
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            size: 18,
            color: AppColors.neutral400,
          ),
          onPressed: onToggle,
        ),
      ),
      validator: validator,
    );
  }
}
