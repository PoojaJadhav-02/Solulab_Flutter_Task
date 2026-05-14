/// Luhn algorithm implementation for credit/debit card validation.
///
/// The Luhn algorithm (also known as the "modulus 10" algorithm) is a simple
/// checksum formula used to validate identification numbers, most notably
/// credit card numbers.
///
/// Algorithm steps:
/// 1. From the rightmost digit, double every second digit.
/// 2. If doubling produces a number > 9, subtract 9.
/// 3. Sum all digits.
/// 4. If total modulo 10 == 0, the number is valid.
class LuhnValidator {
  LuhnValidator._(); // Utility class – prevent instantiation

  /// Returns true if [cardNumber] passes the Luhn checksum.
  ///
  /// [cardNumber] may contain spaces or hyphens; they are stripped before
  /// validation.
  ///
  /// Example:
  /// ```dart
  /// LuhnValidator.isValid('4532015112830366') // true
  /// LuhnValidator.isValid('1234567890123456') // false
  /// ```
  static bool isValid(String cardNumber) {
    // Strip all non-digit characters (spaces, hyphens, etc.)
    final digits = cardNumber.replaceAll(RegExp(r'\D'), '');

    if (digits.isEmpty) return false;
    if (digits.length < 13 || digits.length > 19) return false;

    int sum = 0;
    bool doubleIt = false; // We start from the rightmost digit

    // Traverse from right to left
    for (int i = digits.length - 1; i >= 0; i--) {
      int digit = int.parse(digits[i]);

      if (doubleIt) {
        digit *= 2;
        // If the result is greater than 9, subtract 9
        // (equivalent to summing the two digits, e.g. 16 → 1+6=7 or 16-9=7)
        if (digit > 9) digit -= 9;
      }

      sum += digit;
      doubleIt = !doubleIt; // Alternate the flag
    }

    // A valid card number produces a sum that is a multiple of 10
    return sum % 10 == 0;
  }
}
