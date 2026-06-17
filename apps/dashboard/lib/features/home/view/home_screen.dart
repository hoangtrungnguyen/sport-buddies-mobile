import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/home_bloc.dart';
import '../bloc/home_state.dart';
import '../model/home_models.dart';
import 'widgets/court_status_panel.dart';
import 'widgets/greeting_header.dart';
import 'widgets/kpi_section.dart';
import 'widgets/pending_requests_panel.dart';
import 'widgets/revenue_panel.dart';
import 'widgets/upcoming_panel.dart';

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
              :final summary,
              :final kpis,
              :final requests,
              :final requestsTotal,
              :final upcoming,
              :final weeklyRevenue,
              :final courtStatus,
            ) =>
              _Loaded(
                summary: summary,
                kpis: kpis,
                requests: requests,
                requestsTotal: requestsTotal,
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
    required this.summary,
    required this.kpis,
    required this.requests,
    required this.requestsTotal,
    required this.upcoming,
    required this.weeklyRevenue,
    required this.courtStatus,
  });

  final HomeSummary summary;
  final List<HomeKpi> kpis;
  final List<PendingRequest> requests;
  final int requestsTotal;
  final List<UpcomingSession> upcoming;
  final List<RevenueDay> weeklyRevenue;
  final List<CourtStatusRow> courtStatus;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1240),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 72),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GreetingHeader(summary: summary),
              const SizedBox(height: 16),
              KpiRow(kpis: kpis),
              const SizedBox(height: 16),
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
                              PendingRequestsPanel(
                                  requests: requests, total: requestsTotal),
                              const SizedBox(height: 12),
                              UpcomingPanel(upcoming: upcoming),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 100,
                          child: Column(
                            children: [
                              RevenuePanel(data: weeklyRevenue),
                              const SizedBox(height: 12),
                              CourtStatusPanel(courtStatus: courtStatus),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      PendingRequestsPanel(
                          requests: requests, total: requestsTotal),
                      const SizedBox(height: 12),
                      UpcomingPanel(upcoming: upcoming),
                      const SizedBox(height: 12),
                      RevenuePanel(data: weeklyRevenue),
                      const SizedBox(height: 12),
                      CourtStatusPanel(courtStatus: courtStatus),
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
