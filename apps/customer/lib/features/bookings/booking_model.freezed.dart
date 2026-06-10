// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'booking_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Court {

 String get id; String get name;@JsonKey(name: 'sport_types') List<String> get sportTypes;
/// Create a copy of Court
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CourtCopyWith<Court> get copyWith => _$CourtCopyWithImpl<Court>(this as Court, _$identity);

  /// Serializes this Court to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Court&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.sportTypes, sportTypes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(sportTypes));

@override
String toString() {
  return 'Court(id: $id, name: $name, sportTypes: $sportTypes)';
}


}

/// @nodoc
abstract mixin class $CourtCopyWith<$Res>  {
  factory $CourtCopyWith(Court value, $Res Function(Court) _then) = _$CourtCopyWithImpl;
@useResult
$Res call({
 String id, String name,@JsonKey(name: 'sport_types') List<String> sportTypes
});




}
/// @nodoc
class _$CourtCopyWithImpl<$Res>
    implements $CourtCopyWith<$Res> {
  _$CourtCopyWithImpl(this._self, this._then);

  final Court _self;
  final $Res Function(Court) _then;

/// Create a copy of Court
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? sportTypes = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,sportTypes: null == sportTypes ? _self.sportTypes : sportTypes // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [Court].
extension CourtPatterns on Court {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Court value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Court() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Court value)  $default,){
final _that = this;
switch (_that) {
case _Court():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Court value)?  $default,){
final _that = this;
switch (_that) {
case _Court() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(name: 'sport_types')  List<String> sportTypes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Court() when $default != null:
return $default(_that.id,_that.name,_that.sportTypes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(name: 'sport_types')  List<String> sportTypes)  $default,) {final _that = this;
switch (_that) {
case _Court():
return $default(_that.id,_that.name,_that.sportTypes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name, @JsonKey(name: 'sport_types')  List<String> sportTypes)?  $default,) {final _that = this;
switch (_that) {
case _Court() when $default != null:
return $default(_that.id,_that.name,_that.sportTypes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Court implements Court {
  const _Court({required this.id, required this.name, @JsonKey(name: 'sport_types') final  List<String> sportTypes = const <String>[]}): _sportTypes = sportTypes;
  factory _Court.fromJson(Map<String, dynamic> json) => _$CourtFromJson(json);

@override final  String id;
@override final  String name;
 final  List<String> _sportTypes;
@override@JsonKey(name: 'sport_types') List<String> get sportTypes {
  if (_sportTypes is EqualUnmodifiableListView) return _sportTypes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sportTypes);
}


/// Create a copy of Court
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CourtCopyWith<_Court> get copyWith => __$CourtCopyWithImpl<_Court>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CourtToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Court&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._sportTypes, _sportTypes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(_sportTypes));

@override
String toString() {
  return 'Court(id: $id, name: $name, sportTypes: $sportTypes)';
}


}

/// @nodoc
abstract mixin class _$CourtCopyWith<$Res> implements $CourtCopyWith<$Res> {
  factory _$CourtCopyWith(_Court value, $Res Function(_Court) _then) = __$CourtCopyWithImpl;
@override @useResult
$Res call({
 String id, String name,@JsonKey(name: 'sport_types') List<String> sportTypes
});




}
/// @nodoc
class __$CourtCopyWithImpl<$Res>
    implements _$CourtCopyWith<$Res> {
  __$CourtCopyWithImpl(this._self, this._then);

  final _Court _self;
  final $Res Function(_Court) _then;

/// Create a copy of Court
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? sportTypes = null,}) {
  return _then(_Court(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,sportTypes: null == sportTypes ? _self._sportTypes : sportTypes // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$Slot {

 String get id;@JsonKey(name: 'start_at') DateTime get startTime;@JsonKey(name: 'end_at') DateTime get endTime;@JsonKey(name: 'courts') Court get court;
/// Create a copy of Slot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SlotCopyWith<Slot> get copyWith => _$SlotCopyWithImpl<Slot>(this as Slot, _$identity);

  /// Serializes this Slot to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Slot&&(identical(other.id, id) || other.id == id)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.court, court) || other.court == court));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,startTime,endTime,court);

@override
String toString() {
  return 'Slot(id: $id, startTime: $startTime, endTime: $endTime, court: $court)';
}


}

/// @nodoc
abstract mixin class $SlotCopyWith<$Res>  {
  factory $SlotCopyWith(Slot value, $Res Function(Slot) _then) = _$SlotCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'start_at') DateTime startTime,@JsonKey(name: 'end_at') DateTime endTime,@JsonKey(name: 'courts') Court court
});


$CourtCopyWith<$Res> get court;

}
/// @nodoc
class _$SlotCopyWithImpl<$Res>
    implements $SlotCopyWith<$Res> {
  _$SlotCopyWithImpl(this._self, this._then);

  final Slot _self;
  final $Res Function(Slot) _then;

/// Create a copy of Slot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? startTime = null,Object? endTime = null,Object? court = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime,court: null == court ? _self.court : court // ignore: cast_nullable_to_non_nullable
as Court,
  ));
}
/// Create a copy of Slot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CourtCopyWith<$Res> get court {
  
  return $CourtCopyWith<$Res>(_self.court, (value) {
    return _then(_self.copyWith(court: value));
  });
}
}


