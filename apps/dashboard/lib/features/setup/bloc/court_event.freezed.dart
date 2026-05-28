// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'court_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CourtEvent {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is CourtEvent);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'CourtEvent()';
  }
}

/// @nodoc
class $CourtEventCopyWith<$Res> {
  $CourtEventCopyWith(CourtEvent _, $Res Function(CourtEvent) __);
}

/// Adds pattern-matching-related methods to [CourtEvent].
extension CourtEventPatterns on CourtEvent {
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
    TResult Function(CourtLoadRequested value)? loadRequested,
    TResult Function(CourtDeactivateRequested value)? deactivateRequested,
    TResult Function(CourtReactivateRequested value)? reactivateRequested,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case CourtLoadRequested() when loadRequested != null:
        return loadRequested(_that);
      case CourtDeactivateRequested() when deactivateRequested != null:
        return deactivateRequested(_that);
      case CourtReactivateRequested() when reactivateRequested != null:
        return reactivateRequested(_that);
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
    required TResult Function(CourtLoadRequested value) loadRequested,
    required TResult Function(CourtDeactivateRequested value)
        deactivateRequested,
    required TResult Function(CourtReactivateRequested value)
        reactivateRequested,
  }) {
    final _that = this;
    switch (_that) {
      case CourtLoadRequested():
        return loadRequested(_that);
      case CourtDeactivateRequested():
        return deactivateRequested(_that);
      case CourtReactivateRequested():
        return reactivateRequested(_that);
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
    TResult? Function(CourtLoadRequested value)? loadRequested,
    TResult? Function(CourtDeactivateRequested value)? deactivateRequested,
    TResult? Function(CourtReactivateRequested value)? reactivateRequested,
  }) {
    final _that = this;
    switch (_that) {
      case CourtLoadRequested() when loadRequested != null:
        return loadRequested(_that);
      case CourtDeactivateRequested() when deactivateRequested != null:
        return deactivateRequested(_that);
      case CourtReactivateRequested() when reactivateRequested != null:
        return reactivateRequested(_that);
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
    TResult Function()? loadRequested,
    TResult Function(String id)? deactivateRequested,
    TResult Function(String id)? reactivateRequested,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case CourtLoadRequested() when loadRequested != null:
        return loadRequested();
      case CourtDeactivateRequested() when deactivateRequested != null:
        return deactivateRequested(_that.id);
      case CourtReactivateRequested() when reactivateRequested != null:
        return reactivateRequested(_that.id);
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
    required TResult Function() loadRequested,
    required TResult Function(String id) deactivateRequested,
    required TResult Function(String id) reactivateRequested,
  }) {
    final _that = this;
    switch (_that) {
      case CourtLoadRequested():
        return loadRequested();
      case CourtDeactivateRequested():
        return deactivateRequested(_that.id);
      case CourtReactivateRequested():
        return reactivateRequested(_that.id);
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
    TResult? Function()? loadRequested,
    TResult? Function(String id)? deactivateRequested,
    TResult? Function(String id)? reactivateRequested,
  }) {
    final _that = this;
    switch (_that) {
      case CourtLoadRequested() when loadRequested != null:
        return loadRequested();
      case CourtDeactivateRequested() when deactivateRequested != null:
        return deactivateRequested(_that.id);
      case CourtReactivateRequested() when reactivateRequested != null:
        return reactivateRequested(_that.id);
      case _:
        return null;
    }
  }
}

/// @nodoc

class CourtLoadRequested implements CourtEvent {
  const CourtLoadRequested();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is CourtLoadRequested);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'CourtEvent.loadRequested()';
  }
}

/// @nodoc

class CourtDeactivateRequested implements CourtEvent {
  const CourtDeactivateRequested(this.id);

  final String id;

  /// Create a copy of CourtEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CourtDeactivateRequestedCopyWith<CourtDeactivateRequested> get copyWith =>
      _$CourtDeactivateRequestedCopyWithImpl<CourtDeactivateRequested>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CourtDeactivateRequested &&
            (identical(other.id, id) || other.id == id));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id);

  @override
  String toString() {
    return 'CourtEvent.deactivateRequested(id: $id)';
  }
}

/// @nodoc
abstract mixin class $CourtDeactivateRequestedCopyWith<$Res>
    implements $CourtEventCopyWith<$Res> {
  factory $CourtDeactivateRequestedCopyWith(CourtDeactivateRequested value,
          $Res Function(CourtDeactivateRequested) _then) =
      _$CourtDeactivateRequestedCopyWithImpl;
  @useResult
  $Res call({String id});
}

/// @nodoc
class _$CourtDeactivateRequestedCopyWithImpl<$Res>
    implements $CourtDeactivateRequestedCopyWith<$Res> {
  _$CourtDeactivateRequestedCopyWithImpl(this._self, this._then);

  final CourtDeactivateRequested _self;
  final $Res Function(CourtDeactivateRequested) _then;

  /// Create a copy of CourtEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
  }) {
    return _then(CourtDeactivateRequested(
      null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class CourtReactivateRequested implements CourtEvent {
  const CourtReactivateRequested(this.id);

  final String id;

  /// Create a copy of CourtEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CourtReactivateRequestedCopyWith<CourtReactivateRequested> get copyWith =>
      _$CourtReactivateRequestedCopyWithImpl<CourtReactivateRequested>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CourtReactivateRequested &&
            (identical(other.id, id) || other.id == id));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id);

  @override
  String toString() {
    return 'CourtEvent.reactivateRequested(id: $id)';
  }
}

/// @nodoc
abstract mixin class $CourtReactivateRequestedCopyWith<$Res>
    implements $CourtEventCopyWith<$Res> {
  factory $CourtReactivateRequestedCopyWith(CourtReactivateRequested value,
          $Res Function(CourtReactivateRequested) _then) =
      _$CourtReactivateRequestedCopyWithImpl;
  @useResult
  $Res call({String id});
}

/// @nodoc
class _$CourtReactivateRequestedCopyWithImpl<$Res>
    implements $CourtReactivateRequestedCopyWith<$Res> {
  _$CourtReactivateRequestedCopyWithImpl(this._self, this._then);

  final CourtReactivateRequested _self;
  final $Res Function(CourtReactivateRequested) _then;

  /// Create a copy of CourtEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
  }) {
    return _then(CourtReactivateRequested(
      null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
