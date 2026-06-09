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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( CourtScheduleOverviewLoading value)?  loading,TResult Function( CourtScheduleOverviewLoaded value)?  loaded,TResult Function( CourtScheduleOverviewFailure value)?  failure,required TResult orElse(),}){
final _that = this;
switch (_that) {
case CourtScheduleOverviewLoading() when loading != null:
return loading(_that);case CourtScheduleOverviewLoaded() when loaded != null:
return loaded(_that);case CourtScheduleOverviewFailure() when failure != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( CourtScheduleOverviewLoading value)  loading,required TResult Function( CourtScheduleOverviewLoaded value)  loaded,required TResult Function( CourtScheduleOverviewFailure value)  failure,}){
final _that = this;
switch (_that) {
case CourtScheduleOverviewLoading():
return loading(_that);case CourtScheduleOverviewLoaded():
return loaded(_that);case CourtScheduleOverviewFailure():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( CourtScheduleOverviewLoading value)?  loading,TResult? Function( CourtScheduleOverviewLoaded value)?  loaded,TResult? Function( CourtScheduleOverviewFailure value)?  failure,}){
final _that = this;
switch (_that) {
case CourtScheduleOverviewLoading() when loading != null:
return loading(_that);case CourtScheduleOverviewLoaded() when loaded != null:
return loaded(_that);case CourtScheduleOverviewFailure() when failure != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  loading,TResult Function( int selectedDateIndex,  Map<String, Set<String>> selectedByDate,  List<DateTime> dates,  List<int> hours,  List<ScheduleCourt> courts,  Map<String, Map<String, ScheduleSlot>> slotsByDate)?  loaded,TResult Function( String message,  StackTrace? stackTrace)?  failure,required TResult orElse(),}) {final _that = this;
switch (_that) {
case CourtScheduleOverviewLoading() when loading != null:
return loading();case CourtScheduleOverviewLoaded() when loaded != null:
return loaded(_that.selectedDateIndex,_that.selectedByDate,_that.dates,_that.hours,_that.courts,_that.slotsByDate);case CourtScheduleOverviewFailure() when failure != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  loading,required TResult Function( int selectedDateIndex,  Map<String, Set<String>> selectedByDate,  List<DateTime> dates,  List<int> hours,  List<ScheduleCourt> courts,  Map<String, Map<String, ScheduleSlot>> slotsByDate)  loaded,required TResult Function( String message,  StackTrace? stackTrace)  failure,}) {final _that = this;
switch (_that) {
case CourtScheduleOverviewLoading():
return loading();case CourtScheduleOverviewLoaded():
return loaded(_that.selectedDateIndex,_that.selectedByDate,_that.dates,_that.hours,_that.courts,_that.slotsByDate);case CourtScheduleOverviewFailure():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  loading,TResult? Function( int selectedDateIndex,  Map<String, Set<String>> selectedByDate,  List<DateTime> dates,  List<int> hours,  List<ScheduleCourt> courts,  Map<String, Map<String, ScheduleSlot>> slotsByDate)?  loaded,TResult? Function( String message,  StackTrace? stackTrace)?  failure,}) {final _that = this;
switch (_that) {
case CourtScheduleOverviewLoading() when loading != null:
return loading();case CourtScheduleOverviewLoaded() when loaded != null:
return loaded(_that.selectedDateIndex,_that.selectedByDate,_that.dates,_that.hours,_that.courts,_that.slotsByDate);case CourtScheduleOverviewFailure() when failure != null:
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
  const CourtScheduleOverviewLoaded({required this.selectedDateIndex, required final  Map<String, Set<String>> selectedByDate, required final  List<DateTime> dates, required final  List<int> hours, required final  List<ScheduleCourt> courts, required final  Map<String, Map<String, ScheduleSlot>> slotsByDate}): _selectedByDate = selectedByDate,_dates = dates,_hours = hours,_courts = courts,_slotsByDate = slotsByDate;
  

 final  int selectedDateIndex;
 final  Map<String, Set<String>> _selectedByDate;
 Map<String, Set<String>> get selectedByDate {
  if (_selectedByDate is EqualUnmodifiableMapView) return _selectedByDate;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_selectedByDate);
}

 final  List<DateTime> _dates;
 List<DateTime> get dates {
  if (_dates is EqualUnmodifiableListView) return _dates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_dates);
}

 final  List<int> _hours;
 List<int> get hours {
  if (_hours is EqualUnmodifiableListView) return _hours;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_hours);
}

 final  List<ScheduleCourt> _courts;
 List<ScheduleCourt> get courts {
  if (_courts is EqualUnmodifiableListView) return _courts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_courts);
}

 final  Map<String, Map<String, ScheduleSlot>> _slotsByDate;
 Map<String, Map<String, ScheduleSlot>> get slotsByDate {
  if (_slotsByDate is EqualUnmodifiableMapView) return _slotsByDate;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_slotsByDate);
}


