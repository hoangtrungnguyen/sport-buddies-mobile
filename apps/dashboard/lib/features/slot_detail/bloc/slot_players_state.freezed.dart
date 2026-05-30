// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'slot_players_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SlotPlayersState {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is SlotPlayersState);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'SlotPlayersState()';
  }
}

/// @nodoc
class $SlotPlayersStateCopyWith<$Res> {
  $SlotPlayersStateCopyWith(
      SlotPlayersState _, $Res Function(SlotPlayersState) __);
}

/// Adds pattern-matching-related methods to [SlotPlayersState].
extension SlotPlayersStatePatterns on SlotPlayersState {
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
    TResult Function(SlotPlayersInitial value)? initial,
    TResult Function(SlotPlayersLoading value)? loading,
    TResult Function(SlotPlayersLoaded value)? loaded,
    TResult Function(SlotPlayersFailure value)? failure,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case SlotPlayersInitial() when initial != null:
        return initial(_that);
      case SlotPlayersLoading() when loading != null:
        return loading(_that);
      case SlotPlayersLoaded() when loaded != null:
        return loaded(_that);
      case SlotPlayersFailure() when failure != null:
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
    required TResult Function(SlotPlayersInitial value) initial,
    required TResult Function(SlotPlayersLoading value) loading,
    required TResult Function(SlotPlayersLoaded value) loaded,
    required TResult Function(SlotPlayersFailure value) failure,
  }) {
    final _that = this;
    switch (_that) {
      case SlotPlayersInitial():
        return initial(_that);
      case SlotPlayersLoading():
        return loading(_that);
      case SlotPlayersLoaded():
        return loaded(_that);
      case SlotPlayersFailure():
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
    TResult? Function(SlotPlayersInitial value)? initial,
    TResult? Function(SlotPlayersLoading value)? loading,
    TResult? Function(SlotPlayersLoaded value)? loaded,
    TResult? Function(SlotPlayersFailure value)? failure,
  }) {
    final _that = this;
    switch (_that) {
      case SlotPlayersInitial() when initial != null:
        return initial(_that);
      case SlotPlayersLoading() when loading != null:
        return loading(_that);
      case SlotPlayersLoaded() when loaded != null:
        return loaded(_that);
      case SlotPlayersFailure() when failure != null:
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
    TResult Function(List<SlotPlayer> players)? loaded,
    TResult Function(String message, StackTrace? stackTrace)? failure,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case SlotPlayersInitial() when initial != null:
        return initial();
      case SlotPlayersLoading() when loading != null:
        return loading();
      case SlotPlayersLoaded() when loaded != null:
        return loaded(_that.players);
      case SlotPlayersFailure() when failure != null:
        return failure(_that.message, _that.stackTrace);
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
    required TResult Function(List<SlotPlayer> players) loaded,
    required TResult Function(String message, StackTrace? stackTrace) failure,
  }) {
    final _that = this;
    switch (_that) {
      case SlotPlayersInitial():
        return initial();
      case SlotPlayersLoading():
        return loading();
      case SlotPlayersLoaded():
        return loaded(_that.players);
      case SlotPlayersFailure():
        return failure(_that.message, _that.stackTrace);
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
    TResult? Function(List<SlotPlayer> players)? loaded,
    TResult? Function(String message, StackTrace? stackTrace)? failure,
  }) {
    final _that = this;
    switch (_that) {
      case SlotPlayersInitial() when initial != null:
        return initial();
      case SlotPlayersLoading() when loading != null:
        return loading();
      case SlotPlayersLoaded() when loaded != null:
        return loaded(_that.players);
      case SlotPlayersFailure() when failure != null:
        return failure(_that.message, _that.stackTrace);
      case _:
        return null;
    }
  }
}

/// @nodoc

class SlotPlayersInitial implements SlotPlayersState {
  const SlotPlayersInitial();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is SlotPlayersInitial);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'SlotPlayersState.initial()';
  }
}

