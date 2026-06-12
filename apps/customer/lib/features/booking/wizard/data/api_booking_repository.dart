// Real [BookingRepository] — writes through the core-engine booking API,
// listens over Supabase Realtime (handoff doc 04 §7 "real mapping").
//
// Multi-slot bookings use the atomic `POST /api/bookings/batch` endpoint.
// Single-slot bookings fall back to `POST /api/bookings` for compatibility.

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
      // Use batch endpoint for multiple slots, single endpoint for one slot
      final slotIds = draft.slots.map((s) => s.slotId).toList();
      if (slotIds.length > 1) {
        final ids = await _api.createBatchBooking(
          slotIds: slotIds,
          customerName: contact.name,
          customerPhone: contact.phone,
          notes: contact.note,
        );
        primaryBookingId = ids.isNotEmpty ? ids.first : null;
      } else {
        primaryBookingId = await _api.createBooking(
          slotId: slotIds.first,
          customerName: contact.name,
          customerPhone: contact.phone,
          notes: contact.note,
        );
      }

      // Update slot access if open play-together
      if (access == AccessPolicy.open) {
        for (final slot in draft.slots) {
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

    if (primaryBookingId == null) {
      throw const BookingFailedException('no booking id returned');
    }

    return Booking(
      id: primaryBookingId,
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
