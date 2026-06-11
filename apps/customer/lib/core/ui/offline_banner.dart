import 'package:customer/core/services/connectivity_service.dart';
import 'package:flutter/material.dart';

/// Wraps the whole app and surfaces a banner whenever the device has no
/// internet, so users always know they're offline instead of meeting silent
/// failures or raw errors.
///
/// This widget is a pure **observer** of [ConnectivityService] (the Subject):
/// it owns one instance, listens for status changes, and rebuilds. When the
/// service reports the internet is back it flips [ConnectivityService.isOnline]
/// to true and the banner dismisses itself.
///
/// Mounted via `MaterialApp.router(builder: ...)` so it sits above every
/// route — tabs, login, booking flow alike.
class OfflineBanner extends StatefulWidget {
  const OfflineBanner({super.key, required this.child, this.service});

  final Widget child;

  /// Injectable for tests; defaults to a self-owned [ConnectivityService].
  final ConnectivityService? service;

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> {
  late final ConnectivityService _service;
  bool _ownsService = false;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? ConnectivityService();
    _ownsService = widget.service == null;
    _service.addListener(_onStatusChanged);
    _service.start();
  }

  void _onStatusChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _service.removeListener(_onStatusChanged);
    if (_ownsService) _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _service.isOnline
              ? const SizedBox.shrink()
              : const _OfflineBar(),
        ),
        Expanded(child: widget.child),
      ],
    );
  }
}

class _OfflineBar extends StatelessWidget {
  const _OfflineBar();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFB91C1C),
      child: SafeArea(
        bottom: false,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 16),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off_rounded, size: 16, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Không có kết nối internet',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
