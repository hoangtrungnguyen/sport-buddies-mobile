// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'owner_court.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OwnerCourt {
  String get id;
  String get name;

  /// `courts.sport_types  text[]`
  List<String> get sportTypes;
  int get capacity;

  /// From `courts.operating_hours  jsonb` as {"open":6,"close":22}
  int get openHour;
  int get closeHour;

  /// `courts.price_per_hour  numeric`
  int get pricePerHour;

  /// `courts.status != 'inactive'`
  bool get isActive;

  /// `courts.address`
  String? get address;

  /// `courts.description`
  String? get description;

  /// `courts.amenities  text[]`
  List<String> get amenities;

  /// `courts.lat` / `courts.lng`
  double? get lat;
  double? get lng;

  /// `courts.auto_approve_single` — OWNER-44/45
  bool get autoApproveSingle;

  /// Create a copy of OwnerCourt
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $OwnerCourtCopyWith<OwnerCourt> get copyWith =>
      _$OwnerCourtCopyWithImpl<OwnerCourt>(this as OwnerCourt, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is OwnerCourt &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality()
                .equals(other.sportTypes, sportTypes) &&
            (identical(other.capacity, capacity) ||
                other.capacity == capacity) &&
            (identical(other.openHour, openHour) ||
                other.openHour == openHour) &&
            (identical(other.closeHour, closeHour) ||
                other.closeHour == closeHour) &&
            (identical(other.pricePerHour, pricePerHour) ||
                other.pricePerHour == pricePerHour) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other.amenities, amenities) &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lng, lng) || other.lng == lng) &&
            (identical(other.autoApproveSingle, autoApproveSingle) ||
                other.autoApproveSingle == autoApproveSingle));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      const DeepCollectionEquality().hash(sportTypes),
      capacity,
      openHour,
      closeHour,
      pricePerHour,
      isActive,
      address,
      description,
      const DeepCollectionEquality().hash(amenities),
      lat,
      lng,
      autoApproveSingle);

  @override
  String toString() {
    return 'OwnerCourt(id: $id, name: $name, sportTypes: $sportTypes, capacity: $capacity, openHour: $openHour, closeHour: $closeHour, pricePerHour: $pricePerHour, isActive: $isActive, address: $address, description: $description, amenities: $amenities, lat: $lat, lng: $lng, autoApproveSingle: $autoApproveSingle)';
  }
}

/// @nodoc
abstract mixin class $OwnerCourtCopyWith<$Res> {
  factory $OwnerCourtCopyWith(
          OwnerCourt value, $Res Function(OwnerCourt) _then) =
      _$OwnerCourtCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String name,
      List<String> sportTypes,
      int capacity,
      int openHour,
      int closeHour,
      int pricePerHour,
      bool isActive,
      String? address,
      String? description,
      List<String> amenities,
      double? lat,
      double? lng,
      bool autoApproveSingle});
}

/// @nodoc
class _$OwnerCourtCopyWithImpl<$Res> implements $OwnerCourtCopyWith<$Res> {
  _$OwnerCourtCopyWithImpl(this._self, this._then);

  final OwnerCourt _self;
  final $Res Function(OwnerCourt) _then;

