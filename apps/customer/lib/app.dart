import 'package:customer/core/di/injection.dart';
import 'package:customer/core/l10n/locale_cubit.dart';
import 'package:customer/core/theme/app_theme.dart';
import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class CustomerApp extends StatelessWidget {
  const CustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = sl<GoRouter>();

    return BlocProvider.value(
      value: sl<LocaleCubit>(),
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (context, locale) {
          return MaterialApp.router(
            title: 'SportBuddies',
            theme: buildLightTheme(),
            routerConfig: router,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: locale,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
