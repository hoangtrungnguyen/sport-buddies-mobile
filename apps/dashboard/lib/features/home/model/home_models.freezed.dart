// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HomeKpi {
  String get id;
  String get label;
  String get value;
  String? get unit;
  String? get delta;
  bool? get deltaUp;
  String? get sub;
  int? get progress;
  KpiTone get tone;
  String get icon;

  /// Create a copy of HomeKpi
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $HomeKpiCopyWith<HomeKpi> get copyWith =>
      _$HomeKpiCopyWithImpl<HomeKpi>(this as HomeKpi, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is HomeKpi &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.delta, delta) || other.delta == delta) &&
            (identical(other.deltaUp, deltaUp) || other.deltaUp == deltaUp) &&
            (identical(other.sub, sub) || other.sub == sub) &&
            (identical(other.progress, progress) ||
                other.progress == progress) &&
            (identical(other.tone, tone) || other.tone == tone) &&
            (identical(other.icon, icon) || other.icon == icon));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, label, value, unit, delta,
      deltaUp, sub, progress, tone, icon);

  @override
  String toString() {
    return 'HomeKpi(id: $id, label: $label, value: $value, unit: $unit, delta: $delta, deltaUp: $deltaUp, sub: $sub, progress: $progress, tone: $tone, icon: $icon)';
  }
}

/// @nodoc
abstract mixin class $HomeKpiCopyWith<$Res> {
  factory $HomeKpiCopyWith(HomeKpi value, $Res Function(HomeKpi) _then) =
      _$HomeKpiCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String label,
      String value,
      String? unit,
      String? delta,
      bool? deltaUp,
      String? sub,
      int? progress,
      KpiTone tone,
      String icon});
}

/// @nodoc
class _$HomeKpiCopyWithImpl<$Res> implements $HomeKpiCopyWith<$Res> {
  _$HomeKpiCopyWithImpl(this._self, this._then);

  final HomeKpi _self;
  final $Res Function(HomeKpi) _then;

  /// Create a copy of HomeKpi
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? label = null,
    Object? value = null,
    Object? unit = freezed,
    Object? delta = freezed,
    Object? deltaUp = freezed,
    Object? sub = freezed,
    Object? progress = freezed,
    Object? tone = null,
    Object? icon = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      label: null == label
          ? _self.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _self.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
      unit: freezed == unit
          ? _self.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String?,
      delta: freezed == delta
          ? _self.delta
          : delta // ignore: cast_nullable_to_non_nullable
              as String?,
      deltaUp: freezed == deltaUp
          ? _self.deltaUp
          : deltaUp // ignore: cast_nullable_to_non_nullable
              as bool?,
      sub: freezed == sub
          ? _self.sub
          : sub // ignore: cast_nullable_to_non_nullable
              as String?,
      progress: freezed == progress
          ? _self.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as int?,
      tone: null == tone
          ? _self.tone
          : tone // ignore: cast_nullable_to_non_nullable
              as KpiTone,
      icon: null == icon
          ? _self.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [HomeKpi].
extension HomeKpiPatterns on HomeKpi {
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
    TResult Function(_HomeKpi value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _HomeKpi() when $default != null:
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
    TResult Function(_HomeKpi value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HomeKpi():
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
    TResult? Function(_HomeKpi value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HomeKpi() when $default != null:
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
            String label,
            String value,
            String? unit,
            String? delta,
            bool? deltaUp,
            String? sub,
            int? progress,
            KpiTone tone,
            String icon)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _HomeKpi() when $default != null:
        return $default(
            _that.id,
            _that.label,
            _that.value,
            _that.unit,
            _that.delta,
            _that.deltaUp,
            _that.sub,
            _that.progress,
            _that.tone,
            _that.icon);
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
            String label,
            String value,
            String? unit,
            String? delta,
            bool? deltaUp,
            String? sub,
            int? progress,
            KpiTone tone,
            String icon)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HomeKpi():
        return $default(
            _that.id,
            _that.label,
            _that.value,
            _that.unit,
            _that.delta,
            _that.deltaUp,
            _that.sub,
            _that.progress,
            _that.tone,
            _that.icon);
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
            String label,
            String value,
            String? unit,
            String? delta,
            bool? deltaUp,
            String? sub,
            int? progress,
            KpiTone tone,
            String icon)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HomeKpi() when $default != null:
        return $default(
            _that.id,
            _that.label,
            _that.value,
            _that.unit,
            _that.delta,
            _that.deltaUp,
            _that.sub,
            _that.progress,
            _that.tone,
            _that.icon);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _HomeKpi implements HomeKpi {
  const _HomeKpi(
      {required this.id,
      required this.label,
      required this.value,
      this.unit,
      this.delta,
      this.deltaUp,
      this.sub,
      this.progress,
      required this.tone,
      required this.icon});

  @override
  final String id;
  @override
  final String label;
  @override
  final String value;
  @override
  final String? unit;
  @override
  final String? delta;
  @override
  final bool? deltaUp;
  @override
  final String? sub;
  @override
  final int? progress;
  @override
  final KpiTone tone;
  @override
  final String icon;

  /// Create a copy of HomeKpi
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$HomeKpiCopyWith<_HomeKpi> get copyWith =>
      __$HomeKpiCopyWithImpl<_HomeKpi>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _HomeKpi &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.delta, delta) || other.delta == delta) &&
            (identical(other.deltaUp, deltaUp) || other.deltaUp == deltaUp) &&
            (identical(other.sub, sub) || other.sub == sub) &&
            (identical(other.progress, progress) ||
                other.progress == progress) &&
            (identical(other.tone, tone) || other.tone == tone) &&
            (identical(other.icon, icon) || other.icon == icon));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, label, value, unit, delta,
      deltaUp, sub, progress, tone, icon);

  @override
  String toString() {
    return 'HomeKpi(id: $id, label: $label, value: $value, unit: $unit, delta: $delta, deltaUp: $deltaUp, sub: $sub, progress: $progress, tone: $tone, icon: $icon)';
  }
}

