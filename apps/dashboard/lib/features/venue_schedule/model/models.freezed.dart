// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ScheduleCourt {
  String get id;
  String get name;

  /// Create a copy of ScheduleCourt
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ScheduleCourtCopyWith<ScheduleCourt> get copyWith =>
      _$ScheduleCourtCopyWithImpl<ScheduleCourt>(
          this as ScheduleCourt, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ScheduleCourt &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, name);

  @override
  String toString() {
    return 'ScheduleCourt(id: $id, name: $name)';
  }
}

/// @nodoc
abstract mixin class $ScheduleCourtCopyWith<$Res> {
  factory $ScheduleCourtCopyWith(
          ScheduleCourt value, $Res Function(ScheduleCourt) _then) =
      _$ScheduleCourtCopyWithImpl;
  @useResult
  $Res call({String id, String name});
}

/// @nodoc
class _$ScheduleCourtCopyWithImpl<$Res>
    implements $ScheduleCourtCopyWith<$Res> {
  _$ScheduleCourtCopyWithImpl(this._self, this._then);

  final ScheduleCourt _self;
  final $Res Function(ScheduleCourt) _then;

  /// Create a copy of ScheduleCourt
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [ScheduleCourt].
extension ScheduleCourtPatterns on ScheduleCourt {
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
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ScheduleCourt value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ScheduleCourt() when $default != null:
        return $default(_that);
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
  TResult map<TResult extends Object?>(
    TResult Function(_ScheduleCourt value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ScheduleCourt():
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ScheduleCourt value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ScheduleCourt() when $default != null:
        return $default(_that);
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
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(String id, String name)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ScheduleCourt() when $default != null:
        return $default(_that.id, _that.name);
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
  TResult when<TResult extends Object?>(
    TResult Function(String id, String name) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ScheduleCourt():
        return $default(_that.id, _that.name);
      case _:
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

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(String id, String name)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ScheduleCourt() when $default != null:
        return $default(_that.id, _that.name);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _ScheduleCourt implements ScheduleCourt {
  const _ScheduleCourt({required this.id, required this.name});

  @override
  final String id;
  @override
  final String name;

  /// Create a copy of ScheduleCourt
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ScheduleCourtCopyWith<_ScheduleCourt> get copyWith =>
      __$ScheduleCourtCopyWithImpl<_ScheduleCourt>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ScheduleCourt &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, name);

  @override
  String toString() {
    return 'ScheduleCourt(id: $id, name: $name)';
  }
}

/// @nodoc
abstract mixin class _$ScheduleCourtCopyWith<$Res>
    implements $ScheduleCourtCopyWith<$Res> {
  factory _$ScheduleCourtCopyWith(
          _ScheduleCourt value, $Res Function(_ScheduleCourt) _then) =
      __$ScheduleCourtCopyWithImpl;
  @override
  @useResult
  $Res call({String id, String name});
}

/// @nodoc
class __$ScheduleCourtCopyWithImpl<$Res>
    implements _$ScheduleCourtCopyWith<$Res> {
  __$ScheduleCourtCopyWithImpl(this._self, this._then);

  final _ScheduleCourt _self;
  final $Res Function(_ScheduleCourt) _then;

  /// Create a copy of ScheduleCourt
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? name = null,
  }) {
    return _then(_ScheduleCourt(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
mixin _$Venue {
  String get id;

  /// "Sân 1"
  String get name;

  /// "S1"
  String get shortCode;
  SportType get sport;

  /// Display string, e.g. "Bóng đá 5v5".
  String get sportLabel;

  /// Venue dot colour as an ARGB int (see handoff venue palette).
  int get colorValue;

  /// VND.
  int get pricePerHour;

  /// Daily operating window start (24h), from `courts.operating_hours`.
  /// Null when the court has no parseable operating hours — consumers
  /// apply their own fallback instead of treating a guess as real data.
  int? get openHour;

  /// Daily operating window end (24h) — see [openHour].
  int? get closeHour;

  /// Create a copy of Venue
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $VenueCopyWith<Venue> get copyWith =>
      _$VenueCopyWithImpl<Venue>(this as Venue, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Venue &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.shortCode, shortCode) ||
                other.shortCode == shortCode) &&
            (identical(other.sport, sport) || other.sport == sport) &&
            (identical(other.sportLabel, sportLabel) ||
                other.sportLabel == sportLabel) &&
            (identical(other.colorValue, colorValue) ||
                other.colorValue == colorValue) &&
            (identical(other.pricePerHour, pricePerHour) ||
                other.pricePerHour == pricePerHour) &&
            (identical(other.openHour, openHour) ||
                other.openHour == openHour) &&
            (identical(other.closeHour, closeHour) ||
                other.closeHour == closeHour));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, name, shortCode, sport,
      sportLabel, colorValue, pricePerHour, openHour, closeHour);

  @override
  String toString() {
    return 'Venue(id: $id, name: $name, shortCode: $shortCode, sport: $sport, sportLabel: $sportLabel, colorValue: $colorValue, pricePerHour: $pricePerHour, openHour: $openHour, closeHour: $closeHour)';
  }
}

/// @nodoc
abstract mixin class $VenueCopyWith<$Res> {
  factory $VenueCopyWith(Venue value, $Res Function(Venue) _then) =
      _$VenueCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String name,
      String shortCode,
      SportType sport,
      String sportLabel,
      int colorValue,
      int pricePerHour,
      int? openHour,
      int? closeHour});
}

/// @nodoc
class _$VenueCopyWithImpl<$Res> implements $VenueCopyWith<$Res> {
  _$VenueCopyWithImpl(this._self, this._then);

  final Venue _self;
  final $Res Function(Venue) _then;

  /// Create a copy of Venue
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? shortCode = null,
    Object? sport = null,
    Object? sportLabel = null,
    Object? colorValue = null,
    Object? pricePerHour = null,
    Object? openHour = freezed,
    Object? closeHour = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      shortCode: null == shortCode
          ? _self.shortCode
          : shortCode // ignore: cast_nullable_to_non_nullable
              as String,
      sport: null == sport
          ? _self.sport
          : sport // ignore: cast_nullable_to_non_nullable
              as SportType,
      sportLabel: null == sportLabel
          ? _self.sportLabel
          : sportLabel // ignore: cast_nullable_to_non_nullable
              as String,
      colorValue: null == colorValue
          ? _self.colorValue
          : colorValue // ignore: cast_nullable_to_non_nullable
              as int,
      pricePerHour: null == pricePerHour
          ? _self.pricePerHour
          : pricePerHour // ignore: cast_nullable_to_non_nullable
              as int,
      openHour: freezed == openHour
          ? _self.openHour
          : openHour // ignore: cast_nullable_to_non_nullable
              as int?,
      closeHour: freezed == closeHour
          ? _self.closeHour
          : closeHour // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// Adds pattern-matching-related methods to [Venue].
extension VenuePatterns on Venue {
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
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_Venue value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Venue() when $default != null:
        return $default(_that);
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
  TResult map<TResult extends Object?>(
    TResult Function(_Venue value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Venue():
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_Venue value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Venue() when $default != null:
        return $default(_that);
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
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String id,
            String name,
            String shortCode,
            SportType sport,
            String sportLabel,
            int colorValue,
            int pricePerHour,
            int? openHour,
            int? closeHour)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Venue() when $default != null:
        return $default(
            _that.id,
            _that.name,
            _that.shortCode,
            _that.sport,
            _that.sportLabel,
            _that.colorValue,
            _that.pricePerHour,
            _that.openHour,
            _that.closeHour);
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
  TResult when<TResult extends Object?>(
    TResult Function(
            String id,
            String name,
            String shortCode,
            SportType sport,
            String sportLabel,
            int colorValue,
            int pricePerHour,
            int? openHour,
            int? closeHour)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Venue():
        return $default(
            _that.id,
            _that.name,
            _that.shortCode,
            _that.sport,
            _that.sportLabel,
            _that.colorValue,
            _that.pricePerHour,
            _that.openHour,
            _that.closeHour);
      case _:
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

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String id,
            String name,
            String shortCode,
            SportType sport,
            String sportLabel,
            int colorValue,
            int pricePerHour,
            int? openHour,
            int? closeHour)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Venue() when $default != null:
        return $default(
            _that.id,
            _that.name,
            _that.shortCode,
            _that.sport,
            _that.sportLabel,
            _that.colorValue,
            _that.pricePerHour,
            _that.openHour,
            _that.closeHour);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Venue implements Venue {
  const _Venue(
      {required this.id,
      required this.name,
      required this.shortCode,
      required this.sport,
      required this.sportLabel,
      required this.colorValue,
      required this.pricePerHour,
      this.openHour,
      this.closeHour});

  @override
  final String id;

  /// "Sân 1"
  @override
  final String name;

  /// "S1"
  @override
  final String shortCode;
  @override
  final SportType sport;

  /// Display string, e.g. "Bóng đá 5v5".
  @override
  final String sportLabel;

  /// Venue dot colour as an ARGB int (see handoff venue palette).
  @override
  final int colorValue;

  /// VND.
  @override
  final int pricePerHour;

  /// Daily operating window start (24h), from `courts.operating_hours`.
  /// Null when the court has no parseable operating hours — consumers
  /// apply their own fallback instead of treating a guess as real data.
  @override
  final int? openHour;

  /// Daily operating window end (24h) — see [openHour].
  @override
  final int? closeHour;

  /// Create a copy of Venue
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$VenueCopyWith<_Venue> get copyWith =>
      __$VenueCopyWithImpl<_Venue>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Venue &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.shortCode, shortCode) ||
                other.shortCode == shortCode) &&
            (identical(other.sport, sport) || other.sport == sport) &&
            (identical(other.sportLabel, sportLabel) ||
                other.sportLabel == sportLabel) &&
            (identical(other.colorValue, colorValue) ||
                other.colorValue == colorValue) &&
            (identical(other.pricePerHour, pricePerHour) ||
                other.pricePerHour == pricePerHour) &&
            (identical(other.openHour, openHour) ||
                other.openHour == openHour) &&
            (identical(other.closeHour, closeHour) ||
                other.closeHour == closeHour));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, name, shortCode, sport,
      sportLabel, colorValue, pricePerHour, openHour, closeHour);

  @override
  String toString() {
    return 'Venue(id: $id, name: $name, shortCode: $shortCode, sport: $sport, sportLabel: $sportLabel, colorValue: $colorValue, pricePerHour: $pricePerHour, openHour: $openHour, closeHour: $closeHour)';
  }
}

