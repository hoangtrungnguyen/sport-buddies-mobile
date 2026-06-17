// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HomeState {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is HomeState);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'HomeState()';
  }
}

/// @nodoc
class $HomeStateCopyWith<$Res> {
  $HomeStateCopyWith(HomeState _, $Res Function(HomeState) __);
}

/// Adds pattern-matching-related methods to [HomeState].
extension HomeStatePatterns on HomeState {
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
    TResult Function(HomeInitial value)? initial,
    TResult Function(HomeLoading value)? loading,
    TResult Function(HomeLoaded value)? loaded,
    TResult Function(HomeFailure value)? failure,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case HomeInitial() when initial != null:
        return initial(_that);
      case HomeLoading() when loading != null:
        return loading(_that);
      case HomeLoaded() when loaded != null:
        return loaded(_that);
      case HomeFailure() when failure != null:
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
    required TResult Function(HomeInitial value) initial,
    required TResult Function(HomeLoading value) loading,
    required TResult Function(HomeLoaded value) loaded,
    required TResult Function(HomeFailure value) failure,
  }) {
    final _that = this;
    switch (_that) {
      case HomeInitial():
        return initial(_that);
      case HomeLoading():
        return loading(_that);
      case HomeLoaded():
        return loaded(_that);
      case HomeFailure():
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
    TResult? Function(HomeInitial value)? initial,
    TResult? Function(HomeLoading value)? loading,
    TResult? Function(HomeLoaded value)? loaded,
    TResult? Function(HomeFailure value)? failure,
  }) {
    final _that = this;
    switch (_that) {
      case HomeInitial() when initial != null:
        return initial(_that);
      case HomeLoading() when loading != null:
        return loading(_that);
      case HomeLoaded() when loaded != null:
        return loaded(_that);
      case HomeFailure() when failure != null:
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
    TResult Function(
            HomeSummary summary,
            List<HomeKpi> kpis,
            List<PendingRequest> requests,
            int requestsTotal,
            List<UpcomingSession> upcoming,
            List<RevenueDay> weeklyRevenue,
            List<CourtStatusRow> courtStatus)?
        loaded,
    TResult Function(String message)? failure,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case HomeInitial() when initial != null:
        return initial();
      case HomeLoading() when loading != null:
        return loading();
      case HomeLoaded() when loaded != null:
        return loaded(
            _that.summary,
            _that.kpis,
            _that.requests,
            _that.requestsTotal,
            _that.upcoming,
            _that.weeklyRevenue,
            _that.courtStatus);
      case HomeFailure() when failure != null:
        return failure(_that.message);
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
            HomeSummary summary,
            List<HomeKpi> kpis,
            List<PendingRequest> requests,
            int requestsTotal,
            List<UpcomingSession> upcoming,
            List<RevenueDay> weeklyRevenue,
            List<CourtStatusRow> courtStatus)
        loaded,
    required TResult Function(String message) failure,
  }) {
    final _that = this;
    switch (_that) {
      case HomeInitial():
        return initial();
      case HomeLoading():
        return loading();
      case HomeLoaded():
        return loaded(
            _that.summary,
            _that.kpis,
            _that.requests,
            _that.requestsTotal,
            _that.upcoming,
            _that.weeklyRevenue,
            _that.courtStatus);
      case HomeFailure():
        return failure(_that.message);
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
    TResult? Function(
            HomeSummary summary,
            List<HomeKpi> kpis,
            List<PendingRequest> requests,
            int requestsTotal,
            List<UpcomingSession> upcoming,
            List<RevenueDay> weeklyRevenue,
            List<CourtStatusRow> courtStatus)?
        loaded,
    TResult? Function(String message)? failure,
  }) {
    final _that = this;
    switch (_that) {
      case HomeInitial() when initial != null:
        return initial();
      case HomeLoading() when loading != null:
        return loading();
      case HomeLoaded() when loaded != null:
        return loaded(
            _that.summary,
            _that.kpis,
            _that.requests,
            _that.requestsTotal,
            _that.upcoming,
            _that.weeklyRevenue,
            _that.courtStatus);
      case HomeFailure() when failure != null:
        return failure(_that.message);
      case _:
        return null;
    }
  }
}

/// @nodoc

class HomeInitial implements HomeState {
  const HomeInitial();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is HomeInitial);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'HomeState.initial()';
  }
}

/// @nodoc

class HomeLoading implements HomeState {
  const HomeLoading();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is HomeLoading);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'HomeState.loading()';
  }
}

/// @nodoc

class HomeLoaded implements HomeState {
  const HomeLoaded(
      {required this.summary,
      required final List<HomeKpi> kpis,
      required final List<PendingRequest> requests,
      required this.requestsTotal,
      required final List<UpcomingSession> upcoming,
      required final List<RevenueDay> weeklyRevenue,
      required final List<CourtStatusRow> courtStatus})
      : _kpis = kpis,
        _requests = requests,
        _upcoming = upcoming,
        _weeklyRevenue = weeklyRevenue,
        _courtStatus = courtStatus;

