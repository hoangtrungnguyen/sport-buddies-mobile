// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OwnerProfile {
  String get id;
  String get name;
  String get initials;

  /// Public URL of the uploaded avatar; null → render [initials].
  String? get avatarUrl;
  String get role; // "Chủ sân"
  String get area; // "Quận 7, TP.HCM"
  DateTime get joinedAt;
  String get phone;
  String get email;
  String get address;
  bool get verified; // business
  String get bizName;
  String get taxCode;
  String get bizArea; // payout
  String get bankName;
  String get accountMasked;
  String get accountHolder;
  bool get payoutLinked; // subscription
  Subscription get plan; // security prefs
  bool get twoFactor;
  bool get emailNotif;
  DateTime? get passwordChangedAt;
  int get activeDevices;

  /// Create a copy of OwnerProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $OwnerProfileCopyWith<OwnerProfile> get copyWith =>
      _$OwnerProfileCopyWithImpl<OwnerProfile>(
          this as OwnerProfile, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is OwnerProfile &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.initials, initials) ||
                other.initials == initials) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.area, area) || other.area == area) &&
            (identical(other.joinedAt, joinedAt) ||
                other.joinedAt == joinedAt) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.verified, verified) ||
                other.verified == verified) &&
            (identical(other.bizName, bizName) || other.bizName == bizName) &&
            (identical(other.taxCode, taxCode) || other.taxCode == taxCode) &&
            (identical(other.bizArea, bizArea) || other.bizArea == bizArea) &&
            (identical(other.bankName, bankName) ||
                other.bankName == bankName) &&
            (identical(other.accountMasked, accountMasked) ||
                other.accountMasked == accountMasked) &&
            (identical(other.accountHolder, accountHolder) ||
                other.accountHolder == accountHolder) &&
            (identical(other.payoutLinked, payoutLinked) ||
                other.payoutLinked == payoutLinked) &&
            (identical(other.plan, plan) || other.plan == plan) &&
            (identical(other.twoFactor, twoFactor) ||
                other.twoFactor == twoFactor) &&
            (identical(other.emailNotif, emailNotif) ||
                other.emailNotif == emailNotif) &&
            (identical(other.passwordChangedAt, passwordChangedAt) ||
                other.passwordChangedAt == passwordChangedAt) &&
            (identical(other.activeDevices, activeDevices) ||
                other.activeDevices == activeDevices));
  }

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        name,
        initials,
        avatarUrl,
        role,
        area,
        joinedAt,
        phone,
        email,
        address,
        verified,
        bizName,
        taxCode,
        bizArea,
        bankName,
        accountMasked,
        accountHolder,
        payoutLinked,
        plan,
        twoFactor,
        emailNotif,
        passwordChangedAt,
        activeDevices
      ]);

  @override
  String toString() {
    return 'OwnerProfile(id: $id, name: $name, initials: $initials, avatarUrl: $avatarUrl, role: $role, area: $area, joinedAt: $joinedAt, phone: $phone, email: $email, address: $address, verified: $verified, bizName: $bizName, taxCode: $taxCode, bizArea: $bizArea, bankName: $bankName, accountMasked: $accountMasked, accountHolder: $accountHolder, payoutLinked: $payoutLinked, plan: $plan, twoFactor: $twoFactor, emailNotif: $emailNotif, passwordChangedAt: $passwordChangedAt, activeDevices: $activeDevices)';
  }
}

/// @nodoc
abstract mixin class $OwnerProfileCopyWith<$Res> {
  factory $OwnerProfileCopyWith(
          OwnerProfile value, $Res Function(OwnerProfile) _then) =
      _$OwnerProfileCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String name,
      String initials,
      String? avatarUrl,
      String role,
      String area,
      DateTime joinedAt,
      String phone,
      String email,
      String address,
      bool verified,
      String bizName,
      String taxCode,
      String bizArea,
      String bankName,
      String accountMasked,
      String accountHolder,
      bool payoutLinked,
      Subscription plan,
      bool twoFactor,
      bool emailNotif,
      DateTime? passwordChangedAt,
      int activeDevices});

  $SubscriptionCopyWith<$Res> get plan;
}

/// @nodoc
class _$OwnerProfileCopyWithImpl<$Res> implements $OwnerProfileCopyWith<$Res> {
  _$OwnerProfileCopyWithImpl(this._self, this._then);

