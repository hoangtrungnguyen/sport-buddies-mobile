import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../setup/bloc/court_bloc.dart';
import '../../../setup/bloc/court_event.dart';
import '../../../setup/model/owner_court.dart';
import '../../repository/venue_repository.dart';
import 'court_widgets.dart';

/// One court tile in the "Sân của tôi" grid: striped photo + status chip,
/// name/address, venue-count + sport mini-chips, and the action row. Tapping
/// the card opens the edit form.
class CourtGridCard extends StatelessWidget {
  const CourtGridCard({super.key, required this.court, this.summary});

  final OwnerCourt court;
  final CourtVenueSummary? summary;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => context.go('/courts/${court.id}/edit', extra: court),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _photo(),
            _details(context),
            const Divider(),
            _ActionRow(court: court),
          ],
        ),
      ),
    );
  }

  /// Striped photo placeholder with the status chip overlaid top-left.
  Widget _photo() {
    return Stack(
      children: [
        StripedPhotoPlaceholder(caption: court.name),
        Positioned(
          top: 12,
          left: 12,
          child: CourtStatusChip(
            status: court.isActive
                ? CourtChipStatus.active
                : CourtChipStatus.inactive,
            elevated: true,
          ),
        ),
      ],
    );
  }

  /// Name, address, and the venue-count + sport mini-chips.
  Widget _details(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final venueCount = summary?.count ?? 0;
    final sports = summary?.sports.toList() ?? const <String>[];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            court.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Symbols.location_on,
                  size: 16, color: scheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  (court.address?.isNotEmpty ?? false)
                      ? court.address!
                      : 'Chưa có địa chỉ',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _MiniChip(
                icon: Symbols.grid_view,
                label: '$venueCount sân con',
                outlined: true,
              ),
              for (final s in sports.take(3)) _MiniChip(label: s),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.court});
  final OwnerCourt court;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 2, 4, 4),
      child: Row(
        children: [
          TextButton.icon(
            icon: const Icon(Symbols.edit, size: 16),
            label: const Text('Sửa'),
            onPressed: () =>
                context.go('/courts/${court.id}/edit', extra: court),
          ),
          TextButton.icon(
            icon: const Icon(Symbols.grid_view, size: 16),
            label: const Text('Sân con'),
            onPressed: () => context.go('/courts/${court.id}'),
          ),
          const Spacer(),
          PopupMenuButton<String>(
            icon: const Icon(Symbols.more_vert, size: 20),
            onSelected: (v) {
              final bloc = context.read<CourtBloc>();
              if (v == 'toggle') {
                bloc.add(court.isActive
                    ? CourtEvent.deactivateRequested(court.id)
                    : CourtEvent.reactivateRequested(court.id));
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'toggle',
                child: Text(court.isActive ? 'Tạm ngưng' : 'Kích hoạt'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({this.icon, required this.label, this.outlined = false});
  final IconData? icon;
  final String label;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = outlined ? Colors.transparent : scheme.secondaryContainer;
    final fg = outlined ? scheme.onSurfaceVariant : scheme.onSecondaryContainer;
    return Container(
      height: 26,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(7),
        border: outlined ? Border.all(color: scheme.outlineVariant) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style:
                TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: fg),
          ),
        ],
      ),
    );
  }
}

/// The trailing dashed "Thêm sân mới" tile of the grid.
class AddCourtCard extends StatelessWidget {
  const AddCourtCard({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: DottedBorderBox(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Symbols.add,
                      size: 26, color: scheme.onPrimaryContainer),
                ),
                const SizedBox(height: 12),
                Text('Thêm sân mới',
                    style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(
                  'Nhập tay hoặc để AI điền giúp từ văn bản, liên kết, ảnh',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Rounded dashed-outline container (M3 outlined "add" affordance).
class DottedBorderBox extends StatelessWidget {
  const DottedBorderBox({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedRectPainter(
        color: Theme.of(context).colorScheme.outlineVariant,
      ),
      child: child,
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  _DashedRectPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(12),
    );
    final path = Path()..addRRect(rrect);
    const dash = 6.0, gap = 4.0;
    for (final metric in path.computeMetrics()) {
      double dist = 0;
      while (dist < metric.length) {
        canvas.drawPath(
          metric.extractPath(dist, dist + dash),
          paint,
        );
        dist += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedRectPainter old) => old.color != color;
}