/// @nodoc
abstract mixin class _$VenueCopyWith<$Res> implements $VenueCopyWith<$Res> {
  factory _$VenueCopyWith(_Venue value, $Res Function(_Venue) _then) =
      __$VenueCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String shortCode,
      SportType sport,
      String sportLabel,
      int colorValue,
      int pricePerHour,
      int? openHour,
      int? closeHour});
}

/// @nodoc
class __$VenueCopyWithImpl<$Res> implements _$VenueCopyWith<$Res> {
  __$VenueCopyWithImpl(this._self, this._then);

  final _Venue _self;
  final $Res Function(_Venue) _then;

  /// Create a copy of Venue
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? shortCode = null,
    Object? sport = null,
    Object? sportLabel = null,
    Object? colorValue = null,
    Object? pricePerHour = null,
    Object? openHour = freezed,
    Object? closeHour = freezed,
  }) {
    return _then(_Venue(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      shortCode: null == shortCode
          ? _self.shortCode
          : shortCode // ignore: cast_nullable_to_non_nullable
              as String,
      sport: null == sport
          ? _self.sport
          : sport // ignore: cast_nullable_to_non_nullable
              as SportType,
      sportLabel: null == sportLabel
          ? _self.sportLabel
          : sportLabel // ignore: cast_nullable_to_non_nullable
              as String,
      colorValue: null == colorValue
          ? _self.colorValue
          : colorValue // ignore: cast_nullable_to_non_nullable
              as int,
      pricePerHour: null == pricePerHour
          ? _self.pricePerHour
          : pricePerHour // ignore: cast_nullable_to_non_nullable
              as int,
      openHour: freezed == openHour
          ? _self.openHour
          : openHour // ignore: cast_nullable_to_non_nullable
              as int?,
      closeHour: freezed == closeHour
          ? _self.closeHour
          : closeHour // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
mixin _$Slot {
  String get id;
  String get venueId;
  SlotState get state;

  /// 24h decimal hour, `.5` = `:30` — e.g. 18.0, 19.5.
  double get startHour;

  /// e.g. 1.5.
  double get durationHours;

  /// Day this slot belongs to (Day/Week views).
  DateTime? get date;

  /// 0 = Mon … 6 = Sun (Week view positioning).
  int? get weekday;

  /// Customer/team name OR "Slot trống"/"Bảo trì".
  String get label;

  /// "Cố định T3·T5", "Đang ghép đội", etc.
  String? get subtitle;

  /// Joined count (open/booked group slots).
  int? get players;

  /// Max players.
  int? get capacity;

  /// VND for this slot.
  int? get price;
  PaymentStatus? get payment;

  /// "SPB-060149".
  String? get bookingCode;

  /// Create a copy of Slot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SlotCopyWith<Slot> get copyWith =>
      _$SlotCopyWithImpl<Slot>(this as Slot, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Slot &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.venueId, venueId) || other.venueId == venueId) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.startHour, startHour) ||
                other.startHour == startHour) &&
            (identical(other.durationHours, durationHours) ||
                other.durationHours == durationHours) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.weekday, weekday) || other.weekday == weekday) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.subtitle, subtitle) ||
                other.subtitle == subtitle) &&
            (identical(other.players, players) || other.players == players) &&
            (identical(other.capacity, capacity) ||
                other.capacity == capacity) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.payment, payment) || other.payment == payment) &&
            (identical(other.bookingCode, bookingCode) ||
                other.bookingCode == bookingCode));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      venueId,
      state,
      startHour,
      durationHours,
      date,
      weekday,
      label,
      subtitle,
      players,
      capacity,
      price,
      payment,
      bookingCode);

  @override
  String toString() {
    return 'Slot(id: $id, venueId: $venueId, state: $state, startHour: $startHour, durationHours: $durationHours, date: $date, weekday: $weekday, label: $label, subtitle: $subtitle, players: $players, capacity: $capacity, price: $price, payment: $payment, bookingCode: $bookingCode)';
  }
}

