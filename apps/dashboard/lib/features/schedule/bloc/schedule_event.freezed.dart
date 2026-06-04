// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'schedule_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ScheduleEvent {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is ScheduleEvent);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'ScheduleEvent()';
  }
}

/// @nodoc
class $ScheduleEventCopyWith<$Res> {
  $ScheduleEventCopyWith(ScheduleEvent _, $Res Function(ScheduleEvent) __);
}

/// Adds pattern-matching-related methods to [ScheduleEvent].
extension ScheduleEventPatterns on ScheduleEvent {
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
    TResult Function(ScheduleStarted value)? started,
    TResult Function(ScheduleCourtSelected value)? courtSelected,
    TResult Function(ScheduleWeekChanged value)? weekChanged,
    TResult Function(ScheduleTodayPressed value)? todayPressed,
    TResult Function(ScheduleOwnerSlotCreated value)? ownerSlotCreated,
    TResult Function(ScheduleOpenSlotCreated value)? openSlotCreated,
    TResult Function(ScheduleManualBookingCreated value)? manualBookingCreated,
    TResult Function(ScheduleBookingResultCleared value)? bookingResultCleared,
    TResult Function(ScheduleSlotBlocked value)? slotBlocked,
    TResult Function(ScheduleSlotUnblocked value)? slotUnblocked,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case ScheduleStarted() when started != null:
        return started(_that);
      case ScheduleCourtSelected() when courtSelected != null:
        return courtSelected(_that);
      case ScheduleWeekChanged() when weekChanged != null:
        return weekChanged(_that);
      case ScheduleTodayPressed() when todayPressed != null:
        return todayPressed(_that);
      case ScheduleOwnerSlotCreated() when ownerSlotCreated != null:
        return ownerSlotCreated(_that);
      case ScheduleOpenSlotCreated() when openSlotCreated != null:
        return openSlotCreated(_that);
      case ScheduleManualBookingCreated() when manualBookingCreated != null:
        return manualBookingCreated(_that);
      case ScheduleBookingResultCleared() when bookingResultCleared != null:
        return bookingResultCleared(_that);
      case ScheduleSlotBlocked() when slotBlocked != null:
        return slotBlocked(_that);
      case ScheduleSlotUnblocked() when slotUnblocked != null:
        return slotUnblocked(_that);
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
    required TResult Function(ScheduleStarted value) started,
    required TResult Function(ScheduleCourtSelected value) courtSelected,
    required TResult Function(ScheduleWeekChanged value) weekChanged,
    required TResult Function(ScheduleTodayPressed value) todayPressed,
    required TResult Function(ScheduleOwnerSlotCreated value) ownerSlotCreated,
    required TResult Function(ScheduleOpenSlotCreated value) openSlotCreated,
    required TResult Function(ScheduleManualBookingCreated value)
        manualBookingCreated,
    required TResult Function(ScheduleBookingResultCleared value)
        bookingResultCleared,
    required TResult Function(ScheduleSlotBlocked value) slotBlocked,
    required TResult Function(ScheduleSlotUnblocked value) slotUnblocked,
  }) {
    final _that = this;
    switch (_that) {
      case ScheduleStarted():
        return started(_that);
      case ScheduleCourtSelected():
        return courtSelected(_that);
      case ScheduleWeekChanged():
        return weekChanged(_that);
      case ScheduleTodayPressed():
        return todayPressed(_that);
      case ScheduleOwnerSlotCreated():
        return ownerSlotCreated(_that);
      case ScheduleOpenSlotCreated():
        return openSlotCreated(_that);
      case ScheduleManualBookingCreated():
        return manualBookingCreated(_that);
      case ScheduleBookingResultCleared():
        return bookingResultCleared(_that);
      case ScheduleSlotBlocked():
        return slotBlocked(_that);
      case ScheduleSlotUnblocked():
        return slotUnblocked(_that);
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
    TResult? Function(ScheduleStarted value)? started,
    TResult? Function(ScheduleCourtSelected value)? courtSelected,
    TResult? Function(ScheduleWeekChanged value)? weekChanged,
    TResult? Function(ScheduleTodayPressed value)? todayPressed,
    TResult? Function(ScheduleOwnerSlotCreated value)? ownerSlotCreated,
    TResult? Function(ScheduleOpenSlotCreated value)? openSlotCreated,
    TResult? Function(ScheduleManualBookingCreated value)? manualBookingCreated,
    TResult? Function(ScheduleBookingResultCleared value)? bookingResultCleared,
    TResult? Function(ScheduleSlotBlocked value)? slotBlocked,
    TResult? Function(ScheduleSlotUnblocked value)? slotUnblocked,
  }) {
    final _that = this;
    switch (_that) {
      case ScheduleStarted() when started != null:
        return started(_that);
      case ScheduleCourtSelected() when courtSelected != null:
        return courtSelected(_that);
      case ScheduleWeekChanged() when weekChanged != null:
        return weekChanged(_that);
      case ScheduleTodayPressed() when todayPressed != null:
        return todayPressed(_that);
      case ScheduleOwnerSlotCreated() when ownerSlotCreated != null:
        return ownerSlotCreated(_that);
      case ScheduleOpenSlotCreated() when openSlotCreated != null:
        return openSlotCreated(_that);
      case ScheduleManualBookingCreated() when manualBookingCreated != null:
        return manualBookingCreated(_that);
      case ScheduleBookingResultCleared() when bookingResultCleared != null:
        return bookingResultCleared(_that);
      case ScheduleSlotBlocked() when slotBlocked != null:
        return slotBlocked(_that);
      case ScheduleSlotUnblocked() when slotUnblocked != null:
        return slotUnblocked(_that);
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
    TResult Function(String courtId)? courtSelected,
    TResult Function(DateTime weekStart)? weekChanged,
    TResult Function()? todayPressed,
    TResult Function(DateTime startAt, DateTime endAt)? ownerSlotCreated,
    TResult Function(DateTime startAt, DateTime endAt)? openSlotCreated,
    TResult Function(DateTime startAt, DateTime endAt, String? customerName,
            String? customerPhone, String? notes, int? pricePerHourOverride)?
        manualBookingCreated,
    TResult Function()? bookingResultCleared,
    TResult Function(String slotId, String? reason)? slotBlocked,
    TResult Function(String slotId)? slotUnblocked,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case ScheduleStarted() when started != null:
        return started();
      case ScheduleCourtSelected() when courtSelected != null:
        return courtSelected(_that.courtId);
      case ScheduleWeekChanged() when weekChanged != null:
        return weekChanged(_that.weekStart);
      case ScheduleTodayPressed() when todayPressed != null:
        return todayPressed();
      case ScheduleOwnerSlotCreated() when ownerSlotCreated != null:
        return ownerSlotCreated(_that.startAt, _that.endAt);
      case ScheduleOpenSlotCreated() when openSlotCreated != null:
        return openSlotCreated(_that.startAt, _that.endAt);
      case ScheduleManualBookingCreated() when manualBookingCreated != null:
        return manualBookingCreated(
            _that.startAt,
            _that.endAt,
            _that.customerName,
            _that.customerPhone,
            _that.notes,
            _that.pricePerHourOverride);
      case ScheduleBookingResultCleared() when bookingResultCleared != null:
        return bookingResultCleared();
      case ScheduleSlotBlocked() when slotBlocked != null:
        return slotBlocked(_that.slotId, _that.reason);
      case ScheduleSlotUnblocked() when slotUnblocked != null:
        return slotUnblocked(_that.slotId);
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
    required TResult Function(String courtId) courtSelected,
    required TResult Function(DateTime weekStart) weekChanged,
    required TResult Function() todayPressed,
    required TResult Function(DateTime startAt, DateTime endAt)
        ownerSlotCreated,
    required TResult Function(DateTime startAt, DateTime endAt) openSlotCreated,
    required TResult Function(
            DateTime startAt,
            DateTime endAt,
            String? customerName,
            String? customerPhone,
            String? notes,
            int? pricePerHourOverride)
        manualBookingCreated,
    required TResult Function() bookingResultCleared,
    required TResult Function(String slotId, String? reason) slotBlocked,
    required TResult Function(String slotId) slotUnblocked,
  }) {
    final _that = this;
    switch (_that) {
      case ScheduleStarted():
        return started();
      case ScheduleCourtSelected():
        return courtSelected(_that.courtId);
      case ScheduleWeekChanged():
        return weekChanged(_that.weekStart);
      case ScheduleTodayPressed():
        return todayPressed();
      case ScheduleOwnerSlotCreated():
        return ownerSlotCreated(_that.startAt, _that.endAt);
      case ScheduleOpenSlotCreated():
        return openSlotCreated(_that.startAt, _that.endAt);
      case ScheduleManualBookingCreated():
        return manualBookingCreated(
            _that.startAt,
            _that.endAt,
            _that.customerName,
            _that.customerPhone,
            _that.notes,
            _that.pricePerHourOverride);
      case ScheduleBookingResultCleared():
        return bookingResultCleared();
      case ScheduleSlotBlocked():
        return slotBlocked(_that.slotId, _that.reason);
      case ScheduleSlotUnblocked():
        return slotUnblocked(_that.slotId);
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
    TResult? Function(String courtId)? courtSelected,
    TResult? Function(DateTime weekStart)? weekChanged,
    TResult? Function()? todayPressed,
    TResult? Function(DateTime startAt, DateTime endAt)? ownerSlotCreated,
    TResult? Function(DateTime startAt, DateTime endAt)? openSlotCreated,
    TResult? Function(DateTime startAt, DateTime endAt, String? customerName,
            String? customerPhone, String? notes, int? pricePerHourOverride)?
        manualBookingCreated,
    TResult? Function()? bookingResultCleared,
    TResult? Function(String slotId, String? reason)? slotBlocked,
    TResult? Function(String slotId)? slotUnblocked,
  }) {
    final _that = this;
    switch (_that) {
      case ScheduleStarted() when started != null:
        return started();
      case ScheduleCourtSelected() when courtSelected != null:
        return courtSelected(_that.courtId);
      case ScheduleWeekChanged() when weekChanged != null:
        return weekChanged(_that.weekStart);
      case ScheduleTodayPressed() when todayPressed != null:
        return todayPressed();
      case ScheduleOwnerSlotCreated() when ownerSlotCreated != null:
        return ownerSlotCreated(_that.startAt, _that.endAt);
      case ScheduleOpenSlotCreated() when openSlotCreated != null:
        return openSlotCreated(_that.startAt, _that.endAt);
      case ScheduleManualBookingCreated() when manualBookingCreated != null:
        return manualBookingCreated(
            _that.startAt,
            _that.endAt,
            _that.customerName,
            _that.customerPhone,
            _that.notes,
            _that.pricePerHourOverride);
      case ScheduleBookingResultCleared() when bookingResultCleared != null:
        return bookingResultCleared();
      case ScheduleSlotBlocked() when slotBlocked != null:
        return slotBlocked(_that.slotId, _that.reason);
      case ScheduleSlotUnblocked() when slotUnblocked != null:
        return slotUnblocked(_that.slotId);
      case _:
        return null;
    }
  }
}

