// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'requests_action.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RequestsAction {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is RequestsAction);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'RequestsAction()';
  }
}

/// @nodoc
class $RequestsActionCopyWith<$Res> {
  $RequestsActionCopyWith(RequestsAction _, $Res Function(RequestsAction) __);
}

/// Adds pattern-matching-related methods to [RequestsAction].
extension RequestsActionPatterns on RequestsAction {
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
    TResult Function(RequestApproved value)? approved,
    TResult Function(RequestRejected value)? rejected,
    TResult Function(RequestUndone value)? undone,
    TResult Function(RequestActionFailed value)? failed,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case RequestApproved() when approved != null:
        return approved(_that);
      case RequestRejected() when rejected != null:
        return rejected(_that);
      case RequestUndone() when undone != null:
        return undone(_that);
      case RequestActionFailed() when failed != null:
        return failed(_that);
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
    required TResult Function(RequestApproved value) approved,
    required TResult Function(RequestRejected value) rejected,
    required TResult Function(RequestUndone value) undone,
    required TResult Function(RequestActionFailed value) failed,
  }) {
    final _that = this;
    switch (_that) {
      case RequestApproved():
        return approved(_that);
      case RequestRejected():
        return rejected(_that);
      case RequestUndone():
        return undone(_that);
      case RequestActionFailed():
        return failed(_that);
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
    TResult? Function(RequestApproved value)? approved,
    TResult? Function(RequestRejected value)? rejected,
    TResult? Function(RequestUndone value)? undone,
    TResult? Function(RequestActionFailed value)? failed,
  }) {
    final _that = this;
    switch (_that) {
      case RequestApproved() when approved != null:
        return approved(_that);
      case RequestRejected() when rejected != null:
        return rejected(_that);
      case RequestUndone() when undone != null:
        return undone(_that);
      case RequestActionFailed() when failed != null:
        return failed(_that);
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
    TResult Function(BookingRequest request)? approved,
    TResult Function(BookingRequest request, String? reason)? rejected,
    TResult Function(BookingRequest request)? undone,
    TResult Function(String message)? failed,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case RequestApproved() when approved != null:
        return approved(_that.request);
      case RequestRejected() when rejected != null:
        return rejected(_that.request, _that.reason);
      case RequestUndone() when undone != null:
        return undone(_that.request);
      case RequestActionFailed() when failed != null:
        return failed(_that.message);
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
    required TResult Function(BookingRequest request) approved,
    required TResult Function(BookingRequest request, String? reason) rejected,
    required TResult Function(BookingRequest request) undone,
    required TResult Function(String message) failed,
  }) {
    final _that = this;
    switch (_that) {
      case RequestApproved():
        return approved(_that.request);
      case RequestRejected():
        return rejected(_that.request, _that.reason);
      case RequestUndone():
        return undone(_that.request);
      case RequestActionFailed():
        return failed(_that.message);
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
    TResult? Function(BookingRequest request)? approved,
    TResult? Function(BookingRequest request, String? reason)? rejected,
    TResult? Function(BookingRequest request)? undone,
    TResult? Function(String message)? failed,
  }) {
    final _that = this;
    switch (_that) {
      case RequestApproved() when approved != null:
        return approved(_that.request);
      case RequestRejected() when rejected != null:
        return rejected(_that.request, _that.reason);
      case RequestUndone() when undone != null:
        return undone(_that.request);
      case RequestActionFailed() when failed != null:
        return failed(_that.message);
      case _:
        return null;
    }
  }
}

/// @nodoc

class RequestApproved implements RequestsAction {
  const RequestApproved(this.request);

  final BookingRequest request;

  /// Create a copy of RequestsAction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $RequestApprovedCopyWith<RequestApproved> get copyWith =>
      _$RequestApprovedCopyWithImpl<RequestApproved>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is RequestApproved &&
            (identical(other.request, request) || other.request == request));
  }

  @override
  int get hashCode => Object.hash(runtimeType, request);

  @override
  String toString() {
    return 'RequestsAction.approved(request: $request)';
  }
}

/// @nodoc
abstract mixin class $RequestApprovedCopyWith<$Res>
    implements $RequestsActionCopyWith<$Res> {
  factory $RequestApprovedCopyWith(
          RequestApproved value, $Res Function(RequestApproved) _then) =
      _$RequestApprovedCopyWithImpl;
  @useResult
  $Res call({BookingRequest request});

  $BookingRequestCopyWith<$Res> get request;
}

/// @nodoc
class _$RequestApprovedCopyWithImpl<$Res>
    implements $RequestApprovedCopyWith<$Res> {
  _$RequestApprovedCopyWithImpl(this._self, this._then);

  final RequestApproved _self;
  final $Res Function(RequestApproved) _then;

  /// Create a copy of RequestsAction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? request = null,
  }) {
    return _then(RequestApproved(
      null == request
          ? _self.request
          : request // ignore: cast_nullable_to_non_nullable
              as BookingRequest,
    ));
  }

  /// Create a copy of RequestsAction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BookingRequestCopyWith<$Res> get request {
    return $BookingRequestCopyWith<$Res>(_self.request, (value) {
      return _then(_self.copyWith(request: value));
    });
  }
}

