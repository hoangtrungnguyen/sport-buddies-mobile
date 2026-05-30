import '../core/result.dart';
import '../models/court.dart';

/// Contract for fetching court data from the backend.
///
/// Concrete implementations live in `apps/customer`
/// (`SupabaseCourtRepository`) so that this pure-Dart package carries no
/// Supabase dependency.
abstract interface class CourtRepository {
  /// Returns all courts with `status = 'approved'`.
  Future<Result<List<Court>>> getApprovedCourts();

  /// Returns a single court by [courtId] with full detail fields.
  Future<Result<Court>> fetchCourtById(String courtId);
}
