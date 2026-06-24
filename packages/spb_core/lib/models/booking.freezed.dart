// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'booking.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Booking {
  String get id;

  /// Human-facing reference code (e.g. dashboard request code). Optional.
  String? get code;

  /// Owner of the booking (customer user id).
  String? get userId;

  /// `pending` | `confirmed` | `declined` | `cancelled` | `completed`.
  String get status;

  /// `private` | `open` — who may join the booked slots.
  String get accessPolicy;
  String? get courtId;
  String? get courtName;
  String? get venueName;
  String? get sportType;
  List<Slot> get slots;

  /// Total price in VND.
  int get totalPrice;
  int get maxPlayers;

  /// Contact details, mainly for the owner-facing dashboard.
  String? get customerName;
  String? get customerPhone;
  String? get note;

  /// `oneOff` | `recurring`.
  String get bookingType;
  int? get sessionNumber;
  int? get totalSessions;
  bool get isAutoApproved;
  DateTime? get createdAt;
  DateTime? get confirmedAt;

  /// Create a copy of Booking
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $BookingCopyWith<Booking> get copyWith =>
      _$BookingCopyWithImpl<Booking>(this as Booking, _$identity);

  /// Serializes this Booking to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Booking &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.accessPolicy, accessPolicy) ||
                other.accessPolicy == accessPolicy) &&
            (identical(other.courtId, courtId) || other.courtId == courtId) &&
            (identical(other.courtName, courtName) ||
                other.courtName == courtName) &&
            (identical(other.venueName, venueName) ||
                other.venueName == venueName) &&
            (identical(other.sportType, sportType) ||
                other.sportType == sportType) &&
            const DeepCollectionEquality().equals(other.slots, slots) &&
            (identical(other.totalPrice, totalPrice) ||
                other.totalPrice == totalPrice) &&
            (identical(other.maxPlayers, maxPlayers) ||
                other.maxPlayers == maxPlayers) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.customerPhone, customerPhone) ||
                other.customerPhone == customerPhone) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.bookingType, bookingType) ||
                other.bookingType == bookingType) &&
            (identical(other.sessionNumber, sessionNumber) ||
                other.sessionNumber == sessionNumber) &&
            (identical(other.totalSessions, totalSessions) ||
                other.totalSessions == totalSessions) &&
            (identical(other.isAutoApproved, isAutoApproved) ||
                other.isAutoApproved == isAutoApproved) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.confirmedAt, confirmedAt) ||
                other.confirmedAt == confirmedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        code,
        userId,
        status,
        accessPolicy,
        courtId,
        courtName,
        venueName,
        sportType,
        const DeepCollectionEquality().hash(slots),
        totalPrice,
        maxPlayers,
        customerName,
        customerPhone,
        note,
        bookingType,
        sessionNumber,
        totalSessions,
        isAutoApproved,
        createdAt,
        confirmedAt
      ]);

  @override
  String toString() {
    return 'Booking(id: $id, code: $code, userId: $userId, status: $status, accessPolicy: $accessPolicy, courtId: $courtId, courtName: $courtName, venueName: $venueName, sportType: $sportType, slots: $slots, totalPrice: $totalPrice, maxPlayers: $maxPlayers, customerName: $customerName, customerPhone: $customerPhone, note: $note, bookingType: $bookingType, sessionNumber: $sessionNumber, totalSessions: $totalSessions, isAutoApproved: $isAutoApproved, createdAt: $createdAt, confirmedAt: $confirmedAt)';
  }
}

/// @nodoc
abstract mixin class $BookingCopyWith<$Res> {
  factory $BookingCopyWith(Booking value, $Res Function(Booking) _then) =
      _$BookingCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String? code,
      String? userId,
      String status,
      String accessPolicy,
      String? courtId,
      String? courtName,
      String? venueName,
      String? sportType,
      List<Slot> slots,
      int totalPrice,
      int maxPlayers,
      String? customerName,
      String? customerPhone,
      String? note,
      String bookingType,
      int? sessionNumber,
      int? totalSessions,
      bool isAutoApproved,
      DateTime? createdAt,
      DateTime? confirmedAt});
}

/// @nodoc
class _$BookingCopyWithImpl<$Res> implements $BookingCopyWith<$Res> {
  _$BookingCopyWithImpl(this._self, this._then);

  final Booking _self;
  final $Res Function(Booking) _then;

