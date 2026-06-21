// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'court_schedule_overview_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CourtScheduleOverviewState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CourtScheduleOverviewState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CourtScheduleOverviewState()';
}


}

/// @nodoc
class $CourtScheduleOverviewStateCopyWith<$Res>  {
$CourtScheduleOverviewStateCopyWith(CourtScheduleOverviewState _, $Res Function(CourtScheduleOverviewState) __);
}


/// Adds pattern-matching-related methods to [CourtScheduleOverviewState].
extension CourtScheduleOverviewStatePatterns on CourtScheduleOverviewState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( CourtScheduleOverviewLoading value)?  loading,TResult Function( CourtScheduleOverviewLoaded value)?  loaded,TResult Function( CourtScheduleOverviewBooked value)?  booked,TResult Function( CourtScheduleOverviewFailure value)?  failure,required TResult orElse(),}){
final _that = this;
switch (_that) {
case CourtScheduleOverviewLoading() when loading != null:
return loading(_that);case CourtScheduleOverviewLoaded() when loaded != null:
return loaded(_that);case CourtScheduleOverviewBooked() when booked != null:
return booked(_that);case CourtScheduleOverviewFailure() when failure != null:
return failure(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( CourtScheduleOverviewLoading value)  loading,required TResult Function( CourtScheduleOverviewLoaded value)  loaded,required TResult Function( CourtScheduleOverviewBooked value)  booked,required TResult Function( CourtScheduleOverviewFailure value)  failure,}){
final _that = this;
switch (_that) {
case CourtScheduleOverviewLoading():
return loading(_that);case CourtScheduleOverviewLoaded():
return loaded(_that);case CourtScheduleOverviewBooked():
return booked(_that);case CourtScheduleOverviewFailure():
return failure(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( CourtScheduleOverviewLoading value)?  loading,TResult? Function( CourtScheduleOverviewLoaded value)?  loaded,TResult? Function( CourtScheduleOverviewBooked value)?  booked,TResult? Function( CourtScheduleOverviewFailure value)?  failure,}){
final _that = this;
switch (_that) {
case CourtScheduleOverviewLoading() when loading != null:
return loading(_that);case CourtScheduleOverviewLoaded() when loaded != null:
return loaded(_that);case CourtScheduleOverviewBooked() when booked != null:
return booked(_that);case CourtScheduleOverviewFailure() when failure != null:
return failure(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  loading,TResult Function( List<DateTime> dates,  int selectedDateIndex,  List<ScheduleVenue> venues,  Set<String> selectedSlotIds,  bool submitting,  String? bookingError)?  loaded,TResult Function( List<String> bookingIds)?  booked,TResult Function( String message,  StackTrace? stackTrace)?  failure,required TResult orElse(),}) {final _that = this;
switch (_that) {
case CourtScheduleOverviewLoading() when loading != null:
return loading();case CourtScheduleOverviewLoaded() when loaded != null:
return loaded(_that.dates,_that.selectedDateIndex,_that.venues,_that.selectedSlotIds,_that.submitting,_that.bookingError);case CourtScheduleOverviewBooked() when booked != null:
return booked(_that.bookingIds);case CourtScheduleOverviewFailure() when failure != null:
return failure(_that.message,_that.stackTrace);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  loading,required TResult Function( List<DateTime> dates,  int selectedDateIndex,  List<ScheduleVenue> venues,  Set<String> selectedSlotIds,  bool submitting,  String? bookingError)  loaded,required TResult Function( List<String> bookingIds)  booked,required TResult Function( String message,  StackTrace? stackTrace)  failure,}) {final _that = this;
switch (_that) {
case CourtScheduleOverviewLoading():
return loading();case CourtScheduleOverviewLoaded():
return loaded(_that.dates,_that.selectedDateIndex,_that.venues,_that.selectedSlotIds,_that.submitting,_that.bookingError);case CourtScheduleOverviewBooked():
return booked(_that.bookingIds);case CourtScheduleOverviewFailure():
return failure(_that.message,_that.stackTrace);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  loading,TResult? Function( List<DateTime> dates,  int selectedDateIndex,  List<ScheduleVenue> venues,  Set<String> selectedSlotIds,  bool submitting,  String? bookingError)?  loaded,TResult? Function( List<String> bookingIds)?  booked,TResult? Function( String message,  StackTrace? stackTrace)?  failure,}) {final _that = this;
switch (_that) {
case CourtScheduleOverviewLoading() when loading != null:
return loading();case CourtScheduleOverviewLoaded() when loaded != null:
return loaded(_that.dates,_that.selectedDateIndex,_that.venues,_that.selectedSlotIds,_that.submitting,_that.bookingError);case CourtScheduleOverviewBooked() when booked != null:
return booked(_that.bookingIds);case CourtScheduleOverviewFailure() when failure != null:
return failure(_that.message,_that.stackTrace);case _:
  return null;

}
}

}

/// @nodoc


class CourtScheduleOverviewLoading implements CourtScheduleOverviewState {
  const CourtScheduleOverviewLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CourtScheduleOverviewLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CourtScheduleOverviewState.loading()';
}


}




/// @nodoc


class CourtScheduleOverviewLoaded implements CourtScheduleOverviewState {
  const CourtScheduleOverviewLoaded({required final  List<DateTime> dates, required this.selectedDateIndex, required final  List<ScheduleVenue> venues, required final  Set<String> selectedSlotIds, this.submitting = false, this.bookingError}): _dates = dates,_venues = venues,_selectedSlotIds = selectedSlotIds;
  

