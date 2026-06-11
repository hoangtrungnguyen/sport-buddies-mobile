// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'booking_wizard_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BookingWizardState {

 BookingDraft get draft; ContactInfo get contact; int get currentStep;// 0 Confirm · 1 Play · 2 Awaiting · 3 Done
 AccessPolicy get access; int get maxPlayers; Booking? get booking;// null until createBooking succeeds
 bool get submitting;// RPC in flight
 bool get declined;// owner declined on Step 3
 WizardEffect get effect;
/// Create a copy of BookingWizardState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookingWizardStateCopyWith<BookingWizardState> get copyWith => _$BookingWizardStateCopyWithImpl<BookingWizardState>(this as BookingWizardState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BookingWizardState&&(identical(other.draft, draft) || other.draft == draft)&&(identical(other.contact, contact) || other.contact == contact)&&(identical(other.currentStep, currentStep) || other.currentStep == currentStep)&&(identical(other.access, access) || other.access == access)&&(identical(other.maxPlayers, maxPlayers) || other.maxPlayers == maxPlayers)&&(identical(other.booking, booking) || other.booking == booking)&&(identical(other.submitting, submitting) || other.submitting == submitting)&&(identical(other.declined, declined) || other.declined == declined)&&(identical(other.effect, effect) || other.effect == effect));
}


@override
int get hashCode => Object.hash(runtimeType,draft,contact,currentStep,access,maxPlayers,booking,submitting,declined,effect);

@override
String toString() {
  return 'BookingWizardState(draft: $draft, contact: $contact, currentStep: $currentStep, access: $access, maxPlayers: $maxPlayers, booking: $booking, submitting: $submitting, declined: $declined, effect: $effect)';
}


}

/// @nodoc
abstract mixin class $BookingWizardStateCopyWith<$Res>  {
  factory $BookingWizardStateCopyWith(BookingWizardState value, $Res Function(BookingWizardState) _then) = _$BookingWizardStateCopyWithImpl;
@useResult
$Res call({
 BookingDraft draft, ContactInfo contact, int currentStep, AccessPolicy access, int maxPlayers, Booking? booking, bool submitting, bool declined, WizardEffect effect
});




}
/// @nodoc
class _$BookingWizardStateCopyWithImpl<$Res>
    implements $BookingWizardStateCopyWith<$Res> {
  _$BookingWizardStateCopyWithImpl(this._self, this._then);

  final BookingWizardState _self;
  final $Res Function(BookingWizardState) _then;

/// Create a copy of BookingWizardState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? draft = null,Object? contact = null,Object? currentStep = null,Object? access = null,Object? maxPlayers = null,Object? booking = freezed,Object? submitting = null,Object? declined = null,Object? effect = null,}) {
  return _then(_self.copyWith(
draft: null == draft ? _self.draft : draft // ignore: cast_nullable_to_non_nullable
as BookingDraft,contact: null == contact ? _self.contact : contact // ignore: cast_nullable_to_non_nullable
as ContactInfo,currentStep: null == currentStep ? _self.currentStep : currentStep // ignore: cast_nullable_to_non_nullable
as int,access: null == access ? _self.access : access // ignore: cast_nullable_to_non_nullable
as AccessPolicy,maxPlayers: null == maxPlayers ? _self.maxPlayers : maxPlayers // ignore: cast_nullable_to_non_nullable
as int,booking: freezed == booking ? _self.booking : booking // ignore: cast_nullable_to_non_nullable
as Booking?,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,declined: null == declined ? _self.declined : declined // ignore: cast_nullable_to_non_nullable
as bool,effect: null == effect ? _self.effect : effect // ignore: cast_nullable_to_non_nullable
as WizardEffect,
  ));
}

}


