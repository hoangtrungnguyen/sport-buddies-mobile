class OwnerCourt {
  const OwnerCourt({
    required this.id,
    required this.name,
    required this.sportTypes,
    required this.capacity,
    required this.openHour,
    required this.closeHour,
    required this.pricePerHour,
    required this.isActive,
    this.address,
    this.autoApproveSingle = false,
  });

  final String id;
  final String name;

  /// Matches `courts.sport_types  text[]`
  final List<String> sportTypes;

  final int capacity;

  /// Stored in `courts.operating_hours  jsonb` as {"open":6,"close":22}
  final int openHour;
  final int closeHour;

  /// Matches `courts.price_per_hour  numeric`
  final int pricePerHour;

  /// `courts.status != 'inactive'`
  final bool isActive;

  final String? address;

  /// Whether single-time booking requests are auto-approved for this court
  /// (`courts.auto_approve_single`). OWNER-44/45.
  final bool autoApproveSingle;

  /// First sport type for display convenience.
  String get primarySport =>
      sportTypes.isNotEmpty ? sportTypes.first : '';

  factory OwnerCourt.fromJson(Map<String, dynamic> json) {
    final sports = (json['sport_types'] as List?)
            ?.map((e) => e as String)
            .toList() ??
        [];
    final hours = json['operating_hours'] as Map<String, dynamic>?;
    return OwnerCourt(
      id: json['id'] as String,
      name: json['name'] as String,
      sportTypes: sports,
      capacity: (json['capacity'] as num?)?.toInt() ?? 2,
      openHour: (hours?['open'] as num?)?.toInt() ?? 6,
      closeHour: (hours?['close'] as num?)?.toInt() ?? 22,
      pricePerHour: (json['price_per_hour'] as num?)?.toInt() ?? 0,
      isActive: (json['status'] as String?) != 'inactive',
      address: json['address'] as String?,
      autoApproveSingle:
          (json['auto_approve_single'] as bool?) ?? false,
    );
  }

  OwnerCourt copyWith({
    String? name,
    List<String>? sportTypes,
    int? capacity,
    int? openHour,
    int? closeHour,
    int? pricePerHour,
    bool? isActive,
    bool? autoApproveSingle,
  }) =>
      OwnerCourt(
        id: id,
        name: name ?? this.name,
        sportTypes: sportTypes ?? this.sportTypes,
        capacity: capacity ?? this.capacity,
        openHour: openHour ?? this.openHour,
        closeHour: closeHour ?? this.closeHour,
        pricePerHour: pricePerHour ?? this.pricePerHour,
        isActive: isActive ?? this.isActive,
        address: address,
        autoApproveSingle: autoApproveSingle ?? this.autoApproveSingle,
      );
}