  final OwnerProfile _self;
  final $Res Function(OwnerProfile) _then;

  /// Create a copy of OwnerProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? initials = null,
    Object? avatarUrl = freezed,
    Object? role = null,
    Object? area = null,
    Object? joinedAt = null,
    Object? phone = null,
    Object? email = null,
    Object? address = null,
    Object? verified = null,
    Object? bizName = null,
    Object? taxCode = null,
    Object? bizArea = null,
    Object? bankName = null,
    Object? accountMasked = null,
    Object? accountHolder = null,
    Object? payoutLinked = null,
    Object? plan = null,
    Object? twoFactor = null,
    Object? emailNotif = null,
    Object? passwordChangedAt = freezed,
    Object? activeDevices = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      initials: null == initials
          ? _self.initials
          : initials // ignore: cast_nullable_to_non_nullable
              as String,
      avatarUrl: freezed == avatarUrl
          ? _self.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      role: null == role
          ? _self.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      area: null == area
          ? _self.area
          : area // ignore: cast_nullable_to_non_nullable
              as String,
      joinedAt: null == joinedAt
          ? _self.joinedAt
          : joinedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      phone: null == phone
          ? _self.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _self.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      verified: null == verified
          ? _self.verified
          : verified // ignore: cast_nullable_to_non_nullable
              as bool,
      bizName: null == bizName
          ? _self.bizName
          : bizName // ignore: cast_nullable_to_non_nullable
              as String,
      taxCode: null == taxCode
          ? _self.taxCode
          : taxCode // ignore: cast_nullable_to_non_nullable
              as String,
      bizArea: null == bizArea
          ? _self.bizArea
          : bizArea // ignore: cast_nullable_to_non_nullable
              as String,
      bankName: null == bankName
          ? _self.bankName
          : bankName // ignore: cast_nullable_to_non_nullable
              as String,
      accountMasked: null == accountMasked
          ? _self.accountMasked
          : accountMasked // ignore: cast_nullable_to_non_nullable
              as String,
      accountHolder: null == accountHolder
          ? _self.accountHolder
          : accountHolder // ignore: cast_nullable_to_non_nullable
              as String,
      payoutLinked: null == payoutLinked
          ? _self.payoutLinked
          : payoutLinked // ignore: cast_nullable_to_non_nullable
              as bool,
      plan: null == plan
          ? _self.plan
          : plan // ignore: cast_nullable_to_non_nullable
              as Subscription,
      twoFactor: null == twoFactor
          ? _self.twoFactor
          : twoFactor // ignore: cast_nullable_to_non_nullable
              as bool,
      emailNotif: null == emailNotif
          ? _self.emailNotif
          : emailNotif // ignore: cast_nullable_to_non_nullable
              as bool,
      passwordChangedAt: freezed == passwordChangedAt
          ? _self.passwordChangedAt
          : passwordChangedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      activeDevices: null == activeDevices
          ? _self.activeDevices
          : activeDevices // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }

  /// Create a copy of OwnerProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SubscriptionCopyWith<$Res> get plan {
    return $SubscriptionCopyWith<$Res>(_self.plan, (value) {
      return _then(_self.copyWith(plan: value));
    });
  }
}

