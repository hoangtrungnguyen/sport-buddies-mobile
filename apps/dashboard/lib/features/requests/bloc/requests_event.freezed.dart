// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'requests_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RequestsEvent {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is RequestsEvent);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'RequestsEvent()';
  }
}

/// @nodoc
class $RequestsEventCopyWith<$Res> {
  $RequestsEventCopyWith(RequestsEvent _, $Res Function(RequestsEvent) __);
}

/// Adds pattern-matching-related methods to [RequestsEvent].
extension RequestsEventPatterns on RequestsEvent {
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
    TResult Function(RequestsStarted value)? started,
    TResult Function(RequestsDateChanged value)? dateChanged,
    TResult Function(RequestsPageChanged value)? pageChanged,
    TResult Function(RequestsRefreshed value)? refreshed,
    TResult Function(RequestsApproved value)? approved,
    TResult Function(RequestsRejected value)? rejected,
    TResult Function(RequestsUndoRequested value)? undoRequested,
    TResult Function(RequestsActionConsumed value)? actionConsumed,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case RequestsStarted() when started != null:
        return started(_that);
      case RequestsDateChanged() when dateChanged != null:
        return dateChanged(_that);
      case RequestsPageChanged() when pageChanged != null:
        return pageChanged(_that);
      case RequestsRefreshed() when refreshed != null:
        return refreshed(_that);
      case RequestsApproved() when approved != null:
        return approved(_that);
      case RequestsRejected() when rejected != null:
        return rejected(_that);
      case RequestsUndoRequested() when undoRequested != null:
        return undoRequested(_that);
      case RequestsActionConsumed() when actionConsumed != null:
        return actionConsumed(_that);
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
    required TResult Function(RequestsStarted value) started,
    required TResult Function(RequestsDateChanged value) dateChanged,
    required TResult Function(RequestsPageChanged value) pageChanged,
    required TResult Function(RequestsRefreshed value) refreshed,
    required TResult Function(RequestsApproved value) approved,
    required TResult Function(RequestsRejected value) rejected,
    required TResult Function(RequestsUndoRequested value) undoRequested,
    required TResult Function(RequestsActionConsumed value) actionConsumed,
  }) {
    final _that = this;
    switch (_that) {
      case RequestsStarted():
        return started(_that);
      case RequestsDateChanged():
        return dateChanged(_that);
      case RequestsPageChanged():
        return pageChanged(_that);
      case RequestsRefreshed():
        return refreshed(_that);
      case RequestsApproved():
        return approved(_that);
      case RequestsRejected():
        return rejected(_that);
      case RequestsUndoRequested():
        return undoRequested(_that);
      case RequestsActionConsumed():
        return actionConsumed(_that);
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
    TResult? Function(RequestsStarted value)? started,
    TResult? Function(RequestsDateChanged value)? dateChanged,
    TResult? Function(RequestsPageChanged value)? pageChanged,
    TResult? Function(RequestsRefreshed value)? refreshed,
    TResult? Function(RequestsApproved value)? approved,
    TResult? Function(RequestsRejected value)? rejected,
    TResult? Function(RequestsUndoRequested value)? undoRequested,
    TResult? Function(RequestsActionConsumed value)? actionConsumed,
  }) {
    final _that = this;
    switch (_that) {
      case RequestsStarted() when started != null:
        return started(_that);
      case RequestsDateChanged() when dateChanged != null:
        return dateChanged(_that);
      case RequestsPageChanged() when pageChanged != null:
        return pageChanged(_that);
      case RequestsRefreshed() when refreshed != null:
        return refreshed(_that);
      case RequestsApproved() when approved != null:
        return approved(_that);
      case RequestsRejected() when rejected != null:
        return rejected(_that);
      case RequestsUndoRequested() when undoRequested != null:
        return undoRequested(_that);
      case RequestsActionConsumed() when actionConsumed != null:
        return actionConsumed(_that);
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
    TResult Function()? started,
    TResult Function(DateTime day)? dateChanged,
    TResult Function(int page)? pageChanged,
    TResult Function()? refreshed,
    TResult Function(BookingRequest request)? approved,
    TResult Function(BookingRequest request, String? reason)? rejected,
    TResult Function(BookingRequest request)? undoRequested,
    TResult Function()? actionConsumed,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case RequestsStarted() when started != null:
        return started();
      case RequestsDateChanged() when dateChanged != null:
        return dateChanged(_that.day);
      case RequestsPageChanged() when pageChanged != null:
        return pageChanged(_that.page);
      case RequestsRefreshed() when refreshed != null:
        return refreshed();
      case RequestsApproved() when approved != null:
        return approved(_that.request);
      case RequestsRejected() when rejected != null:
        return rejected(_that.request, _that.reason);
      case RequestsUndoRequested() when undoRequested != null:
        return undoRequested(_that.request);
      case RequestsActionConsumed() when actionConsumed != null:
        return actionConsumed();
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
    required TResult Function() started,
    required TResult Function(DateTime day) dateChanged,
    required TResult Function(int page) pageChanged,
    required TResult Function() refreshed,
    required TResult Function(BookingRequest request) approved,
    required TResult Function(BookingRequest request, String? reason) rejected,
    required TResult Function(BookingRequest request) undoRequested,
    required TResult Function() actionConsumed,
  }) {
    final _that = this;
    switch (_that) {
      case RequestsStarted():
        return started();
      case RequestsDateChanged():
        return dateChanged(_that.day);
      case RequestsPageChanged():
        return pageChanged(_that.page);
      case RequestsRefreshed():
        return refreshed();
      case RequestsApproved():
        return approved(_that.request);
      case RequestsRejected():
        return rejected(_that.request, _that.reason);
      case RequestsUndoRequested():
        return undoRequested(_that.request);
      case RequestsActionConsumed():
        return actionConsumed();
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
    TResult? Function()? started,
    TResult? Function(DateTime day)? dateChanged,
    TResult? Function(int page)? pageChanged,
    TResult? Function()? refreshed,
    TResult? Function(BookingRequest request)? approved,
    TResult? Function(BookingRequest request, String? reason)? rejected,
    TResult? Function(BookingRequest request)? undoRequested,
    TResult? Function()? actionConsumed,
  }) {
    final _that = this;
    switch (_that) {
      case RequestsStarted() when started != null:
        return started();
      case RequestsDateChanged() when dateChanged != null:
        return dateChanged(_that.day);
      case RequestsPageChanged() when pageChanged != null:
        return pageChanged(_that.page);
      case RequestsRefreshed() when refreshed != null:
        return refreshed();
      case RequestsApproved() when approved != null:
        return approved(_that.request);
      case RequestsRejected() when rejected != null:
        return rejected(_that.request, _that.reason);
      case RequestsUndoRequested() when undoRequested != null:
        return undoRequested(_that.request);
      case RequestsActionConsumed() when actionConsumed != null:
        return actionConsumed();
      case _:
        return null;
    }
  }
}

