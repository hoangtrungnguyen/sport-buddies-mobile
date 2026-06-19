import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../nav_model.dart';
import 'top_bar_actions.dart';
import 'top_bar_search.dart';

class TopBar extends StatelessWidget {
  const TopBar({
    super.key,
    required this.location,
    required this.onBellTap,
    this.isMobile = false,
    this.showSearch = true,
  });
  final String location;
  final VoidCallback onBellTap;
  final bool isMobile;
  final bool showSearch;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final title = kRouteTitle[location] ?? 'Trang chủ';

    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(bottom: BorderSide(color: scheme.outlineVariant)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          if (isMobile) ...[
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Symbols.menu),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
            const SizedBox(width: 4),
          ],
          _breadcrumb(theme, scheme, title),
          const Spacer(),
          if (showSearch && !isMobile) ...[
            const TopBarSearchBar(),
            const SizedBox(width: 8),
          ],
          ..._trailing(scheme),
        ],
      ),
    );
  }

  /// Title-only on compact; "Chủ sân / <title>" breadcrumb + venue chip on wide.
  Widget _breadcrumb(ThemeData theme, ColorScheme scheme, String title) {
    if (isMobile) {
      return Flexible(
        child: Text(
          title,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
      );
    }
    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Chủ sân',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text('/',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: scheme.outline)),
          ),
          Flexible(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 10),
          const TopBarVenueChip(),
        ],
      ),
    );
  }

  /// Trailing actions: mail, notifications bell, divider, profile avatar.
  List<Widget> _trailing(ColorScheme scheme) {
    return [
      IconButton(
        icon: const Icon(Symbols.mail),
        color: scheme.onSurfaceVariant,
        onPressed: () {},
      ),
      TopBarBellButton(onTap: onBellTap),
      Container(
        width: 1,
        height: 28,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        color: scheme.outlineVariant,
      ),
      const TopBarProfileAvatar(initials: 'MN'),
    ];
  }
}