/// Adds pattern-matching-related methods to [OwnerProfile].
extension OwnerProfilePatterns on OwnerProfile {
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
    TResult Function(_OwnerProfile value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _OwnerProfile() when $default != null:
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
    TResult Function(_OwnerProfile value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OwnerProfile():
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
    TResult? Function(_OwnerProfile value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OwnerProfile() when $default != null:
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
            String id,
            String name,
            String initials,
            String? avatarUrl,
            String role,
            String area,
            DateTime joinedAt,
            String phone,
            String email,
            String address,
            bool verified,
            String bizName,
            String taxCode,
            String bizArea,
            String bankName,
            String accountMasked,
            String accountHolder,
            bool payoutLinked,
            Subscription plan,
            bool twoFactor,
            bool emailNotif,
            DateTime? passwordChangedAt,
            int activeDevices)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _OwnerProfile() when $default != null:
        return $default(
            _that.id,
            _that.name,
            _that.initials,
            _that.avatarUrl,
            _that.role,
            _that.area,
            _that.joinedAt,
            _that.phone,
            _that.email,
            _that.address,
            _that.verified,
            _that.bizName,
            _that.taxCode,
            _that.bizArea,
            _that.bankName,
            _that.accountMasked,
            _that.accountHolder,
            _that.payoutLinked,
            _that.plan,
            _that.twoFactor,
            _that.emailNotif,
            _that.passwordChangedAt,
            _that.activeDevices);
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
            String id,
            String name,
            String initials,
            String? avatarUrl,
            String role,
            String area,
            DateTime joinedAt,
            String phone,
            String email,
            String address,
            bool verified,
            String bizName,
            String taxCode,
            String bizArea,
            String bankName,
            String accountMasked,
            String accountHolder,
            bool payoutLinked,
            Subscription plan,
            bool twoFactor,
            bool emailNotif,
            DateTime? passwordChangedAt,
            int activeDevices)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OwnerProfile():
        return $default(
            _that.id,
            _that.name,
            _that.initials,
            _that.avatarUrl,
            _that.role,
            _that.area,
            _that.joinedAt,
            _that.phone,
            _that.email,
            _that.address,
            _that.verified,
            _that.bizName,
            _that.taxCode,
            _that.bizArea,
            _that.bankName,
            _that.accountMasked,
            _that.accountHolder,
            _that.payoutLinked,
            _that.plan,
            _that.twoFactor,
            _that.emailNotif,
            _that.passwordChangedAt,
            _that.activeDevices);
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
            String id,
            String name,
            String initials,
            String? avatarUrl,
            String role,
            String area,
            DateTime joinedAt,
            String phone,
            String email,
            String address,
            bool verified,
            String bizName,
            String taxCode,
            String bizArea,
            String bankName,
            String accountMasked,
            String accountHolder,
            bool payoutLinked,
            Subscription plan,
            bool twoFactor,
            bool emailNotif,
            DateTime? passwordChangedAt,
            int activeDevices)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OwnerProfile() when $default != null:
        return $default(
            _that.id,
            _that.name,
            _that.initials,
            _that.avatarUrl,
            _that.role,
            _that.area,
            _that.joinedAt,
            _that.phone,
            _that.email,
            _that.address,
            _that.verified,
            _that.bizName,
            _that.taxCode,
            _that.bizArea,
            _that.bankName,
            _that.accountMasked,
            _that.accountHolder,
            _that.payoutLinked,
            _that.plan,
            _that.twoFactor,
            _that.emailNotif,
            _that.passwordChangedAt,
            _that.activeDevices);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _OwnerProfile implements OwnerProfile {
  const _OwnerProfile(
      {required this.id,
      required this.name,
      required this.initials,
      this.avatarUrl,
      required this.role,
      required this.area,
      required this.joinedAt,
      required this.phone,
      required this.email,
      required this.address,
      required this.verified,
      required this.bizName,
      required this.taxCode,
      required this.bizArea,
      required this.bankName,
      required this.accountMasked,
      required this.accountHolder,
      required this.payoutLinked,
      required this.plan,
      required this.twoFactor,
      required this.emailNotif,
      this.passwordChangedAt,
      this.activeDevices = 0});

  @override
  final String id;
  @override
  final String name;
  @override
  final String initials;

  /// Public URL of the uploaded avatar; null → render [initials].
  @override
  final String? avatarUrl;
  @override
  final String role;
// "Chủ sân"
  @override
  final String area;
// "Quận 7, TP.HCM"
  @override
  final DateTime joinedAt;
  @override
  final String phone;
  @override
  final String email;
  @override
  final String address;
  @override
  final bool verified;
// business
  @override
  final String bizName;
  @override
  final String taxCode;
  @override
  final String bizArea;
// payout
  @override
  final String bankName;
  @override
  final String accountMasked;
  @override
  final String accountHolder;
  @override
  final bool payoutLinked;
// subscription
  @override
  final Subscription plan;
// security prefs
  @override
  final bool twoFactor;
  @override
  final bool emailNotif;
  @override
  final DateTime? passwordChangedAt;
  @override
  @JsonKey()
  final int activeDevices;

  /// Create a copy of OwnerProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$OwnerProfileCopyWith<_OwnerProfile> get copyWith =>
      __$OwnerProfileCopyWithImpl<_OwnerProfile>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _OwnerProfile &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.initials, initials) ||
                other.initials == initials) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.area, area) || other.area == area) &&
            (identical(other.joinedAt, joinedAt) ||
                other.joinedAt == joinedAt) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.verified, verified) ||
                other.verified == verified) &&
            (identical(other.bizName, bizName) || other.bizName == bizName) &&
            (identical(other.taxCode, taxCode) || other.taxCode == taxCode) &&
            (identical(other.bizArea, bizArea) || other.bizArea == bizArea) &&
            (identical(other.bankName, bankName) ||
                other.bankName == bankName) &&
            (identical(other.accountMasked, accountMasked) ||
                other.accountMasked == accountMasked) &&
            (identical(other.accountHolder, accountHolder) ||
                other.accountHolder == accountHolder) &&
            (identical(other.payoutLinked, payoutLinked) ||
                other.payoutLinked == payoutLinked) &&
            (identical(other.plan, plan) || other.plan == plan) &&
            (identical(other.twoFactor, twoFactor) ||
                other.twoFactor == twoFactor) &&
            (identical(other.emailNotif, emailNotif) ||
                other.emailNotif == emailNotif) &&
            (identical(other.passwordChangedAt, passwordChangedAt) ||
                other.passwordChangedAt == passwordChangedAt) &&
            (identical(other.activeDevices, activeDevices) ||
                other.activeDevices == activeDevices));
  }

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        name,
        initials,
        avatarUrl,
        role,
        area,
        joinedAt,
        phone,
        email,
        address,
        verified,
        bizName,
        taxCode,
        bizArea,
        bankName,
        accountMasked,
        accountHolder,
        payoutLinked,
        plan,
        twoFactor,
        emailNotif,
        passwordChangedAt,
        activeDevices
      ]);

  @override
  String toString() {
    return 'OwnerProfile(id: $id, name: $name, initials: $initials, avatarUrl: $avatarUrl, role: $role, area: $area, joinedAt: $joinedAt, phone: $phone, email: $email, address: $address, verified: $verified, bizName: $bizName, taxCode: $taxCode, bizArea: $bizArea, bankName: $bankName, accountMasked: $accountMasked, accountHolder: $accountHolder, payoutLinked: $payoutLinked, plan: $plan, twoFactor: $twoFactor, emailNotif: $emailNotif, passwordChangedAt: $passwordChangedAt, activeDevices: $activeDevices)';
  }
}

