import '../../../passbook_scanner/domain/entities/bank_details.dart';
import '../../../../core/utils/ocr_cleaner.dart';
import '../../../../core/constants/app_constants.dart';

class PassbookParserService {
  const PassbookParserService();

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


  String? _extractIfsc(String text) {
    final ifscPattern = RegExp(
      r'\b([A-Z]{4}0[A-Z0-9]{6})\b',
      caseSensitive: true,
    );

    final match = ifscPattern.firstMatch(text.toUpperCase());
    return match?.group(1);
  }

  String? _extractAccountNumber(String text) {
    final lines = text.split('\n');

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

    final allDigitRuns = RegExp(r'\b\d{9,18}\b');
    final candidates = <String>[];

    for (final match in allDigitRuns.allMatches(text)) {
      final digits = match.group(0)!;
      if (_isValidAccountNumber(digits)) {
        candidates.add(digits);
      }
    }

    if (candidates.isEmpty) return null;

    candidates.sort((a, b) => b.length.compareTo(a.length));
    return candidates.first;
  }

  bool _isValidAccountNumber(String digits) {
    final len = digits.length;
    if (len < AppConstants.accountMinDigits ||
        len > AppConstants.accountMaxDigits) {
      return false;
    }
    if (len == 10 && RegExp(r'^[6-9]').hasMatch(digits)) return false;
    if (len == 4) return false;
    return true;
  }

  String? _extractHolderName(String text) {
    final lines = text.split('\n');

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

  bool _isPlausibleName(String name) {
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.length < 2) return false;
    return words.every(
      (w) => w.length >= 2 && w.length <= 20 && RegExp(r'^[A-Za-z]+$').hasMatch(w),
    );
  }

  String? _inferBankName(String ifsc) {
    if (ifsc.length < 4) return null;
    final prefix = ifsc.substring(0, 4).toUpperCase();
    return _ifscBankMap[prefix];
  }

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
