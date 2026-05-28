// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AuthEvent {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is AuthEvent);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'AuthEvent()';
  }
}

/// @nodoc
class $AuthEventCopyWith<$Res> {
  $AuthEventCopyWith(AuthEvent _, $Res Function(AuthEvent) __);
}

/// Adds pattern-matching-related methods to [AuthEvent].
extension AuthEventPatterns on AuthEvent {
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
    TResult Function(AppStarted value)? appStarted,
    TResult Function(AuthStateChanged value)? authStateChanged,
    TResult Function(LoginSubmitted value)? loginSubmitted,
    TResult Function(ForgotPasswordRequested value)? forgotPasswordRequested,
    TResult Function(LogoutRequested value)? logoutRequested,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case AppStarted() when appStarted != null:
        return appStarted(_that);
      case AuthStateChanged() when authStateChanged != null:
        return authStateChanged(_that);
      case LoginSubmitted() when loginSubmitted != null:
        return loginSubmitted(_that);
      case ForgotPasswordRequested() when forgotPasswordRequested != null:
        return forgotPasswordRequested(_that);
      case LogoutRequested() when logoutRequested != null:
        return logoutRequested(_that);
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
    required TResult Function(AppStarted value) appStarted,
    required TResult Function(AuthStateChanged value) authStateChanged,
    required TResult Function(LoginSubmitted value) loginSubmitted,
    required TResult Function(ForgotPasswordRequested value)
        forgotPasswordRequested,
    required TResult Function(LogoutRequested value) logoutRequested,
  }) {
    final _that = this;
    switch (_that) {
      case AppStarted():
        return appStarted(_that);
      case AuthStateChanged():
        return authStateChanged(_that);
      case LoginSubmitted():
        return loginSubmitted(_that);
      case ForgotPasswordRequested():
        return forgotPasswordRequested(_that);
      case LogoutRequested():
        return logoutRequested(_that);
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
    TResult? Function(AppStarted value)? appStarted,
    TResult? Function(AuthStateChanged value)? authStateChanged,
    TResult? Function(LoginSubmitted value)? loginSubmitted,
    TResult? Function(ForgotPasswordRequested value)? forgotPasswordRequested,
    TResult? Function(LogoutRequested value)? logoutRequested,
  }) {
    final _that = this;
    switch (_that) {
      case AppStarted() when appStarted != null:
        return appStarted(_that);
      case AuthStateChanged() when authStateChanged != null:
        return authStateChanged(_that);
      case LoginSubmitted() when loginSubmitted != null:
        return loginSubmitted(_that);
      case ForgotPasswordRequested() when forgotPasswordRequested != null:
        return forgotPasswordRequested(_that);
      case LogoutRequested() when logoutRequested != null:
        return logoutRequested(_that);
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
    TResult Function()? appStarted,
    TResult Function(Object? session)? authStateChanged,
    TResult Function(String email, String password)? loginSubmitted,
    TResult Function(String email)? forgotPasswordRequested,
    TResult Function()? logoutRequested,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case AppStarted() when appStarted != null:
        return appStarted();
      case AuthStateChanged() when authStateChanged != null:
        return authStateChanged(_that.session);
      case LoginSubmitted() when loginSubmitted != null:
        return loginSubmitted(_that.email, _that.password);
      case ForgotPasswordRequested() when forgotPasswordRequested != null:
        return forgotPasswordRequested(_that.email);
      case LogoutRequested() when logoutRequested != null:
        return logoutRequested();
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
    required TResult Function() appStarted,
    required TResult Function(Object? session) authStateChanged,
    required TResult Function(String email, String password) loginSubmitted,
    required TResult Function(String email) forgotPasswordRequested,
    required TResult Function() logoutRequested,
  }) {
    final _that = this;
    switch (_that) {
      case AppStarted():
        return appStarted();
      case AuthStateChanged():
        return authStateChanged(_that.session);
      case LoginSubmitted():
        return loginSubmitted(_that.email, _that.password);
      case ForgotPasswordRequested():
        return forgotPasswordRequested(_that.email);
      case LogoutRequested():
        return logoutRequested();
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
    TResult? Function()? appStarted,
    TResult? Function(Object? session)? authStateChanged,
    TResult? Function(String email, String password)? loginSubmitted,
    TResult? Function(String email)? forgotPasswordRequested,
    TResult? Function()? logoutRequested,
  }) {
    final _that = this;
    switch (_that) {
      case AppStarted() when appStarted != null:
        return appStarted();
      case AuthStateChanged() when authStateChanged != null:
        return authStateChanged(_that.session);
      case LoginSubmitted() when loginSubmitted != null:
        return loginSubmitted(_that.email, _that.password);
      case ForgotPasswordRequested() when forgotPasswordRequested != null:
        return forgotPasswordRequested(_that.email);
      case LogoutRequested() when logoutRequested != null:
        return logoutRequested();
      case _:
        return null;
    }
  }
}

