// Display view model + Booking→view mappers for the My Bookings screen.
// (Static mock data removed — screens now render real Supabase data only.)

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'booking_model.dart';

enum BookingStatus { confirmed, pending, completed, cancelled }

enum SportType { pickleball, football, badminton, tennis }

enum BookingType { oneOff, recurring }

enum BookingRole { host, join }

class MockBooking {
  const MockBooking({
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
    this.statusLabelOverride,
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

  /// When set, the status badge shows this text instead of the default
  /// label derived from [status]/[role] (used for join requests).
  final String? statusLabelOverride;
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

String bookingStatusLabel(BookingStatus status, {BookingRole role = BookingRole.host}) =>
    switch (status) {
      BookingStatus.confirmed =>
        role == BookingRole.join ? 'Đã duyệt' : 'Đã xác nhận',
      BookingStatus.pending =>
        role == BookingRole.join ? 'Chờ duyệt' : 'Chờ xác nhận',
      BookingStatus.completed => 'Đã hoàn thành',
      BookingStatus.cancelled => 'Đã huỷ',
    };

// ---------------------------------------------------------------------------
// Booking → MockBooking display mapper
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
final _bookingPriceFmt =
    NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0);

extension BookingDisplay on Booking {
  MockBooking toMockBooking() {
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
      BookingStatus.pending => 'Huỷ',
      BookingStatus.confirmed => 'Chi tiết',
      BookingStatus.completed || BookingStatus.cancelled => 'Đặt lại',
    };
    final danger = mappedStatus == BookingStatus.pending;

    return MockBooking(
      id: id,
      courtId: slot.court.id,
      courtName: slot.court.name,
      sport: sport,
      detail: _bookingDateFmt.format(start),
      time:
          '${_bookingTimeFmt.format(start)} – ${_bookingTimeFmt.format(end)}',
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
// JoinedSlotRequest → MockBooking display mapper
// ---------------------------------------------------------------------------

extension JoinRequestDisplay on JoinedSlotRequest {
  MockBooking toMockBooking() {
    final start = slot.startTime.toLocal();
    final end = slot.endTime.toLocal();
    final sport = _parseSport(
      slot.court.sportTypes.isNotEmpty ? slot.court.sportTypes.first : '',
    );
    // Map join-request status onto the booking badge colours and the
    // CAPP-054 labels (Chờ xác nhận / Đã chấp nhận / Từ chối).
    final (mappedStatus, label) = switch (status) {
      'approved' => (BookingStatus.confirmed, 'Đã chấp nhận'),
      'rejected' => (BookingStatus.cancelled, 'Từ chối'),
      _ => (BookingStatus.pending, 'Chờ xác nhận'),
    };

    return MockBooking(
      id: id,
      courtId: slot.court.id,
      courtName: slot.court.name,
      sport: sport,
      detail: _bookingDateFmt.format(start),
      time:
          '${_bookingTimeFmt.format(start)} – ${_bookingTimeFmt.format(end)}',
      price: '—',
      status: mappedStatus,
      type: BookingType.oneOff,
      date: start,
      role: BookingRole.join,
      statusLabelOverride: label,
    );
  }
}

