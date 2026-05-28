class OwnerCourt {
  const OwnerCourt({
    required this.id,
    required this.name,
    required this.sportType,
    required this.capacity,
    required this.openHour,
    required this.closeHour,
    required this.pricePerHour,
    required this.isActive,
  });

  final String id;
  final String name;
  final String sportType;
  final int capacity;
  final int openHour;
  final int closeHour;
  final int pricePerHour;
  final bool isActive;

  factory OwnerCourt.fromJson(Map<String, dynamic> json) => OwnerCourt(
        id: json['id'] as String,
        name: json['name'] as String,
        sportType: (json['sport_type'] as String?) ?? '',
        capacity: (json['capacity'] as num?)?.toInt() ?? 2,
        openHour: (json['open_hour'] as num?)?.toInt() ?? 6,
        closeHour: (json['close_hour'] as num?)?.toInt() ?? 22,
        pricePerHour: (json['price_per_hour'] as num?)?.toInt() ?? 0,
        isActive: (json['status'] as String?) != 'inactive',
      );

  OwnerCourt copyWith({
    String? name,
    String? sportType,
    int? capacity,
    int? openHour,
    int? closeHour,
    int? pricePerHour,
    bool? isActive,
  }) =>
      OwnerCourt(
        id: id,
        name: name ?? this.name,
        sportType: sportType ?? this.sportType,
        capacity: capacity ?? this.capacity,
        openHour: openHour ?? this.openHour,
        closeHour: closeHour ?? this.closeHour,
        pricePerHour: pricePerHour ?? this.pricePerHour,
        isActive: isActive ?? this.isActive,
      );
}
