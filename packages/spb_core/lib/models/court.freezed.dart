// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'court.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Court {
  String get id;
  String get name;
  String? get ownerId;
  double get lat;
  double get lng;
  List<String> get sportTypes;
  String? get address;
  double? get pricePerHour;
  String? get description;
  List<String> get amenities;
  List<String> get photos;

  /// Create a copy of Court
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CourtCopyWith<Court> get copyWith =>
      _$CourtCopyWithImpl<Court>(this as Court, _$identity);

  /// Serializes this Court to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Court &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.ownerId, ownerId) || other.ownerId == ownerId) &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lng, lng) || other.lng == lng) &&
            const DeepCollectionEquality()
                .equals(other.sportTypes, sportTypes) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.pricePerHour, pricePerHour) ||
                other.pricePerHour == pricePerHour) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other.amenities, amenities) &&
            const DeepCollectionEquality().equals(other.photos, photos));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      ownerId,
      lat,
      lng,
      const DeepCollectionEquality().hash(sportTypes),
      address,
      pricePerHour,
      description,
      const DeepCollectionEquality().hash(amenities),
      const DeepCollectionEquality().hash(photos));

  @override
  String toString() {
    return 'Court(id: $id, name: $name, ownerId: $ownerId, lat: $lat, lng: $lng, sportTypes: $sportTypes, address: $address, pricePerHour: $pricePerHour, description: $description, amenities: $amenities, photos: $photos)';
  }
}

/// @nodoc
abstract mixin class $CourtCopyWith<$Res> {
  factory $CourtCopyWith(Court value, $Res Function(Court) _then) =
      _$CourtCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String name,
      String? ownerId,
      double lat,
      double lng,
      List<String> sportTypes,
      String? address,
      double? pricePerHour,
      String? description,
      List<String> amenities,
      List<String> photos});
}

/// @nodoc
class _$CourtCopyWithImpl<$Res> implements $CourtCopyWith<$Res> {
  _$CourtCopyWithImpl(this._self, this._then);

  final Court _self;
  final $Res Function(Court) _then;

  /// Create a copy of Court
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? ownerId = freezed,
    Object? lat = null,
    Object? lng = null,
    Object? sportTypes = null,
    Object? address = freezed,
    Object? pricePerHour = freezed,
    Object? description = freezed,
    Object? amenities = null,
    Object? photos = null,
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
      ownerId: freezed == ownerId
          ? _self.ownerId
          : ownerId // ignore: cast_nullable_to_non_nullable
              as String?,
      lat: null == lat
          ? _self.lat
          : lat // ignore: cast_nullable_to_non_nullable
              as double,
      lng: null == lng
          ? _self.lng
          : lng // ignore: cast_nullable_to_non_nullable
              as double,
      sportTypes: null == sportTypes
          ? _self.sportTypes
          : sportTypes // ignore: cast_nullable_to_non_nullable
              as List<String>,
      address: freezed == address
          ? _self.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      pricePerHour: freezed == pricePerHour
          ? _self.pricePerHour
          : pricePerHour // ignore: cast_nullable_to_non_nullable
              as double?,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      amenities: null == amenities
          ? _self.amenities
          : amenities // ignore: cast_nullable_to_non_nullable
              as List<String>,
      photos: null == photos
          ? _self.photos
          : photos // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// Adds pattern-matching-related methods to [Court].
extension CourtPatterns on Court {
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
    TResult Function(_Court value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Court() when $default != null:
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
    TResult Function(_Court value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Court():
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
    TResult? Function(_Court value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Court() when $default != null:
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
            String? ownerId,
            double lat,
            double lng,
            List<String> sportTypes,
            String? address,
            double? pricePerHour,
            String? description,
            List<String> amenities,
            List<String> photos)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Court() when $default != null:
        return $default(
            _that.id,
            _that.name,
            _that.ownerId,
            _that.lat,
            _that.lng,
            _that.sportTypes,
            _that.address,
            _that.pricePerHour,
            _that.description,
            _that.amenities,
            _that.photos);
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
            String? ownerId,
            double lat,
            double lng,
            List<String> sportTypes,
            String? address,
            double? pricePerHour,
            String? description,
            List<String> amenities,
            List<String> photos)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Court():
        return $default(
            _that.id,
            _that.name,
            _that.ownerId,
            _that.lat,
            _that.lng,
            _that.sportTypes,
            _that.address,
            _that.pricePerHour,
            _that.description,
            _that.amenities,
            _that.photos);
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
            String? ownerId,
            double lat,
            double lng,
            List<String> sportTypes,
            String? address,
            double? pricePerHour,
            String? description,
            List<String> amenities,
            List<String> photos)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Court() when $default != null:
        return $default(
            _that.id,
            _that.name,
            _that.ownerId,
            _that.lat,
            _that.lng,
            _that.sportTypes,
            _that.address,
            _that.pricePerHour,
            _that.description,
            _that.amenities,
            _that.photos);
      case _:
        return null;
    }
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _Court implements Court {
  const _Court(
      {required this.id,
      required this.name,
      this.ownerId,
      this.lat = 0.0,
      this.lng = 0.0,
      final List<String> sportTypes = const <String>[],
      this.address,
      this.pricePerHour,
      this.description,
      final List<String> amenities = const <String>[],
      final List<String> photos = const <String>[]})
      : _sportTypes = sportTypes,
        _amenities = amenities,
        _photos = photos;
  factory _Court.fromJson(Map<String, dynamic> json) => _$CourtFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? ownerId;
  @override
  @JsonKey()
  final double lat;
  @override
  @JsonKey()
  final double lng;
  final List<String> _sportTypes;
  @override
  @JsonKey()
  List<String> get sportTypes {
    if (_sportTypes is EqualUnmodifiableListView) return _sportTypes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sportTypes);
  }

