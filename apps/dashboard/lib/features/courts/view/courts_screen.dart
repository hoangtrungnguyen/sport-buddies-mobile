import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../setup/bloc/court_bloc.dart';
import '../../setup/bloc/court_event.dart';
import '../../setup/bloc/court_state.dart';
import '../../setup/model/owner_court.dart';
import '../repository/venue_repository.dart';
import 'widgets/court_widgets.dart';

class CourtsScreen extends StatelessWidget {
  const CourtsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CourtBloc, CourtState>(
      listener: (context, state) {
        if (state is CourtFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
          context.read<CourtBloc>().add(const CourtEvent.loadRequested());
        }
      },
      builder: (context, state) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(32, 28, 32, 120),
              child: switch (state) {
                CourtInitial() || CourtLoading() => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 80),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                CourtLoaded(:final courts) =>
                  _Loaded(courts: courts),
                CourtFailure() => const SizedBox.shrink(),
              },
            ),
          ),
        );
      },
    );
  }
}

class _Loaded extends StatefulWidget {
  const _Loaded({required this.courts});
  final List<OwnerCourt> courts;

  @override
  State<_Loaded> createState() => _LoadedState();
}

class _LoadedState extends State<_Loaded> {
  /// Memoized so each rebuild reuses the same request — building the future
  /// inline in build() re-fires a Dio call on every CourtBloc emission and
  /// leaks the in-flight requests. Re-fetch only when the court-id set changes.
  late Future<Map<String, CourtVenueSummary>> _summaries;
  late List<String> _ids;

  @override
  void initState() {
    super.initState();
    _ids = widget.courts.map((c) => c.id).toList();
    _summaries = context.read<VenueRepository>().fetchSummaries(_ids);
  }

  @override
  void didUpdateWidget(_Loaded oldWidget) {
    super.didUpdateWidget(oldWidget);
    final ids = widget.courts.map((c) => c.id).toList();
    if (!_sameIds(ids, _ids)) {
      _ids = ids;
      _summaries = context.read<VenueRepository>().fetchSummaries(ids);
    }
  }

  static bool _sameIds(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, CourtVenueSummary>>(
      future: _summaries,
      builder: (context, snap) {
        final summaries = snap.data ?? const {};
        final venueTotal =
            summaries.values.fold<int>(0, (a, s) => a + s.count);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(courtCount: widget.courts.length, venueCount: venueTotal),
            const SizedBox(height: 24),
            _Grid(courts: widget.courts, summaries: summaries),
          ],
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.courtCount, required this.venueCount});
  final int courtCount;
  final int venueCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sân của tôi', style: theme.textTheme.headlineMedium),
              const SizedBox(height: 4),
              Text(
                '$courtCount cụm sân · $venueCount sân con',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        FilledButton.icon(
          icon: const Icon(Symbols.add, size: 18),
          label: const Text('Thêm sân mới'),
          onPressed: () => context.go('/courts/new'),
        ),
      ],
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid({required this.courts, required this.summaries});
  final List<OwnerCourt> courts;
  final Map<String, CourtVenueSummary> summaries;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 16.0;
        const minTile = 280.0;
        final cols =
            ((constraints.maxWidth + gap) / (minTile + gap)).floor().clamp(1, 4);
        final tileW = (constraints.maxWidth - gap * (cols - 1)) / cols;

        final cards = <Widget>[
          for (final c in courts)
            SizedBox(
              width: tileW,
              child: _CourtCard(court: c, summary: summaries[c.id]),
            ),
          SizedBox(
            width: tileW,
            child: _AddCard(onTap: () => context.go('/courts/new')),
          ),
        ];

        return Wrap(spacing: gap, runSpacing: gap, children: cards);
      },
    );
  }
}

class _CourtCard extends StatelessWidget {
  const _CourtCard({required this.court, this.summary});
  final OwnerCourt court;
  final CourtVenueSummary? summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final venueCount = summary?.count ?? 0;
    final sports = summary?.sports.toList() ?? const <String>[];

    return Card(
      child: InkWell(
        onTap: () => context.go('/courts/${court.id}/edit', extra: court),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
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
            ),
            Padding(
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
                      for (final s in sports.take(3))
                        _MiniChip(label: s),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(),
            _ActionRow(court: court),
          ],
        ),
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
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: fg),
          ),
        ],
      ),
    );
  }
}

class _AddCard extends StatelessWidget {
  const _AddCard({required this.onTap});
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
