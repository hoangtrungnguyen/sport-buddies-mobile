import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Formatting + icon helpers shared across the "Sân của tôi" M3 redesign.

final NumberFormat _vnd = NumberFormat.decimalPattern('vi_VN');

/// `120000` → `120.000đ` (vi-VN grouping).
String formatVnd(int amount) => '${_vnd.format(amount)}đ';

/// `120000` → `120.000đ / mỗi giờ`.
String formatPricePerHour(int amount) => '${formatVnd(amount)} / mỗi giờ';

/// `6` → `06:00`. Operating hours are whole-hour ints in the DB.
String formatHour(int hour) => '${hour.toString().padLeft(2, '0')}:00';

/// Maps a `venues.sport_type` Vietnamese label to a Material Symbol.
IconData sportIcon(String sportType) {
  final s = sportType.toLowerCase();
  if (s.contains('bóng đá') || s.contains('bong da')) return Symbols.sports_soccer;
  if (s.contains('bóng rổ') || s.contains('bong ro')) return Symbols.sports_basketball;
  if (s.contains('pickleball')) return Symbols.sports_tennis;
  if (s.contains('tennis')) return Symbols.sports_tennis;
  if (s.contains('cầu lông') || s.contains('cau long')) return Symbols.sports_tennis;
  return Symbols.stadium;
}

/// Maps a `courts.amenities` Vietnamese label to a Material Symbol.
IconData amenityIcon(String amenity) {
  switch (amenity) {
    case 'Bãi đậu xe':
      return Symbols.local_parking;
    case 'Phòng thay đồ':
      return Symbols.checkroom;
    case 'Nhà vệ sinh':
      return Symbols.wc;
    case 'Căng tin':
      return Symbols.storefront;
    case 'Thuê thiết bị':
      return Symbols.sports_tennis;
    case 'WiFi':
      return Symbols.wifi;
    case 'Đèn chiếu sáng':
      return Symbols.lightbulb;
    case 'Mái che':
      return Symbols.roofing;
    default:
      return Symbols.check_circle;
  }
}
