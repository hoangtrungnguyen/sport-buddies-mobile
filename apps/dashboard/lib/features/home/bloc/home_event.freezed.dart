// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HomeEvent {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is HomeEvent);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'HomeEvent()';
  }
}

/// @nodoc
class $HomeEventCopyWith<$Res> {
  $HomeEventCopyWith(HomeEvent _, $Res Function(HomeEvent) __);
}

/// Adds pattern-matching-related methods to [HomeEvent].
extension HomeEventPatterns on HomeEvent {
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
    TResult Function(HomeStarted value)? started,
    TResult Function(HomeRequestApproved value)? requestApproved,
    TResult Function(HomeRequestDeclined value)? requestDeclined,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case HomeStarted() when started != null:
        return started(_that);
      case HomeRequestApproved() when requestApproved != null:
        return requestApproved(_that);
      case HomeRequestDeclined() when requestDeclined != null:
        return requestDeclined(_that);
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
    required TResult Function(HomeStarted value) started,
    required TResult Function(HomeRequestApproved value) requestApproved,
    required TResult Function(HomeRequestDeclined value) requestDeclined,
  }) {
    final _that = this;
    switch (_that) {
      case HomeStarted():
        return started(_that);
      case HomeRequestApproved():
        return requestApproved(_that);
      case HomeRequestDeclined():
        return requestDeclined(_that);
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
    TResult? Function(HomeStarted value)? started,
    TResult? Function(HomeRequestApproved value)? requestApproved,
    TResult? Function(HomeRequestDeclined value)? requestDeclined,
  }) {
    final _that = this;
    switch (_that) {
      case HomeStarted() when started != null:
        return started(_that);
      case HomeRequestApproved() when requestApproved != null:
        return requestApproved(_that);
      case HomeRequestDeclined() when requestDeclined != null:
        return requestDeclined(_that);
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
    TResult Function(String id)? requestApproved,
    TResult Function(String id)? requestDeclined,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case HomeStarted() when started != null:
        return started();
      case HomeRequestApproved() when requestApproved != null:
        return requestApproved(_that.id);
      case HomeRequestDeclined() when requestDeclined != null:
        return requestDeclined(_that.id);
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
    required TResult Function(String id) requestApproved,
    required TResult Function(String id) requestDeclined,
  }) {
    final _that = this;
    switch (_that) {
      case HomeStarted():
        return started();
      case HomeRequestApproved():
        return requestApproved(_that.id);
      case HomeRequestDeclined():
        return requestDeclined(_that.id);
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
    TResult? Function(String id)? requestApproved,
    TResult? Function(String id)? requestDeclined,
  }) {
    final _that = this;
    switch (_that) {
      case HomeStarted() when started != null:
        return started();
      case HomeRequestApproved() when requestApproved != null:
        return requestApproved(_that.id);
      case HomeRequestDeclined() when requestDeclined != null:
        return requestDeclined(_that.id);
      case _:
        return null;
    }
  }
}

/// @nodoc

class HomeStarted implements HomeEvent {
  const HomeStarted();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is HomeStarted);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'HomeEvent.started()';
  }
}

/// @nodoc

class HomeRequestApproved implements HomeEvent {
  const HomeRequestApproved(this.id);

  final String id;

  /// Create a copy of HomeEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $HomeRequestApprovedCopyWith<HomeRequestApproved> get copyWith =>
      _$HomeRequestApprovedCopyWithImpl<HomeRequestApproved>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is HomeRequestApproved &&
            (identical(other.id, id) || other.id == id));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id);

  @override
  String toString() {
    return 'HomeEvent.requestApproved(id: $id)';
  }
}

/// @nodoc
abstract mixin class $HomeRequestApprovedCopyWith<$Res>
    implements $HomeEventCopyWith<$Res> {
  factory $HomeRequestApprovedCopyWith(
          HomeRequestApproved value, $Res Function(HomeRequestApproved) _then) =
      _$HomeRequestApprovedCopyWithImpl;
  @useResult
  $Res call({String id});
}

/// @nodoc
class _$HomeRequestApprovedCopyWithImpl<$Res>
    implements $HomeRequestApprovedCopyWith<$Res> {
  _$HomeRequestApprovedCopyWithImpl(this._self, this._then);

  final HomeRequestApproved _self;
  final $Res Function(HomeRequestApproved) _then;

  /// Create a copy of HomeEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
  }) {
    return _then(HomeRequestApproved(
      null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class HomeRequestDeclined implements HomeEvent {
  const HomeRequestDeclined(this.id);

  final String id;

  /// Create a copy of HomeEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $HomeRequestDeclinedCopyWith<HomeRequestDeclined> get copyWith =>
      _$HomeRequestDeclinedCopyWithImpl<HomeRequestDeclined>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is HomeRequestDeclined &&
            (identical(other.id, id) || other.id == id));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id);

  @override
  String toString() {
    return 'HomeEvent.requestDeclined(id: $id)';
  }
}

/// @nodoc
abstract mixin class $HomeRequestDeclinedCopyWith<$Res>
    implements $HomeEventCopyWith<$Res> {
  factory $HomeRequestDeclinedCopyWith(
          HomeRequestDeclined value, $Res Function(HomeRequestDeclined) _then) =
      _$HomeRequestDeclinedCopyWithImpl;
  @useResult
  $Res call({String id});
}

/// @nodoc
class _$HomeRequestDeclinedCopyWithImpl<$Res>
    implements $HomeRequestDeclinedCopyWith<$Res> {
  _$HomeRequestDeclinedCopyWithImpl(this._self, this._then);

  final HomeRequestDeclined _self;
  final $Res Function(HomeRequestDeclined) _then;

  /// Create a copy of HomeEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
  }) {
    return _then(HomeRequestDeclined(
      null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