/// Adds pattern-matching-related methods to [Slot].
extension SlotPatterns on Slot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Slot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Slot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Slot value)  $default,){
final _that = this;
switch (_that) {
case _Slot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Slot value)?  $default,){
final _that = this;
switch (_that) {
case _Slot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'start_at')  DateTime startTime, @JsonKey(name: 'end_at')  DateTime endTime, @JsonKey(name: 'courts')  Court court)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Slot() when $default != null:
return $default(_that.id,_that.startTime,_that.endTime,_that.court);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'start_at')  DateTime startTime, @JsonKey(name: 'end_at')  DateTime endTime, @JsonKey(name: 'courts')  Court court)  $default,) {final _that = this;
switch (_that) {
case _Slot():
return $default(_that.id,_that.startTime,_that.endTime,_that.court);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'start_at')  DateTime startTime, @JsonKey(name: 'end_at')  DateTime endTime, @JsonKey(name: 'courts')  Court court)?  $default,) {final _that = this;
switch (_that) {
case _Slot() when $default != null:
return $default(_that.id,_that.startTime,_that.endTime,_that.court);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Slot implements Slot {
  const _Slot({required this.id, @JsonKey(name: 'start_at') required this.startTime, @JsonKey(name: 'end_at') required this.endTime, @JsonKey(name: 'courts') required this.court});
  factory _Slot.fromJson(Map<String, dynamic> json) => _$SlotFromJson(json);

@override final  String id;
@override@JsonKey(name: 'start_at') final  DateTime startTime;
@override@JsonKey(name: 'end_at') final  DateTime endTime;
@override@JsonKey(name: 'courts') final  Court court;

/// Create a copy of Slot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SlotCopyWith<_Slot> get copyWith => __$SlotCopyWithImpl<_Slot>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SlotToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Slot&&(identical(other.id, id) || other.id == id)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.court, court) || other.court == court));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,startTime,endTime,court);

@override
String toString() {
  return 'Slot(id: $id, startTime: $startTime, endTime: $endTime, court: $court)';
}


}

/// @nodoc
abstract mixin class _$SlotCopyWith<$Res> implements $SlotCopyWith<$Res> {
  factory _$SlotCopyWith(_Slot value, $Res Function(_Slot) _then) = __$SlotCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'start_at') DateTime startTime,@JsonKey(name: 'end_at') DateTime endTime,@JsonKey(name: 'courts') Court court
});


@override $CourtCopyWith<$Res> get court;

}
/// @nodoc
class __$SlotCopyWithImpl<$Res>
    implements _$SlotCopyWith<$Res> {
  __$SlotCopyWithImpl(this._self, this._then);

  final _Slot _self;
  final $Res Function(_Slot) _then;

/// Create a copy of Slot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? startTime = null,Object? endTime = null,Object? court = null,}) {
  return _then(_Slot(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime,court: null == court ? _self.court : court // ignore: cast_nullable_to_non_nullable
as Court,
  ));
}

/// Create a copy of Slot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CourtCopyWith<$Res> get court {
  
  return $CourtCopyWith<$Res>(_self.court, (value) {
    return _then(_self.copyWith(court: value));
  });
}
}


