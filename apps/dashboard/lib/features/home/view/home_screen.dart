import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../model/home_models.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return Scaffold(
          body: switch (state) {
            HomeInitial() || HomeLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
            HomeLoaded(
              :final kpis,
              :final requests,
              :final upcoming,
              :final weeklyRevenue,
              :final courtStatus,
            ) =>
              _Loaded(
                kpis: kpis,
                requests: requests,
                upcoming: upcoming,
                weeklyRevenue: weeklyRevenue,
                courtStatus: courtStatus,
              ),
            HomeFailure(:final message) => Center(
                child: Text('Error: $message'),
              ),
          },
        );
      },
    );
  }
}

class _Loaded extends StatelessWidget {
  const _Loaded({
    required this.kpis,
    required this.requests,
    required this.upcoming,
    required this.weeklyRevenue,
    required this.courtStatus,
  });

  final List<HomeKpi> kpis;
  final List<PendingRequest> requests;
  final List<UpcomingSession> upcoming;
  final List<RevenueDay> weeklyRevenue;
  final List<CourtStatusRow> courtStatus;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1240),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(32, 28, 32, 96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GreetingHeader(requests: requests),
              const SizedBox(height: 24),
              _KpiRow(kpis: kpis),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth >= 1080) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 155,
                          child: Column(
                            children: [
                              _PendingRequestsPanel(requests: requests),
                              const SizedBox(height: 16),
                              _UpcomingPanel(upcoming: upcoming),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 100,
                          child: Column(
                            children: [
                              _RevenuePanel(data: weeklyRevenue),
                              const SizedBox(height: 16),
                              _CourtStatusPanel(courtStatus: courtStatus),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      _PendingRequestsPanel(requests: requests),
                      const SizedBox(height: 16),
                      _UpcomingPanel(upcoming: upcoming),
                      const SizedBox(height: 16),
                      _RevenuePanel(data: weeklyRevenue),
                      const SizedBox(height: 16),
                      _CourtStatusPanel(courtStatus: courtStatus),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader({required this.requests});
  final List<PendingRequest> requests;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Chào buổi sáng'
        : hour < 18
            ? 'Chào buổi chiều'
            : 'Chào buổi tối';

    return Wrap(
      spacing: 16,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$greeting, anh Minh',
                  style: theme.textTheme.headlineMedium),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    'Thứ Sáu, 12/06/2026 · 5 cụm sân đang hoạt động · 12 sân con',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ),
        ),
        FilledButton.icon(
          icon: const Icon(Symbols.person_add, size: 18),
          label: const Text('Khách vãng lai'),
          onPressed: () {},
        ),
        FilledButton.icon(
          icon: const Icon(Symbols.add, size: 18),
          label: const Text('Tạo đặt sân'),
          onPressed: () {},
        ),
      ],
    );
  }
}

class _KpiRow extends StatelessWidget {
  const _KpiRow({required this.kpis});
  final List<HomeKpi> kpis;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int cols = 4;
        if (constraints.maxWidth < 1080) cols = 2;
        if (constraints.maxWidth < 560) cols = 1;

