import 'failures.dart';

/// A two-state outcome wrapper used by repositories and use cases.
///
/// Per tech-plan §7.1: every fallible boundary returns `Result<T>` instead
/// of throwing. Call sites pattern-match (`switch` on the sealed type) or
/// use [when] for a callback-style fold. Sealed-ness guarantees exhaustive
/// handling at compile time.
sealed class Result<T> {
  const Result();

  /// Functional fold: invoke [success] with the success value or [failure]
  /// with the [AppFailure]. Both branches are required.
  R when<R>({
    required R Function(T value) success,
    required R Function(AppFailure failure) failure,
  });
}

/// Successful outcome holding a [value] of type [T].
final class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;

  @override
  R when<R>({
    required R Function(T value) success,
    required R Function(AppFailure failure) failure,
  }) =>
      success(value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Success<T> && other.value == value);

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Success<$T>($value)';
}

/// Failed outcome carrying an [AppFailure] explaining what went wrong.
final class Failure<T> extends Result<T> {
  const Failure(this.failure);

  final AppFailure failure;

  @override
  R when<R>({
    required R Function(T value) success,
    required R Function(AppFailure failure) failure,
  }) =>
      failure(this.failure);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Failure<T> && other.failure == failure);

  @override
  int get hashCode => failure.hashCode;

  @override
  String toString() => 'Failure<$T>($failure)';
}
