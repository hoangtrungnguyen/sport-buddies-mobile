// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'signup_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SignupState {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is SignupState);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'SignupState()';
  }
}

/// @nodoc
class $SignupStateCopyWith<$Res> {
  $SignupStateCopyWith(SignupState _, $Res Function(SignupState) __);
}

/// Adds pattern-matching-related methods to [SignupState].
extension SignupStatePatterns on SignupState {
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
    TResult Function(SignupInitial value)? initial,
    TResult Function(SignupSubmitting value)? submitting,
    TResult Function(SignupSuccess value)? success,
    TResult Function(SignupRejected value)? rejected,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case SignupInitial() when initial != null:
        return initial(_that);
      case SignupSubmitting() when submitting != null:
        return submitting(_that);
      case SignupSuccess() when success != null:
        return success(_that);
      case SignupRejected() when rejected != null:
        return rejected(_that);
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
    required TResult Function(SignupInitial value) initial,
    required TResult Function(SignupSubmitting value) submitting,
    required TResult Function(SignupSuccess value) success,
    required TResult Function(SignupRejected value) rejected,
  }) {
    final _that = this;
    switch (_that) {
      case SignupInitial():
        return initial(_that);
      case SignupSubmitting():
        return submitting(_that);
      case SignupSuccess():
        return success(_that);
      case SignupRejected():
        return rejected(_that);
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
    TResult? Function(SignupInitial value)? initial,
    TResult? Function(SignupSubmitting value)? submitting,
    TResult? Function(SignupSuccess value)? success,
    TResult? Function(SignupRejected value)? rejected,
  }) {
    final _that = this;
    switch (_that) {
      case SignupInitial() when initial != null:
        return initial(_that);
      case SignupSubmitting() when submitting != null:
        return submitting(_that);
      case SignupSuccess() when success != null:
        return success(_that);
      case SignupRejected() when rejected != null:
        return rejected(_that);
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
    TResult Function()? submitting,
    TResult Function(String email, bool requiresVerification)? success,
    TResult Function(String message, StackTrace? stackTrace)? rejected,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case SignupInitial() when initial != null:
        return initial();
      case SignupSubmitting() when submitting != null:
        return submitting();
      case SignupSuccess() when success != null:
        return success(_that.email, _that.requiresVerification);
      case SignupRejected() when rejected != null:
        return rejected(_that.message, _that.stackTrace);
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
    required TResult Function() submitting,
    required TResult Function(String email, bool requiresVerification) success,
    required TResult Function(String message, StackTrace? stackTrace) rejected,
  }) {
    final _that = this;
    switch (_that) {
      case SignupInitial():
        return initial();
      case SignupSubmitting():
        return submitting();
      case SignupSuccess():
        return success(_that.email, _that.requiresVerification);
      case SignupRejected():
        return rejected(_that.message, _that.stackTrace);
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
    TResult? Function()? submitting,
    TResult? Function(String email, bool requiresVerification)? success,
    TResult? Function(String message, StackTrace? stackTrace)? rejected,
  }) {
    final _that = this;
    switch (_that) {
      case SignupInitial() when initial != null:
        return initial();
      case SignupSubmitting() when submitting != null:
        return submitting();
      case SignupSuccess() when success != null:
        return success(_that.email, _that.requiresVerification);
      case SignupRejected() when rejected != null:
        return rejected(_that.message, _that.stackTrace);
      case _:
        return null;
    }
  }
}

/// @nodoc

class SignupInitial implements SignupState {
  const SignupInitial();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is SignupInitial);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'SignupState.initial()';
  }
}

/// @nodoc

class SignupSubmitting implements SignupState {
  const SignupSubmitting();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is SignupSubmitting);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'SignupState.submitting()';
  }
}

/// @nodoc

class SignupSuccess implements SignupState {
  const SignupSuccess(
      {required this.email, required this.requiresVerification});

  final String email;
  final bool requiresVerification;

  /// Create a copy of SignupState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SignupSuccessCopyWith<SignupSuccess> get copyWith =>
      _$SignupSuccessCopyWithImpl<SignupSuccess>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SignupSuccess &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.requiresVerification, requiresVerification) ||
                other.requiresVerification == requiresVerification));
  }

  @override
  int get hashCode => Object.hash(runtimeType, email, requiresVerification);

  @override
  String toString() {
    return 'SignupState.success(email: $email, requiresVerification: $requiresVerification)';
  }
}

/// @nodoc
abstract mixin class $SignupSuccessCopyWith<$Res>
    implements $SignupStateCopyWith<$Res> {
  factory $SignupSuccessCopyWith(
          SignupSuccess value, $Res Function(SignupSuccess) _then) =
      _$SignupSuccessCopyWithImpl;
  @useResult
  $Res call({String email, bool requiresVerification});
}

/// @nodoc
class _$SignupSuccessCopyWithImpl<$Res>
    implements $SignupSuccessCopyWith<$Res> {
  _$SignupSuccessCopyWithImpl(this._self, this._then);

  final SignupSuccess _self;
  final $Res Function(SignupSuccess) _then;

  /// Create a copy of SignupState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? email = null,
    Object? requiresVerification = null,
  }) {
    return _then(SignupSuccess(
      email: null == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      requiresVerification: null == requiresVerification
          ? _self.requiresVerification
          : requiresVerification // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class SignupRejected with AppExceptionMixin implements SignupState {
  const SignupRejected(this.message, {this.stackTrace});

  final String message;
  final StackTrace? stackTrace;

  /// Create a copy of SignupState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SignupRejectedCopyWith<SignupRejected> get copyWith =>
      _$SignupRejectedCopyWithImpl<SignupRejected>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SignupRejected &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.stackTrace, stackTrace) ||
                other.stackTrace == stackTrace));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, stackTrace);

  @override
  String toString() {
    return 'SignupState.rejected(message: $message, stackTrace: $stackTrace)';
  }
}

/// @nodoc
abstract mixin class $SignupRejectedCopyWith<$Res>
    implements $SignupStateCopyWith<$Res> {
  factory $SignupRejectedCopyWith(
          SignupRejected value, $Res Function(SignupRejected) _then) =
      _$SignupRejectedCopyWithImpl;
  @useResult
  $Res call({String message, StackTrace? stackTrace});
}

/// @nodoc
class _$SignupRejectedCopyWithImpl<$Res>
    implements $SignupRejectedCopyWith<$Res> {
  _$SignupRejectedCopyWithImpl(this._self, this._then);

  final SignupRejected _self;
  final $Res Function(SignupRejected) _then;

  /// Create a copy of SignupState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = null,
    Object? stackTrace = freezed,
  }) {
    return _then(SignupRejected(
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
