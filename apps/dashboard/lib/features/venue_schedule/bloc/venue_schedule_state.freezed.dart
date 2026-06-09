// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'venue_schedule_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VenueScheduleState {
  ScheduleView get view;
  List<Venue> get venues;

  /// Week-view venue. Set to the first venue on load.
  String? get selectedVenueId;

  /// The day the views centre on (date-only, local). Day view shows this
  /// day; Week view its Monday-based week; Month view its month.
  DateTime get focusedDate;

  /// "MÔN" multi-select; empty ⇒ all sports.
  Set<SportType> get sportFilter;

  /// "TRẠNG THÁI" multi-select; empty ⇒ all states.
  Set<SlotState> get stateFilter;

  /// All venues' slots for [focusedDate] (Day view).
  List<Slot> get daySlots;

  /// Selected venue's slots for the week of [focusedDate] (Week view).
  List<Slot> get weekSlots;

  /// Heatmap cells for the month of [focusedDate], full weeks.
  List<OccupancyDay> get monthCells;
  VenueScheduleStatus get status;

  /// Transient success message — cleared via `toastCleared` after 3500ms.
  String? get toast;
  VenueScheduleSheet get activeSheet;

  /// Payload when [activeSheet] is [VenueScheduleSheet.detail].
  Slot? get detailSlot;

  /// Prefill when [activeSheet] is [VenueScheduleSheet.create].
  CreateSlotRequest? get createPrefill;

  /// Prefill when [activeSheet] is [VenueScheduleSheet.block].
  BlockTimeRequest? get blockPrefill;

  /// Create a copy of VenueScheduleState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $VenueScheduleStateCopyWith<VenueScheduleState> get copyWith =>
      _$VenueScheduleStateCopyWithImpl<VenueScheduleState>(
          this as VenueScheduleState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is VenueScheduleState &&
            (identical(other.view, view) || other.view == view) &&
            const DeepCollectionEquality().equals(other.venues, venues) &&
            (identical(other.selectedVenueId, selectedVenueId) ||
                other.selectedVenueId == selectedVenueId) &&
            (identical(other.focusedDate, focusedDate) ||
                other.focusedDate == focusedDate) &&
            const DeepCollectionEquality()
                .equals(other.sportFilter, sportFilter) &&
            const DeepCollectionEquality()
                .equals(other.stateFilter, stateFilter) &&
            const DeepCollectionEquality().equals(other.daySlots, daySlots) &&
            const DeepCollectionEquality().equals(other.weekSlots, weekSlots) &&
            const DeepCollectionEquality()
                .equals(other.monthCells, monthCells) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.toast, toast) || other.toast == toast) &&
            (identical(other.activeSheet, activeSheet) ||
                other.activeSheet == activeSheet) &&
            (identical(other.detailSlot, detailSlot) ||
                other.detailSlot == detailSlot) &&
            (identical(other.createPrefill, createPrefill) ||
                other.createPrefill == createPrefill) &&
            (identical(other.blockPrefill, blockPrefill) ||
                other.blockPrefill == blockPrefill));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      view,
      const DeepCollectionEquality().hash(venues),
      selectedVenueId,
      focusedDate,
      const DeepCollectionEquality().hash(sportFilter),
      const DeepCollectionEquality().hash(stateFilter),
      const DeepCollectionEquality().hash(daySlots),
      const DeepCollectionEquality().hash(weekSlots),
      const DeepCollectionEquality().hash(monthCells),
      status,
      toast,
      activeSheet,
      detailSlot,
      createPrefill,
      blockPrefill);

  @override
  String toString() {
    return 'VenueScheduleState(view: $view, venues: $venues, selectedVenueId: $selectedVenueId, focusedDate: $focusedDate, sportFilter: $sportFilter, stateFilter: $stateFilter, daySlots: $daySlots, weekSlots: $weekSlots, monthCells: $monthCells, status: $status, toast: $toast, activeSheet: $activeSheet, detailSlot: $detailSlot, createPrefill: $createPrefill, blockPrefill: $blockPrefill)';
  }
}

