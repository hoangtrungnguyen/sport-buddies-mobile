// Real [BookingRepository] — writes through the core-engine booking API,
// listens over Supabase Realtime (handoff doc 04 §7 "real mapping").
//
// Backend constraint: `POST /api/bookings` claims ONE slot per call (there is
// no multi-slot atomic endpoint yet). For a multi-slot draft we claim slots
// sequentially and watch the first booking. If a later slot loses the race we
// surface [SlotTakenException]; the slots already claimed remain (true
// multi-slot atomicity needs a server-side `create_booking(uuid[])` RPC —
// tracked separately). Single-slot bookings — the common case for the
// GTM-1-court phase — are fully atomic.

import 'dart:async';

import 'package:customer/core/debug/app_logger.dart';
import 'package:customer/core/services/booking_api_client.dart';
import 'package:customer/features/booking/wizard/data/booking_repository.dart';
import 'package:customer/features/booking/wizard/domain/booking.dart';
import 'package:customer/features/court/domain/booking_draft.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ApiBookingRepository implements BookingRepository {
  ApiBookingRepository({
    required SupabaseClient client,
    required BookingApiClient api,
  })  : _client = client,
        _api = api;

  final SupabaseClient _client;
  final BookingApiClient _api;

  @override
  Future<Booking> createBooking({
    required BookingDraft draft,
    required ContactInfo contact,
    required AccessPolicy access,
    required int maxPlayers,
  }) async {
    if (draft.slots.isEmpty) {
      throw const BookingFailedException('empty draft');
    }

    String? primaryBookingId;
    try {
      for (final slot in draft.slots) {
        final id = await _api.createBooking(
          slotId: slot.slotId,
          customerName: contact.name,
          customerPhone: contact.phone,
          notes: contact.note,
        );
        primaryBookingId ??= id;

        if (access == AccessPolicy.open) {
          await _api.updateSlotAccess(
            slotId: slot.slotId,
            accessPolicy: 'open',
            maxPlayers: maxPlayers,
          );
        }
      }
    } on SlotUnavailableException catch (e, st) {
      appLogger.e('ApiBookingRepository.createBooking: slot taken',
          error: e, stackTrace: st);
      throw const SlotTakenException(<String>[]);
    } on NoConnectionException {
      throw const BookingFailedException('no_connection');
    } on BookingApiException catch (e, st) {
      appLogger.e('ApiBookingRepository.createBooking', error: e, stackTrace: st);
      throw BookingFailedException(e.code);
    } catch (e, st) {
      appLogger.e('ApiBookingRepository.createBooking: unexpected',
          error: e, stackTrace: st);
      throw const BookingFailedException();
    }

    return Booking(
      id: primaryBookingId!,
      status: BookingStatus.pending,
      centerId: draft.centerId,
      courtId: draft.courtId,
      slots: draft.slots,
      access: access,
      maxPlayers: access == AccessPolicy.open ? maxPlayers : null,
      totalVnd: draft.totalVnd,
      createdAt: DateTime.now(),
    );
  }

  @override
  Stream<Booking> watchBooking(Booking booking) {
    final controller = StreamController<Booking>();
    final channel = _client.channel('booking_watch_${booking.id}');

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'bookings',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: booking.id,
          ),
          callback: (payload) {
            final status =
                BookingStatusX.fromRow(payload.newRecord['status'] as String?);
            controller.add(booking.copyWith(
              status: status,
              confirmedAt:
                  status == BookingStatus.confirmed ? DateTime.now() : null,
            ));
          },
        )
        .subscribe();

    controller.onCancel = () => channel.unsubscribe();
    return controller.stream;
  }
}
