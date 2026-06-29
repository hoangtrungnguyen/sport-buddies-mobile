/// SportBuddies shared core library.
///
/// Pure Dart only — no Flutter, no Supabase. Consumed by `apps/customer`
/// (and any future apps) for entities, value objects, repository contracts,
/// and use cases. See the technical plan §1.3 for the layered architecture.
library;

export 'core/api_exception.dart';
export 'core/failures.dart';
export 'core/result.dart';
export 'core/theme/app_colors.dart';
export 'core/value_objects/lat_lng.dart';
export 'models/app_notification.dart';
export 'models/booking.dart';
export 'models/court.dart';
export 'models/court_availability.dart';
export 'models/slot.dart';
export 'repositories/court_availability_repository.dart';
export 'repositories/court_repository.dart';
export 'repositories/slot_repository.dart';
