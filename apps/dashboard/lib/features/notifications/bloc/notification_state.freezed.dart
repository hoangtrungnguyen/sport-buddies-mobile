// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NotificationState {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is NotificationState);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'NotificationState()';
  }
}

/// @nodoc
class $NotificationStateCopyWith<$Res> {
  $NotificationStateCopyWith(
      NotificationState _, $Res Function(NotificationState) __);
}

/// Adds pattern-matching-related methods to [NotificationState].
extension NotificationStatePatterns on NotificationState {
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
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NotificationInitial value)? initial,
    TResult Function(NotificationLoading value)? loading,
    TResult Function(NotificationLoaded value)? loaded,
    TResult Function(NotificationFailure value)? failure,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case NotificationInitial() when initial != null:
        return initial(_that);
      case NotificationLoading() when loading != null:
        return loading(_that);
      case NotificationLoaded() when loaded != null:
        return loaded(_that);
      case NotificationFailure() when failure != null:
        return failure(_that);
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
  TResult map<TResult extends Object?>({
    required TResult Function(NotificationInitial value) initial,
    required TResult Function(NotificationLoading value) loading,
    required TResult Function(NotificationLoaded value) loaded,
    required TResult Function(NotificationFailure value) failure,
  }) {
    final _that = this;
    switch (_that) {
      case NotificationInitial():
        return initial(_that);
      case NotificationLoading():
        return loading(_that);
      case NotificationLoaded():
        return loaded(_that);
      case NotificationFailure():
        return failure(_that);
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
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NotificationInitial value)? initial,
    TResult? Function(NotificationLoading value)? loading,
    TResult? Function(NotificationLoaded value)? loaded,
    TResult? Function(NotificationFailure value)? failure,
  }) {
    final _that = this;
    switch (_that) {
      case NotificationInitial() when initial != null:
        return initial(_that);
      case NotificationLoading() when loading != null:
        return loading(_that);
      case NotificationLoaded() when loaded != null:
        return loaded(_that);
      case NotificationFailure() when failure != null:
        return failure(_that);
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
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<AppNotification> notifications, int unreadCount)?
        loaded,
    TResult Function(String message, StackTrace? stackTrace)? failure,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case NotificationInitial() when initial != null:
        return initial();
      case NotificationLoading() when loading != null:
        return loading();
      case NotificationLoaded() when loaded != null:
        return loaded(_that.notifications, _that.unreadCount);
      case NotificationFailure() when failure != null:
        return failure(_that.message, _that.stackTrace);
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
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
            List<AppNotification> notifications, int unreadCount)
        loaded,
    required TResult Function(String message, StackTrace? stackTrace) failure,
  }) {
    final _that = this;
    switch (_that) {
      case NotificationInitial():
        return initial();
      case NotificationLoading():
        return loading();
      case NotificationLoaded():
        return loaded(_that.notifications, _that.unreadCount);
      case NotificationFailure():
        return failure(_that.message, _that.stackTrace);
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
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<AppNotification> notifications, int unreadCount)?
        loaded,
    TResult? Function(String message, StackTrace? stackTrace)? failure,
  }) {
    final _that = this;
    switch (_that) {
      case NotificationInitial() when initial != null:
        return initial();
      case NotificationLoading() when loading != null:
        return loading();
      case NotificationLoaded() when loaded != null:
        return loaded(_that.notifications, _that.unreadCount);
      case NotificationFailure() when failure != null:
        return failure(_that.message, _that.stackTrace);
      case _:
        return null;
    }
  }
}

/// @nodoc

class NotificationInitial implements NotificationState {
  const NotificationInitial();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is NotificationInitial);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'NotificationState.initial()';
  }
}

/// @nodoc

class NotificationLoading implements NotificationState {
  const NotificationLoading();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is NotificationLoading);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'NotificationState.loading()';
  }
}

/// @nodoc

class NotificationLoaded implements NotificationState {
  const NotificationLoaded(final List<AppNotification> notifications,
      {this.unreadCount = 0})
      : _notifications = notifications;

  final List<AppNotification> _notifications;
  List<AppNotification> get notifications {
    if (_notifications is EqualUnmodifiableListView) return _notifications;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_notifications);
  }

  @JsonKey()
  final int unreadCount;

  /// Create a copy of NotificationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $NotificationLoadedCopyWith<NotificationLoaded> get copyWith =>
      _$NotificationLoadedCopyWithImpl<NotificationLoaded>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is NotificationLoaded &&
            const DeepCollectionEquality()
                .equals(other._notifications, _notifications) &&
            (identical(other.unreadCount, unreadCount) ||
                other.unreadCount == unreadCount));
  }

  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(_notifications), unreadCount);

  @override
  String toString() {
    return 'NotificationState.loaded(notifications: $notifications, unreadCount: $unreadCount)';
  }
}

/// @nodoc
abstract mixin class $NotificationLoadedCopyWith<$Res>
    implements $NotificationStateCopyWith<$Res> {
  factory $NotificationLoadedCopyWith(
          NotificationLoaded value, $Res Function(NotificationLoaded) _then) =
      _$NotificationLoadedCopyWithImpl;
  @useResult
  $Res call({List<AppNotification> notifications, int unreadCount});
}

/// @nodoc
class _$NotificationLoadedCopyWithImpl<$Res>
    implements $NotificationLoadedCopyWith<$Res> {
  _$NotificationLoadedCopyWithImpl(this._self, this._then);

  final NotificationLoaded _self;
  final $Res Function(NotificationLoaded) _then;

  /// Create a copy of NotificationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? notifications = null,
    Object? unreadCount = null,
  }) {
    return _then(NotificationLoaded(
      null == notifications
          ? _self._notifications
          : notifications // ignore: cast_nullable_to_non_nullable
              as List<AppNotification>,
      unreadCount: null == unreadCount
          ? _self.unreadCount
          : unreadCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class NotificationFailure with AppExceptionMixin implements NotificationState {
  const NotificationFailure(this.message, {this.stackTrace});

  final String message;
  final StackTrace? stackTrace;

  /// Create a copy of NotificationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $NotificationFailureCopyWith<NotificationFailure> get copyWith =>
      _$NotificationFailureCopyWithImpl<NotificationFailure>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is NotificationFailure &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.stackTrace, stackTrace) ||
                other.stackTrace == stackTrace));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, stackTrace);

  @override
  String toString() {
    return 'NotificationState.failure(message: $message, stackTrace: $stackTrace)';
  }
}

/// @nodoc
abstract mixin class $NotificationFailureCopyWith<$Res>
    implements $NotificationStateCopyWith<$Res> {
  factory $NotificationFailureCopyWith(
          NotificationFailure value, $Res Function(NotificationFailure) _then) =
      _$NotificationFailureCopyWithImpl;
  @useResult
  $Res call({String message, StackTrace? stackTrace});
}

/// @nodoc
class _$NotificationFailureCopyWithImpl<$Res>
    implements $NotificationFailureCopyWith<$Res> {
  _$NotificationFailureCopyWithImpl(this._self, this._then);

  final NotificationFailure _self;
  final $Res Function(NotificationFailure) _then;

  /// Create a copy of NotificationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = null,
    Object? stackTrace = freezed,
  }) {
    return _then(NotificationFailure(
      null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      stackTrace: freezed == stackTrace
          ? _self.stackTrace
          : stackTrace // ignore: cast_nullable_to_non_nullable
              as StackTrace?,
    ));
  }
}

// dart format on
