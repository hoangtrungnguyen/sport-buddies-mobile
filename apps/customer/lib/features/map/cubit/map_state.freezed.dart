// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'map_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MapState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MapState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MapState()';
}


}

/// @nodoc
class $MapStateCopyWith<$Res>  {
$MapStateCopyWith(MapState _, $Res Function(MapState) __);
}


/// Adds pattern-matching-related methods to [MapState].
extension MapStatePatterns on MapState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( MapInitial value)?  initial,TResult Function( MapLoading value)?  loading,TResult Function( MapLoaded value)?  loaded,TResult Function( MapError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case MapInitial() when initial != null:
return initial(_that);case MapLoading() when loading != null:
return loading(_that);case MapLoaded() when loaded != null:
return loaded(_that);case MapError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( MapInitial value)  initial,required TResult Function( MapLoading value)  loading,required TResult Function( MapLoaded value)  loaded,required TResult Function( MapError value)  error,}){
final _that = this;
switch (_that) {
case MapInitial():
return initial(_that);case MapLoading():
return loading(_that);case MapLoaded():
return loaded(_that);case MapError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( MapInitial value)?  initial,TResult? Function( MapLoading value)?  loading,TResult? Function( MapLoaded value)?  loaded,TResult? Function( MapError value)?  error,}){
final _that = this;
switch (_that) {
case MapInitial() when initial != null:
return initial(_that);case MapLoading() when loading != null:
return loading(_that);case MapLoaded() when loaded != null:
return loaded(_that);case MapError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( List<CourtAvailability> courts,  CourtAvailability? selectedCourt)?  loaded,TResult Function( String message,  StackTrace? stackTrace)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case MapInitial() when initial != null:
return initial();case MapLoading() when loading != null:
return loading();case MapLoaded() when loaded != null:
return loaded(_that.courts,_that.selectedCourt);case MapError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( List<CourtAvailability> courts,  CourtAvailability? selectedCourt)  loaded,required TResult Function( String message,  StackTrace? stackTrace)  error,}) {final _that = this;
switch (_that) {
case MapInitial():
return initial();case MapLoading():
return loading();case MapLoaded():
return loaded(_that.courts,_that.selectedCourt);case MapError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( List<CourtAvailability> courts,  CourtAvailability? selectedCourt)?  loaded,TResult? Function( String message,  StackTrace? stackTrace)?  error,}) {final _that = this;
switch (_that) {
case MapInitial() when initial != null:
return initial();case MapLoading() when loading != null:
return loading();case MapLoaded() when loaded != null:
return loaded(_that.courts,_that.selectedCourt);case MapError() when error != null:
return error(_that.message,_that.stackTrace);case _:
  return null;

}
}

}

/// @nodoc


class MapInitial implements MapState {
  const MapInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MapInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MapState.initial()';
}


}




/// @nodoc


class MapLoading implements MapState {
  const MapLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MapLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MapState.loading()';
}


}




/// @nodoc


class MapLoaded implements MapState {
  const MapLoaded(final  List<CourtAvailability> courts, {this.selectedCourt}): _courts = courts;
  

 final  List<CourtAvailability> _courts;
 List<CourtAvailability> get courts {
  if (_courts is EqualUnmodifiableListView) return _courts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_courts);
}

 final  CourtAvailability? selectedCourt;

/// Create a copy of MapState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MapLoadedCopyWith<MapLoaded> get copyWith => _$MapLoadedCopyWithImpl<MapLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MapLoaded&&const DeepCollectionEquality().equals(other._courts, _courts)&&(identical(other.selectedCourt, selectedCourt) || other.selectedCourt == selectedCourt));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_courts),selectedCourt);

@override
String toString() {
  return 'MapState.loaded(courts: $courts, selectedCourt: $selectedCourt)';
}


}

/// @nodoc
abstract mixin class $MapLoadedCopyWith<$Res> implements $MapStateCopyWith<$Res> {
  factory $MapLoadedCopyWith(MapLoaded value, $Res Function(MapLoaded) _then) = _$MapLoadedCopyWithImpl;
@useResult
$Res call({
 List<CourtAvailability> courts, CourtAvailability? selectedCourt
});


$CourtAvailabilityCopyWith<$Res>? get selectedCourt;

}
/// @nodoc
class _$MapLoadedCopyWithImpl<$Res>
    implements $MapLoadedCopyWith<$Res> {
  _$MapLoadedCopyWithImpl(this._self, this._then);

  final MapLoaded _self;
  final $Res Function(MapLoaded) _then;

/// Create a copy of MapState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? courts = null,Object? selectedCourt = freezed,}) {
  return _then(MapLoaded(
null == courts ? _self._courts : courts // ignore: cast_nullable_to_non_nullable
as List<CourtAvailability>,selectedCourt: freezed == selectedCourt ? _self.selectedCourt : selectedCourt // ignore: cast_nullable_to_non_nullable
as CourtAvailability?,
  ));
}

/// Create a copy of MapState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CourtAvailabilityCopyWith<$Res>? get selectedCourt {
    if (_self.selectedCourt == null) {
    return null;
  }

  return $CourtAvailabilityCopyWith<$Res>(_self.selectedCourt!, (value) {
    return _then(_self.copyWith(selectedCourt: value));
  });
}
}

/// @nodoc


class MapError with AppExceptionMixin implements MapState {
  const MapError(this.message, {this.stackTrace});
  

 final  String message;
 final  StackTrace? stackTrace;

/// Create a copy of MapState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MapErrorCopyWith<MapError> get copyWith => _$MapErrorCopyWithImpl<MapError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MapError&&(identical(other.message, message) || other.message == message)&&(identical(other.stackTrace, stackTrace) || other.stackTrace == stackTrace));
}


@override
int get hashCode => Object.hash(runtimeType,message,stackTrace);

@override
String toString() {
  return 'MapState.error(message: $message, stackTrace: $stackTrace)';
}


}

/// @nodoc
abstract mixin class $MapErrorCopyWith<$Res> implements $MapStateCopyWith<$Res> {
  factory $MapErrorCopyWith(MapError value, $Res Function(MapError) _then) = _$MapErrorCopyWithImpl;
@useResult
$Res call({
 String message, StackTrace? stackTrace
});




}
/// @nodoc
class _$MapErrorCopyWithImpl<$Res>
    implements $MapErrorCopyWith<$Res> {
  _$MapErrorCopyWithImpl(this._self, this._then);

  final MapError _self;
  final $Res Function(MapError) _then;

/// Create a copy of MapState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,Object? stackTrace = freezed,}) {
  return _then(MapError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,stackTrace: freezed == stackTrace ? _self.stackTrace : stackTrace // ignore: cast_nullable_to_non_nullable
as StackTrace?,
  ));
}


}

// dart format on