/// @nodoc

class RequestsStarted implements RequestsEvent {
  const RequestsStarted();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is RequestsStarted);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'RequestsEvent.started()';
  }
}

/// @nodoc

class RequestsDateChanged implements RequestsEvent {
  const RequestsDateChanged(this.day);

  final DateTime day;

  /// Create a copy of RequestsEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $RequestsDateChangedCopyWith<RequestsDateChanged> get copyWith =>
      _$RequestsDateChangedCopyWithImpl<RequestsDateChanged>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is RequestsDateChanged &&
            (identical(other.day, day) || other.day == day));
  }

  @override
  int get hashCode => Object.hash(runtimeType, day);

  @override
  String toString() {
    return 'RequestsEvent.dateChanged(day: $day)';
  }
}

/// @nodoc
abstract mixin class $RequestsDateChangedCopyWith<$Res>
    implements $RequestsEventCopyWith<$Res> {
  factory $RequestsDateChangedCopyWith(
          RequestsDateChanged value, $Res Function(RequestsDateChanged) _then) =
      _$RequestsDateChangedCopyWithImpl;
  @useResult
  $Res call({DateTime day});
}

/// @nodoc
class _$RequestsDateChangedCopyWithImpl<$Res>
    implements $RequestsDateChangedCopyWith<$Res> {
  _$RequestsDateChangedCopyWithImpl(this._self, this._then);

  final RequestsDateChanged _self;
  final $Res Function(RequestsDateChanged) _then;

  /// Create a copy of RequestsEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? day = null,
  }) {
    return _then(RequestsDateChanged(
      null == day
          ? _self.day
          : day // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc

class RequestsPageChanged implements RequestsEvent {
  const RequestsPageChanged(this.page);

  final int page;

  /// Create a copy of RequestsEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $RequestsPageChangedCopyWith<RequestsPageChanged> get copyWith =>
      _$RequestsPageChangedCopyWithImpl<RequestsPageChanged>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is RequestsPageChanged &&
            (identical(other.page, page) || other.page == page));
  }

  @override
  int get hashCode => Object.hash(runtimeType, page);

  @override
  String toString() {
    return 'RequestsEvent.pageChanged(page: $page)';
  }
}

/// @nodoc
abstract mixin class $RequestsPageChangedCopyWith<$Res>
    implements $RequestsEventCopyWith<$Res> {
  factory $RequestsPageChangedCopyWith(
          RequestsPageChanged value, $Res Function(RequestsPageChanged) _then) =
      _$RequestsPageChangedCopyWithImpl;
  @useResult
  $Res call({int page});
}

/// @nodoc
class _$RequestsPageChangedCopyWithImpl<$Res>
    implements $RequestsPageChangedCopyWith<$Res> {
  _$RequestsPageChangedCopyWithImpl(this._self, this._then);

  final RequestsPageChanged _self;
  final $Res Function(RequestsPageChanged) _then;

  /// Create a copy of RequestsEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? page = null,
  }) {
    return _then(RequestsPageChanged(
      null == page
          ? _self.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class RequestsRefreshed implements RequestsEvent {
  const RequestsRefreshed();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is RequestsRefreshed);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'RequestsEvent.refreshed()';
  }
}

/// @nodoc

class RequestsApproved implements RequestsEvent {
  const RequestsApproved(this.request);

  final BookingRequest request;

  /// Create a copy of RequestsEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $RequestsApprovedCopyWith<RequestsApproved> get copyWith =>
      _$RequestsApprovedCopyWithImpl<RequestsApproved>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is RequestsApproved &&
            (identical(other.request, request) || other.request == request));
  }

  @override
  int get hashCode => Object.hash(runtimeType, request);

  @override
  String toString() {
    return 'RequestsEvent.approved(request: $request)';
  }
}

