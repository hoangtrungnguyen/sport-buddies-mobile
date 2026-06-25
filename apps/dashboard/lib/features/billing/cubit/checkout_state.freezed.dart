// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'checkout_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CheckoutState {
  Invoice get invoice;
  List<PaymentMethod> get methods;
  PaymentMethodId get selected;
  bool get submitting;
  PaymentOutcome? get outcome;

  /// Create a copy of CheckoutState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CheckoutStateCopyWith<CheckoutState> get copyWith =>
      _$CheckoutStateCopyWithImpl<CheckoutState>(
          this as CheckoutState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CheckoutState &&
            (identical(other.invoice, invoice) || other.invoice == invoice) &&
            const DeepCollectionEquality().equals(other.methods, methods) &&
            (identical(other.selected, selected) ||
                other.selected == selected) &&
            (identical(other.submitting, submitting) ||
                other.submitting == submitting) &&
            (identical(other.outcome, outcome) || other.outcome == outcome));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      invoice,
      const DeepCollectionEquality().hash(methods),
      selected,
      submitting,
      outcome);

  @override
  String toString() {
    return 'CheckoutState(invoice: $invoice, methods: $methods, selected: $selected, submitting: $submitting, outcome: $outcome)';
  }
}

/// @nodoc
abstract mixin class $CheckoutStateCopyWith<$Res> {
  factory $CheckoutStateCopyWith(
          CheckoutState value, $Res Function(CheckoutState) _then) =
      _$CheckoutStateCopyWithImpl;
  @useResult
  $Res call(
      {Invoice invoice,
      List<PaymentMethod> methods,
      PaymentMethodId selected,
      bool submitting,
      PaymentOutcome? outcome});
}

/// @nodoc
class _$CheckoutStateCopyWithImpl<$Res>
    implements $CheckoutStateCopyWith<$Res> {
  _$CheckoutStateCopyWithImpl(this._self, this._then);

  final CheckoutState _self;
  final $Res Function(CheckoutState) _then;

  /// Create a copy of CheckoutState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? invoice = null,
    Object? methods = null,
    Object? selected = null,
    Object? submitting = null,
    Object? outcome = freezed,
  }) {
    return _then(_self.copyWith(
      invoice: null == invoice
          ? _self.invoice
          : invoice // ignore: cast_nullable_to_non_nullable
              as Invoice,
      methods: null == methods
          ? _self.methods
          : methods // ignore: cast_nullable_to_non_nullable
              as List<PaymentMethod>,
      selected: null == selected
          ? _self.selected
          : selected // ignore: cast_nullable_to_non_nullable
              as PaymentMethodId,
      submitting: null == submitting
          ? _self.submitting
          : submitting // ignore: cast_nullable_to_non_nullable
              as bool,
      outcome: freezed == outcome
          ? _self.outcome
          : outcome // ignore: cast_nullable_to_non_nullable
              as PaymentOutcome?,
    ));
  }
}

/// Adds pattern-matching-related methods to [CheckoutState].
extension CheckoutStatePatterns on CheckoutState {
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
    TResult Function(_CheckoutState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CheckoutState() when $default != null:
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
    TResult Function(_CheckoutState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CheckoutState():
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
    TResult? Function(_CheckoutState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CheckoutState() when $default != null:
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
    TResult Function(Invoice invoice, List<PaymentMethod> methods,
            PaymentMethodId selected, bool submitting, PaymentOutcome? outcome)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CheckoutState() when $default != null:
        return $default(_that.invoice, _that.methods, _that.selected,
            _that.submitting, _that.outcome);
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
    TResult Function(Invoice invoice, List<PaymentMethod> methods,
            PaymentMethodId selected, bool submitting, PaymentOutcome? outcome)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CheckoutState():
        return $default(_that.invoice, _that.methods, _that.selected,
            _that.submitting, _that.outcome);
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
    TResult? Function(Invoice invoice, List<PaymentMethod> methods,
            PaymentMethodId selected, bool submitting, PaymentOutcome? outcome)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CheckoutState() when $default != null:
        return $default(_that.invoice, _that.methods, _that.selected,
            _that.submitting, _that.outcome);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _CheckoutState extends CheckoutState {
  const _CheckoutState(
      {required this.invoice,
      required final List<PaymentMethod> methods,
      required this.selected,
      this.submitting = false,
      this.outcome})
      : _methods = methods,
        super._();

  @override
  final Invoice invoice;
  final List<PaymentMethod> _methods;
  @override
  List<PaymentMethod> get methods {
    if (_methods is EqualUnmodifiableListView) return _methods;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_methods);
  }

  @override
  final PaymentMethodId selected;
  @override
  @JsonKey()
  final bool submitting;
  @override
  final PaymentOutcome? outcome;

  /// Create a copy of CheckoutState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CheckoutStateCopyWith<_CheckoutState> get copyWith =>
      __$CheckoutStateCopyWithImpl<_CheckoutState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CheckoutState &&
            (identical(other.invoice, invoice) || other.invoice == invoice) &&
            const DeepCollectionEquality().equals(other._methods, _methods) &&
            (identical(other.selected, selected) ||
                other.selected == selected) &&
            (identical(other.submitting, submitting) ||
                other.submitting == submitting) &&
            (identical(other.outcome, outcome) || other.outcome == outcome));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      invoice,
      const DeepCollectionEquality().hash(_methods),
      selected,
      submitting,
      outcome);

  @override
  String toString() {
    return 'CheckoutState(invoice: $invoice, methods: $methods, selected: $selected, submitting: $submitting, outcome: $outcome)';
  }
}

/// @nodoc
abstract mixin class _$CheckoutStateCopyWith<$Res>
    implements $CheckoutStateCopyWith<$Res> {
  factory _$CheckoutStateCopyWith(
          _CheckoutState value, $Res Function(_CheckoutState) _then) =
      __$CheckoutStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {Invoice invoice,
      List<PaymentMethod> methods,
      PaymentMethodId selected,
      bool submitting,
      PaymentOutcome? outcome});
}

/// @nodoc
class __$CheckoutStateCopyWithImpl<$Res>
    implements _$CheckoutStateCopyWith<$Res> {
  __$CheckoutStateCopyWithImpl(this._self, this._then);

  final _CheckoutState _self;
  final $Res Function(_CheckoutState) _then;

  /// Create a copy of CheckoutState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? invoice = null,
    Object? methods = null,
    Object? selected = null,
    Object? submitting = null,
    Object? outcome = freezed,
  }) {
    return _then(_CheckoutState(
      invoice: null == invoice
          ? _self.invoice
          : invoice // ignore: cast_nullable_to_non_nullable
              as Invoice,
      methods: null == methods
          ? _self._methods
          : methods // ignore: cast_nullable_to_non_nullable
              as List<PaymentMethod>,
      selected: null == selected
          ? _self.selected
          : selected // ignore: cast_nullable_to_non_nullable
              as PaymentMethodId,
      submitting: null == submitting
          ? _self.submitting
          : submitting // ignore: cast_nullable_to_non_nullable
              as bool,
      outcome: freezed == outcome
          ? _self.outcome
          : outcome // ignore: cast_nullable_to_non_nullable
              as PaymentOutcome?,
    ));
  }
}

// dart format on
