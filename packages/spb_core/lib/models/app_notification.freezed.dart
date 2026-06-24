// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_notification.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppNotification {
  String get id;
  String get type;
  DateTime get createdAt;
  String get text;
  String get meta;
  bool get isRead;

  /// Optional related entity ids for deep-linking.
  String? get bookingId;
  String? get slotId;

  /// Create a copy of AppNotification
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AppNotificationCopyWith<AppNotification> get copyWith =>
      _$AppNotificationCopyWithImpl<AppNotification>(
          this as AppNotification, _$identity);

  /// Serializes this AppNotification to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AppNotification &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.meta, meta) || other.meta == meta) &&
            (identical(other.isRead, isRead) || other.isRead == isRead) &&
            (identical(other.bookingId, bookingId) ||
                other.bookingId == bookingId) &&
            (identical(other.slotId, slotId) || other.slotId == slotId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, type, createdAt, text, meta, isRead, bookingId, slotId);

  @override
  String toString() {
    return 'AppNotification(id: $id, type: $type, createdAt: $createdAt, text: $text, meta: $meta, isRead: $isRead, bookingId: $bookingId, slotId: $slotId)';
  }
}

/// @nodoc
abstract mixin class $AppNotificationCopyWith<$Res> {
  factory $AppNotificationCopyWith(
          AppNotification value, $Res Function(AppNotification) _then) =
      _$AppNotificationCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String type,
      DateTime createdAt,
      String text,
      String meta,
      bool isRead,
      String? bookingId,
      String? slotId});
}

/// @nodoc
class _$AppNotificationCopyWithImpl<$Res>
    implements $AppNotificationCopyWith<$Res> {
  _$AppNotificationCopyWithImpl(this._self, this._then);

  final AppNotification _self;
  final $Res Function(AppNotification) _then;

  /// Create a copy of AppNotification
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? createdAt = null,
    Object? text = null,
    Object? meta = null,
    Object? isRead = null,
    Object? bookingId = freezed,
    Object? slotId = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      text: null == text
          ? _self.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      meta: null == meta
          ? _self.meta
          : meta // ignore: cast_nullable_to_non_nullable
              as String,
      isRead: null == isRead
          ? _self.isRead
          : isRead // ignore: cast_nullable_to_non_nullable
              as bool,
      bookingId: freezed == bookingId
          ? _self.bookingId
          : bookingId // ignore: cast_nullable_to_non_nullable
              as String?,
      slotId: freezed == slotId
          ? _self.slotId
          : slotId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [AppNotification].
extension AppNotificationPatterns on AppNotification {
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
    TResult Function(_AppNotification value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AppNotification() when $default != null:
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
    TResult Function(_AppNotification value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AppNotification():
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
    TResult? Function(_AppNotification value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AppNotification() when $default != null:
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
    TResult Function(String id, String type, DateTime createdAt, String text,
            String meta, bool isRead, String? bookingId, String? slotId)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AppNotification() when $default != null:
        return $default(_that.id, _that.type, _that.createdAt, _that.text,
            _that.meta, _that.isRead, _that.bookingId, _that.slotId);
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
    TResult Function(String id, String type, DateTime createdAt, String text,
            String meta, bool isRead, String? bookingId, String? slotId)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AppNotification():
        return $default(_that.id, _that.type, _that.createdAt, _that.text,
            _that.meta, _that.isRead, _that.bookingId, _that.slotId);
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
    TResult? Function(String id, String type, DateTime createdAt, String text,
            String meta, bool isRead, String? bookingId, String? slotId)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AppNotification() when $default != null:
        return $default(_that.id, _that.type, _that.createdAt, _that.text,
            _that.meta, _that.isRead, _that.bookingId, _that.slotId);
      case _:
        return null;
    }
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _AppNotification extends AppNotification {
  const _AppNotification(
      {required this.id,
      required this.type,
      required this.createdAt,
      this.text = '',
      this.meta = '',
      this.isRead = false,
      this.bookingId,
      this.slotId})
      : super._();
  factory _AppNotification.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationFromJson(json);

  @override
  final String id;
  @override
  final String type;
  @override
  final DateTime createdAt;
  @override
  @JsonKey()
  final String text;
  @override
  @JsonKey()
  final String meta;
  @override
  @JsonKey()
  final bool isRead;

  /// Optional related entity ids for deep-linking.
  @override
  final String? bookingId;
  @override
  final String? slotId;

  /// Create a copy of AppNotification
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AppNotificationCopyWith<_AppNotification> get copyWith =>
      __$AppNotificationCopyWithImpl<_AppNotification>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$AppNotificationToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AppNotification &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.meta, meta) || other.meta == meta) &&
            (identical(other.isRead, isRead) || other.isRead == isRead) &&
            (identical(other.bookingId, bookingId) ||
                other.bookingId == bookingId) &&
            (identical(other.slotId, slotId) || other.slotId == slotId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, type, createdAt, text, meta, isRead, bookingId, slotId);

  @override
  String toString() {
    return 'AppNotification(id: $id, type: $type, createdAt: $createdAt, text: $text, meta: $meta, isRead: $isRead, bookingId: $bookingId, slotId: $slotId)';
  }
}

/// @nodoc
abstract mixin class _$AppNotificationCopyWith<$Res>
    implements $AppNotificationCopyWith<$Res> {
  factory _$AppNotificationCopyWith(
          _AppNotification value, $Res Function(_AppNotification) _then) =
      __$AppNotificationCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String type,
      DateTime createdAt,
      String text,
      String meta,
      bool isRead,
      String? bookingId,
      String? slotId});
}

/// @nodoc
class __$AppNotificationCopyWithImpl<$Res>
    implements _$AppNotificationCopyWith<$Res> {
  __$AppNotificationCopyWithImpl(this._self, this._then);

  final _AppNotification _self;
  final $Res Function(_AppNotification) _then;

  /// Create a copy of AppNotification
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? createdAt = null,
    Object? text = null,
    Object? meta = null,
    Object? isRead = null,
    Object? bookingId = freezed,
    Object? slotId = freezed,
  }) {
    return _then(_AppNotification(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      text: null == text
          ? _self.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      meta: null == meta
          ? _self.meta
          : meta // ignore: cast_nullable_to_non_nullable
              as String,
      isRead: null == isRead
          ? _self.isRead
          : isRead // ignore: cast_nullable_to_non_nullable
              as bool,
      bookingId: freezed == bookingId
          ? _self.bookingId
          : bookingId // ignore: cast_nullable_to_non_nullable
              as String?,
      slotId: freezed == slotId
          ? _self.slotId
          : slotId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
