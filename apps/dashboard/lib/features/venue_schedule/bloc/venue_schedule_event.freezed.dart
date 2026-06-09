// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'venue_schedule_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VenueScheduleEvent {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is VenueScheduleEvent);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'VenueScheduleEvent()';
  }
}

/// @nodoc
class $VenueScheduleEventCopyWith<$Res> {
  $VenueScheduleEventCopyWith(
      VenueScheduleEvent _, $Res Function(VenueScheduleEvent) __);
}

/// Adds pattern-matching-related methods to [VenueScheduleEvent].
extension VenueScheduleEventPatterns on VenueScheduleEvent {
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
    TResult Function(VenueScheduleStarted value)? started,
    TResult Function(VenueScheduleViewChanged value)? viewChanged,
    TResult Function(VenueScheduleDateMoved value)? dateMoved,
    TResult Function(VenueScheduleTodayPressed value)? todayPressed,
    TResult Function(VenueScheduleVenueSelected value)? venueSelected,
    TResult Function(VenueScheduleSportFilterToggled value)? sportFilterToggled,
    TResult Function(VenueScheduleStateFilterToggled value)? stateFilterToggled,
    TResult Function(VenueScheduleSlotTapped value)? slotTapped,
    TResult Function(VenueScheduleEmptyCellTapped value)? emptyCellTapped,
    TResult Function(VenueScheduleDragBlockRequested value)? dragBlockRequested,
    TResult Function(VenueScheduleMonthDayTapped value)? monthDayTapped,
    TResult Function(VenueScheduleCreateSlotSubmitted value)?
        createSlotSubmitted,
    TResult Function(VenueScheduleBlockSubmitted value)? blockSubmitted,
    TResult Function(VenueScheduleApproveRequested value)? approveRequested,
    TResult Function(VenueScheduleRejectRequested value)? rejectRequested,
    TResult Function(VenueScheduleCancelRequested value)? cancelRequested,
    TResult Function(VenueScheduleToastCleared value)? toastCleared,
    TResult Function(VenueScheduleSheetClosed value)? sheetClosed,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case VenueScheduleStarted() when started != null:
        return started(_that);
      case VenueScheduleViewChanged() when viewChanged != null:
        return viewChanged(_that);
      case VenueScheduleDateMoved() when dateMoved != null:
        return dateMoved(_that);
      case VenueScheduleTodayPressed() when todayPressed != null:
        return todayPressed(_that);
      case VenueScheduleVenueSelected() when venueSelected != null:
        return venueSelected(_that);
      case VenueScheduleSportFilterToggled() when sportFilterToggled != null:
        return sportFilterToggled(_that);
      case VenueScheduleStateFilterToggled() when stateFilterToggled != null:
        return stateFilterToggled(_that);
      case VenueScheduleSlotTapped() when slotTapped != null:
        return slotTapped(_that);
      case VenueScheduleEmptyCellTapped() when emptyCellTapped != null:
        return emptyCellTapped(_that);
      case VenueScheduleDragBlockRequested() when dragBlockRequested != null:
        return dragBlockRequested(_that);
      case VenueScheduleMonthDayTapped() when monthDayTapped != null:
        return monthDayTapped(_that);
      case VenueScheduleCreateSlotSubmitted() when createSlotSubmitted != null:
        return createSlotSubmitted(_that);
      case VenueScheduleBlockSubmitted() when blockSubmitted != null:
        return blockSubmitted(_that);
      case VenueScheduleApproveRequested() when approveRequested != null:
        return approveRequested(_that);
      case VenueScheduleRejectRequested() when rejectRequested != null:
        return rejectRequested(_that);
      case VenueScheduleCancelRequested() when cancelRequested != null:
        return cancelRequested(_that);
      case VenueScheduleToastCleared() when toastCleared != null:
        return toastCleared(_that);
      case VenueScheduleSheetClosed() when sheetClosed != null:
        return sheetClosed(_that);
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
    required TResult Function(VenueScheduleStarted value) started,
    required TResult Function(VenueScheduleViewChanged value) viewChanged,
    required TResult Function(VenueScheduleDateMoved value) dateMoved,
    required TResult Function(VenueScheduleTodayPressed value) todayPressed,
    required TResult Function(VenueScheduleVenueSelected value) venueSelected,
    required TResult Function(VenueScheduleSportFilterToggled value)
        sportFilterToggled,
    required TResult Function(VenueScheduleStateFilterToggled value)
        stateFilterToggled,
    required TResult Function(VenueScheduleSlotTapped value) slotTapped,
    required TResult Function(VenueScheduleEmptyCellTapped value)
        emptyCellTapped,
    required TResult Function(VenueScheduleDragBlockRequested value)
        dragBlockRequested,
    required TResult Function(VenueScheduleMonthDayTapped value) monthDayTapped,
    required TResult Function(VenueScheduleCreateSlotSubmitted value)
        createSlotSubmitted,
    required TResult Function(VenueScheduleBlockSubmitted value) blockSubmitted,
    required TResult Function(VenueScheduleApproveRequested value)
        approveRequested,
    required TResult Function(VenueScheduleRejectRequested value)
        rejectRequested,
    required TResult Function(VenueScheduleCancelRequested value)
        cancelRequested,
    required TResult Function(VenueScheduleToastCleared value) toastCleared,
    required TResult Function(VenueScheduleSheetClosed value) sheetClosed,
  }) {
    final _that = this;
    switch (_that) {
      case VenueScheduleStarted():
        return started(_that);
      case VenueScheduleViewChanged():
        return viewChanged(_that);
      case VenueScheduleDateMoved():
        return dateMoved(_that);
      case VenueScheduleTodayPressed():
        return todayPressed(_that);
      case VenueScheduleVenueSelected():
        return venueSelected(_that);
      case VenueScheduleSportFilterToggled():
        return sportFilterToggled(_that);
      case VenueScheduleStateFilterToggled():
        return stateFilterToggled(_that);
      case VenueScheduleSlotTapped():
        return slotTapped(_that);
      case VenueScheduleEmptyCellTapped():
        return emptyCellTapped(_that);
      case VenueScheduleDragBlockRequested():
        return dragBlockRequested(_that);
      case VenueScheduleMonthDayTapped():
        return monthDayTapped(_that);
      case VenueScheduleCreateSlotSubmitted():
        return createSlotSubmitted(_that);
      case VenueScheduleBlockSubmitted():
        return blockSubmitted(_that);
      case VenueScheduleApproveRequested():
        return approveRequested(_that);
      case VenueScheduleRejectRequested():
        return rejectRequested(_that);
      case VenueScheduleCancelRequested():
        return cancelRequested(_that);
      case VenueScheduleToastCleared():
        return toastCleared(_that);
      case VenueScheduleSheetClosed():
        return sheetClosed(_that);
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
    TResult? Function(VenueScheduleStarted value)? started,
    TResult? Function(VenueScheduleViewChanged value)? viewChanged,
    TResult? Function(VenueScheduleDateMoved value)? dateMoved,
    TResult? Function(VenueScheduleTodayPressed value)? todayPressed,
    TResult? Function(VenueScheduleVenueSelected value)? venueSelected,
    TResult? Function(VenueScheduleSportFilterToggled value)?
        sportFilterToggled,
    TResult? Function(VenueScheduleStateFilterToggled value)?
        stateFilterToggled,
    TResult? Function(VenueScheduleSlotTapped value)? slotTapped,
    TResult? Function(VenueScheduleEmptyCellTapped value)? emptyCellTapped,
    TResult? Function(VenueScheduleDragBlockRequested value)?
        dragBlockRequested,
    TResult? Function(VenueScheduleMonthDayTapped value)? monthDayTapped,
    TResult? Function(VenueScheduleCreateSlotSubmitted value)?
        createSlotSubmitted,
    TResult? Function(VenueScheduleBlockSubmitted value)? blockSubmitted,
    TResult? Function(VenueScheduleApproveRequested value)? approveRequested,
    TResult? Function(VenueScheduleRejectRequested value)? rejectRequested,
    TResult? Function(VenueScheduleCancelRequested value)? cancelRequested,
    TResult? Function(VenueScheduleToastCleared value)? toastCleared,
    TResult? Function(VenueScheduleSheetClosed value)? sheetClosed,
  }) {
    final _that = this;
    switch (_that) {
      case VenueScheduleStarted() when started != null:
        return started(_that);
      case VenueScheduleViewChanged() when viewChanged != null:
        return viewChanged(_that);
      case VenueScheduleDateMoved() when dateMoved != null:
        return dateMoved(_that);
      case VenueScheduleTodayPressed() when todayPressed != null:
        return todayPressed(_that);
      case VenueScheduleVenueSelected() when venueSelected != null:
        return venueSelected(_that);
      case VenueScheduleSportFilterToggled() when sportFilterToggled != null:
        return sportFilterToggled(_that);
      case VenueScheduleStateFilterToggled() when stateFilterToggled != null:
        return stateFilterToggled(_that);
      case VenueScheduleSlotTapped() when slotTapped != null:
        return slotTapped(_that);
      case VenueScheduleEmptyCellTapped() when emptyCellTapped != null:
        return emptyCellTapped(_that);
      case VenueScheduleDragBlockRequested() when dragBlockRequested != null:
        return dragBlockRequested(_that);
      case VenueScheduleMonthDayTapped() when monthDayTapped != null:
        return monthDayTapped(_that);
      case VenueScheduleCreateSlotSubmitted() when createSlotSubmitted != null:
        return createSlotSubmitted(_that);
      case VenueScheduleBlockSubmitted() when blockSubmitted != null:
        return blockSubmitted(_that);
      case VenueScheduleApproveRequested() when approveRequested != null:
        return approveRequested(_that);
      case VenueScheduleRejectRequested() when rejectRequested != null:
        return rejectRequested(_that);
      case VenueScheduleCancelRequested() when cancelRequested != null:
        return cancelRequested(_that);
      case VenueScheduleToastCleared() when toastCleared != null:
        return toastCleared(_that);
      case VenueScheduleSheetClosed() when sheetClosed != null:
        return sheetClosed(_that);
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
    TResult Function(ScheduleView view)? viewChanged,
    TResult Function(int delta)? dateMoved,
    TResult Function()? todayPressed,
    TResult Function(String venueId)? venueSelected,
    TResult Function(SportType sport)? sportFilterToggled,
    TResult Function(SlotState state)? stateFilterToggled,
    TResult Function(Slot slot)? slotTapped,
    TResult Function(String venueId, double startHour, int? weekday,
            double durationHours)?
        emptyCellTapped,
    TResult Function(
            String venueId, double startHour, double endHour, int? weekday)?
        dragBlockRequested,
    TResult Function(DateTime date)? monthDayTapped,
    TResult Function(CreateSlotRequest request, bool repeat, List<int> weekdays,
            int weeks)?
        createSlotSubmitted,
    TResult Function(BlockTimeRequest request, bool repeat, List<int> weekdays,
            int weeks)?
        blockSubmitted,
    TResult Function(String slotId)? approveRequested,
    TResult Function(String slotId)? rejectRequested,
    TResult Function(String slotId)? cancelRequested,
    TResult Function()? toastCleared,
    TResult Function()? sheetClosed,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case VenueScheduleStarted() when started != null:
        return started();
      case VenueScheduleViewChanged() when viewChanged != null:
        return viewChanged(_that.view);
      case VenueScheduleDateMoved() when dateMoved != null:
        return dateMoved(_that.delta);
      case VenueScheduleTodayPressed() when todayPressed != null:
        return todayPressed();
      case VenueScheduleVenueSelected() when venueSelected != null:
        return venueSelected(_that.venueId);
      case VenueScheduleSportFilterToggled() when sportFilterToggled != null:
        return sportFilterToggled(_that.sport);
      case VenueScheduleStateFilterToggled() when stateFilterToggled != null:
        return stateFilterToggled(_that.state);
      case VenueScheduleSlotTapped() when slotTapped != null:
        return slotTapped(_that.slot);
      case VenueScheduleEmptyCellTapped() when emptyCellTapped != null:
        return emptyCellTapped(
            _that.venueId, _that.startHour, _that.weekday, _that.durationHours);
      case VenueScheduleDragBlockRequested() when dragBlockRequested != null:
        return dragBlockRequested(
            _that.venueId, _that.startHour, _that.endHour, _that.weekday);
      case VenueScheduleMonthDayTapped() when monthDayTapped != null:
        return monthDayTapped(_that.date);
      case VenueScheduleCreateSlotSubmitted() when createSlotSubmitted != null:
        return createSlotSubmitted(
            _that.request, _that.repeat, _that.weekdays, _that.weeks);
      case VenueScheduleBlockSubmitted() when blockSubmitted != null:
        return blockSubmitted(
            _that.request, _that.repeat, _that.weekdays, _that.weeks);
      case VenueScheduleApproveRequested() when approveRequested != null:
        return approveRequested(_that.slotId);
      case VenueScheduleRejectRequested() when rejectRequested != null:
        return rejectRequested(_that.slotId);
      case VenueScheduleCancelRequested() when cancelRequested != null:
        return cancelRequested(_that.slotId);
      case VenueScheduleToastCleared() when toastCleared != null:
        return toastCleared();
      case VenueScheduleSheetClosed() when sheetClosed != null:
        return sheetClosed();
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
    required TResult Function(ScheduleView view) viewChanged,
    required TResult Function(int delta) dateMoved,
    required TResult Function() todayPressed,
    required TResult Function(String venueId) venueSelected,
    required TResult Function(SportType sport) sportFilterToggled,
    required TResult Function(SlotState state) stateFilterToggled,
    required TResult Function(Slot slot) slotTapped,
    required TResult Function(String venueId, double startHour, int? weekday,
            double durationHours)
        emptyCellTapped,
    required TResult Function(
            String venueId, double startHour, double endHour, int? weekday)
        dragBlockRequested,
    required TResult Function(DateTime date) monthDayTapped,
    required TResult Function(CreateSlotRequest request, bool repeat,
            List<int> weekdays, int weeks)
        createSlotSubmitted,
    required TResult Function(BlockTimeRequest request, bool repeat,
            List<int> weekdays, int weeks)
        blockSubmitted,
    required TResult Function(String slotId) approveRequested,
    required TResult Function(String slotId) rejectRequested,
    required TResult Function(String slotId) cancelRequested,
    required TResult Function() toastCleared,
    required TResult Function() sheetClosed,
  }) {
    final _that = this;
    switch (_that) {
      case VenueScheduleStarted():
        return started();
      case VenueScheduleViewChanged():
        return viewChanged(_that.view);
      case VenueScheduleDateMoved():
        return dateMoved(_that.delta);
      case VenueScheduleTodayPressed():
        return todayPressed();
      case VenueScheduleVenueSelected():
        return venueSelected(_that.venueId);
      case VenueScheduleSportFilterToggled():
        return sportFilterToggled(_that.sport);
      case VenueScheduleStateFilterToggled():
        return stateFilterToggled(_that.state);
      case VenueScheduleSlotTapped():
        return slotTapped(_that.slot);
      case VenueScheduleEmptyCellTapped():
        return emptyCellTapped(
            _that.venueId, _that.startHour, _that.weekday, _that.durationHours);
      case VenueScheduleDragBlockRequested():
        return dragBlockRequested(
            _that.venueId, _that.startHour, _that.endHour, _that.weekday);
      case VenueScheduleMonthDayTapped():
        return monthDayTapped(_that.date);
      case VenueScheduleCreateSlotSubmitted():
        return createSlotSubmitted(
            _that.request, _that.repeat, _that.weekdays, _that.weeks);
      case VenueScheduleBlockSubmitted():
        return blockSubmitted(
            _that.request, _that.repeat, _that.weekdays, _that.weeks);
      case VenueScheduleApproveRequested():
        return approveRequested(_that.slotId);
      case VenueScheduleRejectRequested():
        return rejectRequested(_that.slotId);
      case VenueScheduleCancelRequested():
        return cancelRequested(_that.slotId);
      case VenueScheduleToastCleared():
        return toastCleared();
      case VenueScheduleSheetClosed():
        return sheetClosed();
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
    TResult? Function(ScheduleView view)? viewChanged,
    TResult? Function(int delta)? dateMoved,
    TResult? Function()? todayPressed,
    TResult? Function(String venueId)? venueSelected,
    TResult? Function(SportType sport)? sportFilterToggled,
    TResult? Function(SlotState state)? stateFilterToggled,
    TResult? Function(Slot slot)? slotTapped,
    TResult? Function(String venueId, double startHour, int? weekday,
            double durationHours)?
        emptyCellTapped,
    TResult? Function(
            String venueId, double startHour, double endHour, int? weekday)?
        dragBlockRequested,
    TResult? Function(DateTime date)? monthDayTapped,
    TResult? Function(CreateSlotRequest request, bool repeat,
            List<int> weekdays, int weeks)?
        createSlotSubmitted,
    TResult? Function(BlockTimeRequest request, bool repeat, List<int> weekdays,
            int weeks)?
        blockSubmitted,
    TResult? Function(String slotId)? approveRequested,
    TResult? Function(String slotId)? rejectRequested,
    TResult? Function(String slotId)? cancelRequested,
    TResult? Function()? toastCleared,
    TResult? Function()? sheetClosed,
  }) {
    final _that = this;
    switch (_that) {
      case VenueScheduleStarted() when started != null:
        return started();
      case VenueScheduleViewChanged() when viewChanged != null:
        return viewChanged(_that.view);
      case VenueScheduleDateMoved() when dateMoved != null:
        return dateMoved(_that.delta);
      case VenueScheduleTodayPressed() when todayPressed != null:
        return todayPressed();
      case VenueScheduleVenueSelected() when venueSelected != null:
        return venueSelected(_that.venueId);
      case VenueScheduleSportFilterToggled() when sportFilterToggled != null:
        return sportFilterToggled(_that.sport);
      case VenueScheduleStateFilterToggled() when stateFilterToggled != null:
        return stateFilterToggled(_that.state);
      case VenueScheduleSlotTapped() when slotTapped != null:
        return slotTapped(_that.slot);
      case VenueScheduleEmptyCellTapped() when emptyCellTapped != null:
        return emptyCellTapped(
            _that.venueId, _that.startHour, _that.weekday, _that.durationHours);
      case VenueScheduleDragBlockRequested() when dragBlockRequested != null:
        return dragBlockRequested(
            _that.venueId, _that.startHour, _that.endHour, _that.weekday);
      case VenueScheduleMonthDayTapped() when monthDayTapped != null:
        return monthDayTapped(_that.date);
      case VenueScheduleCreateSlotSubmitted() when createSlotSubmitted != null:
        return createSlotSubmitted(
            _that.request, _that.repeat, _that.weekdays, _that.weeks);
      case VenueScheduleBlockSubmitted() when blockSubmitted != null:
        return blockSubmitted(
            _that.request, _that.repeat, _that.weekdays, _that.weeks);
      case VenueScheduleApproveRequested() when approveRequested != null:
        return approveRequested(_that.slotId);
      case VenueScheduleRejectRequested() when rejectRequested != null:
        return rejectRequested(_that.slotId);
      case VenueScheduleCancelRequested() when cancelRequested != null:
        return cancelRequested(_that.slotId);
      case VenueScheduleToastCleared() when toastCleared != null:
        return toastCleared();
      case VenueScheduleSheetClosed() when sheetClosed != null:
        return sheetClosed();
      case _:
        return null;
    }
  }
}