/// @nodoc
abstract mixin class _$HomeKpiCopyWith<$Res> implements $HomeKpiCopyWith<$Res> {
  factory _$HomeKpiCopyWith(_HomeKpi value, $Res Function(_HomeKpi) _then) =
      __$HomeKpiCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String label,
      String value,
      String? unit,
      String? delta,
      bool? deltaUp,
      String? sub,
      int? progress,
      KpiTone tone,
      String icon});
}

/// @nodoc
class __$HomeKpiCopyWithImpl<$Res> implements _$HomeKpiCopyWith<$Res> {
  __$HomeKpiCopyWithImpl(this._self, this._then);

  final _HomeKpi _self;
  final $Res Function(_HomeKpi) _then;

  /// Create a copy of HomeKpi
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? label = null,
    Object? value = null,
    Object? unit = freezed,
    Object? delta = freezed,
    Object? deltaUp = freezed,
    Object? sub = freezed,
    Object? progress = freezed,
    Object? tone = null,
    Object? icon = null,
  }) {
    return _then(_HomeKpi(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      label: null == label
          ? _self.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _self.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
      unit: freezed == unit
          ? _self.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String?,
      delta: freezed == delta
          ? _self.delta
          : delta // ignore: cast_nullable_to_non_nullable
              as String?,
      deltaUp: freezed == deltaUp
          ? _self.deltaUp
          : deltaUp // ignore: cast_nullable_to_non_nullable
              as bool?,
      sub: freezed == sub
          ? _self.sub
          : sub // ignore: cast_nullable_to_non_nullable
              as String?,
      progress: freezed == progress
          ? _self.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as int?,
      tone: null == tone
          ? _self.tone
          : tone // ignore: cast_nullable_to_non_nullable
              as KpiTone,
      icon: null == icon
          ? _self.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
mixin _$PendingRequest {
  String get id;
  String get name;
  String get initials;
  String get court;
  String get venue;
  String get sport;
  String get when;
  int get price;
  bool get regular;

  /// Create a copy of PendingRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PendingRequestCopyWith<PendingRequest> get copyWith =>
      _$PendingRequestCopyWithImpl<PendingRequest>(
          this as PendingRequest, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PendingRequest &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.initials, initials) ||
                other.initials == initials) &&
            (identical(other.court, court) || other.court == court) &&
            (identical(other.venue, venue) || other.venue == venue) &&
            (identical(other.sport, sport) || other.sport == sport) &&
            (identical(other.when, when) || other.when == when) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.regular, regular) || other.regular == regular));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, name, initials, court, venue,
      sport, when, price, regular);

  @override
  String toString() {
    return 'PendingRequest(id: $id, name: $name, initials: $initials, court: $court, venue: $venue, sport: $sport, when: $when, price: $price, regular: $regular)';
  }
}

