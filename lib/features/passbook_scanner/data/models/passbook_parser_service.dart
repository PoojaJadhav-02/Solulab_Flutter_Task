import '../../../passbook_scanner/domain/entities/bank_details.dart';
import '../../../../core/utils/ocr_cleaner.dart';
import '../../../../core/constants/app_constants.dart';

/// Parses raw OCR text from a bank passbook or account statement into a
/// structured [BankDetails] entity.
///
/// All parsing is manual — no third-party parser library is used.
/// The parser handles:
///  • Valid Indian IFSC code detection via regex
///  • Account number extraction (distinguishing from phone/pin/card numbers)
///  • Account holder name extraction from noisy OCR text
///  • Bank name inference from IFSC prefix
///  • Duplicate detection and deduplication
class PassbookParserService {
  const PassbookParserService();

  // ── IFSC prefix → Bank name mapping (top Indian banks) ──────────────────
  static const Map<String, String> _ifscBankMap = {
    'SBIN': 'State Bank of India',
    'HDFC': 'HDFC Bank',
    'ICIC': 'ICICI Bank',
    'AXIS': 'Axis Bank',
    'KKBK': 'Kotak Mahindra Bank',
    'PUNB': 'Punjab National Bank',
    'UBIN': 'Union Bank of India',
    'CNRB': 'Canara Bank',
    'BKID': 'Bank of India',
    'BARB': 'Bank of Baroda',
    'IOBA': 'Indian Overseas Bank',
    'IDBI': 'IDBI Bank',
    'INDB': 'IndusInd Bank',
    'FDRL': 'Federal Bank',
    'KVBL': 'Karur Vysya Bank',
    'YESB': 'Yes Bank',
    'RATN': 'RBL Bank',
    'UTIB': 'Axis Bank',
    'ALLA': 'Allahabad Bank',
    'CORP': 'Corporation Bank',
    'VIJB': 'Vijaya Bank',
    'SIBL': 'South Indian Bank',
    'CITI': 'Citibank',
    'HSBC': 'HSBC Bank',
    'SCBL': 'Standard Chartered Bank',
    'DEUT': 'Deutsche Bank',
  };

  // ─────────────────────────────────────────────────────────────────────────
  // Public API
  // ─────────────────────────────────────────────────────────────────────────