/// @nodoc

class SlotPlayersLoading implements SlotPlayersState {
  const SlotPlayersLoading();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is SlotPlayersLoading);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'SlotPlayersState.loading()';
  }
}

/// @nodoc

class SlotPlayersLoaded implements SlotPlayersState {
  const SlotPlayersLoaded(final List<SlotPlayer> players) : _players = players;

  final List<SlotPlayer> _players;
  List<SlotPlayer> get players {
    if (_players is EqualUnmodifiableListView) return _players;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_players);
  }

  /// Create a copy of SlotPlayersState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SlotPlayersLoadedCopyWith<SlotPlayersLoaded> get copyWith =>
      _$SlotPlayersLoadedCopyWithImpl<SlotPlayersLoaded>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SlotPlayersLoaded &&
            const DeepCollectionEquality().equals(other._players, _players));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_players));

  @override
  String toString() {
    return 'SlotPlayersState.loaded(players: $players)';
  }
}

/// @nodoc
abstract mixin class $SlotPlayersLoadedCopyWith<$Res>
    implements $SlotPlayersStateCopyWith<$Res> {
  factory $SlotPlayersLoadedCopyWith(
          SlotPlayersLoaded value, $Res Function(SlotPlayersLoaded) _then) =
      _$SlotPlayersLoadedCopyWithImpl;
  @useResult
  $Res call({List<SlotPlayer> players});
}

/// @nodoc
class _$SlotPlayersLoadedCopyWithImpl<$Res>
    implements $SlotPlayersLoadedCopyWith<$Res> {
  _$SlotPlayersLoadedCopyWithImpl(this._self, this._then);

  final SlotPlayersLoaded _self;
  final $Res Function(SlotPlayersLoaded) _then;

  /// Create a copy of SlotPlayersState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? players = null,
  }) {
    return _then(SlotPlayersLoaded(
      null == players
          ? _self._players
          : players // ignore: cast_nullable_to_non_nullable
              as List<SlotPlayer>,
    ));
  }
}

/// @nodoc

class SlotPlayersFailure with AppExceptionMixin implements SlotPlayersState {
  const SlotPlayersFailure(this.message, {this.stackTrace});

  final String message;
  final StackTrace? stackTrace;

  /// Create a copy of SlotPlayersState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SlotPlayersFailureCopyWith<SlotPlayersFailure> get copyWith =>
      _$SlotPlayersFailureCopyWithImpl<SlotPlayersFailure>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SlotPlayersFailure &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.stackTrace, stackTrace) ||
                other.stackTrace == stackTrace));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, stackTrace);

  @override
  String toString() {
    return 'SlotPlayersState.failure(message: $message, stackTrace: $stackTrace)';
  }
}

/// @nodoc
abstract mixin class $SlotPlayersFailureCopyWith<$Res>
    implements $SlotPlayersStateCopyWith<$Res> {
  factory $SlotPlayersFailureCopyWith(
          SlotPlayersFailure value, $Res Function(SlotPlayersFailure) _then) =
      _$SlotPlayersFailureCopyWithImpl;
  @useResult
  $Res call({String message, StackTrace? stackTrace});
}

/// @nodoc
class _$SlotPlayersFailureCopyWithImpl<$Res>
    implements $SlotPlayersFailureCopyWith<$Res> {
  _$SlotPlayersFailureCopyWithImpl(this._self, this._then);

  final SlotPlayersFailure _self;
  final $Res Function(SlotPlayersFailure) _then;

  /// Create a copy of SlotPlayersState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = null,
    Object? stackTrace = freezed,
  }) {
    return _then(SlotPlayersFailure(
      null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      stackTrace: freezed == stackTrace
          ? _self.stackTrace
          : stackTrace // ignore: cast_nullable_to_non_nullable
              as StackTrace?,
    ));
  }
}

// dart format on
