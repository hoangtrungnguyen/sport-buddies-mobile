// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'court_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CourtState {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is CourtState);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'CourtState()';
  }
}

/// @nodoc
class $CourtStateCopyWith<$Res> {
  $CourtStateCopyWith(CourtState _, $Res Function(CourtState) __);
}

/// Adds pattern-matching-related methods to [CourtState].
extension CourtStatePatterns on CourtState {
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
    TResult Function(CourtInitial value)? initial,
    TResult Function(CourtLoading value)? loading,
    TResult Function(CourtLoaded value)? loaded,
    TResult Function(CourtFailure value)? failure,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case CourtInitial() when initial != null:
        return initial(_that);
      case CourtLoading() when loading != null:
        return loading(_that);
      case CourtLoaded() when loaded != null:
        return loaded(_that);
      case CourtFailure() when failure != null:
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
    required TResult Function(CourtInitial value) initial,
    required TResult Function(CourtLoading value) loading,
    required TResult Function(CourtLoaded value) loaded,
    required TResult Function(CourtFailure value) failure,
  }) {
    final _that = this;
    switch (_that) {
      case CourtInitial():
        return initial(_that);
      case CourtLoading():
        return loading(_that);
      case CourtLoaded():
        return loaded(_that);
      case CourtFailure():
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
    TResult? Function(CourtInitial value)? initial,
    TResult? Function(CourtLoading value)? loading,
    TResult? Function(CourtLoaded value)? loaded,
    TResult? Function(CourtFailure value)? failure,
  }) {
    final _that = this;
    switch (_that) {
      case CourtInitial() when initial != null:
        return initial(_that);
      case CourtLoading() when loading != null:
        return loading(_that);
      case CourtLoaded() when loaded != null:
        return loaded(_that);
      case CourtFailure() when failure != null:
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
    TResult Function(List<OwnerCourt> courts)? loaded,
    TResult Function(String message, StackTrace? stackTrace)? failure,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case CourtInitial() when initial != null:
        return initial();
      case CourtLoading() when loading != null:
        return loading();
      case CourtLoaded() when loaded != null:
        return loaded(_that.courts);
      case CourtFailure() when failure != null:
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
    required TResult Function(List<OwnerCourt> courts) loaded,
    required TResult Function(String message, StackTrace? stackTrace) failure,
  }) {
    final _that = this;
    switch (_that) {
      case CourtInitial():
        return initial();
      case CourtLoading():
        return loading();
      case CourtLoaded():
        return loaded(_that.courts);
      case CourtFailure():
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
    TResult? Function(List<OwnerCourt> courts)? loaded,
    TResult? Function(String message, StackTrace? stackTrace)? failure,
  }) {
    final _that = this;
    switch (_that) {
      case CourtInitial() when initial != null:
        return initial();
      case CourtLoading() when loading != null:
        return loading();
      case CourtLoaded() when loaded != null:
        return loaded(_that.courts);
      case CourtFailure() when failure != null:
        return failure(_that.message, _that.stackTrace);
      case _:
        return null;
    }
  }
}

/// @nodoc

class CourtInitial implements CourtState {
  const CourtInitial();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is CourtInitial);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'CourtState.initial()';
  }
}

/// @nodoc

class CourtLoading implements CourtState {
  const CourtLoading();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is CourtLoading);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'CourtState.loading()';
  }
}

/// @nodoc

class CourtLoaded implements CourtState {
  const CourtLoaded(final List<OwnerCourt> courts) : _courts = courts;

  final List<OwnerCourt> _courts;
  List<OwnerCourt> get courts {
    if (_courts is EqualUnmodifiableListView) return _courts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_courts);
  }

  /// Create a copy of CourtState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CourtLoadedCopyWith<CourtLoaded> get copyWith =>
      _$CourtLoadedCopyWithImpl<CourtLoaded>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CourtLoaded &&
            const DeepCollectionEquality().equals(other._courts, _courts));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_courts));

  @override
  String toString() {
    return 'CourtState.loaded(courts: $courts)';
  }
}

/// @nodoc
abstract mixin class $CourtLoadedCopyWith<$Res>
    implements $CourtStateCopyWith<$Res> {
  factory $CourtLoadedCopyWith(
          CourtLoaded value, $Res Function(CourtLoaded) _then) =
      _$CourtLoadedCopyWithImpl;
  @useResult
  $Res call({List<OwnerCourt> courts});
}

/// @nodoc
class _$CourtLoadedCopyWithImpl<$Res> implements $CourtLoadedCopyWith<$Res> {
  _$CourtLoadedCopyWithImpl(this._self, this._then);

  final CourtLoaded _self;
  final $Res Function(CourtLoaded) _then;

  /// Create a copy of CourtState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? courts = null,
  }) {
    return _then(CourtLoaded(
      null == courts
          ? _self._courts
          : courts // ignore: cast_nullable_to_non_nullable
              as List<OwnerCourt>,
    ));
  }
}

/// @nodoc

class CourtFailure with AppExceptionMixin implements CourtState {
  const CourtFailure(this.message, {this.stackTrace});

  final String message;
  final StackTrace? stackTrace;

  /// Create a copy of CourtState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CourtFailureCopyWith<CourtFailure> get copyWith =>
      _$CourtFailureCopyWithImpl<CourtFailure>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CourtFailure &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.stackTrace, stackTrace) ||
                other.stackTrace == stackTrace));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, stackTrace);

  @override
  String toString() {
    return 'CourtState.failure(message: $message, stackTrace: $stackTrace)';
  }
}

/// @nodoc
abstract mixin class $CourtFailureCopyWith<$Res>
    implements $CourtStateCopyWith<$Res> {
  factory $CourtFailureCopyWith(
          CourtFailure value, $Res Function(CourtFailure) _then) =
      _$CourtFailureCopyWithImpl;
  @useResult
  $Res call({String message, StackTrace? stackTrace});
}

/// @nodoc
class _$CourtFailureCopyWithImpl<$Res> implements $CourtFailureCopyWith<$Res> {
  _$CourtFailureCopyWithImpl(this._self, this._then);

  final CourtFailure _self;
  final $Res Function(CourtFailure) _then;

  /// Create a copy of CourtState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = null,
    Object? stackTrace = freezed,
  }) {
    return _then(CourtFailure(
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
