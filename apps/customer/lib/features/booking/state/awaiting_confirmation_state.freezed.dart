// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'awaiting_confirmation_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AwaitingState {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is AwaitingState);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'AwaitingState()';
  }
}

/// @nodoc
class $AwaitingStateCopyWith<$Res> {
  $AwaitingStateCopyWith(AwaitingState _, $Res Function(AwaitingState) __);
}

/// Adds pattern-matching-related methods to [AwaitingState].
extension AwaitingStatePatterns on AwaitingState {
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
    TResult Function(AwaitingInitial value)? initial,
    TResult Function(AwaitingLoading value)? loading,
    TResult Function(AwaitingLoaded value)? loaded,
    TResult Function(AwaitingConfirmed value)? confirmed,
    TResult Function(AwaitingError value)? error,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case AwaitingInitial() when initial != null:
        return initial(_that);
      case AwaitingLoading() when loading != null:
        return loading(_that);
      case AwaitingLoaded() when loaded != null:
        return loaded(_that);
      case AwaitingConfirmed() when confirmed != null:
        return confirmed(_that);
      case AwaitingError() when error != null:
        return error(_that);
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
    required TResult Function(AwaitingInitial value) initial,
    required TResult Function(AwaitingLoading value) loading,
    required TResult Function(AwaitingLoaded value) loaded,
    required TResult Function(AwaitingConfirmed value) confirmed,
    required TResult Function(AwaitingError value) error,
  }) {
    final _that = this;
    switch (_that) {
      case AwaitingInitial():
        return initial(_that);
      case AwaitingLoading():
        return loading(_that);
      case AwaitingLoaded():
        return loaded(_that);
      case AwaitingConfirmed():
        return confirmed(_that);
      case AwaitingError():
        return error(_that);
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
    TResult? Function(AwaitingInitial value)? initial,
    TResult? Function(AwaitingLoading value)? loading,
    TResult? Function(AwaitingLoaded value)? loaded,
    TResult? Function(AwaitingConfirmed value)? confirmed,
    TResult? Function(AwaitingError value)? error,
  }) {
    final _that = this;
    switch (_that) {
      case AwaitingInitial() when initial != null:
        return initial(_that);
      case AwaitingLoading() when loading != null:
        return loading(_that);
      case AwaitingLoaded() when loaded != null:
        return loaded(_that);
      case AwaitingConfirmed() when confirmed != null:
        return confirmed(_that);
      case AwaitingError() when error != null:
        return error(_that);
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
    TResult Function(String bookingId, String slotId, String courtName,
            DateTime slotStart, DateTime slotEnd, String status)?
        loaded,
    TResult Function(String bookingId, String slotId)? confirmed,
    TResult Function(String message, StackTrace? stackTrace)? error,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case AwaitingInitial() when initial != null:
        return initial();
      case AwaitingLoading() when loading != null:
        return loading();
      case AwaitingLoaded() when loaded != null:
        return loaded(_that.bookingId, _that.slotId, _that.courtName,
            _that.slotStart, _that.slotEnd, _that.status);
      case AwaitingConfirmed() when confirmed != null:
        return confirmed(_that.bookingId, _that.slotId);
      case AwaitingError() when error != null:
        return error(_that.message, _that.stackTrace);
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
    required TResult Function(String bookingId, String slotId, String courtName,
            DateTime slotStart, DateTime slotEnd, String status)
        loaded,
    required TResult Function(String bookingId, String slotId) confirmed,
    required TResult Function(String message, StackTrace? stackTrace) error,
  }) {
    final _that = this;
    switch (_that) {
      case AwaitingInitial():
        return initial();
      case AwaitingLoading():
        return loading();
      case AwaitingLoaded():
        return loaded(_that.bookingId, _that.slotId, _that.courtName,
            _that.slotStart, _that.slotEnd, _that.status);
      case AwaitingConfirmed():
        return confirmed(_that.bookingId, _that.slotId);
      case AwaitingError():
        return error(_that.message, _that.stackTrace);
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
    TResult? Function(String bookingId, String slotId, String courtName,
            DateTime slotStart, DateTime slotEnd, String status)?
        loaded,
    TResult? Function(String bookingId, String slotId)? confirmed,
    TResult? Function(String message, StackTrace? stackTrace)? error,
  }) {
    final _that = this;
    switch (_that) {
      case AwaitingInitial() when initial != null:
        return initial();
      case AwaitingLoading() when loading != null:
        return loading();
      case AwaitingLoaded() when loaded != null:
        return loaded(_that.bookingId, _that.slotId, _that.courtName,
            _that.slotStart, _that.slotEnd, _that.status);
      case AwaitingConfirmed() when confirmed != null:
        return confirmed(_that.bookingId, _that.slotId);
      case AwaitingError() when error != null:
        return error(_that.message, _that.stackTrace);
      case _:
        return null;
    }
  }
}