 final  List<DateTime> _dates;
 List<DateTime> get dates {
  if (_dates is EqualUnmodifiableListView) return _dates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_dates);
}

 final  int selectedDateIndex;
 final  List<ScheduleVenue> _venues;
 List<ScheduleVenue> get venues {
  if (_venues is EqualUnmodifiableListView) return _venues;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_venues);
}

 final  Set<String> _selectedSlotIds;
 Set<String> get selectedSlotIds {
  if (_selectedSlotIds is EqualUnmodifiableSetView) return _selectedSlotIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_selectedSlotIds);
}

@JsonKey() final  bool submitting;
 final  String? bookingError;

/// Create a copy of CourtScheduleOverviewState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CourtScheduleOverviewLoadedCopyWith<CourtScheduleOverviewLoaded> get copyWith => _$CourtScheduleOverviewLoadedCopyWithImpl<CourtScheduleOverviewLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CourtScheduleOverviewLoaded&&const DeepCollectionEquality().equals(other._dates, _dates)&&(identical(other.selectedDateIndex, selectedDateIndex) || other.selectedDateIndex == selectedDateIndex)&&const DeepCollectionEquality().equals(other._venues, _venues)&&const DeepCollectionEquality().equals(other._selectedSlotIds, _selectedSlotIds)&&(identical(other.submitting, submitting) || other.submitting == submitting)&&(identical(other.bookingError, bookingError) || other.bookingError == bookingError));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_dates),selectedDateIndex,const DeepCollectionEquality().hash(_venues),const DeepCollectionEquality().hash(_selectedSlotIds),submitting,bookingError);

@override
String toString() {
  return 'CourtScheduleOverviewState.loaded(dates: $dates, selectedDateIndex: $selectedDateIndex, venues: $venues, selectedSlotIds: $selectedSlotIds, submitting: $submitting, bookingError: $bookingError)';
}


}