/// @nodoc

class ScheduleStarted implements ScheduleEvent {
  const ScheduleStarted();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is ScheduleStarted);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'ScheduleEvent.started()';
  }
}

/// @nodoc

class ScheduleCourtSelected implements ScheduleEvent {
  const ScheduleCourtSelected(this.courtId);

  final String courtId;

  /// Create a copy of ScheduleEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ScheduleCourtSelectedCopyWith<ScheduleCourtSelected> get copyWith =>
      _$ScheduleCourtSelectedCopyWithImpl<ScheduleCourtSelected>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ScheduleCourtSelected &&
            (identical(other.courtId, courtId) || other.courtId == courtId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, courtId);

  @override
  String toString() {
    return 'ScheduleEvent.courtSelected(courtId: $courtId)';
  }
}

/// @nodoc
abstract mixin class $ScheduleCourtSelectedCopyWith<$Res>
    implements $ScheduleEventCopyWith<$Res> {
  factory $ScheduleCourtSelectedCopyWith(ScheduleCourtSelected value,
          $Res Function(ScheduleCourtSelected) _then) =
      _$ScheduleCourtSelectedCopyWithImpl;
  @useResult
  $Res call({String courtId});
}

/// @nodoc
class _$ScheduleCourtSelectedCopyWithImpl<$Res>
    implements $ScheduleCourtSelectedCopyWith<$Res> {
  _$ScheduleCourtSelectedCopyWithImpl(this._self, this._then);

  final ScheduleCourtSelected _self;
  final $Res Function(ScheduleCourtSelected) _then;

  /// Create a copy of ScheduleEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? courtId = null,
  }) {
    return _then(ScheduleCourtSelected(
      null == courtId
          ? _self.courtId
          : courtId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class ScheduleWeekChanged implements ScheduleEvent {
  const ScheduleWeekChanged(this.weekStart);

  final DateTime weekStart;

  /// Create a copy of ScheduleEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ScheduleWeekChangedCopyWith<ScheduleWeekChanged> get copyWith =>
      _$ScheduleWeekChangedCopyWithImpl<ScheduleWeekChanged>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ScheduleWeekChanged &&
            (identical(other.weekStart, weekStart) ||
                other.weekStart == weekStart));
  }

  @override
  int get hashCode => Object.hash(runtimeType, weekStart);

  @override
  String toString() {
    return 'ScheduleEvent.weekChanged(weekStart: $weekStart)';
  }
}

/// @nodoc
abstract mixin class $ScheduleWeekChangedCopyWith<$Res>
    implements $ScheduleEventCopyWith<$Res> {
  factory $ScheduleWeekChangedCopyWith(
          ScheduleWeekChanged value, $Res Function(ScheduleWeekChanged) _then) =
      _$ScheduleWeekChangedCopyWithImpl;
  @useResult
  $Res call({DateTime weekStart});
}

/// @nodoc
class _$ScheduleWeekChangedCopyWithImpl<$Res>
    implements $ScheduleWeekChangedCopyWith<$Res> {
  _$ScheduleWeekChangedCopyWithImpl(this._self, this._then);

  final ScheduleWeekChanged _self;
  final $Res Function(ScheduleWeekChanged) _then;

  /// Create a copy of ScheduleEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? weekStart = null,
  }) {
    return _then(ScheduleWeekChanged(
      null == weekStart
          ? _self.weekStart
          : weekStart // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc

class ScheduleTodayPressed implements ScheduleEvent {
  const ScheduleTodayPressed();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is ScheduleTodayPressed);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'ScheduleEvent.todayPressed()';
  }
}

/// @nodoc

class ScheduleOwnerSlotCreated implements ScheduleEvent {
  const ScheduleOwnerSlotCreated({required this.startAt, required this.endAt});

  final DateTime startAt;
  final DateTime endAt;

  /// Create a copy of ScheduleEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ScheduleOwnerSlotCreatedCopyWith<ScheduleOwnerSlotCreated> get copyWith =>
      _$ScheduleOwnerSlotCreatedCopyWithImpl<ScheduleOwnerSlotCreated>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ScheduleOwnerSlotCreated &&
            (identical(other.startAt, startAt) || other.startAt == startAt) &&
            (identical(other.endAt, endAt) || other.endAt == endAt));
  }

  @override
  int get hashCode => Object.hash(runtimeType, startAt, endAt);

  @override
  String toString() {
    return 'ScheduleEvent.ownerSlotCreated(startAt: $startAt, endAt: $endAt)';
  }
}

