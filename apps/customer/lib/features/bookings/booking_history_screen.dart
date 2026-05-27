// Booking History feature — BookingHistoryScreen.
//
// Accessible via the '/bookings/history' route.
//
// BLoC states handled:
//   BookingsLoading  → CircularProgressIndicator
//   BookingsLoaded   → ListView of BookingTile; empty state when list is empty
//   BookingsError    → error message with retry button

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'booking_history_cubit.dart';
import 'booking_tile.dart';
import 'bookings_state.dart';

/// Route entry point — wraps the screen in a [BookingHistoryCubit].
class BookingHistoryPage extends StatelessWidget {
  const BookingHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          BookingHistoryCubit(Supabase.instance.client)..loadHistory(),
      child: const BookingHistoryScreen(),
    );
  }
}

/// The screen itself — reads from [BookingHistoryCubit] via BlocBuilder.
class BookingHistoryScreen extends StatelessWidget {
  const BookingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lịch sử đặt sân')),
      body: BlocBuilder<BookingHistoryCubit, BookingsState>(
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
                itemBuilder: (context, index) =>
                    BookingTile(booking: bookings[index]),
              ),
            BookingsError(:final message) => _ErrorState(
                message: message,
                onRetry: () =>
                    context.read<BookingHistoryCubit>().loadHistory(),
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
          const Icon(Icons.history, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Không có lịch sử đặt sân',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Các lịch đặt đã hoàn thành hoặc huỷ sẽ hiện ở đây.',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
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
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}
