import 'package:customer/core/debug/app_logger.dart';
import 'package:customer/core/debug/app_exception_dialog.dart';
import 'package:customer/core/mixins/app_exception_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppBlocObserver extends BlocObserver {
  AppBlocObserver({required this.navigatorKey});

  final GlobalKey<NavigatorState> navigatorKey;

  @override
  void onCreate(BlocBase<dynamic> bloc) {
    super.onCreate(bloc);
    appLogger.d('CREATE ${bloc.runtimeType}');
  }

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    appLogger.d(
      '${bloc.runtimeType}: '
      '${change.currentState.runtimeType} → ${change.nextState.runtimeType}',
    );
    if (change.nextState is AppExceptionMixin) {
      (change.nextState as AppExceptionMixin).logError();
    }
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    appLogger.e('${bloc.runtimeType}', error: error, stackTrace: stackTrace);
    _showAppExceptionDialog(error);
    super.onError(bloc, error, stackTrace);
  }

  void _showAppExceptionDialog(Object error) {
    final context = navigatorKey.currentContext;
    if (context == null) return;
    AppExceptionDialog.show(context, error.toString());
  }
}