/// @nodoc
mixin _$Booking {

 String get id; String get userId; String get status;@JsonKey(name: 'slots') Slot get slot; String get bookingType; int? get sessionNumber; int? get totalSessions; double? get totalPrice;
/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookingCopyWith<Booking> get copyWith => _$BookingCopyWithImpl<Booking>(this as Booking, _$identity);

  /// Serializes this Booking to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Booking&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.status, status) || other.status == status)&&(identical(other.slot, slot) || other.slot == slot)&&(identical(other.bookingType, bookingType) || other.bookingType == bookingType)&&(identical(other.sessionNumber, sessionNumber) || other.sessionNumber == sessionNumber)&&(identical(other.totalSessions, totalSessions) || other.totalSessions == totalSessions)&&(identical(other.totalPrice, totalPrice) || other.totalPrice == totalPrice));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,status,slot,bookingType,sessionNumber,totalSessions,totalPrice);

@override
String toString() {
  return 'Booking(id: $id, userId: $userId, status: $status, slot: $slot, bookingType: $bookingType, sessionNumber: $sessionNumber, totalSessions: $totalSessions, totalPrice: $totalPrice)';
}


}

/// @nodoc
abstract mixin class $BookingCopyWith<$Res>  {
  factory $BookingCopyWith(Booking value, $Res Function(Booking) _then) = _$BookingCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String status,@JsonKey(name: 'slots') Slot slot, String bookingType, int? sessionNumber, int? totalSessions, double? totalPrice
});


$SlotCopyWith<$Res> get slot;

}
/// @nodoc
class _$BookingCopyWithImpl<$Res>
    implements $BookingCopyWith<$Res> {
  _$BookingCopyWithImpl(this._self, this._then);

  final Booking _self;
  final $Res Function(Booking) _then;

/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? status = null,Object? slot = null,Object? bookingType = null,Object? sessionNumber = freezed,Object? totalSessions = freezed,Object? totalPrice = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,slot: null == slot ? _self.slot : slot // ignore: cast_nullable_to_non_nullable
as Slot,bookingType: null == bookingType ? _self.bookingType : bookingType // ignore: cast_nullable_to_non_nullable
as String,sessionNumber: freezed == sessionNumber ? _self.sessionNumber : sessionNumber // ignore: cast_nullable_to_non_nullable
as int?,totalSessions: freezed == totalSessions ? _self.totalSessions : totalSessions // ignore: cast_nullable_to_non_nullable
as int?,totalPrice: freezed == totalPrice ? _self.totalPrice : totalPrice // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}
/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SlotCopyWith<$Res> get slot {
  
  return $SlotCopyWith<$Res>(_self.slot, (value) {
    return _then(_self.copyWith(slot: value));
  });
}
}


/// Adds pattern-matching-related methods to [Booking].
extension BookingPatterns on Booking {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Booking value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Booking() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Booking value)  $default,){
final _that = this;
switch (_that) {
case _Booking():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Booking value)?  $default,){
final _that = this;
switch (_that) {
case _Booking() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String status, @JsonKey(name: 'slots')  Slot slot,  String bookingType,  int? sessionNumber,  int? totalSessions,  double? totalPrice)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Booking() when $default != null:
return $default(_that.id,_that.userId,_that.status,_that.slot,_that.bookingType,_that.sessionNumber,_that.totalSessions,_that.totalPrice);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String status, @JsonKey(name: 'slots')  Slot slot,  String bookingType,  int? sessionNumber,  int? totalSessions,  double? totalPrice)  $default,) {final _that = this;
switch (_that) {
case _Booking():
return $default(_that.id,_that.userId,_that.status,_that.slot,_that.bookingType,_that.sessionNumber,_that.totalSessions,_that.totalPrice);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String status, @JsonKey(name: 'slots')  Slot slot,  String bookingType,  int? sessionNumber,  int? totalSessions,  double? totalPrice)?  $default,) {final _that = this;
switch (_that) {
case _Booking() when $default != null:
return $default(_that.id,_that.userId,_that.status,_that.slot,_that.bookingType,_that.sessionNumber,_that.totalSessions,_that.totalPrice);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _Booking implements Booking {
  const _Booking({required this.id, required this.userId, required this.status, @JsonKey(name: 'slots') required this.slot, this.bookingType = 'one_off', this.sessionNumber, this.totalSessions, this.totalPrice});
  factory _Booking.fromJson(Map<String, dynamic> json) => _$BookingFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String status;
@override@JsonKey(name: 'slots') final  Slot slot;
@override@JsonKey() final  String bookingType;
@override final  int? sessionNumber;
@override final  int? totalSessions;
@override final  double? totalPrice;

/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookingCopyWith<_Booking> get copyWith => __$BookingCopyWithImpl<_Booking>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BookingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Booking&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.status, status) || other.status == status)&&(identical(other.slot, slot) || other.slot == slot)&&(identical(other.bookingType, bookingType) || other.bookingType == bookingType)&&(identical(other.sessionNumber, sessionNumber) || other.sessionNumber == sessionNumber)&&(identical(other.totalSessions, totalSessions) || other.totalSessions == totalSessions)&&(identical(other.totalPrice, totalPrice) || other.totalPrice == totalPrice));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,status,slot,bookingType,sessionNumber,totalSessions,totalPrice);