  @override
  final String? address;
  @override
  final double? pricePerHour;
  @override
  final String? description;
  final List<String> _amenities;
  @override
  @JsonKey()
  List<String> get amenities {
    if (_amenities is EqualUnmodifiableListView) return _amenities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_amenities);
  }

  final List<String> _photos;
  @override
  @JsonKey()
  List<String> get photos {
    if (_photos is EqualUnmodifiableListView) return _photos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_photos);
  }

  /// Create a copy of Court
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CourtCopyWith<_Court> get copyWith =>
      __$CourtCopyWithImpl<_Court>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$CourtToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Court &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.ownerId, ownerId) || other.ownerId == ownerId) &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lng, lng) || other.lng == lng) &&
            const DeepCollectionEquality()
                .equals(other._sportTypes, _sportTypes) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.pricePerHour, pricePerHour) ||
                other.pricePerHour == pricePerHour) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality()
                .equals(other._amenities, _amenities) &&
            const DeepCollectionEquality().equals(other._photos, _photos));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      ownerId,
      lat,
      lng,
      const DeepCollectionEquality().hash(_sportTypes),
      address,
      pricePerHour,
      description,
      const DeepCollectionEquality().hash(_amenities),
      const DeepCollectionEquality().hash(_photos));

  @override
  String toString() {
    return 'Court(id: $id, name: $name, ownerId: $ownerId, lat: $lat, lng: $lng, sportTypes: $sportTypes, address: $address, pricePerHour: $pricePerHour, description: $description, amenities: $amenities, photos: $photos)';
  }
}

/// @nodoc
abstract mixin class _$CourtCopyWith<$Res> implements $CourtCopyWith<$Res> {
  factory _$CourtCopyWith(_Court value, $Res Function(_Court) _then) =
      __$CourtCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String? ownerId,
      double lat,
      double lng,
      List<String> sportTypes,
      String? address,
      double? pricePerHour,
      String? description,
      List<String> amenities,
      List<String> photos});
}

/// @nodoc
class __$CourtCopyWithImpl<$Res> implements _$CourtCopyWith<$Res> {
  __$CourtCopyWithImpl(this._self, this._then);

  final _Court _self;
  final $Res Function(_Court) _then;

  /// Create a copy of Court
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? ownerId = freezed,
    Object? lat = null,
    Object? lng = null,
    Object? sportTypes = null,
    Object? address = freezed,
    Object? pricePerHour = freezed,
    Object? description = freezed,
    Object? amenities = null,
    Object? photos = null,
  }) {
    return _then(_Court(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      ownerId: freezed == ownerId
          ? _self.ownerId
          : ownerId // ignore: cast_nullable_to_non_nullable
              as String?,
      lat: null == lat
          ? _self.lat
          : lat // ignore: cast_nullable_to_non_nullable
              as double,
      lng: null == lng
          ? _self.lng
          : lng // ignore: cast_nullable_to_non_nullable
              as double,
      sportTypes: null == sportTypes
          ? _self._sportTypes
          : sportTypes // ignore: cast_nullable_to_non_nullable
              as List<String>,
      address: freezed == address
          ? _self.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      pricePerHour: freezed == pricePerHour
          ? _self.pricePerHour
          : pricePerHour // ignore: cast_nullable_to_non_nullable
              as double?,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      amenities: null == amenities
          ? _self._amenities
          : amenities // ignore: cast_nullable_to_non_nullable
              as List<String>,
      photos: null == photos
          ? _self._photos
          : photos // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

// dart format on
