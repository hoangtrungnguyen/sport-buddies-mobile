/// Service-layer exception vocabulary shared by the SportBuddies apps.
///
/// The backend boundary is exception-based: HTTP clients `throw` on a non-2xx
/// response or a transport failure, and call sites `catch` by type. This file
/// gives both apps one base vocabulary for that boundary so a feature can
/// `catch` an [ApiException] / [NetworkException] (or an app-specific subclass)
/// regardless of which app it lives in.
///
/// This is deliberately separate from [AppFailure] (`failures.dart`): that is
/// the *Result*-based model for repositories that fold errors into return
/// values; this is the *throw/catch* model the HTTP clients actually use. An
/// app bridges the two by mapping a caught [ApiException] to an [AppFailure] at
/// its repository boundary (e.g. `ServerFailure(e.statusCode)`).
library;

/// A non-2xx response from a backend API.
///
/// - [statusCode] — the HTTP status, when the transport spoke HTTP.
/// - [code] — the machine-readable error key from the backend's error envelope
///   (e.g. `slot_taken`), when present.
/// - [detail] / [message] — human-readable explanation. Both are exposed so an
///   envelope's `detail` field and a plain message map onto the same type
///   without forcing call sites to pick one.
///
/// Apps subclass this for domain-specific errors (e.g. a 409 "slot taken")
/// while keeping a single base every feature can catch.
class ApiException implements Exception {
  const ApiException({
    this.statusCode,
    this.code,
    this.detail,
    this.message,
  });

  /// HTTP status code of the failing response, when known.
  final int? statusCode;

  /// Machine-readable error key from the backend error envelope, when present.
  final String? code;

  /// Human-readable detail from the error envelope, when present.
  final String? detail;

  /// Human-readable message, when the backend returned a bare message rather
  /// than a structured envelope.
  final String? message;

  @override
  String toString() {
    final parts = <String>[
      if (statusCode != null) '$statusCode',
      if (code != null) code!,
      if (detail != null) detail!,
      if (message != null) message!,
    ];
    return 'ApiException(${parts.join(', ')})';
  }
}

/// The request never reached the server — the device is offline or the host is
/// unreachable. UI should surface a "no internet" message rather than a
/// server-error message.
class NetworkException implements Exception {
  const NetworkException([this.message]);

  /// Optional human-readable context (rarely shown; UI usually maps this to a
  /// fixed "no connection" string).
  final String? message;

  @override
  String toString() =>
      'NetworkException${message != null ? '($message)' : ''}';
}
