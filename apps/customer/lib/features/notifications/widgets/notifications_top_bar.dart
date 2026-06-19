// Top bar for the notifications screen: back, title and "mark all read".
// Extracted from notifications_screen.dart.

import 'package:customer/features/notifications/notifications_cubit.dart';
import 'package:customer/features/notifications/notifications_style.dart';
import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key, required this.unreadCount});

  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 4, 8, 0),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              color: mdOnSurface,
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: Text(
                AppLocalizations.of(context).notifTitle,
                style: const TextStyle(
                  color: mdOnSurface,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (unreadCount > 0)
              TextButton(
                onPressed: () =>
                    context.read<NotificationsCubit>().markAllRead(),
                child: Text(
                  AppLocalizations.of(context).notifMarkAllRead,
                  style: const TextStyle(color: mdPrimary, fontSize: 14),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
