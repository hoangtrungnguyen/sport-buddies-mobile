// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'participant.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Participant {
  String get id;
  String get name;
  String? get userId;
  String? get avatarUrl;
  bool get isHost;

  /// `pending` | `confirmed` | `cancelled`.
  String get bookingStatus;

  /// `paid` | `partial` | `unpaid` | `unknown`.
  String get paymentStatus;
  String? get paymentMethod;
  int? get expectedPrice;

  /// Create a copy of Participant
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ParticipantCopyWith<Participant> get copyWith =>
      _$ParticipantCopyWithImpl<Participant>(this as Participant, _$identity);

  /// Serializes this Participant to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Participant &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.isHost, isHost) || other.isHost == isHost) &&
            (identical(other.bookingStatus, bookingStatus) ||
                other.bookingStatus == bookingStatus) &&
            (identical(other.paymentStatus, paymentStatus) ||
                other.paymentStatus == paymentStatus) &&
            (identical(other.paymentMethod, paymentMethod) ||
                other.paymentMethod == paymentMethod) &&
            (identical(other.expectedPrice, expectedPrice) ||
                other.expectedPrice == expectedPrice));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, userId, avatarUrl,
      isHost, bookingStatus, paymentStatus, paymentMethod, expectedPrice);

  @override
  String toString() {
    return 'Participant(id: $id, name: $name, userId: $userId, avatarUrl: $avatarUrl, isHost: $isHost, bookingStatus: $bookingStatus, paymentStatus: $paymentStatus, paymentMethod: $paymentMethod, expectedPrice: $expectedPrice)';
  }
}

/// @nodoc
abstract mixin class $ParticipantCopyWith<$Res> {
  factory $ParticipantCopyWith(
          Participant value, $Res Function(Participant) _then) =
      _$ParticipantCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String name,
      String? userId,
      String? avatarUrl,
      bool isHost,
      String bookingStatus,
      String paymentStatus,
      String? paymentMethod,
      int? expectedPrice});
}

/// @nodoc
class _$ParticipantCopyWithImpl<$Res> implements $ParticipantCopyWith<$Res> {
  _$ParticipantCopyWithImpl(this._self, this._then);

  final Participant _self;
  final $Res Function(Participant) _then;

  /// Create a copy of Participant
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? userId = freezed,
    Object? avatarUrl = freezed,
    Object? isHost = null,
    Object? bookingStatus = null,
    Object? paymentStatus = null,
    Object? paymentMethod = freezed,
    Object? expectedPrice = freezed,
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
      userId: freezed == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      avatarUrl: freezed == avatarUrl
          ? _self.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      isHost: null == isHost
          ? _self.isHost
          : isHost // ignore: cast_nullable_to_non_nullable
              as bool,
      bookingStatus: null == bookingStatus
          ? _self.bookingStatus
          : bookingStatus // ignore: cast_nullable_to_non_nullable
              as String,
      paymentStatus: null == paymentStatus
          ? _self.paymentStatus
          : paymentStatus // ignore: cast_nullable_to_non_nullable
              as String,
      paymentMethod: freezed == paymentMethod
          ? _self.paymentMethod
          : paymentMethod // ignore: cast_nullable_to_non_nullable
              as String?,
      expectedPrice: freezed == expectedPrice
          ? _self.expectedPrice
          : expectedPrice // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// Adds pattern-matching-related methods to [Participant].
extension ParticipantPatterns on Participant {
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
    TResult Function(_Participant value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Participant() when $default != null:
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
    TResult Function(_Participant value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Participant():
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
    TResult? Function(_Participant value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Participant() when $default != null:
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
            String? userId,
            String? avatarUrl,
            bool isHost,
            String bookingStatus,
            String paymentStatus,
            String? paymentMethod,
            int? expectedPrice)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Participant() when $default != null:
        return $default(
            _that.id,
            _that.name,
            _that.userId,
            _that.avatarUrl,
            _that.isHost,
            _that.bookingStatus,
            _that.paymentStatus,
            _that.paymentMethod,
            _that.expectedPrice);
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
            String? userId,
            String? avatarUrl,
            bool isHost,
            String bookingStatus,
            String paymentStatus,
            String? paymentMethod,
            int? expectedPrice)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Participant():
        return $default(
            _that.id,
            _that.name,
            _that.userId,
            _that.avatarUrl,
            _that.isHost,
            _that.bookingStatus,
            _that.paymentStatus,
            _that.paymentMethod,
            _that.expectedPrice);
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
            String? userId,
            String? avatarUrl,
            bool isHost,
            String bookingStatus,
            String paymentStatus,
            String? paymentMethod,
            int? expectedPrice)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Participant() when $default != null:
        return $default(
            _that.id,
            _that.name,
            _that.userId,
            _that.avatarUrl,
            _that.isHost,
            _that.bookingStatus,
            _that.paymentStatus,
            _that.paymentMethod,
            _that.expectedPrice);
      case _:
        return null;
    }
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _Participant extends Participant {
  const _Participant(
      {required this.id,
      required this.name,
      this.userId,
      this.avatarUrl,
      this.isHost = false,
      this.bookingStatus = 'confirmed',
      this.paymentStatus = 'unknown',
      this.paymentMethod,
      this.expectedPrice})
      : super._();
  factory _Participant.fromJson(Map<String, dynamic> json) =>
      _$ParticipantFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? userId;
  @override
  final String? avatarUrl;
  @override
  @JsonKey()
  final bool isHost;

  /// `pending` | `confirmed` | `cancelled`.
  @override
  @JsonKey()
  final String bookingStatus;

  /// `paid` | `partial` | `unpaid` | `unknown`.
  @override
  @JsonKey()
  final String paymentStatus;
  @override
  final String? paymentMethod;
  @override
  final int? expectedPrice;

  /// Create a copy of Participant
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ParticipantCopyWith<_Participant> get copyWith =>
      __$ParticipantCopyWithImpl<_Participant>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ParticipantToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Participant &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.isHost, isHost) || other.isHost == isHost) &&
            (identical(other.bookingStatus, bookingStatus) ||
                other.bookingStatus == bookingStatus) &&
            (identical(other.paymentStatus, paymentStatus) ||
                other.paymentStatus == paymentStatus) &&
            (identical(other.paymentMethod, paymentMethod) ||
                other.paymentMethod == paymentMethod) &&
            (identical(other.expectedPrice, expectedPrice) ||
                other.expectedPrice == expectedPrice));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, userId, avatarUrl,
      isHost, bookingStatus, paymentStatus, paymentMethod, expectedPrice);

  @override
  String toString() {
    return 'Participant(id: $id, name: $name, userId: $userId, avatarUrl: $avatarUrl, isHost: $isHost, bookingStatus: $bookingStatus, paymentStatus: $paymentStatus, paymentMethod: $paymentMethod, expectedPrice: $expectedPrice)';
  }
}