  /// Entry point: parses [rawText] and returns a [BankDetails].
  BankDetails parsePassbook(String rawText) {
    if (rawText.trim().isEmpty) return const BankDetails();

    final cleaned = OcrCleaner.removeDuplicateLines(
      OcrCleaner.normaliseWhitespace(rawText),
    );

    final ifscCode = _extractIfsc(cleaned);
    final accountNumber = _extractAccountNumber(cleaned);
    final holderName = _extractHolderName(cleaned);
    final bankName = ifscCode != null
        ? _inferBankName(ifscCode)
        : _extractBankName(cleaned);

    return BankDetails(
      accountHolderName: holderName,
      accountNumber: accountNumber,
      ifscCode: ifscCode,
      bankName: bankName,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Private helpers
  // ─────────────────────────────────────────────────────────────────────────

  /// Extracts a valid Indian IFSC code.
  ///
  /// Format: 4 uppercase letters (bank code) + '0' + 6 alphanumeric chars
  /// Example: "SBIN0001234", "HDFC0000001"
  String? _extractIfsc(String text) {
    // Strict IFSC regex per RBI specification
    final ifscPattern = RegExp(
      r'\b([A-Z]{4}0[A-Z0-9]{6})\b',
      caseSensitive: true,
    );

    final match = ifscPattern.firstMatch(text.toUpperCase());
    return match?.group(1);
  }

  /// Extracts the most probable bank account number.
  ///
  /// Strategy:
  ///  1. Look for a number on a line labeled "Account No", "A/C No", etc.
  ///  2. Collect all digit sequences in the valid account-number length range.
  ///  3. Exclude phone numbers (10 digits starting with 6-9) and PINs (4/6 digits).
  ///  4. Prefer longer numbers (Indian account numbers are typically 11-18 digits).
  String? _extractAccountNumber(String text) {
    final lines = text.split('\n');

    // Strategy 1: labeled line
    final labelPattern = RegExp(
      r'(?:account\s*(?:no|number|num|#)|a\/c\s*(?:no|number|num|#)|'
      r'acct\s*(?:no|number))[:\s\-]*(\d[\d\s]{7,20})',
      caseSensitive: false,
    );

    for (final line in lines) {
      final match = labelPattern.firstMatch(line);
      if (match != null) {
        final digits = OcrCleaner.digitsOnly(match.group(1)!);
        if (_isValidAccountNumber(digits)) return digits;
      }
    }

    // Strategy 2: scan all digit sequences
    final allDigitRuns = RegExp(r'\b\d{9,18}\b');
    final candidates = <String>[];

    for (final match in allDigitRuns.allMatches(text)) {
      final digits = match.group(0)!;
      if (_isValidAccountNumber(digits)) {
        candidates.add(digits);
      }
    }

    if (candidates.isEmpty) return null;

    // Prefer longer candidates (account numbers > phone numbers in length)
    candidates.sort((a, b) => b.length.compareTo(a.length));
    return candidates.first;
  }

  /// Returns true if the digit string is within account number length bounds
  /// and does not match common non-account patterns.
  bool _isValidAccountNumber(String digits) {
    final len = digits.length;
    if (len < AppConstants.accountMinDigits ||
        len > AppConstants.accountMaxDigits) {
      return false;
    }
    // Exclude Indian mobile numbers (10 digits, starts 6-9)
    if (len == 10 && RegExp(r'^[6-9]').hasMatch(digits)) return false;
    // Exclude year-like 4-digit values
    if (len == 4) return false;
    return true;
  }

  /// Extracts the probable account holder name.
  ///
  /// Strategy:
  ///  1. Look for labeled lines: "Name:", "Account Holder:", etc.
  ///  2. Fall back to all-caps multi-word lines that don't contain keywords.
  String? _extractHolderName(String text) {
    final lines = text.split('\n');

    // Strategy 1: labeled line
    final labelPattern = RegExp(
      r'(?:account\s*holder|customer\s*name|name\s*of\s*(?:account\s*)?'
      r'holder|name)[:\s\-]+([A-Za-z\s]{4,50})',
      caseSensitive: false,
    );

    for (final line in lines) {
      final match = labelPattern.firstMatch(line);
      if (match != null) {
        final name = match.group(1)!.trim();
        if (_isPlausibleName(name)) {
          return OcrCleaner.toTitleCase(name);
        }
      }
    }

    // Strategy 2: all-caps lines, skip known non-name keywords
    final skipKeywords = RegExp(
      r'\b(BANK|BRANCH|ACCOUNT|BALANCE|STATEMENT|PASSBOOK|IFSC|MICR|'
      r'SWIFT|ADDRESS|DATE|PHONE|MOBILE|EMAIL|PAN|AADHAAR|'
      r'TRANSACTION|WITHDRAWAL|DEPOSIT|INTEREST|SAVING|CURRENT)\b',
      caseSensitive: false,
    );

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      if (trimmed.contains(RegExp(r'\d'))) continue;
      if (skipKeywords.hasMatch(trimmed)) continue;
      if (trimmed == trimmed.toUpperCase() && _isPlausibleName(trimmed)) {
        return OcrCleaner.toTitleCase(trimmed);
      }
    }

    return null;
  }

  /// Checks that [name] looks like a real person's name.
  bool _isPlausibleName(String name) {
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.length < 2) return false;
    // Each word should be 2–20 characters, letters only
    return words.every(
      (w) => w.length >= 2 && w.length <= 20 && RegExp(r'^[A-Za-z]+$').hasMatch(w),
    );
  }

  /// Infers the bank name from the first 4 characters of the IFSC code.
  String? _inferBankName(String ifsc) {
    if (ifsc.length < 4) return null;
    final prefix = ifsc.substring(0, 4).toUpperCase();
    return _ifscBankMap[prefix];
  }

  /// Attempts to extract the bank name directly from the OCR text,
  /// e.g. from a header line like "STATE BANK OF INDIA".
  String? _extractBankName(String text) {
    final knownBankPatterns = <String>[
      'State Bank of India',
      'HDFC Bank',
      'ICICI Bank',
      'Axis Bank',
      'Punjab National Bank',
      'Canara Bank',
      'Bank of Baroda',
      'Bank of India',
      'Union Bank of India',
      'Kotak Mahindra Bank',
      'Yes Bank',
      'IndusInd Bank',
      'Federal Bank',
      'South Indian Bank',
      'Karur Vysya Bank',
      'Citibank',
      'HSBC',
    ];

    for (final bank in knownBankPatterns) {
      if (text.toLowerCase().contains(bank.toLowerCase())) return bank;
    }

    return null;
  }
}