/// @nodoc
abstract mixin class _$OwnerProfileCopyWith<$Res>
    implements $OwnerProfileCopyWith<$Res> {
  factory _$OwnerProfileCopyWith(
          _OwnerProfile value, $Res Function(_OwnerProfile) _then) =
      __$OwnerProfileCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String initials,
      String? avatarUrl,
      String role,
      String area,
      DateTime joinedAt,
      String phone,
      String email,
      String address,
      bool verified,
      String bizName,
      String taxCode,
      String bizArea,
      String bankName,
      String accountMasked,
      String accountHolder,
      bool payoutLinked,
      Subscription plan,
      bool twoFactor,
      bool emailNotif,
      DateTime? passwordChangedAt,
      int activeDevices});

  @override
  $SubscriptionCopyWith<$Res> get plan;
}

/// @nodoc
class __$OwnerProfileCopyWithImpl<$Res>
    implements _$OwnerProfileCopyWith<$Res> {
  __$OwnerProfileCopyWithImpl(this._self, this._then);

  final _OwnerProfile _self;
  final $Res Function(_OwnerProfile) _then;

  /// Create a copy of OwnerProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? initials = null,
    Object? avatarUrl = freezed,
    Object? role = null,
    Object? area = null,
    Object? joinedAt = null,
    Object? phone = null,
    Object? email = null,
    Object? address = null,
    Object? verified = null,
    Object? bizName = null,
    Object? taxCode = null,
    Object? bizArea = null,
    Object? bankName = null,
    Object? accountMasked = null,
    Object? accountHolder = null,
    Object? payoutLinked = null,
    Object? plan = null,
    Object? twoFactor = null,
    Object? emailNotif = null,
    Object? passwordChangedAt = freezed,
    Object? activeDevices = null,
  }) {
    return _then(_OwnerProfile(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      initials: null == initials
          ? _self.initials
          : initials // ignore: cast_nullable_to_non_nullable
              as String,
      avatarUrl: freezed == avatarUrl
          ? _self.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      role: null == role
          ? _self.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      area: null == area
          ? _self.area
          : area // ignore: cast_nullable_to_non_nullable
              as String,
      joinedAt: null == joinedAt
          ? _self.joinedAt
          : joinedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      phone: null == phone
          ? _self.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _self.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      verified: null == verified
          ? _self.verified
          : verified // ignore: cast_nullable_to_non_nullable
              as bool,
      bizName: null == bizName
          ? _self.bizName
          : bizName // ignore: cast_nullable_to_non_nullable
              as String,
      taxCode: null == taxCode
          ? _self.taxCode
          : taxCode // ignore: cast_nullable_to_non_nullable
              as String,
      bizArea: null == bizArea
          ? _self.bizArea
          : bizArea // ignore: cast_nullable_to_non_nullable
              as String,
      bankName: null == bankName
          ? _self.bankName
          : bankName // ignore: cast_nullable_to_non_nullable
              as String,
      accountMasked: null == accountMasked
          ? _self.accountMasked
          : accountMasked // ignore: cast_nullable_to_non_nullable
              as String,
      accountHolder: null == accountHolder
          ? _self.accountHolder
          : accountHolder // ignore: cast_nullable_to_non_nullable
              as String,
      payoutLinked: null == payoutLinked
          ? _self.payoutLinked
          : payoutLinked // ignore: cast_nullable_to_non_nullable
              as bool,
      plan: null == plan
          ? _self.plan
          : plan // ignore: cast_nullable_to_non_nullable
              as Subscription,
      twoFactor: null == twoFactor
          ? _self.twoFactor
          : twoFactor // ignore: cast_nullable_to_non_nullable
              as bool,
      emailNotif: null == emailNotif
          ? _self.emailNotif
          : emailNotif // ignore: cast_nullable_to_non_nullable
              as bool,
      passwordChangedAt: freezed == passwordChangedAt
          ? _self.passwordChangedAt
          : passwordChangedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      activeDevices: null == activeDevices
          ? _self.activeDevices
          : activeDevices // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }

  /// Create a copy of OwnerProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SubscriptionCopyWith<$Res> get plan {
    return $SubscriptionCopyWith<$Res>(_self.plan, (value) {
      return _then(_self.copyWith(plan: value));
    });
  }
}

/// @nodoc
mixin _$ProfileStats {
  int get clusters;
  int get venues;
  double get rating;
  int get ratingCount;
  int get monthlyBookings;

  /// Create a copy of ProfileStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ProfileStatsCopyWith<ProfileStats> get copyWith =>
      _$ProfileStatsCopyWithImpl<ProfileStats>(
          this as ProfileStats, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ProfileStats &&
            (identical(other.clusters, clusters) ||
                other.clusters == clusters) &&
            (identical(other.venues, venues) || other.venues == venues) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.ratingCount, ratingCount) ||
                other.ratingCount == ratingCount) &&
            (identical(other.monthlyBookings, monthlyBookings) ||
                other.monthlyBookings == monthlyBookings));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, clusters, venues, rating, ratingCount, monthlyBookings);

  @override
  String toString() {
    return 'ProfileStats(clusters: $clusters, venues: $venues, rating: $rating, ratingCount: $ratingCount, monthlyBookings: $monthlyBookings)';
  }
}

