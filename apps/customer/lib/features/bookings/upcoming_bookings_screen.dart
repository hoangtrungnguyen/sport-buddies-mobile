// Bookings feature — UpcomingBookingsScreen.
//
// Accessible via the '/bookings/upcoming' route.
//
// BLoC states handled:
//   BookingsLoading      → CircularProgressIndicator
//   BookingsCancelling   → CircularProgressIndicator (cancel in-flight)
//   BookingsLoaded       → filter bar + ListView of BookingTile; empty state when list is empty
//   BookingsError        → error message with retry button
//
// Cancel flow:
//   Pending bookings show a delete icon.
//   Tapping it opens a confirmation dialog ('Huỷ đặt sân này?').
//   On confirm, BookingsCubit.cancelBooking(id) is called.

import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'booking_filter_bar.dart';
import 'booking_model.dart';
import 'booking_tile.dart';
import 'bookings_cubit.dart';
import 'bookings_state.dart';

/// Route entry point — wraps the screen in a [BookingsCubit].
class UpcomingBookingsPage extends StatelessWidget {
  const UpcomingBookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BookingsCubit(Supabase.instance.client)..loadUpcoming(),
      child: const UpcomingBookingsScreen(),
    );
  }
}

/// The screen itself — reads from [BookingsCubit] via BlocBuilder.
class UpcomingBookingsScreen extends StatelessWidget {
  const UpcomingBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upcoming Bookings')),
      body: BlocBuilder<BookingsCubit, BookingsState>(
        builder: (context, state) {
          return switch (state) {
            BookingsLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            BookingsCancelling() => const Center(
              child: CircularProgressIndicator(),
            ),
            BookingsLoaded() => _LoadedBody(state: state),
            BookingsError(:final message) => _ErrorState(
              message: message,
              onRetry: () => context.read<BookingsCubit>().loadUpcoming(),
            ),
          };
        },
      ),
    );
  }
}

/// Renders the filter bar + the list (or empty state) for [BookingsLoaded].
class _LoadedBody extends StatelessWidget {
  const _LoadedBody({required this.state});

  final BookingsLoaded state;

  @override
  Widget build(BuildContext context) {
    final filtered = state.filteredBookings;
    return Column(
      children: [
        BookingFilterBar(
          selectedStatus: state.selectedStatus,
          onFilterChanged: (status) =>
              context.read<BookingsCubit>().filterByStatus(status),
        ),
        Expanded(
          child: filtered.isEmpty
              ? const _EmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) =>
                      _CancellableBookingTile(booking: filtered[index]),
                ),
        ),
      ],
    );
  }
}

/// Wraps [BookingTile] with a confirmation dialog for pending bookings.
class _CancellableBookingTile extends StatelessWidget {
  const _CancellableBookingTile({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final isPending = booking.status == 'pending';
    return BookingTile(
      booking: booking,
      onCancel: isPending ? () => _confirmCancel(context) : null,
    );
  }

  Future<void> _confirmCancel(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.bookingCancelConfirmTitle),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.commonNo),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              l10n.commonConfirm,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<BookingsCubit>().cancelBooking(booking.id);
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.sports_tennis, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No upcoming bookings',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Book a court to get started!',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