/// @nodoc
abstract mixin class $CourtScheduleOverviewLoadedCopyWith<$Res> implements $CourtScheduleOverviewStateCopyWith<$Res> {
  factory $CourtScheduleOverviewLoadedCopyWith(CourtScheduleOverviewLoaded value, $Res Function(CourtScheduleOverviewLoaded) _then) = _$CourtScheduleOverviewLoadedCopyWithImpl;
@useResult
$Res call({
 List<DateTime> dates, int selectedDateIndex, List<ScheduleVenue> venues, Set<String> selectedSlotIds, bool submitting, String? bookingError
});




}
/// @nodoc
class _$CourtScheduleOverviewLoadedCopyWithImpl<$Res>
    implements $CourtScheduleOverviewLoadedCopyWith<$Res> {
  _$CourtScheduleOverviewLoadedCopyWithImpl(this._self, this._then);

  final CourtScheduleOverviewLoaded _self;
  final $Res Function(CourtScheduleOverviewLoaded) _then;

/// Create a copy of CourtScheduleOverviewState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? dates = null,Object? selectedDateIndex = null,Object? venues = null,Object? selectedSlotIds = null,Object? submitting = null,Object? bookingError = freezed,}) {
  return _then(CourtScheduleOverviewLoaded(
dates: null == dates ? _self._dates : dates // ignore: cast_nullable_to_non_nullable
as List<DateTime>,selectedDateIndex: null == selectedDateIndex ? _self.selectedDateIndex : selectedDateIndex // ignore: cast_nullable_to_non_nullable
as int,venues: null == venues ? _self._venues : venues // ignore: cast_nullable_to_non_nullable
as List<ScheduleVenue>,selectedSlotIds: null == selectedSlotIds ? _self._selectedSlotIds : selectedSlotIds // ignore: cast_nullable_to_non_nullable
as Set<String>,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,bookingError: freezed == bookingError ? _self.bookingError : bookingError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class CourtScheduleOverviewBooked implements CourtScheduleOverviewState {
  const CourtScheduleOverviewBooked({required final  List<String> bookingIds}): _bookingIds = bookingIds;
  

 final  List<String> _bookingIds;
 List<String> get bookingIds {
  if (_bookingIds is EqualUnmodifiableListView) return _bookingIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bookingIds);
}


/// Create a copy of CourtScheduleOverviewState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CourtScheduleOverviewBookedCopyWith<CourtScheduleOverviewBooked> get copyWith => _$CourtScheduleOverviewBookedCopyWithImpl<CourtScheduleOverviewBooked>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CourtScheduleOverviewBooked&&const DeepCollectionEquality().equals(other._bookingIds, _bookingIds));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_bookingIds));

@override
String toString() {
  return 'CourtScheduleOverviewState.booked(bookingIds: $bookingIds)';
}


}

/// @nodoc
abstract mixin class $CourtScheduleOverviewBookedCopyWith<$Res> implements $CourtScheduleOverviewStateCopyWith<$Res> {
  factory $CourtScheduleOverviewBookedCopyWith(CourtScheduleOverviewBooked value, $Res Function(CourtScheduleOverviewBooked) _then) = _$CourtScheduleOverviewBookedCopyWithImpl;
@useResult
$Res call({
 List<String> bookingIds
});




}
/// @nodoc
class _$CourtScheduleOverviewBookedCopyWithImpl<$Res>
    implements $CourtScheduleOverviewBookedCopyWith<$Res> {
  _$CourtScheduleOverviewBookedCopyWithImpl(this._self, this._then);

  final CourtScheduleOverviewBooked _self;
  final $Res Function(CourtScheduleOverviewBooked) _then;

/// Create a copy of CourtScheduleOverviewState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? bookingIds = null,}) {
  return _then(CourtScheduleOverviewBooked(
bookingIds: null == bookingIds ? _self._bookingIds : bookingIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc


class CourtScheduleOverviewFailure with AppExceptionMixin implements CourtScheduleOverviewState {
  const CourtScheduleOverviewFailure(this.message, {this.stackTrace});
  

 final  String message;
 final  StackTrace? stackTrace;

/// Create a copy of CourtScheduleOverviewState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CourtScheduleOverviewFailureCopyWith<CourtScheduleOverviewFailure> get copyWith => _$CourtScheduleOverviewFailureCopyWithImpl<CourtScheduleOverviewFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CourtScheduleOverviewFailure&&(identical(other.message, message) || other.message == message)&&(identical(other.stackTrace, stackTrace) || other.stackTrace == stackTrace));
}


@override
int get hashCode => Object.hash(runtimeType,message,stackTrace);

@override
String toString() {
  return 'CourtScheduleOverviewState.failure(message: $message, stackTrace: $stackTrace)';
}


}

/// @nodoc
abstract mixin class $CourtScheduleOverviewFailureCopyWith<$Res> implements $CourtScheduleOverviewStateCopyWith<$Res> {
  factory $CourtScheduleOverviewFailureCopyWith(CourtScheduleOverviewFailure value, $Res Function(CourtScheduleOverviewFailure) _then) = _$CourtScheduleOverviewFailureCopyWithImpl;
@useResult
$Res call({
 String message, StackTrace? stackTrace
});




}
/// @nodoc
class _$CourtScheduleOverviewFailureCopyWithImpl<$Res>
    implements $CourtScheduleOverviewFailureCopyWith<$Res> {
  _$CourtScheduleOverviewFailureCopyWithImpl(this._self, this._then);

  final CourtScheduleOverviewFailure _self;
  final $Res Function(CourtScheduleOverviewFailure) _then;

/// Create a copy of CourtScheduleOverviewState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,Object? stackTrace = freezed,}) {
  return _then(CourtScheduleOverviewFailure(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,stackTrace: freezed == stackTrace ? _self.stackTrace : stackTrace // ignore: cast_nullable_to_non_nullable
as StackTrace?,
  ));
}


}

// dart format on