/// @nodoc
abstract mixin class $SlotCopyWith<$Res> {
  factory $SlotCopyWith(Slot value, $Res Function(Slot) _then) =
      _$SlotCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String venueId,
      SlotState state,
      double startHour,
      double durationHours,
      DateTime? date,
      int? weekday,
      String label,
      String? subtitle,
      int? players,
      int? capacity,
      int? price,
      PaymentStatus? payment,
      String? bookingCode});
}

/// @nodoc
class _$SlotCopyWithImpl<$Res> implements $SlotCopyWith<$Res> {
  _$SlotCopyWithImpl(this._self, this._then);

  final Slot _self;
  final $Res Function(Slot) _then;

  /// Create a copy of Slot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? venueId = null,
    Object? state = null,
    Object? startHour = null,
    Object? durationHours = null,
    Object? date = freezed,
    Object? weekday = freezed,
    Object? label = null,
    Object? subtitle = freezed,
    Object? players = freezed,
    Object? capacity = freezed,
    Object? price = freezed,
    Object? payment = freezed,
    Object? bookingCode = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      venueId: null == venueId
          ? _self.venueId
          : venueId // ignore: cast_nullable_to_non_nullable
              as String,
      state: null == state
          ? _self.state
          : state // ignore: cast_nullable_to_non_nullable
              as SlotState,
      startHour: null == startHour
          ? _self.startHour
          : startHour // ignore: cast_nullable_to_non_nullable
              as double,
      durationHours: null == durationHours
          ? _self.durationHours
          : durationHours // ignore: cast_nullable_to_non_nullable
              as double,
      date: freezed == date
          ? _self.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      weekday: freezed == weekday
          ? _self.weekday
          : weekday // ignore: cast_nullable_to_non_nullable
              as int?,
      label: null == label
          ? _self.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      subtitle: freezed == subtitle
          ? _self.subtitle
          : subtitle // ignore: cast_nullable_to_non_nullable
              as String?,
      players: freezed == players
          ? _self.players
          : players // ignore: cast_nullable_to_non_nullable
              as int?,
      capacity: freezed == capacity
          ? _self.capacity
          : capacity // ignore: cast_nullable_to_non_nullable
              as int?,
      price: freezed == price
          ? _self.price
          : price // ignore: cast_nullable_to_non_nullable
              as int?,
      payment: freezed == payment
          ? _self.payment
          : payment // ignore: cast_nullable_to_non_nullable
              as PaymentStatus?,
      bookingCode: freezed == bookingCode
          ? _self.bookingCode
          : bookingCode // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
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

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_Slot value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Slot() when $default != null:
        return $default(_that);
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
  TResult map<TResult extends Object?>(
    TResult Function(_Slot value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Slot():
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_Slot value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Slot() when $default != null:
        return $default(_that);
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
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String id,
            String venueId,
            SlotState state,
            double startHour,
            double durationHours,
            DateTime? date,
            int? weekday,
            String label,
            String? subtitle,
            int? players,
            int? capacity,
            int? price,
            PaymentStatus? payment,
            String? bookingCode)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Slot() when $default != null:
        return $default(
            _that.id,
            _that.venueId,
            _that.state,
            _that.startHour,
            _that.durationHours,
            _that.date,
            _that.weekday,
            _that.label,
            _that.subtitle,
            _that.players,
            _that.capacity,
            _that.price,
            _that.payment,
            _that.bookingCode);
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
  TResult when<TResult extends Object?>(
    TResult Function(
            String id,
            String venueId,
            SlotState state,
            double startHour,
            double durationHours,
            DateTime? date,
            int? weekday,
            String label,
            String? subtitle,
            int? players,
            int? capacity,
            int? price,
            PaymentStatus? payment,
            String? bookingCode)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Slot():
        return $default(
            _that.id,
            _that.venueId,
            _that.state,
            _that.startHour,
            _that.durationHours,
            _that.date,
            _that.weekday,
            _that.label,
            _that.subtitle,
            _that.players,
            _that.capacity,
            _that.price,
            _that.payment,
            _that.bookingCode);
      case _:
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

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String id,
            String venueId,
            SlotState state,
            double startHour,
            double durationHours,
            DateTime? date,
            int? weekday,
            String label,
            String? subtitle,
            int? players,
            int? capacity,
            int? price,
            PaymentStatus? payment,
            String? bookingCode)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Slot() when $default != null:
        return $default(
            _that.id,
            _that.venueId,
            _that.state,
            _that.startHour,
            _that.durationHours,
            _that.date,
            _that.weekday,
            _that.label,
            _that.subtitle,
            _that.players,
            _that.capacity,
            _that.price,
            _that.payment,
            _that.bookingCode);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Slot extends Slot {
  const _Slot(
      {required this.id,
      required this.venueId,
      required this.state,
      required this.startHour,
      required this.durationHours,
      this.date,
      this.weekday,
      required this.label,
      this.subtitle,
      this.players,
      this.capacity,
      this.price,
      this.payment,
      this.bookingCode})
      : super._();

  @override
  final String id;
  @override
  final String venueId;
  @override
  final SlotState state;

  /// 24h decimal hour, `.5` = `:30` — e.g. 18.0, 19.5.
  @override
  final double startHour;

  /// e.g. 1.5.
  @override
  final double durationHours;

  /// Day this slot belongs to (Day/Week views).
  @override
  final DateTime? date;

  /// 0 = Mon … 6 = Sun (Week view positioning).
  @override
  final int? weekday;

  /// Customer/team name OR "Slot trống"/"Bảo trì".
  @override
  final String label;

  /// "Cố định T3·T5", "Đang ghép đội", etc.
  @override
  final String? subtitle;

  /// Joined count (open/booked group slots).
  @override
  final int? players;

  /// Max players.
  @override
  final int? capacity;

  /// VND for this slot.
  @override
  final int? price;
  @override
  final PaymentStatus? payment;

  /// "SPB-060149".
  @override
  final String? bookingCode;

  /// Create a copy of Slot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SlotCopyWith<_Slot> get copyWith =>
      __$SlotCopyWithImpl<_Slot>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Slot &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.venueId, venueId) || other.venueId == venueId) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.startHour, startHour) ||
                other.startHour == startHour) &&
            (identical(other.durationHours, durationHours) ||
                other.durationHours == durationHours) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.weekday, weekday) || other.weekday == weekday) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.subtitle, subtitle) ||
                other.subtitle == subtitle) &&
            (identical(other.players, players) || other.players == players) &&
            (identical(other.capacity, capacity) ||
                other.capacity == capacity) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.payment, payment) || other.payment == payment) &&
            (identical(other.bookingCode, bookingCode) ||
                other.bookingCode == bookingCode));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      venueId,
      state,
      startHour,
      durationHours,
      date,
      weekday,
      label,
      subtitle,
      players,
      capacity,
      price,
      payment,
      bookingCode);

  @override
  String toString() {
    return 'Slot(id: $id, venueId: $venueId, state: $state, startHour: $startHour, durationHours: $durationHours, date: $date, weekday: $weekday, label: $label, subtitle: $subtitle, players: $players, capacity: $capacity, price: $price, payment: $payment, bookingCode: $bookingCode)';
  }
}