/// @nodoc
abstract mixin class $ScheduleOwnerSlotCreatedCopyWith<$Res>
    implements $ScheduleEventCopyWith<$Res> {
  factory $ScheduleOwnerSlotCreatedCopyWith(ScheduleOwnerSlotCreated value,
          $Res Function(ScheduleOwnerSlotCreated) _then) =
      _$ScheduleOwnerSlotCreatedCopyWithImpl;
  @useResult
  $Res call({DateTime startAt, DateTime endAt});
}

/// @nodoc
class _$ScheduleOwnerSlotCreatedCopyWithImpl<$Res>
    implements $ScheduleOwnerSlotCreatedCopyWith<$Res> {
  _$ScheduleOwnerSlotCreatedCopyWithImpl(this._self, this._then);

  final ScheduleOwnerSlotCreated _self;
  final $Res Function(ScheduleOwnerSlotCreated) _then;

  /// Create a copy of ScheduleEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? startAt = null,
    Object? endAt = null,
  }) {
    return _then(ScheduleOwnerSlotCreated(
      startAt: null == startAt
          ? _self.startAt
          : startAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endAt: null == endAt
          ? _self.endAt
          : endAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc

class ScheduleOpenSlotCreated implements ScheduleEvent {
  const ScheduleOpenSlotCreated({required this.startAt, required this.endAt});

  final DateTime startAt;
  final DateTime endAt;

  /// Create a copy of ScheduleEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ScheduleOpenSlotCreatedCopyWith<ScheduleOpenSlotCreated> get copyWith =>
      _$ScheduleOpenSlotCreatedCopyWithImpl<ScheduleOpenSlotCreated>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ScheduleOpenSlotCreated &&
            (identical(other.startAt, startAt) || other.startAt == startAt) &&
            (identical(other.endAt, endAt) || other.endAt == endAt));
  }

  @override
  int get hashCode => Object.hash(runtimeType, startAt, endAt);

  @override
  String toString() {
    return 'ScheduleEvent.openSlotCreated(startAt: $startAt, endAt: $endAt)';
  }
}

/// @nodoc
abstract mixin class $ScheduleOpenSlotCreatedCopyWith<$Res>
    implements $ScheduleEventCopyWith<$Res> {
  factory $ScheduleOpenSlotCreatedCopyWith(ScheduleOpenSlotCreated value,
          $Res Function(ScheduleOpenSlotCreated) _then) =
      _$ScheduleOpenSlotCreatedCopyWithImpl;
  @useResult
  $Res call({DateTime startAt, DateTime endAt});
}

/// @nodoc
class _$ScheduleOpenSlotCreatedCopyWithImpl<$Res>
    implements $ScheduleOpenSlotCreatedCopyWith<$Res> {
  _$ScheduleOpenSlotCreatedCopyWithImpl(this._self, this._then);

  final ScheduleOpenSlotCreated _self;
  final $Res Function(ScheduleOpenSlotCreated) _then;

  /// Create a copy of ScheduleEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? startAt = null,
    Object? endAt = null,
  }) {
    return _then(ScheduleOpenSlotCreated(
      startAt: null == startAt
          ? _self.startAt
          : startAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endAt: null == endAt
          ? _self.endAt
          : endAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc

class ScheduleManualBookingCreated implements ScheduleEvent {
  const ScheduleManualBookingCreated(
      {required this.startAt,
      required this.endAt,
      this.customerName,
      this.customerPhone,
      this.notes,
      this.pricePerHourOverride});

  final DateTime startAt;
  final DateTime endAt;
  final String? customerName;
  final String? customerPhone;
  final String? notes;
  final int? pricePerHourOverride;

  /// Create a copy of ScheduleEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ScheduleManualBookingCreatedCopyWith<ScheduleManualBookingCreated>
      get copyWith => _$ScheduleManualBookingCreatedCopyWithImpl<
          ScheduleManualBookingCreated>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ScheduleManualBookingCreated &&
            (identical(other.startAt, startAt) || other.startAt == startAt) &&
            (identical(other.endAt, endAt) || other.endAt == endAt) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.customerPhone, customerPhone) ||
                other.customerPhone == customerPhone) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.pricePerHourOverride, pricePerHourOverride) ||
                other.pricePerHourOverride == pricePerHourOverride));
  }

  @override
  int get hashCode => Object.hash(runtimeType, startAt, endAt, customerName,
      customerPhone, notes, pricePerHourOverride);

  @override
  String toString() {
    return 'ScheduleEvent.manualBookingCreated(startAt: $startAt, endAt: $endAt, customerName: $customerName, customerPhone: $customerPhone, notes: $notes, pricePerHourOverride: $pricePerHourOverride)';
  }
}

