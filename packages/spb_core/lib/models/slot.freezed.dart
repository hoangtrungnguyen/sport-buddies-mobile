// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'slot.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Slot {
  String get id;
  DateTime get startTime;
  DateTime get endTime;
  String get courtId;
  String get courtName;
  String get sportType;
  String get accessPolicy;
  int get maxPlayers;
  int get currentPlayers;
  String? get hostId;

  /// Create a copy of Slot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SlotCopyWith<Slot> get copyWith =>
      _$SlotCopyWithImpl<Slot>(this as Slot, _$identity);

  /// Serializes this Slot to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Slot &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.courtId, courtId) || other.courtId == courtId) &&
            (identical(other.courtName, courtName) ||
                other.courtName == courtName) &&
            (identical(other.sportType, sportType) ||
                other.sportType == sportType) &&
            (identical(other.accessPolicy, accessPolicy) ||
                other.accessPolicy == accessPolicy) &&
            (identical(other.maxPlayers, maxPlayers) ||
                other.maxPlayers == maxPlayers) &&
            (identical(other.currentPlayers, currentPlayers) ||
                other.currentPlayers == currentPlayers) &&
            (identical(other.hostId, hostId) || other.hostId == hostId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, startTime, endTime, courtId,
      courtName, sportType, accessPolicy, maxPlayers, currentPlayers, hostId);

  @override
  String toString() {
    return 'Slot(id: $id, startTime: $startTime, endTime: $endTime, courtId: $courtId, courtName: $courtName, sportType: $sportType, accessPolicy: $accessPolicy, maxPlayers: $maxPlayers, currentPlayers: $currentPlayers, hostId: $hostId)';
  }
}

/// @nodoc
abstract mixin class $SlotCopyWith<$Res> {
  factory $SlotCopyWith(Slot value, $Res Function(Slot) _then) =
      _$SlotCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      DateTime startTime,
      DateTime endTime,
      String courtId,
      String courtName,
      String sportType,
      String accessPolicy,
      int maxPlayers,
      int currentPlayers,
      String? hostId});
}

/// @nodoc
class _$SlotCopyWithImpl<$Res> implements $SlotCopyWith<$Res> {
  _$SlotCopyWithImpl(this._self, this._then);

  final Slot _self;
  final $Res Function(Slot) _then;

