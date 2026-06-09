import 'dart:async';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spb_core/core/theme/app_colors.dart';

/// Shared right-drawer chrome for the "Lịch sân" sheets (detail / create /
/// block) — `.overlay` + `.drawer` in the handoff CSS (`position: fixed;
/// inset: 0`).
///
/// Hosted in the ROOT overlay above the app shell (see the page's
/// `_overlayLayer`) so it fills the whole viewport: the scrim
/// (`rgba(17,24,39,.4)`, 2px blur, tap-to-dismiss) dims sidebar + topbar
/// too, and the 480px white panel slides in from the right in ~140ms at
/// full screen height. Below 1024px the panel is full-width. The sheet
/// content (head/body/foot) is the [child]'s job.
class ScheduleSideSheet extends StatefulWidget {
  const ScheduleSideSheet({
    super.key,
    required this.child,
    required this.onDismiss,
  });

  final Widget child;

  /// Called on scrim tap — dispatch `VenueScheduleEvent.sheetClosed()`.
  final VoidCallback onDismiss;

  @override
  State<ScheduleSideSheet> createState() => _ScheduleSideSheetState();
}

class _ScheduleSideSheetState extends State<ScheduleSideSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 140),
  )..forward();

  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(1, 0),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final sheetWidth = screenWidth < 1024 ? screenWidth : 480.0;
    return Stack(
      children: [
        // Scrim — rgba(17,24,39,.4) + blur(2px), tap to dismiss.
        Positioned.fill(
          child: GestureDetector(
            onTap: widget.onDismiss,
            child: FadeTransition(
              opacity: _controller,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                child: const ColoredBox(color: Color(0x66111827)),
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          bottom: 0,
          right: 0,
          width: sheetWidth,
          child: SlideTransition(
            position: _slide,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(left: BorderSide(color: AppColors.neutral200)),
                boxShadow: [
                  // --shadow-xl: 0 24px 48px rgba(17,24,39,.10)
                  BoxShadow(
                    color: Color(0x1A111827),
                    offset: Offset(0, 24),
                    blurRadius: 48,
                  ),
                ],
              ),
              child: widget.child,
            ),
          ),
        ),
      ],
    );
  }
}

/// Bottom-centre success toast (`.toast` in the handoff CSS): dark `--n-900`
/// pill, white text, green check icon.
///
/// Display is driven by `VenueScheduleState.toast` — pass it as [message];
/// renders nothing while null. Whenever a new message appears, a 3500ms timer
/// fires [onCleared] (wire it to dispatch `VenueScheduleEvent.toastCleared()`).
class ScheduleToast extends StatefulWidget {
  const ScheduleToast({
    super.key,
    required this.message,
    required this.onCleared,
  });

  final String? message;
  final VoidCallback onCleared;

  @override
  State<ScheduleToast> createState() => _ScheduleToastState();
}

class _ScheduleToastState extends State<ScheduleToast> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _restartTimer();
  }

  @override
  void didUpdateWidget(ScheduleToast oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.message != oldWidget.message) _restartTimer();
  }

  void _restartTimer() {
    _timer?.cancel();
    _timer = null;
    if (widget.message != null) {
      _timer = Timer(const Duration(milliseconds: 3500), widget.onCleared);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final message = widget.message;
    if (message == null) return const SizedBox.shrink();
    return IgnorePointer(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 24),
          // slideUp 160ms — re-runs for each new message.
          child: TweenAnimationBuilder<double>(
            key: ValueKey(message),
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            builder: (context, t, child) => Opacity(
              opacity: t,
              child: Transform.translate(
                offset: Offset(0, 12 * (1 - t)),
                child: child,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: const BoxDecoration(
                color: AppColors.neutral900,
                borderRadius: BorderRadius.all(Radius.circular(10)),
                boxShadow: [
                  // --shadow-lg: 0 12px 24px rgba(17,24,39,.08)
                  BoxShadow(
                    color: Color(0x14111827),
                    offset: Offset(0, 12),
                    blurRadius: 24,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check, size: 16, color: Color(0xFF86EFAC)),
                  const SizedBox(width: 12),
                  Text(
                    message,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
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