/// Adds pattern-matching-related methods to [BookingWizardState].
extension BookingWizardStatePatterns on BookingWizardState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BookingWizardState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BookingWizardState() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BookingWizardState value)  $default,){
final _that = this;
switch (_that) {
case _BookingWizardState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BookingWizardState value)?  $default,){
final _that = this;
switch (_that) {
case _BookingWizardState() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( BookingDraft draft,  ContactInfo contact,  int currentStep,  AccessPolicy access,  int maxPlayers,  Booking? booking,  bool submitting,  bool declined,  WizardEffect effect)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BookingWizardState() when $default != null:
return $default(_that.draft,_that.contact,_that.currentStep,_that.access,_that.maxPlayers,_that.booking,_that.submitting,_that.declined,_that.effect);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( BookingDraft draft,  ContactInfo contact,  int currentStep,  AccessPolicy access,  int maxPlayers,  Booking? booking,  bool submitting,  bool declined,  WizardEffect effect)  $default,) {final _that = this;
switch (_that) {
case _BookingWizardState():
return $default(_that.draft,_that.contact,_that.currentStep,_that.access,_that.maxPlayers,_that.booking,_that.submitting,_that.declined,_that.effect);case _:
  throw StateError('Unexpected subclass');

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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( BookingDraft draft,  ContactInfo contact,  int currentStep,  AccessPolicy access,  int maxPlayers,  Booking? booking,  bool submitting,  bool declined,  WizardEffect effect)?  $default,) {final _that = this;
switch (_that) {
case _BookingWizardState() when $default != null:
return $default(_that.draft,_that.contact,_that.currentStep,_that.access,_that.maxPlayers,_that.booking,_that.submitting,_that.declined,_that.effect);case _:
  return null;

}
}

}

/// @nodoc


class _BookingWizardState extends BookingWizardState {
  const _BookingWizardState({required this.draft, required this.contact, this.currentStep = 0, this.access = AccessPolicy.private, this.maxPlayers = 4, this.booking, this.submitting = false, this.declined = false, this.effect = WizardEffect.none}): super._();
  

@override final  BookingDraft draft;
@override final  ContactInfo contact;
@override@JsonKey() final  int currentStep;
// 0 Confirm · 1 Play · 2 Awaiting · 3 Done
@override@JsonKey() final  AccessPolicy access;
@override@JsonKey() final  int maxPlayers;
@override final  Booking? booking;
// null until createBooking succeeds
@override@JsonKey() final  bool submitting;
// RPC in flight
@override@JsonKey() final  bool declined;
// owner declined on Step 3
@override@JsonKey() final  WizardEffect effect;

/// Create a copy of BookingWizardState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookingWizardStateCopyWith<_BookingWizardState> get copyWith => __$BookingWizardStateCopyWithImpl<_BookingWizardState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BookingWizardState&&(identical(other.draft, draft) || other.draft == draft)&&(identical(other.contact, contact) || other.contact == contact)&&(identical(other.currentStep, currentStep) || other.currentStep == currentStep)&&(identical(other.access, access) || other.access == access)&&(identical(other.maxPlayers, maxPlayers) || other.maxPlayers == maxPlayers)&&(identical(other.booking, booking) || other.booking == booking)&&(identical(other.submitting, submitting) || other.submitting == submitting)&&(identical(other.declined, declined) || other.declined == declined)&&(identical(other.effect, effect) || other.effect == effect));
}


@override
int get hashCode => Object.hash(runtimeType,draft,contact,currentStep,access,maxPlayers,booking,submitting,declined,effect);

@override
String toString() {
  return 'BookingWizardState(draft: $draft, contact: $contact, currentStep: $currentStep, access: $access, maxPlayers: $maxPlayers, booking: $booking, submitting: $submitting, declined: $declined, effect: $effect)';
}


}

/// @nodoc
abstract mixin class _$BookingWizardStateCopyWith<$Res> implements $BookingWizardStateCopyWith<$Res> {
  factory _$BookingWizardStateCopyWith(_BookingWizardState value, $Res Function(_BookingWizardState) _then) = __$BookingWizardStateCopyWithImpl;
@override @useResult
$Res call({
 BookingDraft draft, ContactInfo contact, int currentStep, AccessPolicy access, int maxPlayers, Booking? booking, bool submitting, bool declined, WizardEffect effect
});




}
/// @nodoc
class __$BookingWizardStateCopyWithImpl<$Res>
    implements _$BookingWizardStateCopyWith<$Res> {
  __$BookingWizardStateCopyWithImpl(this._self, this._then);

  final _BookingWizardState _self;
  final $Res Function(_BookingWizardState) _then;

/// Create a copy of BookingWizardState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? draft = null,Object? contact = null,Object? currentStep = null,Object? access = null,Object? maxPlayers = null,Object? booking = freezed,Object? submitting = null,Object? declined = null,Object? effect = null,}) {
  return _then(_BookingWizardState(
draft: null == draft ? _self.draft : draft // ignore: cast_nullable_to_non_nullable
as BookingDraft,contact: null == contact ? _self.contact : contact // ignore: cast_nullable_to_non_nullable
as ContactInfo,currentStep: null == currentStep ? _self.currentStep : currentStep // ignore: cast_nullable_to_non_nullable
as int,access: null == access ? _self.access : access // ignore: cast_nullable_to_non_nullable
as AccessPolicy,maxPlayers: null == maxPlayers ? _self.maxPlayers : maxPlayers // ignore: cast_nullable_to_non_nullable
as int,booking: freezed == booking ? _self.booking : booking // ignore: cast_nullable_to_non_nullable
as Booking?,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,declined: null == declined ? _self.declined : declined // ignore: cast_nullable_to_non_nullable
as bool,effect: null == effect ? _self.effect : effect // ignore: cast_nullable_to_non_nullable
as WizardEffect,
  ));
}


}

// dart format on
