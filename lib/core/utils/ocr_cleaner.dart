/// Utility class for cleaning and normalising raw OCR output.
///
/// OCR engines frequently produce character-level mistakes, especially
/// for digits vs letters. This class provides deterministic corrections.
class OcrCleaner {
  OcrCleaner._();

  // ── Character-level fixes for digit contexts ───────────────────────────────

  /// Replaces common OCR letter→digit mistakes in a string that should
  /// contain only digits.
  ///
  /// Common substitutions:
  ///   O/o → 0   (letter O looks like zero)
  ///   I/l → 1   (letter I or lowercase L looks like one)
  ///   S   → 5   (letter S can look like five in some fonts)
  ///   B   → 8   (letter B can look like eight)
  ///   G   → 6   (letter G can look like six)
  ///   Z   → 2   (letter Z can look like two)
  static String fixDigitOcrErrors(String input) {
    return input
        .replaceAll(RegExp(r'[Oo]'), '0')
        .replaceAll(RegExp(r'[IlL]'), '1')
        .replaceAll('S', '5')
        .replaceAll('B', '8')
        .replaceAll('G', '6')
        .replaceAll('Z', '2');
  }

  /// Normalises common separators and whitespace in raw OCR text.
  static String normaliseWhitespace(String input) {
    return input
        .replaceAll(RegExp(r'\r\n|\r'), '\n') // unify line endings
        .replaceAll(RegExp(r'[ \t]+'), ' ')    // collapse horizontal spaces
        .trim();
  }

  /// Strips all non-digit characters, useful when we need pure digit strings.
  static String digitsOnly(String input) {
    return input.replaceAll(RegExp(r'\D'), '');
  }

  /// Strips all non-alphanumeric characters (keeps letters & digits).
  static String alphanumericOnly(String input) {
    return input.replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
  }

  /// Converts a raw line to title case, ignoring short words.
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

  /// Removes redundant duplicate lines from raw OCR output.
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
