// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'slot_player.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SlotPlayer {
  /// Stable list key (participant id, else booking id, else user id).
  String get id;

  /// Display name (`Khách / Người chơi` fallback when unknown).
  String get name;

  /// The player's user id, when known.
  String? get userId;

  /// Profile avatar URL — null under current owner RLS (BCORE bug).
  String? get avatarUrl;

  /// Booking status badge source; null when the player has no booking row.
  BookingStatus? get bookingStatus;
  PaymentStatus get paymentStatus;

  /// Create a copy of SlotPlayer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SlotPlayerCopyWith<SlotPlayer> get copyWith =>
      _$SlotPlayerCopyWithImpl<SlotPlayer>(this as SlotPlayer, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SlotPlayer &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.bookingStatus, bookingStatus) ||
                other.bookingStatus == bookingStatus) &&
            (identical(other.paymentStatus, paymentStatus) ||
                other.paymentStatus == paymentStatus));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, id, name, userId, avatarUrl, bookingStatus, paymentStatus);

  @override
  String toString() {
    return 'SlotPlayer(id: $id, name: $name, userId: $userId, avatarUrl: $avatarUrl, bookingStatus: $bookingStatus, paymentStatus: $paymentStatus)';
  }
}

/// @nodoc
abstract mixin class $SlotPlayerCopyWith<$Res> {
  factory $SlotPlayerCopyWith(
          SlotPlayer value, $Res Function(SlotPlayer) _then) =
      _$SlotPlayerCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String name,
      String? userId,
      String? avatarUrl,
      BookingStatus? bookingStatus,
      PaymentStatus paymentStatus});
}

/// @nodoc
class _$SlotPlayerCopyWithImpl<$Res> implements $SlotPlayerCopyWith<$Res> {
  _$SlotPlayerCopyWithImpl(this._self, this._then);

  final SlotPlayer _self;
  final $Res Function(SlotPlayer) _then;

  /// Create a copy of SlotPlayer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? userId = freezed,
    Object? avatarUrl = freezed,
    Object? bookingStatus = freezed,
    Object? paymentStatus = null,
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
      userId: freezed == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      avatarUrl: freezed == avatarUrl
          ? _self.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      bookingStatus: freezed == bookingStatus
          ? _self.bookingStatus
          : bookingStatus // ignore: cast_nullable_to_non_nullable
              as BookingStatus?,
      paymentStatus: null == paymentStatus
          ? _self.paymentStatus
          : paymentStatus // ignore: cast_nullable_to_non_nullable
              as PaymentStatus,
    ));
  }
}

/// Adds pattern-matching-related methods to [SlotPlayer].
extension SlotPlayerPatterns on SlotPlayer {
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
    TResult Function(_SlotPlayer value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SlotPlayer() when $default != null:
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
    TResult Function(_SlotPlayer value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SlotPlayer():
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
    TResult? Function(_SlotPlayer value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SlotPlayer() when $default != null:
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
    TResult Function(String id, String name, String? userId, String? avatarUrl,
            BookingStatus? bookingStatus, PaymentStatus paymentStatus)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SlotPlayer() when $default != null:
        return $default(_that.id, _that.name, _that.userId, _that.avatarUrl,
            _that.bookingStatus, _that.paymentStatus);
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
    TResult Function(String id, String name, String? userId, String? avatarUrl,
            BookingStatus? bookingStatus, PaymentStatus paymentStatus)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SlotPlayer():
        return $default(_that.id, _that.name, _that.userId, _that.avatarUrl,
            _that.bookingStatus, _that.paymentStatus);
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
    TResult? Function(String id, String name, String? userId, String? avatarUrl,
            BookingStatus? bookingStatus, PaymentStatus paymentStatus)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SlotPlayer() when $default != null:
        return $default(_that.id, _that.name, _that.userId, _that.avatarUrl,
            _that.bookingStatus, _that.paymentStatus);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _SlotPlayer extends SlotPlayer {
  const _SlotPlayer(
      {required this.id,
      required this.name,
      this.userId,
      this.avatarUrl,
      this.bookingStatus,
      this.paymentStatus = PaymentStatus.unknown})
      : super._();

  /// Stable list key (participant id, else booking id, else user id).
  @override
  final String id;

  /// Display name (`Khách / Người chơi` fallback when unknown).
  @override
  final String name;

  /// The player's user id, when known.
  @override
  final String? userId;

  /// Profile avatar URL — null under current owner RLS (BCORE bug).
  @override
  final String? avatarUrl;

  /// Booking status badge source; null when the player has no booking row.
  @override
  final BookingStatus? bookingStatus;
  @override
  @JsonKey()
  final PaymentStatus paymentStatus;

  /// Create a copy of SlotPlayer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SlotPlayerCopyWith<_SlotPlayer> get copyWith =>
      __$SlotPlayerCopyWithImpl<_SlotPlayer>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SlotPlayer &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.bookingStatus, bookingStatus) ||
                other.bookingStatus == bookingStatus) &&
            (identical(other.paymentStatus, paymentStatus) ||
                other.paymentStatus == paymentStatus));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, id, name, userId, avatarUrl, bookingStatus, paymentStatus);

  @override
  String toString() {
    return 'SlotPlayer(id: $id, name: $name, userId: $userId, avatarUrl: $avatarUrl, bookingStatus: $bookingStatus, paymentStatus: $paymentStatus)';
  }
}

/// @nodoc
abstract mixin class _$SlotPlayerCopyWith<$Res>
    implements $SlotPlayerCopyWith<$Res> {
  factory _$SlotPlayerCopyWith(
          _SlotPlayer value, $Res Function(_SlotPlayer) _then) =
      __$SlotPlayerCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String? userId,
      String? avatarUrl,
      BookingStatus? bookingStatus,
      PaymentStatus paymentStatus});
}

/// @nodoc
class __$SlotPlayerCopyWithImpl<$Res> implements _$SlotPlayerCopyWith<$Res> {
  __$SlotPlayerCopyWithImpl(this._self, this._then);

  final _SlotPlayer _self;
  final $Res Function(_SlotPlayer) _then;

  /// Create a copy of SlotPlayer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? userId = freezed,
    Object? avatarUrl = freezed,
    Object? bookingStatus = freezed,
    Object? paymentStatus = null,
  }) {
    return _then(_SlotPlayer(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      userId: freezed == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      avatarUrl: freezed == avatarUrl
          ? _self.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      bookingStatus: freezed == bookingStatus
          ? _self.bookingStatus
          : bookingStatus // ignore: cast_nullable_to_non_nullable
              as BookingStatus?,
      paymentStatus: null == paymentStatus
          ? _self.paymentStatus
          : paymentStatus // ignore: cast_nullable_to_non_nullable
              as PaymentStatus,
    ));
  }
}

// dart format on