/// @nodoc

class VenueScheduleStarted implements VenueScheduleEvent {
  const VenueScheduleStarted();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is VenueScheduleStarted);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'VenueScheduleEvent.started()';
  }
}

/// @nodoc

class VenueScheduleViewChanged implements VenueScheduleEvent {
  const VenueScheduleViewChanged(this.view);

  final ScheduleView view;

  /// Create a copy of VenueScheduleEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $VenueScheduleViewChangedCopyWith<VenueScheduleViewChanged> get copyWith =>
      _$VenueScheduleViewChangedCopyWithImpl<VenueScheduleViewChanged>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is VenueScheduleViewChanged &&
            (identical(other.view, view) || other.view == view));
  }

  @override
  int get hashCode => Object.hash(runtimeType, view);

  @override
  String toString() {
    return 'VenueScheduleEvent.viewChanged(view: $view)';
  }
}

/// @nodoc
abstract mixin class $VenueScheduleViewChangedCopyWith<$Res>
    implements $VenueScheduleEventCopyWith<$Res> {
  factory $VenueScheduleViewChangedCopyWith(VenueScheduleViewChanged value,
          $Res Function(VenueScheduleViewChanged) _then) =
      _$VenueScheduleViewChangedCopyWithImpl;
  @useResult
  $Res call({ScheduleView view});
}

