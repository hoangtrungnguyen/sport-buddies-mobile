import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../setup/model/owner_court.dart';
import '../../bloc/venue_bloc.dart';
import '../../model/venue.dart';
import '../../repository/venue_repository.dart';
import '../../util/court_format.dart';
import 'venue_bulk_ai_sheet.dart';
import 'venue_dialog.dart';

/// Right-column panel: header + add actions, and the venue list grouped by
/// sport (or loading/empty/error states from [VenueBloc]).
class VenuePanel extends StatelessWidget {
  const VenuePanel({super.key, required this.court});
  final OwnerCourt court;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return BlocBuilder<VenueBloc, VenueState>(
      builder: (context, state) {
        final venues = state is VenueLoaded ? state.venues : const <Venue>[];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sân con · ${court.name}',
                          style: theme.textTheme.titleLarge),
                      const SizedBox(height: 2),
                      Text(
                        '${venues.length} sân · mở cửa ${formatHour(court.openHour)}–${formatHour(court.closeHour)}',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                FilledButton.tonalIcon(
                  icon: const Icon(Symbols.auto_awesome, size: 18),
                  label: const Text('Tạo nhanh bằng AI'),
                  onPressed: () => openBulkAiSheet(context, court.id),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  icon: const Icon(Symbols.add, size: 18),
                  label: const Text('Thêm sân con'),
                  onPressed: () => openVenueDialog(context, court.id),
                ),
              ],
            ),
            const SizedBox(height: 16),
            switch (state) {
              VenueInitial() || VenueLoading() => const Padding(
                  padding: EdgeInsets.all(48),
                  child: Center(child: CircularProgressIndicator()),
                ),
              VenueLoaded(:final venues) when venues.isEmpty =>
                _EmptyVenues(courtId: court.id),
              VenueLoaded(:final venues) => _VenueGroups(
                  courtId: court.id, venues: venues),
              VenueFailure(:final message) => Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(message,
                      style: TextStyle(color: scheme.error)),
                ),
            },
          ],
        );
      },
    );
  }
}

class _VenueGroups extends StatelessWidget {
  const _VenueGroups({required this.courtId, required this.venues});
  final String courtId;
  final List<Venue> venues;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final groups = <String, List<Venue>>{};
    for (final v in venues) {
      groups.putIfAbsent(v.sportType.isEmpty ? 'Khác' : v.sportType, () => [])
          .add(v);
    }
    final keys = groups.keys.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final sport in keys) ...[
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: Row(
              children: [
                Icon(sportIcon(sport), size: 18, color: scheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Text('$sport · ${groups[sport]!.length} sân',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(color: scheme.onSurfaceVariant)),
              ],
            ),
          ),
          Card(
            color: scheme.surfaceContainerLowest,
            child: Column(
              children: [
                for (int i = 0; i < groups[sport]!.length; i++) ...[
                  if (i > 0) const Divider(height: 1, indent: 16, endIndent: 16),
                  _VenueRow(courtId: courtId, venue: groups[sport]![i]),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _VenueRow extends StatelessWidget {
  const _VenueRow({required this.courtId, required this.venue});
  final String courtId;
  final Venue venue;

  Future<void> _delete(BuildContext context) async {
    final repo = context.read<VenueRepository>();
    final messenger = ScaffoldMessenger.of(context);
    final bloc = context.read<VenueBloc>();
    try {
      await repo.deactivate(venue.id);
      bloc.add(const VenueEvent.reloadRequested());
      messenger.showSnackBar(
        SnackBar(
          content: Text('Đã xoá ${venue.name}'),
          action: SnackBarAction(
            label: 'Hoàn tác',
            onPressed: () async {
              await repo.reactivate(venue.id);
              bloc.add(const VenueEvent.reloadRequested());
            },
          ),
        ),
      );
    } catch (_) {
      messenger.showSnackBar(
          const SnackBar(content: Text('Không thể xoá. Thử lại nhé.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: scheme.secondaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(sportIcon(venue.sportType),
                size: 22, color: scheme.onSecondaryContainer),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(venue.name, style: theme.textTheme.titleSmall),
                Row(
                  children: [
                    Icon(venue.indoor ? Symbols.roofing : Symbols.sunny,
                        size: 14, color: scheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${venue.sportType} · ${venue.indoor ? 'Trong nhà' : 'Ngoài trời'}',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: scheme.onSurfaceVariant),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(formatPricePerHour(venue.pricePerHour),
              style: theme.textTheme.bodyMedium),
          IconButton(
            icon: const Icon(Symbols.edit, size: 20),
            tooltip: 'Sửa',
            onPressed: () =>
                openVenueDialog(context, courtId, venue: venue),
          ),
          IconButton(
            icon: const Icon(Symbols.delete, size: 20),
            tooltip: 'Xoá',
            onPressed: () => _delete(context),
          ),
        ],
      ),
    );
  }
}

class _EmptyVenues extends StatelessWidget {
  const _EmptyVenues({required this.courtId});
  final String courtId;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        children: [
          Icon(Symbols.grid_view, size: 36, color: scheme.outline),
          const SizedBox(height: 12),
          Text('Chưa có sân con nào', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Thêm từng sân, hoặc mô tả tất cả trong một câu để AI tạo giúp.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton.tonalIcon(
                icon: const Icon(Symbols.auto_awesome, size: 18),
                label: const Text('Tạo nhanh bằng AI'),
                onPressed: () => openBulkAiSheet(context, courtId),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                icon: const Icon(Symbols.add, size: 18),
                label: const Text('Thêm sân con'),
                onPressed: () => openVenueDialog(context, courtId),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