/// @nodoc
abstract mixin class _$ParticipantCopyWith<$Res>
    implements $ParticipantCopyWith<$Res> {
  factory _$ParticipantCopyWith(
          _Participant value, $Res Function(_Participant) _then) =
      __$ParticipantCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String? userId,
      String? avatarUrl,
      bool isHost,
      String bookingStatus,
      String paymentStatus,
      String? paymentMethod,
      int? expectedPrice});
}

/// @nodoc
class __$ParticipantCopyWithImpl<$Res> implements _$ParticipantCopyWith<$Res> {
  __$ParticipantCopyWithImpl(this._self, this._then);

  final _Participant _self;
  final $Res Function(_Participant) _then;

  /// Create a copy of Participant
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? userId = freezed,
    Object? avatarUrl = freezed,
    Object? isHost = null,
    Object? bookingStatus = null,
    Object? paymentStatus = null,
    Object? paymentMethod = freezed,
    Object? expectedPrice = freezed,
  }) {
    return _then(_Participant(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      userId: freezed == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      avatarUrl: freezed == avatarUrl
          ? _self.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      isHost: null == isHost
          ? _self.isHost
          : isHost // ignore: cast_nullable_to_non_nullable
              as bool,
      bookingStatus: null == bookingStatus
          ? _self.bookingStatus
          : bookingStatus // ignore: cast_nullable_to_non_nullable
              as String,
      paymentStatus: null == paymentStatus
          ? _self.paymentStatus
          : paymentStatus // ignore: cast_nullable_to_non_nullable
              as String,
      paymentMethod: freezed == paymentMethod
          ? _self.paymentMethod
          : paymentMethod // ignore: cast_nullable_to_non_nullable
              as String?,
      expectedPrice: freezed == expectedPrice
          ? _self.expectedPrice
          : expectedPrice // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
mixin _$JoinRequest {
  String get id;
  String get slotId;
  String get userId;
  String? get userName;
  String? get avatarUrl;

  /// `pending` | `approved` | `rejected`.
  String get status;
  String? get note;
  DateTime? get createdAt;

  /// Create a copy of JoinRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $JoinRequestCopyWith<JoinRequest> get copyWith =>
      _$JoinRequestCopyWithImpl<JoinRequest>(this as JoinRequest, _$identity);

  /// Serializes this JoinRequest to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is JoinRequest &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.slotId, slotId) || other.slotId == slotId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, slotId, userId, userName,
      avatarUrl, status, note, createdAt);

  @override
  String toString() {
    return 'JoinRequest(id: $id, slotId: $slotId, userId: $userId, userName: $userName, avatarUrl: $avatarUrl, status: $status, note: $note, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class $JoinRequestCopyWith<$Res> {
  factory $JoinRequestCopyWith(
          JoinRequest value, $Res Function(JoinRequest) _then) =
      _$JoinRequestCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String slotId,
      String userId,
      String? userName,
      String? avatarUrl,
      String status,
      String? note,
      DateTime? createdAt});
}

/// @nodoc
class _$JoinRequestCopyWithImpl<$Res> implements $JoinRequestCopyWith<$Res> {
  _$JoinRequestCopyWithImpl(this._self, this._then);

  final JoinRequest _self;
  final $Res Function(JoinRequest) _then;

  /// Create a copy of JoinRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? slotId = null,
    Object? userId = null,
    Object? userName = freezed,
    Object? avatarUrl = freezed,
    Object? status = null,
    Object? note = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      slotId: null == slotId
          ? _self.slotId
          : slotId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      userName: freezed == userName
          ? _self.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String?,
      avatarUrl: freezed == avatarUrl
          ? _self.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      note: freezed == note
          ? _self.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// Adds pattern-matching-related methods to [JoinRequest].
extension JoinRequestPatterns on JoinRequest {
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
    TResult Function(_JoinRequest value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _JoinRequest() when $default != null:
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
    TResult Function(_JoinRequest value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _JoinRequest():
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
    TResult? Function(_JoinRequest value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _JoinRequest() when $default != null:
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
            String slotId,
            String userId,
            String? userName,
            String? avatarUrl,
            String status,
            String? note,
            DateTime? createdAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _JoinRequest() when $default != null:
        return $default(_that.id, _that.slotId, _that.userId, _that.userName,
            _that.avatarUrl, _that.status, _that.note, _that.createdAt);
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
    TResult Function(String id, String slotId, String userId, String? userName,
            String? avatarUrl, String status, String? note, DateTime? createdAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _JoinRequest():
        return $default(_that.id, _that.slotId, _that.userId, _that.userName,
            _that.avatarUrl, _that.status, _that.note, _that.createdAt);
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
            String slotId,
            String userId,
            String? userName,
            String? avatarUrl,
            String status,
            String? note,
            DateTime? createdAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _JoinRequest() when $default != null:
        return $default(_that.id, _that.slotId, _that.userId, _that.userName,
            _that.avatarUrl, _that.status, _that.note, _that.createdAt);
      case _:
        return null;
    }
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _JoinRequest extends JoinRequest {
  const _JoinRequest(
      {required this.id,
      required this.slotId,
      required this.userId,
      this.userName,
      this.avatarUrl,
      this.status = 'pending',
      this.note,
      this.createdAt})
      : super._();
  factory _JoinRequest.fromJson(Map<String, dynamic> json) =>
      _$JoinRequestFromJson(json);

  @override
  final String id;
  @override
  final String slotId;
  @override
  final String userId;
  @override
  final String? userName;
  @override
  final String? avatarUrl;

  /// `pending` | `approved` | `rejected`.
  @override
  @JsonKey()
  final String status;
  @override
  final String? note;
  @override
  final DateTime? createdAt;

  /// Create a copy of JoinRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$JoinRequestCopyWith<_JoinRequest> get copyWith =>
      __$JoinRequestCopyWithImpl<_JoinRequest>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$JoinRequestToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _JoinRequest &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.slotId, slotId) || other.slotId == slotId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, slotId, userId, userName,
      avatarUrl, status, note, createdAt);

  @override
  String toString() {
    return 'JoinRequest(id: $id, slotId: $slotId, userId: $userId, userName: $userName, avatarUrl: $avatarUrl, status: $status, note: $note, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class _$JoinRequestCopyWith<$Res>
    implements $JoinRequestCopyWith<$Res> {
  factory _$JoinRequestCopyWith(
          _JoinRequest value, $Res Function(_JoinRequest) _then) =
      __$JoinRequestCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String slotId,
      String userId,
      String? userName,
      String? avatarUrl,
      String status,
      String? note,
      DateTime? createdAt});
}

/// @nodoc
class __$JoinRequestCopyWithImpl<$Res> implements _$JoinRequestCopyWith<$Res> {
  __$JoinRequestCopyWithImpl(this._self, this._then);

  final _JoinRequest _self;
  final $Res Function(_JoinRequest) _then;

  /// Create a copy of JoinRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? slotId = null,
    Object? userId = null,
    Object? userName = freezed,
    Object? avatarUrl = freezed,
    Object? status = null,
    Object? note = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_JoinRequest(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      slotId: null == slotId
          ? _self.slotId
          : slotId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      userName: freezed == userName
          ? _self.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String?,
      avatarUrl: freezed == avatarUrl
          ? _self.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      note: freezed == note
          ? _self.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

// dart format on
