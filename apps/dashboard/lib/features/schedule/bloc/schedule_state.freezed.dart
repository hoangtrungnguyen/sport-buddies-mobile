// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'schedule_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ScheduleState {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is ScheduleState);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'ScheduleState()';
  }
}

/// @nodoc
class $ScheduleStateCopyWith<$Res> {
  $ScheduleStateCopyWith(ScheduleState _, $Res Function(ScheduleState) __);
}

/// Adds pattern-matching-related methods to [ScheduleState].
extension ScheduleStatePatterns on ScheduleState {
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
    TResult Function(ScheduleInitial value)? initial,
    TResult Function(ScheduleLoading value)? loading,
    TResult Function(ScheduleLoaded value)? loaded,
    TResult Function(ScheduleFailure value)? failure,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case ScheduleInitial() when initial != null:
        return initial(_that);
      case ScheduleLoading() when loading != null:
        return loading(_that);
      case ScheduleLoaded() when loaded != null:
        return loaded(_that);
      case ScheduleFailure() when failure != null:
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
    required TResult Function(ScheduleInitial value) initial,
    required TResult Function(ScheduleLoading value) loading,
    required TResult Function(ScheduleLoaded value) loaded,
    required TResult Function(ScheduleFailure value) failure,
  }) {
    final _that = this;
    switch (_that) {
      case ScheduleInitial():
        return initial(_that);
      case ScheduleLoading():
        return loading(_that);
      case ScheduleLoaded():
        return loaded(_that);
      case ScheduleFailure():
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
    TResult? Function(ScheduleInitial value)? initial,
    TResult? Function(ScheduleLoading value)? loading,
    TResult? Function(ScheduleLoaded value)? loaded,
    TResult? Function(ScheduleFailure value)? failure,
  }) {
    final _that = this;
    switch (_that) {
      case ScheduleInitial() when initial != null:
        return initial(_that);
      case ScheduleLoading() when loading != null:
        return loading(_that);
      case ScheduleLoaded() when loaded != null:
        return loaded(_that);
      case ScheduleFailure() when failure != null:
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
            List<OwnerCourt> courts,
            String activeCourtId,
            DateTime weekStart,
            List<OwnerSlot> slots,
            bool busy,
            ManualBookingResult? bookingResult)?
        loaded,
    TResult Function(String message, StackTrace? stackTrace)? failure,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case ScheduleInitial() when initial != null:
        return initial();
      case ScheduleLoading() when loading != null:
        return loading();
      case ScheduleLoaded() when loaded != null:
        return loaded(_that.courts, _that.activeCourtId, _that.weekStart,
            _that.slots, _that.busy, _that.bookingResult);
      case ScheduleFailure() when failure != null:
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
    required TResult Function(
            List<OwnerCourt> courts,
            String activeCourtId,
            DateTime weekStart,
            List<OwnerSlot> slots,
            bool busy,
            ManualBookingResult? bookingResult)
        loaded,
    required TResult Function(String message, StackTrace? stackTrace) failure,
  }) {
    final _that = this;
    switch (_that) {
      case ScheduleInitial():
        return initial();
      case ScheduleLoading():
        return loading();
      case ScheduleLoaded():
        return loaded(_that.courts, _that.activeCourtId, _that.weekStart,
            _that.slots, _that.busy, _that.bookingResult);
      case ScheduleFailure():
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
    TResult? Function(
            List<OwnerCourt> courts,
            String activeCourtId,
            DateTime weekStart,
            List<OwnerSlot> slots,
            bool busy,
            ManualBookingResult? bookingResult)?
        loaded,
    TResult? Function(String message, StackTrace? stackTrace)? failure,
  }) {
    final _that = this;
    switch (_that) {
      case ScheduleInitial() when initial != null:
        return initial();
      case ScheduleLoading() when loading != null:
        return loading();
      case ScheduleLoaded() when loaded != null:
        return loaded(_that.courts, _that.activeCourtId, _that.weekStart,
            _that.slots, _that.busy, _that.bookingResult);
      case ScheduleFailure() when failure != null:
        return failure(_that.message, _that.stackTrace);
      case _:
        return null;
    }
  }
}

/// @nodoc

class ScheduleInitial implements ScheduleState {
  const ScheduleInitial();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is ScheduleInitial);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'ScheduleState.initial()';
  }
}

/// @nodoc

class ScheduleLoading implements ScheduleState {
  const ScheduleLoading();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is ScheduleLoading);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'ScheduleState.loading()';
  }
}

/// @nodoc

class ScheduleLoaded implements ScheduleState {
  const ScheduleLoaded(
      {required final List<OwnerCourt> courts,
      required this.activeCourtId,
      required this.weekStart,
      required final List<OwnerSlot> slots,
      this.busy = false,
      this.bookingResult})
      : _courts = courts,
        _slots = slots;