/// @nodoc
abstract mixin class _$SlotCopyWith<$Res> implements $SlotCopyWith<$Res> {
  factory _$SlotCopyWith(_Slot value, $Res Function(_Slot) _then) =
      __$SlotCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String venueId,
      SlotState state,
      double startHour,
      double durationHours,
      DateTime? date,
      int? weekday,
      String label,
      String? subtitle,
      int? players,
      int? capacity,
      int? price,
      PaymentStatus? payment,
      String? bookingCode});
}

/// @nodoc
class __$SlotCopyWithImpl<$Res> implements _$SlotCopyWith<$Res> {
  __$SlotCopyWithImpl(this._self, this._then);

  final _Slot _self;
  final $Res Function(_Slot) _then;

  /// Create a copy of Slot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? venueId = null,
    Object? state = null,
    Object? startHour = null,
    Object? durationHours = null,
    Object? date = freezed,
    Object? weekday = freezed,
    Object? label = null,
    Object? subtitle = freezed,
    Object? players = freezed,
    Object? capacity = freezed,
    Object? price = freezed,
    Object? payment = freezed,
    Object? bookingCode = freezed,
  }) {
    return _then(_Slot(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      venueId: null == venueId
          ? _self.venueId
          : venueId // ignore: cast_nullable_to_non_nullable
              as String,
      state: null == state
          ? _self.state
          : state // ignore: cast_nullable_to_non_nullable
              as SlotState,
      startHour: null == startHour
          ? _self.startHour
          : startHour // ignore: cast_nullable_to_non_nullable
              as double,
      durationHours: null == durationHours
          ? _self.durationHours
          : durationHours // ignore: cast_nullable_to_non_nullable
              as double,
      date: freezed == date
          ? _self.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      weekday: freezed == weekday
          ? _self.weekday
          : weekday // ignore: cast_nullable_to_non_nullable
              as int?,
      label: null == label
          ? _self.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      subtitle: freezed == subtitle
          ? _self.subtitle
          : subtitle // ignore: cast_nullable_to_non_nullable
              as String?,
      players: freezed == players
          ? _self.players
          : players // ignore: cast_nullable_to_non_nullable
              as int?,
      capacity: freezed == capacity
          ? _self.capacity
          : capacity // ignore: cast_nullable_to_non_nullable
              as int?,
      price: freezed == price
          ? _self.price
          : price // ignore: cast_nullable_to_non_nullable
              as int?,
      payment: freezed == payment
          ? _self.payment
          : payment // ignore: cast_nullable_to_non_nullable
              as PaymentStatus?,
      bookingCode: freezed == bookingCode
          ? _self.bookingCode
          : bookingCode // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
mixin _$OccupancyDay {
  DateTime get date;

  /// 0.0–1.0.
  double get occupancy;
  int get bookings;

  /// VND.
  int get revenue;
  bool get isToday;
  bool get isCurrentMonth;

  /// Create a copy of OccupancyDay
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $OccupancyDayCopyWith<OccupancyDay> get copyWith =>
      _$OccupancyDayCopyWithImpl<OccupancyDay>(
          this as OccupancyDay, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is OccupancyDay &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.occupancy, occupancy) ||
                other.occupancy == occupancy) &&
            (identical(other.bookings, bookings) ||
                other.bookings == bookings) &&
            (identical(other.revenue, revenue) || other.revenue == revenue) &&
            (identical(other.isToday, isToday) || other.isToday == isToday) &&
            (identical(other.isCurrentMonth, isCurrentMonth) ||
                other.isCurrentMonth == isCurrentMonth));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, date, occupancy, bookings, revenue, isToday, isCurrentMonth);

  @override
  String toString() {
    return 'OccupancyDay(date: $date, occupancy: $occupancy, bookings: $bookings, revenue: $revenue, isToday: $isToday, isCurrentMonth: $isCurrentMonth)';
  }
}