/// @nodoc
abstract mixin class $PendingRequestCopyWith<$Res> {
  factory $PendingRequestCopyWith(
          PendingRequest value, $Res Function(PendingRequest) _then) =
      _$PendingRequestCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String name,
      String initials,
      String court,
      String venue,
      String sport,
      String when,
      int price,
      bool regular});
}

/// @nodoc
class _$PendingRequestCopyWithImpl<$Res>
    implements $PendingRequestCopyWith<$Res> {
  _$PendingRequestCopyWithImpl(this._self, this._then);

  final PendingRequest _self;
  final $Res Function(PendingRequest) _then;

  /// Create a copy of PendingRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? initials = null,
    Object? court = null,
    Object? venue = null,
    Object? sport = null,
    Object? when = null,
    Object? price = null,
    Object? regular = null,
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
      initials: null == initials
          ? _self.initials
          : initials // ignore: cast_nullable_to_non_nullable
              as String,
      court: null == court
          ? _self.court
          : court // ignore: cast_nullable_to_non_nullable
              as String,
      venue: null == venue
          ? _self.venue
          : venue // ignore: cast_nullable_to_non_nullable
              as String,
      sport: null == sport
          ? _self.sport
          : sport // ignore: cast_nullable_to_non_nullable
              as String,
      when: null == when
          ? _self.when
          : when // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _self.price
          : price // ignore: cast_nullable_to_non_nullable
              as int,
      regular: null == regular
          ? _self.regular
          : regular // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// Adds pattern-matching-related methods to [PendingRequest].
extension PendingRequestPatterns on PendingRequest {
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
    TResult Function(_PendingRequest value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PendingRequest() when $default != null:
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
    TResult Function(_PendingRequest value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PendingRequest():
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
    TResult? Function(_PendingRequest value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PendingRequest() when $default != null:
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
    TResult Function(String id, String name, String initials, String court,
            String venue, String sport, String when, int price, bool regular)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PendingRequest() when $default != null:
        return $default(_that.id, _that.name, _that.initials, _that.court,
            _that.venue, _that.sport, _that.when, _that.price, _that.regular);
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
    TResult Function(String id, String name, String initials, String court,
            String venue, String sport, String when, int price, bool regular)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PendingRequest():
        return $default(_that.id, _that.name, _that.initials, _that.court,
            _that.venue, _that.sport, _that.when, _that.price, _that.regular);
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
    TResult? Function(String id, String name, String initials, String court,
            String venue, String sport, String when, int price, bool regular)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PendingRequest() when $default != null:
        return $default(_that.id, _that.name, _that.initials, _that.court,
            _that.venue, _that.sport, _that.when, _that.price, _that.regular);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _PendingRequest implements PendingRequest {
  const _PendingRequest(
      {required this.id,
      required this.name,
      required this.initials,
      required this.court,
      required this.venue,
      required this.sport,
      required this.when,
      required this.price,
      this.regular = false});

  @override
  final String id;
  @override
  final String name;
  @override
  final String initials;
  @override
  final String court;
  @override
  final String venue;
  @override
  final String sport;
  @override
  final String when;
  @override
  final int price;
  @override
  @JsonKey()
  final bool regular;

  /// Create a copy of PendingRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PendingRequestCopyWith<_PendingRequest> get copyWith =>
      __$PendingRequestCopyWithImpl<_PendingRequest>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PendingRequest &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.initials, initials) ||
                other.initials == initials) &&
            (identical(other.court, court) || other.court == court) &&
            (identical(other.venue, venue) || other.venue == venue) &&
            (identical(other.sport, sport) || other.sport == sport) &&
            (identical(other.when, when) || other.when == when) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.regular, regular) || other.regular == regular));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, name, initials, court, venue,
      sport, when, price, regular);

  @override
  String toString() {
    return 'PendingRequest(id: $id, name: $name, initials: $initials, court: $court, venue: $venue, sport: $sport, when: $when, price: $price, regular: $regular)';
  }
}

