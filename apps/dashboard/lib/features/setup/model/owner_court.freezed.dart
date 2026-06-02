// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'owner_court.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OwnerCourt {
  String get id;
  String get name;

  /// `courts.status` mapped to a bool — 'inactive' → false, anything else → true.
  @JsonKey(
      name: 'status', fromJson: _activeFromStatus, toJson: _statusFromActive)
  bool get isActive;

  /// `courts.operating_hours  jsonb` — `{"open": 6, "close": 22}`.
  /// Use [openHour] / [closeHour] getters for typed access.
  @JsonKey(name: 'operating_hours')
  Map<String, dynamic>? get operatingHours;

  /// `courts.address`
  String? get address;

  /// `courts.description`
  String? get description;

  /// `courts.amenities  text[]`
  List<String> get amenities;

  /// `courts.lat` / `courts.lng`
  double? get lat;
  double? get lng;

  /// `courts.auto_approve_single` — OWNER-44/45
  @JsonKey(name: 'auto_approve_single')
  bool get autoApproveSingle;

  /// `courts.additional_info  jsonb` — arbitrary key/value metadata.
  /// Known keys: `google_maps_url`.
  @JsonKey(name: 'additional_info')
  Map<String, dynamic> get additionalInfo;

  /// Create a copy of OwnerCourt
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $OwnerCourtCopyWith<OwnerCourt> get copyWith =>
      _$OwnerCourtCopyWithImpl<OwnerCourt>(this as OwnerCourt, _$identity);

  /// Serializes this OwnerCourt to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is OwnerCourt &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            const DeepCollectionEquality()
                .equals(other.operatingHours, operatingHours) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other.amenities, amenities) &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lng, lng) || other.lng == lng) &&
            (identical(other.autoApproveSingle, autoApproveSingle) ||
                other.autoApproveSingle == autoApproveSingle) &&
            const DeepCollectionEquality()
                .equals(other.additionalInfo, additionalInfo));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      isActive,
      const DeepCollectionEquality().hash(operatingHours),
      address,
      description,
      const DeepCollectionEquality().hash(amenities),
      lat,
      lng,
      autoApproveSingle,
      const DeepCollectionEquality().hash(additionalInfo));

  @override
  String toString() {
    return 'OwnerCourt(id: $id, name: $name, isActive: $isActive, operatingHours: $operatingHours, address: $address, description: $description, amenities: $amenities, lat: $lat, lng: $lng, autoApproveSingle: $autoApproveSingle, additionalInfo: $additionalInfo)';
  }
}

/// @nodoc
abstract mixin class $OwnerCourtCopyWith<$Res> {
  factory $OwnerCourtCopyWith(
          OwnerCourt value, $Res Function(OwnerCourt) _then) =
      _$OwnerCourtCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String name,
      @JsonKey(
          name: 'status',
          fromJson: _activeFromStatus,
          toJson: _statusFromActive)
      bool isActive,
      @JsonKey(name: 'operating_hours') Map<String, dynamic>? operatingHours,
      String? address,
      String? description,
      List<String> amenities,
      double? lat,
      double? lng,
      @JsonKey(name: 'auto_approve_single') bool autoApproveSingle,
      @JsonKey(name: 'additional_info') Map<String, dynamic> additionalInfo});
}

/// @nodoc
class _$OwnerCourtCopyWithImpl<$Res> implements $OwnerCourtCopyWith<$Res> {
  _$OwnerCourtCopyWithImpl(this._self, this._then);

  final OwnerCourt _self;
  final $Res Function(OwnerCourt) _then;

