// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:customer/core/di/injection_module.dart' as _i598;
import 'package:customer/features/profile/profile_cubit.dart' as _i724;
import 'package:get_it/get_it.dart' as _i174;
import 'package:go_router/go_router.dart' as _i583;
import 'package:injectable/injectable.dart' as _i526;
import 'package:supabase_flutter/supabase_flutter.dart' as _i454;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final registerModule = _$RegisterModule();
    gh.singleton<_i454.SupabaseClient>(() => registerModule.supabaseClient);
    gh.singleton<_i583.GoRouter>(() => registerModule.goRouter);
    gh.factory<_i724.ProfileCubit>(
        () => _i724.ProfileCubit(gh<_i454.SupabaseClient>()));
    return this;
  }
}

class _$RegisterModule extends _i598.RegisterModule {}