/// @nodoc
abstract mixin class $OccupancyDayCopyWith<$Res> {
  factory $OccupancyDayCopyWith(
          OccupancyDay value, $Res Function(OccupancyDay) _then) =
      _$OccupancyDayCopyWithImpl;
  @useResult
  $Res call(
      {DateTime date,
      double occupancy,
      int bookings,
      int revenue,
      bool isToday,
      bool isCurrentMonth});
}

/// @nodoc
class _$OccupancyDayCopyWithImpl<$Res> implements $OccupancyDayCopyWith<$Res> {
  _$OccupancyDayCopyWithImpl(this._self, this._then);

  final OccupancyDay _self;
  final $Res Function(OccupancyDay) _then;

  /// Create a copy of OccupancyDay
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? occupancy = null,
    Object? bookings = null,
    Object? revenue = null,
    Object? isToday = null,
    Object? isCurrentMonth = null,
  }) {
    return _then(_self.copyWith(
      date: null == date
          ? _self.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      occupancy: null == occupancy
          ? _self.occupancy
          : occupancy // ignore: cast_nullable_to_non_nullable
              as double,
      bookings: null == bookings
          ? _self.bookings
          : bookings // ignore: cast_nullable_to_non_nullable
              as int,
      revenue: null == revenue
          ? _self.revenue
          : revenue // ignore: cast_nullable_to_non_nullable
              as int,
      isToday: null == isToday
          ? _self.isToday
          : isToday // ignore: cast_nullable_to_non_nullable
              as bool,
      isCurrentMonth: null == isCurrentMonth
          ? _self.isCurrentMonth
          : isCurrentMonth // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// Adds pattern-matching-related methods to [OccupancyDay].
extension OccupancyDayPatterns on OccupancyDay {
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
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_OccupancyDay value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _OccupancyDay() when $default != null:
        return $default(_that);
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
  TResult map<TResult extends Object?>(
    TResult Function(_OccupancyDay value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OccupancyDay():
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_OccupancyDay value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OccupancyDay() when $default != null:
        return $default(_that);
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
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(DateTime date, double occupancy, int bookings, int revenue,
            bool isToday, bool isCurrentMonth)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _OccupancyDay() when $default != null:
        return $default(_that.date, _that.occupancy, _that.bookings,
            _that.revenue, _that.isToday, _that.isCurrentMonth);
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
  TResult when<TResult extends Object?>(
    TResult Function(DateTime date, double occupancy, int bookings, int revenue,
            bool isToday, bool isCurrentMonth)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OccupancyDay():
        return $default(_that.date, _that.occupancy, _that.bookings,
            _that.revenue, _that.isToday, _that.isCurrentMonth);
      case _:
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

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(DateTime date, double occupancy, int bookings,
            int revenue, bool isToday, bool isCurrentMonth)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OccupancyDay() when $default != null:
        return $default(_that.date, _that.occupancy, _that.bookings,
            _that.revenue, _that.isToday, _that.isCurrentMonth);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _OccupancyDay implements OccupancyDay {
  const _OccupancyDay(
      {required this.date,
      required this.occupancy,
      required this.bookings,
      required this.revenue,
      this.isToday = false,
      this.isCurrentMonth = false});

  @override
  final DateTime date;

  /// 0.0–1.0.
  @override
  final double occupancy;
  @override
  final int bookings;

  /// VND.
  @override
  final int revenue;
  @override
  @JsonKey()
  final bool isToday;
  @override
  @JsonKey()
  final bool isCurrentMonth;

  /// Create a copy of OccupancyDay
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$OccupancyDayCopyWith<_OccupancyDay> get copyWith =>
      __$OccupancyDayCopyWithImpl<_OccupancyDay>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _OccupancyDay &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.occupancy, occupancy) ||
                other.occupancy == occupancy) &&
            (identical(other.bookings, bookings) ||
                other.bookings == bookings) &&
            (identical(other.revenue, revenue) || other.revenue == revenue) &&
            (identical(other.isToday, isToday) || other.isToday == isToday) &&
            (identical(other.isCurrentMonth, isCurrentMonth) ||
                other.isCurrentMonth == isCurrentMonth));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, date, occupancy, bookings, revenue, isToday, isCurrentMonth);

  @override
  String toString() {
    return 'OccupancyDay(date: $date, occupancy: $occupancy, bookings: $bookings, revenue: $revenue, isToday: $isToday, isCurrentMonth: $isCurrentMonth)';
  }
}

/// @nodoc
abstract mixin class _$OccupancyDayCopyWith<$Res>
    implements $OccupancyDayCopyWith<$Res> {
  factory _$OccupancyDayCopyWith(
          _OccupancyDay value, $Res Function(_OccupancyDay) _then) =
      __$OccupancyDayCopyWithImpl;
  @override
  @useResult
  $Res call(
      {DateTime date,
      double occupancy,
      int bookings,
      int revenue,
      bool isToday,
      bool isCurrentMonth});
}

/// @nodoc
class __$OccupancyDayCopyWithImpl<$Res>
    implements _$OccupancyDayCopyWith<$Res> {
  __$OccupancyDayCopyWithImpl(this._self, this._then);

  final _OccupancyDay _self;
  final $Res Function(_OccupancyDay) _then;

  /// Create a copy of OccupancyDay
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? date = null,
    Object? occupancy = null,
    Object? bookings = null,
    Object? revenue = null,
    Object? isToday = null,
    Object? isCurrentMonth = null,
  }) {
    return _then(_OccupancyDay(
      date: null == date
          ? _self.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      occupancy: null == occupancy
          ? _self.occupancy
          : occupancy // ignore: cast_nullable_to_non_nullable
              as double,
      bookings: null == bookings
          ? _self.bookings
          : bookings // ignore: cast_nullable_to_non_nullable
              as int,
      revenue: null == revenue
          ? _self.revenue
          : revenue // ignore: cast_nullable_to_non_nullable
              as int,
      isToday: null == isToday
          ? _self.isToday
          : isToday // ignore: cast_nullable_to_non_nullable
              as bool,
      isCurrentMonth: null == isCurrentMonth
          ? _self.isCurrentMonth
          : isCurrentMonth // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
mixin _$CreateSlotRequest {
  String get venueId;

  /// 24h decimal, snapped to 30-minute increments.
  double get startHour;

  /// 1 / 1.5 / 2 / 2.5 / 3.
  double get durationHours;

  /// Day the slot lands on (Day view / single create).
  DateTime? get date;

  /// 0 = Mon … 6 = Sun (Week view create).
  int? get weekday;

  /// One of [SlotState.empty] (Slot trống), [SlotState.open]
  /// (Slot mở (ghép)) or [SlotState.private] (Slot riêng).
  SlotState get slotType;

  /// Open-slot extras ("Số người tối đa") — only when [slotType] is open.
  int? get capacity;

  /// Open-slot extras ("Giá / người"), VND — only when [slotType] is open.
  int? get pricePerPerson;
  String? get note;

  /// Create a copy of CreateSlotRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CreateSlotRequestCopyWith<CreateSlotRequest> get copyWith =>
      _$CreateSlotRequestCopyWithImpl<CreateSlotRequest>(
          this as CreateSlotRequest, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CreateSlotRequest &&
            (identical(other.venueId, venueId) || other.venueId == venueId) &&
            (identical(other.startHour, startHour) ||
                other.startHour == startHour) &&
            (identical(other.durationHours, durationHours) ||
                other.durationHours == durationHours) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.weekday, weekday) || other.weekday == weekday) &&
            (identical(other.slotType, slotType) ||
                other.slotType == slotType) &&
            (identical(other.capacity, capacity) ||
                other.capacity == capacity) &&
            (identical(other.pricePerPerson, pricePerPerson) ||
                other.pricePerPerson == pricePerPerson) &&
            (identical(other.note, note) || other.note == note));
  }

  @override
  int get hashCode => Object.hash(runtimeType, venueId, startHour,
      durationHours, date, weekday, slotType, capacity, pricePerPerson, note);

  @override
  String toString() {
    return 'CreateSlotRequest(venueId: $venueId, startHour: $startHour, durationHours: $durationHours, date: $date, weekday: $weekday, slotType: $slotType, capacity: $capacity, pricePerPerson: $pricePerPerson, note: $note)';
  }
}

/// @nodoc
abstract mixin class $CreateSlotRequestCopyWith<$Res> {
  factory $CreateSlotRequestCopyWith(
          CreateSlotRequest value, $Res Function(CreateSlotRequest) _then) =
      _$CreateSlotRequestCopyWithImpl;
  @useResult
  $Res call(
      {String venueId,
      double startHour,
      double durationHours,
      DateTime? date,
      int? weekday,
      SlotState slotType,
      int? capacity,
      int? pricePerPerson,
      String? note});
}

/// @nodoc
class _$CreateSlotRequestCopyWithImpl<$Res>
    implements $CreateSlotRequestCopyWith<$Res> {
  _$CreateSlotRequestCopyWithImpl(this._self, this._then);

  final CreateSlotRequest _self;
  final $Res Function(CreateSlotRequest) _then;

  /// Create a copy of CreateSlotRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? venueId = null,
    Object? startHour = null,
    Object? durationHours = null,
    Object? date = freezed,
    Object? weekday = freezed,
    Object? slotType = null,
    Object? capacity = freezed,
    Object? pricePerPerson = freezed,
    Object? note = freezed,
  }) {
    return _then(_self.copyWith(
      venueId: null == venueId
          ? _self.venueId
          : venueId // ignore: cast_nullable_to_non_nullable
              as String,
      startHour: null == startHour
          ? _self.startHour
          : startHour // ignore: cast_nullable_to_non_nullable
              as double,
      durationHours: null == durationHours
          ? _self.durationHours
          : durationHours // ignore: cast_nullable_to_non_nullable
              as double,
      date: freezed == date
          ? _self.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      weekday: freezed == weekday
          ? _self.weekday
          : weekday // ignore: cast_nullable_to_non_nullable
              as int?,
      slotType: null == slotType
          ? _self.slotType
          : slotType // ignore: cast_nullable_to_non_nullable
              as SlotState,
      capacity: freezed == capacity
          ? _self.capacity
          : capacity // ignore: cast_nullable_to_non_nullable
              as int?,
      pricePerPerson: freezed == pricePerPerson
          ? _self.pricePerPerson
          : pricePerPerson // ignore: cast_nullable_to_non_nullable
              as int?,
      note: freezed == note
          ? _self.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [CreateSlotRequest].
extension CreateSlotRequestPatterns on CreateSlotRequest {
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
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_CreateSlotRequest value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CreateSlotRequest() when $default != null:
        return $default(_that);
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
  TResult map<TResult extends Object?>(
    TResult Function(_CreateSlotRequest value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CreateSlotRequest():
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_CreateSlotRequest value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CreateSlotRequest() when $default != null:
        return $default(_that);
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
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String venueId,
            double startHour,
            double durationHours,
            DateTime? date,
            int? weekday,
            SlotState slotType,
            int? capacity,
            int? pricePerPerson,
            String? note)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CreateSlotRequest() when $default != null:
        return $default(
            _that.venueId,
            _that.startHour,
            _that.durationHours,
            _that.date,
            _that.weekday,
            _that.slotType,
            _that.capacity,
            _that.pricePerPerson,
            _that.note);
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
  TResult when<TResult extends Object?>(
    TResult Function(
            String venueId,
            double startHour,
            double durationHours,
            DateTime? date,
            int? weekday,
            SlotState slotType,
            int? capacity,
            int? pricePerPerson,
            String? note)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CreateSlotRequest():
        return $default(
            _that.venueId,
            _that.startHour,
            _that.durationHours,
            _that.date,
            _that.weekday,
            _that.slotType,
            _that.capacity,
            _that.pricePerPerson,
            _that.note);
      case _:
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

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String venueId,
            double startHour,
            double durationHours,
            DateTime? date,
            int? weekday,
            SlotState slotType,
            int? capacity,
            int? pricePerPerson,
            String? note)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CreateSlotRequest() when $default != null:
        return $default(
            _that.venueId,
            _that.startHour,
            _that.durationHours,
            _that.date,
            _that.weekday,
            _that.slotType,
            _that.capacity,
            _that.pricePerPerson,
            _that.note);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _CreateSlotRequest extends CreateSlotRequest {
  const _CreateSlotRequest(
      {required this.venueId,
      required this.startHour,
      this.durationHours = 1.0,
      this.date,
      this.weekday,
      this.slotType = SlotState.empty,
      this.capacity,
      this.pricePerPerson,
      this.note})
      : super._();

  @override
  final String venueId;

  /// 24h decimal, snapped to 30-minute increments.
  @override
  final double startHour;

  /// 1 / 1.5 / 2 / 2.5 / 3.
  @override
  @JsonKey()
  final double durationHours;

  /// Day the slot lands on (Day view / single create).
  @override
  final DateTime? date;

  /// 0 = Mon … 6 = Sun (Week view create).
  @override
  final int? weekday;

  /// One of [SlotState.empty] (Slot trống), [SlotState.open]
  /// (Slot mở (ghép)) or [SlotState.private] (Slot riêng).
  @override
  @JsonKey()
  final SlotState slotType;

  /// Open-slot extras ("Số người tối đa") — only when [slotType] is open.
  @override
  final int? capacity;

  /// Open-slot extras ("Giá / người"), VND — only when [slotType] is open.
  @override
  final int? pricePerPerson;
  @override
  final String? note;

  /// Create a copy of CreateSlotRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CreateSlotRequestCopyWith<_CreateSlotRequest> get copyWith =>
      __$CreateSlotRequestCopyWithImpl<_CreateSlotRequest>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CreateSlotRequest &&
            (identical(other.venueId, venueId) || other.venueId == venueId) &&
            (identical(other.startHour, startHour) ||
                other.startHour == startHour) &&
            (identical(other.durationHours, durationHours) ||
                other.durationHours == durationHours) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.weekday, weekday) || other.weekday == weekday) &&
            (identical(other.slotType, slotType) ||
                other.slotType == slotType) &&
            (identical(other.capacity, capacity) ||
                other.capacity == capacity) &&
            (identical(other.pricePerPerson, pricePerPerson) ||
                other.pricePerPerson == pricePerPerson) &&
            (identical(other.note, note) || other.note == note));
  }

  @override
  int get hashCode => Object.hash(runtimeType, venueId, startHour,
      durationHours, date, weekday, slotType, capacity, pricePerPerson, note);

  @override
  String toString() {
    return 'CreateSlotRequest(venueId: $venueId, startHour: $startHour, durationHours: $durationHours, date: $date, weekday: $weekday, slotType: $slotType, capacity: $capacity, pricePerPerson: $pricePerPerson, note: $note)';
  }
}

/// @nodoc
abstract mixin class _$CreateSlotRequestCopyWith<$Res>
    implements $CreateSlotRequestCopyWith<$Res> {
  factory _$CreateSlotRequestCopyWith(
          _CreateSlotRequest value, $Res Function(_CreateSlotRequest) _then) =
      __$CreateSlotRequestCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String venueId,
      double startHour,
      double durationHours,
      DateTime? date,
      int? weekday,
      SlotState slotType,
      int? capacity,
      int? pricePerPerson,
      String? note});
}

