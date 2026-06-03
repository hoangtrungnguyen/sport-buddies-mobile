// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'booking_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BookingRequest {
  /// Raw `bookings.id` (UUID) — the stable key.
  String get id;

  /// Short, human-facing order code shown on the card (e.g. `#A1B2C3`).
  String get code;

  /// Display name of the customer (`Khách lẻ` when anonymous).
  String get customerName;

  /// Name of the booked court.
  String get courtName;

  /// Slot start (UTC). Render `.toLocal()`.
  DateTime get startAt;

  /// Slot end (UTC). Render `.toLocal()`.
  DateTime get endAt;
  BookingStatus get status;

  /// Resolved VND revenue (explicit total if > 0, else court price ×
  /// duration; `0` when neither is known).
  int get revenue;

  /// Linked `slots.id`, when the join provided it — needed to free the slot
  /// on reject (OWNER-29).
  String? get slotId;

  /// Customer phone. Per OWNER-28 it is only surfaced on the card **after**
  /// approval — see [revealedPhone], which gates on [status].
  String? get customerPhone;

  /// Whether this booking was auto-approved by the system (OWNER-45).
  /// Shown as a "Tự động" chip on confirmed cards.
  bool get isAutoApproved;

  /// Sport type from the venue (OWNER-213). Empty string when unavailable.
  String get sportType;

  /// Name of the specific venue (playable area) within the court (OWNER-226).
  /// Empty string when unavailable (e.g. court has no venues yet).
  String get venueName;

  /// Create a copy of BookingRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $BookingRequestCopyWith<BookingRequest> get copyWith =>
      _$BookingRequestCopyWithImpl<BookingRequest>(
          this as BookingRequest, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is BookingRequest &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.courtName, courtName) ||
                other.courtName == courtName) &&
            (identical(other.startAt, startAt) || other.startAt == startAt) &&
            (identical(other.endAt, endAt) || other.endAt == endAt) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.revenue, revenue) || other.revenue == revenue) &&
            (identical(other.slotId, slotId) || other.slotId == slotId) &&
            (identical(other.customerPhone, customerPhone) ||
                other.customerPhone == customerPhone) &&
            (identical(other.isAutoApproved, isAutoApproved) ||
                other.isAutoApproved == isAutoApproved) &&
            (identical(other.sportType, sportType) ||
                other.sportType == sportType) &&
            (identical(other.venueName, venueName) ||
                other.venueName == venueName));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      code,
      customerName,
      courtName,
      startAt,
      endAt,
      status,
      revenue,
      slotId,
      customerPhone,
      isAutoApproved,
      sportType,
      venueName);

  @override
  String toString() {
    return 'BookingRequest(id: $id, code: $code, customerName: $customerName, courtName: $courtName, startAt: $startAt, endAt: $endAt, status: $status, revenue: $revenue, slotId: $slotId, customerPhone: $customerPhone, isAutoApproved: $isAutoApproved, sportType: $sportType, venueName: $venueName)';
  }
}

/// @nodoc
abstract mixin class $BookingRequestCopyWith<$Res> {
  factory $BookingRequestCopyWith(
          BookingRequest value, $Res Function(BookingRequest) _then) =
      _$BookingRequestCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String code,
      String customerName,
      String courtName,
      DateTime startAt,
      DateTime endAt,
      BookingStatus status,
      int revenue,
      String? slotId,
      String? customerPhone,
      bool isAutoApproved,
      String sportType,
      String venueName});
}