/// @nodoc
abstract mixin class $ProfileStatsCopyWith<$Res> {
  factory $ProfileStatsCopyWith(
          ProfileStats value, $Res Function(ProfileStats) _then) =
      _$ProfileStatsCopyWithImpl;
  @useResult
  $Res call(
      {int clusters,
      int venues,
      double rating,
      int ratingCount,
      int monthlyBookings});
}

/// @nodoc
class _$ProfileStatsCopyWithImpl<$Res> implements $ProfileStatsCopyWith<$Res> {
  _$ProfileStatsCopyWithImpl(this._self, this._then);

  final ProfileStats _self;
  final $Res Function(ProfileStats) _then;

  /// Create a copy of ProfileStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? clusters = null,
    Object? venues = null,
    Object? rating = null,
    Object? ratingCount = null,
    Object? monthlyBookings = null,
  }) {
    return _then(_self.copyWith(
      clusters: null == clusters
          ? _self.clusters
          : clusters // ignore: cast_nullable_to_non_nullable
              as int,
      venues: null == venues
          ? _self.venues
          : venues // ignore: cast_nullable_to_non_nullable
              as int,
      rating: null == rating
          ? _self.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double,
      ratingCount: null == ratingCount
          ? _self.ratingCount
          : ratingCount // ignore: cast_nullable_to_non_nullable
              as int,
      monthlyBookings: null == monthlyBookings
          ? _self.monthlyBookings
          : monthlyBookings // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// Adds pattern-matching-related methods to [ProfileStats].
extension ProfileStatsPatterns on ProfileStats {
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
    TResult Function(_ProfileStats value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ProfileStats() when $default != null:
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
    TResult Function(_ProfileStats value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProfileStats():
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
    TResult? Function(_ProfileStats value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProfileStats() when $default != null:
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
    TResult Function(int clusters, int venues, double rating, int ratingCount,
            int monthlyBookings)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ProfileStats() when $default != null:
        return $default(_that.clusters, _that.venues, _that.rating,
            _that.ratingCount, _that.monthlyBookings);
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
    TResult Function(int clusters, int venues, double rating, int ratingCount,
            int monthlyBookings)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProfileStats():
        return $default(_that.clusters, _that.venues, _that.rating,
            _that.ratingCount, _that.monthlyBookings);
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
    TResult? Function(int clusters, int venues, double rating, int ratingCount,
            int monthlyBookings)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProfileStats() when $default != null:
        return $default(_that.clusters, _that.venues, _that.rating,
            _that.ratingCount, _that.monthlyBookings);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _ProfileStats implements ProfileStats {
  const _ProfileStats(
      {required this.clusters,
      required this.venues,
      required this.rating,
      required this.ratingCount,
      required this.monthlyBookings});

  @override
  final int clusters;
  @override
  final int venues;
  @override
  final double rating;
  @override
  final int ratingCount;
  @override
  final int monthlyBookings;

  /// Create a copy of ProfileStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ProfileStatsCopyWith<_ProfileStats> get copyWith =>
      __$ProfileStatsCopyWithImpl<_ProfileStats>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ProfileStats &&
            (identical(other.clusters, clusters) ||
                other.clusters == clusters) &&
            (identical(other.venues, venues) || other.venues == venues) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.ratingCount, ratingCount) ||
                other.ratingCount == ratingCount) &&
            (identical(other.monthlyBookings, monthlyBookings) ||
                other.monthlyBookings == monthlyBookings));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, clusters, venues, rating, ratingCount, monthlyBookings);

  @override
  String toString() {
    return 'ProfileStats(clusters: $clusters, venues: $venues, rating: $rating, ratingCount: $ratingCount, monthlyBookings: $monthlyBookings)';
  }
}

/// @nodoc
abstract mixin class _$ProfileStatsCopyWith<$Res>
    implements $ProfileStatsCopyWith<$Res> {
  factory _$ProfileStatsCopyWith(
          _ProfileStats value, $Res Function(_ProfileStats) _then) =
      __$ProfileStatsCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int clusters,
      int venues,
      double rating,
      int ratingCount,
      int monthlyBookings});
}

/// @nodoc
class __$ProfileStatsCopyWithImpl<$Res>
    implements _$ProfileStatsCopyWith<$Res> {
  __$ProfileStatsCopyWithImpl(this._self, this._then);

  final _ProfileStats _self;
  final $Res Function(_ProfileStats) _then;

  /// Create a copy of ProfileStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? clusters = null,
    Object? venues = null,
    Object? rating = null,
    Object? ratingCount = null,
    Object? monthlyBookings = null,
  }) {
    return _then(_ProfileStats(
      clusters: null == clusters
          ? _self.clusters
          : clusters // ignore: cast_nullable_to_non_nullable
              as int,
      venues: null == venues
          ? _self.venues
          : venues // ignore: cast_nullable_to_non_nullable
              as int,
      rating: null == rating
          ? _self.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double,
      ratingCount: null == ratingCount
          ? _self.ratingCount
          : ratingCount // ignore: cast_nullable_to_non_nullable
              as int,
      monthlyBookings: null == monthlyBookings
          ? _self.monthlyBookings
          : monthlyBookings // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
mixin _$Subscription {
  String get name; // "Gói miễn phí 3 tháng"
  DateTime get expiresAt;
  int get daysLeft;
  double get progress;

  /// Create a copy of Subscription
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SubscriptionCopyWith<Subscription> get copyWith =>
      _$SubscriptionCopyWithImpl<Subscription>(
          this as Subscription, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Subscription &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.daysLeft, daysLeft) ||
                other.daysLeft == daysLeft) &&
            (identical(other.progress, progress) ||
                other.progress == progress));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, name, expiresAt, daysLeft, progress);

  @override
  String toString() {
    return 'Subscription(name: $name, expiresAt: $expiresAt, daysLeft: $daysLeft, progress: $progress)';
  }
}

