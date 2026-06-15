import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../setup/bloc/court_bloc.dart';
import '../../setup/bloc/court_state.dart';
import '../../setup/model/owner_court.dart';
import '../bloc/venue_bloc.dart';
import 'widgets/court_info_card.dart';
import 'widgets/venue_panel.dart';

class CourtDetailScreen extends StatelessWidget {
  const CourtDetailScreen({super.key, required this.courtId});
  final String courtId;

  @override
  Widget build(BuildContext context) {
    final court = context.select<CourtBloc, OwnerCourt?>(
      (bloc) => switch (bloc.state) {
        CourtLoaded(:final courts) =>
          courts.where((c) => c.id == courtId).firstOrNull,
        _ => null,
      },
    );

    if (court == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return BlocListener<VenueBloc, VenueState>(
      listenWhen: (a, b) => b is VenueFailure,
      listener: (context, state) {
        if (state is VenueFailure) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Symbols.arrow_back),
            onPressed: () =>
                context.canPop() ? context.pop() : context.go('/courts'),
          ),
          title: Text('Sân con · ${court.name}'),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(height: 1),
          ),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1080),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(32, 28, 32, 120),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 820;
                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 340, child: CourtInfoCard(court: court)),
                        const SizedBox(width: 24),
                        Expanded(child: VenuePanel(court: court)),
                      ],
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CourtInfoCard(court: court),
                      const SizedBox(height: 20),
                      VenuePanel(court: court),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