/// @nodoc
abstract mixin class _$PendingRequestCopyWith<$Res>
    implements $PendingRequestCopyWith<$Res> {
  factory _$PendingRequestCopyWith(
          _PendingRequest value, $Res Function(_PendingRequest) _then) =
      __$PendingRequestCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String initials,
      String court,
      String venue,
      String sport,
      String when,
      int price,
      bool regular});
}

/// @nodoc
class __$PendingRequestCopyWithImpl<$Res>
    implements _$PendingRequestCopyWith<$Res> {
  __$PendingRequestCopyWithImpl(this._self, this._then);

  final _PendingRequest _self;
  final $Res Function(_PendingRequest) _then;

  /// Create a copy of PendingRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? initials = null,
    Object? court = null,
    Object? venue = null,
    Object? sport = null,
    Object? when = null,
    Object? price = null,
    Object? regular = null,
  }) {
    return _then(_PendingRequest(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      initials: null == initials
          ? _self.initials
          : initials // ignore: cast_nullable_to_non_nullable
              as String,
      court: null == court
          ? _self.court
          : court // ignore: cast_nullable_to_non_nullable
              as String,
      venue: null == venue
          ? _self.venue
          : venue // ignore: cast_nullable_to_non_nullable
              as String,
      sport: null == sport
          ? _self.sport
          : sport // ignore: cast_nullable_to_non_nullable
              as String,
      when: null == when
          ? _self.when
          : when // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _self.price
          : price // ignore: cast_nullable_to_non_nullable
              as int,
      regular: null == regular
          ? _self.regular
          : regular // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
mixin _$UpcomingSession {
  String get id;
  String get time;
  String get end;
  String get name;
  String get where;
  SessionStatus get status;

  /// Create a copy of UpcomingSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $UpcomingSessionCopyWith<UpcomingSession> get copyWith =>
      _$UpcomingSessionCopyWithImpl<UpcomingSession>(
          this as UpcomingSession, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is UpcomingSession &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.time, time) || other.time == time) &&
            (identical(other.end, end) || other.end == end) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.where, where) || other.where == where) &&
            (identical(other.status, status) || other.status == status));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, id, time, end, name, where, status);

  @override
  String toString() {
    return 'UpcomingSession(id: $id, time: $time, end: $end, name: $name, where: $where, status: $status)';
  }
}

/// @nodoc
abstract mixin class $UpcomingSessionCopyWith<$Res> {
  factory $UpcomingSessionCopyWith(
          UpcomingSession value, $Res Function(UpcomingSession) _then) =
      _$UpcomingSessionCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String time,
      String end,
      String name,
      String where,
      SessionStatus status});
}

/// @nodoc
class _$UpcomingSessionCopyWithImpl<$Res>
    implements $UpcomingSessionCopyWith<$Res> {
  _$UpcomingSessionCopyWithImpl(this._self, this._then);

  final UpcomingSession _self;
  final $Res Function(UpcomingSession) _then;

  /// Create a copy of UpcomingSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? time = null,
    Object? end = null,
    Object? name = null,
    Object? where = null,
    Object? status = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      time: null == time
          ? _self.time
          : time // ignore: cast_nullable_to_non_nullable
              as String,
      end: null == end
          ? _self.end
          : end // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      where: null == where
          ? _self.where
          : where // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as SessionStatus,
    ));
  }
}

