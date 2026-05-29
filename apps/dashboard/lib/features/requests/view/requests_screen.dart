import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spb_core/core/theme/app_colors.dart';

import '../bloc/requests_bloc.dart';
import '../model/booking_request.dart';
import '../requests_logic.dart';

/// Status foreground tones, shared by the summary bar and the card badges.
const Color _pendingFg = Color(0xFF854D0E);
const Color _confirmedFg = Color(0xFF166534);

/// OWNER-27 — the owner's daily incoming-requests queue: summary bar, day
/// navigation, and a grouped, paginated list of booking cards.
class RequestsScreen extends StatelessWidget {
  const RequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RequestsBloc, RequestsState>(
      builder: (context, state) => switch (state) {
        RequestsInitial() || RequestsLoading() => const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
        RequestsFailure(:final message) => _FailureView(message: message),
        RequestsLoaded() => _Loaded(state: state),
      },
    );
  }
}

// ---------------------------------------------------------------------------

class _Loaded extends StatelessWidget {
  const _Loaded({required this.state});
  final RequestsLoaded state;

  @override
  Widget build(BuildContext context) {
    final summary = computeSummary(state.requests);
    final total = state.requests.length;
    final page = clampPage(state.page, total);
    final slice = pageSlice(state.requests, page);
    final groups = groupBySlotTime(slice);
    // Full-day count per slot start, so a group split across a page boundary
    // still shows its true total rather than the per-page slice count.
    final dayCounts = <int, int>{};
    for (final r in state.requests) {
      final k = r.startAt.millisecondsSinceEpoch;
      dayCounts[k] = (dayCounts[k] ?? 0) + 1;
    }

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 26, 28, 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Header(),
              const SizedBox(height: 20),
              _DateNav(day: state.day),
              const SizedBox(height: 18),
              _SummaryBar(summary: summary),
              const SizedBox(height: 20),
              if (total == 0)
                const _EmptyView()
              else ...[
                for (final g in groups)
                  _Group(
                    group: g,
                    dayCount:
                        dayCounts[g.startAt.millisecondsSinceEpoch] ??
                            g.items.length,
                  ),
                const SizedBox(height: 8),
                _PaginationBar(page: page, total: total),
              ],
            ],
          ),
        ),
        if (state.busy)
          Positioned(
            top: 30,
            right: 36,
            child: Semantics(
              label: 'requests-busy',
              child: const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: AppColors.primary),
              ),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Yêu cầu đặt sân',
          style: GoogleFonts.sora(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: AppColors.neutral900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Theo dõi và xử lý các đơn đặt sân trong ngày.',
          style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5, color: AppColors.neutral500),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------

class _DateNav extends StatelessWidget {
  const _DateNav({required this.day});
  final DateTime day;

  Future<void> _pick(BuildContext context) async {
    final bloc = context.read<RequestsBloc>();
    final picked = await showDatePicker(
      context: context,
      initialDate: day,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) bloc.add(RequestsEvent.dateChanged(picked));
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<RequestsBloc>();
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.neutral200),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _NavArrow(
                icon: Icons.chevron_left_rounded,
                semantics: 'requests-prev-day-btn',
                onTap: () => bloc.add(RequestsEvent.dateChanged(addDays(day, -1))),
              ),
              Semantics(
                label: 'requests-date-picker-btn',
                button: true,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => _pick(context),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_today_rounded,
                            size: 14, color: AppColors.neutral500),
                        const SizedBox(width: 8),
                        Text(
                          dayHeading(day),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.neutral900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              _NavArrow(
                icon: Icons.chevron_right_rounded,
                semantics: 'requests-next-day-btn',
                onTap: () => bloc.add(RequestsEvent.dateChanged(addDays(day, 1))),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Semantics(
          label: 'requests-today-btn',
          button: true,
          child: OutlinedButton(
            onPressed: () => bloc.add(RequestsEvent.dateChanged(DateTime.now())),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.neutral700,
              side: const BorderSide(color: AppColors.neutral200),
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              textStyle: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600, fontSize: 12.5),
            ),
            child: const Text('Hôm nay'),
          ),
        ),
      ],
    );
  }
}

