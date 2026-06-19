import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../bloc/home_bloc.dart';
import '../../bloc/home_event.dart';
import '../../model/home_models.dart';

class PendingRequestsPanel extends StatelessWidget {
  const PendingRequestsPanel({
    super.key,
    required this.requests,
    required this.total,
  });
  final List<PendingRequest> requests;

  /// Full pending count (may exceed [requests] when the panel holds a subset).
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final shown = requests.take(4).toList();
    final remaining = total - shown.length;

    return Card(
      elevation: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(context, theme, scheme),
          const Divider(height: 1),
          if (shown.isEmpty)
            _emptyState(theme, scheme)
          else
            ...shown.map((req) => _RequestRow(request: req)),
          if (remaining > 0) _remainingLink(context, remaining),
        ],
      ),
    );
  }

  /// Title + total count badge + "Xem tất cả" link.
  Widget _header(BuildContext context, ThemeData theme, ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      child: Row(
        children: [
          Icon(Symbols.inbox, size: 20, color: scheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Yêu cầu cần xử lý', style: theme.textTheme.titleMedium),
                Text('$total yêu cầu',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: scheme.onSurfaceVariant)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: scheme.secondaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('$total',
                style: TextStyle(
                  fontSize: 12,
                  color: scheme.onSecondaryContainer,
                  fontWeight: FontWeight.w600,
                )),
          ),
          const SizedBox(width: 4),
          TextButton(
            onPressed: () => context.go('/requests'),
            child: const Text('Xem tất cả'),
          ),
        ],
      ),
    );
  }

  /// "Đã xử lý hết yêu cầu" empty state.
  Widget _emptyState(ThemeData theme, ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      child: Center(
        child: Column(
          children: [
            Icon(Symbols.task_alt, size: 36, color: scheme.primary),
            const SizedBox(height: 12),
            Text('Đã xử lý hết yêu cầu', style: theme.textTheme.titleSmall),
          ],
        ),
      ),
    );
  }

  /// "Còn N yêu cầu khác" link to the full requests screen.
  Widget _remainingLink(BuildContext context, int remaining) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Center(
        child: TextButton.icon(
          icon: const Icon(Symbols.arrow_forward, size: 18),
          label: Text('Còn $remaining yêu cầu khác'),
          onPressed: () => context.go('/requests'),
        ),
      ),
    );
  }
}

class _RequestRow extends StatelessWidget {
  const _RequestRow({required this.request});
  final PendingRequest request;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Row(
        children: [
          _avatar(scheme),
          const SizedBox(width: 12),
          Expanded(child: _info(theme, scheme)),
          const SizedBox(width: 8),
          ..._actions(context),
        ],
      ),
    );
  }

  /// Circular initials avatar.
  Widget _avatar(ColorScheme scheme) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          request.initials,
          style: TextStyle(
            color: scheme.onTertiaryContainer,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// Name (+ "Khách quen" badge), court/venue/sport line, and the time + price.
  Widget _info(ThemeData theme, ColorScheme scheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(request.name,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w500)),
            ),
            if (request.regular)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text('Khách quen',
                    style: TextStyle(
                      fontSize: 10,
                      color: scheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    )),
              ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          [request.court, request.venue, request.sport]
              .where((p) => p.isNotEmpty)
              .join(' · '),
          style: theme.textTheme.bodySmall
              ?.copyWith(color: scheme.onSurfaceVariant),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Symbols.schedule, size: 14, color: scheme.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(request.when,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: scheme.onSurfaceVariant)),
            const SizedBox(width: 8),
            Text('${request.price ~/ 1000}k',
                style: theme.textTheme.bodySmall
                    ?.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }

  /// Decline + approve action buttons.
  List<Widget> _actions(BuildContext context) {
    return [
      SizedBox(
        width: 36,
        child: TextButton(
          onPressed: () => context
              .read<HomeBloc>()
              .add(HomeEvent.requestDeclined(request)),
          style: TextButton.styleFrom(padding: EdgeInsets.zero),
          child: const Text('Từ chối', style: TextStyle(fontSize: 12)),
        ),
      ),
      SizedBox(
        width: 36,
        child: FilledButton(
          onPressed: () => context
              .read<HomeBloc>()
              .add(HomeEvent.requestApproved(request)),
          style: FilledButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(36, 36),
          ),
          child: const Icon(Symbols.check, size: 16),
        ),
      ),
    ];
  }
}