/// @nodoc

class AppStarted implements AuthEvent {
  const AppStarted();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is AppStarted);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'AuthEvent.appStarted()';
  }
}

/// @nodoc

class AuthStateChanged implements AuthEvent {
  const AuthStateChanged(this.session);

  final Object? session;

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AuthStateChangedCopyWith<AuthStateChanged> get copyWith =>
      _$AuthStateChangedCopyWithImpl<AuthStateChanged>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AuthStateChanged &&
            const DeepCollectionEquality().equals(other.session, session));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(session));

  @override
  String toString() {
    return 'AuthEvent.authStateChanged(session: $session)';
  }
}

/// @nodoc
abstract mixin class $AuthStateChangedCopyWith<$Res>
    implements $AuthEventCopyWith<$Res> {
  factory $AuthStateChangedCopyWith(
          AuthStateChanged value, $Res Function(AuthStateChanged) _then) =
      _$AuthStateChangedCopyWithImpl;
  @useResult
  $Res call({Object? session});
}

/// @nodoc
class _$AuthStateChangedCopyWithImpl<$Res>
    implements $AuthStateChangedCopyWith<$Res> {
  _$AuthStateChangedCopyWithImpl(this._self, this._then);

  final AuthStateChanged _self;
  final $Res Function(AuthStateChanged) _then;

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? session = freezed,
  }) {
    return _then(AuthStateChanged(
      freezed == session ? _self.session : session,
    ));
  }
}

/// @nodoc

class LoginSubmitted implements AuthEvent {
  const LoginSubmitted({required this.email, required this.password});

  final String email;
  final String password;

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $LoginSubmittedCopyWith<LoginSubmitted> get copyWith =>
      _$LoginSubmittedCopyWithImpl<LoginSubmitted>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is LoginSubmitted &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.password, password) ||
                other.password == password));
  }

  @override
  int get hashCode => Object.hash(runtimeType, email, password);

  @override
  String toString() {
    return 'AuthEvent.loginSubmitted(email: $email, password: $password)';
  }
}

/// @nodoc
abstract mixin class $LoginSubmittedCopyWith<$Res>
    implements $AuthEventCopyWith<$Res> {
  factory $LoginSubmittedCopyWith(
          LoginSubmitted value, $Res Function(LoginSubmitted) _then) =
      _$LoginSubmittedCopyWithImpl;
  @useResult
  $Res call({String email, String password});
}

/// @nodoc
class _$LoginSubmittedCopyWithImpl<$Res>
    implements $LoginSubmittedCopyWith<$Res> {
  _$LoginSubmittedCopyWithImpl(this._self, this._then);

  final LoginSubmitted _self;
  final $Res Function(LoginSubmitted) _then;

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? email = null,
    Object? password = null,
  }) {
    return _then(LoginSubmitted(
      email: null == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _self.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class ForgotPasswordRequested implements AuthEvent {
  const ForgotPasswordRequested({required this.email});

  final String email;

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ForgotPasswordRequestedCopyWith<ForgotPasswordRequested> get copyWith =>
      _$ForgotPasswordRequestedCopyWithImpl<ForgotPasswordRequested>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ForgotPasswordRequested &&
            (identical(other.email, email) || other.email == email));
  }

  @override
  int get hashCode => Object.hash(runtimeType, email);

  @override
  String toString() {
    return 'AuthEvent.forgotPasswordRequested(email: $email)';
  }
}

/// @nodoc
abstract mixin class $ForgotPasswordRequestedCopyWith<$Res>
    implements $AuthEventCopyWith<$Res> {
  factory $ForgotPasswordRequestedCopyWith(ForgotPasswordRequested value,
          $Res Function(ForgotPasswordRequested) _then) =
      _$ForgotPasswordRequestedCopyWithImpl;
  @useResult
  $Res call({String email});
}

/// @nodoc
class _$ForgotPasswordRequestedCopyWithImpl<$Res>
    implements $ForgotPasswordRequestedCopyWith<$Res> {
  _$ForgotPasswordRequestedCopyWithImpl(this._self, this._then);

  final ForgotPasswordRequested _self;
  final $Res Function(ForgotPasswordRequested) _then;

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? email = null,
  }) {
    return _then(ForgotPasswordRequested(
      email: null == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class LogoutRequested implements AuthEvent {
  const LogoutRequested();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is LogoutRequested);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'AuthEvent.logoutRequested()';
  }
}

// dart format on
