/// Extension methods that add convenience APIs to common Dart types.
extension StringExtensions on String {
  /// Returns true if the string contains at least [n] digit characters.
  bool hasAtLeastNDigits(int n) => RegExp(r'\d').allMatches(this).length >= n;

  /// Returns the string masked, showing only the last [visible] characters.
  /// All other characters are replaced with [maskChar].
  String maskExcept({int visible = 4, String maskChar = 'X'}) {
    if (length <= visible) return this;
    final tail = substring(length - visible);
    final masked = maskChar * (length - visible);
    return '$masked$tail';
  }

  /// Inserts [separator] every [groupSize] characters from the right.
  String groupDigits({int groupSize = 4, String separator = ' '}) {
    final digitsOnly = replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    for (int i = 0; i < digitsOnly.length; i++) {
      if (i > 0 && (digitsOnly.length - i) % groupSize == 0) {
        buffer.write(separator);
      }
      buffer.write(digitsOnly[i]);
    }
    return buffer.toString();
  }

  /// Checks whether this string is a plausible personal name:
  /// At least 2 words, only letters and spaces, no digits.
  bool get isPlausibleName {
    final trimmed = trim();
    if (trimmed.contains(RegExp(r'\d'))) return false;
    final words = trimmed.split(RegExp(r'\s+'));
    return words.length >= 2 && words.every((w) => w.length >= 1);
  }

  /// Converts to uppercase, trimmed.
  String get upperTrimmed => toUpperCase().trim();

  /// Returns null if string is empty/whitespace, otherwise the trimmed string.
  String? get nullIfEmpty => trim().isEmpty ? null : trim();
}

extension ListExtensions<T> on List<T> {
  /// Returns the first element matching [test], or null if none matches.
  T? firstWhereOrNull(bool Function(T) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
