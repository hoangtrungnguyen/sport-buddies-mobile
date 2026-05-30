// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'owner_slot.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OwnerSlot {
  String get id;
  String get courtId;
  DateTime get startAt;
  DateTime get endAt;
  String get status;

  /// Owner-supplied reason shown on a blocked slot (OWNER-25). Maps to
  /// `slots.blocked_reason`; null unless [status] is [SlotStatus.blocked].
  String? get blockedReason;

  /// Create a copy of OwnerSlot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $OwnerSlotCopyWith<OwnerSlot> get copyWith =>
      _$OwnerSlotCopyWithImpl<OwnerSlot>(this as OwnerSlot, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is OwnerSlot &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.courtId, courtId) || other.courtId == courtId) &&
            (identical(other.startAt, startAt) || other.startAt == startAt) &&
            (identical(other.endAt, endAt) || other.endAt == endAt) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.blockedReason, blockedReason) ||
                other.blockedReason == blockedReason));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, id, courtId, startAt, endAt, status, blockedReason);

  @override
  String toString() {
    return 'OwnerSlot(id: $id, courtId: $courtId, startAt: $startAt, endAt: $endAt, status: $status, blockedReason: $blockedReason)';
  }
}

/// @nodoc
abstract mixin class $OwnerSlotCopyWith<$Res> {
  factory $OwnerSlotCopyWith(OwnerSlot value, $Res Function(OwnerSlot) _then) =
      _$OwnerSlotCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String courtId,
      DateTime startAt,
      DateTime endAt,
      String status,
      String? blockedReason});
}

/// @nodoc
class _$OwnerSlotCopyWithImpl<$Res> implements $OwnerSlotCopyWith<$Res> {
  _$OwnerSlotCopyWithImpl(this._self, this._then);

  final OwnerSlot _self;
  final $Res Function(OwnerSlot) _then;

  /// Create a copy of OwnerSlot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? courtId = null,
    Object? startAt = null,
    Object? endAt = null,
    Object? status = null,
    Object? blockedReason = freezed,
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
      startAt: null == startAt
          ? _self.startAt
          : startAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endAt: null == endAt
          ? _self.endAt
          : endAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      blockedReason: freezed == blockedReason
          ? _self.blockedReason
          : blockedReason // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [OwnerSlot].
extension OwnerSlotPatterns on OwnerSlot {
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
    TResult Function(_OwnerSlot value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _OwnerSlot() when $default != null:
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
    TResult Function(_OwnerSlot value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OwnerSlot():
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
    TResult? Function(_OwnerSlot value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OwnerSlot() when $default != null:
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
    TResult Function(String id, String courtId, DateTime startAt,
            DateTime endAt, String status, String? blockedReason)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _OwnerSlot() when $default != null:
        return $default(_that.id, _that.courtId, _that.startAt, _that.endAt,
            _that.status, _that.blockedReason);
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
    TResult Function(String id, String courtId, DateTime startAt,
            DateTime endAt, String status, String? blockedReason)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OwnerSlot():
        return $default(_that.id, _that.courtId, _that.startAt, _that.endAt,
            _that.status, _that.blockedReason);
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
    TResult? Function(String id, String courtId, DateTime startAt,
            DateTime endAt, String status, String? blockedReason)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OwnerSlot() when $default != null:
        return $default(_that.id, _that.courtId, _that.startAt, _that.endAt,
            _that.status, _that.blockedReason);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _OwnerSlot extends OwnerSlot {
  const _OwnerSlot(
      {required this.id,
      required this.courtId,
      required this.startAt,
      required this.endAt,
      this.status = SlotStatus.open,
      this.blockedReason})
      : super._();

  @override
  final String id;
  @override
  final String courtId;
  @override
  final DateTime startAt;
  @override
  final DateTime endAt;
  @override
  @JsonKey()
  final String status;

  /// Owner-supplied reason shown on a blocked slot (OWNER-25). Maps to
  /// `slots.blocked_reason`; null unless [status] is [SlotStatus.blocked].
  @override
  final String? blockedReason;

  /// Create a copy of OwnerSlot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$OwnerSlotCopyWith<_OwnerSlot> get copyWith =>
      __$OwnerSlotCopyWithImpl<_OwnerSlot>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _OwnerSlot &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.courtId, courtId) || other.courtId == courtId) &&
            (identical(other.startAt, startAt) || other.startAt == startAt) &&
            (identical(other.endAt, endAt) || other.endAt == endAt) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.blockedReason, blockedReason) ||
                other.blockedReason == blockedReason));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, id, courtId, startAt, endAt, status, blockedReason);

  @override
  String toString() {
    return 'OwnerSlot(id: $id, courtId: $courtId, startAt: $startAt, endAt: $endAt, status: $status, blockedReason: $blockedReason)';
  }
}

/// @nodoc
abstract mixin class _$OwnerSlotCopyWith<$Res>
    implements $OwnerSlotCopyWith<$Res> {
  factory _$OwnerSlotCopyWith(
          _OwnerSlot value, $Res Function(_OwnerSlot) _then) =
      __$OwnerSlotCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String courtId,
      DateTime startAt,
      DateTime endAt,
      String status,
      String? blockedReason});
}

/// @nodoc
class __$OwnerSlotCopyWithImpl<$Res> implements _$OwnerSlotCopyWith<$Res> {
  __$OwnerSlotCopyWithImpl(this._self, this._then);

  final _OwnerSlot _self;
  final $Res Function(_OwnerSlot) _then;

  /// Create a copy of OwnerSlot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? courtId = null,
    Object? startAt = null,
    Object? endAt = null,
    Object? status = null,
    Object? blockedReason = freezed,
  }) {
    return _then(_OwnerSlot(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      courtId: null == courtId
          ? _self.courtId
          : courtId // ignore: cast_nullable_to_non_nullable
              as String,
      startAt: null == startAt
          ? _self.startAt
          : startAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endAt: null == endAt
          ? _self.endAt
          : endAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      blockedReason: freezed == blockedReason
          ? _self.blockedReason
          : blockedReason // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
