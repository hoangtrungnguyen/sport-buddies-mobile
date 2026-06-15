import 'package:customer/core/mixins/app_exception_mixin.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:spb_core/spb_core.dart';

part 'discovery_state.freezed.dart';

@freezed
sealed class DiscoveryState with _$DiscoveryState {
  const factory DiscoveryState.initial() = DiscoveryInitial;
  const factory DiscoveryState.loading() = DiscoveryLoading;

  const factory DiscoveryState.loaded(
    List<CourtAvailability> courts, {
    CourtAvailability? selectedCourt,
  }) = DiscoveryLoaded;

  @With<AppExceptionMixin>()
  const factory DiscoveryState.error(String message, {StackTrace? stackTrace}) =
      DiscoveryError;
}

extension DiscoveryLoadedX on DiscoveryLoaded {
  DiscoveryLoaded withSelection(CourtAvailability? court) =>
      copyWith(selectedCourt: court);

  List<CourtAvailability> applyFilter({
    required Set<String> sports,
    required double? maxDistanceKm,
    required LatLng? userPos,
    required bool onlyWithOpenSlots,
  }) {
    return courts.where((court) {
      if (onlyWithOpenSlots && court.openSlotCount == 0) return false;
      if (sports.isNotEmpty && !court.sportTypes.any(sports.contains)) {
        return false;
      }
      if (maxDistanceKm != null && userPos != null) {
        final courtPos = LatLng(court.lat, court.lng);
        if (!userPos.isWithinRadius(courtPos, maxDistanceKm)) return false;
      }
      return true;
    }).toList();
  }
}
