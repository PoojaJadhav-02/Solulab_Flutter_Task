class AppStrings {
  AppStrings._();

  static const String appName = 'OCR Scanner';
  static const String appVersion = '1.0.0';

  static const String homeTitle = 'OCR Scanner';
  static const String homeSubtitle = 'Scan cards & bank passbooks instantly';
  static const String scanCardBtn = 'Scan Card';
  static const String scanPassbookBtn = 'Scan Passbook';
  static const String cardScanDesc =
      'Credit, Debit & Prepaid cards\nExtract number, expiry & name';
  static const String passbookScanDesc =
      'Bank Passbooks & Documents\nExtract account, IFSC & holder';

  static const String cardScannerTitle = 'Card Scanner';
  static const String cardNumber = 'Card Number';
  static const String cardHolder = 'Card Holder';
  static const String cardExpiry = 'Expiry Date';
  static const String cardValid = 'Card Valid (Luhn)';
  static const String cardNetwork = 'Card Network';
  static const String scanAgain = 'Scan Again';
  static const String useCamera = 'Use Camera';
  static const String useGallery = 'From Gallery';
  static const String cardResultTitle = 'Card Details';

  static const String passbookScannerTitle = 'Passbook Scanner';
  static const String accountHolder = 'Account Holder';
  static const String accountNumber = 'Account Number';
  static const String ifscCode = 'IFSC Code';
  static const String bankName = 'Bank Name';
  static const String passbookResultTitle = 'Bank Details';

  static const String processing = 'Processing…';
  static const String extracting = 'Extracting text via OCR…';
  static const String noTextFound = 'No text found in image.\nTry a clearer scan.';
  static const String parsingFailed = 'Could not parse details.\nEnsure the image is clear.';
  static const String invalidScan = 'Invalid scan. Please try again.';
  static const String permissionDenied = 'Camera permission denied.\nGrant permission in Settings.';
  static const String notDetected = 'Not detected';

  static const String tryAgain = 'Try Again';
  static const String openSettings = 'Open Settings';
  static const String back = 'Back';
}
