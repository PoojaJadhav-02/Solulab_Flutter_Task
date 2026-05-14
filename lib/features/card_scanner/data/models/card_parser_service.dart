import '../../../card_scanner/domain/entities/card_details.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/utils/luhn_validator.dart';
import '../../../../core/utils/ocr_cleaner.dart';
import '../../../../core/constants/app_constants.dart';

/// Parses raw OCR text into a structured [CardDetails] entity.
///
/// All logic is manual — no third-party parser library is used.
/// The parser handles:
///  • OCR letter→digit substitutions (O→0, I→1, etc.)
///  • Card numbers in various formats (spaces, hyphens, compact)
///  • Expiry dates in MM/YY, MM-YY, MM/YYYY, and MMYY formats
///  • Card holder names (multi-word, all-caps lines)
///  • Network detection from BIN/IIN prefix
///  • Luhn validation
class CardParserService {
  const CardParserService();

  // ─────────────────────────────────────────────────────────────────────────
  // Public API
  // ─────────────────────────────────────────────────────────────────────────

  /// Entry point: parses [rawText] and returns a [CardDetails].
  CardDetails parseCard(String rawText) {
    if (rawText.trim().isEmpty) {
      return const CardDetails();
    }

    final cleaned = OcrCleaner.removeDuplicateLines(
      OcrCleaner.normaliseWhitespace(rawText),
    );
    final lines = cleaned.split('\n').map((l) => l.trim()).toList();

    final cardNumber = _extractCardNumber(lines);
    final expiry = _extractExpiry(cleaned);
    final holderName = _extractHolderName(lines, cardNumber);
    final network = _detectNetwork(cardNumber);
    final luhnValid = cardNumber != null && LuhnValidator.isValid(cardNumber);

    return CardDetails(
      rawCardNumber: cardNumber,
      cardHolderName: holderName,
      expiryDate: expiry,
      cardNetwork: network,
      isLuhnValid: luhnValid,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Private helpers
  // ─────────────────────────────────────────────────────────────────────────

  /// Finds the most likely card number in [lines].
  ///
  /// Strategy:
  /// 1. Look for groups of 4 digits separated by spaces/hyphens (16-digit fmt)
  /// 2. Look for a compact run of 13–19 digits on a single line
  /// 3. Apply OCR fixes before matching
  String? _extractCardNumber(List<String> lines) {
    // Pattern 1 — grouped format: "4532 0151 1283 0366" or "4532-0151-1283-0366"
    final groupedPattern =
        RegExp(r'(\d{4}[\s\-]){3}\d{1,4}|\d{4}[\s\-]\d{6}[\s\-]\d{5}');

    // Pattern 2 — compact 13-19 digits (AmEx = 15, others = 13/16/19)
    final compactPattern = RegExp(r'\b\d{13,19}\b');

    for (final line in lines) {
      // Apply OCR digit corrections before trying to match
      final fixed = OcrCleaner.fixDigitOcrErrors(line);

      final grouped = groupedPattern.firstMatch(fixed);
      if (grouped != null) {
        final digits = OcrCleaner.digitsOnly(grouped.group(0)!);
        if (_isPlausibleCardNumber(digits)) return digits;
      }
    }

    // Second pass: compact numbers
    for (final line in lines) {
      final fixed = OcrCleaner.fixDigitOcrErrors(line);
      for (final match in compactPattern.allMatches(fixed)) {
        final digits = match.group(0)!;
        if (_isPlausibleCardNumber(digits)) return digits;
      }
    }

    return null;
  }

  /// Validates that the digit string is within card number length bounds.
  bool _isPlausibleCardNumber(String digits) {
    return digits.length >= AppConstants.cardMinDigits &&
        digits.length <= AppConstants.cardMaxDigits;
  }

  /// Extracts the expiry date from raw text.
  ///
  /// Recognised formats:
  ///   MM/YY  →  "12/25"
  ///   MM-YY  →  "12-25"
  ///   MM/YYYY → "12/2025"  → normalised to "12/25"
  ///   MMYY (compact, must be preceded by "VALID" or "THRU" context)
  String? _extractExpiry(String text) {
    // MM/YY or MM-YY
    final slashOrDash = RegExp(
      r'\b(0[1-9]|1[0-2])[\/\-](2[0-9]|[0-9]{2})\b',
    );

    // MM/YYYY
    final fullYear = RegExp(
      r'\b(0[1-9]|1[0-2])\/(20[2-9][0-9])\b',
    );

    // Look for "VALID THRU" or "EXPIRY" or "EXP" context for compact MMYY
    final contextPattern = RegExp(
      r'(?:VALID\s*(?:THRU|THROUGH|TILL)|EXPIRY|EXPIRES?|EXP)\s*[:\s]*'
      r'(0[1-9]|1[0-2])[\/\-\s]?(2[0-9]|[0-9]{2})',
      caseSensitive: false,
    );

    // Try full-year format first
    final fullMatch = fullYear.firstMatch(text);
    if (fullMatch != null) {
      final month = fullMatch.group(1)!;
      final year = fullMatch.group(2)!.substring(2); // "2025" → "25"
      return '$month/$year';
    }

    // Context-aware MMYY
    final ctxMatch = contextPattern.firstMatch(text);
    if (ctxMatch != null) {
      return '${ctxMatch.group(1)}/${ctxMatch.group(2)}';
    }

    // Plain MM/YY or MM-YY
    final plainMatch = slashOrDash.firstMatch(text);
    if (plainMatch != null) {
      return plainMatch.group(0)!.replaceAll('-', '/');
    }

    return null;
  }

  /// Extracts the probable card holder name.
  ///
  /// Strategy:
  ///  1. Skip lines containing digits or keywords like "VALID", "BANK", etc.
  ///  2. Prefer all-caps multi-word lines (cards print names in uppercase).
  ///  3. Apply a minimum word count and length check.
  String? _extractHolderName(List<String> lines, String? cardNumber) {
    // Keywords that appear on cards but are NOT the holder name
    final skipKeywords = RegExp(
      r'\b(VALID|THRU|THROUGH|EXPIRY|EXPIRES?|BANK|CREDIT|DEBIT|VISA|'
      r'MASTER|MASTERCARD|RUPAY|MAESTRO|DISCOVER|AMEX|MEMBER|SINCE|'
      r'PLATINUM|GOLD|CLASSIC|SIGNATURE|WORLD|CVV|CVC|PIN|ATM)\b',
      caseSensitive: false,
    );

    final candidates = <String>[];

    for (final line in lines) {
      // Skip empty lines
      if (line.trim().isEmpty) continue;
      // Skip lines with digits (numbers, dates, etc.)
      if (line.contains(RegExp(r'\d'))) continue;
      // Skip lines matching card-specific keywords
      if (skipKeywords.hasMatch(line)) continue;
      // Must have at least 2 words
      final words = line.trim().split(RegExp(r'\s+'));
      if (words.length < 2) continue;
      // Words should be reasonable name lengths
      if (words.any((w) => w.length < 2 || w.length > 20)) continue;
      // Must contain only letters, spaces, and common name punctuation
      if (!RegExp(r"^[A-Za-z\s'\-\.]+$").hasMatch(line.trim())) continue;

      candidates.add(line.trim().toUpperCase());
    }

    if (candidates.isEmpty) return null;

    // Prefer the longest candidate (more words = more likely a full name)
    candidates.sort((a, b) => b.split(' ').length.compareTo(a.split(' ').length));
    return candidates.first;
  }

  /// Detects the card network from the BIN (first 1–4 digits).
  ///
  /// Based on widely-published BIN ranges:
  ///   Visa         — starts with 4
  ///   Mastercard   — starts with 51–55 or 2221–2720
  ///   Amex         — starts with 34 or 37
  ///   Discover     — starts with 6011, 622126–622925, 644–649, 65
  ///   RuPay        — starts with 60, 65, 81, 82 (India-specific)
  ///   Maestro      — starts with 6759, 676770, 676774
  CardNetwork _detectNetwork(String? cardNumber) {
    if (cardNumber == null || cardNumber.isEmpty) return CardNetwork.unknown;

    final n = cardNumber.replaceAll(RegExp(r'\D'), '');
    if (n.isEmpty) return CardNetwork.unknown;

    // American Express: 15 digits, starts 34 or 37
    if ((n.startsWith('34') || n.startsWith('37')) && n.length == 15) {
      return CardNetwork.americanExpress;
    }

    // Visa: starts with 4, length 13 or 16
    if (n.startsWith('4') && (n.length == 13 || n.length == 16)) {
      return CardNetwork.visa;
    }

    // Mastercard: 51–55 or 2221–2720
    if (n.length == 16) {
      final prefix2 = int.tryParse(n.substring(0, 2)) ?? 0;
      final prefix4 = int.tryParse(n.substring(0, 4)) ?? 0;
      if (prefix2 >= 51 && prefix2 <= 55) return CardNetwork.mastercard;
      if (prefix4 >= 2221 && prefix4 <= 2720) return CardNetwork.mastercard;
    }

    // Discover: 6011, 65
    if (n.startsWith('6011') || n.startsWith('65')) {
      return CardNetwork.discover;
    }

    // Maestro: 6759, 676770, 676774
    if (n.startsWith('6759') ||
        n.startsWith('676770') ||
        n.startsWith('676774')) {
      return CardNetwork.maestro;
    }

    // RuPay (India): 60, 65, 81, 82
    if (n.startsWith('60') ||
        n.startsWith('81') ||
        n.startsWith('82')) {
      return CardNetwork.rupay;
    }

    return CardNetwork.unknown;
  }
}
