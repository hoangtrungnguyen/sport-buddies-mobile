import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Shell-less gate shown whenever there is no authenticated session — both for
/// fresh (never-signed-in) visitors and for sessions that expire mid-use. It
/// deliberately renders WITHOUT the navigation drawer/rail so an unauthenticated
/// user never sees the management surface; the only action is to sign in.
///
/// Wired as the redirect target for any protected route while
/// `auth.currentSession == null` (see `buildRouter`).
class UnauthorizedScreen extends StatelessWidget {
  const UnauthorizedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: scheme.secondaryContainer,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(Symbols.lock,
                      size: 34, fill: 1, color: scheme.onSecondaryContainer),
                ),
                const SizedBox(height: 24),
                Text(
                  'Bạn chưa đăng nhập',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Phiên đăng nhập đã hết hạn hoặc bạn chưa đăng nhập. '
                  'Vui lòng đăng nhập để tiếp tục.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: 28),
                FilledButton.icon(
                  onPressed: () => context.go('/login'),
                  icon: const Icon(Symbols.login, size: 18),
                  label: const Text('Đăng nhập'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
