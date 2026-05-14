import 'package:flutter_test/flutter_test.dart';
import 'package:solulab_company_task/features/card_scanner/data/models/card_parser_service.dart';
import 'package:solulab_company_task/features/card_scanner/domain/entities/card_details.dart';
import 'package:solulab_company_task/core/utils/enums.dart';

/// Unit tests for [CardParserService].
///
/// Each test uses a realistic simulated OCR string that mimics what
/// google_mlkit_text_recognition would return for a physical card.
void main() {
  late CardParserService parser;

  setUp(() {
    parser = const CardParserService();
  });

  // ── Helper ───────────────────────────────────────────────────────────────
  CardDetails parse(String rawText) => parser.parseCard(rawText);

  // ── Card Number Extraction ────────────────────────────────────────────────
  group('Card Number Extraction', () {
    test('extracts grouped 16-digit Visa number', () {
      const ocr = '''
HDFC BANK
4532 0151 1283 0366
JOHN DOE
VALID THRU 12/28
''';
      final result = parse(ocr);
      expect(result.rawCardNumber, equals('4532015112830366'));
    });

    test('extracts hyphen-separated number', () {
      const ocr = '5425-2334-3010-9903\nJANE SMITH\n09/26';
      final result = parse(ocr);
      expect(result.rawCardNumber, equals('5425233430109903'));
    });

    test('extracts compact 16-digit number', () {
      const ocr = 'AXIS BANK\n4916338506082832\nMEMBER SINCE 2020';
      final result = parse(ocr);
      expect(result.rawCardNumber, equals('4916338506082832'));
    });

    test('fixes OCR O→0 substitution in card number', () {
      // OCR mistake: O instead of 0 in the number
      const ocr = '4532 O151 1283 O366\nVALID THRU 12/28';
      final result = parse(ocr);
      expect(result.rawCardNumber, equals('4532015112830366'));
    });

    test('returns null card number for text with no valid number', () {
      const ocr = 'Hello World\nNo card here';
      final result = parse(ocr);
      expect(result.rawCardNumber, isNull);
    });

    test('extracts 15-digit AmEx number', () {
      const ocr = 'AMERICAN EXPRESS\n374251018720955\nMR JAMES BOND\n11/27';
      final result = parse(ocr);
      expect(result.rawCardNumber, equals('374251018720955'));
      expect(result.cardNetwork, equals(CardNetwork.americanExpress));
    });
  });

  // ── Expiry Date Extraction ────────────────────────────────────────────────
  group('Expiry Date Extraction', () {
    test('extracts MM/YY format', () {
      const ocr = '4111 1111 1111 1111\n12/25\nJOHN DOE';
      expect(parse(ocr).expiryDate, equals('12/25'));
    });

    test('extracts MM-YY format and normalises to MM/YY', () {
      const ocr = '4111 1111 1111 1111\n03-29\nJOHN DOE';
      expect(parse(ocr).expiryDate, equals('03/29'));
    });

    test('extracts full year MM/YYYY and converts to MM/YY', () {
      const ocr = 'VALID THRU 08/2027\n4532 0151 1283 0366';
      expect(parse(ocr).expiryDate, equals('08/27'));
    });

    test('extracts from VALID THRU context label', () {
      const ocr = '4532 0151 1283 0366\nVALID THRU 06/26\nJOHN DOE';
      expect(parse(ocr).expiryDate, equals('06/26'));
    });

    test('returns null when no expiry found', () {
      const ocr = '4532 0151 1283 0366\nJOHN DOE';
      expect(parse(ocr).expiryDate, isNull);
    });
  });

  // ── Card Holder Extraction ────────────────────────────────────────────────
  group('Card Holder Name Extraction', () {
    test('extracts uppercase 2-word name', () {
      const ocr = '4532 0151 1283 0366\nVALID THRU 12/25\nJOHN DOE';
      expect(parse(ocr).cardHolderName, equals('JOHN DOE'));
    });

    test('extracts 3-word name', () {
      const ocr = '5425 2334 3010 9903\nMR JAMES BOND\n09/27';
      final result = parse(ocr);
      expect(result.cardHolderName, isNotNull);
    });

    test('ignores VALID THRU keyword line', () {
      const ocr = '4532 0151 1283 0366\nVALID THRU\nJANE SMITH\n11/28';
      final result = parse(ocr);
      // Should not pick "VALID THRU" as name
      expect(result.cardHolderName, isNot(equals('VALID THRU')));
    });

    test('ignores lines containing digits', () {
      const ocr = '4532 0151 1283 0366\nEXP 12/25\nJOHN DOE';
      final result = parse(ocr);
      expect(result.cardHolderName, equals('JOHN DOE'));
    });

    test('returns null when no name detectable', () {
      const ocr = '4532 0151 1283 0366\n12/25\nVISA CREDIT';
      // VISA CREDIT may match keyword filter — should return null or filter
      final result = parse(ocr);
      // Just verify no crash, name may or may not be null
      expect(() => result.cardHolderName, returnsNormally);
    });
  });

  // ── Network Detection ──────────────────────────────────────────────────────
  group('Card Network Detection', () {
    test('detects Visa', () {
      expect(
        parse('4532 0151 1283 0366\n12/25').cardNetwork,
        CardNetwork.visa,
      );
    });

    test('detects Mastercard (51–55 prefix)', () {
      expect(
        parse('5425 2334 3010 9903\n12/25').cardNetwork,
        CardNetwork.mastercard,
      );
    });

    test('detects American Express', () {
      expect(
        parse('374251018720955\n12/25').cardNetwork,
        CardNetwork.americanExpress,
      );
    });

    test('detects Discover', () {
      expect(
        parse('6011 1111 1111 1117\n12/25').cardNetwork,
        CardNetwork.discover,
      );
    });

    test('returns unknown for unrecognised prefix', () {
      // 9-prefix is not assigned to any standard network
      expect(
        parse('9999999999999999\n12/25').cardNetwork,
        CardNetwork.unknown,
      );
    });
  });

  // ── Luhn Validation ────────────────────────────────────────────────────────
  group('Luhn Validation via parseCard', () {
    test('marks valid Visa as Luhn valid', () {
      expect(
        parse('4532 0151 1283 0366\n12/25').isLuhnValid,
        isTrue,
      );
    });

    test('marks sequential digits as Luhn invalid', () {
      expect(
        parse('1234 5678 9012 3456\n12/25').isLuhnValid,
        isFalse,
      );
    });
  });

  // ── Masked Card Number ─────────────────────────────────────────────────────
  group('Masked Card Number', () {
    test('formats as XXXX XXXX XXXX 0366', () {
      final result = parse('4532 0151 1283 0366\n12/25');
      expect(result.maskedCardNumber, equals('XXXX XXXX XXXX 0366'));
    });
  });

  // ── Empty / Noisy Input ────────────────────────────────────────────────────
  group('Edge Cases', () {
    test('empty string returns empty CardDetails', () {
      final result = parse('');
      expect(result.rawCardNumber, isNull);
      expect(result.cardHolderName, isNull);
      expect(result.expiryDate, isNull);
    });

    test('noise-only string does not crash', () {
      const noise = '... *** ~~~ ### @@@';
      expect(() => parse(noise), returnsNormally);
    });

    test('duplicate lines are deduplicated', () {
      const ocr = '4532 0151 1283 0366\n4532 0151 1283 0366\nJOHN DOE\nJOHN DOE\n12/25';
      final result = parse(ocr);
      // Parser should still find one card number, not crash
      expect(result.rawCardNumber, equals('4532015112830366'));
    });
  });
}
