// Slot list body, empty-state and error views for the open-slot list screen.
// Extracted from open_slot_list_screen.dart.

import 'package:customer/features/slots/widgets/open_slot_card.dart';
import 'package:customer/l10n/app_localizations.dart';
import 'package:customer/features/slots/slots_style.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:spb_core/spb_core.dart';

class SlotBody extends StatelessWidget {
  const SlotBody({super.key, required this.slots});

  final List<Slot> slots;

  @override
  Widget build(BuildContext context) {
    if (slots.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: const _EmptyView(),
          ),
        ],
      );
    }
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      itemCount: slots.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        if (i == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              AppLocalizations.of(context).slotsCountSort(slots.length),
              style: const TextStyle(fontSize: 12, color: mdOnSurfaceVariant),
            ),
          );
        }
        return SlotCard(
          slot: slots[i - 1],
          onTap: () => context.push('/slot/${slots[i - 1].id}'),
        );
      },
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: mdSurfaceContainer,
                borderRadius: BorderRadius.circular(mdCornerMd),
              ),
              child: const Icon(
                Icons.group_outlined,
                size: 36,
                color: mdOnSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.slotsEmptyTitle,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: mdOnSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.slotsEmptyBody,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: mdOnSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(message, style: const TextStyle(color: mdOnSurfaceVariant)),
    );
  }
}
