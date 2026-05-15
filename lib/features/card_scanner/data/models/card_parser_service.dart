import '../../../card_scanner/domain/entities/card_details.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/utils/luhn_validator.dart';
import '../../../../core/utils/ocr_cleaner.dart';
import '../../../../core/constants/app_constants.dart';

class CardParserService {
  const CardParserService();


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


  String? _extractCardNumber(List<String> lines) {
    final groupedPattern =
        RegExp(r'(\d{4}[\s\-]){3}\d{1,4}|\d{4}[\s\-]\d{6}[\s\-]\d{5}');

    final compactPattern = RegExp(r'\b\d{13,19}\b');

    for (final line in lines) {
      final fixed = OcrCleaner.fixDigitOcrErrors(line);

      final grouped = groupedPattern.firstMatch(fixed);
      if (grouped != null) {
        final digits = OcrCleaner.digitsOnly(grouped.group(0)!);
        if (_isPlausibleCardNumber(digits)) return digits;
      }
    }

    for (final line in lines) {
      final fixed = OcrCleaner.fixDigitOcrErrors(line);
      for (final match in compactPattern.allMatches(fixed)) {
        final digits = match.group(0)!;
        if (_isPlausibleCardNumber(digits)) return digits;
      }
    }

    return null;
  }

  bool _isPlausibleCardNumber(String digits) {
    return digits.length >= AppConstants.cardMinDigits &&
        digits.length <= AppConstants.cardMaxDigits;
  }

  String? _extractExpiry(String text) {
    final slashOrDash = RegExp(
      r'\b(0[1-9]|1[0-2])[\/\-](2[0-9]|[0-9]{2})\b',
    );

    final fullYear = RegExp(
      r'\b(0[1-9]|1[0-2])\/(20[2-9][0-9])\b',
    );

    final contextPattern = RegExp(
      r'(?:VALID\s*(?:THRU|THROUGH|TILL)|EXPIRY|EXPIRES?|EXP)\s*[:\s]*'
      r'(0[1-9]|1[0-2])[\/\-\s]?(2[0-9]|[0-9]{2})',
      caseSensitive: false,
    );

    final fullMatch = fullYear.firstMatch(text);
    if (fullMatch != null) {
      final month = fullMatch.group(1)!;
      final year = fullMatch.group(2)!.substring(2); // "2025" → "25"
      return '$month/$year';
    }

    final ctxMatch = contextPattern.firstMatch(text);
    if (ctxMatch != null) {
      return '${ctxMatch.group(1)}/${ctxMatch.group(2)}';
    }

    final plainMatch = slashOrDash.firstMatch(text);
    if (plainMatch != null) {
      return plainMatch.group(0)!.replaceAll('-', '/');
    }

    return null;
  }

  String? _extractHolderName(List<String> lines, String? cardNumber) {
    final skipKeywords = RegExp(
      r'\b(VALID|THRU|THROUGH|EXPIRY|EXPIRES?|BANK|CREDIT|DEBIT|VISA|'
      r'MASTER|MASTERCARD|RUPAY|MAESTRO|DISCOVER|AMEX|MEMBER|SINCE|'
      r'PLATINUM|GOLD|CLASSIC|SIGNATURE|WORLD|CVV|CVC|PIN|ATM)\b',
      caseSensitive: false,
    );

    final candidates = <String>[];

    for (final line in lines) {
      if (line.trim().isEmpty) continue;
      if (line.contains(RegExp(r'\d'))) continue;
      if (skipKeywords.hasMatch(line)) continue;
      final words = line.trim().split(RegExp(r'\s+'));
      if (words.length < 2) continue;
      if (words.any((w) => w.length < 2 || w.length > 20)) continue;
      if (!RegExp(r"^[A-Za-z\s'\-\.]+$").hasMatch(line.trim())) continue;

      candidates.add(line.trim().toUpperCase());
    }

    if (candidates.isEmpty) return null;

    candidates.sort((a, b) => b.split(' ').length.compareTo(a.split(' ').length));
    return candidates.first;
  }

  CardNetwork _detectNetwork(String? cardNumber) {
    if (cardNumber == null || cardNumber.isEmpty) return CardNetwork.unknown;

    final n = cardNumber.replaceAll(RegExp(r'\D'), '');
    if (n.isEmpty) return CardNetwork.unknown;

    if ((n.startsWith('34') || n.startsWith('37')) && n.length == 15) {
      return CardNetwork.americanExpress;
    }

    if (n.startsWith('4') && (n.length == 13 || n.length == 16)) {
      return CardNetwork.visa;
    }

    if (n.length == 16) {
      final prefix2 = int.tryParse(n.substring(0, 2)) ?? 0;
      final prefix4 = int.tryParse(n.substring(0, 4)) ?? 0;
      if (prefix2 >= 51 && prefix2 <= 55) return CardNetwork.mastercard;
      if (prefix4 >= 2221 && prefix4 <= 2720) return CardNetwork.mastercard;
    }

    if (n.startsWith('6011') || n.startsWith('65')) {
      return CardNetwork.discover;
    }

    if (n.startsWith('6759') ||
        n.startsWith('676770') ||
        n.startsWith('676774')) {
      return CardNetwork.maestro;
    }

    if (n.startsWith('60') ||
        n.startsWith('81') ||
        n.startsWith('82')) {
      return CardNetwork.rupay;
    }

    return CardNetwork.unknown;
  }
}