        return GridView.count(
          crossAxisCount: cols,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1 / 1.1,
          children: [for (final kpi in kpis) _KpiCard(kpi: kpi)],
        );
      },
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.kpi});
  final HomeKpi kpi;

  Color _getToneColor(KpiTone tone, ColorScheme scheme) {
    return switch (tone) {
      KpiTone.primary => scheme.primaryContainer,
      KpiTone.tertiary => scheme.tertiaryContainer,
      KpiTone.secondary => scheme.secondaryContainer,
      KpiTone.warn => const Color(0xFFFEF3C0),
    };
  }

  Color _getToneForeground(KpiTone tone, ColorScheme scheme) {
    return switch (tone) {
      KpiTone.primary => scheme.onPrimaryContainer,
      KpiTone.tertiary => scheme.onTertiaryContainer,
      KpiTone.secondary => scheme.onSecondaryContainer,
      KpiTone.warn => const Color(0xFF574500),
    };
  }

  IconData _getIcon(String icon) {
    return switch (icon) {
      'payments' => Symbols.payments,
      'event_available' => Symbols.event_available,
      'donut_large' => Symbols.donut_large,
      'inbox' => Symbols.inbox,
      _ => Symbols.info,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getToneColor(kpi.tone, scheme),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getIcon(kpi.icon),
                    size: 20,
                    color: _getToneForeground(kpi.tone, scheme),
                  ),
                ),
                if (kpi.delta != null)
                  _DeltaChip(
                    delta: kpi.delta!,
                    isUp: kpi.deltaUp,
                    tone: kpi.tone,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(kpi.label,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: scheme.onSurfaceVariant)),
            const SizedBox(height: 6),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: kpi.value,
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w500, fontSize: 30),
                  ),
                  if (kpi.unit != null) ...[
                    const TextSpan(text: ' '),
                    TextSpan(
                      text: kpi.unit!,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ],
              ),
            ),
            if (kpi.progress != null) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: kpi.progress! / 100,
                  minHeight: 6,
                  backgroundColor: scheme.surfaceContainerHighest,
                  valueColor:
                      AlwaysStoppedAnimation(scheme.primary),
                ),
              ),
            ],
            if (kpi.sub != null) ...[
              const SizedBox(height: 6),
              Text(kpi.sub!,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: scheme.onSurfaceVariant)),
            ],
          ],
        ),
      ),
    );
  }
}

class _DeltaChip extends StatelessWidget {
  const _DeltaChip({
    required this.delta,
    required this.isUp,
    required this.tone,
  });