class _NavArrow extends StatelessWidget {
  const _NavArrow(
      {required this.icon, required this.onTap, required this.semantics});
  final IconData icon;
  final VoidCallback onTap;
  final String semantics;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semantics,
      button: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 18, color: AppColors.neutral600),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _SummaryBar extends StatelessWidget {
  const _SummaryBar({required this.summary});
  final RequestsSummary summary;

  @override
  Widget build(BuildContext context) {
    final cards = <Widget>[
      _StatCard(
        semantics: 'requests-summary-total',
        label: 'Tổng đơn',
        value: summary.total.toString(),
        icon: Icons.receipt_long_rounded,
        accent: AppColors.primary,
        accentBg: AppColors.primaryLight,
      ),
      _StatCard(
        semantics: 'requests-summary-pending',
        label: 'Chờ xác nhận',
        value: summary.pending.toString(),
        icon: Icons.hourglass_top_rounded,
        accent: _pendingFg,
        accentBg: AppColors.warningBg,
      ),
      _StatCard(
        semantics: 'requests-summary-revenue',
        label: 'Doanh thu dự kiến',
        value: formatVnd(summary.expectedRevenue),
        icon: Icons.payments_rounded,
        accent: _confirmedFg,
        accentBg: AppColors.successBg,
      ),
    ];

    return LayoutBuilder(
      builder: (context, c) {
        // Stack vertically on mobile widths (the shell renders content
        // full-width below 1024) so the revenue value never truncates.
        if (c.maxWidth < 640) {
          return Column(
            children: [
              for (var i = 0; i < cards.length; i++) ...[
                if (i > 0) const SizedBox(height: 12),
                cards[i],
              ],
            ],
          );
        }
        return Row(
          children: [
            for (var i = 0; i < cards.length; i++) ...[
              if (i > 0) const SizedBox(width: 14),
              Expanded(child: cards[i]),
            ],
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.semantics,
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
    required this.accentBg,
  });
  final String semantics;
  final String label;
  final String value;
  final IconData icon;
  final Color accent;
  final Color accentBg;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semantics,
      value: value,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.neutral200),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: accentBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 19, color: accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 12, color: AppColors.neutral500),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    style: GoogleFonts.sora(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                      color: AppColors.neutral900,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _Group extends StatelessWidget {
  const _Group({required this.group, required this.dayCount});
  final BookingGroup group;

  /// Total bookings sharing this slot time across the whole day (not just this
  /// page) — keeps the count honest when a group straddles a page boundary.
  final int dayCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                const Icon(Icons.schedule_rounded,
                    size: 15, color: AppColors.neutral400),
                const SizedBox(width: 7),
                Text(
                  group.label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutral700,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$dayCount đơn',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 12, color: AppColors.neutral400),
                ),
              ],
            ),
          ),
          for (final r in group.items) _RequestCard(request: r),
        ],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.request});
  final BookingRequest request;

  @override
  Widget build(BuildContext context) {
    final cancelled = request.isCancelled;
    final card = Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Row(
        children: [
          _Avatar(name: request.customerName, greyed: cancelled),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        request.customerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.neutral900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      request.code,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutral400,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.place_rounded,
                        size: 13, color: AppColors.neutral400),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        request.courtName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5, color: AppColors.neutral500),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.schedule_rounded,
                        size: 13, color: AppColors.neutral400),
                    const SizedBox(width: 4),
                    Text(
                      timeRange(
                          request.startAt.toLocal(), request.endAt.toLocal()),
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5, color: AppColors.neutral500),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _StatusBadge(status: request.status),
        ],
      ),
    );

    final labelled = Semantics(
      label: 'requests-card-${request.id}',
      child: card,
    );
    // Cancelled bookings are de-emphasized (reduced opacity), per OWNER-27 AC.
    return cancelled ? Opacity(opacity: 0.55, child: labelled) : labelled;
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name, required this.greyed});
  final String name;
  final bool greyed;

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: greyed
            ? null
            : const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark]),
        color: greyed ? AppColors.neutral200 : null,
      ),
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.sora(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: greyed ? AppColors.neutral500 : Colors.white,
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final BookingStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      BookingStatus.pending => (AppColors.warningBg, _pendingFg),
      BookingStatus.confirmed => (AppColors.successBg, _confirmedFg),
      BookingStatus.cancelled => (AppColors.neutral100, AppColors.neutral500),
    };
    return Semantics(
      label: 'requests-status-${status.name}',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(
          statusLabel(status),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: fg,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _PaginationBar extends StatelessWidget {
  const _PaginationBar({required this.page, required this.total});
  final int page;
  final int total;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<RequestsBloc>();
    final pages = pageCount(total);
    final canPrev = page > 0;
    final canNext = page < pages - 1;
    return Row(
      children: [
        Semantics(
          label: 'requests-record-count',
          child: Text(
            recordCountLabel(page, total),
            style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5, color: AppColors.neutral600),
          ),
        ),
        const Spacer(),
        _PageButton(
          icon: Icons.chevron_left_rounded,
          semantics: 'requests-prev-page-btn',
          enabled: canPrev,
          onTap: () => bloc.add(RequestsEvent.pageChanged(page - 1)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'Trang ${page + 1}/$pages',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppColors.neutral700,
            ),
          ),
        ),
        _PageButton(
          icon: Icons.chevron_right_rounded,
          semantics: 'requests-next-page-btn',
          enabled: canNext,
          onTap: () => bloc.add(RequestsEvent.pageChanged(page + 1)),
        ),
      ],
    );
  }
}

class _PageButton extends StatelessWidget {
  const _PageButton({
    required this.icon,
    required this.semantics,
    required this.enabled,
    required this.onTap,
  });
  final IconData icon;
  final String semantics;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semantics,
      button: true,
      enabled: enabled,
      child: Opacity(
        opacity: enabled ? 1 : 0.4,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.neutral200),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: enabled ? onTap : null,
            child: Padding(
              padding: const EdgeInsets.all(7),
              child: Icon(icon, size: 18, color: AppColors.neutral600),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'requests-empty',
      container: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 56),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.neutral200),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.inbox_rounded,
                  size: 32, color: AppColors.primary),
            ),
            const SizedBox(height: 18),
            Text(
              'Chưa có đơn đặt sân nào',
              style: GoogleFonts.sora(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Các đơn đặt sân trong ngày sẽ hiển thị ở đây.',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5, color: AppColors.neutral500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _FailureView extends StatelessWidget {
  const _FailureView({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 40, color: AppColors.danger),
          const SizedBox(height: 12),
          Text(message,
              style: GoogleFonts.plusJakartaSans(
                  color: AppColors.neutral600, fontSize: 14)),
          const SizedBox(height: 16),
          Semantics(
            label: 'requests-retry-btn',
            button: true,
            child: OutlinedButton(
              onPressed: () =>
                  context.read<RequestsBloc>().add(const RequestsEvent.refreshed()),
              child: const Text('Thử lại'),
            ),
          ),
        ],
      ),
    );
  }
}