  /// Create a copy of Booking
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = freezed,
    Object? userId = freezed,
    Object? status = null,
    Object? accessPolicy = null,
    Object? courtId = freezed,
    Object? courtName = freezed,
    Object? venueName = freezed,
    Object? sportType = freezed,
    Object? slots = null,
    Object? totalPrice = null,
    Object? maxPlayers = null,
    Object? customerName = freezed,
    Object? customerPhone = freezed,
    Object? note = freezed,
    Object? bookingType = null,
    Object? sessionNumber = freezed,
    Object? totalSessions = freezed,
    Object? isAutoApproved = null,
    Object? createdAt = freezed,
    Object? confirmedAt = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      code: freezed == code
          ? _self.code
          : code // ignore: cast_nullable_to_non_nullable
              as String?,
      userId: freezed == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      accessPolicy: null == accessPolicy
          ? _self.accessPolicy
          : accessPolicy // ignore: cast_nullable_to_non_nullable
              as String,
      courtId: freezed == courtId
          ? _self.courtId
          : courtId // ignore: cast_nullable_to_non_nullable
              as String?,
      courtName: freezed == courtName
          ? _self.courtName
          : courtName // ignore: cast_nullable_to_non_nullable
              as String?,
      venueName: freezed == venueName
          ? _self.venueName
          : venueName // ignore: cast_nullable_to_non_nullable
              as String?,
      sportType: freezed == sportType
          ? _self.sportType
          : sportType // ignore: cast_nullable_to_non_nullable
              as String?,
      slots: null == slots
          ? _self.slots
          : slots // ignore: cast_nullable_to_non_nullable
              as List<Slot>,
      totalPrice: null == totalPrice
          ? _self.totalPrice
          : totalPrice // ignore: cast_nullable_to_non_nullable
              as int,
      maxPlayers: null == maxPlayers
          ? _self.maxPlayers
          : maxPlayers // ignore: cast_nullable_to_non_nullable
              as int,
      customerName: freezed == customerName
          ? _self.customerName
          : customerName // ignore: cast_nullable_to_non_nullable
              as String?,
      customerPhone: freezed == customerPhone
          ? _self.customerPhone
          : customerPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      note: freezed == note
          ? _self.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      bookingType: null == bookingType
          ? _self.bookingType
          : bookingType // ignore: cast_nullable_to_non_nullable
              as String,
      sessionNumber: freezed == sessionNumber
          ? _self.sessionNumber
          : sessionNumber // ignore: cast_nullable_to_non_nullable
              as int?,
      totalSessions: freezed == totalSessions
          ? _self.totalSessions
          : totalSessions // ignore: cast_nullable_to_non_nullable
              as int?,
      isAutoApproved: null == isAutoApproved
          ? _self.isAutoApproved
          : isAutoApproved // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      confirmedAt: freezed == confirmedAt
          ? _self.confirmedAt
          : confirmedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
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

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_Booking value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Booking() when $default != null:
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
    TResult Function(_Booking value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Booking():
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
    TResult? Function(_Booking value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Booking() when $default != null:
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
            String? code,
            String? userId,
            String status,
            String accessPolicy,
            String? courtId,
            String? courtName,
            String? venueName,
            String? sportType,
            List<Slot> slots,
            int totalPrice,
            int maxPlayers,
            String? customerName,
            String? customerPhone,
            String? note,
            String bookingType,
            int? sessionNumber,
            int? totalSessions,
            bool isAutoApproved,
            DateTime? createdAt,
            DateTime? confirmedAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Booking() when $default != null:
        return $default(
            _that.id,
            _that.code,
            _that.userId,
            _that.status,
            _that.accessPolicy,
            _that.courtId,
            _that.courtName,
            _that.venueName,
            _that.sportType,
            _that.slots,
            _that.totalPrice,
            _that.maxPlayers,
            _that.customerName,
            _that.customerPhone,
            _that.note,
            _that.bookingType,
            _that.sessionNumber,
            _that.totalSessions,
            _that.isAutoApproved,
            _that.createdAt,
            _that.confirmedAt);
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
            String? code,
            String? userId,
            String status,
            String accessPolicy,
            String? courtId,
            String? courtName,
            String? venueName,
            String? sportType,
            List<Slot> slots,
            int totalPrice,
            int maxPlayers,
            String? customerName,
            String? customerPhone,
            String? note,
            String bookingType,
            int? sessionNumber,
            int? totalSessions,
            bool isAutoApproved,
            DateTime? createdAt,
            DateTime? confirmedAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Booking():
        return $default(
            _that.id,
            _that.code,
            _that.userId,
            _that.status,
            _that.accessPolicy,
            _that.courtId,
            _that.courtName,
            _that.venueName,
            _that.sportType,
            _that.slots,
            _that.totalPrice,
            _that.maxPlayers,
            _that.customerName,
            _that.customerPhone,
            _that.note,
            _that.bookingType,
            _that.sessionNumber,
            _that.totalSessions,
            _that.isAutoApproved,
            _that.createdAt,
            _that.confirmedAt);
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
            String? code,
            String? userId,
            String status,
            String accessPolicy,
            String? courtId,
            String? courtName,
            String? venueName,
            String? sportType,
            List<Slot> slots,
            int totalPrice,
            int maxPlayers,
            String? customerName,
            String? customerPhone,
            String? note,
            String bookingType,
            int? sessionNumber,
            int? totalSessions,
            bool isAutoApproved,
            DateTime? createdAt,
            DateTime? confirmedAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Booking() when $default != null:
        return $default(
            _that.id,
            _that.code,
            _that.userId,
            _that.status,
            _that.accessPolicy,
            _that.courtId,
            _that.courtName,
            _that.venueName,
            _that.sportType,
            _that.slots,
            _that.totalPrice,
            _that.maxPlayers,
            _that.customerName,
            _that.customerPhone,
            _that.note,
            _that.bookingType,
            _that.sessionNumber,
            _that.totalSessions,
            _that.isAutoApproved,
            _that.createdAt,
            _that.confirmedAt);
      case _:
        return null;
    }
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _Booking extends Booking {
  const _Booking(
      {required this.id,
      this.code,
      this.userId,
      this.status = 'pending',
      this.accessPolicy = 'private',
      this.courtId,
      this.courtName,
      this.venueName,
      this.sportType,
      final List<Slot> slots = const <Slot>[],
      this.totalPrice = 0,
      this.maxPlayers = 1,
      this.customerName,
      this.customerPhone,
      this.note,
      this.bookingType = 'oneOff',
      this.sessionNumber,
      this.totalSessions,
      this.isAutoApproved = false,
      this.createdAt,
      this.confirmedAt})
      : _slots = slots,
        super._();
  factory _Booking.fromJson(Map<String, dynamic> json) =>
      _$BookingFromJson(json);

  @override
  final String id;

  /// Human-facing reference code (e.g. dashboard request code). Optional.
  @override
  final String? code;

  /// Owner of the booking (customer user id).
  @override
  final String? userId;

  /// `pending` | `confirmed` | `declined` | `cancelled` | `completed`.
  @override
  @JsonKey()
  final String status;

  /// `private` | `open` — who may join the booked slots.
  @override
  @JsonKey()
  final String accessPolicy;
  @override
  final String? courtId;
  @override
  final String? courtName;
  @override
  final String? venueName;
  @override
  final String? sportType;
  final List<Slot> _slots;
  @override
  @JsonKey()
  List<Slot> get slots {
    if (_slots is EqualUnmodifiableListView) return _slots;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_slots);
  }

  /// Total price in VND.
  @override
  @JsonKey()
  final int totalPrice;
  @override
  @JsonKey()
  final int maxPlayers;

  /// Contact details, mainly for the owner-facing dashboard.
  @override
  final String? customerName;
  @override
  final String? customerPhone;
  @override
  final String? note;

  /// `oneOff` | `recurring`.
  @override
  @JsonKey()
  final String bookingType;
  @override
  final int? sessionNumber;
  @override
  final int? totalSessions;
  @override
  @JsonKey()
  final bool isAutoApproved;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? confirmedAt;

  /// Create a copy of Booking
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$BookingCopyWith<_Booking> get copyWith =>
      __$BookingCopyWithImpl<_Booking>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$BookingToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Booking &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.accessPolicy, accessPolicy) ||
                other.accessPolicy == accessPolicy) &&
            (identical(other.courtId, courtId) || other.courtId == courtId) &&
            (identical(other.courtName, courtName) ||
                other.courtName == courtName) &&
            (identical(other.venueName, venueName) ||
                other.venueName == venueName) &&
            (identical(other.sportType, sportType) ||
                other.sportType == sportType) &&
            const DeepCollectionEquality().equals(other._slots, _slots) &&
            (identical(other.totalPrice, totalPrice) ||
                other.totalPrice == totalPrice) &&
            (identical(other.maxPlayers, maxPlayers) ||
                other.maxPlayers == maxPlayers) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.customerPhone, customerPhone) ||
                other.customerPhone == customerPhone) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.bookingType, bookingType) ||
                other.bookingType == bookingType) &&
            (identical(other.sessionNumber, sessionNumber) ||
                other.sessionNumber == sessionNumber) &&
            (identical(other.totalSessions, totalSessions) ||
                other.totalSessions == totalSessions) &&
            (identical(other.isAutoApproved, isAutoApproved) ||
                other.isAutoApproved == isAutoApproved) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.confirmedAt, confirmedAt) ||
                other.confirmedAt == confirmedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        code,
        userId,
        status,
        accessPolicy,
        courtId,
        courtName,
        venueName,
        sportType,
        const DeepCollectionEquality().hash(_slots),
        totalPrice,
        maxPlayers,
        customerName,
        customerPhone,
        note,
        bookingType,
        sessionNumber,
        totalSessions,
        isAutoApproved,
        createdAt,
        confirmedAt
      ]);

  @override
  String toString() {
    return 'Booking(id: $id, code: $code, userId: $userId, status: $status, accessPolicy: $accessPolicy, courtId: $courtId, courtName: $courtName, venueName: $venueName, sportType: $sportType, slots: $slots, totalPrice: $totalPrice, maxPlayers: $maxPlayers, customerName: $customerName, customerPhone: $customerPhone, note: $note, bookingType: $bookingType, sessionNumber: $sessionNumber, totalSessions: $totalSessions, isAutoApproved: $isAutoApproved, createdAt: $createdAt, confirmedAt: $confirmedAt)';
  }
}