/// @nodoc
class _$BookingRequestCopyWithImpl<$Res>
    implements $BookingRequestCopyWith<$Res> {
  _$BookingRequestCopyWithImpl(this._self, this._then);

  final BookingRequest _self;
  final $Res Function(BookingRequest) _then;

  /// Create a copy of BookingRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? customerName = null,
    Object? courtName = null,
    Object? startAt = null,
    Object? endAt = null,
    Object? status = null,
    Object? revenue = null,
    Object? slotId = freezed,
    Object? customerPhone = freezed,
    Object? isAutoApproved = null,
    Object? sportType = null,
    Object? venueName = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      code: null == code
          ? _self.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      customerName: null == customerName
          ? _self.customerName
          : customerName // ignore: cast_nullable_to_non_nullable
              as String,
      courtName: null == courtName
          ? _self.courtName
          : courtName // ignore: cast_nullable_to_non_nullable
              as String,
      startAt: null == startAt
          ? _self.startAt
          : startAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endAt: null == endAt
          ? _self.endAt
          : endAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as BookingStatus,
      revenue: null == revenue
          ? _self.revenue
          : revenue // ignore: cast_nullable_to_non_nullable
              as int,
      slotId: freezed == slotId
          ? _self.slotId
          : slotId // ignore: cast_nullable_to_non_nullable
              as String?,
      customerPhone: freezed == customerPhone
          ? _self.customerPhone
          : customerPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      isAutoApproved: null == isAutoApproved
          ? _self.isAutoApproved
          : isAutoApproved // ignore: cast_nullable_to_non_nullable
              as bool,
      sportType: null == sportType
          ? _self.sportType
          : sportType // ignore: cast_nullable_to_non_nullable
              as String,
      venueName: null == venueName
          ? _self.venueName
          : venueName // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [BookingRequest].
extension BookingRequestPatterns on BookingRequest {
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
    TResult Function(_BookingRequest value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _BookingRequest() when $default != null:
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
    TResult Function(_BookingRequest value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _BookingRequest():
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
    TResult? Function(_BookingRequest value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _BookingRequest() when $default != null:
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
            String code,
            String customerName,
            String courtName,
            DateTime startAt,
            DateTime endAt,
            BookingStatus status,
            int revenue,
            String? slotId,
            String? customerPhone,
            bool isAutoApproved,
            String sportType,
            String venueName)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _BookingRequest() when $default != null:
        return $default(
            _that.id,
            _that.code,
            _that.customerName,
            _that.courtName,
            _that.startAt,
            _that.endAt,
            _that.status,
            _that.revenue,
            _that.slotId,
            _that.customerPhone,
            _that.isAutoApproved,
            _that.sportType,
            _that.venueName);
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
            String code,
            String customerName,
            String courtName,
            DateTime startAt,
            DateTime endAt,
            BookingStatus status,
            int revenue,
            String? slotId,
            String? customerPhone,
            bool isAutoApproved,
            String sportType,
            String venueName)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _BookingRequest():
        return $default(
            _that.id,
            _that.code,
            _that.customerName,
            _that.courtName,
            _that.startAt,
            _that.endAt,
            _that.status,
            _that.revenue,
            _that.slotId,
            _that.customerPhone,
            _that.isAutoApproved,
            _that.sportType,
            _that.venueName);
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
            String code,
            String customerName,
            String courtName,
            DateTime startAt,
            DateTime endAt,
            BookingStatus status,
            int revenue,
            String? slotId,
            String? customerPhone,
            bool isAutoApproved,
            String sportType,
            String venueName)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _BookingRequest() when $default != null:
        return $default(
            _that.id,
            _that.code,
            _that.customerName,
            _that.courtName,
            _that.startAt,
            _that.endAt,
            _that.status,
            _that.revenue,
            _that.slotId,
            _that.customerPhone,
            _that.isAutoApproved,
            _that.sportType,
            _that.venueName);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _BookingRequest extends BookingRequest {
  const _BookingRequest(
      {required this.id,
      required this.code,
      required this.customerName,
      required this.courtName,
      required this.startAt,
      required this.endAt,
      required this.status,
      required this.revenue,
      this.slotId,
      this.customerPhone,
      this.isAutoApproved = false,
      this.sportType = '',
      this.venueName = ''})
      : super._();

  /// Raw `bookings.id` (UUID) — the stable key.
  @override
  final String id;

  /// Short, human-facing order code shown on the card (e.g. `#A1B2C3`).
  @override
  final String code;

  /// Display name of the customer (`Khách lẻ` when anonymous).
  @override
  final String customerName;

  /// Name of the booked court.
  @override
  final String courtName;

  /// Slot start (UTC). Render `.toLocal()`.
  @override
  final DateTime startAt;

  /// Slot end (UTC). Render `.toLocal()`.
  @override
  final DateTime endAt;
  @override
  final BookingStatus status;

  /// Resolved VND revenue (explicit total if > 0, else court price ×
  /// duration; `0` when neither is known).
  @override
  final int revenue;

  /// Linked `slots.id`, when the join provided it — needed to free the slot
  /// on reject (OWNER-29).
  @override
  final String? slotId;

  /// Customer phone. Per OWNER-28 it is only surfaced on the card **after**
  /// approval — see [revealedPhone], which gates on [status].
  @override
  final String? customerPhone;

  /// Whether this booking was auto-approved by the system (OWNER-45).
  /// Shown as a "Tự động" chip on confirmed cards.
  @override
  @JsonKey()
  final bool isAutoApproved;

  /// Sport type from the venue (OWNER-213). Empty string when unavailable.
  @override
  @JsonKey()
  final String sportType;

  /// Name of the specific venue (playable area) within the court (OWNER-226).
  /// Empty string when unavailable (e.g. court has no venues yet).
  @override
  @JsonKey()
  final String venueName;

  /// Create a copy of BookingRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$BookingRequestCopyWith<_BookingRequest> get copyWith =>
      __$BookingRequestCopyWithImpl<_BookingRequest>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _BookingRequest &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.courtName, courtName) ||
                other.courtName == courtName) &&
            (identical(other.startAt, startAt) || other.startAt == startAt) &&
            (identical(other.endAt, endAt) || other.endAt == endAt) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.revenue, revenue) || other.revenue == revenue) &&
            (identical(other.slotId, slotId) || other.slotId == slotId) &&
            (identical(other.customerPhone, customerPhone) ||
                other.customerPhone == customerPhone) &&
            (identical(other.isAutoApproved, isAutoApproved) ||
                other.isAutoApproved == isAutoApproved) &&
            (identical(other.sportType, sportType) ||
                other.sportType == sportType) &&
            (identical(other.venueName, venueName) ||
                other.venueName == venueName));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      code,
      customerName,
      courtName,
      startAt,
      endAt,
      status,
      revenue,
      slotId,
      customerPhone,
      isAutoApproved,
      sportType,
      venueName);

  @override
  String toString() {
    return 'BookingRequest(id: $id, code: $code, customerName: $customerName, courtName: $courtName, startAt: $startAt, endAt: $endAt, status: $status, revenue: $revenue, slotId: $slotId, customerPhone: $customerPhone, isAutoApproved: $isAutoApproved, sportType: $sportType, venueName: $venueName)';
  }
}

