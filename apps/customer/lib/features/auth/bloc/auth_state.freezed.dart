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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthState()';
}


}

/// @nodoc
class $AuthStateCopyWith<$Res>  {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( AuthInitial value)?  initial,TResult Function( AuthLoading value)?  loading,TResult Function( AuthSuccess value)?  success,TResult Function( AuthValidationError value)?  validationError,TResult Function( AuthRejected value)?  rejected,TResult Function( AuthFailureState value)?  failure,TResult Function( PasswordResetSent value)?  passwordResetSent,TResult Function( VerificationEmailSent value)?  verificationEmailSent,TResult Function( AuthAuthenticated value)?  authenticated,TResult Function( AuthUnauthenticated value)?  unauthenticated,required TResult orElse(),}){
final _that = this;
switch (_that) {
case AuthInitial() when initial != null:
return initial(_that);case AuthLoading() when loading != null:
return loading(_that);case AuthSuccess() when success != null:
return success(_that);case AuthValidationError() when validationError != null:
return validationError(_that);case AuthRejected() when rejected != null:
return rejected(_that);case AuthFailureState() when failure != null:
return failure(_that);case PasswordResetSent() when passwordResetSent != null:
return passwordResetSent(_that);case VerificationEmailSent() when verificationEmailSent != null:
return verificationEmailSent(_that);case AuthAuthenticated() when authenticated != null:
return authenticated(_that);case AuthUnauthenticated() when unauthenticated != null:
return unauthenticated(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( AuthInitial value)  initial,required TResult Function( AuthLoading value)  loading,required TResult Function( AuthSuccess value)  success,required TResult Function( AuthValidationError value)  validationError,required TResult Function( AuthRejected value)  rejected,required TResult Function( AuthFailureState value)  failure,required TResult Function( PasswordResetSent value)  passwordResetSent,required TResult Function( VerificationEmailSent value)  verificationEmailSent,required TResult Function( AuthAuthenticated value)  authenticated,required TResult Function( AuthUnauthenticated value)  unauthenticated,}){
final _that = this;
switch (_that) {
case AuthInitial():
return initial(_that);case AuthLoading():
return loading(_that);case AuthSuccess():
return success(_that);case AuthValidationError():
return validationError(_that);case AuthRejected():
return rejected(_that);case AuthFailureState():
return failure(_that);case PasswordResetSent():
return passwordResetSent(_that);case VerificationEmailSent():
return verificationEmailSent(_that);case AuthAuthenticated():
return authenticated(_that);case AuthUnauthenticated():
return unauthenticated(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( AuthInitial value)?  initial,TResult? Function( AuthLoading value)?  loading,TResult? Function( AuthSuccess value)?  success,TResult? Function( AuthValidationError value)?  validationError,TResult? Function( AuthRejected value)?  rejected,TResult? Function( AuthFailureState value)?  failure,TResult? Function( PasswordResetSent value)?  passwordResetSent,TResult? Function( VerificationEmailSent value)?  verificationEmailSent,TResult? Function( AuthAuthenticated value)?  authenticated,TResult? Function( AuthUnauthenticated value)?  unauthenticated,}){
final _that = this;
switch (_that) {
case AuthInitial() when initial != null:
return initial(_that);case AuthLoading() when loading != null:
return loading(_that);case AuthSuccess() when success != null:
return success(_that);case AuthValidationError() when validationError != null:
return validationError(_that);case AuthRejected() when rejected != null:
return rejected(_that);case AuthFailureState() when failure != null:
return failure(_that);case PasswordResetSent() when passwordResetSent != null:
return passwordResetSent(_that);case VerificationEmailSent() when verificationEmailSent != null:
return verificationEmailSent(_that);case AuthAuthenticated() when authenticated != null:
return authenticated(_that);case AuthUnauthenticated() when unauthenticated != null:
return unauthenticated(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function()?  success,TResult Function( String message)?  validationError,TResult Function( String message,  StackTrace? stackTrace)?  rejected,TResult Function( String message,  StackTrace? stackTrace)?  failure,TResult Function()?  passwordResetSent,TResult Function()?  verificationEmailSent,TResult Function()?  authenticated,TResult Function()?  unauthenticated,required TResult orElse(),}) {final _that = this;
switch (_that) {
case AuthInitial() when initial != null:
return initial();case AuthLoading() when loading != null:
return loading();case AuthSuccess() when success != null:
return success();case AuthValidationError() when validationError != null:
return validationError(_that.message);case AuthRejected() when rejected != null:
return rejected(_that.message,_that.stackTrace);case AuthFailureState() when failure != null:
return failure(_that.message,_that.stackTrace);case PasswordResetSent() when passwordResetSent != null:
return passwordResetSent();case VerificationEmailSent() when verificationEmailSent != null:
return verificationEmailSent();case AuthAuthenticated() when authenticated != null:
return authenticated();case AuthUnauthenticated() when unauthenticated != null:
return unauthenticated();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function()  success,required TResult Function( String message)  validationError,required TResult Function( String message,  StackTrace? stackTrace)  rejected,required TResult Function( String message,  StackTrace? stackTrace)  failure,required TResult Function()  passwordResetSent,required TResult Function()  verificationEmailSent,required TResult Function()  authenticated,required TResult Function()  unauthenticated,}) {final _that = this;
switch (_that) {
case AuthInitial():
return initial();case AuthLoading():
return loading();case AuthSuccess():
return success();case AuthValidationError():
return validationError(_that.message);case AuthRejected():
return rejected(_that.message,_that.stackTrace);case AuthFailureState():
return failure(_that.message,_that.stackTrace);case PasswordResetSent():
return passwordResetSent();case VerificationEmailSent():
return verificationEmailSent();case AuthAuthenticated():
return authenticated();case AuthUnauthenticated():
return unauthenticated();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function()?  success,TResult? Function( String message)?  validationError,TResult? Function( String message,  StackTrace? stackTrace)?  rejected,TResult? Function( String message,  StackTrace? stackTrace)?  failure,TResult? Function()?  passwordResetSent,TResult? Function()?  verificationEmailSent,TResult? Function()?  authenticated,TResult? Function()?  unauthenticated,}) {final _that = this;
switch (_that) {
case AuthInitial() when initial != null:
return initial();case AuthLoading() when loading != null:
return loading();case AuthSuccess() when success != null:
return success();case AuthValidationError() when validationError != null:
return validationError(_that.message);case AuthRejected() when rejected != null:
return rejected(_that.message,_that.stackTrace);case AuthFailureState() when failure != null:
return failure(_that.message,_that.stackTrace);case PasswordResetSent() when passwordResetSent != null:
return passwordResetSent();case VerificationEmailSent() when verificationEmailSent != null:
return verificationEmailSent();case AuthAuthenticated() when authenticated != null:
return authenticated();case AuthUnauthenticated() when unauthenticated != null:
return unauthenticated();case _:
  return null;

}
}

}

/// @nodoc


class AuthInitial implements AuthState {
  const AuthInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthInitial);
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthState.loading()';
}


}