  /// Create a copy of OwnerCourt
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? isActive = null,
    Object? operatingHours = freezed,
    Object? address = freezed,
    Object? description = freezed,
    Object? amenities = null,
    Object? lat = freezed,
    Object? lng = freezed,
    Object? autoApproveSingle = null,
    Object? additionalInfo = null,
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
      isActive: null == isActive
          ? _self.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      operatingHours: freezed == operatingHours
          ? _self.operatingHours
          : operatingHours // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      address: freezed == address
          ? _self.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      amenities: null == amenities
          ? _self.amenities
          : amenities // ignore: cast_nullable_to_non_nullable
              as List<String>,
      lat: freezed == lat
          ? _self.lat
          : lat // ignore: cast_nullable_to_non_nullable
              as double?,
      lng: freezed == lng
          ? _self.lng
          : lng // ignore: cast_nullable_to_non_nullable
              as double?,
      autoApproveSingle: null == autoApproveSingle
          ? _self.autoApproveSingle
          : autoApproveSingle // ignore: cast_nullable_to_non_nullable
              as bool,
      additionalInfo: null == additionalInfo
          ? _self.additionalInfo
          : additionalInfo // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// Adds pattern-matching-related methods to [OwnerCourt].
extension OwnerCourtPatterns on OwnerCourt {
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
    TResult Function(_OwnerCourt value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _OwnerCourt() when $default != null:
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
    TResult Function(_OwnerCourt value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OwnerCourt():
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
    TResult? Function(_OwnerCourt value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OwnerCourt() when $default != null:
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
            @JsonKey(
                name: 'status',
                fromJson: _activeFromStatus,
                toJson: _statusFromActive)
            bool isActive,
            @JsonKey(name: 'operating_hours')
            Map<String, dynamic>? operatingHours,
            String? address,
            String? description,
            List<String> amenities,
            double? lat,
            double? lng,
            @JsonKey(name: 'auto_approve_single') bool autoApproveSingle,
            @JsonKey(name: 'additional_info')
            Map<String, dynamic> additionalInfo)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _OwnerCourt() when $default != null:
        return $default(
            _that.id,
            _that.name,
            _that.isActive,
            _that.operatingHours,
            _that.address,
            _that.description,
            _that.amenities,
            _that.lat,
            _that.lng,
            _that.autoApproveSingle,
            _that.additionalInfo);
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
            @JsonKey(
                name: 'status',
                fromJson: _activeFromStatus,
                toJson: _statusFromActive)
            bool isActive,
            @JsonKey(name: 'operating_hours')
            Map<String, dynamic>? operatingHours,
            String? address,
            String? description,
            List<String> amenities,
            double? lat,
            double? lng,
            @JsonKey(name: 'auto_approve_single') bool autoApproveSingle,
            @JsonKey(name: 'additional_info')
            Map<String, dynamic> additionalInfo)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OwnerCourt():
        return $default(
            _that.id,
            _that.name,
            _that.isActive,
            _that.operatingHours,
            _that.address,
            _that.description,
            _that.amenities,
            _that.lat,
            _that.lng,
            _that.autoApproveSingle,
            _that.additionalInfo);
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
            @JsonKey(
                name: 'status',
                fromJson: _activeFromStatus,
                toJson: _statusFromActive)
            bool isActive,
            @JsonKey(name: 'operating_hours')
            Map<String, dynamic>? operatingHours,
            String? address,
            String? description,
            List<String> amenities,
            double? lat,
            double? lng,
            @JsonKey(name: 'auto_approve_single') bool autoApproveSingle,
            @JsonKey(name: 'additional_info')
            Map<String, dynamic> additionalInfo)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OwnerCourt() when $default != null:
        return $default(
            _that.id,
            _that.name,
            _that.isActive,
            _that.operatingHours,
            _that.address,
            _that.description,
            _that.amenities,
            _that.lat,
            _that.lng,
            _that.autoApproveSingle,
            _that.additionalInfo);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _OwnerCourt extends OwnerCourt {
  const _OwnerCourt(
      {required this.id,
      required this.name,
      @JsonKey(
          name: 'status',
          fromJson: _activeFromStatus,
          toJson: _statusFromActive)
      required this.isActive,
      @JsonKey(name: 'operating_hours')
      final Map<String, dynamic>? operatingHours,
      this.address,
      this.description,
      final List<String> amenities = const [],
      this.lat,
      this.lng,
      @JsonKey(name: 'auto_approve_single') this.autoApproveSingle = false,
      @JsonKey(name: 'additional_info')
      final Map<String, dynamic> additionalInfo = const {}})
      : _operatingHours = operatingHours,
        _amenities = amenities,
        _additionalInfo = additionalInfo,
        super._();
  factory _OwnerCourt.fromJson(Map<String, dynamic> json) =>
      _$OwnerCourtFromJson(json);

  @override
  final String id;
  @override
  final String name;

  /// `courts.status` mapped to a bool — 'inactive' → false, anything else → true.
  @override
  @JsonKey(
      name: 'status', fromJson: _activeFromStatus, toJson: _statusFromActive)
  final bool isActive;

  /// `courts.operating_hours  jsonb` — `{"open": 6, "close": 22}`.
  /// Use [openHour] / [closeHour] getters for typed access.
  final Map<String, dynamic>? _operatingHours;

  /// `courts.operating_hours  jsonb` — `{"open": 6, "close": 22}`.
  /// Use [openHour] / [closeHour] getters for typed access.
  @override
  @JsonKey(name: 'operating_hours')
  Map<String, dynamic>? get operatingHours {
    final value = _operatingHours;
    if (value == null) return null;
    if (_operatingHours is EqualUnmodifiableMapView) return _operatingHours;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  /// `courts.address`
  @override
  final String? address;

  /// `courts.description`
  @override
  final String? description;

  /// `courts.amenities  text[]`
  final List<String> _amenities;

  /// `courts.amenities  text[]`
  @override
  @JsonKey()
  List<String> get amenities {
    if (_amenities is EqualUnmodifiableListView) return _amenities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_amenities);
  }

  /// `courts.lat` / `courts.lng`
  @override
  final double? lat;
  @override
  final double? lng;

  /// `courts.auto_approve_single` — OWNER-44/45
  @override
  @JsonKey(name: 'auto_approve_single')
  final bool autoApproveSingle;

  /// `courts.additional_info  jsonb` — arbitrary key/value metadata.
  /// Known keys: `google_maps_url`.
  final Map<String, dynamic> _additionalInfo;

  /// `courts.additional_info  jsonb` — arbitrary key/value metadata.
  /// Known keys: `google_maps_url`.
  @override
  @JsonKey(name: 'additional_info')
  Map<String, dynamic> get additionalInfo {
    if (_additionalInfo is EqualUnmodifiableMapView) return _additionalInfo;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_additionalInfo);
  }