  final String delta;
  final bool? isUp;
  final KpiTone tone;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (bg, fg, icon) = switch (isUp) {
      true => (
          scheme.primaryContainer,
          scheme.onPrimaryContainer,
          Symbols.arrow_upward,
        ),
      false => (
          scheme.errorContainer,
          scheme.onErrorContainer,
          Symbols.schedule,
        ),
      null => (
          scheme.surfaceContainerHigh,
          scheme.onSurfaceVariant,
          Symbols.info,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 4),
          Text(
            delta,
            style: TextStyle(fontSize: 12, color: fg, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _PendingRequestsPanel extends StatelessWidget {
  const _PendingRequestsPanel({required this.requests});
  final List<PendingRequest> requests;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final shown = requests.take(4).toList();
    final remaining = requests.length - shown.length;

    return Card(
      elevation: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
            child: Row(
              children: [
                Icon(Symbols.inbox, size: 20, color: scheme.onSurfaceVariant),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Yêu cầu cần xử lý',
                          style: theme.textTheme.titleMedium),
                      Text('${requests.length} yêu cầu',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: scheme.onSurfaceVariant)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: scheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('${requests.length}',
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
          ),
          const Divider(height: 1),
          if (shown.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
              child: Center(
                child: Column(
                  children: [
                    Icon(Symbols.task_alt,
                        size: 40, color: scheme.primary),
                    const SizedBox(height: 12),
                    Text('Đã xử lý hết yêu cầu',
                        style: theme.textTheme.titleSmall),
                  ],
                ),
              ),
            )
          else
            ...shown.map((req) => _RequestRow(request: req)),
          if (remaining > 0)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Center(
                child: TextButton.icon(
                  icon: const Icon(Symbols.arrow_forward, size: 18),
                  label: Text('Còn $remaining yêu cầu khác'),
                  onPressed: () => context.go('/requests'),
                ),
              ),
            ),
        ],
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
          Container(
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
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
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
                  '${request.court} · ${request.venue} · ${request.sport}',
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
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 36,
            child: TextButton(
              onPressed: () =>
                  context.read<HomeBloc>().add(HomeEvent.requestDeclined(request.id)),
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              child: const Text('Từ chối', style: TextStyle(fontSize: 12)),
            ),
          ),
          SizedBox(
            width: 36,
            child: FilledButton(
              onPressed: () =>
                  context.read<HomeBloc>().add(HomeEvent.requestApproved(request.id)),
              style: FilledButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(36, 36),
              ),
              child: const Icon(Symbols.check, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class _UpcomingPanel extends StatelessWidget {
  const _UpcomingPanel({required this.upcoming});
  final List<UpcomingSession> upcoming;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      elevation: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
            child: Row(
              children: [
                Icon(Symbols.today, size: 20, color: scheme.onSurfaceVariant),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Sắp diễn ra hôm nay',
                      style: theme.textTheme.titleMedium),
                ),
                TextButton(
                  onPressed: () => context.go('/schedule'),
                  child: const Text('Lịch sân'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...upcoming.map((sess) => _SessionRow(session: sess)),
        ],
      ),
    );
  }
}

class _SessionRow extends StatelessWidget {
  const _SessionRow({required this.session});
  final UpcomingSession session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isConfirmed = session.status == SessionStatus.confirmed;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(session.time,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFeatures: [FontFeature.tabularFigures()])),
                const SizedBox(height: 2),
                Text(session.end,
                    style: TextStyle(
                        fontSize: 11,
                        color: scheme.onSurfaceVariant,
                        fontFeatures: const [FontFeature.tabularFigures()])),
              ],
            ),
          ),
          Container(
            width: 2,
            height: 32,
            color: scheme.primary,
            margin: const EdgeInsets.symmetric(horizontal: 12),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(session.name,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(session.where,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: scheme.onSurfaceVariant)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _StatusChip(
            status: isConfirmed ? 'Đã xác nhận' : 'Vãng lai',
            isConfirmed: isConfirmed,
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.status,
    required this.isConfirmed,
  });

  final String status;
  final bool isConfirmed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = isConfirmed ? scheme.secondaryContainer : Colors.transparent;
    final fg = isConfirmed ? scheme.onSecondaryContainer : scheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: isConfirmed ? null : Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isConfirmed ? Symbols.check_circle : Symbols.directions_walk,
            size: 14,
            color: fg,
          ),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              fontSize: 12,
              color: fg,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _RevenuePanel extends StatelessWidget {
  const _RevenuePanel({required this.data});
  final List<RevenueDay> data;

  int get _total => data.fold(0, (sum, d) => sum + d.value);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final avg = _total ~/ data.length;
    final formatted = (_total / 1000000).toStringAsFixed(2);

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 12, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Symbols.bar_chart, size: 20, color: scheme.onSurfaceVariant),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Doanh thu 7 ngày',
                      style: theme.textTheme.titleMedium),
                ),
                TextButton(
                  onPressed: () => context.go('/analytics'),
                  child: const Text('Thống kê'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${formatted}tr',
              style:
                  const TextStyle(fontSize: 26, fontWeight: FontWeight.w500),
            ),
            Text(
              'tổng tuần · TB ${_formatVnd(avg)}/ngày',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 130,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final day in data)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: day.today
                                      ? scheme.primary
                                      : scheme.secondaryContainer,
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(4)),
                                ),
                                child: Tooltip(
                                  message: _formatVnd(day.value),
                                  child: const SizedBox(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              day.day,
                              style: TextStyle(
                                fontSize: 12,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatVnd(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}tr';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}k';
    }
    return '$value';
  }
}

class _CourtStatusPanel extends StatelessWidget {
  const _CourtStatusPanel({required this.courtStatus});
  final List<CourtStatusRow> courtStatus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      elevation: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
            child: Row(
              children: [
                Icon(Symbols.stadium, size: 20, color: scheme.onSurfaceVariant),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Tình trạng sân',
                      style: theme.textTheme.titleMedium),
                ),
                TextButton(
                  onPressed: () => context.go('/courts'),
                  child: const Text('Quản lý'),
                )
              ],
            ),
          ),
          const Divider(height: 1),
          ...courtStatus.map((court) => _CourtStatusRow(court: court)),
        ],
      ),
    );
  }
}

class _CourtStatusRow extends StatelessWidget {
  const _CourtStatusRow({required this.court});
  final CourtStatusRow court;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isActive = court.status == CourtState.active;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: scheme.secondaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Symbols.stadium,
              size: 20,
              color: scheme.onSecondaryContainer,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isActive ? scheme.primary : scheme.outline,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(court.name,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${court.venues} sân con · lấp đầy hôm nay',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 60,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: court.occupancy / 100,
                    minHeight: 6,
                    backgroundColor: scheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation(scheme.primary),
                  ),
                ),
                const SizedBox(height: 4),
                Text('${court.occupancy}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
