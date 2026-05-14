import 'package:flutter_test/flutter_test.dart';
import 'package:solulab_company_task/features/passbook_scanner/data/models/passbook_parser_service.dart';
import 'package:solulab_company_task/features/passbook_scanner/domain/entities/bank_details.dart';

/// Unit tests for [PassbookParserService].
///
/// Each test simulates realistic OCR output from an Indian bank passbook,
/// including cases with noise, duplicates, and partial data.
void main() {
  late PassbookParserService parser;

  setUp(() {
    parser = const PassbookParserService();
  });

  BankDetails parse(String rawText) => parser.parsePassbook(rawText);

  // ── IFSC Code Extraction ───────────────────────────────────────────────────
  group('IFSC Code Extraction', () {
    test('extracts valid SBI IFSC', () {
      const ocr = '''
STATE BANK OF INDIA
Account No: 12345678901
IFSC: SBIN0001234
Name: RAMESH KUMAR
''';
      expect(parse(ocr).ifscCode, equals('SBIN0001234'));
    });

    test('extracts valid HDFC IFSC', () {
      const ocr = 'HDFC BANK\nIFSC Code HDFC0001522\nA/C No 50100234567890';
      expect(parse(ocr).ifscCode, equals('HDFC0001522'));
    });

    test('extracts IFSC in mixed-case text by uppercasing', () {
      const ocr = 'ifsc code : icic0003456\nname : Priya Singh';
      expect(parse(ocr).ifscCode, equals('ICIC0003456'));
    });

    test('does not extract malformed IFSC (wrong format)', () {
      // "HDFC12345" is missing the mandatory 0 at position 5
      const ocr = 'IFSC: HDFC12345\nAccount: 123456789012';
      expect(parse(ocr).ifscCode, isNull);
    });

    test('returns null when no IFSC present', () {
      const ocr = 'Account No: 98765432101\nName: ANIL SHARMA';
      expect(parse(ocr).ifscCode, isNull);
    });
  });

  // ── Account Number Extraction ─────────────────────────────────────────────
  group('Account Number Extraction', () {
    test('extracts labeled account number', () {
      const ocr = '''
CANARA BANK
Account Number: 0341201010834
IFSC: CNRB0000341
Name: SUNITA PATEL
''';
      expect(parse(ocr).accountNumber, equals('0341201010834'));
    });

    test('extracts from A/C No label', () {
      const ocr = 'A/C No. 50100234567890\nIFSC HDFC0001522';
      expect(parse(ocr).accountNumber, equals('50100234567890'));
    });

    test('ignores mobile numbers (10 digits starting with 6-9)', () {
      const ocr = '''
Phone: 9876543210
Account No: 12345678901
IFSC: SBIN0001234
''';
      // Should pick the 11-digit account number, not the 10-digit mobile
      final result = parse(ocr);
      expect(result.accountNumber, equals('12345678901'));
    });

    test('prefers longer number over shorter', () {
      const ocr = '''
Branch Code: 001234
Account Number: 123456789012345
IFSC: AXIS0001234
''';
      expect(parse(ocr).accountNumber, equals('123456789012345'));
    });

    test('returns null when no valid account number present', () {
      const ocr = 'Name: JOHN\nPhone: 9876543210\nDate: 2025';
      // 10-digit mobile excluded, 4-digit year excluded
      expect(parse(ocr).accountNumber, isNull);
    });
  });

  // ── Account Holder Name Extraction ────────────────────────────────────────
  group('Account Holder Name Extraction', () {
    test('extracts from "Name:" label', () {
      const ocr = '''
UNION BANK OF INDIA
Account No: 678901234567
IFSC: UBIN0567890
Name: RAMESH KUMAR SHARMA
''';
      final result = parse(ocr);
      expect(result.accountHolderName, isNotNull);
      // Returned in title case
      expect(result.accountHolderName,
          anyOf(contains('Ramesh'), contains('RAMESH')));
    });

    test('extracts from "Account Holder:" label', () {
      const ocr = 'Account Holder: PRIYA SINGH\nAccount No: 123456789012';
      final result = parse(ocr);
      expect(result.accountHolderName, isNotNull);
    });

    test('does not confuse BANK NAME as account holder', () {
      const ocr = '''
STATE BANK OF INDIA
BRANCH: MUMBAI MAIN
Name: ANIL GUPTA
Account: 98765432101
''';
      final result = parse(ocr);
      // "STATE BANK OF INDIA" should not be the holder name
      expect(result.accountHolderName, isNot(contains('STATE')));
    });

    test('falls back to all-caps name line when no label', () {
      const ocr = '''
PUNJAB NATIONAL BANK
RAHUL VERMA
Account No 11223344556677
IFSC PUNB0123456
''';
      final result = parse(ocr);
      expect(result.accountHolderName, isNotNull);
    });
  });

  // ── Bank Name Inference ───────────────────────────────────────────────────
  group('Bank Name Inference', () {
    test('infers SBI from IFSC prefix SBIN', () {
      const ocr = 'Account: 12345678901\nIFSC: SBIN0001234';
      expect(parse(ocr).bankName, equals('State Bank of India'));
    });

    test('infers HDFC from IFSC prefix HDFC', () {
      const ocr = 'Account: 50100234567890\nIFSC: HDFC0001522';
      expect(parse(ocr).bankName, equals('HDFC Bank'));
    });

    test('detects bank name from text when IFSC absent', () {
      const ocr = 'HDFC Bank\nAccount No: 50100234567890';
      expect(parse(ocr).bankName, equals('HDFC Bank'));
    });

    test('returns null for unknown bank', () {
      const ocr = 'Account: 12345678901\nIFSC: XXXX0123456';
      // XXXX prefix not in mapping, no known bank text
      expect(parse(ocr).bankName, isNull);
    });
  });

  // ── Edge Cases ─────────────────────────────────────────────────────────────
  group('Edge Cases', () {
    test('empty string returns empty BankDetails', () {
      final result = parse('');
      expect(result.hasData, isFalse);
    });

    test('noisy OCR does not crash', () {
      const noise = '~~~@@@###\n... ??? !!!\nXXX YYY ZZZ';
      expect(() => parse(noise), returnsNormally);
    });

    test('duplicate lines are handled gracefully', () {
      const ocr = '''
SBIN0001234
SBIN0001234
Account: 12345678901
Account: 12345678901
''';
      final result = parse(ocr);
      expect(result.ifscCode, equals('SBIN0001234'));
      expect(result.accountNumber, equals('12345678901'));
    });

    test('formatted account number inserts spaces every 4 digits', () {
      const ocr = 'Account No: 12345678901234';
      final result = parse(ocr);
      // 14-digit account → formatted with spaces
      expect(result.formattedAccountNumber, equals('1234 5678 9012 34'));
    });

    test('fully realistic SBI passbook OCR', () {
      const ocr = '''
STATE BANK OF INDIA
BRANCH: CONNAUGHT PLACE, NEW DELHI
MICR CODE: 110002020

ACCOUNT HOLDER: RAJESH KUMAR SINGH
ACCOUNT NUMBER: 32101234567890
IFSC CODE: SBIN0000691
MOBILE: 9876543210
EMAIL: rajesh@email.com
PAN: ABCDE1234F
''';
      final result = parse(ocr);
      expect(result.ifscCode, equals('SBIN0000691'));
      expect(result.accountNumber, equals('32101234567890'));
      expect(result.bankName, equals('State Bank of India'));
      expect(result.accountHolderName, isNotNull);
    });
  });
}