/// @nodoc
abstract mixin class $VenueScheduleStateCopyWith<$Res> {
  factory $VenueScheduleStateCopyWith(
          VenueScheduleState value, $Res Function(VenueScheduleState) _then) =
      _$VenueScheduleStateCopyWithImpl;
  @useResult
  $Res call(
      {ScheduleView view,
      List<Venue> venues,
      String? selectedVenueId,
      DateTime focusedDate,
      Set<SportType> sportFilter,
      Set<SlotState> stateFilter,
      List<Slot> daySlots,
      List<Slot> weekSlots,
      List<OccupancyDay> monthCells,
      VenueScheduleStatus status,
      String? toast,
      VenueScheduleSheet activeSheet,
      Slot? detailSlot,
      CreateSlotRequest? createPrefill,
      BlockTimeRequest? blockPrefill});

  $SlotCopyWith<$Res>? get detailSlot;
  $CreateSlotRequestCopyWith<$Res>? get createPrefill;
  $BlockTimeRequestCopyWith<$Res>? get blockPrefill;
}

/// @nodoc
class _$VenueScheduleStateCopyWithImpl<$Res>
    implements $VenueScheduleStateCopyWith<$Res> {
  _$VenueScheduleStateCopyWithImpl(this._self, this._then);

  final VenueScheduleState _self;
  final $Res Function(VenueScheduleState) _then;

  /// Create a copy of VenueScheduleState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? view = null,
    Object? venues = null,
    Object? selectedVenueId = freezed,
    Object? focusedDate = null,
    Object? sportFilter = null,
    Object? stateFilter = null,
    Object? daySlots = null,
    Object? weekSlots = null,
    Object? monthCells = null,
    Object? status = null,
    Object? toast = freezed,
    Object? activeSheet = null,
    Object? detailSlot = freezed,
    Object? createPrefill = freezed,
    Object? blockPrefill = freezed,
  }) {
    return _then(_self.copyWith(
      view: null == view
          ? _self.view
          : view // ignore: cast_nullable_to_non_nullable
              as ScheduleView,
      venues: null == venues
          ? _self.venues
          : venues // ignore: cast_nullable_to_non_nullable
              as List<Venue>,
      selectedVenueId: freezed == selectedVenueId
          ? _self.selectedVenueId
          : selectedVenueId // ignore: cast_nullable_to_non_nullable
              as String?,
      focusedDate: null == focusedDate
          ? _self.focusedDate
          : focusedDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      sportFilter: null == sportFilter
          ? _self.sportFilter
          : sportFilter // ignore: cast_nullable_to_non_nullable
              as Set<SportType>,
      stateFilter: null == stateFilter
          ? _self.stateFilter
          : stateFilter // ignore: cast_nullable_to_non_nullable
              as Set<SlotState>,
      daySlots: null == daySlots
          ? _self.daySlots
          : daySlots // ignore: cast_nullable_to_non_nullable
              as List<Slot>,
      weekSlots: null == weekSlots
          ? _self.weekSlots
          : weekSlots // ignore: cast_nullable_to_non_nullable
              as List<Slot>,
      monthCells: null == monthCells
          ? _self.monthCells
          : monthCells // ignore: cast_nullable_to_non_nullable
              as List<OccupancyDay>,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as VenueScheduleStatus,
      toast: freezed == toast
          ? _self.toast
          : toast // ignore: cast_nullable_to_non_nullable
              as String?,
      activeSheet: null == activeSheet
          ? _self.activeSheet
          : activeSheet // ignore: cast_nullable_to_non_nullable
              as VenueScheduleSheet,
      detailSlot: freezed == detailSlot
          ? _self.detailSlot
          : detailSlot // ignore: cast_nullable_to_non_nullable
              as Slot?,
      createPrefill: freezed == createPrefill
          ? _self.createPrefill
          : createPrefill // ignore: cast_nullable_to_non_nullable
              as CreateSlotRequest?,
      blockPrefill: freezed == blockPrefill
          ? _self.blockPrefill
          : blockPrefill // ignore: cast_nullable_to_non_nullable
              as BlockTimeRequest?,
    ));
  }

  /// Create a copy of VenueScheduleState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SlotCopyWith<$Res>? get detailSlot {
    if (_self.detailSlot == null) {
      return null;
    }

    return $SlotCopyWith<$Res>(_self.detailSlot!, (value) {
      return _then(_self.copyWith(detailSlot: value));
    });
  }

  /// Create a copy of VenueScheduleState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CreateSlotRequestCopyWith<$Res>? get createPrefill {
    if (_self.createPrefill == null) {
      return null;
    }

    return $CreateSlotRequestCopyWith<$Res>(_self.createPrefill!, (value) {
      return _then(_self.copyWith(createPrefill: value));
    });
  }

  /// Create a copy of VenueScheduleState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BlockTimeRequestCopyWith<$Res>? get blockPrefill {
    if (_self.blockPrefill == null) {
      return null;
    }

    return $BlockTimeRequestCopyWith<$Res>(_self.blockPrefill!, (value) {
      return _then(_self.copyWith(blockPrefill: value));
    });
  }
}

