import 'package:dashboard/features/notifications/bloc/notification_bloc.dart';
import 'package:dashboard/features/notifications/bloc/notification_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// The active-venue context chip shown next to the breadcrumb on wide layouts.
class TopBarVenueChip extends StatelessWidget {
  const TopBarVenueChip({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration:
                BoxDecoration(shape: BoxShape.circle, color: scheme.primary),
          ),
          const SizedBox(width: 6),
          Text(
            'SnB Đại Lộc · Q7',
            style: theme.textTheme.labelMedium?.copyWith(
              color: scheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// The owner avatar at the far right of the top bar — the always-visible entry
/// point to the profile screen (`/profile`). Initials come from the live
/// Supabase session; a primary ring marks the active route.
class TopBarProfileAvatar extends StatelessWidget {
  const TopBarProfileAvatar({super.key});

  /// 1–2 letter initials for the signed-in owner — same rules as the drawer
  /// footer (metadata name → email local part → fallback).
  static String _initials() {
    User? user;
    try {
      user = Supabase.instance.client.auth.currentUser;
    } catch (_) {
      user = null;
    }
    final meta = user?.userMetadata;
    final metaName =
        (meta?['full_name'] ?? meta?['name'] ?? meta?['display_name'])
            as String?;
    final source = (metaName != null && metaName.trim().isNotEmpty)
        ? metaName.trim()
        : (user?.email?.contains('@') ?? false)
            ? user!.email!.split('@').first
            : '';
    final parts =
        source.split(RegExp(r'[\s.]+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'MN';
    if (parts.length == 1) {
      final p = parts.first;
      return (p.length >= 2 ? p.substring(0, 2) : p).toUpperCase();
    }
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final active = GoRouterState.of(context).matchedLocation == '/profile';

    return Tooltip(
      message: 'Hồ sơ',
      child: InkWell(
        onTap: () => context.go('/profile'),
        customBorder: const CircleBorder(),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: active
                ? Border.all(color: scheme.primary, width: 2)
                : null,
          ),
          padding: const EdgeInsets.all(2),
          child: CircleAvatar(
            radius: 17,
            backgroundColor: scheme.primary,
            child: Text(
              _initials(),
              style: theme.textTheme.labelMedium?.copyWith(
                color: scheme.onPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Notifications bell with a live unread-count badge from [NotificationBloc].
class TopBarBellButton extends StatelessWidget {
  const TopBarBellButton({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final unread = context.select<NotificationBloc, int>(
      (bloc) => bloc.state is NotificationLoaded
          ? (bloc.state as NotificationLoaded).unreadCount
          : 0,
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: const Icon(Symbols.notifications),
          color: scheme.onSurfaceVariant,
          onPressed: onTap,
        ),
        if (unread > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              decoration:
                  BoxDecoration(shape: BoxShape.circle, color: scheme.error),
              alignment: Alignment.center,
              child: Text(
                unread > 9 ? '9+' : unread.toString(),
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: scheme.onError,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
