// Mock domain model + static data for the My Bookings screen.
// Replace with real BLoC/Supabase calls when backend is ready.

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
// MockBooking → Booking domain mapper (dev fallback)
// ---------------------------------------------------------------------------

double? _parseMockPrice(String price) {
  if (price == '—') return null;
  final digits = price.replaceAll(RegExp(r'[^0-9]'), '');
  final value = int.tryParse(digits);
  if (value == null) return null;
  return (price.toLowerCase().contains('k') ? value * 1000 : value).toDouble();
}

Booking mockBookingToDomain(MockBooking mock) {
  final timeParts = mock.time.split(' – ');
  final sParts = timeParts[0].trim().split(':');
  final eParts = timeParts.length > 1 ? timeParts[1].trim().split(':') : sParts;
  final start = mock.date.copyWith(
    hour: int.tryParse(sParts[0]) ?? 0,
    minute: int.tryParse(sParts.length > 1 ? sParts[1] : '0') ?? 0,
    second: 0, millisecond: 0, microsecond: 0,
  );
  final end = mock.date.copyWith(
    hour: int.tryParse(eParts[0]) ?? 0,
    minute: int.tryParse(eParts.length > 1 ? eParts[1] : '0') ?? 0,
    second: 0, millisecond: 0, microsecond: 0,
  );
  final safeId = mock.id.padLeft(8, '0');
  return Booking(
    id: safeId,
    userId: '',
    status: mock.status.name,
    slot: Slot(
      id: 'mock-slot-${mock.id}',
      startTime: start,
      endTime: end,
      court: Court(
        id: mock.courtId ?? 'mock-court-${mock.id}',
        name: mock.courtName,
        sportTypes: [mock.sport.name],
      ),
    ),
    bookingType: mock.type == BookingType.recurring ? 'recurring' : 'one_off',
    sessionNumber: mock.type == BookingType.recurring ? 1 : null,
    totalSessions: mock.type == BookingType.recurring ? 7 : null,
    totalPrice: _parseMockPrice(mock.price),
  );
}

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
    role: BookingRole.host,
    players: '2/4 người',
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
    action: 'Quản lý',
    date: _today,
    role: BookingRole.host,
    players: '2/4 người',
  ),
  MockBooking(
    id: 'j1',
    courtName: 'Pickle Hub Q3 · Sân B',
    sport: SportType.pickleball,
    detail: 'Thanh toán tại sân · 2/4 người',
    time: '19:00 – 21:00',
    price: '120k/người',
    status: BookingStatus.confirmed,
    type: BookingType.oneOff,
    action: 'Nhắn chủ slot',
    date: _today,
    role: BookingRole.join,
    hostName: 'Minh Quân',
    hostInitials: 'MQ',
    hostColor: const Color(0xFF16A34A),
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
    date: _tomorrow,
    role: BookingRole.host,
  ),
  MockBooking(
    id: 'j2',
    courtName: 'Sân Tao Đàn · Bóng 7v7',
    sport: SportType.football,
    detail: 'Bạn đã gửi yêu cầu · 9/14 người · 2 giờ trước',
    time: '20:00 – 21:30',
    price: '120k/người',
    status: BookingStatus.pending,
    type: BookingType.oneOff,
    action: 'Huỷ yêu cầu',
    actionDanger: true,
    date: _tomorrow,
    role: BookingRole.join,
    hostName: 'Nguyễn Hoàng',
    hostInitials: 'NH',
    hostColor: const Color(0xFF0EA5E9),
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
    role: BookingRole.host,
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
    role: BookingRole.host,
  ),
  MockBooking(
    id: 'h-j1',
    courtName: 'Sân Tao Đàn · Bóng 7v7',
    sport: SportType.football,
    detail: '11/05 · 1.5 giờ',
    time: '20:00 – 21:30',
    price: '120k/người',
    status: BookingStatus.completed,
    type: BookingType.oneOff,
    action: 'Tìm slot khác',
    date: _today.subtract(const Duration(days: 4)),
    role: BookingRole.join,
    hostName: 'Lê Anh Tuấn',
    hostInitials: 'LA',
    hostColor: const Color(0xFFEF4444),
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
    role: BookingRole.host,
  ),
  MockBooking(
    id: 'h-j2',
    courtName: 'Sân Nguyễn Du · Sân 5v5',
    sport: SportType.football,
    detail: '10/05 · Chủ slot từ chối yêu cầu',
    time: '21:00 – 22:30',
    price: '—',
    status: BookingStatus.cancelled,
    type: BookingType.oneOff,
    action: 'Tìm slot khác',
    date: _today.subtract(const Duration(days: 5)),
    role: BookingRole.join,
    hostName: 'Phạm Thuỷ',
    hostInitials: 'PT',
    hostColor: const Color(0xFF16A34A),
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
    role: BookingRole.host,
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
    role: BookingRole.host,
  ),
];
