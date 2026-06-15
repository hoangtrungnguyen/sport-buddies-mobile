import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../setup/bloc/court_bloc.dart';
import '../../../setup/bloc/court_event.dart';
import '../../../setup/bloc/court_state.dart';
import '../../../setup/model/owner_court.dart';
import '../../util/court_format.dart';
import 'court_widgets.dart';

/// Left-column summary card: identity, status, contact/location info, amenities,
/// description, auto-approve toggle, and the edit-court action.
class CourtInfoCard extends StatelessWidget {
  const CourtInfoCard({super.key, required this.court});
  final OwnerCourt court;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: scheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Symbols.stadium,
                      size: 22, color: scheme.onSecondaryContainer),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(court.name, style: theme.textTheme.titleMedium)),
              ],
            ),
            const SizedBox(height: 12),
            CourtStatusChip(
              status: court.isActive
                  ? CourtChipStatus.active
                  : CourtChipStatus.inactive,
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            if (court.address != null && court.address!.isNotEmpty)
              _InfoRow(icon: Symbols.location_on, text: court.address!),
            if (court.lat != null && court.lng != null)
              _InfoRow(
                icon: Symbols.my_location,
                text:
                    '${court.lat!.toStringAsFixed(5)}, ${court.lng!.toStringAsFixed(5)}',
              ),
            if ((court.additionalInfo['phone'] as String?)?.isNotEmpty ?? false)
              _InfoRow(
                  icon: Symbols.call,
                  text: court.additionalInfo['phone'] as String),
            _InfoRow(
              icon: Symbols.schedule,
              text:
                  '${formatHour(court.openHour)} – ${formatHour(court.closeHour)}',
            ),
            if (court.amenities.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final a in court.amenities)
                    Chip(
                      avatar: Icon(amenityIcon(a), size: 16),
                      label: Text(a),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                ],
              ),
            ],
            if (court.description != null && court.description!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(court.description!,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: scheme.onSurfaceVariant, height: 1.5)),
            ],
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            _AutoApproveRow(court: court),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Symbols.edit, size: 18),
                label: const Text('Chỉnh sửa thông tin sân'),
                onPressed: () =>
                    context.go('/courts/${court.id}/edit', extra: court),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: scheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _AutoApproveRow extends StatelessWidget {
  const _AutoApproveRow({required this.court});
  final OwnerCourt court;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final loading = context.select<CourtBloc, bool>((b) => b.state is CourtLoading);
    final on = court.autoApproveSingle;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: on ? scheme.primaryContainer : scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: on ? scheme.primary : scheme.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tự động duyệt đặt sân', style: theme.textTheme.titleSmall),
                Text(
                  on
                      ? 'Đặt sân một lần được duyệt tự động.'
                      : 'Cần duyệt thủ công từng yêu cầu.',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Semantics(
            label: 'court-auto-approve-toggle',
            toggled: on,
            child: Switch(
              value: on,
              onChanged: loading
                  ? null
                  : (v) {
                      context.read<CourtBloc>().add(
                          CourtEvent.autoApproveToggled(court.id, value: v));
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đã lưu cài đặt')));
                    },
            ),
          ),
        ],
      ),
    );
  }
}
