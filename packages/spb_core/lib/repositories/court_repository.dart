import '../core/result.dart';
import '../models/court.dart';

/// Contract for fetching court data from the backend.
///
/// Concrete implementations live in `apps/customer`
/// (`SupabaseCourtRepository`) so that this pure-Dart package carries no
/// Supabase dependency.
abstract interface class CourtRepository {
  /// Returns all courts with `status = 'approved'`.
  ///
  /// Resolves to [Success<List<Court>>] on a successful response or
  /// [Failure] (wrapping an [AppFailure]) on network / server error.
  Future<Result<List<Court>>> getApprovedCourts();
}
