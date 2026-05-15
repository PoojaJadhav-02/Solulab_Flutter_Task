extension StringExtensions on String {
  bool hasAtLeastNDigits(int n) => RegExp(r'\d').allMatches(this).length >= n;

  String maskExcept({int visible = 4, String maskChar = 'X'}) {
    if (length <= visible) return this;
    final tail = substring(length - visible);
    final masked = maskChar * (length - visible);
    return '$masked$tail';
  }

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

  bool get isPlausibleName {
    final trimmed = trim();
    if (trimmed.contains(RegExp(r'\d'))) return false;
    final words = trimmed.split(RegExp(r'\s+'));
    return words.length >= 2 && words.every((w) => w.length >= 1);
  }

  String get upperTrimmed => toUpperCase().trim();

  String? get nullIfEmpty => trim().isEmpty ? null : trim();
}

extension ListExtensions<T> on List<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