  final HomeSummary summary;
  final List<HomeKpi> _kpis;
  List<HomeKpi> get kpis {
    if (_kpis is EqualUnmodifiableListView) return _kpis;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_kpis);
  }

  final List<PendingRequest> _requests;
  List<PendingRequest> get requests {
    if (_requests is EqualUnmodifiableListView) return _requests;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_requests);
  }

  final int requestsTotal;
  final List<UpcomingSession> _upcoming;
  List<UpcomingSession> get upcoming {
    if (_upcoming is EqualUnmodifiableListView) return _upcoming;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_upcoming);
  }

  final List<RevenueDay> _weeklyRevenue;
  List<RevenueDay> get weeklyRevenue {
    if (_weeklyRevenue is EqualUnmodifiableListView) return _weeklyRevenue;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_weeklyRevenue);
  }

  final List<CourtStatusRow> _courtStatus;
  List<CourtStatusRow> get courtStatus {
    if (_courtStatus is EqualUnmodifiableListView) return _courtStatus;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_courtStatus);
  }

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $HomeLoadedCopyWith<HomeLoaded> get copyWith =>
      _$HomeLoadedCopyWithImpl<HomeLoaded>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is HomeLoaded &&
            (identical(other.summary, summary) || other.summary == summary) &&
            const DeepCollectionEquality().equals(other._kpis, _kpis) &&
            const DeepCollectionEquality().equals(other._requests, _requests) &&
            (identical(other.requestsTotal, requestsTotal) ||
                other.requestsTotal == requestsTotal) &&
            const DeepCollectionEquality().equals(other._upcoming, _upcoming) &&
            const DeepCollectionEquality()
                .equals(other._weeklyRevenue, _weeklyRevenue) &&
            const DeepCollectionEquality()
                .equals(other._courtStatus, _courtStatus));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      summary,
      const DeepCollectionEquality().hash(_kpis),
      const DeepCollectionEquality().hash(_requests),
      requestsTotal,
      const DeepCollectionEquality().hash(_upcoming),
      const DeepCollectionEquality().hash(_weeklyRevenue),
      const DeepCollectionEquality().hash(_courtStatus));

  @override
  String toString() {
    return 'HomeState.loaded(summary: $summary, kpis: $kpis, requests: $requests, requestsTotal: $requestsTotal, upcoming: $upcoming, weeklyRevenue: $weeklyRevenue, courtStatus: $courtStatus)';
  }
}

/// @nodoc
abstract mixin class $HomeLoadedCopyWith<$Res>
    implements $HomeStateCopyWith<$Res> {
  factory $HomeLoadedCopyWith(
          HomeLoaded value, $Res Function(HomeLoaded) _then) =
      _$HomeLoadedCopyWithImpl;
  @useResult
  $Res call(
      {HomeSummary summary,
      List<HomeKpi> kpis,
      List<PendingRequest> requests,
      int requestsTotal,
      List<UpcomingSession> upcoming,
      List<RevenueDay> weeklyRevenue,
      List<CourtStatusRow> courtStatus});

  $HomeSummaryCopyWith<$Res> get summary;
}

/// @nodoc
class _$HomeLoadedCopyWithImpl<$Res> implements $HomeLoadedCopyWith<$Res> {
  _$HomeLoadedCopyWithImpl(this._self, this._then);

  final HomeLoaded _self;
  final $Res Function(HomeLoaded) _then;

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? summary = null,
    Object? kpis = null,
    Object? requests = null,
    Object? requestsTotal = null,
    Object? upcoming = null,
    Object? weeklyRevenue = null,
    Object? courtStatus = null,
  }) {
    return _then(HomeLoaded(
      summary: null == summary
          ? _self.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as HomeSummary,
      kpis: null == kpis
          ? _self._kpis
          : kpis // ignore: cast_nullable_to_non_nullable
              as List<HomeKpi>,
      requests: null == requests
          ? _self._requests
          : requests // ignore: cast_nullable_to_non_nullable
              as List<PendingRequest>,
      requestsTotal: null == requestsTotal
          ? _self.requestsTotal
          : requestsTotal // ignore: cast_nullable_to_non_nullable
              as int,
      upcoming: null == upcoming
          ? _self._upcoming
          : upcoming // ignore: cast_nullable_to_non_nullable
              as List<UpcomingSession>,
      weeklyRevenue: null == weeklyRevenue
          ? _self._weeklyRevenue
          : weeklyRevenue // ignore: cast_nullable_to_non_nullable
              as List<RevenueDay>,
      courtStatus: null == courtStatus
          ? _self._courtStatus
          : courtStatus // ignore: cast_nullable_to_non_nullable
              as List<CourtStatusRow>,
    ));
  }

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $HomeSummaryCopyWith<$Res> get summary {
    return $HomeSummaryCopyWith<$Res>(_self.summary, (value) {
      return _then(_self.copyWith(summary: value));
    });
  }
}

/// @nodoc

class HomeFailure implements HomeState {
  const HomeFailure(this.message);

  final String message;

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $HomeFailureCopyWith<HomeFailure> get copyWith =>
      _$HomeFailureCopyWithImpl<HomeFailure>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is HomeFailure &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @override
  String toString() {
    return 'HomeState.failure(message: $message)';
  }
}

/// @nodoc
abstract mixin class $HomeFailureCopyWith<$Res>
    implements $HomeStateCopyWith<$Res> {
  factory $HomeFailureCopyWith(
          HomeFailure value, $Res Function(HomeFailure) _then) =
      _$HomeFailureCopyWithImpl;
  @useResult
  $Res call({String message});
}

/// @nodoc
class _$HomeFailureCopyWithImpl<$Res> implements $HomeFailureCopyWith<$Res> {
  _$HomeFailureCopyWithImpl(this._self, this._then);

  final HomeFailure _self;
  final $Res Function(HomeFailure) _then;

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = null,
  }) {
    return _then(HomeFailure(
      null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