/// Create a copy of CourtScheduleOverviewState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CourtScheduleOverviewLoadedCopyWith<CourtScheduleOverviewLoaded> get copyWith => _$CourtScheduleOverviewLoadedCopyWithImpl<CourtScheduleOverviewLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CourtScheduleOverviewLoaded&&(identical(other.selectedDateIndex, selectedDateIndex) || other.selectedDateIndex == selectedDateIndex)&&const DeepCollectionEquality().equals(other._selectedByDate, _selectedByDate)&&const DeepCollectionEquality().equals(other._dates, _dates)&&const DeepCollectionEquality().equals(other._hours, _hours)&&const DeepCollectionEquality().equals(other._courts, _courts)&&const DeepCollectionEquality().equals(other._slotsByDate, _slotsByDate));
}


@override
int get hashCode => Object.hash(runtimeType,selectedDateIndex,const DeepCollectionEquality().hash(_selectedByDate),const DeepCollectionEquality().hash(_dates),const DeepCollectionEquality().hash(_hours),const DeepCollectionEquality().hash(_courts),const DeepCollectionEquality().hash(_slotsByDate));

@override
String toString() {
  return 'CourtScheduleOverviewState.loaded(selectedDateIndex: $selectedDateIndex, selectedByDate: $selectedByDate, dates: $dates, hours: $hours, courts: $courts, slotsByDate: $slotsByDate)';
}


}

/// @nodoc
abstract mixin class $CourtScheduleOverviewLoadedCopyWith<$Res> implements $CourtScheduleOverviewStateCopyWith<$Res> {
  factory $CourtScheduleOverviewLoadedCopyWith(CourtScheduleOverviewLoaded value, $Res Function(CourtScheduleOverviewLoaded) _then) = _$CourtScheduleOverviewLoadedCopyWithImpl;
@useResult
$Res call({
 int selectedDateIndex, Map<String, Set<String>> selectedByDate, List<DateTime> dates, List<int> hours, List<ScheduleCourt> courts, Map<String, Map<String, ScheduleSlot>> slotsByDate
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
@pragma('vm:prefer-inline') $Res call({Object? selectedDateIndex = null,Object? selectedByDate = null,Object? dates = null,Object? hours = null,Object? courts = null,Object? slotsByDate = null,}) {
  return _then(CourtScheduleOverviewLoaded(
selectedDateIndex: null == selectedDateIndex ? _self.selectedDateIndex : selectedDateIndex // ignore: cast_nullable_to_non_nullable
as int,selectedByDate: null == selectedByDate ? _self._selectedByDate : selectedByDate // ignore: cast_nullable_to_non_nullable
as Map<String, Set<String>>,dates: null == dates ? _self._dates : dates // ignore: cast_nullable_to_non_nullable
as List<DateTime>,hours: null == hours ? _self._hours : hours // ignore: cast_nullable_to_non_nullable
as List<int>,courts: null == courts ? _self._courts : courts // ignore: cast_nullable_to_non_nullable
as List<ScheduleCourt>,slotsByDate: null == slotsByDate ? _self._slotsByDate : slotsByDate // ignore: cast_nullable_to_non_nullable
as Map<String, Map<String, ScheduleSlot>>,
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