/// @nodoc
abstract mixin class _$BookingRequestCopyWith<$Res>
    implements $BookingRequestCopyWith<$Res> {
  factory _$BookingRequestCopyWith(
          _BookingRequest value, $Res Function(_BookingRequest) _then) =
      __$BookingRequestCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String code,
      String customerName,
      String courtName,
      DateTime startAt,
      DateTime endAt,
      BookingStatus status,
      int revenue,
      String? slotId,
      String? customerPhone,
      bool isAutoApproved,
      String sportType,
      String venueName});
}

/// @nodoc
class __$BookingRequestCopyWithImpl<$Res>
    implements _$BookingRequestCopyWith<$Res> {
  __$BookingRequestCopyWithImpl(this._self, this._then);

  final _BookingRequest _self;
  final $Res Function(_BookingRequest) _then;

  /// Create a copy of BookingRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? customerName = null,
    Object? courtName = null,
    Object? startAt = null,
    Object? endAt = null,
    Object? status = null,
    Object? revenue = null,
    Object? slotId = freezed,
    Object? customerPhone = freezed,
    Object? isAutoApproved = null,
    Object? sportType = null,
    Object? venueName = null,
  }) {
    return _then(_BookingRequest(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      code: null == code
          ? _self.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      customerName: null == customerName
          ? _self.customerName
          : customerName // ignore: cast_nullable_to_non_nullable
              as String,
      courtName: null == courtName
          ? _self.courtName
          : courtName // ignore: cast_nullable_to_non_nullable
              as String,
      startAt: null == startAt
          ? _self.startAt
          : startAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endAt: null == endAt
          ? _self.endAt
          : endAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as BookingStatus,
      revenue: null == revenue
          ? _self.revenue
          : revenue // ignore: cast_nullable_to_non_nullable
              as int,
      slotId: freezed == slotId
          ? _self.slotId
          : slotId // ignore: cast_nullable_to_non_nullable
              as String?,
      customerPhone: freezed == customerPhone
          ? _self.customerPhone
          : customerPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      isAutoApproved: null == isAutoApproved
          ? _self.isAutoApproved
          : isAutoApproved // ignore: cast_nullable_to_non_nullable
              as bool,
      sportType: null == sportType
          ? _self.sportType
          : sportType // ignore: cast_nullable_to_non_nullable
              as String,
      venueName: null == venueName
          ? _self.venueName
          : venueName // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
