// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'requests_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RequestsState {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is RequestsState);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'RequestsState()';
  }
}

/// @nodoc
class $RequestsStateCopyWith<$Res> {
  $RequestsStateCopyWith(RequestsState _, $Res Function(RequestsState) __);
}

/// Adds pattern-matching-related methods to [RequestsState].
extension RequestsStatePatterns on RequestsState {
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
    TResult Function(RequestsInitial value)? initial,
    TResult Function(RequestsLoading value)? loading,
    TResult Function(RequestsLoaded value)? loaded,
    TResult Function(RequestsFailure value)? failure,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case RequestsInitial() when initial != null:
        return initial(_that);
      case RequestsLoading() when loading != null:
        return loading(_that);
      case RequestsLoaded() when loaded != null:
        return loaded(_that);
      case RequestsFailure() when failure != null:
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
    required TResult Function(RequestsInitial value) initial,
    required TResult Function(RequestsLoading value) loading,
    required TResult Function(RequestsLoaded value) loaded,
    required TResult Function(RequestsFailure value) failure,
  }) {
    final _that = this;
    switch (_that) {
      case RequestsInitial():
        return initial(_that);
      case RequestsLoading():
        return loading(_that);
      case RequestsLoaded():
        return loaded(_that);
      case RequestsFailure():
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
    TResult? Function(RequestsInitial value)? initial,
    TResult? Function(RequestsLoading value)? loading,
    TResult? Function(RequestsLoaded value)? loaded,
    TResult? Function(RequestsFailure value)? failure,
  }) {
    final _that = this;
    switch (_that) {
      case RequestsInitial() when initial != null:
        return initial(_that);
      case RequestsLoading() when loading != null:
        return loading(_that);
      case RequestsLoaded() when loaded != null:
        return loaded(_that);
      case RequestsFailure() when failure != null:
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
    TResult Function(
            DateTime day, List<BookingRequest> requests, int page, bool busy)?
        loaded,
    TResult Function(String message, DateTime? day, StackTrace? stackTrace)?
        failure,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case RequestsInitial() when initial != null:
        return initial();
      case RequestsLoading() when loading != null:
        return loading();
      case RequestsLoaded() when loaded != null:
        return loaded(_that.day, _that.requests, _that.page, _that.busy);
      case RequestsFailure() when failure != null:
        return failure(_that.message, _that.day, _that.stackTrace);
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
    required TResult Function(
            DateTime day, List<BookingRequest> requests, int page, bool busy)
        loaded,
    required TResult Function(
            String message, DateTime? day, StackTrace? stackTrace)
        failure,
  }) {
    final _that = this;
    switch (_that) {
      case RequestsInitial():
        return initial();
      case RequestsLoading():
        return loading();
      case RequestsLoaded():
        return loaded(_that.day, _that.requests, _that.page, _that.busy);
      case RequestsFailure():
        return failure(_that.message, _that.day, _that.stackTrace);
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
    TResult? Function(
            DateTime day, List<BookingRequest> requests, int page, bool busy)?
        loaded,
    TResult? Function(String message, DateTime? day, StackTrace? stackTrace)?
        failure,
  }) {
    final _that = this;
    switch (_that) {
      case RequestsInitial() when initial != null:
        return initial();
      case RequestsLoading() when loading != null:
        return loading();
      case RequestsLoaded() when loaded != null:
        return loaded(_that.day, _that.requests, _that.page, _that.busy);
      case RequestsFailure() when failure != null:
        return failure(_that.message, _that.day, _that.stackTrace);
      case _:
        return null;
    }
  }
}

/// @nodoc

class RequestsInitial implements RequestsState {
  const RequestsInitial();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is RequestsInitial);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'RequestsState.initial()';
  }
}

/// @nodoc

class RequestsLoading implements RequestsState {
  const RequestsLoading();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is RequestsLoading);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'RequestsState.loading()';
  }
}

/// @nodoc

class RequestsLoaded implements RequestsState {
  const RequestsLoaded(
      {required this.day,
      required final List<BookingRequest> requests,
      this.page = 0,
      this.busy = false})
      : _requests = requests;