  /// Create a copy of OwnerCourt
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? sportTypes = null,
    Object? capacity = null,
    Object? openHour = null,
    Object? closeHour = null,
    Object? pricePerHour = null,
    Object? isActive = null,
    Object? address = freezed,
    Object? description = freezed,
    Object? amenities = null,
    Object? lat = freezed,
    Object? lng = freezed,
    Object? autoApproveSingle = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      sportTypes: null == sportTypes
          ? _self.sportTypes
          : sportTypes // ignore: cast_nullable_to_non_nullable
              as List<String>,
      capacity: null == capacity
          ? _self.capacity
          : capacity // ignore: cast_nullable_to_non_nullable
              as int,
      openHour: null == openHour
          ? _self.openHour
          : openHour // ignore: cast_nullable_to_non_nullable
              as int,
      closeHour: null == closeHour
          ? _self.closeHour
          : closeHour // ignore: cast_nullable_to_non_nullable
              as int,
      pricePerHour: null == pricePerHour
          ? _self.pricePerHour
          : pricePerHour // ignore: cast_nullable_to_non_nullable
              as int,
      isActive: null == isActive
          ? _self.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      address: freezed == address
          ? _self.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      amenities: null == amenities
          ? _self.amenities
          : amenities // ignore: cast_nullable_to_non_nullable
              as List<String>,
      lat: freezed == lat
          ? _self.lat
          : lat // ignore: cast_nullable_to_non_nullable
              as double?,
      lng: freezed == lng
          ? _self.lng
          : lng // ignore: cast_nullable_to_non_nullable
              as double?,
      autoApproveSingle: null == autoApproveSingle
          ? _self.autoApproveSingle
          : autoApproveSingle // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// Adds pattern-matching-related methods to [OwnerCourt].
extension OwnerCourtPatterns on OwnerCourt {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_OwnerCourt value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _OwnerCourt() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_OwnerCourt value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OwnerCourt():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_OwnerCourt value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OwnerCourt() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String id,
            String name,
            List<String> sportTypes,
            int capacity,
            int openHour,
            int closeHour,
            int pricePerHour,
            bool isActive,
            String? address,
            String? description,
            List<String> amenities,
            double? lat,
            double? lng,
            bool autoApproveSingle)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _OwnerCourt() when $default != null:
        return $default(
            _that.id,
            _that.name,
            _that.sportTypes,
            _that.capacity,
            _that.openHour,
            _that.closeHour,
            _that.pricePerHour,
            _that.isActive,
            _that.address,
            _that.description,
            _that.amenities,
            _that.lat,
            _that.lng,
            _that.autoApproveSingle);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String id,
            String name,
            List<String> sportTypes,
            int capacity,
            int openHour,
            int closeHour,
            int pricePerHour,
            bool isActive,
            String? address,
            String? description,
            List<String> amenities,
            double? lat,
            double? lng,
            bool autoApproveSingle)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OwnerCourt():
        return $default(
            _that.id,
            _that.name,
            _that.sportTypes,
            _that.capacity,
            _that.openHour,
            _that.closeHour,
            _that.pricePerHour,
            _that.isActive,
            _that.address,
            _that.description,
            _that.amenities,
            _that.lat,
            _that.lng,
            _that.autoApproveSingle);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String id,
            String name,
            List<String> sportTypes,
            int capacity,
            int openHour,
            int closeHour,
            int pricePerHour,
            bool isActive,
            String? address,
            String? description,
            List<String> amenities,
            double? lat,
            double? lng,
            bool autoApproveSingle)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OwnerCourt() when $default != null:
        return $default(
            _that.id,
            _that.name,
            _that.sportTypes,
            _that.capacity,
            _that.openHour,
            _that.closeHour,
            _that.pricePerHour,
            _that.isActive,
            _that.address,
            _that.description,
            _that.amenities,
            _that.lat,
            _that.lng,
            _that.autoApproveSingle);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _OwnerCourt extends OwnerCourt {
  const _OwnerCourt(
      {required this.id,
      required this.name,
      required final List<String> sportTypes,
      required this.capacity,
      required this.openHour,
      required this.closeHour,
      required this.pricePerHour,
      required this.isActive,
      this.address,
      this.description,
      final List<String> amenities = const [],
      this.lat,
      this.lng,
      this.autoApproveSingle = false})
      : _sportTypes = sportTypes,
        _amenities = amenities,
        super._();

  @override
  final String id;
  @override
  final String name;

  /// `courts.sport_types  text[]`
  final List<String> _sportTypes;

  /// `courts.sport_types  text[]`
  @override
  List<String> get sportTypes {
    if (_sportTypes is EqualUnmodifiableListView) return _sportTypes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sportTypes);
  }

  @override
  final int capacity;

  /// From `courts.operating_hours  jsonb` as {"open":6,"close":22}
  @override
  final int openHour;
  @override
  final int closeHour;

  /// `courts.price_per_hour  numeric`
  @override
  final int pricePerHour;

  /// `courts.status != 'inactive'`
  @override
  final bool isActive;

  /// `courts.address`
  @override
  final String? address;

  /// `courts.description`
  @override
  final String? description;

  /// `courts.amenities  text[]`
  final List<String> _amenities;

  /// `courts.amenities  text[]`
  @override
  @JsonKey()
  List<String> get amenities {
    if (_amenities is EqualUnmodifiableListView) return _amenities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_amenities);
  }

  /// `courts.lat` / `courts.lng`
  @override
  final double? lat;
  @override
  final double? lng;

  /// `courts.auto_approve_single` — OWNER-44/45
  @override
  @JsonKey()
  final bool autoApproveSingle;

  /// Create a copy of OwnerCourt
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$OwnerCourtCopyWith<_OwnerCourt> get copyWith =>
      __$OwnerCourtCopyWithImpl<_OwnerCourt>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _OwnerCourt &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality()
                .equals(other._sportTypes, _sportTypes) &&
            (identical(other.capacity, capacity) ||
                other.capacity == capacity) &&
            (identical(other.openHour, openHour) ||
                other.openHour == openHour) &&
            (identical(other.closeHour, closeHour) ||
                other.closeHour == closeHour) &&
            (identical(other.pricePerHour, pricePerHour) ||
                other.pricePerHour == pricePerHour) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality()
                .equals(other._amenities, _amenities) &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lng, lng) || other.lng == lng) &&
            (identical(other.autoApproveSingle, autoApproveSingle) ||
                other.autoApproveSingle == autoApproveSingle));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      const DeepCollectionEquality().hash(_sportTypes),
      capacity,
      openHour,
      closeHour,
      pricePerHour,
      isActive,
      address,
      description,
      const DeepCollectionEquality().hash(_amenities),
      lat,
      lng,
      autoApproveSingle);

  @override
  String toString() {
    return 'OwnerCourt(id: $id, name: $name, sportTypes: $sportTypes, capacity: $capacity, openHour: $openHour, closeHour: $closeHour, pricePerHour: $pricePerHour, isActive: $isActive, address: $address, description: $description, amenities: $amenities, lat: $lat, lng: $lng, autoApproveSingle: $autoApproveSingle)';
  }
}

