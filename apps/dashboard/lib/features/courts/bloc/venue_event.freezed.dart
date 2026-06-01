// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'venue_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VenueEvent {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is VenueEvent);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'VenueEvent()';
  }
}

/// @nodoc
class $VenueEventCopyWith<$Res> {
  $VenueEventCopyWith(VenueEvent _, $Res Function(VenueEvent) __);
}

/// Adds pattern-matching-related methods to [VenueEvent].
extension VenueEventPatterns on VenueEvent {
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
    TResult Function(VenueLoadRequested value)? loadRequested,
    TResult Function(VenueReloadRequested value)? reloadRequested,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case VenueLoadRequested() when loadRequested != null:
        return loadRequested(_that);
      case VenueReloadRequested() when reloadRequested != null:
        return reloadRequested(_that);
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
    required TResult Function(VenueLoadRequested value) loadRequested,
    required TResult Function(VenueReloadRequested value) reloadRequested,
  }) {
    final _that = this;
    switch (_that) {
      case VenueLoadRequested():
        return loadRequested(_that);
      case VenueReloadRequested():
        return reloadRequested(_that);
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
    TResult? Function(VenueLoadRequested value)? loadRequested,
    TResult? Function(VenueReloadRequested value)? reloadRequested,
  }) {
    final _that = this;
    switch (_that) {
      case VenueLoadRequested() when loadRequested != null:
        return loadRequested(_that);
      case VenueReloadRequested() when reloadRequested != null:
        return reloadRequested(_that);
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
    TResult Function(String courtId)? loadRequested,
    TResult Function()? reloadRequested,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case VenueLoadRequested() when loadRequested != null:
        return loadRequested(_that.courtId);
      case VenueReloadRequested() when reloadRequested != null:
        return reloadRequested();
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
    required TResult Function(String courtId) loadRequested,
    required TResult Function() reloadRequested,
  }) {
    final _that = this;
    switch (_that) {
      case VenueLoadRequested():
        return loadRequested(_that.courtId);
      case VenueReloadRequested():
        return reloadRequested();
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
    TResult? Function(String courtId)? loadRequested,
    TResult? Function()? reloadRequested,
  }) {
    final _that = this;
    switch (_that) {
      case VenueLoadRequested() when loadRequested != null:
        return loadRequested(_that.courtId);
      case VenueReloadRequested() when reloadRequested != null:
        return reloadRequested();
      case _:
        return null;
    }
  }
}

/// @nodoc

class VenueLoadRequested implements VenueEvent {
  const VenueLoadRequested(this.courtId);

  final String courtId;

  /// Create a copy of VenueEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $VenueLoadRequestedCopyWith<VenueLoadRequested> get copyWith =>
      _$VenueLoadRequestedCopyWithImpl<VenueLoadRequested>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is VenueLoadRequested &&
            (identical(other.courtId, courtId) || other.courtId == courtId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, courtId);

  @override
  String toString() {
    return 'VenueEvent.loadRequested(courtId: $courtId)';
  }
}

/// @nodoc
abstract mixin class $VenueLoadRequestedCopyWith<$Res>
    implements $VenueEventCopyWith<$Res> {
  factory $VenueLoadRequestedCopyWith(
          VenueLoadRequested value, $Res Function(VenueLoadRequested) _then) =
      _$VenueLoadRequestedCopyWithImpl;
  @useResult
  $Res call({String courtId});
}

/// @nodoc
class _$VenueLoadRequestedCopyWithImpl<$Res>
    implements $VenueLoadRequestedCopyWith<$Res> {
  _$VenueLoadRequestedCopyWithImpl(this._self, this._then);

  final VenueLoadRequested _self;
  final $Res Function(VenueLoadRequested) _then;

  /// Create a copy of VenueEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? courtId = null,
  }) {
    return _then(VenueLoadRequested(
      null == courtId
          ? _self.courtId
          : courtId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class VenueReloadRequested implements VenueEvent {
  const VenueReloadRequested();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is VenueReloadRequested);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'VenueEvent.reloadRequested()';
  }
}

// dart format on