/// @nodoc


class AuthSuccess implements AuthState {
  const AuthSuccess();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthSuccess);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthState.success()';
}


}




/// @nodoc


class AuthValidationError implements AuthState {
  const AuthValidationError(this.message);
  

 final  String message;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthValidationErrorCopyWith<AuthValidationError> get copyWith => _$AuthValidationErrorCopyWithImpl<AuthValidationError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthValidationError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'AuthState.validationError(message: $message)';
}


}

/// @nodoc
abstract mixin class $AuthValidationErrorCopyWith<$Res> implements $AuthStateCopyWith<$Res> {
  factory $AuthValidationErrorCopyWith(AuthValidationError value, $Res Function(AuthValidationError) _then) = _$AuthValidationErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$AuthValidationErrorCopyWithImpl<$Res>
    implements $AuthValidationErrorCopyWith<$Res> {
  _$AuthValidationErrorCopyWithImpl(this._self, this._then);

  final AuthValidationError _self;
  final $Res Function(AuthValidationError) _then;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(AuthValidationError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class AuthRejected with AppExceptionMixin implements AuthState {
  const AuthRejected(this.message, {this.stackTrace});
  

 final  String message;
 final  StackTrace? stackTrace;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthRejectedCopyWith<AuthRejected> get copyWith => _$AuthRejectedCopyWithImpl<AuthRejected>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthRejected&&(identical(other.message, message) || other.message == message)&&(identical(other.stackTrace, stackTrace) || other.stackTrace == stackTrace));
}


@override
int get hashCode => Object.hash(runtimeType,message,stackTrace);

@override
String toString() {
  return 'AuthState.rejected(message: $message, stackTrace: $stackTrace)';
}


}

/// @nodoc
abstract mixin class $AuthRejectedCopyWith<$Res> implements $AuthStateCopyWith<$Res> {
  factory $AuthRejectedCopyWith(AuthRejected value, $Res Function(AuthRejected) _then) = _$AuthRejectedCopyWithImpl;
@useResult
$Res call({
 String message, StackTrace? stackTrace
});




}
/// @nodoc
class _$AuthRejectedCopyWithImpl<$Res>
    implements $AuthRejectedCopyWith<$Res> {
  _$AuthRejectedCopyWithImpl(this._self, this._then);

  final AuthRejected _self;
  final $Res Function(AuthRejected) _then;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,Object? stackTrace = freezed,}) {
  return _then(AuthRejected(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,stackTrace: freezed == stackTrace ? _self.stackTrace : stackTrace // ignore: cast_nullable_to_non_nullable
as StackTrace?,
  ));
}


}

