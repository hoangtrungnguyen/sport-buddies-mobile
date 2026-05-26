// Bookings feature — UpcomingBookingsScreen.
//
// Accessible via the '/bookings/upcoming' route.
//
// BLoC states handled:
//   BookingsLoading      → CircularProgressIndicator
//   BookingsCancelling   → CircularProgressIndicator (cancel in-flight)
//   BookingsLoaded       → ListView of BookingTile; empty state when list is empty
//   BookingsError        → error message with retry button
//
// Cancel flow:
//   Pending bookings show a delete icon.
//   Tapping it opens a confirmation dialog ('Huỷ đặt sân này?').
//   On confirm, BookingsCubit.cancelBooking(id) is called.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      create: (_) =>
          BookingsCubit(Supabase.instance.client)..loadUpcoming(),
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
            BookingsLoaded(:final bookings) when bookings.isEmpty =>
              const _EmptyState(),
            BookingsLoaded(:final bookings) => ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: bookings.length,
                itemBuilder: (context, index) => _CancellableBookingTile(
                  booking: bookings[index],
                ),
              ),
            BookingsError(:final message) => _ErrorState(
                message: message,
                onRetry: () =>
                    context.read<BookingsCubit>().loadUpcoming(),
              ),
          };
        },
      ),
    );
  }
}

/// Wraps [BookingTile] and appends a cancel icon for pending bookings.
class _CancellableBookingTile extends StatelessWidget {
  const _CancellableBookingTile({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final isPending = booking.status == 'pending';

    if (!isPending) {
      return BookingTile(booking: booking);
    }

    return Stack(
      alignment: Alignment.centerRight,
      children: [
        BookingTile(booking: booking),
        Positioned(
          right: 28,
          child: IconButton(
            icon: const Icon(Icons.cancel_outlined, color: Colors.red),
            tooltip: 'Cancel booking',
            onPressed: () => _confirmCancel(context),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmCancel(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Huỷ đặt sân này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Không'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'Xác nhận',
              style: TextStyle(color: Colors.red),
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
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: Colors.grey),
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
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