/// @nodoc
abstract mixin class _$OwnerCourtCopyWith<$Res>
    implements $OwnerCourtCopyWith<$Res> {
  factory _$OwnerCourtCopyWith(
          _OwnerCourt value, $Res Function(_OwnerCourt) _then) =
      __$OwnerCourtCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      List<String> sportTypes,
      int capacity,
      int openHour,
      int closeHour,
      int pricePerHour,
      bool isActive,
      String? address,
      String? description,
      List<String> amenities,
      double? lat,
      double? lng,
      bool autoApproveSingle});
}

/// @nodoc
class __$OwnerCourtCopyWithImpl<$Res> implements _$OwnerCourtCopyWith<$Res> {
  __$OwnerCourtCopyWithImpl(this._self, this._then);

  final _OwnerCourt _self;
  final $Res Function(_OwnerCourt) _then;

  /// Create a copy of OwnerCourt
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? sportTypes = null,
    Object? capacity = null,
    Object? openHour = null,
    Object? closeHour = null,
    Object? pricePerHour = null,
    Object? isActive = null,
    Object? address = freezed,
    Object? description = freezed,
    Object? amenities = null,
    Object? lat = freezed,
    Object? lng = freezed,
    Object? autoApproveSingle = null,
  }) {
    return _then(_OwnerCourt(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      sportTypes: null == sportTypes
          ? _self._sportTypes
          : sportTypes // ignore: cast_nullable_to_non_nullable
              as List<String>,
      capacity: null == capacity
          ? _self.capacity
          : capacity // ignore: cast_nullable_to_non_nullable
              as int,
      openHour: null == openHour
          ? _self.openHour
          : openHour // ignore: cast_nullable_to_non_nullable
              as int,
      closeHour: null == closeHour
          ? _self.closeHour
          : closeHour // ignore: cast_nullable_to_non_nullable
              as int,
      pricePerHour: null == pricePerHour
          ? _self.pricePerHour
          : pricePerHour // ignore: cast_nullable_to_non_nullable
              as int,
      isActive: null == isActive
          ? _self.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      address: freezed == address
          ? _self.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      amenities: null == amenities
          ? _self._amenities
          : amenities // ignore: cast_nullable_to_non_nullable
              as List<String>,
      lat: freezed == lat
          ? _self.lat
          : lat // ignore: cast_nullable_to_non_nullable
              as double?,
      lng: freezed == lng
          ? _self.lng
          : lng // ignore: cast_nullable_to_non_nullable
              as double?,
      autoApproveSingle: null == autoApproveSingle
          ? _self.autoApproveSingle
          : autoApproveSingle // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on