  final DateTime day;
  final List<BookingRequest> _requests;
  List<BookingRequest> get requests {
    if (_requests is EqualUnmodifiableListView) return _requests;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_requests);
  }

  @JsonKey()
  final int page;
  @JsonKey()
  final bool busy;

  /// Create a copy of RequestsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $RequestsLoadedCopyWith<RequestsLoaded> get copyWith =>
      _$RequestsLoadedCopyWithImpl<RequestsLoaded>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is RequestsLoaded &&
            (identical(other.day, day) || other.day == day) &&
            const DeepCollectionEquality().equals(other._requests, _requests) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.busy, busy) || other.busy == busy));
  }

  @override
  int get hashCode => Object.hash(runtimeType, day,
      const DeepCollectionEquality().hash(_requests), page, busy);

  @override
  String toString() {
    return 'RequestsState.loaded(day: $day, requests: $requests, page: $page, busy: $busy)';
  }
}

/// @nodoc
abstract mixin class $RequestsLoadedCopyWith<$Res>
    implements $RequestsStateCopyWith<$Res> {
  factory $RequestsLoadedCopyWith(
          RequestsLoaded value, $Res Function(RequestsLoaded) _then) =
      _$RequestsLoadedCopyWithImpl;
  @useResult
  $Res call({DateTime day, List<BookingRequest> requests, int page, bool busy});
}

/// @nodoc
class _$RequestsLoadedCopyWithImpl<$Res>
    implements $RequestsLoadedCopyWith<$Res> {
  _$RequestsLoadedCopyWithImpl(this._self, this._then);

  final RequestsLoaded _self;
  final $Res Function(RequestsLoaded) _then;

  /// Create a copy of RequestsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? day = null,
    Object? requests = null,
    Object? page = null,
    Object? busy = null,
  }) {
    return _then(RequestsLoaded(
      day: null == day
          ? _self.day
          : day // ignore: cast_nullable_to_non_nullable
              as DateTime,
      requests: null == requests
          ? _self._requests
          : requests // ignore: cast_nullable_to_non_nullable
              as List<BookingRequest>,
      page: null == page
          ? _self.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      busy: null == busy
          ? _self.busy
          : busy // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class RequestsFailure with AppExceptionMixin implements RequestsState {
  const RequestsFailure(this.message, {this.day, this.stackTrace});

  final String message;
  final DateTime? day;
  final StackTrace? stackTrace;

  /// Create a copy of RequestsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $RequestsFailureCopyWith<RequestsFailure> get copyWith =>
      _$RequestsFailureCopyWithImpl<RequestsFailure>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is RequestsFailure &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.day, day) || other.day == day) &&
            (identical(other.stackTrace, stackTrace) ||
                other.stackTrace == stackTrace));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, day, stackTrace);

  @override
  String toString() {
    return 'RequestsState.failure(message: $message, day: $day, stackTrace: $stackTrace)';
  }
}

/// @nodoc
abstract mixin class $RequestsFailureCopyWith<$Res>
    implements $RequestsStateCopyWith<$Res> {
  factory $RequestsFailureCopyWith(
          RequestsFailure value, $Res Function(RequestsFailure) _then) =
      _$RequestsFailureCopyWithImpl;
  @useResult
  $Res call({String message, DateTime? day, StackTrace? stackTrace});
}

/// @nodoc
class _$RequestsFailureCopyWithImpl<$Res>
    implements $RequestsFailureCopyWith<$Res> {
  _$RequestsFailureCopyWithImpl(this._self, this._then);

  final RequestsFailure _self;
  final $Res Function(RequestsFailure) _then;

  /// Create a copy of RequestsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = null,
    Object? day = freezed,
    Object? stackTrace = freezed,
  }) {
    return _then(RequestsFailure(
      null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      day: freezed == day
          ? _self.day
          : day // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      stackTrace: freezed == stackTrace
          ? _self.stackTrace
          : stackTrace // ignore: cast_nullable_to_non_nullable
              as StackTrace?,
    ));
  }
}

// dart format on