/// @nodoc
class __$CreateSlotRequestCopyWithImpl<$Res>
    implements _$CreateSlotRequestCopyWith<$Res> {
  __$CreateSlotRequestCopyWithImpl(this._self, this._then);

  final _CreateSlotRequest _self;
  final $Res Function(_CreateSlotRequest) _then;

  /// Create a copy of CreateSlotRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? venueId = null,
    Object? startHour = null,
    Object? durationHours = null,
    Object? date = freezed,
    Object? weekday = freezed,
    Object? slotType = null,
    Object? capacity = freezed,
    Object? pricePerPerson = freezed,
    Object? note = freezed,
  }) {
    return _then(_CreateSlotRequest(
      venueId: null == venueId
          ? _self.venueId
          : venueId // ignore: cast_nullable_to_non_nullable
              as String,
      startHour: null == startHour
          ? _self.startHour
          : startHour // ignore: cast_nullable_to_non_nullable
              as double,
      durationHours: null == durationHours
          ? _self.durationHours
          : durationHours // ignore: cast_nullable_to_non_nullable
              as double,
      date: freezed == date
          ? _self.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      weekday: freezed == weekday
          ? _self.weekday
          : weekday // ignore: cast_nullable_to_non_nullable
              as int?,
      slotType: null == slotType
          ? _self.slotType
          : slotType // ignore: cast_nullable_to_non_nullable
              as SlotState,
      capacity: freezed == capacity
          ? _self.capacity
          : capacity // ignore: cast_nullable_to_non_nullable
              as int?,
      pricePerPerson: freezed == pricePerPerson
          ? _self.pricePerPerson
          : pricePerPerson // ignore: cast_nullable_to_non_nullable
              as int?,
      note: freezed == note
          ? _self.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
mixin _$BlockTimeRequest {
  String get venueId;

  /// 24h decimal, snapped to 30-minute increments.
  double get startHour;
  double get durationHours;

  /// Day being blocked (Day view drag).
  DateTime? get date;

  /// 0 = Mon … 6 = Sun (Week view drag).
  int? get weekday;

  /// One of [SlotState.locked] (Khoá giờ), [SlotState.maintenance]
  /// (Bảo trì) or [SlotState.owner] (Sân của tôi).
  SlotState get blockType;
  String? get note;

  /// Create a copy of BlockTimeRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $BlockTimeRequestCopyWith<BlockTimeRequest> get copyWith =>
      _$BlockTimeRequestCopyWithImpl<BlockTimeRequest>(
          this as BlockTimeRequest, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is BlockTimeRequest &&
            (identical(other.venueId, venueId) || other.venueId == venueId) &&
            (identical(other.startHour, startHour) ||
                other.startHour == startHour) &&
            (identical(other.durationHours, durationHours) ||
                other.durationHours == durationHours) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.weekday, weekday) || other.weekday == weekday) &&
            (identical(other.blockType, blockType) ||
                other.blockType == blockType) &&
            (identical(other.note, note) || other.note == note));
  }

  @override
  int get hashCode => Object.hash(runtimeType, venueId, startHour,
      durationHours, date, weekday, blockType, note);

  @override
  String toString() {
    return 'BlockTimeRequest(venueId: $venueId, startHour: $startHour, durationHours: $durationHours, date: $date, weekday: $weekday, blockType: $blockType, note: $note)';
  }
}

