import 'package:flutter_test/flutter_test.dart';
import 'package:solulab_company_task/core/utils/luhn_validator.dart';

/// Unit tests for the Luhn algorithm implementation.
///
/// Test cases cover:
///  • Known-valid card numbers (Visa, Mastercard, AmEx)
///  • Known-invalid card numbers
///  • Edge cases (empty, too short, too long, with spaces/hyphens)
void main() {
  group('LuhnValidator', () {
    // ── Valid card numbers ─────────────────────────────────────────────────
    group('returns true for known-valid card numbers', () {
      test('Visa 16-digit', () {
        expect(LuhnValidator.isValid('4532015112830366'), isTrue);
      });

      test('Visa 16-digit (with spaces)', () {
        expect(LuhnValidator.isValid('4532 0151 1283 0366'), isTrue);
      });

      test('Visa 16-digit alternate', () {
        // 4539578763621486 is a well-known Luhn-valid Visa test number
        expect(LuhnValidator.isValid('4539578763621486'), isTrue);
      });

      test('Mastercard 16-digit', () {
        expect(LuhnValidator.isValid('5425233430109903'), isTrue);
      });

      test('Mastercard (with hyphens)', () {
        expect(LuhnValidator.isValid('5425-2334-3010-9903'), isTrue);
      });

      test('American Express 15-digit', () {
        // 378282246310005 is the canonical AmEx test number
        expect(LuhnValidator.isValid('378282246310005'), isTrue);
      });

      test('Discover 16-digit', () {
        expect(LuhnValidator.isValid('6011111111111117'), isTrue);
      });

      test('Well-known test number 4111111111111111', () {
        expect(LuhnValidator.isValid('4111111111111111'), isTrue);
      });

      test('Another valid Visa', () {
        expect(LuhnValidator.isValid('4916338506082832'), isTrue);
      });
    });

    // ── Invalid card numbers ──────────────────────────────────────────────
    group('returns false for known-invalid card numbers', () {
      test('Sequential digits (obviously wrong)', () {
        expect(LuhnValidator.isValid('1234567890123456'), isFalse);
      });

      test('All zeros actually passes Luhn (sum=0, divisible by 10)', () {
        // Mathematically 0000000000000000 passes Luhn;
        // in practice the card parser's plausibility check rejects it.
        expect(LuhnValidator.isValid('0000000000000000'), isTrue);
      });

      test('Off-by-one digit mutation', () {
        // 4532015112830366 is valid; changing last digit by 1 breaks Luhn
        expect(LuhnValidator.isValid('4532015112830367'), isFalse);
      });

      test('Reversed valid number', () {
        expect(LuhnValidator.isValid('6630328211510254'), isFalse);
      });
    });

    // ── Edge cases ────────────────────────────────────────────────────────
    group('edge cases', () {
      test('empty string returns false', () {
        expect(LuhnValidator.isValid(''), isFalse);
      });

      test('only spaces returns false', () {
        expect(LuhnValidator.isValid('    '), isFalse);
      });

      test('too short (< 13 digits) returns false', () {
        expect(LuhnValidator.isValid('12345'), isFalse);
      });

      test('too long (> 19 digits) returns false', () {
        expect(LuhnValidator.isValid('45320151128303660000'), isFalse);
      });

      test('letters only returns false', () {
        expect(LuhnValidator.isValid('ABCDEFGHIJKLMNOP'), isFalse);
      });

      test('mixed valid digits with extra spaces is accepted', () {
        // Spaces stripped → valid 16-digit Visa
        expect(LuhnValidator.isValid('  4532 0151 1283 0366  '), isTrue);
      });
    });
  });
}
