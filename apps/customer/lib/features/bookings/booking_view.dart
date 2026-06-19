// BookingView display view-model + Booking→view mappers for the My Bookings
// screen. Renders real Supabase data (no mock/seed data).

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'booking_model.dart';

enum BookingStatus { confirmed, pending, completed, cancelled }

enum SportType { pickleball, football, badminton, tennis }

enum BookingType { oneOff, recurring }

enum BookingRole { host, join }

class BookingView {
  const BookingView({
    required this.id,
    required this.courtName,
    required this.sport,
    required this.detail,
    required this.time,
    required this.price,
    required this.status,
    required this.type,
    required this.date,
    this.role = BookingRole.host,
    this.courtId,
    this.recurringLabel,
    this.slots = 1,
    this.action,
    this.actionDanger = false,
    this.players,
    this.hostName,
    this.hostInitials,
    this.hostColor,
    this.statusOverrideToken,
  });

  final String id;
  final String? courtId;
  final String courtName;
  final SportType sport;
  final String detail;
  final String? recurringLabel;
  final String time;
  final String price;
  final BookingStatus status;
  final BookingType type;
  final int slots;
  final String? action;
  final bool actionDanger;
  final DateTime date;
  final BookingRole role;
  final String? players;
  final String? hostName;
  final String? hostInitials;
  final Color? hostColor;

  /// When set, the status badge uses this join-request token instead of the
  /// default label derived from [status]/[role]: 'accepted' | 'rejected' |
  /// 'pending'. The screen resolves it to a localized string.
  final String? statusOverrideToken;
}

Color bookingSportColor(SportType sport) => switch (sport) {
  SportType.pickleball => const Color(0xFF0EA5E9),
  SportType.football => const Color(0xFF16A34A),
  SportType.badminton => const Color(0xFFEAB308),
  SportType.tennis => const Color(0xFFEF4444),
};

String bookingSportEmoji(SportType sport) => switch (sport) {
  SportType.pickleball => '🏓',
  SportType.football => '⚽',
  SportType.badminton => '🏸',
  SportType.tennis => '🎾',
};

// ---------------------------------------------------------------------------
// Booking → BookingView display mapper
// ---------------------------------------------------------------------------

SportType _parseSport(String raw) => switch (raw.toLowerCase().trim()) {
  'football' || 'soccer' || 'bóng đá' => SportType.football,
  'badminton' || 'cầu lông' => SportType.badminton,
  'tennis' => SportType.tennis,
  _ => SportType.pickleball,
};

BookingStatus _parseStatus(String raw) => switch (raw) {
  'pending' => BookingStatus.pending,
  'confirmed' => BookingStatus.confirmed,
  'completed' => BookingStatus.completed,
  'cancelled' => BookingStatus.cancelled,
  _ => BookingStatus.pending,
};

final _bookingDateFmt = DateFormat('dd/MM');
final _bookingTimeFmt = DateFormat('HH:mm');
final _bookingPriceFmt = NumberFormat.currency(
  locale: 'vi_VN',
  symbol: '',
  decimalDigits: 0,
);

extension BookingDisplay on Booking {
  BookingView toBookingView() {
    final start = slot.startTime.toLocal();
    final end = slot.endTime.toLocal();
    final sport = _parseSport(
      slot.court.sportTypes.isNotEmpty ? slot.court.sportTypes.first : '',
    );
    final type = bookingType == 'recurring'
        ? BookingType.recurring
        : BookingType.oneOff;
    final mappedStatus = _parseStatus(status);
    final priceLabel = totalPrice != null && totalPrice! > 0
        ? '${_bookingPriceFmt.format(totalPrice).trim()}đ'
        : '—';
    final action = switch (mappedStatus) {
      BookingStatus.pending => 'cancel',
      BookingStatus.confirmed => 'detail',
      BookingStatus.completed || BookingStatus.cancelled => 'rebook',
    };
    final danger = mappedStatus == BookingStatus.pending;

    return BookingView(
      id: id,
      courtId: slot.court.id,
      courtName: slot.court.name,
      sport: sport,
      detail: _bookingDateFmt.format(start),
      time: '${_bookingTimeFmt.format(start)} – ${_bookingTimeFmt.format(end)}',
      price: priceLabel,
      status: mappedStatus,
      type: type,
      date: start,
      action: action,
      actionDanger: danger,
      role: BookingRole.host,
    );
  }
}

// ---------------------------------------------------------------------------
// JoinedSlotRequest → BookingView display mapper
// ---------------------------------------------------------------------------

extension JoinRequestDisplay on JoinedSlotRequest {
  BookingView toBookingView() {
    final start = slot.startTime.toLocal();
    final end = slot.endTime.toLocal();
    final sport = _parseSport(
      slot.court.sportTypes.isNotEmpty ? slot.court.sportTypes.first : '',
    );
    // Map join-request status onto the booking badge colours and a token the
    // screen resolves to a localized label (accepted / rejected / pending).
    final (mappedStatus, overrideToken) = switch (status) {
      'approved' => (BookingStatus.confirmed, 'accepted'),
      'rejected' => (BookingStatus.cancelled, 'rejected'),
      _ => (BookingStatus.pending, 'pending'),
    };

    return BookingView(
      id: id,
      courtId: slot.court.id,
      courtName: slot.court.name,
      sport: sport,
      detail: _bookingDateFmt.format(start),
      time: '${_bookingTimeFmt.format(start)} – ${_bookingTimeFmt.format(end)}',
      price: '—',
      status: mappedStatus,
      type: BookingType.oneOff,
      date: start,
      role: BookingRole.join,
      statusOverrideToken: overrideToken,
    );
  }
}