/// Adds pattern-matching-related methods to [VenueScheduleState].
extension VenueScheduleStatePatterns on VenueScheduleState {
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
    TResult Function(_VenueScheduleState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _VenueScheduleState() when $default != null:
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
    TResult Function(_VenueScheduleState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _VenueScheduleState():
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
    TResult? Function(_VenueScheduleState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _VenueScheduleState() when $default != null:
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
    TResult Function(
            ScheduleView view,
            List<Venue> venues,
            String? selectedVenueId,
            DateTime focusedDate,
            Set<SportType> sportFilter,
            Set<SlotState> stateFilter,
            List<Slot> daySlots,
            List<Slot> weekSlots,
            List<OccupancyDay> monthCells,
            VenueScheduleStatus status,
            String? toast,
            VenueScheduleSheet activeSheet,
            Slot? detailSlot,
            CreateSlotRequest? createPrefill,
            BlockTimeRequest? blockPrefill)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _VenueScheduleState() when $default != null:
        return $default(
            _that.view,
            _that.venues,
            _that.selectedVenueId,
            _that.focusedDate,
            _that.sportFilter,
            _that.stateFilter,
            _that.daySlots,
            _that.weekSlots,
            _that.monthCells,
            _that.status,
            _that.toast,
            _that.activeSheet,
            _that.detailSlot,
            _that.createPrefill,
            _that.blockPrefill);
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
    TResult Function(
            ScheduleView view,
            List<Venue> venues,
            String? selectedVenueId,
            DateTime focusedDate,
            Set<SportType> sportFilter,
            Set<SlotState> stateFilter,
            List<Slot> daySlots,
            List<Slot> weekSlots,
            List<OccupancyDay> monthCells,
            VenueScheduleStatus status,
            String? toast,
            VenueScheduleSheet activeSheet,
            Slot? detailSlot,
            CreateSlotRequest? createPrefill,
            BlockTimeRequest? blockPrefill)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _VenueScheduleState():
        return $default(
            _that.view,
            _that.venues,
            _that.selectedVenueId,
            _that.focusedDate,
            _that.sportFilter,
            _that.stateFilter,
            _that.daySlots,
            _that.weekSlots,
            _that.monthCells,
            _that.status,
            _that.toast,
            _that.activeSheet,
            _that.detailSlot,
            _that.createPrefill,
            _that.blockPrefill);
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
    TResult? Function(
            ScheduleView view,
            List<Venue> venues,
            String? selectedVenueId,
            DateTime focusedDate,
            Set<SportType> sportFilter,
            Set<SlotState> stateFilter,
            List<Slot> daySlots,
            List<Slot> weekSlots,
            List<OccupancyDay> monthCells,
            VenueScheduleStatus status,
            String? toast,
            VenueScheduleSheet activeSheet,
            Slot? detailSlot,
            CreateSlotRequest? createPrefill,
            BlockTimeRequest? blockPrefill)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _VenueScheduleState() when $default != null:
        return $default(
            _that.view,
            _that.venues,
            _that.selectedVenueId,
            _that.focusedDate,
            _that.sportFilter,
            _that.stateFilter,
            _that.daySlots,
            _that.weekSlots,
            _that.monthCells,
            _that.status,
            _that.toast,
            _that.activeSheet,
            _that.detailSlot,
            _that.createPrefill,
            _that.blockPrefill);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _VenueScheduleState extends VenueScheduleState {
  const _VenueScheduleState(
      {this.view = ScheduleView.day,
      final List<Venue> venues = const <Venue>[],
      this.selectedVenueId,
      required this.focusedDate,
      final Set<SportType> sportFilter = const <SportType>{},
      final Set<SlotState> stateFilter = const <SlotState>{},
      final List<Slot> daySlots = const <Slot>[],
      final List<Slot> weekSlots = const <Slot>[],
      final List<OccupancyDay> monthCells = const <OccupancyDay>[],
      this.status = VenueScheduleStatus.loading,
      this.toast,
      this.activeSheet = VenueScheduleSheet.none,
      this.detailSlot,
      this.createPrefill,
      this.blockPrefill})
      : _venues = venues,
        _sportFilter = sportFilter,
        _stateFilter = stateFilter,
        _daySlots = daySlots,
        _weekSlots = weekSlots,
        _monthCells = monthCells,
        super._();

  @override
  @JsonKey()
  final ScheduleView view;
  final List<Venue> _venues;
  @override
  @JsonKey()
  List<Venue> get venues {
    if (_venues is EqualUnmodifiableListView) return _venues;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_venues);
  }

  /// Week-view venue. Set to the first venue on load.
  @override
  final String? selectedVenueId;

  /// The day the views centre on (date-only, local). Day view shows this
  /// day; Week view its Monday-based week; Month view its month.
  @override
  final DateTime focusedDate;

  /// "MÔN" multi-select; empty ⇒ all sports.
  final Set<SportType> _sportFilter;

  /// "MÔN" multi-select; empty ⇒ all sports.
  @override
  @JsonKey()
  Set<SportType> get sportFilter {
    if (_sportFilter is EqualUnmodifiableSetView) return _sportFilter;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_sportFilter);
  }

  /// "TRẠNG THÁI" multi-select; empty ⇒ all states.
  final Set<SlotState> _stateFilter;

  /// "TRẠNG THÁI" multi-select; empty ⇒ all states.
  @override
  @JsonKey()
  Set<SlotState> get stateFilter {
    if (_stateFilter is EqualUnmodifiableSetView) return _stateFilter;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_stateFilter);
  }

  /// All venues' slots for [focusedDate] (Day view).
  final List<Slot> _daySlots;

  /// All venues' slots for [focusedDate] (Day view).
  @override
  @JsonKey()
  List<Slot> get daySlots {
    if (_daySlots is EqualUnmodifiableListView) return _daySlots;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_daySlots);
  }