  /// Create a copy of OwnerCourt
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$OwnerCourtCopyWith<_OwnerCourt> get copyWith =>
      __$OwnerCourtCopyWithImpl<_OwnerCourt>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$OwnerCourtToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _OwnerCourt &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            const DeepCollectionEquality()
                .equals(other._operatingHours, _operatingHours) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality()
                .equals(other._amenities, _amenities) &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lng, lng) || other.lng == lng) &&
            (identical(other.autoApproveSingle, autoApproveSingle) ||
                other.autoApproveSingle == autoApproveSingle) &&
            const DeepCollectionEquality()
                .equals(other._additionalInfo, _additionalInfo));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      isActive,
      const DeepCollectionEquality().hash(_operatingHours),
      address,
      description,
      const DeepCollectionEquality().hash(_amenities),
      lat,
      lng,
      autoApproveSingle,
      const DeepCollectionEquality().hash(_additionalInfo));

  @override
  String toString() {
    return 'OwnerCourt(id: $id, name: $name, isActive: $isActive, operatingHours: $operatingHours, address: $address, description: $description, amenities: $amenities, lat: $lat, lng: $lng, autoApproveSingle: $autoApproveSingle, additionalInfo: $additionalInfo)';
  }
}

/// @nodoc
abstract mixin class _$OwnerCourtCopyWith<$Res>
    implements $OwnerCourtCopyWith<$Res> {
  factory _$OwnerCourtCopyWith(
          _OwnerCourt value, $Res Function(_OwnerCourt) _then) =
      __$OwnerCourtCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      @JsonKey(
          name: 'status',
          fromJson: _activeFromStatus,
          toJson: _statusFromActive)
      bool isActive,
      @JsonKey(name: 'operating_hours') Map<String, dynamic>? operatingHours,
      String? address,
      String? description,
      List<String> amenities,
      double? lat,
      double? lng,
      @JsonKey(name: 'auto_approve_single') bool autoApproveSingle,
      @JsonKey(name: 'additional_info') Map<String, dynamic> additionalInfo});
}

/// @nodoc
class __$OwnerCourtCopyWithImpl<$Res> implements _$OwnerCourtCopyWith<$Res> {
  __$OwnerCourtCopyWithImpl(this._self, this._then);

  final _OwnerCourt _self;
  final $Res Function(_OwnerCourt) _then;

  /// Create a copy of OwnerCourt
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? isActive = null,
    Object? operatingHours = freezed,
    Object? address = freezed,
    Object? description = freezed,
    Object? amenities = null,
    Object? lat = freezed,
    Object? lng = freezed,
    Object? autoApproveSingle = null,
    Object? additionalInfo = null,
  }) {
    return _then(_OwnerCourt(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      isActive: null == isActive
          ? _self.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      operatingHours: freezed == operatingHours
          ? _self._operatingHours
          : operatingHours // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      address: freezed == address
          ? _self.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      amenities: null == amenities
          ? _self._amenities
          : amenities // ignore: cast_nullable_to_non_nullable
              as List<String>,
      lat: freezed == lat
          ? _self.lat
          : lat // ignore: cast_nullable_to_non_nullable
              as double?,
      lng: freezed == lng
          ? _self.lng
          : lng // ignore: cast_nullable_to_non_nullable
              as double?,
      autoApproveSingle: null == autoApproveSingle
          ? _self.autoApproveSingle
          : autoApproveSingle // ignore: cast_nullable_to_non_nullable
              as bool,
      additionalInfo: null == additionalInfo
          ? _self._additionalInfo
          : additionalInfo // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

// dart format on