/// @nodoc
class _$VenueScheduleViewChangedCopyWithImpl<$Res>
    implements $VenueScheduleViewChangedCopyWith<$Res> {
  _$VenueScheduleViewChangedCopyWithImpl(this._self, this._then);

  final VenueScheduleViewChanged _self;
  final $Res Function(VenueScheduleViewChanged) _then;

  /// Create a copy of VenueScheduleEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? view = null,
  }) {
    return _then(VenueScheduleViewChanged(
      null == view
          ? _self.view
          : view // ignore: cast_nullable_to_non_nullable
              as ScheduleView,
    ));
  }
}

/// @nodoc

class VenueScheduleDateMoved implements VenueScheduleEvent {
  const VenueScheduleDateMoved(this.delta);

  final int delta;

  /// Create a copy of VenueScheduleEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $VenueScheduleDateMovedCopyWith<VenueScheduleDateMoved> get copyWith =>
      _$VenueScheduleDateMovedCopyWithImpl<VenueScheduleDateMoved>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is VenueScheduleDateMoved &&
            (identical(other.delta, delta) || other.delta == delta));
  }

  @override
  int get hashCode => Object.hash(runtimeType, delta);

  @override
  String toString() {
    return 'VenueScheduleEvent.dateMoved(delta: $delta)';
  }
}

