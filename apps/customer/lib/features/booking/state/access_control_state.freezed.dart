// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'access_control_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AccessControlState {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is AccessControlState);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'AccessControlState()';
  }
}

/// @nodoc
class $AccessControlStateCopyWith<$Res> {
  $AccessControlStateCopyWith(
      AccessControlState _, $Res Function(AccessControlState) __);
}

/// Adds pattern-matching-related methods to [AccessControlState].
extension AccessControlStatePatterns on AccessControlState {
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
    TResult Function(AccessControlIdle value)? idle,
    TResult Function(AccessControlSaving value)? saving,
    TResult Function(AccessControlSaved value)? saved,
    TResult Function(AccessControlFailure value)? failure,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case AccessControlIdle() when idle != null:
        return idle(_that);
      case AccessControlSaving() when saving != null:
        return saving(_that);
      case AccessControlSaved() when saved != null:
        return saved(_that);
      case AccessControlFailure() when failure != null:
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
    required TResult Function(AccessControlIdle value) idle,
    required TResult Function(AccessControlSaving value) saving,
    required TResult Function(AccessControlSaved value) saved,
    required TResult Function(AccessControlFailure value) failure,
  }) {
    final _that = this;
    switch (_that) {
      case AccessControlIdle():
        return idle(_that);
      case AccessControlSaving():
        return saving(_that);
      case AccessControlSaved():
        return saved(_that);
      case AccessControlFailure():
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
    TResult? Function(AccessControlIdle value)? idle,
    TResult? Function(AccessControlSaving value)? saving,
    TResult? Function(AccessControlSaved value)? saved,
    TResult? Function(AccessControlFailure value)? failure,
  }) {
    final _that = this;
    switch (_that) {
      case AccessControlIdle() when idle != null:
        return idle(_that);
      case AccessControlSaving() when saving != null:
        return saving(_that);
      case AccessControlSaved() when saved != null:
        return saved(_that);
      case AccessControlFailure() when failure != null:
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
    TResult Function()? idle,
    TResult Function()? saving,
    TResult Function()? saved,
    TResult Function(String message, StackTrace? stackTrace)? failure,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case AccessControlIdle() when idle != null:
        return idle();
      case AccessControlSaving() when saving != null:
        return saving();
      case AccessControlSaved() when saved != null:
        return saved();
      case AccessControlFailure() when failure != null:
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
    required TResult Function() idle,
    required TResult Function() saving,
    required TResult Function() saved,
    required TResult Function(String message, StackTrace? stackTrace) failure,
  }) {
    final _that = this;
    switch (_that) {
      case AccessControlIdle():
        return idle();
      case AccessControlSaving():
        return saving();
      case AccessControlSaved():
        return saved();
      case AccessControlFailure():
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
    TResult? Function()? idle,
    TResult? Function()? saving,
    TResult? Function()? saved,
    TResult? Function(String message, StackTrace? stackTrace)? failure,
  }) {
    final _that = this;
    switch (_that) {
      case AccessControlIdle() when idle != null:
        return idle();
      case AccessControlSaving() when saving != null:
        return saving();
      case AccessControlSaved() when saved != null:
        return saved();
      case AccessControlFailure() when failure != null:
        return failure(_that.message, _that.stackTrace);
      case _:
        return null;
    }
  }
}

/// @nodoc

class AccessControlIdle implements AccessControlState {
  const AccessControlIdle();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is AccessControlIdle);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'AccessControlState.idle()';
  }
}

/// @nodoc

class AccessControlSaving implements AccessControlState {
  const AccessControlSaving();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is AccessControlSaving);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'AccessControlState.saving()';
  }
}

/// @nodoc

class AccessControlSaved implements AccessControlState {
  const AccessControlSaved();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is AccessControlSaved);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'AccessControlState.saved()';
  }
}

/// @nodoc

class AccessControlFailure
    with AppExceptionMixin
    implements AccessControlState {
  const AccessControlFailure(this.message, {this.stackTrace});

  final String message;
  final StackTrace? stackTrace;

  /// Create a copy of AccessControlState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AccessControlFailureCopyWith<AccessControlFailure> get copyWith =>
      _$AccessControlFailureCopyWithImpl<AccessControlFailure>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AccessControlFailure &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.stackTrace, stackTrace) ||
                other.stackTrace == stackTrace));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, stackTrace);

  @override
  String toString() {
    return 'AccessControlState.failure(message: $message, stackTrace: $stackTrace)';
  }
}

/// @nodoc
abstract mixin class $AccessControlFailureCopyWith<$Res>
    implements $AccessControlStateCopyWith<$Res> {
  factory $AccessControlFailureCopyWith(AccessControlFailure value,
          $Res Function(AccessControlFailure) _then) =
      _$AccessControlFailureCopyWithImpl;
  @useResult
  $Res call({String message, StackTrace? stackTrace});
}

/// @nodoc
class _$AccessControlFailureCopyWithImpl<$Res>
    implements $AccessControlFailureCopyWith<$Res> {
  _$AccessControlFailureCopyWithImpl(this._self, this._then);

  final AccessControlFailure _self;
  final $Res Function(AccessControlFailure) _then;

  /// Create a copy of AccessControlState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = null,
    Object? stackTrace = freezed,
  }) {
    return _then(AccessControlFailure(
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