/// @nodoc
abstract mixin class $ScheduleManualBookingCreatedCopyWith<$Res>
    implements $ScheduleEventCopyWith<$Res> {
  factory $ScheduleManualBookingCreatedCopyWith(
          ScheduleManualBookingCreated value,
          $Res Function(ScheduleManualBookingCreated) _then) =
      _$ScheduleManualBookingCreatedCopyWithImpl;
  @useResult
  $Res call(
      {DateTime startAt,
      DateTime endAt,
      String? customerName,
      String? customerPhone,
      String? notes,
      int? pricePerHourOverride});
}

/// @nodoc
class _$ScheduleManualBookingCreatedCopyWithImpl<$Res>
    implements $ScheduleManualBookingCreatedCopyWith<$Res> {
  _$ScheduleManualBookingCreatedCopyWithImpl(this._self, this._then);

  final ScheduleManualBookingCreated _self;
  final $Res Function(ScheduleManualBookingCreated) _then;

  /// Create a copy of ScheduleEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? startAt = null,
    Object? endAt = null,
    Object? customerName = freezed,
    Object? customerPhone = freezed,
    Object? notes = freezed,
    Object? pricePerHourOverride = freezed,
  }) {
    return _then(ScheduleManualBookingCreated(
      startAt: null == startAt
          ? _self.startAt
          : startAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endAt: null == endAt
          ? _self.endAt
          : endAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      customerName: freezed == customerName
          ? _self.customerName
          : customerName // ignore: cast_nullable_to_non_nullable
              as String?,
      customerPhone: freezed == customerPhone
          ? _self.customerPhone
          : customerPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      pricePerHourOverride: freezed == pricePerHourOverride
          ? _self.pricePerHourOverride
          : pricePerHourOverride // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc

class ScheduleBookingResultCleared implements ScheduleEvent {
  const ScheduleBookingResultCleared();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ScheduleBookingResultCleared);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'ScheduleEvent.bookingResultCleared()';
  }
}

/// @nodoc

class ScheduleSlotBlocked implements ScheduleEvent {
  const ScheduleSlotBlocked(this.slotId, {this.reason});

  final String slotId;
  final String? reason;

  /// Create a copy of ScheduleEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ScheduleSlotBlockedCopyWith<ScheduleSlotBlocked> get copyWith =>
      _$ScheduleSlotBlockedCopyWithImpl<ScheduleSlotBlocked>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ScheduleSlotBlocked &&
            (identical(other.slotId, slotId) || other.slotId == slotId) &&
            (identical(other.reason, reason) || other.reason == reason));
  }

  @override
  int get hashCode => Object.hash(runtimeType, slotId, reason);

  @override
  String toString() {
    return 'ScheduleEvent.slotBlocked(slotId: $slotId, reason: $reason)';
  }
}