/// @nodoc
abstract mixin class $BlockTimeRequestCopyWith<$Res> {
  factory $BlockTimeRequestCopyWith(
          BlockTimeRequest value, $Res Function(BlockTimeRequest) _then) =
      _$BlockTimeRequestCopyWithImpl;
  @useResult
  $Res call(
      {String venueId,
      double startHour,
      double durationHours,
      DateTime? date,
      int? weekday,
      SlotState blockType,
      String? note});
}

/// @nodoc
class _$BlockTimeRequestCopyWithImpl<$Res>
    implements $BlockTimeRequestCopyWith<$Res> {
  _$BlockTimeRequestCopyWithImpl(this._self, this._then);

  final BlockTimeRequest _self;
  final $Res Function(BlockTimeRequest) _then;

  /// Create a copy of BlockTimeRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? venueId = null,
    Object? startHour = null,
    Object? durationHours = null,
    Object? date = freezed,
    Object? weekday = freezed,
    Object? blockType = null,
    Object? note = freezed,
  }) {
    return _then(_self.copyWith(
      venueId: null == venueId
          ? _self.venueId
          : venueId // ignore: cast_nullable_to_non_nullable
              as String,
      startHour: null == startHour
          ? _self.startHour
          : startHour // ignore: cast_nullable_to_non_nullable
              as double,
      durationHours: null == durationHours
          ? _self.durationHours
          : durationHours // ignore: cast_nullable_to_non_nullable
              as double,
      date: freezed == date
          ? _self.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      weekday: freezed == weekday
          ? _self.weekday
          : weekday // ignore: cast_nullable_to_non_nullable
              as int?,
      blockType: null == blockType
          ? _self.blockType
          : blockType // ignore: cast_nullable_to_non_nullable
              as SlotState,
      note: freezed == note
          ? _self.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [BlockTimeRequest].
extension BlockTimeRequestPatterns on BlockTimeRequest {
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
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_BlockTimeRequest value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _BlockTimeRequest() when $default != null:
        return $default(_that);
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
  TResult map<TResult extends Object?>(
    TResult Function(_BlockTimeRequest value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _BlockTimeRequest():
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_BlockTimeRequest value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _BlockTimeRequest() when $default != null:
        return $default(_that);
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
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(String venueId, double startHour, double durationHours,
            DateTime? date, int? weekday, SlotState blockType, String? note)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _BlockTimeRequest() when $default != null:
        return $default(_that.venueId, _that.startHour, _that.durationHours,
            _that.date, _that.weekday, _that.blockType, _that.note);
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
  TResult when<TResult extends Object?>(
    TResult Function(String venueId, double startHour, double durationHours,
            DateTime? date, int? weekday, SlotState blockType, String? note)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _BlockTimeRequest():
        return $default(_that.venueId, _that.startHour, _that.durationHours,
            _that.date, _that.weekday, _that.blockType, _that.note);
      case _:
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

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(String venueId, double startHour, double durationHours,
            DateTime? date, int? weekday, SlotState blockType, String? note)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _BlockTimeRequest() when $default != null:
        return $default(_that.venueId, _that.startHour, _that.durationHours,
            _that.date, _that.weekday, _that.blockType, _that.note);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _BlockTimeRequest extends BlockTimeRequest {
  const _BlockTimeRequest(
      {required this.venueId,
      required this.startHour,
      this.durationHours = 1.0,
      this.date,
      this.weekday,
      this.blockType = SlotState.locked,
      this.note})
      : super._();

  @override
  final String venueId;

  /// 24h decimal, snapped to 30-minute increments.
  @override
  final double startHour;
  @override
  @JsonKey()
  final double durationHours;

  /// Day being blocked (Day view drag).
  @override
  final DateTime? date;

  /// 0 = Mon … 6 = Sun (Week view drag).
  @override
  final int? weekday;

  /// One of [SlotState.locked] (Khoá giờ), [SlotState.maintenance]
  /// (Bảo trì) or [SlotState.owner] (Sân của tôi).
  @override
  @JsonKey()
  final SlotState blockType;
  @override
  final String? note;

  /// Create a copy of BlockTimeRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$BlockTimeRequestCopyWith<_BlockTimeRequest> get copyWith =>
      __$BlockTimeRequestCopyWithImpl<_BlockTimeRequest>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _BlockTimeRequest &&
            (identical(other.venueId, venueId) || other.venueId == venueId) &&
            (identical(other.startHour, startHour) ||
                other.startHour == startHour) &&
            (identical(other.durationHours, durationHours) ||
                other.durationHours == durationHours) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.weekday, weekday) || other.weekday == weekday) &&
            (identical(other.blockType, blockType) ||
                other.blockType == blockType) &&
            (identical(other.note, note) || other.note == note));
  }

  @override
  int get hashCode => Object.hash(runtimeType, venueId, startHour,
      durationHours, date, weekday, blockType, note);

  @override
  String toString() {
    return 'BlockTimeRequest(venueId: $venueId, startHour: $startHour, durationHours: $durationHours, date: $date, weekday: $weekday, blockType: $blockType, note: $note)';
  }
}

/// @nodoc
abstract mixin class _$BlockTimeRequestCopyWith<$Res>
    implements $BlockTimeRequestCopyWith<$Res> {
  factory _$BlockTimeRequestCopyWith(
          _BlockTimeRequest value, $Res Function(_BlockTimeRequest) _then) =
      __$BlockTimeRequestCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String venueId,
      double startHour,
      double durationHours,
      DateTime? date,
      int? weekday,
      SlotState blockType,
      String? note});
}

/// @nodoc
class __$BlockTimeRequestCopyWithImpl<$Res>
    implements _$BlockTimeRequestCopyWith<$Res> {
  __$BlockTimeRequestCopyWithImpl(this._self, this._then);

  final _BlockTimeRequest _self;
  final $Res Function(_BlockTimeRequest) _then;

  /// Create a copy of BlockTimeRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? venueId = null,
    Object? startHour = null,
    Object? durationHours = null,
    Object? date = freezed,
    Object? weekday = freezed,
    Object? blockType = null,
    Object? note = freezed,
  }) {
    return _then(_BlockTimeRequest(
      venueId: null == venueId
          ? _self.venueId
          : venueId // ignore: cast_nullable_to_non_nullable
              as String,
      startHour: null == startHour
          ? _self.startHour
          : startHour // ignore: cast_nullable_to_non_nullable
              as double,
      durationHours: null == durationHours
          ? _self.durationHours
          : durationHours // ignore: cast_nullable_to_non_nullable
              as double,
      date: freezed == date
          ? _self.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      weekday: freezed == weekday
          ? _self.weekday
          : weekday // ignore: cast_nullable_to_non_nullable
              as int?,
      blockType: null == blockType
          ? _self.blockType
          : blockType // ignore: cast_nullable_to_non_nullable
              as SlotState,
      note: freezed == note
          ? _self.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