/// @nodoc
abstract mixin class $VenueScheduleDateMovedCopyWith<$Res>
    implements $VenueScheduleEventCopyWith<$Res> {
  factory $VenueScheduleDateMovedCopyWith(VenueScheduleDateMoved value,
          $Res Function(VenueScheduleDateMoved) _then) =
      _$VenueScheduleDateMovedCopyWithImpl;
  @useResult
  $Res call({int delta});
}

/// @nodoc
class _$VenueScheduleDateMovedCopyWithImpl<$Res>
    implements $VenueScheduleDateMovedCopyWith<$Res> {
  _$VenueScheduleDateMovedCopyWithImpl(this._self, this._then);

  final VenueScheduleDateMoved _self;
  final $Res Function(VenueScheduleDateMoved) _then;

  /// Create a copy of VenueScheduleEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? delta = null,
  }) {
    return _then(VenueScheduleDateMoved(
      null == delta
          ? _self.delta
          : delta // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class VenueScheduleTodayPressed implements VenueScheduleEvent {
  const VenueScheduleTodayPressed();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is VenueScheduleTodayPressed);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'VenueScheduleEvent.todayPressed()';
  }
}

/// @nodoc

class VenueScheduleVenueSelected implements VenueScheduleEvent {
  const VenueScheduleVenueSelected(this.venueId);

  final String venueId;