/// @nodoc
abstract mixin class $ScheduleSlotBlockedCopyWith<$Res>
    implements $ScheduleEventCopyWith<$Res> {
  factory $ScheduleSlotBlockedCopyWith(
          ScheduleSlotBlocked value, $Res Function(ScheduleSlotBlocked) _then) =
      _$ScheduleSlotBlockedCopyWithImpl;
  @useResult
  $Res call({String slotId, String? reason});
}

/// @nodoc
class _$ScheduleSlotBlockedCopyWithImpl<$Res>
    implements $ScheduleSlotBlockedCopyWith<$Res> {
  _$ScheduleSlotBlockedCopyWithImpl(this._self, this._then);

  final ScheduleSlotBlocked _self;
  final $Res Function(ScheduleSlotBlocked) _then;

  /// Create a copy of ScheduleEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? slotId = null,
    Object? reason = freezed,
  }) {
    return _then(ScheduleSlotBlocked(
      null == slotId
          ? _self.slotId
          : slotId // ignore: cast_nullable_to_non_nullable
              as String,
      reason: freezed == reason
          ? _self.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class ScheduleSlotUnblocked implements ScheduleEvent {
  const ScheduleSlotUnblocked(this.slotId);

  final String slotId;

  /// Create a copy of ScheduleEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ScheduleSlotUnblockedCopyWith<ScheduleSlotUnblocked> get copyWith =>
      _$ScheduleSlotUnblockedCopyWithImpl<ScheduleSlotUnblocked>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ScheduleSlotUnblocked &&
            (identical(other.slotId, slotId) || other.slotId == slotId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, slotId);

  @override
  String toString() {
    return 'ScheduleEvent.slotUnblocked(slotId: $slotId)';
  }
}

/// @nodoc
abstract mixin class $ScheduleSlotUnblockedCopyWith<$Res>
    implements $ScheduleEventCopyWith<$Res> {
  factory $ScheduleSlotUnblockedCopyWith(ScheduleSlotUnblocked value,
          $Res Function(ScheduleSlotUnblocked) _then) =
      _$ScheduleSlotUnblockedCopyWithImpl;
  @useResult
  $Res call({String slotId});
}

/// @nodoc
class _$ScheduleSlotUnblockedCopyWithImpl<$Res>
    implements $ScheduleSlotUnblockedCopyWith<$Res> {
  _$ScheduleSlotUnblockedCopyWithImpl(this._self, this._then);

  final ScheduleSlotUnblocked _self;
  final $Res Function(ScheduleSlotUnblocked) _then;

  /// Create a copy of ScheduleEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? slotId = null,
  }) {
    return _then(ScheduleSlotUnblocked(
      null == slotId
          ? _self.slotId
          : slotId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
