import 'package:customer/core/mixins/app_exception_mixin.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:spb_core/spb_core.dart';

part 'map_state.freezed.dart';

@freezed
sealed class MapState with _$MapState {
  const factory MapState.initial() = MapInitial;
  const factory MapState.loading() = MapLoading;

  const factory MapState.loaded(
    List<CourtAvailability> courts, {
    CourtAvailability? selectedCourt,
  }) = MapLoaded;

  @With<AppExceptionMixin>()
  const factory MapState.error(String message, {StackTrace? stackTrace}) =
      MapError;
}

extension MapLoadedX on MapLoaded {
  MapLoaded withSelection(CourtAvailability? court) =>
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