/// Adds pattern-matching-related methods to [UpcomingSession].
extension UpcomingSessionPatterns on UpcomingSession {
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
    TResult Function(_UpcomingSession value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _UpcomingSession() when $default != null:
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
    TResult Function(_UpcomingSession value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UpcomingSession():
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
    TResult? Function(_UpcomingSession value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UpcomingSession() when $default != null:
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
    TResult Function(String id, String time, String end, String name,
            String where, SessionStatus status)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _UpcomingSession() when $default != null:
        return $default(_that.id, _that.time, _that.end, _that.name,
            _that.where, _that.status);
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
    TResult Function(String id, String time, String end, String name,
            String where, SessionStatus status)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UpcomingSession():
        return $default(_that.id, _that.time, _that.end, _that.name,
            _that.where, _that.status);
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
    TResult? Function(String id, String time, String end, String name,
            String where, SessionStatus status)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UpcomingSession() when $default != null:
        return $default(_that.id, _that.time, _that.end, _that.name,
            _that.where, _that.status);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _UpcomingSession implements UpcomingSession {
  const _UpcomingSession(
      {required this.id,
      required this.time,
      required this.end,
      required this.name,
      required this.where,
      required this.status});

  @override
  final String id;
  @override
  final String time;
  @override
  final String end;
  @override
  final String name;
  @override
  final String where;
  @override
  final SessionStatus status;

  /// Create a copy of UpcomingSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$UpcomingSessionCopyWith<_UpcomingSession> get copyWith =>
      __$UpcomingSessionCopyWithImpl<_UpcomingSession>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _UpcomingSession &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.time, time) || other.time == time) &&
            (identical(other.end, end) || other.end == end) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.where, where) || other.where == where) &&
            (identical(other.status, status) || other.status == status));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, id, time, end, name, where, status);

  @override
  String toString() {
    return 'UpcomingSession(id: $id, time: $time, end: $end, name: $name, where: $where, status: $status)';
  }
}

/// @nodoc
abstract mixin class _$UpcomingSessionCopyWith<$Res>
    implements $UpcomingSessionCopyWith<$Res> {
  factory _$UpcomingSessionCopyWith(
          _UpcomingSession value, $Res Function(_UpcomingSession) _then) =
      __$UpcomingSessionCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String time,
      String end,
      String name,
      String where,
      SessionStatus status});
}

/// @nodoc
class __$UpcomingSessionCopyWithImpl<$Res>
    implements _$UpcomingSessionCopyWith<$Res> {
  __$UpcomingSessionCopyWithImpl(this._self, this._then);

  final _UpcomingSession _self;
  final $Res Function(_UpcomingSession) _then;

  /// Create a copy of UpcomingSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? time = null,
    Object? end = null,
    Object? name = null,
    Object? where = null,
    Object? status = null,
  }) {
    return _then(_UpcomingSession(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      time: null == time
          ? _self.time
          : time // ignore: cast_nullable_to_non_nullable
              as String,
      end: null == end
          ? _self.end
          : end // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      where: null == where
          ? _self.where
          : where // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as SessionStatus,
    ));
  }
}

/// @nodoc
mixin _$RevenueDay {
  String get day;
  int get value;
  bool get today;

  /// Create a copy of RevenueDay
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $RevenueDayCopyWith<RevenueDay> get copyWith =>
      _$RevenueDayCopyWithImpl<RevenueDay>(this as RevenueDay, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is RevenueDay &&
            (identical(other.day, day) || other.day == day) &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.today, today) || other.today == today));
  }

  @override
  int get hashCode => Object.hash(runtimeType, day, value, today);

  @override
  String toString() {
    return 'RevenueDay(day: $day, value: $value, today: $today)';
  }
}

/// @nodoc
abstract mixin class $RevenueDayCopyWith<$Res> {
  factory $RevenueDayCopyWith(
          RevenueDay value, $Res Function(RevenueDay) _then) =
      _$RevenueDayCopyWithImpl;
  @useResult
  $Res call({String day, int value, bool today});
}