  /// Create a copy of VenueScheduleEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $VenueScheduleVenueSelectedCopyWith<VenueScheduleVenueSelected>
      get copyWith =>
          _$VenueScheduleVenueSelectedCopyWithImpl<VenueScheduleVenueSelected>(
              this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is VenueScheduleVenueSelected &&
            (identical(other.venueId, venueId) || other.venueId == venueId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, venueId);

  @override
  String toString() {
    return 'VenueScheduleEvent.venueSelected(venueId: $venueId)';
  }
}

/// @nodoc
abstract mixin class $VenueScheduleVenueSelectedCopyWith<$Res>
    implements $VenueScheduleEventCopyWith<$Res> {
  factory $VenueScheduleVenueSelectedCopyWith(VenueScheduleVenueSelected value,
          $Res Function(VenueScheduleVenueSelected) _then) =
      _$VenueScheduleVenueSelectedCopyWithImpl;
  @useResult
  $Res call({String venueId});
}

/// @nodoc
class _$VenueScheduleVenueSelectedCopyWithImpl<$Res>
    implements $VenueScheduleVenueSelectedCopyWith<$Res> {
  _$VenueScheduleVenueSelectedCopyWithImpl(this._self, this._then);

  final VenueScheduleVenueSelected _self;
  final $Res Function(VenueScheduleVenueSelected) _then;

  /// Create a copy of VenueScheduleEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? venueId = null,
  }) {
    return _then(VenueScheduleVenueSelected(
      null == venueId
          ? _self.venueId
          : venueId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class VenueScheduleSportFilterToggled implements VenueScheduleEvent {
  const VenueScheduleSportFilterToggled(this.sport);

  final SportType sport;

  /// Create a copy of VenueScheduleEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $VenueScheduleSportFilterToggledCopyWith<VenueScheduleSportFilterToggled>
      get copyWith => _$VenueScheduleSportFilterToggledCopyWithImpl<
          VenueScheduleSportFilterToggled>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is VenueScheduleSportFilterToggled &&
            (identical(other.sport, sport) || other.sport == sport));
  }

  @override
  int get hashCode => Object.hash(runtimeType, sport);

  @override
  String toString() {
    return 'VenueScheduleEvent.sportFilterToggled(sport: $sport)';
  }
}

/// @nodoc
abstract mixin class $VenueScheduleSportFilterToggledCopyWith<$Res>
    implements $VenueScheduleEventCopyWith<$Res> {
  factory $VenueScheduleSportFilterToggledCopyWith(
          VenueScheduleSportFilterToggled value,
          $Res Function(VenueScheduleSportFilterToggled) _then) =
      _$VenueScheduleSportFilterToggledCopyWithImpl;
  @useResult
  $Res call({SportType sport});
}

/// @nodoc
class _$VenueScheduleSportFilterToggledCopyWithImpl<$Res>
    implements $VenueScheduleSportFilterToggledCopyWith<$Res> {
  _$VenueScheduleSportFilterToggledCopyWithImpl(this._self, this._then);

  final VenueScheduleSportFilterToggled _self;
  final $Res Function(VenueScheduleSportFilterToggled) _then;

  /// Create a copy of VenueScheduleEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? sport = null,
  }) {
    return _then(VenueScheduleSportFilterToggled(
      null == sport
          ? _self.sport
          : sport // ignore: cast_nullable_to_non_nullable
              as SportType,
    ));
  }
}

/// @nodoc

class VenueScheduleStateFilterToggled implements VenueScheduleEvent {
  const VenueScheduleStateFilterToggled(this.state);

  final SlotState state;

  /// Create a copy of VenueScheduleEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $VenueScheduleStateFilterToggledCopyWith<VenueScheduleStateFilterToggled>
      get copyWith => _$VenueScheduleStateFilterToggledCopyWithImpl<
          VenueScheduleStateFilterToggled>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is VenueScheduleStateFilterToggled &&
            (identical(other.state, state) || other.state == state));
  }

  @override
  int get hashCode => Object.hash(runtimeType, state);

  @override
  String toString() {
    return 'VenueScheduleEvent.stateFilterToggled(state: $state)';
  }
}

/// @nodoc
abstract mixin class $VenueScheduleStateFilterToggledCopyWith<$Res>
    implements $VenueScheduleEventCopyWith<$Res> {
  factory $VenueScheduleStateFilterToggledCopyWith(
          VenueScheduleStateFilterToggled value,
          $Res Function(VenueScheduleStateFilterToggled) _then) =
      _$VenueScheduleStateFilterToggledCopyWithImpl;
  @useResult
  $Res call({SlotState state});
}

/// @nodoc
class _$VenueScheduleStateFilterToggledCopyWithImpl<$Res>
    implements $VenueScheduleStateFilterToggledCopyWith<$Res> {
  _$VenueScheduleStateFilterToggledCopyWithImpl(this._self, this._then);

  final VenueScheduleStateFilterToggled _self;
  final $Res Function(VenueScheduleStateFilterToggled) _then;

  /// Create a copy of VenueScheduleEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? state = null,
  }) {
    return _then(VenueScheduleStateFilterToggled(
      null == state
          ? _self.state
          : state // ignore: cast_nullable_to_non_nullable
              as SlotState,
    ));
  }
}

/// @nodoc

class VenueScheduleSlotTapped implements VenueScheduleEvent {
  const VenueScheduleSlotTapped(this.slot);

  final Slot slot;

  /// Create a copy of VenueScheduleEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $VenueScheduleSlotTappedCopyWith<VenueScheduleSlotTapped> get copyWith =>
      _$VenueScheduleSlotTappedCopyWithImpl<VenueScheduleSlotTapped>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is VenueScheduleSlotTapped &&
            (identical(other.slot, slot) || other.slot == slot));
  }

  @override
  int get hashCode => Object.hash(runtimeType, slot);

  @override
  String toString() {
    return 'VenueScheduleEvent.slotTapped(slot: $slot)';
  }
}

/// @nodoc
abstract mixin class $VenueScheduleSlotTappedCopyWith<$Res>
    implements $VenueScheduleEventCopyWith<$Res> {
  factory $VenueScheduleSlotTappedCopyWith(VenueScheduleSlotTapped value,
          $Res Function(VenueScheduleSlotTapped) _then) =
      _$VenueScheduleSlotTappedCopyWithImpl;
  @useResult
  $Res call({Slot slot});

  $SlotCopyWith<$Res> get slot;
}

/// @nodoc
class _$VenueScheduleSlotTappedCopyWithImpl<$Res>
    implements $VenueScheduleSlotTappedCopyWith<$Res> {
  _$VenueScheduleSlotTappedCopyWithImpl(this._self, this._then);

  final VenueScheduleSlotTapped _self;
  final $Res Function(VenueScheduleSlotTapped) _then;

  /// Create a copy of VenueScheduleEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? slot = null,
  }) {
    return _then(VenueScheduleSlotTapped(
      null == slot
          ? _self.slot
          : slot // ignore: cast_nullable_to_non_nullable
              as Slot,
    ));
  }

  /// Create a copy of VenueScheduleEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SlotCopyWith<$Res> get slot {
    return $SlotCopyWith<$Res>(_self.slot, (value) {
      return _then(_self.copyWith(slot: value));
    });
  }
}

/// @nodoc

class VenueScheduleEmptyCellTapped implements VenueScheduleEvent {
  const VenueScheduleEmptyCellTapped(this.venueId, this.startHour,
      {this.weekday, this.durationHours = 1.0});

  final String venueId;
  final double startHour;
  final int? weekday;
  @JsonKey()
  final double durationHours;

