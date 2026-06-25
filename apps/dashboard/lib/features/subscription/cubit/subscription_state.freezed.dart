// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subscription_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SubscriptionState {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is SubscriptionState);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'SubscriptionState()';
  }
}

/// @nodoc
class $SubscriptionStateCopyWith<$Res> {
  $SubscriptionStateCopyWith(
      SubscriptionState _, $Res Function(SubscriptionState) __);
}

/// Adds pattern-matching-related methods to [SubscriptionState].
extension SubscriptionStatePatterns on SubscriptionState {
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
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SubscriptionInitial value)? initial,
    TResult Function(SubscriptionLoading value)? loading,
    TResult Function(SubscriptionLoaded value)? loaded,
    TResult Function(SubscriptionFailure value)? failure,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case SubscriptionInitial() when initial != null:
        return initial(_that);
      case SubscriptionLoading() when loading != null:
        return loading(_that);
      case SubscriptionLoaded() when loaded != null:
        return loaded(_that);
      case SubscriptionFailure() when failure != null:
        return failure(_that);
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
  TResult map<TResult extends Object?>({
    required TResult Function(SubscriptionInitial value) initial,
    required TResult Function(SubscriptionLoading value) loading,
    required TResult Function(SubscriptionLoaded value) loaded,
    required TResult Function(SubscriptionFailure value) failure,
  }) {
    final _that = this;
    switch (_that) {
      case SubscriptionInitial():
        return initial(_that);
      case SubscriptionLoading():
        return loading(_that);
      case SubscriptionLoaded():
        return loaded(_that);
      case SubscriptionFailure():
        return failure(_that);
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
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SubscriptionInitial value)? initial,
    TResult? Function(SubscriptionLoading value)? loading,
    TResult? Function(SubscriptionLoaded value)? loaded,
    TResult? Function(SubscriptionFailure value)? failure,
  }) {
    final _that = this;
    switch (_that) {
      case SubscriptionInitial() when initial != null:
        return initial(_that);
      case SubscriptionLoading() when loading != null:
        return loading(_that);
      case SubscriptionLoaded() when loaded != null:
        return loaded(_that);
      case SubscriptionFailure() when failure != null:
        return failure(_that);
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
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(Subscription subscription)? loaded,
    TResult Function(String message)? failure,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case SubscriptionInitial() when initial != null:
        return initial();
      case SubscriptionLoading() when loading != null:
        return loading();
      case SubscriptionLoaded() when loaded != null:
        return loaded(_that.subscription);
      case SubscriptionFailure() when failure != null:
        return failure(_that.message);
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
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(Subscription subscription) loaded,
    required TResult Function(String message) failure,
  }) {
    final _that = this;
    switch (_that) {
      case SubscriptionInitial():
        return initial();
      case SubscriptionLoading():
        return loading();
      case SubscriptionLoaded():
        return loaded(_that.subscription);
      case SubscriptionFailure():
        return failure(_that.message);
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
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(Subscription subscription)? loaded,
    TResult? Function(String message)? failure,
  }) {
    final _that = this;
    switch (_that) {
      case SubscriptionInitial() when initial != null:
        return initial();
      case SubscriptionLoading() when loading != null:
        return loading();
      case SubscriptionLoaded() when loaded != null:
        return loaded(_that.subscription);
      case SubscriptionFailure() when failure != null:
        return failure(_that.message);
      case _:
        return null;
    }
  }
}

/// @nodoc

class SubscriptionInitial implements SubscriptionState {
  const SubscriptionInitial();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is SubscriptionInitial);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'SubscriptionState.initial()';
  }
}

/// @nodoc

class SubscriptionLoading implements SubscriptionState {
  const SubscriptionLoading();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is SubscriptionLoading);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'SubscriptionState.loading()';
  }
}

/// @nodoc

class SubscriptionLoaded implements SubscriptionState {
  const SubscriptionLoaded(this.subscription);

  final Subscription subscription;

  /// Create a copy of SubscriptionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SubscriptionLoadedCopyWith<SubscriptionLoaded> get copyWith =>
      _$SubscriptionLoadedCopyWithImpl<SubscriptionLoaded>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SubscriptionLoaded &&
            (identical(other.subscription, subscription) ||
                other.subscription == subscription));
  }

  @override
  int get hashCode => Object.hash(runtimeType, subscription);

  @override
  String toString() {
    return 'SubscriptionState.loaded(subscription: $subscription)';
  }
}

/// @nodoc
abstract mixin class $SubscriptionLoadedCopyWith<$Res>
    implements $SubscriptionStateCopyWith<$Res> {
  factory $SubscriptionLoadedCopyWith(
          SubscriptionLoaded value, $Res Function(SubscriptionLoaded) _then) =
      _$SubscriptionLoadedCopyWithImpl;
  @useResult
  $Res call({Subscription subscription});

  $SubscriptionCopyWith<$Res> get subscription;
}

/// @nodoc
class _$SubscriptionLoadedCopyWithImpl<$Res>
    implements $SubscriptionLoadedCopyWith<$Res> {
  _$SubscriptionLoadedCopyWithImpl(this._self, this._then);

  final SubscriptionLoaded _self;
  final $Res Function(SubscriptionLoaded) _then;

  /// Create a copy of SubscriptionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? subscription = null,
  }) {
    return _then(SubscriptionLoaded(
      null == subscription
          ? _self.subscription
          : subscription // ignore: cast_nullable_to_non_nullable
              as Subscription,
    ));
  }

  /// Create a copy of SubscriptionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SubscriptionCopyWith<$Res> get subscription {
    return $SubscriptionCopyWith<$Res>(_self.subscription, (value) {
      return _then(_self.copyWith(subscription: value));
    });
  }
}

/// @nodoc

class SubscriptionFailure implements SubscriptionState {
  const SubscriptionFailure(this.message);

  final String message;

  /// Create a copy of SubscriptionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SubscriptionFailureCopyWith<SubscriptionFailure> get copyWith =>
      _$SubscriptionFailureCopyWithImpl<SubscriptionFailure>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SubscriptionFailure &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @override
  String toString() {
    return 'SubscriptionState.failure(message: $message)';
  }
}

/// @nodoc
abstract mixin class $SubscriptionFailureCopyWith<$Res>
    implements $SubscriptionStateCopyWith<$Res> {
  factory $SubscriptionFailureCopyWith(
          SubscriptionFailure value, $Res Function(SubscriptionFailure) _then) =
      _$SubscriptionFailureCopyWithImpl;
  @useResult
  $Res call({String message});
}

/// @nodoc
class _$SubscriptionFailureCopyWithImpl<$Res>
    implements $SubscriptionFailureCopyWith<$Res> {
  _$SubscriptionFailureCopyWithImpl(this._self, this._then);

  final SubscriptionFailure _self;
  final $Res Function(SubscriptionFailure) _then;

  /// Create a copy of SubscriptionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = null,
  }) {
    return _then(SubscriptionFailure(
      null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
