import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../setup/bloc/court_bloc.dart';
import '../../setup/bloc/court_event.dart';
import '../../setup/bloc/court_state.dart';
import '../../setup/model/owner_court.dart';
import '../repository/venue_repository.dart';
import 'widgets/court_grid_cards.dart';

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
              child: CourtGridCard(court: c, summary: summaries[c.id]),
            ),
          SizedBox(
            width: tileW,
            child: AddCourtCard(onTap: () => context.go('/courts/new')),
          ),
        ];

        return Wrap(spacing: gap, runSpacing: gap, children: cards);
      },
    );
  }
}