  /// Create a copy of VenueScheduleEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $VenueScheduleEmptyCellTappedCopyWith<VenueScheduleEmptyCellTapped>
      get copyWith => _$VenueScheduleEmptyCellTappedCopyWithImpl<
          VenueScheduleEmptyCellTapped>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is VenueScheduleEmptyCellTapped &&
            (identical(other.venueId, venueId) || other.venueId == venueId) &&
            (identical(other.startHour, startHour) ||
                other.startHour == startHour) &&
            (identical(other.weekday, weekday) || other.weekday == weekday) &&
            (identical(other.durationHours, durationHours) ||
                other.durationHours == durationHours));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, venueId, startHour, weekday, durationHours);

  @override
  String toString() {
    return 'VenueScheduleEvent.emptyCellTapped(venueId: $venueId, startHour: $startHour, weekday: $weekday, durationHours: $durationHours)';
  }
}

/// @nodoc
abstract mixin class $VenueScheduleEmptyCellTappedCopyWith<$Res>
    implements $VenueScheduleEventCopyWith<$Res> {
  factory $VenueScheduleEmptyCellTappedCopyWith(
          VenueScheduleEmptyCellTapped value,
          $Res Function(VenueScheduleEmptyCellTapped) _then) =
      _$VenueScheduleEmptyCellTappedCopyWithImpl;
  @useResult
  $Res call(
      {String venueId, double startHour, int? weekday, double durationHours});
}

/// @nodoc
class _$VenueScheduleEmptyCellTappedCopyWithImpl<$Res>
    implements $VenueScheduleEmptyCellTappedCopyWith<$Res> {
  _$VenueScheduleEmptyCellTappedCopyWithImpl(this._self, this._then);

  final VenueScheduleEmptyCellTapped _self;
  final $Res Function(VenueScheduleEmptyCellTapped) _then;

  /// Create a copy of VenueScheduleEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? venueId = null,
    Object? startHour = null,
    Object? weekday = freezed,
    Object? durationHours = null,
  }) {
    return _then(VenueScheduleEmptyCellTapped(
      null == venueId
          ? _self.venueId
          : venueId // ignore: cast_nullable_to_non_nullable
              as String,
      null == startHour
          ? _self.startHour
          : startHour // ignore: cast_nullable_to_non_nullable
              as double,
      weekday: freezed == weekday
          ? _self.weekday
          : weekday // ignore: cast_nullable_to_non_nullable
              as int?,
      durationHours: null == durationHours
          ? _self.durationHours
          : durationHours // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc

class VenueScheduleDragBlockRequested implements VenueScheduleEvent {
  const VenueScheduleDragBlockRequested(
      this.venueId, this.startHour, this.endHour,
      {this.weekday});

  final String venueId;
  final double startHour;
  final double endHour;
  final int? weekday;

  /// Create a copy of VenueScheduleEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $VenueScheduleDragBlockRequestedCopyWith<VenueScheduleDragBlockRequested>
      get copyWith => _$VenueScheduleDragBlockRequestedCopyWithImpl<
          VenueScheduleDragBlockRequested>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is VenueScheduleDragBlockRequested &&
            (identical(other.venueId, venueId) || other.venueId == venueId) &&
            (identical(other.startHour, startHour) ||
                other.startHour == startHour) &&
            (identical(other.endHour, endHour) || other.endHour == endHour) &&
            (identical(other.weekday, weekday) || other.weekday == weekday));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, venueId, startHour, endHour, weekday);

  @override
  String toString() {
    return 'VenueScheduleEvent.dragBlockRequested(venueId: $venueId, startHour: $startHour, endHour: $endHour, weekday: $weekday)';
  }
}

/// @nodoc
abstract mixin class $VenueScheduleDragBlockRequestedCopyWith<$Res>
    implements $VenueScheduleEventCopyWith<$Res> {
  factory $VenueScheduleDragBlockRequestedCopyWith(
          VenueScheduleDragBlockRequested value,
          $Res Function(VenueScheduleDragBlockRequested) _then) =
      _$VenueScheduleDragBlockRequestedCopyWithImpl;
  @useResult
  $Res call({String venueId, double startHour, double endHour, int? weekday});
}

/// @nodoc
class _$VenueScheduleDragBlockRequestedCopyWithImpl<$Res>
    implements $VenueScheduleDragBlockRequestedCopyWith<$Res> {
  _$VenueScheduleDragBlockRequestedCopyWithImpl(this._self, this._then);

  final VenueScheduleDragBlockRequested _self;
  final $Res Function(VenueScheduleDragBlockRequested) _then;

  /// Create a copy of VenueScheduleEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? venueId = null,
    Object? startHour = null,
    Object? endHour = null,
    Object? weekday = freezed,
  }) {
    return _then(VenueScheduleDragBlockRequested(
      null == venueId
          ? _self.venueId
          : venueId // ignore: cast_nullable_to_non_nullable
              as String,
      null == startHour
          ? _self.startHour
          : startHour // ignore: cast_nullable_to_non_nullable
              as double,
      null == endHour
          ? _self.endHour
          : endHour // ignore: cast_nullable_to_non_nullable
              as double,
      weekday: freezed == weekday
          ? _self.weekday
          : weekday // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc

class VenueScheduleMonthDayTapped implements VenueScheduleEvent {
  const VenueScheduleMonthDayTapped(this.date);

  final DateTime date;

  /// Create a copy of VenueScheduleEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $VenueScheduleMonthDayTappedCopyWith<VenueScheduleMonthDayTapped>
      get copyWith => _$VenueScheduleMonthDayTappedCopyWithImpl<
          VenueScheduleMonthDayTapped>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is VenueScheduleMonthDayTapped &&
            (identical(other.date, date) || other.date == date));
  }

  @override
  int get hashCode => Object.hash(runtimeType, date);

  @override
  String toString() {
    return 'VenueScheduleEvent.monthDayTapped(date: $date)';
  }
}

/// @nodoc
abstract mixin class $VenueScheduleMonthDayTappedCopyWith<$Res>
    implements $VenueScheduleEventCopyWith<$Res> {
  factory $VenueScheduleMonthDayTappedCopyWith(
          VenueScheduleMonthDayTapped value,
          $Res Function(VenueScheduleMonthDayTapped) _then) =
      _$VenueScheduleMonthDayTappedCopyWithImpl;
  @useResult
  $Res call({DateTime date});
}

/// @nodoc
class _$VenueScheduleMonthDayTappedCopyWithImpl<$Res>
    implements $VenueScheduleMonthDayTappedCopyWith<$Res> {
  _$VenueScheduleMonthDayTappedCopyWithImpl(this._self, this._then);

  final VenueScheduleMonthDayTapped _self;
  final $Res Function(VenueScheduleMonthDayTapped) _then;

  /// Create a copy of VenueScheduleEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? date = null,
  }) {
    return _then(VenueScheduleMonthDayTapped(
      null == date
          ? _self.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc

class VenueScheduleCreateSlotSubmitted implements VenueScheduleEvent {
  const VenueScheduleCreateSlotSubmitted(this.request,
      {this.repeat = false,
      final List<int> weekdays = const <int>[],
      this.weeks = 4})
      : _weekdays = weekdays;

  final CreateSlotRequest request;
  @JsonKey()
  final bool repeat;
  final List<int> _weekdays;
  @JsonKey()
  List<int> get weekdays {
    if (_weekdays is EqualUnmodifiableListView) return _weekdays;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_weekdays);
  }

  @JsonKey()
  final int weeks;

  /// Create a copy of VenueScheduleEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $VenueScheduleCreateSlotSubmittedCopyWith<VenueScheduleCreateSlotSubmitted>
      get copyWith => _$VenueScheduleCreateSlotSubmittedCopyWithImpl<
          VenueScheduleCreateSlotSubmitted>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is VenueScheduleCreateSlotSubmitted &&
            (identical(other.request, request) || other.request == request) &&
            (identical(other.repeat, repeat) || other.repeat == repeat) &&
            const DeepCollectionEquality().equals(other._weekdays, _weekdays) &&
            (identical(other.weeks, weeks) || other.weeks == weeks));
  }

  @override
  int get hashCode => Object.hash(runtimeType, request, repeat,
      const DeepCollectionEquality().hash(_weekdays), weeks);

  @override
  String toString() {
    return 'VenueScheduleEvent.createSlotSubmitted(request: $request, repeat: $repeat, weekdays: $weekdays, weeks: $weeks)';
  }
}