  /// Create a copy of Slot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? courtId = null,
    Object? courtName = null,
    Object? sportType = null,
    Object? accessPolicy = null,
    Object? maxPlayers = null,
    Object? currentPlayers = null,
    Object? hostId = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      startTime: null == startTime
          ? _self.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endTime: null == endTime
          ? _self.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      courtId: null == courtId
          ? _self.courtId
          : courtId // ignore: cast_nullable_to_non_nullable
              as String,
      courtName: null == courtName
          ? _self.courtName
          : courtName // ignore: cast_nullable_to_non_nullable
              as String,
      sportType: null == sportType
          ? _self.sportType
          : sportType // ignore: cast_nullable_to_non_nullable
              as String,
      accessPolicy: null == accessPolicy
          ? _self.accessPolicy
          : accessPolicy // ignore: cast_nullable_to_non_nullable
              as String,
      maxPlayers: null == maxPlayers
          ? _self.maxPlayers
          : maxPlayers // ignore: cast_nullable_to_non_nullable
              as int,
      currentPlayers: null == currentPlayers
          ? _self.currentPlayers
          : currentPlayers // ignore: cast_nullable_to_non_nullable
              as int,
      hostId: freezed == hostId
          ? _self.hostId
          : hostId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [Slot].
extension SlotPatterns on Slot {
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
    TResult Function(_Slot value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Slot() when $default != null:
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
    TResult Function(_Slot value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Slot():
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
    TResult? Function(_Slot value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Slot() when $default != null:
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
            DateTime startTime,
            DateTime endTime,
            String courtId,
            String courtName,
            String sportType,
            String accessPolicy,
            int maxPlayers,
            int currentPlayers,
            String? hostId)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Slot() when $default != null:
        return $default(
            _that.id,
            _that.startTime,
            _that.endTime,
            _that.courtId,
            _that.courtName,
            _that.sportType,
            _that.accessPolicy,
            _that.maxPlayers,
            _that.currentPlayers,
            _that.hostId);
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
            DateTime startTime,
            DateTime endTime,
            String courtId,
            String courtName,
            String sportType,
            String accessPolicy,
            int maxPlayers,
            int currentPlayers,
            String? hostId)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Slot():
        return $default(
            _that.id,
            _that.startTime,
            _that.endTime,
            _that.courtId,
            _that.courtName,
            _that.sportType,
            _that.accessPolicy,
            _that.maxPlayers,
            _that.currentPlayers,
            _that.hostId);
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
            DateTime startTime,
            DateTime endTime,
            String courtId,
            String courtName,
            String sportType,
            String accessPolicy,
            int maxPlayers,
            int currentPlayers,
            String? hostId)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Slot() when $default != null:
        return $default(
            _that.id,
            _that.startTime,
            _that.endTime,
            _that.courtId,
            _that.courtName,
            _that.sportType,
            _that.accessPolicy,
            _that.maxPlayers,
            _that.currentPlayers,
            _that.hostId);
      case _:
        return null;
    }
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _Slot extends Slot {
  const _Slot(
      {required this.id,
      required this.startTime,
      required this.endTime,
      required this.courtId,
      required this.courtName,
      required this.sportType,
      this.accessPolicy = 'open',
      this.maxPlayers = 4,
      this.currentPlayers = 0,
      this.hostId})
      : super._();
  factory _Slot.fromJson(Map<String, dynamic> json) => _$SlotFromJson(json);

  @override
  final String id;
  @override
  final DateTime startTime;
  @override
  final DateTime endTime;
  @override
  final String courtId;
  @override
  final String courtName;
  @override
  final String sportType;
  @override
  @JsonKey()
  final String accessPolicy;
  @override
  @JsonKey()
  final int maxPlayers;
  @override
  @JsonKey()
  final int currentPlayers;
  @override
  final String? hostId;

  /// Create a copy of Slot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SlotCopyWith<_Slot> get copyWith =>
      __$SlotCopyWithImpl<_Slot>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SlotToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Slot &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.courtId, courtId) || other.courtId == courtId) &&
            (identical(other.courtName, courtName) ||
                other.courtName == courtName) &&
            (identical(other.sportType, sportType) ||
                other.sportType == sportType) &&
            (identical(other.accessPolicy, accessPolicy) ||
                other.accessPolicy == accessPolicy) &&
            (identical(other.maxPlayers, maxPlayers) ||
                other.maxPlayers == maxPlayers) &&
            (identical(other.currentPlayers, currentPlayers) ||
                other.currentPlayers == currentPlayers) &&
            (identical(other.hostId, hostId) || other.hostId == hostId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, startTime, endTime, courtId,
      courtName, sportType, accessPolicy, maxPlayers, currentPlayers, hostId);

  @override
  String toString() {
    return 'Slot(id: $id, startTime: $startTime, endTime: $endTime, courtId: $courtId, courtName: $courtName, sportType: $sportType, accessPolicy: $accessPolicy, maxPlayers: $maxPlayers, currentPlayers: $currentPlayers, hostId: $hostId)';
  }
}

/// @nodoc
abstract mixin class _$SlotCopyWith<$Res> implements $SlotCopyWith<$Res> {
  factory _$SlotCopyWith(_Slot value, $Res Function(_Slot) _then) =
      __$SlotCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      DateTime startTime,
      DateTime endTime,
      String courtId,
      String courtName,
      String sportType,
      String accessPolicy,
      int maxPlayers,
      int currentPlayers,
      String? hostId});
}

/// @nodoc
class __$SlotCopyWithImpl<$Res> implements _$SlotCopyWith<$Res> {
  __$SlotCopyWithImpl(this._self, this._then);

  final _Slot _self;
  final $Res Function(_Slot) _then;

  /// Create a copy of Slot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? courtId = null,
    Object? courtName = null,
    Object? sportType = null,
    Object? accessPolicy = null,
    Object? maxPlayers = null,
    Object? currentPlayers = null,
    Object? hostId = freezed,
  }) {
    return _then(_Slot(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      startTime: null == startTime
          ? _self.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endTime: null == endTime
          ? _self.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      courtId: null == courtId
          ? _self.courtId
          : courtId // ignore: cast_nullable_to_non_nullable
              as String,
      courtName: null == courtName
          ? _self.courtName
          : courtName // ignore: cast_nullable_to_non_nullable
              as String,
      sportType: null == sportType
          ? _self.sportType
          : sportType // ignore: cast_nullable_to_non_nullable
              as String,
      accessPolicy: null == accessPolicy
          ? _self.accessPolicy
          : accessPolicy // ignore: cast_nullable_to_non_nullable
              as String,
      maxPlayers: null == maxPlayers
          ? _self.maxPlayers
          : maxPlayers // ignore: cast_nullable_to_non_nullable
              as int,
      currentPlayers: null == currentPlayers
          ? _self.currentPlayers
          : currentPlayers // ignore: cast_nullable_to_non_nullable
              as int,
      hostId: freezed == hostId
          ? _self.hostId
          : hostId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