/// @nodoc
class _$RevenueDayCopyWithImpl<$Res> implements $RevenueDayCopyWith<$Res> {
  _$RevenueDayCopyWithImpl(this._self, this._then);

  final RevenueDay _self;
  final $Res Function(RevenueDay) _then;

  /// Create a copy of RevenueDay
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? day = null,
    Object? value = null,
    Object? today = null,
  }) {
    return _then(_self.copyWith(
      day: null == day
          ? _self.day
          : day // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _self.value
          : value // ignore: cast_nullable_to_non_nullable
              as int,
      today: null == today
          ? _self.today
          : today // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// Adds pattern-matching-related methods to [RevenueDay].
extension RevenueDayPatterns on RevenueDay {
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
    TResult Function(_RevenueDay value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _RevenueDay() when $default != null:
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
    TResult Function(_RevenueDay value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RevenueDay():
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
    TResult? Function(_RevenueDay value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RevenueDay() when $default != null:
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
    TResult Function(String day, int value, bool today)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _RevenueDay() when $default != null:
        return $default(_that.day, _that.value, _that.today);
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
    TResult Function(String day, int value, bool today) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RevenueDay():
        return $default(_that.day, _that.value, _that.today);
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
    TResult? Function(String day, int value, bool today)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RevenueDay() when $default != null:
        return $default(_that.day, _that.value, _that.today);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _RevenueDay implements RevenueDay {
  const _RevenueDay(
      {required this.day, required this.value, this.today = false});

  @override
  final String day;
  @override
  final int value;
  @override
  @JsonKey()
  final bool today;

  /// Create a copy of RevenueDay
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$RevenueDayCopyWith<_RevenueDay> get copyWith =>
      __$RevenueDayCopyWithImpl<_RevenueDay>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _RevenueDay &&
            (identical(other.day, day) || other.day == day) &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.today, today) || other.today == today));
  }

  @override
  int get hashCode => Object.hash(runtimeType, day, value, today);

  @override
  String toString() {
    return 'RevenueDay(day: $day, value: $value, today: $today)';
  }
}

/// @nodoc
abstract mixin class _$RevenueDayCopyWith<$Res>
    implements $RevenueDayCopyWith<$Res> {
  factory _$RevenueDayCopyWith(
          _RevenueDay value, $Res Function(_RevenueDay) _then) =
      __$RevenueDayCopyWithImpl;
  @override
  @useResult
  $Res call({String day, int value, bool today});
}

/// @nodoc
class __$RevenueDayCopyWithImpl<$Res> implements _$RevenueDayCopyWith<$Res> {
  __$RevenueDayCopyWithImpl(this._self, this._then);

  final _RevenueDay _self;
  final $Res Function(_RevenueDay) _then;

  /// Create a copy of RevenueDay
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? day = null,
    Object? value = null,
    Object? today = null,
  }) {
    return _then(_RevenueDay(
      day: null == day
          ? _self.day
          : day // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _self.value
          : value // ignore: cast_nullable_to_non_nullable
              as int,
      today: null == today
          ? _self.today
          : today // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
mixin _$CourtStatusRow {
  String get id;
  String get name;
  int get venues;
  int get occupancy;
  CourtState get status;

  /// Create a copy of CourtStatusRow
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CourtStatusRowCopyWith<CourtStatusRow> get copyWith =>
      _$CourtStatusRowCopyWithImpl<CourtStatusRow>(
          this as CourtStatusRow, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CourtStatusRow &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.venues, venues) || other.venues == venues) &&
            (identical(other.occupancy, occupancy) ||
                other.occupancy == occupancy) &&
            (identical(other.status, status) || other.status == status));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, venues, occupancy, status);

  @override
  String toString() {
    return 'CourtStatusRow(id: $id, name: $name, venues: $venues, occupancy: $occupancy, status: $status)';
  }
}

/// @nodoc
abstract mixin class $CourtStatusRowCopyWith<$Res> {
  factory $CourtStatusRowCopyWith(
          CourtStatusRow value, $Res Function(CourtStatusRow) _then) =
      _$CourtStatusRowCopyWithImpl;
  @useResult
  $Res call(
      {String id, String name, int venues, int occupancy, CourtState status});
}

/// @nodoc
class _$CourtStatusRowCopyWithImpl<$Res>
    implements $CourtStatusRowCopyWith<$Res> {
  _$CourtStatusRowCopyWithImpl(this._self, this._then);

  final CourtStatusRow _self;
  final $Res Function(CourtStatusRow) _then;

  /// Create a copy of CourtStatusRow
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? venues = null,
    Object? occupancy = null,
    Object? status = null,
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
      venues: null == venues
          ? _self.venues
          : venues // ignore: cast_nullable_to_non_nullable
              as int,
      occupancy: null == occupancy
          ? _self.occupancy
          : occupancy // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as CourtState,
    ));
  }
}