/// @nodoc
abstract mixin class $VenueScheduleCreateSlotSubmittedCopyWith<$Res>
    implements $VenueScheduleEventCopyWith<$Res> {
  factory $VenueScheduleCreateSlotSubmittedCopyWith(
          VenueScheduleCreateSlotSubmitted value,
          $Res Function(VenueScheduleCreateSlotSubmitted) _then) =
      _$VenueScheduleCreateSlotSubmittedCopyWithImpl;
  @useResult
  $Res call(
      {CreateSlotRequest request, bool repeat, List<int> weekdays, int weeks});

  $CreateSlotRequestCopyWith<$Res> get request;
}

/// @nodoc
class _$VenueScheduleCreateSlotSubmittedCopyWithImpl<$Res>
    implements $VenueScheduleCreateSlotSubmittedCopyWith<$Res> {
  _$VenueScheduleCreateSlotSubmittedCopyWithImpl(this._self, this._then);

  final VenueScheduleCreateSlotSubmitted _self;
  final $Res Function(VenueScheduleCreateSlotSubmitted) _then;

  /// Create a copy of VenueScheduleEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? request = null,
    Object? repeat = null,
    Object? weekdays = null,
    Object? weeks = null,
  }) {
    return _then(VenueScheduleCreateSlotSubmitted(
      null == request
          ? _self.request
          : request // ignore: cast_nullable_to_non_nullable
              as CreateSlotRequest,
      repeat: null == repeat
          ? _self.repeat
          : repeat // ignore: cast_nullable_to_non_nullable
              as bool,
      weekdays: null == weekdays
          ? _self._weekdays
          : weekdays // ignore: cast_nullable_to_non_nullable
              as List<int>,
      weeks: null == weeks
          ? _self.weeks
          : weeks // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }

  /// Create a copy of VenueScheduleEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CreateSlotRequestCopyWith<$Res> get request {
    return $CreateSlotRequestCopyWith<$Res>(_self.request, (value) {
      return _then(_self.copyWith(request: value));
    });
  }
}

/// @nodoc

class VenueScheduleBlockSubmitted implements VenueScheduleEvent {
  const VenueScheduleBlockSubmitted(this.request,
      {this.repeat = false,
      final List<int> weekdays = const <int>[],
      this.weeks = 4})
      : _weekdays = weekdays;

  final BlockTimeRequest request;
  @JsonKey()
  final bool repeat;
  final List<int> _weekdays;
  @JsonKey()
  List<int> get weekdays {
    if (_weekdays is EqualUnmodifiableListView) return _weekdays;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_weekdays);
  }

  @JsonKey()
  final int weeks;

  /// Create a copy of VenueScheduleEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $VenueScheduleBlockSubmittedCopyWith<VenueScheduleBlockSubmitted>
      get copyWith => _$VenueScheduleBlockSubmittedCopyWithImpl<
          VenueScheduleBlockSubmitted>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is VenueScheduleBlockSubmitted &&
            (identical(other.request, request) || other.request == request) &&
            (identical(other.repeat, repeat) || other.repeat == repeat) &&
            const DeepCollectionEquality().equals(other._weekdays, _weekdays) &&
            (identical(other.weeks, weeks) || other.weeks == weeks));
  }

  @override
  int get hashCode => Object.hash(runtimeType, request, repeat,
      const DeepCollectionEquality().hash(_weekdays), weeks);

  @override
  String toString() {
    return 'VenueScheduleEvent.blockSubmitted(request: $request, repeat: $repeat, weekdays: $weekdays, weeks: $weeks)';
  }
}

/// @nodoc
abstract mixin class $VenueScheduleBlockSubmittedCopyWith<$Res>
    implements $VenueScheduleEventCopyWith<$Res> {
  factory $VenueScheduleBlockSubmittedCopyWith(
          VenueScheduleBlockSubmitted value,
          $Res Function(VenueScheduleBlockSubmitted) _then) =
      _$VenueScheduleBlockSubmittedCopyWithImpl;
  @useResult
  $Res call(
      {BlockTimeRequest request, bool repeat, List<int> weekdays, int weeks});

  $BlockTimeRequestCopyWith<$Res> get request;
}

