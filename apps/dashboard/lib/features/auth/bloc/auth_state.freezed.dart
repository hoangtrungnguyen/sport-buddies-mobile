// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AuthState {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is AuthState);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'AuthState()';
  }
}

/// @nodoc
class $AuthStateCopyWith<$Res> {
  $AuthStateCopyWith(AuthState _, $Res Function(AuthState) __);
}

/// Adds pattern-matching-related methods to [AuthState].
extension AuthStatePatterns on AuthState {
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
    TResult Function(AuthInitial value)? initial,
    TResult Function(AuthLoading value)? loading,
    TResult Function(AuthAuthenticated value)? authenticated,
    TResult Function(AuthUnauthenticated value)? unauthenticated,
    TResult Function(AuthRejected value)? rejected,
    TResult Function(PasswordResetSent value)? passwordResetSent,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case AuthInitial() when initial != null:
        return initial(_that);
      case AuthLoading() when loading != null:
        return loading(_that);
      case AuthAuthenticated() when authenticated != null:
        return authenticated(_that);
      case AuthUnauthenticated() when unauthenticated != null:
        return unauthenticated(_that);
      case AuthRejected() when rejected != null:
        return rejected(_that);
      case PasswordResetSent() when passwordResetSent != null:
        return passwordResetSent(_that);
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
    required TResult Function(AuthInitial value) initial,
    required TResult Function(AuthLoading value) loading,
    required TResult Function(AuthAuthenticated value) authenticated,
    required TResult Function(AuthUnauthenticated value) unauthenticated,
    required TResult Function(AuthRejected value) rejected,
    required TResult Function(PasswordResetSent value) passwordResetSent,
  }) {
    final _that = this;
    switch (_that) {
      case AuthInitial():
        return initial(_that);
      case AuthLoading():
        return loading(_that);
      case AuthAuthenticated():
        return authenticated(_that);
      case AuthUnauthenticated():
        return unauthenticated(_that);
      case AuthRejected():
        return rejected(_that);
      case PasswordResetSent():
        return passwordResetSent(_that);
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
    TResult? Function(AuthInitial value)? initial,
    TResult? Function(AuthLoading value)? loading,
    TResult? Function(AuthAuthenticated value)? authenticated,
    TResult? Function(AuthUnauthenticated value)? unauthenticated,
    TResult? Function(AuthRejected value)? rejected,
    TResult? Function(PasswordResetSent value)? passwordResetSent,
  }) {
    final _that = this;
    switch (_that) {
      case AuthInitial() when initial != null:
        return initial(_that);
      case AuthLoading() when loading != null:
        return loading(_that);
      case AuthAuthenticated() when authenticated != null:
        return authenticated(_that);
      case AuthUnauthenticated() when unauthenticated != null:
        return unauthenticated(_that);
      case AuthRejected() when rejected != null:
        return rejected(_that);
      case PasswordResetSent() when passwordResetSent != null:
        return passwordResetSent(_that);
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
    TResult Function()? authenticated,
    TResult Function()? unauthenticated,
    TResult Function(String message, StackTrace? stackTrace)? rejected,
    TResult Function()? passwordResetSent,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case AuthInitial() when initial != null:
        return initial();
      case AuthLoading() when loading != null:
        return loading();
      case AuthAuthenticated() when authenticated != null:
        return authenticated();
      case AuthUnauthenticated() when unauthenticated != null:
        return unauthenticated();
      case AuthRejected() when rejected != null:
        return rejected(_that.message, _that.stackTrace);
      case PasswordResetSent() when passwordResetSent != null:
        return passwordResetSent();
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
    required TResult Function() authenticated,
    required TResult Function() unauthenticated,
    required TResult Function(String message, StackTrace? stackTrace) rejected,
    required TResult Function() passwordResetSent,
  }) {
    final _that = this;
    switch (_that) {
      case AuthInitial():
        return initial();
      case AuthLoading():
        return loading();
      case AuthAuthenticated():
        return authenticated();
      case AuthUnauthenticated():
        return unauthenticated();
      case AuthRejected():
        return rejected(_that.message, _that.stackTrace);
      case PasswordResetSent():
        return passwordResetSent();
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
    TResult? Function()? authenticated,
    TResult? Function()? unauthenticated,
    TResult? Function(String message, StackTrace? stackTrace)? rejected,
    TResult? Function()? passwordResetSent,
  }) {
    final _that = this;
    switch (_that) {
      case AuthInitial() when initial != null:
        return initial();
      case AuthLoading() when loading != null:
        return loading();
      case AuthAuthenticated() when authenticated != null:
        return authenticated();
      case AuthUnauthenticated() when unauthenticated != null:
        return unauthenticated();
      case AuthRejected() when rejected != null:
        return rejected(_that.message, _that.stackTrace);
      case PasswordResetSent() when passwordResetSent != null:
        return passwordResetSent();
      case _:
        return null;
    }
  }
}

/// @nodoc

class AuthInitial implements AuthState {
  const AuthInitial();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is AuthInitial);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'AuthState.initial()';
  }
}

/// @nodoc

class AuthLoading implements AuthState {
  const AuthLoading();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is AuthLoading);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'AuthState.loading()';
  }
}

/// @nodoc

class AuthAuthenticated implements AuthState {
  const AuthAuthenticated();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is AuthAuthenticated);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'AuthState.authenticated()';
  }
}

/// @nodoc

class AuthUnauthenticated implements AuthState {
  const AuthUnauthenticated();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is AuthUnauthenticated);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'AuthState.unauthenticated()';
  }
}

/// @nodoc

class AuthRejected with AppExceptionMixin implements AuthState {
  const AuthRejected(this.message, {this.stackTrace});

  final String message;
  final StackTrace? stackTrace;

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AuthRejectedCopyWith<AuthRejected> get copyWith =>
      _$AuthRejectedCopyWithImpl<AuthRejected>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AuthRejected &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.stackTrace, stackTrace) ||
                other.stackTrace == stackTrace));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, stackTrace);

  @override
  String toString() {
    return 'AuthState.rejected(message: $message, stackTrace: $stackTrace)';
  }
}

/// @nodoc
abstract mixin class $AuthRejectedCopyWith<$Res>
    implements $AuthStateCopyWith<$Res> {
  factory $AuthRejectedCopyWith(
          AuthRejected value, $Res Function(AuthRejected) _then) =
      _$AuthRejectedCopyWithImpl;
  @useResult
  $Res call({String message, StackTrace? stackTrace});
}

/// @nodoc
class _$AuthRejectedCopyWithImpl<$Res> implements $AuthRejectedCopyWith<$Res> {
  _$AuthRejectedCopyWithImpl(this._self, this._then);

  final AuthRejected _self;
  final $Res Function(AuthRejected) _then;

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = null,
    Object? stackTrace = freezed,
  }) {
    return _then(AuthRejected(
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

/// @nodoc

class PasswordResetSent implements AuthState {
  const PasswordResetSent();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is PasswordResetSent);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'AuthState.passwordResetSent()';
  }
}

// dart format on