/// @nodoc
abstract mixin class $RequestsApprovedCopyWith<$Res>
    implements $RequestsEventCopyWith<$Res> {
  factory $RequestsApprovedCopyWith(
          RequestsApproved value, $Res Function(RequestsApproved) _then) =
      _$RequestsApprovedCopyWithImpl;
  @useResult
  $Res call({BookingRequest request});

  $BookingRequestCopyWith<$Res> get request;
}

/// @nodoc
class _$RequestsApprovedCopyWithImpl<$Res>
    implements $RequestsApprovedCopyWith<$Res> {
  _$RequestsApprovedCopyWithImpl(this._self, this._then);

  final RequestsApproved _self;
  final $Res Function(RequestsApproved) _then;

  /// Create a copy of RequestsEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? request = null,
  }) {
    return _then(RequestsApproved(
      null == request
          ? _self.request
          : request // ignore: cast_nullable_to_non_nullable
              as BookingRequest,
    ));
  }

  /// Create a copy of RequestsEvent
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

class RequestsRejected implements RequestsEvent {
  const RequestsRejected(this.request, {this.reason});

  final BookingRequest request;
  final String? reason;

  /// Create a copy of RequestsEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $RequestsRejectedCopyWith<RequestsRejected> get copyWith =>
      _$RequestsRejectedCopyWithImpl<RequestsRejected>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is RequestsRejected &&
            (identical(other.request, request) || other.request == request) &&
            (identical(other.reason, reason) || other.reason == reason));
  }

  @override
  int get hashCode => Object.hash(runtimeType, request, reason);

  @override
  String toString() {
    return 'RequestsEvent.rejected(request: $request, reason: $reason)';
  }
}

/// @nodoc
abstract mixin class $RequestsRejectedCopyWith<$Res>
    implements $RequestsEventCopyWith<$Res> {
  factory $RequestsRejectedCopyWith(
          RequestsRejected value, $Res Function(RequestsRejected) _then) =
      _$RequestsRejectedCopyWithImpl;
  @useResult
  $Res call({BookingRequest request, String? reason});

  $BookingRequestCopyWith<$Res> get request;
}

/// @nodoc
class _$RequestsRejectedCopyWithImpl<$Res>
    implements $RequestsRejectedCopyWith<$Res> {
  _$RequestsRejectedCopyWithImpl(this._self, this._then);

  final RequestsRejected _self;
  final $Res Function(RequestsRejected) _then;

  /// Create a copy of RequestsEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? request = null,
    Object? reason = freezed,
  }) {
    return _then(RequestsRejected(
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

  /// Create a copy of RequestsEvent
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

class RequestsUndoRequested implements RequestsEvent {
  const RequestsUndoRequested(this.request);

  final BookingRequest request;

  /// Create a copy of RequestsEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $RequestsUndoRequestedCopyWith<RequestsUndoRequested> get copyWith =>
      _$RequestsUndoRequestedCopyWithImpl<RequestsUndoRequested>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is RequestsUndoRequested &&
            (identical(other.request, request) || other.request == request));
  }

  @override
  int get hashCode => Object.hash(runtimeType, request);

  @override
  String toString() {
    return 'RequestsEvent.undoRequested(request: $request)';
  }
}

/// @nodoc
abstract mixin class $RequestsUndoRequestedCopyWith<$Res>
    implements $RequestsEventCopyWith<$Res> {
  factory $RequestsUndoRequestedCopyWith(RequestsUndoRequested value,
          $Res Function(RequestsUndoRequested) _then) =
      _$RequestsUndoRequestedCopyWithImpl;
  @useResult
  $Res call({BookingRequest request});

  $BookingRequestCopyWith<$Res> get request;
}

/// @nodoc
class _$RequestsUndoRequestedCopyWithImpl<$Res>
    implements $RequestsUndoRequestedCopyWith<$Res> {
  _$RequestsUndoRequestedCopyWithImpl(this._self, this._then);

  final RequestsUndoRequested _self;
  final $Res Function(RequestsUndoRequested) _then;

  /// Create a copy of RequestsEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? request = null,
  }) {
    return _then(RequestsUndoRequested(
      null == request
          ? _self.request
          : request // ignore: cast_nullable_to_non_nullable
              as BookingRequest,
    ));
  }

  /// Create a copy of RequestsEvent
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

class RequestsActionConsumed implements RequestsEvent {
  const RequestsActionConsumed();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is RequestsActionConsumed);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'RequestsEvent.actionConsumed()';
  }
}

// dart format on
