import 'package:customer/features/courts/cubit/court_detail_cubit.dart';
import 'package:customer/features/courts/widgets/court_photo_carousel.dart';
import 'package:customer/features/courts/widgets/court_info_section.dart';
import 'package:customer/features/courts/widgets/court_bottom_cta.dart';
import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spb_core/spb_core.dart';

class CourtDetailScreen extends StatefulWidget {
  const CourtDetailScreen({super.key, required this.courtId});

  final String courtId;

  @override
  State<CourtDetailScreen> createState() => _CourtDetailScreenState();
}

class _CourtDetailScreenState extends State<CourtDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CourtDetailCubit>().loadCourt(widget.courtId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CourtDetailCubit, CourtDetailState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: switch (state) {
            CourtDetailLoading() || CourtDetailInitial() => const Center(
              child: CircularProgressIndicator(),
            ),
            CourtDetailError(message: final msg) => _ErrorBody(
              message: msg,
              courtId: widget.courtId,
            ),
            CourtDetailLoaded(
              court: final court,
              openSlotCount: final openSlotCount,
              groupSlots: final groupSlots,
            ) =>
              _Body(
                court: court,
                openSlotCount: openSlotCount,
                groupSlots: groupSlots,
              ),
          },
        );
      },
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message, required this.courtId});

  final String message;
  final String courtId;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, style: const TextStyle(color: Color(0xFF6B7280))),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () =>
                context.read<CourtDetailCubit>().loadCourt(courtId),
            child: Text(AppLocalizations.of(context).commonRetry),
          ),
        ],
      ),
    );
  }
}

class _Body extends StatefulWidget {
  const _Body({
    required this.court,
    required this.openSlotCount,
    required this.groupSlots,
  });

  final Court court;
  final int openSlotCount;
  final List<Slot> groupSlots;

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final court = widget.court;
    // Clear the sticky BottomCta: its height is ~88 + safe-area inset when the
    // court is full (extra "Xem lịch trống" link row), so reserve enough scroll
    // padding that the last section ("Lịch tổng hợp") isn't hidden behind it.
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Stack(
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 120 + bottomInset),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PhotoCarousel(
                photos: court.photos,
                controller: _pageController,
                currentPage: _currentPage,
                onPageChanged: (i) => setState(() => _currentPage = i),
              ),
              CourtInfoSection(
                court: court,
                openSlotCount: widget.openSlotCount,
                groupSlots: widget.groupSlots,
              ),
            ],
          ),
        ),
        BottomCta(
          courtId: court.id,
          pricePerHour: court.pricePerHour,
          openSlotCount: widget.openSlotCount,
          courtName: court.name,
          courtAddress: court.address,
        ),
      ],
    );
  }
}
