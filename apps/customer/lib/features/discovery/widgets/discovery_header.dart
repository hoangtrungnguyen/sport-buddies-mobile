// Header for the discovery list screen: title, live count subtitle and the
// filter / search icon buttons. Extracted from discovery_list_screen.dart.

import 'package:customer/features/discovery/discovery_style.dart';
import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class DiscoveryHeader extends StatelessWidget {
  const DiscoveryHeader({
    super.key,
    required this.courtCount,
    required this.openSlots,
    required this.isLoading,
    required this.isEmpty,
    required this.onSearch,
    required this.onOpenFilter,
    required this.onNotifications,
  });

  final int courtCount;
  final int openSlots;
  final bool isLoading;
  final bool isEmpty;
  final VoidCallback onSearch;
  final VoidCallback onOpenFilter;
  final VoidCallback onNotifications;

  String _subtitle(AppLocalizations l10n) {
    if (isLoading) return l10n.discoveryUpdating;
    if (isEmpty) return l10n.discoveryNoMatch;
    return l10n.discoverySubtitle(courtCount, openSlots);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final topPad = MediaQuery.of(context).padding.top;
    return Container(
      color: mdSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, topPad + 12, 8, 0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.discoveryTitle,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: mdOnSurface,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _subtitle(l10n),
                        style: const TextStyle(
                          fontSize: 12,
                          color: mdOnSurfaceVariant,
                          height: 1.4,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                _HeaderIconButton(
                  label: l10n.commonFilter,
                  icon: Icons.tune,
                  onTap: onOpenFilter,
                ),
                const SizedBox(width: 8),
                _HeaderIconButton(
                  label: l10n.commonSearch,
                  icon: Icons.search,
                  onTap: onSearch,
                ),
                const SizedBox(width: 8),
                _HeaderIconButton(
                  label: l10n.commonNotifications,
                  icon: Icons.notifications_none,
                  onTap: onNotifications,
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: mdOutlineVariant),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(99),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: mdOutlineVariant),
            color: mdSurface,
          ),
          child: Icon(icon, size: 20, color: mdOnSurfaceVariant),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// CountLine
// ---------------------------------------------------------------------------
