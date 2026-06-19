import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/browse_pick_theme.dart';

/// Single reusable placeholder for out-of-scope edges (handoff doc 03 §5).
/// Every such tap lands here — no dead taps — with a working back button.
class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({
    super.key,
    required this.title,
    required this.subtitle,
  });

  /// 06A → "Chi tiết slot" / "EPIC-4 · SPB-035 — đang phát triển".
  /// 10  → "Đặt sân"      / "EPIC-5 · SPB-042 — đang phát triển".
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return BrowsePickTheme(
      child: Builder(
        builder: (context) {
          final scheme = Theme.of(context).colorScheme;
          final text = Theme.of(context).textTheme;
          return Scaffold(
            appBar: AppBar(
              title: Text(title),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: AppLocalizations.of(context).commonBack,
                onPressed: () => context.pop(),
              ),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.construction_rounded,
                      size: 48,
                      color: scheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: text.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