/// Adds pattern-matching-related methods to [CourtStatusRow].
extension CourtStatusRowPatterns on CourtStatusRow {
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
    TResult Function(_CourtStatusRow value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CourtStatusRow() when $default != null:
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
    TResult Function(_CourtStatusRow value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CourtStatusRow():
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
    TResult? Function(_CourtStatusRow value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CourtStatusRow() when $default != null:
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
    TResult Function(String id, String name, int venues, int occupancy,
            CourtState status)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CourtStatusRow() when $default != null:
        return $default(
            _that.id, _that.name, _that.venues, _that.occupancy, _that.status);
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
    TResult Function(String id, String name, int venues, int occupancy,
            CourtState status)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CourtStatusRow():
        return $default(
            _that.id, _that.name, _that.venues, _that.occupancy, _that.status);
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
    TResult? Function(String id, String name, int venues, int occupancy,
            CourtState status)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CourtStatusRow() when $default != null:
        return $default(
            _that.id, _that.name, _that.venues, _that.occupancy, _that.status);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _CourtStatusRow implements CourtStatusRow {
  const _CourtStatusRow(
      {required this.id,
      required this.name,
      required this.venues,
      required this.occupancy,
      required this.status});

  @override
  final String id;
  @override
  final String name;
  @override
  final int venues;
  @override
  final int occupancy;
  @override
  final CourtState status;

  /// Create a copy of CourtStatusRow
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CourtStatusRowCopyWith<_CourtStatusRow> get copyWith =>
      __$CourtStatusRowCopyWithImpl<_CourtStatusRow>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CourtStatusRow &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.venues, venues) || other.venues == venues) &&
            (identical(other.occupancy, occupancy) ||
                other.occupancy == occupancy) &&
            (identical(other.status, status) || other.status == status));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, venues, occupancy, status);

  @override
  String toString() {
    return 'CourtStatusRow(id: $id, name: $name, venues: $venues, occupancy: $occupancy, status: $status)';
  }
}

/// @nodoc
abstract mixin class _$CourtStatusRowCopyWith<$Res>
    implements $CourtStatusRowCopyWith<$Res> {
  factory _$CourtStatusRowCopyWith(
          _CourtStatusRow value, $Res Function(_CourtStatusRow) _then) =
      __$CourtStatusRowCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id, String name, int venues, int occupancy, CourtState status});
}

/// @nodoc
class __$CourtStatusRowCopyWithImpl<$Res>
    implements _$CourtStatusRowCopyWith<$Res> {
  __$CourtStatusRowCopyWithImpl(this._self, this._then);

  final _CourtStatusRow _self;
  final $Res Function(_CourtStatusRow) _then;

  /// Create a copy of CourtStatusRow
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? venues = null,
    Object? occupancy = null,
    Object? status = null,
  }) {
    return _then(_CourtStatusRow(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      venues: null == venues
          ? _self.venues
          : venues // ignore: cast_nullable_to_non_nullable
              as int,
      occupancy: null == occupancy
          ? _self.occupancy
          : occupancy // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as CourtState,
    ));
  }
}

// dart format on
