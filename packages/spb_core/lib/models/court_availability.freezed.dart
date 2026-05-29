// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'court_availability.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CourtAvailability {
  String get courtId;
  String get name;
  double get lat;
  double get lng;
  int get openSlotCount;
  String get sportType;

  /// Create a copy of CourtAvailability
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CourtAvailabilityCopyWith<CourtAvailability> get copyWith =>
      _$CourtAvailabilityCopyWithImpl<CourtAvailability>(
          this as CourtAvailability, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CourtAvailability &&
            (identical(other.courtId, courtId) || other.courtId == courtId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lng, lng) || other.lng == lng) &&
            (identical(other.openSlotCount, openSlotCount) ||
                other.openSlotCount == openSlotCount) &&
            (identical(other.sportType, sportType) ||
                other.sportType == sportType));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, courtId, name, lat, lng, openSlotCount, sportType);

  @override
  String toString() {
    return 'CourtAvailability(courtId: $courtId, name: $name, lat: $lat, lng: $lng, openSlotCount: $openSlotCount, sportType: $sportType)';
  }
}

/// @nodoc
abstract mixin class $CourtAvailabilityCopyWith<$Res> {
  factory $CourtAvailabilityCopyWith(
          CourtAvailability value, $Res Function(CourtAvailability) _then) =
      _$CourtAvailabilityCopyWithImpl;
  @useResult
  $Res call(
      {String courtId,
      String name,
      double lat,
      double lng,
      int openSlotCount,
      String sportType});
}

/// @nodoc
class _$CourtAvailabilityCopyWithImpl<$Res>
    implements $CourtAvailabilityCopyWith<$Res> {
  _$CourtAvailabilityCopyWithImpl(this._self, this._then);

  final CourtAvailability _self;
  final $Res Function(CourtAvailability) _then;

  /// Create a copy of CourtAvailability
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? courtId = null,
    Object? name = null,
    Object? lat = null,
    Object? lng = null,
    Object? openSlotCount = null,
    Object? sportType = null,
  }) {
    return _then(_self.copyWith(
      courtId: null == courtId
          ? _self.courtId
          : courtId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      lat: null == lat
          ? _self.lat
          : lat // ignore: cast_nullable_to_non_nullable
              as double,
      lng: null == lng
          ? _self.lng
          : lng // ignore: cast_nullable_to_non_nullable
              as double,
      openSlotCount: null == openSlotCount
          ? _self.openSlotCount
          : openSlotCount // ignore: cast_nullable_to_non_nullable
              as int,
      sportType: null == sportType
          ? _self.sportType
          : sportType // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [CourtAvailability].
extension CourtAvailabilityPatterns on CourtAvailability {
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
    TResult Function(_CourtAvailability value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CourtAvailability() when $default != null:
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
    TResult Function(_CourtAvailability value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CourtAvailability():
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
    TResult? Function(_CourtAvailability value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CourtAvailability() when $default != null:
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
    TResult Function(String courtId, String name, double lat, double lng,
            int openSlotCount, String sportType)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CourtAvailability() when $default != null:
        return $default(_that.courtId, _that.name, _that.lat, _that.lng,
            _that.openSlotCount, _that.sportType);
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
    TResult Function(String courtId, String name, double lat, double lng,
            int openSlotCount, String sportType)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CourtAvailability():
        return $default(_that.courtId, _that.name, _that.lat, _that.lng,
            _that.openSlotCount, _that.sportType);
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
    TResult? Function(String courtId, String name, double lat, double lng,
            int openSlotCount, String sportType)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CourtAvailability() when $default != null:
        return $default(_that.courtId, _that.name, _that.lat, _that.lng,
            _that.openSlotCount, _that.sportType);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _CourtAvailability extends CourtAvailability {
  const _CourtAvailability(
      {required this.courtId,
      required this.name,
      required this.lat,
      required this.lng,
      required this.openSlotCount,
      this.sportType = ''})
      : super._();

  @override
  final String courtId;
  @override
  final String name;
  @override
  final double lat;
  @override
  final double lng;
  @override
  final int openSlotCount;
  @override
  @JsonKey()
  final String sportType;

  /// Create a copy of CourtAvailability
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CourtAvailabilityCopyWith<_CourtAvailability> get copyWith =>
      __$CourtAvailabilityCopyWithImpl<_CourtAvailability>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CourtAvailability &&
            (identical(other.courtId, courtId) || other.courtId == courtId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lng, lng) || other.lng == lng) &&
            (identical(other.openSlotCount, openSlotCount) ||
                other.openSlotCount == openSlotCount) &&
            (identical(other.sportType, sportType) ||
                other.sportType == sportType));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, courtId, name, lat, lng, openSlotCount, sportType);

  @override
  String toString() {
    return 'CourtAvailability(courtId: $courtId, name: $name, lat: $lat, lng: $lng, openSlotCount: $openSlotCount, sportType: $sportType)';
  }
}

/// @nodoc
abstract mixin class _$CourtAvailabilityCopyWith<$Res>
    implements $CourtAvailabilityCopyWith<$Res> {
  factory _$CourtAvailabilityCopyWith(
          _CourtAvailability value, $Res Function(_CourtAvailability) _then) =
      __$CourtAvailabilityCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String courtId,
      String name,
      double lat,
      double lng,
      int openSlotCount,
      String sportType});
}

/// @nodoc
class __$CourtAvailabilityCopyWithImpl<$Res>
    implements _$CourtAvailabilityCopyWith<$Res> {
  __$CourtAvailabilityCopyWithImpl(this._self, this._then);

  final _CourtAvailability _self;
  final $Res Function(_CourtAvailability) _then;

  /// Create a copy of CourtAvailability
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? courtId = null,
    Object? name = null,
    Object? lat = null,
    Object? lng = null,
    Object? openSlotCount = null,
    Object? sportType = null,
  }) {
    return _then(_CourtAvailability(
      courtId: null == courtId
          ? _self.courtId
          : courtId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      lat: null == lat
          ? _self.lat
          : lat // ignore: cast_nullable_to_non_nullable
              as double,
      lng: null == lng
          ? _self.lng
          : lng // ignore: cast_nullable_to_non_nullable
              as double,
      openSlotCount: null == openSlotCount
          ? _self.openSlotCount
          : openSlotCount // ignore: cast_nullable_to_non_nullable
              as int,
      sportType: null == sportType
          ? _self.sportType
          : sportType // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
