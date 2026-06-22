// Booking detail — MD3 redesign.
// Route: /bookings/:id  (full-screen, no bottom nav)
// Design: EPIC-6 My Bookings.html → BookingDetail component

import 'package:customer/core/env/env.dart';
import 'package:customer/core/l10n/error_messages.dart';
import 'package:customer/core/services/booking_api_client.dart';
import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'booking_detail_cubit.dart';
import 'booking_detail_state.dart';
import 'booking_model.dart';
import 'bookings_style.dart';
import 'widgets/booking_info_card.dart';
import 'widgets/booking_participants_card.dart';
import 'widgets/booking_join_requests_card.dart';
import 'widgets/booking_bottom_actions.dart';

// ─── Page entry point ────────────────────────────────────────────────────────

class BookingDetailPage extends StatelessWidget {
  const BookingDetailPage({super.key, required this.bookingId});

  final String bookingId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BookingDetailCubit(
        Supabase.instance.client,
        apiClient: BookingApiClient(
          supabase: Supabase.instance.client,
          baseUrl: Env.apiBaseUrl,
        ),
      )..loadBookingDetail(bookingId),
      child: const BookingDetailScreen(),
    );
  }
}

// ─── Screen ──────────────────────────────────────────────────────────────────

class BookingDetailScreen extends StatelessWidget {
  const BookingDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mdSurface,
      appBar: AppBar(
        backgroundColor: mdSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context).bookingDetailTitle,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: mdOnSurface,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: mdOnSurface),
          onPressed: () {
            if (context.canPop()) context.pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: mdOnSurface),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocConsumer<BookingDetailCubit, BookingDetailState>(
        listenWhen: (prev, curr) =>
            curr is BookingDetailLoaded && curr.actionError != null,
        listener: (context, state) {
          final code = (state as BookingDetailLoaded).actionError!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                appErrorMessage(AppLocalizations.of(context), code),
              ),
              backgroundColor: mdError,
            ),
          );
        },
        builder: (context, state) => switch (state) {
          BookingDetailLoading() => const Center(
            child: CircularProgressIndicator(),
          ),
          BookingDetailLoaded(
            :final booking,
            :final joinRequests,
            :final processing,
          ) =>
            _LoadedBody(
              booking: booking,
              joinRequests: joinRequests,
              processing: processing,
            ),
          BookingDetailError(:final message) => _ErrorBody(message: message),
        },
      ),
    );
  }
}

// ─── Loaded body ─────────────────────────────────────────────────────────────

class _LoadedBody extends StatelessWidget {
  const _LoadedBody({
    required this.booking,
    required this.joinRequests,
    required this.processing,
  });

  final Booking? booking;
  final List<JoinRequest> joinRequests;
  final Set<String> processing;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
          children: [
            if (booking != null) ...[
              BookingInfoCard(booking: booking!),
              const SizedBox(height: 12),
              ParticipantsCard(joinRequests: joinRequests),
              const SizedBox(height: 12),
              JoinRequestsCard(
                joinRequests: joinRequests,
                slotId: booking!.slot.id,
                processing: processing,
              ),
            ],
          ],
        ),
        if (booking != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomActions(booking: booking!),
          ),
      ],
    );
  }
}

// ─── Error body ───────────────────────────────────────────────────────────────

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: mdOnSurfaceVariant),
        ),
      ),
    );
  }
}
