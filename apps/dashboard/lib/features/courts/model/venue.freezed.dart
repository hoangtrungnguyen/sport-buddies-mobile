// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'venue.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Venue {
  String get id;
  String get courtId;
  String get name;
  String get sportType;
  int get capacity;
  int get pricePerHour;
  bool get isActive;
  bool get indoor;

  /// Create a copy of Venue
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $VenueCopyWith<Venue> get copyWith =>
      _$VenueCopyWithImpl<Venue>(this as Venue, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Venue &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.courtId, courtId) || other.courtId == courtId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.sportType, sportType) ||
                other.sportType == sportType) &&
            (identical(other.capacity, capacity) ||
                other.capacity == capacity) &&
            (identical(other.pricePerHour, pricePerHour) ||
                other.pricePerHour == pricePerHour) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.indoor, indoor) || other.indoor == indoor));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, courtId, name, sportType,
      capacity, pricePerHour, isActive, indoor);

  @override
  String toString() {
    return 'Venue(id: $id, courtId: $courtId, name: $name, sportType: $sportType, capacity: $capacity, pricePerHour: $pricePerHour, isActive: $isActive, indoor: $indoor)';
  }
}

/// @nodoc
abstract mixin class $VenueCopyWith<$Res> {
  factory $VenueCopyWith(Venue value, $Res Function(Venue) _then) =
      _$VenueCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String courtId,
      String name,
      String sportType,
      int capacity,
      int pricePerHour,
      bool isActive,
      bool indoor});
}

/// @nodoc
class _$VenueCopyWithImpl<$Res> implements $VenueCopyWith<$Res> {
  _$VenueCopyWithImpl(this._self, this._then);

  final Venue _self;
  final $Res Function(Venue) _then;

  /// Create a copy of Venue
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? courtId = null,
    Object? name = null,
    Object? sportType = null,
    Object? capacity = null,
    Object? pricePerHour = null,
    Object? isActive = null,
    Object? indoor = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      courtId: null == courtId
          ? _self.courtId
          : courtId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      sportType: null == sportType
          ? _self.sportType
          : sportType // ignore: cast_nullable_to_non_nullable
              as String,
      capacity: null == capacity
          ? _self.capacity
          : capacity // ignore: cast_nullable_to_non_nullable
              as int,
      pricePerHour: null == pricePerHour
          ? _self.pricePerHour
          : pricePerHour // ignore: cast_nullable_to_non_nullable
              as int,
      isActive: null == isActive
          ? _self.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      indoor: null == indoor
          ? _self.indoor
          : indoor // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// Adds pattern-matching-related methods to [Venue].
extension VenuePatterns on Venue {
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
    TResult Function(_Venue value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Venue() when $default != null:
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
    TResult Function(_Venue value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Venue():
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
    TResult? Function(_Venue value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Venue() when $default != null:
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
    TResult Function(String id, String courtId, String name, String sportType,
            int capacity, int pricePerHour, bool isActive, bool indoor)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Venue() when $default != null:
        return $default(_that.id, _that.courtId, _that.name, _that.sportType,
            _that.capacity, _that.pricePerHour, _that.isActive, _that.indoor);
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
    TResult Function(String id, String courtId, String name, String sportType,
            int capacity, int pricePerHour, bool isActive, bool indoor)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Venue():
        return $default(_that.id, _that.courtId, _that.name, _that.sportType,
            _that.capacity, _that.pricePerHour, _that.isActive, _that.indoor);
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
    TResult? Function(String id, String courtId, String name, String sportType,
            int capacity, int pricePerHour, bool isActive, bool indoor)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Venue() when $default != null:
        return $default(_that.id, _that.courtId, _that.name, _that.sportType,
            _that.capacity, _that.pricePerHour, _that.isActive, _that.indoor);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Venue extends Venue {
  const _Venue(
      {required this.id,
      required this.courtId,
      required this.name,
      required this.sportType,
      required this.capacity,
      required this.pricePerHour,
      required this.isActive,
      this.indoor = false})
      : super._();

  @override
  final String id;
  @override
  final String courtId;
  @override
  final String name;
  @override
  final String sportType;
  @override
  final int capacity;
  @override
  final int pricePerHour;
  @override
  final bool isActive;
  @override
  @JsonKey()
  final bool indoor;

  /// Create a copy of Venue
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$VenueCopyWith<_Venue> get copyWith =>
      __$VenueCopyWithImpl<_Venue>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Venue &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.courtId, courtId) || other.courtId == courtId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.sportType, sportType) ||
                other.sportType == sportType) &&
            (identical(other.capacity, capacity) ||
                other.capacity == capacity) &&
            (identical(other.pricePerHour, pricePerHour) ||
                other.pricePerHour == pricePerHour) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.indoor, indoor) || other.indoor == indoor));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, courtId, name, sportType,
      capacity, pricePerHour, isActive, indoor);

  @override
  String toString() {
    return 'Venue(id: $id, courtId: $courtId, name: $name, sportType: $sportType, capacity: $capacity, pricePerHour: $pricePerHour, isActive: $isActive, indoor: $indoor)';
  }
}

/// @nodoc
abstract mixin class _$VenueCopyWith<$Res> implements $VenueCopyWith<$Res> {
  factory _$VenueCopyWith(_Venue value, $Res Function(_Venue) _then) =
      __$VenueCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String courtId,
      String name,
      String sportType,
      int capacity,
      int pricePerHour,
      bool isActive,
      bool indoor});
}

/// @nodoc
class __$VenueCopyWithImpl<$Res> implements _$VenueCopyWith<$Res> {
  __$VenueCopyWithImpl(this._self, this._then);

  final _Venue _self;
  final $Res Function(_Venue) _then;

  /// Create a copy of Venue
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? courtId = null,
    Object? name = null,
    Object? sportType = null,
    Object? capacity = null,
    Object? pricePerHour = null,
    Object? isActive = null,
    Object? indoor = null,
  }) {
    return _then(_Venue(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      courtId: null == courtId
          ? _self.courtId
          : courtId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      sportType: null == sportType
          ? _self.sportType
          : sportType // ignore: cast_nullable_to_non_nullable
              as String,
      capacity: null == capacity
          ? _self.capacity
          : capacity // ignore: cast_nullable_to_non_nullable
              as int,
      pricePerHour: null == pricePerHour
          ? _self.pricePerHour
          : pricePerHour // ignore: cast_nullable_to_non_nullable
              as int,
      isActive: null == isActive
          ? _self.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      indoor: null == indoor
          ? _self.indoor
          : indoor // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on