@override
String toString() {
  return 'Booking(id: $id, userId: $userId, status: $status, slot: $slot, bookingType: $bookingType, sessionNumber: $sessionNumber, totalSessions: $totalSessions, totalPrice: $totalPrice)';
}


}

/// @nodoc
abstract mixin class _$BookingCopyWith<$Res> implements $BookingCopyWith<$Res> {
  factory _$BookingCopyWith(_Booking value, $Res Function(_Booking) _then) = __$BookingCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String status,@JsonKey(name: 'slots') Slot slot, String bookingType, int? sessionNumber, int? totalSessions, double? totalPrice
});


@override $SlotCopyWith<$Res> get slot;

}
/// @nodoc
class __$BookingCopyWithImpl<$Res>
    implements _$BookingCopyWith<$Res> {
  __$BookingCopyWithImpl(this._self, this._then);

  final _Booking _self;
  final $Res Function(_Booking) _then;

/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? status = null,Object? slot = null,Object? bookingType = null,Object? sessionNumber = freezed,Object? totalSessions = freezed,Object? totalPrice = freezed,}) {
  return _then(_Booking(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,slot: null == slot ? _self.slot : slot // ignore: cast_nullable_to_non_nullable
as Slot,bookingType: null == bookingType ? _self.bookingType : bookingType // ignore: cast_nullable_to_non_nullable
as String,sessionNumber: freezed == sessionNumber ? _self.sessionNumber : sessionNumber // ignore: cast_nullable_to_non_nullable
as int?,totalSessions: freezed == totalSessions ? _self.totalSessions : totalSessions // ignore: cast_nullable_to_non_nullable
as int?,totalPrice: freezed == totalPrice ? _self.totalPrice : totalPrice // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SlotCopyWith<$Res> get slot {
  
  return $SlotCopyWith<$Res>(_self.slot, (value) {
    return _then(_self.copyWith(slot: value));
  });
}
}


/// @nodoc
mixin _$JoinedSlotRequest {

 String get id; String get status;// pending | approved | rejected
@JsonKey(name: 'slots') Slot get slot;@JsonKey(name: 'requested_at') DateTime? get requestedAt;
/// Create a copy of JoinedSlotRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JoinedSlotRequestCopyWith<JoinedSlotRequest> get copyWith => _$JoinedSlotRequestCopyWithImpl<JoinedSlotRequest>(this as JoinedSlotRequest, _$identity);

  /// Serializes this JoinedSlotRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JoinedSlotRequest&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.slot, slot) || other.slot == slot)&&(identical(other.requestedAt, requestedAt) || other.requestedAt == requestedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,status,slot,requestedAt);

@override
String toString() {
  return 'JoinedSlotRequest(id: $id, status: $status, slot: $slot, requestedAt: $requestedAt)';
}


}

/// @nodoc
abstract mixin class $JoinedSlotRequestCopyWith<$Res>  {
  factory $JoinedSlotRequestCopyWith(JoinedSlotRequest value, $Res Function(JoinedSlotRequest) _then) = _$JoinedSlotRequestCopyWithImpl;
@useResult
$Res call({
 String id, String status,@JsonKey(name: 'slots') Slot slot,@JsonKey(name: 'requested_at') DateTime? requestedAt
});


$SlotCopyWith<$Res> get slot;

}
/// @nodoc
class _$JoinedSlotRequestCopyWithImpl<$Res>
    implements $JoinedSlotRequestCopyWith<$Res> {
  _$JoinedSlotRequestCopyWithImpl(this._self, this._then);

  final JoinedSlotRequest _self;
  final $Res Function(JoinedSlotRequest) _then;

/// Create a copy of JoinedSlotRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? status = null,Object? slot = null,Object? requestedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,slot: null == slot ? _self.slot : slot // ignore: cast_nullable_to_non_nullable
as Slot,requestedAt: freezed == requestedAt ? _self.requestedAt : requestedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of JoinedSlotRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SlotCopyWith<$Res> get slot {
  
  return $SlotCopyWith<$Res>(_self.slot, (value) {
    return _then(_self.copyWith(slot: value));
  });
}
}


/// Adds pattern-matching-related methods to [JoinedSlotRequest].
extension JoinedSlotRequestPatterns on JoinedSlotRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _JoinedSlotRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _JoinedSlotRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _JoinedSlotRequest value)  $default,){
final _that = this;
switch (_that) {
case _JoinedSlotRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _JoinedSlotRequest value)?  $default,){
final _that = this;
switch (_that) {
case _JoinedSlotRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String status, @JsonKey(name: 'slots')  Slot slot, @JsonKey(name: 'requested_at')  DateTime? requestedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _JoinedSlotRequest() when $default != null:
return $default(_that.id,_that.status,_that.slot,_that.requestedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String status, @JsonKey(name: 'slots')  Slot slot, @JsonKey(name: 'requested_at')  DateTime? requestedAt)  $default,) {final _that = this;
switch (_that) {
case _JoinedSlotRequest():
return $default(_that.id,_that.status,_that.slot,_that.requestedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String status, @JsonKey(name: 'slots')  Slot slot, @JsonKey(name: 'requested_at')  DateTime? requestedAt)?  $default,) {final _that = this;
switch (_that) {
case _JoinedSlotRequest() when $default != null:
return $default(_that.id,_that.status,_that.slot,_that.requestedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _JoinedSlotRequest implements JoinedSlotRequest {
  const _JoinedSlotRequest({required this.id, required this.status, @JsonKey(name: 'slots') required this.slot, @JsonKey(name: 'requested_at') this.requestedAt});
  factory _JoinedSlotRequest.fromJson(Map<String, dynamic> json) => _$JoinedSlotRequestFromJson(json);

@override final  String id;
@override final  String status;
// pending | approved | rejected
@override@JsonKey(name: 'slots') final  Slot slot;
@override@JsonKey(name: 'requested_at') final  DateTime? requestedAt;

/// Create a copy of JoinedSlotRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$JoinedSlotRequestCopyWith<_JoinedSlotRequest> get copyWith => __$JoinedSlotRequestCopyWithImpl<_JoinedSlotRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$JoinedSlotRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _JoinedSlotRequest&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.slot, slot) || other.slot == slot)&&(identical(other.requestedAt, requestedAt) || other.requestedAt == requestedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,status,slot,requestedAt);

@override
String toString() {
  return 'JoinedSlotRequest(id: $id, status: $status, slot: $slot, requestedAt: $requestedAt)';
}


}

/// @nodoc
abstract mixin class _$JoinedSlotRequestCopyWith<$Res> implements $JoinedSlotRequestCopyWith<$Res> {
  factory _$JoinedSlotRequestCopyWith(_JoinedSlotRequest value, $Res Function(_JoinedSlotRequest) _then) = __$JoinedSlotRequestCopyWithImpl;
@override @useResult
$Res call({
 String id, String status,@JsonKey(name: 'slots') Slot slot,@JsonKey(name: 'requested_at') DateTime? requestedAt
});


@override $SlotCopyWith<$Res> get slot;

}
/// @nodoc
class __$JoinedSlotRequestCopyWithImpl<$Res>
    implements _$JoinedSlotRequestCopyWith<$Res> {
  __$JoinedSlotRequestCopyWithImpl(this._self, this._then);

  final _JoinedSlotRequest _self;
  final $Res Function(_JoinedSlotRequest) _then;

/// Create a copy of JoinedSlotRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? status = null,Object? slot = null,Object? requestedAt = freezed,}) {
  return _then(_JoinedSlotRequest(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,slot: null == slot ? _self.slot : slot // ignore: cast_nullable_to_non_nullable
as Slot,requestedAt: freezed == requestedAt ? _self.requestedAt : requestedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of JoinedSlotRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SlotCopyWith<$Res> get slot {
  
  return $SlotCopyWith<$Res>(_self.slot, (value) {
    return _then(_self.copyWith(slot: value));
  });
}
}

// dart format on
