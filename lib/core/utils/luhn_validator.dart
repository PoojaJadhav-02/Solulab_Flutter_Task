class LuhnValidator {
  LuhnValidator._(); // Utility class – prevent instantiation

  static bool isValid(String cardNumber) {
    final digits = cardNumber.replaceAll(RegExp(r'\D'), '');

    if (digits.isEmpty) return false;
    if (digits.length < 13 || digits.length > 19) return false;

    int sum = 0;
    bool doubleIt = false; // We start from the rightmost digit

    for (int i = digits.length - 1; i >= 0; i--) {
      int digit = int.parse(digits[i]);

      if (doubleIt) {
        digit *= 2;
        if (digit > 9) digit -= 9;
      }

      sum += digit;
      doubleIt = !doubleIt; // Alternate the flag
    }

    return sum % 10 == 0;
  }
}
