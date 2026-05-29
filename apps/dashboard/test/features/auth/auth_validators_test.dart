import 'package:dashboard/features/auth/auth_validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('validateEmail', () {
    test('rejects null/empty/whitespace', () {
      expect(validateEmail(null), isNotNull);
      expect(validateEmail(''), isNotNull);
      expect(validateEmail('   '), isNotNull);
    });

    test('rejects malformed addresses', () {
      expect(validateEmail('notanemail'), isNotNull);
      expect(validateEmail('foo@bar'), isNotNull);
      expect(validateEmail('@bar.com'), isNotNull);
    });

    test('accepts a valid address (trimmed)', () {
      expect(validateEmail('owner@example.com'), isNull);
      expect(validateEmail('  owner@example.com  '), isNull);
    });
  });

  group('validateLoginPassword', () {
    test('only requires non-empty', () {
      expect(validateLoginPassword(null), isNotNull);
      expect(validateLoginPassword(''), isNotNull);
      expect(validateLoginPassword('x'), isNull);
    });
  });

  group('validateSignupPassword', () {
    test('rejects empty', () {
      expect(validateSignupPassword(null), isNotNull);
      expect(validateSignupPassword(''), isNotNull);
    });

    test('rejects shorter than 8 chars', () {
      expect(validateSignupPassword('ab12'), isNotNull);
      expect(validateSignupPassword('abc123z'), isNotNull); // 7 chars
    });

    test('requires at least one letter', () {
      expect(validateSignupPassword('12345678'), isNotNull);
    });

    test('requires at least one digit', () {
      expect(validateSignupPassword('abcdefgh'), isNotNull);
    });

    test('accepts 8+ chars with a letter and a digit', () {
      expect(validateSignupPassword('abcd1234'), isNull);
      expect(validateSignupPassword('Password1'), isNull);
    });
  });

  group('validateConfirmPassword', () {
    test('rejects empty confirmation', () {
      expect(validateConfirmPassword('abcd1234', null), isNotNull);
      expect(validateConfirmPassword('abcd1234', ''), isNotNull);
    });

    test('rejects a mismatch', () {
      expect(validateConfirmPassword('abcd1234', 'abcd9999'), isNotNull);
    });

    test('accepts a match', () {
      expect(validateConfirmPassword('abcd1234', 'abcd1234'), isNull);
    });
  });
}
