import 'package:dashboard/core/debug/app_logger.dart';

mixin AppExceptionMixin {
  String get message;
  StackTrace? get stackTrace;

  void logError() {
    appLogger.e(message, error: message, stackTrace: stackTrace);
  }
}
