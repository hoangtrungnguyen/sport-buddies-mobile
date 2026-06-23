import 'package:logger/logger.dart';

final appLogger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 8,
    lineLength: 100,
    colors: true,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
);

/// Dedicated logger for outbound API/network traffic — one compact line per
/// request (see `LoggingHttpClient`). Kept separate from [appLogger] so the
/// call trace is easy to scan/filter and so its formatting stays terse.
final apiLogger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 0,
    lineLength: 100,
    colors: true,
    printEmojis: false,
    dateTimeFormat: DateTimeFormat.onlyTime,
  ),
);