  final List<OwnerCourt> _courts;
  List<OwnerCourt> get courts {
    if (_courts is EqualUnmodifiableListView) return _courts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_courts);
  }

  final String activeCourtId;
  final DateTime weekStart;
  final List<OwnerSlot> _slots;
  List<OwnerSlot> get slots {
    if (_slots is EqualUnmodifiableListView) return _slots;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_slots);
  }

  @JsonKey()
  final bool busy;

  /// Transient outcome of the most recent manual-booking attempt (OWNER-23).
  /// Set by the bloc when the booking resolves, consumed once by the compose
  /// dialog, then cleared via [ScheduleEvent.bookingResultCleared]. Null in
  /// the steady state.
  final ManualBookingResult? bookingResult;

  /// Create a copy of ScheduleState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ScheduleLoadedCopyWith<ScheduleLoaded> get copyWith =>
      _$ScheduleLoadedCopyWithImpl<ScheduleLoaded>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ScheduleLoaded &&
            const DeepCollectionEquality().equals(other._courts, _courts) &&
            (identical(other.activeCourtId, activeCourtId) ||
                other.activeCourtId == activeCourtId) &&
            (identical(other.weekStart, weekStart) ||
                other.weekStart == weekStart) &&
            const DeepCollectionEquality().equals(other._slots, _slots) &&
            (identical(other.busy, busy) || other.busy == busy) &&
            (identical(other.bookingResult, bookingResult) ||
                other.bookingResult == bookingResult));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_courts),
      activeCourtId,
      weekStart,
      const DeepCollectionEquality().hash(_slots),
      busy,
      bookingResult);

  @override
  String toString() {
    return 'ScheduleState.loaded(courts: $courts, activeCourtId: $activeCourtId, weekStart: $weekStart, slots: $slots, busy: $busy, bookingResult: $bookingResult)';
  }
}

/// @nodoc
abstract mixin class $ScheduleLoadedCopyWith<$Res>
    implements $ScheduleStateCopyWith<$Res> {
  factory $ScheduleLoadedCopyWith(
          ScheduleLoaded value, $Res Function(ScheduleLoaded) _then) =
      _$ScheduleLoadedCopyWithImpl;
  @useResult
  $Res call(
      {List<OwnerCourt> courts,
      String activeCourtId,
      DateTime weekStart,
      List<OwnerSlot> slots,
      bool busy,
      ManualBookingResult? bookingResult});
}

/// @nodoc
class _$ScheduleLoadedCopyWithImpl<$Res>
    implements $ScheduleLoadedCopyWith<$Res> {
  _$ScheduleLoadedCopyWithImpl(this._self, this._then);

  final ScheduleLoaded _self;
  final $Res Function(ScheduleLoaded) _then;

  /// Create a copy of ScheduleState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? courts = null,
    Object? activeCourtId = null,
    Object? weekStart = null,
    Object? slots = null,
    Object? busy = null,
    Object? bookingResult = freezed,
  }) {
    return _then(ScheduleLoaded(
      courts: null == courts
          ? _self._courts
          : courts // ignore: cast_nullable_to_non_nullable
              as List<OwnerCourt>,
      activeCourtId: null == activeCourtId
          ? _self.activeCourtId
          : activeCourtId // ignore: cast_nullable_to_non_nullable
              as String,
      weekStart: null == weekStart
          ? _self.weekStart
          : weekStart // ignore: cast_nullable_to_non_nullable
              as DateTime,
      slots: null == slots
          ? _self._slots
          : slots // ignore: cast_nullable_to_non_nullable
              as List<OwnerSlot>,
      busy: null == busy
          ? _self.busy
          : busy // ignore: cast_nullable_to_non_nullable
              as bool,
      bookingResult: freezed == bookingResult
          ? _self.bookingResult
          : bookingResult // ignore: cast_nullable_to_non_nullable
              as ManualBookingResult?,
    ));
  }
}

/// @nodoc

class ScheduleFailure with AppExceptionMixin implements ScheduleState {
  const ScheduleFailure(this.message, {this.stackTrace});

  final String message;
  final StackTrace? stackTrace;

  /// Create a copy of ScheduleState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ScheduleFailureCopyWith<ScheduleFailure> get copyWith =>
      _$ScheduleFailureCopyWithImpl<ScheduleFailure>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ScheduleFailure &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.stackTrace, stackTrace) ||
                other.stackTrace == stackTrace));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, stackTrace);

  @override
  String toString() {
    return 'ScheduleState.failure(message: $message, stackTrace: $stackTrace)';
  }
}

/// @nodoc
abstract mixin class $ScheduleFailureCopyWith<$Res>
    implements $ScheduleStateCopyWith<$Res> {
  factory $ScheduleFailureCopyWith(
          ScheduleFailure value, $Res Function(ScheduleFailure) _then) =
      _$ScheduleFailureCopyWithImpl;
  @useResult
  $Res call({String message, StackTrace? stackTrace});
}

/// @nodoc
class _$ScheduleFailureCopyWithImpl<$Res>
    implements $ScheduleFailureCopyWith<$Res> {
  _$ScheduleFailureCopyWithImpl(this._self, this._then);

  final ScheduleFailure _self;
  final $Res Function(ScheduleFailure) _then;

  /// Create a copy of ScheduleState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = null,
    Object? stackTrace = freezed,
  }) {
    return _then(ScheduleFailure(
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