  /// Selected venue's slots for the week of [focusedDate] (Week view).
  final List<Slot> _weekSlots;

  /// Selected venue's slots for the week of [focusedDate] (Week view).
  @override
  @JsonKey()
  List<Slot> get weekSlots {
    if (_weekSlots is EqualUnmodifiableListView) return _weekSlots;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_weekSlots);
  }

  /// Heatmap cells for the month of [focusedDate], full weeks.
  final List<OccupancyDay> _monthCells;

  /// Heatmap cells for the month of [focusedDate], full weeks.
  @override
  @JsonKey()
  List<OccupancyDay> get monthCells {
    if (_monthCells is EqualUnmodifiableListView) return _monthCells;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_monthCells);
  }

  @override
  @JsonKey()
  final VenueScheduleStatus status;

  /// Transient success message — cleared via `toastCleared` after 3500ms.
  @override
  final String? toast;
  @override
  @JsonKey()
  final VenueScheduleSheet activeSheet;

  /// Payload when [activeSheet] is [VenueScheduleSheet.detail].
  @override
  final Slot? detailSlot;

  /// Prefill when [activeSheet] is [VenueScheduleSheet.create].
  @override
  final CreateSlotRequest? createPrefill;

  /// Prefill when [activeSheet] is [VenueScheduleSheet.block].
  @override
  final BlockTimeRequest? blockPrefill;

  /// Create a copy of VenueScheduleState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$VenueScheduleStateCopyWith<_VenueScheduleState> get copyWith =>
      __$VenueScheduleStateCopyWithImpl<_VenueScheduleState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _VenueScheduleState &&
            (identical(other.view, view) || other.view == view) &&
            const DeepCollectionEquality().equals(other._venues, _venues) &&
            (identical(other.selectedVenueId, selectedVenueId) ||
                other.selectedVenueId == selectedVenueId) &&
            (identical(other.focusedDate, focusedDate) ||
                other.focusedDate == focusedDate) &&
            const DeepCollectionEquality()
                .equals(other._sportFilter, _sportFilter) &&
            const DeepCollectionEquality()
                .equals(other._stateFilter, _stateFilter) &&
            const DeepCollectionEquality().equals(other._daySlots, _daySlots) &&
            const DeepCollectionEquality()
                .equals(other._weekSlots, _weekSlots) &&
            const DeepCollectionEquality()
                .equals(other._monthCells, _monthCells) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.toast, toast) || other.toast == toast) &&
            (identical(other.activeSheet, activeSheet) ||
                other.activeSheet == activeSheet) &&
            (identical(other.detailSlot, detailSlot) ||
                other.detailSlot == detailSlot) &&
            (identical(other.createPrefill, createPrefill) ||
                other.createPrefill == createPrefill) &&
            (identical(other.blockPrefill, blockPrefill) ||
                other.blockPrefill == blockPrefill));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      view,
      const DeepCollectionEquality().hash(_venues),
      selectedVenueId,
      focusedDate,
      const DeepCollectionEquality().hash(_sportFilter),
      const DeepCollectionEquality().hash(_stateFilter),
      const DeepCollectionEquality().hash(_daySlots),
      const DeepCollectionEquality().hash(_weekSlots),
      const DeepCollectionEquality().hash(_monthCells),
      status,
      toast,
      activeSheet,
      detailSlot,
      createPrefill,
      blockPrefill);

  @override
  String toString() {
    return 'VenueScheduleState(view: $view, venues: $venues, selectedVenueId: $selectedVenueId, focusedDate: $focusedDate, sportFilter: $sportFilter, stateFilter: $stateFilter, daySlots: $daySlots, weekSlots: $weekSlots, monthCells: $monthCells, status: $status, toast: $toast, activeSheet: $activeSheet, detailSlot: $detailSlot, createPrefill: $createPrefill, blockPrefill: $blockPrefill)';
  }
}