/// @nodoc

class RequestRejected implements RequestsAction {
  const RequestRejected(this.request, {this.reason});

  final BookingRequest request;
  final String? reason;

  /// Create a copy of RequestsAction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $RequestRejectedCopyWith<RequestRejected> get copyWith =>
      _$RequestRejectedCopyWithImpl<RequestRejected>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is RequestRejected &&
            (identical(other.request, request) || other.request == request) &&
            (identical(other.reason, reason) || other.reason == reason));
  }

  @override
  int get hashCode => Object.hash(runtimeType, request, reason);

  @override
  String toString() {
    return 'RequestsAction.rejected(request: $request, reason: $reason)';
  }
}

/// @nodoc
abstract mixin class $RequestRejectedCopyWith<$Res>
    implements $RequestsActionCopyWith<$Res> {
  factory $RequestRejectedCopyWith(
          RequestRejected value, $Res Function(RequestRejected) _then) =
      _$RequestRejectedCopyWithImpl;
  @useResult
  $Res call({BookingRequest request, String? reason});

  $BookingRequestCopyWith<$Res> get request;
}

/// @nodoc
class _$RequestRejectedCopyWithImpl<$Res>
    implements $RequestRejectedCopyWith<$Res> {
  _$RequestRejectedCopyWithImpl(this._self, this._then);

  final RequestRejected _self;
  final $Res Function(RequestRejected) _then;

  /// Create a copy of RequestsAction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? request = null,
    Object? reason = freezed,
  }) {
    return _then(RequestRejected(
      null == request
          ? _self.request
          : request // ignore: cast_nullable_to_non_nullable
              as BookingRequest,
      reason: freezed == reason
          ? _self.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }

  /// Create a copy of RequestsAction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BookingRequestCopyWith<$Res> get request {
    return $BookingRequestCopyWith<$Res>(_self.request, (value) {
      return _then(_self.copyWith(request: value));
    });
  }
}

/// @nodoc

class RequestUndone implements RequestsAction {
  const RequestUndone(this.request);

  final BookingRequest request;

  /// Create a copy of RequestsAction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $RequestUndoneCopyWith<RequestUndone> get copyWith =>
      _$RequestUndoneCopyWithImpl<RequestUndone>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is RequestUndone &&
            (identical(other.request, request) || other.request == request));
  }

  @override
  int get hashCode => Object.hash(runtimeType, request);

  @override
  String toString() {
    return 'RequestsAction.undone(request: $request)';
  }
}

/// @nodoc
abstract mixin class $RequestUndoneCopyWith<$Res>
    implements $RequestsActionCopyWith<$Res> {
  factory $RequestUndoneCopyWith(
          RequestUndone value, $Res Function(RequestUndone) _then) =
      _$RequestUndoneCopyWithImpl;
  @useResult
  $Res call({BookingRequest request});

  $BookingRequestCopyWith<$Res> get request;
}

/// @nodoc
class _$RequestUndoneCopyWithImpl<$Res>
    implements $RequestUndoneCopyWith<$Res> {
  _$RequestUndoneCopyWithImpl(this._self, this._then);

  final RequestUndone _self;
  final $Res Function(RequestUndone) _then;

  /// Create a copy of RequestsAction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? request = null,
  }) {
    return _then(RequestUndone(
      null == request
          ? _self.request
          : request // ignore: cast_nullable_to_non_nullable
              as BookingRequest,
    ));
  }

  /// Create a copy of RequestsAction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BookingRequestCopyWith<$Res> get request {
    return $BookingRequestCopyWith<$Res>(_self.request, (value) {
      return _then(_self.copyWith(request: value));
    });
  }
}

/// @nodoc

class RequestActionFailed implements RequestsAction {
  const RequestActionFailed(this.message);

  final String message;

  /// Create a copy of RequestsAction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $RequestActionFailedCopyWith<RequestActionFailed> get copyWith =>
      _$RequestActionFailedCopyWithImpl<RequestActionFailed>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is RequestActionFailed &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @override
  String toString() {
    return 'RequestsAction.failed(message: $message)';
  }
}

/// @nodoc
abstract mixin class $RequestActionFailedCopyWith<$Res>
    implements $RequestsActionCopyWith<$Res> {
  factory $RequestActionFailedCopyWith(
          RequestActionFailed value, $Res Function(RequestActionFailed) _then) =
      _$RequestActionFailedCopyWithImpl;
  @useResult
  $Res call({String message});
}

/// @nodoc
class _$RequestActionFailedCopyWithImpl<$Res>
    implements $RequestActionFailedCopyWith<$Res> {
  _$RequestActionFailedCopyWithImpl(this._self, this._then);

  final RequestActionFailed _self;
  final $Res Function(RequestActionFailed) _then;

  /// Create a copy of RequestsAction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = null,
  }) {
    return _then(RequestActionFailed(
      null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
