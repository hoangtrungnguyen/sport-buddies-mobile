// Mock domain model + static data for the My Bookings screen.
// Replace with real BLoC/Supabase calls when backend is ready.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'booking_model.dart';

enum BookingStatus { confirmed, pending, completed, cancelled }

enum SportType { pickleball, football, badminton, tennis }

enum BookingType { oneOff, recurring }

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
    this.courtId,
    this.recurringLabel,
    this.slots = 1,
    this.action,
    this.actionDanger = false,
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
}

class MockJoinRequest {
  const MockJoinRequest({
    required this.id,
    required this.courtName,
    required this.detail,
    required this.timeAgo,
  });

  final String id;
  final String courtName;
  final String detail;
  final String timeAgo;
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

String bookingStatusLabel(BookingStatus status) => switch (status) {
      BookingStatus.confirmed => 'Đã xác nhận',
      BookingStatus.pending => 'Chờ xác nhận',
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
    );
  }
}

// ---------------------------------------------------------------------------
// Mock data
// ---------------------------------------------------------------------------

final _today = DateTime.now();
final _tomorrow = _today.add(const Duration(days: 1));
final _dayAfter = _today.add(const Duration(days: 2));

final List<MockBooking> mockUpcomingBookings = [
  MockBooking(
    id: '1',
    courtName: 'Pickle Hub Q1 · Sân B',
    sport: SportType.pickleball,
    detail: 'Thanh toán tại sân · 🌐 Mở chơi ghép',
    recurringLabel: 'Buổi 1/7 · Mỗi T3, T5 · 19:00 – 20:30',
    time: '19:00 – 20:30',
    price: '250k',
    status: BookingStatus.confirmed,
    type: BookingType.recurring,
    action: 'Xem cả lịch',
    date: _today,
  ),
  MockBooking(
    id: '2',
    courtName: 'Pickle Hub Q1 · Sân B',
    sport: SportType.pickleball,
    detail: 'Thanh toán tại sân · 🌐 Mở chơi ghép',
    time: '09:00 – 12:00',
    price: '610k',
    status: BookingStatus.confirmed,
    type: BookingType.oneOff,
    slots: 3,
    action: 'Quản lý người chơi',
    date: _today,
  ),
  MockBooking(
    id: '3',
    courtName: 'Sân Tao Đàn · Bóng 7',
    sport: SportType.football,
    detail: 'Thanh toán tại sân · 2 buổi liên tiếp',
    time: '20:00 – 23:00',
    price: '700k',
    status: BookingStatus.pending,
    type: BookingType.oneOff,
    slots: 2,
    action: 'Huỷ',
    actionDanger: true,
    date: _today,
  ),
  MockBooking(
    id: '4',
    courtName: 'Badminton Pro · Sân 3',
    sport: SportType.badminton,
    detail: 'Thanh toán tại sân',
    time: '18:00 – 19:30',
    price: '180k',
    status: BookingStatus.confirmed,
    type: BookingType.oneOff,
    action: 'Chi tiết',
    date: _tomorrow,
  ),
  MockBooking(
    id: '5',
    courtName: 'Pickle Hub Q1 · Sân B',
    sport: SportType.pickleball,
    detail: 'Thanh toán tại sân · 🌐 Mở chơi ghép',
    recurringLabel: 'Buổi 2/7 · Mỗi T3, T5',
    time: '19:00 – 20:30',
    price: '250k',
    status: BookingStatus.pending,
    type: BookingType.recurring,
    action: 'Xem cả lịch',
    date: _dayAfter,
  ),
];

final List<MockJoinRequest> mockJoinRequests = [
  const MockJoinRequest(
    id: 'jr1',
    courtName: 'Pickle Hub Q3 · Sân B',
    detail: 'Mai · 19:00 – 21:00 · 2/4 người',
    timeAgo: '2 giờ trước',
  ),
];

final List<MockBooking> mockHistoryBookings = [
  MockBooking(
    id: '101',
    courtId: 'court-pickle-q1',
    courtName: 'Pickle Hub Q1 · Sân A',
    sport: SportType.pickleball,
    detail: '13/05 · 1.5 giờ',
    time: '18:00 – 19:30',
    price: '200k',
    status: BookingStatus.completed,
    type: BookingType.oneOff,
    action: 'Đặt lại',
    date: _today.subtract(const Duration(days: 2)),
  ),
  MockBooking(
    id: '102',
    courtId: 'court-tennis-bt',
    courtName: 'CLB Tennis Bình Thạnh',
    sport: SportType.tennis,
    detail: '12/05 · 1 giờ',
    time: '06:00 – 07:00',
    price: '150k',
    status: BookingStatus.completed,
    type: BookingType.oneOff,
    action: 'Đặt lại',
    date: _today.subtract(const Duration(days: 3)),
  ),
  MockBooking(
    id: '103',
    courtName: 'Sân Nguyễn Du · Sân 5v5',
    sport: SportType.football,
    detail: '10/05 · Chủ sân từ chối',
    time: '21:00 – 22:30',
    price: '—',
    status: BookingStatus.cancelled,
    type: BookingType.oneOff,
    action: 'Xem lý do',
    date: _today.subtract(const Duration(days: 5)),
  ),
  MockBooking(
    id: '104',
    courtId: 'court-badminton-pro',
    courtName: 'Badminton Pro · Sân 1',
    sport: SportType.badminton,
    detail: '08/05 · 1.5 giờ',
    time: '19:00 – 20:30',
    price: '180k',
    status: BookingStatus.completed,
    type: BookingType.oneOff,
    action: 'Đặt lại',
    date: _today.subtract(const Duration(days: 7)),
  ),
  MockBooking(
    id: '105',
    courtId: 'court-pickle-q3',
    courtName: 'Pickle Hub Q3 · Sân B',
    sport: SportType.pickleball,
    detail: '05/05 · Bạn huỷ',
    time: '20:00 – 22:00',
    price: '—',
    status: BookingStatus.cancelled,
    type: BookingType.oneOff,
    action: 'Đặt lại',
    date: _today.subtract(const Duration(days: 10)),
  ),
];
