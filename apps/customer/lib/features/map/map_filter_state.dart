// Map filter state — grava-c9ca.3.1
//
// Holds the set of currently active sport filters for the map screen.
// An empty [selectedSports] means "show all" (no filter active).

/// State for [MapFilterCubit].
///
/// [selectedSports] is a set of sport identifiers (lower-case slugs, e.g.
/// `'football'`, `'basketball'`).  An empty set means "All" — no filter
/// is applied and every court marker is visible.
class MapFilterState {
  const MapFilterState({this.selectedSports = const {}});

  final Set<String> selectedSports;

  MapFilterState copyWith({Set<String>? selectedSports}) {
    return MapFilterState(
      selectedSports: selectedSports ?? this.selectedSports,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MapFilterState &&
          runtimeType == other.runtimeType &&
          _setsEqual(selectedSports, other.selectedSports);

  @override
  int get hashCode => Object.hashAll(selectedSports.toList()..sort());

  static bool _setsEqual(Set<String> a, Set<String> b) {
    if (a.length != b.length) return false;
    return a.containsAll(b);
  }
}