/// @nodoc

class AwaitingInitial implements AwaitingState {
  const AwaitingInitial();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is AwaitingInitial);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'AwaitingState.initial()';
  }
}

/// @nodoc

class AwaitingLoading implements AwaitingState {
  const AwaitingLoading();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is AwaitingLoading);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'AwaitingState.loading()';
  }
}

/// @nodoc

class AwaitingLoaded implements AwaitingState {
  const AwaitingLoaded(
      {required this.bookingId,
      required this.slotId,
      required this.courtName,
      required this.slotStart,
      required this.slotEnd,
      this.status = 'pending'});

  final String bookingId;
  final String slotId;
  final String courtName;
  final DateTime slotStart;
  final DateTime slotEnd;
  @JsonKey()
  final String status;

  /// Create a copy of AwaitingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AwaitingLoadedCopyWith<AwaitingLoaded> get copyWith =>
      _$AwaitingLoadedCopyWithImpl<AwaitingLoaded>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AwaitingLoaded &&
            (identical(other.bookingId, bookingId) ||
                other.bookingId == bookingId) &&
            (identical(other.slotId, slotId) || other.slotId == slotId) &&
            (identical(other.courtName, courtName) ||
                other.courtName == courtName) &&
            (identical(other.slotStart, slotStart) ||
                other.slotStart == slotStart) &&
            (identical(other.slotEnd, slotEnd) || other.slotEnd == slotEnd) &&
            (identical(other.status, status) || other.status == status));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, bookingId, slotId, courtName, slotStart, slotEnd, status);

  @override
  String toString() {
    return 'AwaitingState.loaded(bookingId: $bookingId, slotId: $slotId, courtName: $courtName, slotStart: $slotStart, slotEnd: $slotEnd, status: $status)';
  }
}

/// @nodoc
abstract mixin class $AwaitingLoadedCopyWith<$Res>
    implements $AwaitingStateCopyWith<$Res> {
  factory $AwaitingLoadedCopyWith(
          AwaitingLoaded value, $Res Function(AwaitingLoaded) _then) =
      _$AwaitingLoadedCopyWithImpl;
  @useResult
  $Res call(
      {String bookingId,
      String slotId,
      String courtName,
      DateTime slotStart,
      DateTime slotEnd,
      String status});
}

