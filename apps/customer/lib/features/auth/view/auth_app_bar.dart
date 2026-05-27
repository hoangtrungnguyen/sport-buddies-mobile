import 'package:flutter/material.dart';

class AuthAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AuthAppBar({
    required this.title,
    this.isCloseButton = false,
    this.onLeadingPressed,
    super.key,
  });

  final String title;
  final bool isCloseButton;
  final VoidCallback? onLeadingPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 104,
      padding: const EdgeInsets.only(top: 48, left: 16, right: 16),
      color: Colors.transparent,
      alignment: Alignment.center,
      child: Row(
        children: [
          GestureDetector(
            onTap: onLeadingPressed ?? () => Navigator.of(context).maybePop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Icon(
                isCloseButton ? Icons.close : Icons.chevron_left,
                size: 20,
                color: const Color(0xFF111827),
              ),
            ),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF111827),
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.05,
              ),
            ),
          ),
          const SizedBox(width: 40), // Balances the leading button to keep title centered
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(104);
}
