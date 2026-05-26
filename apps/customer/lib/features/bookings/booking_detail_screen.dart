// Booking detail feature — BookingDetailScreen.
//
// Accessible via the '/bookings/:id' route.
//
// BLoC states handled:
//   BookingDetailLoading  → CircularProgressIndicator
//   BookingDetailLoaded   → Booking info + "Yêu cầu tham gia" section
//   BookingDetailError    → error message

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'booking_detail_cubit.dart';
import 'booking_detail_state.dart';

/// Route entry point — wraps the screen in a [BookingDetailCubit].
class BookingDetailPage extends StatelessWidget {
  const BookingDetailPage({super.key, required this.bookingId});

  final String bookingId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BookingDetailCubit(Supabase.instance.client)
        ..loadBookingDetail(bookingId),
      child: const BookingDetailScreen(),
    );
  }
}

/// The screen itself — reads from [BookingDetailCubit] via BlocBuilder.
class BookingDetailScreen extends StatelessWidget {
  const BookingDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết đặt sân'),
        leading: BackButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            }
          },
        ),
      ),
      body: BlocBuilder<BookingDetailCubit, BookingDetailState>(
        builder: (context, state) {
          return switch (state) {
            BookingDetailLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
            BookingDetailLoaded(:final booking, :final joinRequests) =>
              _LoadedBody(booking: booking, joinRequests: joinRequests),
            BookingDetailError(:final message) => _ErrorBody(message: message),
          };
        },
      ),
    );
  }
}

class _LoadedBody extends StatelessWidget {
  const _LoadedBody({
    required this.booking,
    required this.joinRequests,
  });

  final dynamic booking;
  final List<JoinRequest> joinRequests;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (booking != null) ...[
          _BookingInfoCard(booking: booking),
          const SizedBox(height: 24),
        ],
        _JoinRequestsSection(joinRequests: joinRequests),
      ],
    );
  }
}

class _BookingInfoCard extends StatelessWidget {
  const _BookingInfoCard({required this.booking});

  final dynamic booking;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              booking.slot.court.name,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '${_formatDateTime(booking.slot.startTime)} — '
              '${_formatTime(booking.slot.endTime)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            _StatusChip(status: booking.status),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year} '
        '${_formatTime(dt)}';
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(status),
      backgroundColor: _chipColor(status),
      labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
    );
  }

  Color _chipColor(String status) {
    return switch (status) {
      'confirmed' => Colors.green,
      'pending' => Colors.orange,
      'cancelled' => Colors.red,
      _ => Colors.grey,
    };
  }
}

class _JoinRequestsSection extends StatelessWidget {
  const _JoinRequestsSection({required this.joinRequests});

  final List<JoinRequest> joinRequests;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Yêu cầu tham gia',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        if (joinRequests.isEmpty)
          const _EmptyRequestsState()
        else
          ...joinRequests.map((req) => _JoinRequestTile(request: req)),
      ],
    );
  }
}

class _EmptyRequestsState extends StatelessWidget {
  const _EmptyRequestsState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(
          'Chưa có yêu cầu tham gia',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Colors.grey),
        ),
      ),
    );
  }
}

class _JoinRequestTile extends StatelessWidget {
  const _JoinRequestTile({required this.request});

  final JoinRequest request;

  @override
  Widget build(BuildContext context) {
    final initials = request.userName.isNotEmpty
        ? request.userName[0].toUpperCase()
        : '?';

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blueAccent,
        backgroundImage: request.avatarUrl != null
            ? NetworkImage(request.avatarUrl!)
            : null,
        child: request.avatarUrl == null
            ? Text(initials, style: const TextStyle(color: Colors.white))
            : null,
      ),
      title: Text(request.userName),
      subtitle: Text(request.status),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}
