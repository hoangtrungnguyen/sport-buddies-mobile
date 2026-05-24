/// Domain-level failure types used across the SportBuddies app.
///
/// Per tech-plan §7.2: a sealed [AppFailure] hierarchy lets call sites
/// exhaustively switch on the failure kind without resorting to error
/// codes or string matching. Additional subclasses (e.g. `ValidationFailure`,
/// `PermissionFailure`) are introduced by feature stories as they emerge —
/// keep this file minimal until a real need surfaces (tech-plan §10).
sealed class AppFailure {
  const AppFailure();
}

/// Authentication / authorization problem surfaced by Supabase Auth or
/// downstream gates.
final class AuthFailure extends AppFailure {
  const AuthFailure(this.message);

  /// Human-readable reason. Safe to surface in UI via i18n lookup.
  final String message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuthFailure && other.message == message);

  @override
  int get hashCode => message.hashCode;

  @override
  String toString() => 'AuthFailure($message)';
}

/// Transport-level failure: device offline, DNS, TLS, timeout, etc.
final class NetworkFailure extends AppFailure {
  const NetworkFailure();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is NetworkFailure;

  @override
  int get hashCode => (NetworkFailure).hashCode;

  @override
  String toString() => 'NetworkFailure()';
}

/// Server-side failure carrying the HTTP-ish status code returned by the
/// backend (Supabase REST/RPC or Django DRF).
final class ServerFailure extends AppFailure {
  const ServerFailure(this.code);

  /// HTTP status code, or an application-defined error code when the
  /// transport didn't speak HTTP semantics.
  final int code;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is ServerFailure && other.code == code);

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => 'ServerFailure($code)';
}
