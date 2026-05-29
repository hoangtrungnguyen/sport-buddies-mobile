/// Shared client-side validators for the auth flows (login, signup,
/// forgot-password). Returning `null` means "valid"; a non-null [String] is a
/// localized, user-facing error message ready to surface in a [Form] field or
/// as a rejection key.
///
/// Kept free of Flutter/BLoC imports so it can be unit-tested in isolation and
/// reused by both `Form` field validators and BLoC event handlers.
library;

/// Validates an email address. Mirrors the backend's expectation of a
/// syntactically valid address (the server is the source of truth).
String? validateEmail(String? email) {
  if (email == null || email.trim().isEmpty) return 'Vui lòng nhập email.';
  final re = RegExp(r'^[^@]+@[^@]+\.[^@]+');
  if (!re.hasMatch(email.trim())) return 'Email không hợp lệ.';
  return null;
}

/// Login only requires a non-empty password — strength is the server's call,
/// and rejecting on length here would lock out pre-existing accounts.
String? validateLoginPassword(String? password) {
  if (password == null || password.isEmpty) return 'Vui lòng nhập mật khẩu.';
  return null;
}

/// Signup mirrors the `POST /auth/owner/signup` contract:
/// "min 8 chars, at least 1 letter and 1 digit". Surfacing these client-side
/// avoids a round-trip 400 for an obviously weak password.
String? validateSignupPassword(String? password) {
  if (password == null || password.isEmpty) return 'Vui lòng nhập mật khẩu.';
  if (password.length < 8) {
    return 'Mật khẩu phải có ít nhất 8 ký tự.';
  }
  if (!RegExp(r'[A-Za-z]').hasMatch(password)) {
    return 'Mật khẩu phải chứa ít nhất 1 chữ cái.';
  }
  if (!RegExp(r'\d').hasMatch(password)) {
    return 'Mật khẩu phải chứa ít nhất 1 chữ số.';
  }
  return null;
}

/// Confirms the re-typed password matches. Purely a UX guard — never sent to
/// the server.
String? validateConfirmPassword(String? password, String? confirm) {
  if (confirm == null || confirm.isEmpty) return 'Vui lòng xác nhận mật khẩu.';
  if (password != confirm) return 'Mật khẩu xác nhận không khớp.';
  return null;
}