/// @nodoc
abstract mixin class _$BookingCopyWith<$Res> implements $BookingCopyWith<$Res> {
  factory _$BookingCopyWith(_Booking value, $Res Function(_Booking) _then) =
      __$BookingCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String? code,
      String? userId,
      String status,
      String accessPolicy,
      String? courtId,
      String? courtName,
      String? venueName,
      String? sportType,
      List<Slot> slots,
      int totalPrice,
      int maxPlayers,
      String? customerName,
      String? customerPhone,
      String? note,
      String bookingType,
      int? sessionNumber,
      int? totalSessions,
      bool isAutoApproved,
      DateTime? createdAt,
      DateTime? confirmedAt});
}

/// @nodoc
class __$BookingCopyWithImpl<$Res> implements _$BookingCopyWith<$Res> {
  __$BookingCopyWithImpl(this._self, this._then);

  final _Booking _self;
  final $Res Function(_Booking) _then;

  /// Create a copy of Booking
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? code = freezed,
    Object? userId = freezed,
    Object? status = null,
    Object? accessPolicy = null,
    Object? courtId = freezed,
    Object? courtName = freezed,
    Object? venueName = freezed,
    Object? sportType = freezed,
    Object? slots = null,
    Object? totalPrice = null,
    Object? maxPlayers = null,
    Object? customerName = freezed,
    Object? customerPhone = freezed,
    Object? note = freezed,
    Object? bookingType = null,
    Object? sessionNumber = freezed,
    Object? totalSessions = freezed,
    Object? isAutoApproved = null,
    Object? createdAt = freezed,
    Object? confirmedAt = freezed,
  }) {
    return _then(_Booking(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      code: freezed == code
          ? _self.code
          : code // ignore: cast_nullable_to_non_nullable
              as String?,
      userId: freezed == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      accessPolicy: null == accessPolicy
          ? _self.accessPolicy
          : accessPolicy // ignore: cast_nullable_to_non_nullable
              as String,
      courtId: freezed == courtId
          ? _self.courtId
          : courtId // ignore: cast_nullable_to_non_nullable
              as String?,
      courtName: freezed == courtName
          ? _self.courtName
          : courtName // ignore: cast_nullable_to_non_nullable
              as String?,
      venueName: freezed == venueName
          ? _self.venueName
          : venueName // ignore: cast_nullable_to_non_nullable
              as String?,
      sportType: freezed == sportType
          ? _self.sportType
          : sportType // ignore: cast_nullable_to_non_nullable
              as String?,
      slots: null == slots
          ? _self._slots
          : slots // ignore: cast_nullable_to_non_nullable
              as List<Slot>,
      totalPrice: null == totalPrice
          ? _self.totalPrice
          : totalPrice // ignore: cast_nullable_to_non_nullable
              as int,
      maxPlayers: null == maxPlayers
          ? _self.maxPlayers
          : maxPlayers // ignore: cast_nullable_to_non_nullable
              as int,
      customerName: freezed == customerName
          ? _self.customerName
          : customerName // ignore: cast_nullable_to_non_nullable
              as String?,
      customerPhone: freezed == customerPhone
          ? _self.customerPhone
          : customerPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      note: freezed == note
          ? _self.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      bookingType: null == bookingType
          ? _self.bookingType
          : bookingType // ignore: cast_nullable_to_non_nullable
              as String,
      sessionNumber: freezed == sessionNumber
          ? _self.sessionNumber
          : sessionNumber // ignore: cast_nullable_to_non_nullable
              as int?,
      totalSessions: freezed == totalSessions
          ? _self.totalSessions
          : totalSessions // ignore: cast_nullable_to_non_nullable
              as int?,
      isAutoApproved: null == isAutoApproved
          ? _self.isAutoApproved
          : isAutoApproved // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      confirmedAt: freezed == confirmedAt
          ? _self.confirmedAt
          : confirmedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

// dart format on
