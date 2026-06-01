// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'venue_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VenueState {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is VenueState);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'VenueState()';
  }
}

/// @nodoc
class $VenueStateCopyWith<$Res> {
  $VenueStateCopyWith(VenueState _, $Res Function(VenueState) __);
}

/// Adds pattern-matching-related methods to [VenueState].
extension VenueStatePatterns on VenueState {
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
    TResult Function(VenueInitial value)? initial,
    TResult Function(VenueLoading value)? loading,
    TResult Function(VenueLoaded value)? loaded,
    TResult Function(VenueFailure value)? failure,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case VenueInitial() when initial != null:
        return initial(_that);
      case VenueLoading() when loading != null:
        return loading(_that);
      case VenueLoaded() when loaded != null:
        return loaded(_that);
      case VenueFailure() when failure != null:
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
    required TResult Function(VenueInitial value) initial,
    required TResult Function(VenueLoading value) loading,
    required TResult Function(VenueLoaded value) loaded,
    required TResult Function(VenueFailure value) failure,
  }) {
    final _that = this;
    switch (_that) {
      case VenueInitial():
        return initial(_that);
      case VenueLoading():
        return loading(_that);
      case VenueLoaded():
        return loaded(_that);
      case VenueFailure():
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
    TResult? Function(VenueInitial value)? initial,
    TResult? Function(VenueLoading value)? loading,
    TResult? Function(VenueLoaded value)? loaded,
    TResult? Function(VenueFailure value)? failure,
  }) {
    final _that = this;
    switch (_that) {
      case VenueInitial() when initial != null:
        return initial(_that);
      case VenueLoading() when loading != null:
        return loading(_that);
      case VenueLoaded() when loaded != null:
        return loaded(_that);
      case VenueFailure() when failure != null:
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
    TResult Function(String courtId, List<Venue> venues)? loaded,
    TResult Function(String message, String? courtId, StackTrace? stackTrace)?
        failure,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case VenueInitial() when initial != null:
        return initial();
      case VenueLoading() when loading != null:
        return loading();
      case VenueLoaded() when loaded != null:
        return loaded(_that.courtId, _that.venues);
      case VenueFailure() when failure != null:
        return failure(_that.message, _that.courtId, _that.stackTrace);
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
    required TResult Function(String courtId, List<Venue> venues) loaded,
    required TResult Function(
            String message, String? courtId, StackTrace? stackTrace)
        failure,
  }) {
    final _that = this;
    switch (_that) {
      case VenueInitial():
        return initial();
      case VenueLoading():
        return loading();
      case VenueLoaded():
        return loaded(_that.courtId, _that.venues);
      case VenueFailure():
        return failure(_that.message, _that.courtId, _that.stackTrace);
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
    TResult? Function(String courtId, List<Venue> venues)? loaded,
    TResult? Function(String message, String? courtId, StackTrace? stackTrace)?
        failure,
  }) {
    final _that = this;
    switch (_that) {
      case VenueInitial() when initial != null:
        return initial();
      case VenueLoading() when loading != null:
        return loading();
      case VenueLoaded() when loaded != null:
        return loaded(_that.courtId, _that.venues);
      case VenueFailure() when failure != null:
        return failure(_that.message, _that.courtId, _that.stackTrace);
      case _:
        return null;
    }
  }
}

/// @nodoc

class VenueInitial implements VenueState {
  const VenueInitial();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is VenueInitial);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'VenueState.initial()';
  }
}

/// @nodoc

class VenueLoading implements VenueState {
  const VenueLoading();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is VenueLoading);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'VenueState.loading()';
  }
}

/// @nodoc

class VenueLoaded implements VenueState {
  const VenueLoaded({required this.courtId, required final List<Venue> venues})
      : _venues = venues;

  final String courtId;
  final List<Venue> _venues;
  List<Venue> get venues {
    if (_venues is EqualUnmodifiableListView) return _venues;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_venues);
  }

  /// Create a copy of VenueState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $VenueLoadedCopyWith<VenueLoaded> get copyWith =>
      _$VenueLoadedCopyWithImpl<VenueLoaded>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is VenueLoaded &&
            (identical(other.courtId, courtId) || other.courtId == courtId) &&
            const DeepCollectionEquality().equals(other._venues, _venues));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, courtId, const DeepCollectionEquality().hash(_venues));

  @override
  String toString() {
    return 'VenueState.loaded(courtId: $courtId, venues: $venues)';
  }
}

/// @nodoc
abstract mixin class $VenueLoadedCopyWith<$Res>
    implements $VenueStateCopyWith<$Res> {
  factory $VenueLoadedCopyWith(
          VenueLoaded value, $Res Function(VenueLoaded) _then) =
      _$VenueLoadedCopyWithImpl;
  @useResult
  $Res call({String courtId, List<Venue> venues});
}

/// @nodoc
class _$VenueLoadedCopyWithImpl<$Res> implements $VenueLoadedCopyWith<$Res> {
  _$VenueLoadedCopyWithImpl(this._self, this._then);

  final VenueLoaded _self;
  final $Res Function(VenueLoaded) _then;

  /// Create a copy of VenueState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? courtId = null,
    Object? venues = null,
  }) {
    return _then(VenueLoaded(
      courtId: null == courtId
          ? _self.courtId
          : courtId // ignore: cast_nullable_to_non_nullable
              as String,
      venues: null == venues
          ? _self._venues
          : venues // ignore: cast_nullable_to_non_nullable
              as List<Venue>,
    ));
  }
}

/// @nodoc

class VenueFailure with AppExceptionMixin implements VenueState {
  const VenueFailure(this.message, {this.courtId, this.stackTrace});

  final String message;
  final String? courtId;
  final StackTrace? stackTrace;

  /// Create a copy of VenueState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $VenueFailureCopyWith<VenueFailure> get copyWith =>
      _$VenueFailureCopyWithImpl<VenueFailure>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is VenueFailure &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.courtId, courtId) || other.courtId == courtId) &&
            (identical(other.stackTrace, stackTrace) ||
                other.stackTrace == stackTrace));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, courtId, stackTrace);

  @override
  String toString() {
    return 'VenueState.failure(message: $message, courtId: $courtId, stackTrace: $stackTrace)';
  }
}

/// @nodoc
abstract mixin class $VenueFailureCopyWith<$Res>
    implements $VenueStateCopyWith<$Res> {
  factory $VenueFailureCopyWith(
          VenueFailure value, $Res Function(VenueFailure) _then) =
      _$VenueFailureCopyWithImpl;
  @useResult
  $Res call({String message, String? courtId, StackTrace? stackTrace});
}

/// @nodoc
class _$VenueFailureCopyWithImpl<$Res> implements $VenueFailureCopyWith<$Res> {
  _$VenueFailureCopyWithImpl(this._self, this._then);

  final VenueFailure _self;
  final $Res Function(VenueFailure) _then;

  /// Create a copy of VenueState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = null,
    Object? courtId = freezed,
    Object? stackTrace = freezed,
  }) {
    return _then(VenueFailure(
      null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      courtId: freezed == courtId
          ? _self.courtId
          : courtId // ignore: cast_nullable_to_non_nullable
              as String?,
      stackTrace: freezed == stackTrace
          ? _self.stackTrace
          : stackTrace // ignore: cast_nullable_to_non_nullable
              as StackTrace?,
    ));
  }
}

// dart format on
