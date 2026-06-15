// DiscoveryCubit
//
// Fetches courts enriched with slot-availability data from
// [CourtAvailabilityRepository] and emits the appropriate [DiscoveryState].
//
// The cubit is pure business logic with no Flutter SDK dependency; it is
// provided to the widget tree via BlocProvider in the router builder (§6.2).

import 'package:customer/features/discovery/cubit/discovery_state.dart';
export 'package:customer/features/discovery/cubit/discovery_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spb_core/spb_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Cubit that manages the map's court list enriched with availability data.
///
/// Typical lifecycle:
///   1. BlocProvider creates the cubit and calls [loadCourts].
///   2. Cubit emits [DiscoveryLoading] while the repository is fetching.
///   3. On success: emits [DiscoveryLoaded] with the court list.
///   4. On failure: emits [DiscoveryError] with a human-readable message.
///
/// When availability data changes (e.g. a slot is booked), the widget can
/// call [loadCourts] again to refresh the markers.
class DiscoveryCubit extends Cubit<DiscoveryState> {
  DiscoveryCubit({
    required CourtAvailabilityRepository repository,
    SupabaseClient? realtimeClient,
  })  : _repository = repository,
        super(const DiscoveryState.initial()) {
    _setupRealtime(realtimeClient);
  }

  final CourtAvailabilityRepository _repository;
  RealtimeChannel? _channel;

  void _setupRealtime(SupabaseClient? client) {
    if (client == null) return;
    _channel = client.channel('discovery_slots_availability').onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'slots',
          callback: (_) {
            if (!isClosed) loadCourts();
          },
        );
    _channel!.subscribe();
  }

  @override
  Future<void> close() {
    _channel?.unsubscribe();
    return super.close();
  }

  /// Fetches courts with availability and updates state.
  ///
  /// Safe to call multiple times — each call resets to [DiscoveryLoading] first.
  Future<void> loadCourts() async {
    emit(const DiscoveryState.loading());

    final result = await _repository.fetchCourtsWithAvailability();
    result.when(
      success: (courts) => emit(DiscoveryState.loaded(courts)),
      failure: (failure) => emit(DiscoveryState.error(_failureMessage(failure))),
    );
  }

  /// Sets [court] as the selected court (shown in the preview panel).
  ///
  /// Pass null to deselect. No-op if the cubit is not in [DiscoveryLoaded] state.
  void selectCourt(CourtAvailability? court) {
    final s = state;
    if (s is DiscoveryLoaded) emit(s.withSelection(court));
  }

  /// Maps domain failures to user-facing messages.
  static String _failureMessage(AppFailure failure) {
    return switch (failure) {
      NetworkFailure() => 'No internet connection.',
      ServerFailure(code: final c) => 'Server error ($c).',
      AuthFailure(message: final m) => 'Authentication error: $m',
    };
  }
}