/// @nodoc
class _$VenueScheduleBlockSubmittedCopyWithImpl<$Res>
    implements $VenueScheduleBlockSubmittedCopyWith<$Res> {
  _$VenueScheduleBlockSubmittedCopyWithImpl(this._self, this._then);

  final VenueScheduleBlockSubmitted _self;
  final $Res Function(VenueScheduleBlockSubmitted) _then;

  /// Create a copy of VenueScheduleEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? request = null,
    Object? repeat = null,
    Object? weekdays = null,
    Object? weeks = null,
  }) {
    return _then(VenueScheduleBlockSubmitted(
      null == request
          ? _self.request
          : request // ignore: cast_nullable_to_non_nullable
              as BlockTimeRequest,
      repeat: null == repeat
          ? _self.repeat
          : repeat // ignore: cast_nullable_to_non_nullable
              as bool,
      weekdays: null == weekdays
          ? _self._weekdays
          : weekdays // ignore: cast_nullable_to_non_nullable
              as List<int>,
      weeks: null == weeks
          ? _self.weeks
          : weeks // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }

  /// Create a copy of VenueScheduleEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BlockTimeRequestCopyWith<$Res> get request {
    return $BlockTimeRequestCopyWith<$Res>(_self.request, (value) {
      return _then(_self.copyWith(request: value));
    });
  }
}

/// @nodoc

class VenueScheduleApproveRequested implements VenueScheduleEvent {
  const VenueScheduleApproveRequested(this.slotId);

  final String slotId;

  /// Create a copy of VenueScheduleEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $VenueScheduleApproveRequestedCopyWith<VenueScheduleApproveRequested>
      get copyWith => _$VenueScheduleApproveRequestedCopyWithImpl<
          VenueScheduleApproveRequested>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is VenueScheduleApproveRequested &&
            (identical(other.slotId, slotId) || other.slotId == slotId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, slotId);

  @override
  String toString() {
    return 'VenueScheduleEvent.approveRequested(slotId: $slotId)';
  }
}

/// @nodoc
abstract mixin class $VenueScheduleApproveRequestedCopyWith<$Res>
    implements $VenueScheduleEventCopyWith<$Res> {
  factory $VenueScheduleApproveRequestedCopyWith(
          VenueScheduleApproveRequested value,
          $Res Function(VenueScheduleApproveRequested) _then) =
      _$VenueScheduleApproveRequestedCopyWithImpl;
  @useResult
  $Res call({String slotId});
}

/// @nodoc
class _$VenueScheduleApproveRequestedCopyWithImpl<$Res>
    implements $VenueScheduleApproveRequestedCopyWith<$Res> {
  _$VenueScheduleApproveRequestedCopyWithImpl(this._self, this._then);

  final VenueScheduleApproveRequested _self;
  final $Res Function(VenueScheduleApproveRequested) _then;

  /// Create a copy of VenueScheduleEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? slotId = null,
  }) {
    return _then(VenueScheduleApproveRequested(
      null == slotId
          ? _self.slotId
          : slotId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class VenueScheduleRejectRequested implements VenueScheduleEvent {
  const VenueScheduleRejectRequested(this.slotId);

  final String slotId;

  /// Create a copy of VenueScheduleEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $VenueScheduleRejectRequestedCopyWith<VenueScheduleRejectRequested>
      get copyWith => _$VenueScheduleRejectRequestedCopyWithImpl<
          VenueScheduleRejectRequested>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is VenueScheduleRejectRequested &&
            (identical(other.slotId, slotId) || other.slotId == slotId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, slotId);

  @override
  String toString() {
    return 'VenueScheduleEvent.rejectRequested(slotId: $slotId)';
  }
}

/// @nodoc
abstract mixin class $VenueScheduleRejectRequestedCopyWith<$Res>
    implements $VenueScheduleEventCopyWith<$Res> {
  factory $VenueScheduleRejectRequestedCopyWith(
          VenueScheduleRejectRequested value,
          $Res Function(VenueScheduleRejectRequested) _then) =
      _$VenueScheduleRejectRequestedCopyWithImpl;
  @useResult
  $Res call({String slotId});
}

/// @nodoc
class _$VenueScheduleRejectRequestedCopyWithImpl<$Res>
    implements $VenueScheduleRejectRequestedCopyWith<$Res> {
  _$VenueScheduleRejectRequestedCopyWithImpl(this._self, this._then);

  final VenueScheduleRejectRequested _self;
  final $Res Function(VenueScheduleRejectRequested) _then;

  /// Create a copy of VenueScheduleEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? slotId = null,
  }) {
    return _then(VenueScheduleRejectRequested(
      null == slotId
          ? _self.slotId
          : slotId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class VenueScheduleCancelRequested implements VenueScheduleEvent {
  const VenueScheduleCancelRequested(this.slotId);

  final String slotId;

  /// Create a copy of VenueScheduleEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $VenueScheduleCancelRequestedCopyWith<VenueScheduleCancelRequested>
      get copyWith => _$VenueScheduleCancelRequestedCopyWithImpl<
          VenueScheduleCancelRequested>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is VenueScheduleCancelRequested &&
            (identical(other.slotId, slotId) || other.slotId == slotId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, slotId);

  @override
  String toString() {
    return 'VenueScheduleEvent.cancelRequested(slotId: $slotId)';
  }
}

/// @nodoc
abstract mixin class $VenueScheduleCancelRequestedCopyWith<$Res>
    implements $VenueScheduleEventCopyWith<$Res> {
  factory $VenueScheduleCancelRequestedCopyWith(
          VenueScheduleCancelRequested value,
          $Res Function(VenueScheduleCancelRequested) _then) =
      _$VenueScheduleCancelRequestedCopyWithImpl;
  @useResult
  $Res call({String slotId});
}

/// @nodoc
class _$VenueScheduleCancelRequestedCopyWithImpl<$Res>
    implements $VenueScheduleCancelRequestedCopyWith<$Res> {
  _$VenueScheduleCancelRequestedCopyWithImpl(this._self, this._then);

  final VenueScheduleCancelRequested _self;
  final $Res Function(VenueScheduleCancelRequested) _then;

  /// Create a copy of VenueScheduleEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? slotId = null,
  }) {
    return _then(VenueScheduleCancelRequested(
      null == slotId
          ? _self.slotId
          : slotId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class VenueScheduleToastCleared implements VenueScheduleEvent {
  const VenueScheduleToastCleared();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is VenueScheduleToastCleared);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'VenueScheduleEvent.toastCleared()';
  }
}

/// @nodoc

class VenueScheduleSheetClosed implements VenueScheduleEvent {
  const VenueScheduleSheetClosed();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is VenueScheduleSheetClosed);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'VenueScheduleEvent.sheetClosed()';
  }
}

// dart format on
