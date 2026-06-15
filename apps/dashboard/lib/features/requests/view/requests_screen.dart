import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spb_core/core/theme/app_colors.dart';

import '../bloc/requests_bloc.dart';
import '../model/booking_request.dart';
import '../model/requests_action.dart';
import '../requests_logic.dart';
import 'widgets/request_group.dart';
import 'widgets/requests_date_nav.dart';
import 'widgets/requests_header.dart';
import 'widgets/requests_pagination_bar.dart';
import 'widgets/requests_states.dart';
import 'widgets/requests_summary_bar.dart';

/// OWNER-27 — the owner's daily incoming-requests queue: summary bar, day
/// navigation, and a grouped, paginated list of booking cards.
class RequestsScreen extends StatelessWidget {
  const RequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RequestsBloc, RequestsState>(
      // React exactly once to each fresh action signal (identity, not value).
      listenWhen: (prev, curr) {
        final p = prev is RequestsLoaded ? prev.lastAction : null;
        final c = curr is RequestsLoaded ? curr.lastAction : null;
        return c != null && !identical(p, c);
      },
      listener: _onAction,
      builder: (context, state) => switch (state) {
        RequestsInitial() || RequestsLoading() => const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
        RequestsFailure(:final message) => RequestsFailureView(message: message),
        RequestsLoaded() => _Loaded(state: state),
      },
    );
  }

  /// Surfaces the result of an approve/reject/undo, then clears the signal.
  /// The approve/reject snackbars carry a "Hoàn tác" action whose visible
  /// duration is the grace period within which the action can be undone.
  static void _onAction(BuildContext context, RequestsState state) {
    if (state is! RequestsLoaded) return;
    final action = state.lastAction;
    if (action == null) return;
    final bloc = context.read<RequestsBloc>();
    final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();

    SnackBar undoable(String text, BookingRequest request) => SnackBar(
          content: Text(text),
          backgroundColor: AppColors.neutral800,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Hoàn tác',
            textColor: AppColors.primaryMid,
            onPressed: () => bloc.add(RequestsEvent.undoRequested(request)),
          ),
        );

    switch (action) {
      case RequestApproved(:final request):
        messenger.showSnackBar(
            undoable('Đã duyệt đơn ${request.code}.', request));
      case RequestRejected(:final request):
        messenger.showSnackBar(
            undoable('Đã từ chối đơn ${request.code}.', request));
      case RequestUndone():
        messenger.showSnackBar(const SnackBar(
          content: Text('Đã hoàn tác.'),
          backgroundColor: AppColors.neutral800,
          behavior: SnackBarBehavior.floating,
        ));
      case RequestActionFailed(:final message):
        messenger.showSnackBar(SnackBar(
          content: Text(message),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ));
    }
    bloc.add(const RequestsEvent.actionConsumed());
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
              const RequestsHeader(),
              const SizedBox(height: 20),
              RequestsDateNav(day: state.day),
              const SizedBox(height: 18),
              RequestsSummaryBar(summary: summary),
              const SizedBox(height: 20),
              if (total == 0)
                const RequestsEmptyView()
              else ...[
                for (final g in groups)
                  RequestGroup(
                    group: g,
                    dayCount:
                        dayCounts[g.startAt.millisecondsSinceEpoch] ??
                            g.items.length,
                  ),
                const SizedBox(height: 8),
                RequestsPaginationBar(page: page, total: total),
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
