// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PaymentState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PaymentState()';
}


}

/// @nodoc
class $PaymentStateCopyWith<$Res>  {
$PaymentStateCopyWith(PaymentState _, $Res Function(PaymentState) __);
}


/// Adds pattern-matching-related methods to [PaymentState].
extension PaymentStatePatterns on PaymentState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( PaymentLoading value)?  loading,TResult Function( PaymentLoaded value)?  loaded,TResult Function( PaymentError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case PaymentLoading() when loading != null:
return loading(_that);case PaymentLoaded() when loaded != null:
return loaded(_that);case PaymentError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( PaymentLoading value)  loading,required TResult Function( PaymentLoaded value)  loaded,required TResult Function( PaymentError value)  error,}){
final _that = this;
switch (_that) {
case PaymentLoading():
return loading(_that);case PaymentLoaded():
return loaded(_that);case PaymentError():
return error(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( PaymentLoading value)?  loading,TResult? Function( PaymentLoaded value)?  loaded,TResult? Function( PaymentError value)?  error,}){
final _that = this;
switch (_that) {
case PaymentLoading() when loading != null:
return loading(_that);case PaymentLoaded() when loaded != null:
return loaded(_that);case PaymentError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  loading,TResult Function( String bookingId,  String courtName,  DateTime slotStart,  DateTime slotEnd,  double totalPrice)?  loaded,TResult Function( String message,  StackTrace? stackTrace)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case PaymentLoading() when loading != null:
return loading();case PaymentLoaded() when loaded != null:
return loaded(_that.bookingId,_that.courtName,_that.slotStart,_that.slotEnd,_that.totalPrice);case PaymentError() when error != null:
return error(_that.message,_that.stackTrace);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  loading,required TResult Function( String bookingId,  String courtName,  DateTime slotStart,  DateTime slotEnd,  double totalPrice)  loaded,required TResult Function( String message,  StackTrace? stackTrace)  error,}) {final _that = this;
switch (_that) {
case PaymentLoading():
return loading();case PaymentLoaded():
return loaded(_that.bookingId,_that.courtName,_that.slotStart,_that.slotEnd,_that.totalPrice);case PaymentError():
return error(_that.message,_that.stackTrace);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  loading,TResult? Function( String bookingId,  String courtName,  DateTime slotStart,  DateTime slotEnd,  double totalPrice)?  loaded,TResult? Function( String message,  StackTrace? stackTrace)?  error,}) {final _that = this;
switch (_that) {
case PaymentLoading() when loading != null:
return loading();case PaymentLoaded() when loaded != null:
return loaded(_that.bookingId,_that.courtName,_that.slotStart,_that.slotEnd,_that.totalPrice);case PaymentError() when error != null:
return error(_that.message,_that.stackTrace);case _:
  return null;

}
}

}

/// @nodoc


class PaymentLoading implements PaymentState {
  const PaymentLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PaymentState.loading()';
}


}




/// @nodoc


class PaymentLoaded implements PaymentState {
  const PaymentLoaded({required this.bookingId, required this.courtName, required this.slotStart, required this.slotEnd, required this.totalPrice});
  

 final  String bookingId;
 final  String courtName;
 final  DateTime slotStart;
 final  DateTime slotEnd;
 final  double totalPrice;

/// Create a copy of PaymentState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentLoadedCopyWith<PaymentLoaded> get copyWith => _$PaymentLoadedCopyWithImpl<PaymentLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentLoaded&&(identical(other.bookingId, bookingId) || other.bookingId == bookingId)&&(identical(other.courtName, courtName) || other.courtName == courtName)&&(identical(other.slotStart, slotStart) || other.slotStart == slotStart)&&(identical(other.slotEnd, slotEnd) || other.slotEnd == slotEnd)&&(identical(other.totalPrice, totalPrice) || other.totalPrice == totalPrice));
}


@override
int get hashCode => Object.hash(runtimeType,bookingId,courtName,slotStart,slotEnd,totalPrice);

@override
String toString() {
  return 'PaymentState.loaded(bookingId: $bookingId, courtName: $courtName, slotStart: $slotStart, slotEnd: $slotEnd, totalPrice: $totalPrice)';
}


}

/// @nodoc
abstract mixin class $PaymentLoadedCopyWith<$Res> implements $PaymentStateCopyWith<$Res> {
  factory $PaymentLoadedCopyWith(PaymentLoaded value, $Res Function(PaymentLoaded) _then) = _$PaymentLoadedCopyWithImpl;
@useResult
$Res call({
 String bookingId, String courtName, DateTime slotStart, DateTime slotEnd, double totalPrice
});




}
/// @nodoc
class _$PaymentLoadedCopyWithImpl<$Res>
    implements $PaymentLoadedCopyWith<$Res> {
  _$PaymentLoadedCopyWithImpl(this._self, this._then);

  final PaymentLoaded _self;
  final $Res Function(PaymentLoaded) _then;

/// Create a copy of PaymentState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? bookingId = null,Object? courtName = null,Object? slotStart = null,Object? slotEnd = null,Object? totalPrice = null,}) {
  return _then(PaymentLoaded(
bookingId: null == bookingId ? _self.bookingId : bookingId // ignore: cast_nullable_to_non_nullable
as String,courtName: null == courtName ? _self.courtName : courtName // ignore: cast_nullable_to_non_nullable
as String,slotStart: null == slotStart ? _self.slotStart : slotStart // ignore: cast_nullable_to_non_nullable
as DateTime,slotEnd: null == slotEnd ? _self.slotEnd : slotEnd // ignore: cast_nullable_to_non_nullable
as DateTime,totalPrice: null == totalPrice ? _self.totalPrice : totalPrice // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc


class PaymentError with AppExceptionMixin implements PaymentState {
  const PaymentError(this.message, {this.stackTrace});
  

 final  String message;
 final  StackTrace? stackTrace;

/// Create a copy of PaymentState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentErrorCopyWith<PaymentError> get copyWith => _$PaymentErrorCopyWithImpl<PaymentError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentError&&(identical(other.message, message) || other.message == message)&&(identical(other.stackTrace, stackTrace) || other.stackTrace == stackTrace));
}


@override
int get hashCode => Object.hash(runtimeType,message,stackTrace);

@override
String toString() {
  return 'PaymentState.error(message: $message, stackTrace: $stackTrace)';
}


}

/// @nodoc
abstract mixin class $PaymentErrorCopyWith<$Res> implements $PaymentStateCopyWith<$Res> {
  factory $PaymentErrorCopyWith(PaymentError value, $Res Function(PaymentError) _then) = _$PaymentErrorCopyWithImpl;
@useResult
$Res call({
 String message, StackTrace? stackTrace
});




}
/// @nodoc
class _$PaymentErrorCopyWithImpl<$Res>
    implements $PaymentErrorCopyWith<$Res> {
  _$PaymentErrorCopyWithImpl(this._self, this._then);

  final PaymentError _self;
  final $Res Function(PaymentError) _then;

/// Create a copy of PaymentState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,Object? stackTrace = freezed,}) {
  return _then(PaymentError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,stackTrace: freezed == stackTrace ? _self.stackTrace : stackTrace // ignore: cast_nullable_to_non_nullable
as StackTrace?,
  ));
}


}

// dart format on