/// @nodoc
abstract mixin class $SubscriptionCopyWith<$Res> {
  factory $SubscriptionCopyWith(
          Subscription value, $Res Function(Subscription) _then) =
      _$SubscriptionCopyWithImpl;
  @useResult
  $Res call({String name, DateTime expiresAt, int daysLeft, double progress});
}

/// @nodoc
class _$SubscriptionCopyWithImpl<$Res> implements $SubscriptionCopyWith<$Res> {
  _$SubscriptionCopyWithImpl(this._self, this._then);

  final Subscription _self;
  final $Res Function(Subscription) _then;

  /// Create a copy of Subscription
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? expiresAt = null,
    Object? daysLeft = null,
    Object? progress = null,
  }) {
    return _then(_self.copyWith(
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      expiresAt: null == expiresAt
          ? _self.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      daysLeft: null == daysLeft
          ? _self.daysLeft
          : daysLeft // ignore: cast_nullable_to_non_nullable
              as int,
      progress: null == progress
          ? _self.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// Adds pattern-matching-related methods to [Subscription].
extension SubscriptionPatterns on Subscription {
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
    TResult Function(_Subscription value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Subscription() when $default != null:
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
    TResult Function(_Subscription value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Subscription():
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
    TResult? Function(_Subscription value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Subscription() when $default != null:
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
            String name, DateTime expiresAt, int daysLeft, double progress)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Subscription() when $default != null:
        return $default(
            _that.name, _that.expiresAt, _that.daysLeft, _that.progress);
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
            String name, DateTime expiresAt, int daysLeft, double progress)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Subscription():
        return $default(
            _that.name, _that.expiresAt, _that.daysLeft, _that.progress);
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
            String name, DateTime expiresAt, int daysLeft, double progress)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Subscription() when $default != null:
        return $default(
            _that.name, _that.expiresAt, _that.daysLeft, _that.progress);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Subscription implements Subscription {
  const _Subscription(
      {required this.name,
      required this.expiresAt,
      required this.daysLeft,
      required this.progress});

  @override
  final String name;
// "Gói miễn phí 3 tháng"
  @override
  final DateTime expiresAt;
  @override
  final int daysLeft;
  @override
  final double progress;

  /// Create a copy of Subscription
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SubscriptionCopyWith<_Subscription> get copyWith =>
      __$SubscriptionCopyWithImpl<_Subscription>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Subscription &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.daysLeft, daysLeft) ||
                other.daysLeft == daysLeft) &&
            (identical(other.progress, progress) ||
                other.progress == progress));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, name, expiresAt, daysLeft, progress);

  @override
  String toString() {
    return 'Subscription(name: $name, expiresAt: $expiresAt, daysLeft: $daysLeft, progress: $progress)';
  }
}

/// @nodoc
abstract mixin class _$SubscriptionCopyWith<$Res>
    implements $SubscriptionCopyWith<$Res> {
  factory _$SubscriptionCopyWith(
          _Subscription value, $Res Function(_Subscription) _then) =
      __$SubscriptionCopyWithImpl;
  @override
  @useResult
  $Res call({String name, DateTime expiresAt, int daysLeft, double progress});
}

/// @nodoc
class __$SubscriptionCopyWithImpl<$Res>
    implements _$SubscriptionCopyWith<$Res> {
  __$SubscriptionCopyWithImpl(this._self, this._then);

  final _Subscription _self;
  final $Res Function(_Subscription) _then;

  /// Create a copy of Subscription
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? name = null,
    Object? expiresAt = null,
    Object? daysLeft = null,
    Object? progress = null,
  }) {
    return _then(_Subscription(
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      expiresAt: null == expiresAt
          ? _self.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      daysLeft: null == daysLeft
          ? _self.daysLeft
          : daysLeft // ignore: cast_nullable_to_non_nullable
              as int,
      progress: null == progress
          ? _self.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

// dart format on
