import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import 'booking_view.dart';

@immutable
sealed class HistoryState {
  const HistoryState();
}

class HistoryLoading extends HistoryState {
  const HistoryLoading();
}

class HistoryLoaded extends HistoryState {
  const HistoryLoaded(this.items);
  final List<HistoryBookingItem> items;
}

class HistoryError extends HistoryState {
  const HistoryError(this.message);
  final String message;
}

class HistoryBookingItem {
  const HistoryBookingItem({
    required this.id,
    required this.courtId,
    required this.courtName,
    required this.sport,
    required this.startAt,
    required this.endAt,
    required this.dbStatus,
    this.totalPrice,
  });

  final String id;
  final String courtId;
  final String courtName;
  final SportType sport;
  final DateTime startAt;
  final DateTime endAt;

  /// Raw DB value: 'completed' | 'cancelled'
  final String dbStatus;
  final double? totalPrice;

  static final _timeFmt = DateFormat('HH:mm');
  static final _dateFmt = DateFormat('dd/MM');
  static final _priceFmt = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '',
    decimalDigits: 0,
  );

  BookingStatus get bookingStatus => dbStatus == 'completed'
      ? BookingStatus.completed
      : BookingStatus.cancelled;

  BookingView toBookingView() {
    final price = totalPrice != null
        ? '${_priceFmt.format(totalPrice!).trim()}đ'
        : '—';

    return BookingView(
      id: id,
      courtId: courtId,
      courtName: courtName,
      sport: sport,
      detail: _dateFmt.format(startAt),
      time: '${_timeFmt.format(startAt)} – ${_timeFmt.format(endAt)}',
      price: price,
      status: bookingStatus,
      type: BookingType.oneOff,
      action: 'rebook',
      date: startAt,
    );
  }
}