/// @nodoc
abstract mixin class _$VenueScheduleStateCopyWith<$Res>
    implements $VenueScheduleStateCopyWith<$Res> {
  factory _$VenueScheduleStateCopyWith(
          _VenueScheduleState value, $Res Function(_VenueScheduleState) _then) =
      __$VenueScheduleStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {ScheduleView view,
      List<Venue> venues,
      String? selectedVenueId,
      DateTime focusedDate,
      Set<SportType> sportFilter,
      Set<SlotState> stateFilter,
      List<Slot> daySlots,
      List<Slot> weekSlots,
      List<OccupancyDay> monthCells,
      VenueScheduleStatus status,
      String? toast,
      VenueScheduleSheet activeSheet,
      Slot? detailSlot,
      CreateSlotRequest? createPrefill,
      BlockTimeRequest? blockPrefill});

  @override
  $SlotCopyWith<$Res>? get detailSlot;
  @override
  $CreateSlotRequestCopyWith<$Res>? get createPrefill;
  @override
  $BlockTimeRequestCopyWith<$Res>? get blockPrefill;
}

/// @nodoc
class __$VenueScheduleStateCopyWithImpl<$Res>
    implements _$VenueScheduleStateCopyWith<$Res> {
  __$VenueScheduleStateCopyWithImpl(this._self, this._then);

  final _VenueScheduleState _self;
  final $Res Function(_VenueScheduleState) _then;

  /// Create a copy of VenueScheduleState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? view = null,
    Object? venues = null,
    Object? selectedVenueId = freezed,
    Object? focusedDate = null,
    Object? sportFilter = null,
    Object? stateFilter = null,
    Object? daySlots = null,
    Object? weekSlots = null,
    Object? monthCells = null,
    Object? status = null,
    Object? toast = freezed,
    Object? activeSheet = null,
    Object? detailSlot = freezed,
    Object? createPrefill = freezed,
    Object? blockPrefill = freezed,
  }) {
    return _then(_VenueScheduleState(
      view: null == view
          ? _self.view
          : view // ignore: cast_nullable_to_non_nullable
              as ScheduleView,
      venues: null == venues
          ? _self._venues
          : venues // ignore: cast_nullable_to_non_nullable
              as List<Venue>,
      selectedVenueId: freezed == selectedVenueId
          ? _self.selectedVenueId
          : selectedVenueId // ignore: cast_nullable_to_non_nullable
              as String?,
      focusedDate: null == focusedDate
          ? _self.focusedDate
          : focusedDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      sportFilter: null == sportFilter
          ? _self._sportFilter
          : sportFilter // ignore: cast_nullable_to_non_nullable
              as Set<SportType>,
      stateFilter: null == stateFilter
          ? _self._stateFilter
          : stateFilter // ignore: cast_nullable_to_non_nullable
              as Set<SlotState>,
      daySlots: null == daySlots
          ? _self._daySlots
          : daySlots // ignore: cast_nullable_to_non_nullable
              as List<Slot>,
      weekSlots: null == weekSlots
          ? _self._weekSlots
          : weekSlots // ignore: cast_nullable_to_non_nullable
              as List<Slot>,
      monthCells: null == monthCells
          ? _self._monthCells
          : monthCells // ignore: cast_nullable_to_non_nullable
              as List<OccupancyDay>,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as VenueScheduleStatus,
      toast: freezed == toast
          ? _self.toast
          : toast // ignore: cast_nullable_to_non_nullable
              as String?,
      activeSheet: null == activeSheet
          ? _self.activeSheet
          : activeSheet // ignore: cast_nullable_to_non_nullable
              as VenueScheduleSheet,
      detailSlot: freezed == detailSlot
          ? _self.detailSlot
          : detailSlot // ignore: cast_nullable_to_non_nullable
              as Slot?,
      createPrefill: freezed == createPrefill
          ? _self.createPrefill
          : createPrefill // ignore: cast_nullable_to_non_nullable
              as CreateSlotRequest?,
      blockPrefill: freezed == blockPrefill
          ? _self.blockPrefill
          : blockPrefill // ignore: cast_nullable_to_non_nullable
              as BlockTimeRequest?,
    ));
  }

  /// Create a copy of VenueScheduleState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SlotCopyWith<$Res>? get detailSlot {
    if (_self.detailSlot == null) {
      return null;
    }

    return $SlotCopyWith<$Res>(_self.detailSlot!, (value) {
      return _then(_self.copyWith(detailSlot: value));
    });
  }

  /// Create a copy of VenueScheduleState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CreateSlotRequestCopyWith<$Res>? get createPrefill {
    if (_self.createPrefill == null) {
      return null;
    }

    return $CreateSlotRequestCopyWith<$Res>(_self.createPrefill!, (value) {
      return _then(_self.copyWith(createPrefill: value));
    });
  }

  /// Create a copy of VenueScheduleState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BlockTimeRequestCopyWith<$Res>? get blockPrefill {
    if (_self.blockPrefill == null) {
      return null;
    }

    return $BlockTimeRequestCopyWith<$Res>(_self.blockPrefill!, (value) {
      return _then(_self.copyWith(blockPrefill: value));
    });
  }
}

// dart format on