/// @nodoc


class AuthFailureState implements AuthState {
  const AuthFailureState(this.message, {this.stackTrace});
  

 final  String message;
 final  StackTrace? stackTrace;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthFailureStateCopyWith<AuthFailureState> get copyWith => _$AuthFailureStateCopyWithImpl<AuthFailureState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthFailureState&&(identical(other.message, message) || other.message == message)&&(identical(other.stackTrace, stackTrace) || other.stackTrace == stackTrace));
}


@override
int get hashCode => Object.hash(runtimeType,message,stackTrace);

@override
String toString() {
  return 'AuthState.failure(message: $message, stackTrace: $stackTrace)';
}


}

/// @nodoc
abstract mixin class $AuthFailureStateCopyWith<$Res> implements $AuthStateCopyWith<$Res> {
  factory $AuthFailureStateCopyWith(AuthFailureState value, $Res Function(AuthFailureState) _then) = _$AuthFailureStateCopyWithImpl;
@useResult
$Res call({
 String message, StackTrace? stackTrace
});




}
/// @nodoc
class _$AuthFailureStateCopyWithImpl<$Res>
    implements $AuthFailureStateCopyWith<$Res> {
  _$AuthFailureStateCopyWithImpl(this._self, this._then);

  final AuthFailureState _self;
  final $Res Function(AuthFailureState) _then;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,Object? stackTrace = freezed,}) {
  return _then(AuthFailureState(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,stackTrace: freezed == stackTrace ? _self.stackTrace : stackTrace // ignore: cast_nullable_to_non_nullable
as StackTrace?,
  ));
}


}

/// @nodoc


class PasswordResetSent implements AuthState {
  const PasswordResetSent();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PasswordResetSent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthState.passwordResetSent()';
}


}




/// @nodoc


class VerificationEmailSent implements AuthState {
  const VerificationEmailSent();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VerificationEmailSent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthState.verificationEmailSent()';
}


}




/// @nodoc


class AuthAuthenticated implements AuthState {
  const AuthAuthenticated();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthAuthenticated);
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthUnauthenticated);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthState.unauthenticated()';
}


}




// dart format on
