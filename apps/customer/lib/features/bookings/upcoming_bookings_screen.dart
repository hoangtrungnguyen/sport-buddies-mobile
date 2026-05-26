// Bookings feature — UpcomingBookingsScreen.
//
// Accessible via the '/bookings/upcoming' route.
//
// BLoC states handled:
//   BookingsLoading  → CircularProgressIndicator
//   BookingsLoaded   → ListView of BookingTile; empty state when list is empty
//   BookingsError    → error message with retry button

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
            BookingsLoaded(:final bookings) when bookings.isEmpty =>
              const _EmptyState(),
            BookingsLoaded(:final bookings) => ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: bookings.length,
                itemBuilder: (context, index) =>
                    BookingTile(booking: bookings[index]),
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