/// @nodoc
class _$AwaitingLoadedCopyWithImpl<$Res>
    implements $AwaitingLoadedCopyWith<$Res> {
  _$AwaitingLoadedCopyWithImpl(this._self, this._then);

  final AwaitingLoaded _self;
  final $Res Function(AwaitingLoaded) _then;

  /// Create a copy of AwaitingState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? bookingId = null,
    Object? slotId = null,
    Object? courtName = null,
    Object? slotStart = null,
    Object? slotEnd = null,
    Object? status = null,
  }) {
    return _then(AwaitingLoaded(
      bookingId: null == bookingId
          ? _self.bookingId
          : bookingId // ignore: cast_nullable_to_non_nullable
              as String,
      slotId: null == slotId
          ? _self.slotId
          : slotId // ignore: cast_nullable_to_non_nullable
              as String,
      courtName: null == courtName
          ? _self.courtName
          : courtName // ignore: cast_nullable_to_non_nullable
              as String,
      slotStart: null == slotStart
          ? _self.slotStart
          : slotStart // ignore: cast_nullable_to_non_nullable
              as DateTime,
      slotEnd: null == slotEnd
          ? _self.slotEnd
          : slotEnd // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class AwaitingConfirmed implements AwaitingState {
  const AwaitingConfirmed({required this.bookingId, required this.slotId});

  final String bookingId;
  final String slotId;

  /// Create a copy of AwaitingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AwaitingConfirmedCopyWith<AwaitingConfirmed> get copyWith =>
      _$AwaitingConfirmedCopyWithImpl<AwaitingConfirmed>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AwaitingConfirmed &&
            (identical(other.bookingId, bookingId) ||
                other.bookingId == bookingId) &&
            (identical(other.slotId, slotId) || other.slotId == slotId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, bookingId, slotId);

  @override
  String toString() {
    return 'AwaitingState.confirmed(bookingId: $bookingId, slotId: $slotId)';
  }
}

/// @nodoc
abstract mixin class $AwaitingConfirmedCopyWith<$Res>
    implements $AwaitingStateCopyWith<$Res> {
  factory $AwaitingConfirmedCopyWith(
          AwaitingConfirmed value, $Res Function(AwaitingConfirmed) _then) =
      _$AwaitingConfirmedCopyWithImpl;
  @useResult
  $Res call({String bookingId, String slotId});
}

/// @nodoc
class _$AwaitingConfirmedCopyWithImpl<$Res>
    implements $AwaitingConfirmedCopyWith<$Res> {
  _$AwaitingConfirmedCopyWithImpl(this._self, this._then);

  final AwaitingConfirmed _self;
  final $Res Function(AwaitingConfirmed) _then;

  /// Create a copy of AwaitingState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? bookingId = null,
    Object? slotId = null,
  }) {
    return _then(AwaitingConfirmed(
      bookingId: null == bookingId
          ? _self.bookingId
          : bookingId // ignore: cast_nullable_to_non_nullable
              as String,
      slotId: null == slotId
          ? _self.slotId
          : slotId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class AwaitingError with AppExceptionMixin implements AwaitingState {
  const AwaitingError(this.message, {this.stackTrace});

  final String message;
  final StackTrace? stackTrace;

  /// Create a copy of AwaitingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AwaitingErrorCopyWith<AwaitingError> get copyWith =>
      _$AwaitingErrorCopyWithImpl<AwaitingError>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AwaitingError &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.stackTrace, stackTrace) ||
                other.stackTrace == stackTrace));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, stackTrace);

  @override
  String toString() {
    return 'AwaitingState.error(message: $message, stackTrace: $stackTrace)';
  }
}

/// @nodoc
abstract mixin class $AwaitingErrorCopyWith<$Res>
    implements $AwaitingStateCopyWith<$Res> {
  factory $AwaitingErrorCopyWith(
          AwaitingError value, $Res Function(AwaitingError) _then) =
      _$AwaitingErrorCopyWithImpl;
  @useResult
  $Res call({String message, StackTrace? stackTrace});
}

/// @nodoc
class _$AwaitingErrorCopyWithImpl<$Res>
    implements $AwaitingErrorCopyWith<$Res> {
  _$AwaitingErrorCopyWithImpl(this._self, this._then);

  final AwaitingError _self;
  final $Res Function(AwaitingError) _then;

  /// Create a copy of AwaitingState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = null,
    Object? stackTrace = freezed,
  }) {
    return _then(AwaitingError(
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
