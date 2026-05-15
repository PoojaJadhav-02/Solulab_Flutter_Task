class OcrCleaner {
  OcrCleaner._();


  static String fixDigitOcrErrors(String input) {
    return input
        .replaceAll(RegExp(r'[Oo]'), '0')
        .replaceAll(RegExp(r'[IlL]'), '1')
        .replaceAll('S', '5')
        .replaceAll('B', '8')
        .replaceAll('G', '6')
        .replaceAll('Z', '2');
  }

  static String normaliseWhitespace(String input) {
    return input
        .replaceAll(RegExp(r'\r\n|\r'), '\n') // unify line endings
        .replaceAll(RegExp(r'[ \t]+'), ' ')    // collapse horizontal spaces
        .trim();
  }

  static String digitsOnly(String input) {
    return input.replaceAll(RegExp(r'\D'), '');
  }

  static String alphanumericOnly(String input) {
    return input.replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
  }

  static String toTitleCase(String input) {
    final skipWords = {'a', 'an', 'the', 'of', 'in', 'on', 'at', 'to'};
    return input
        .trim()
        .split(RegExp(r'\s+'))
        .map((word) {
          if (word.isEmpty) return word;
          final lower = word.toLowerCase();
          if (skipWords.contains(lower)) return lower;
          return '${lower[0].toUpperCase()}${lower.substring(1)}';
        })
        .join(' ');
  }

  static String removeDuplicateLines(String rawText) {
    final seen = <String>{};
    final lines = rawText.split('\n');
    final cleaned = <String>[];

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isNotEmpty && seen.add(trimmed.toLowerCase())) {
        cleaned.add(trimmed);
      }
    }

    return cleaned.join('\n');
  }
}
