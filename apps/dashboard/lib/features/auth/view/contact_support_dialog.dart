import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spb_core/core/theme/app_colors.dart';

/// Support contact an owner reaches out to for a password reset.
///
/// Self-service password reset is intentionally disabled for the owner
/// dashboard — an administrator changes the password on request.
const String kSupportContact = 'hoangtrungnguyen18102000@gmail.com';

/// Shows the "contact us to reset your password" dialog. Used in place of a
/// self-service reset flow (OWNER-55).
Future<void> showContactSupportDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (_) => const _ContactSupportDialog(),
  );
}

class _ContactSupportDialog extends StatelessWidget {
  const _ContactSupportDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Semantics(
          label: 'forgot-password-dialog',
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _icon(),
                const SizedBox(height: 16),
                Text(
                  'Đặt lại mật khẩu',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.sora(
                    fontWeight: FontWeight.w800,
                    fontSize: 19,
                    letterSpacing: -0.3,
                    color: AppColors.neutral900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Vì lý do bảo mật, mật khẩu chỉ được đặt lại bởi quản trị viên. '
                  'Vui lòng liên hệ với chúng tôi để được hỗ trợ đổi mật khẩu.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    height: 1.5,
                    color: AppColors.neutral500,
                  ),
                ),
                const SizedBox(height: 18),
                _ContactRow(),
                const SizedBox(height: 20),
                _closeButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Tinted circular lock-reset avatar at the top of the dialog.
  Widget _icon() {
    return Center(
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary.withValues(alpha: 0.12),
        ),
        child: const Icon(
          Icons.lock_reset_rounded,
          color: AppColors.primary,
          size: 28,
        ),
      ),
    );
  }

  /// "Đã hiểu" — dismisses the dialog.
  Widget _closeButton(BuildContext context) {
    return Semantics(
      label: 'forgot-password-dialog-close-btn',
      button: true,
      child: ElevatedButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Đã hiểu'),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.email_outlined, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            // No Semantics label wrapper — let SelectableText expose the email
            // itself to the accessibility tree (and to automation).
            child: SelectableText(
              kSupportContact,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.neutral900,
              ),
            ),
          ),
          Semantics(
            label: 'forgot-password-copy-btn',
            button: true,
            child: IconButton(
              icon: const Icon(Icons.copy_rounded, size: 18),
              color: AppColors.neutral400,
              tooltip: 'Sao chép',
              visualDensity: VisualDensity.compact,
              onPressed: () {
                Clipboard.setData(const ClipboardData(text: kSupportContact));
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    const SnackBar(
                      content: Text('Đã sao chép email liên hệ'),
                      duration: Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
              },
            ),
          ),
        ],
      ),
    );
  }
}
