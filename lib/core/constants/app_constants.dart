class AppConstants {
  AppConstants._(); // Prevent instantiation

  static const String appName = 'OCR Scanner';
  static const String appVersion = '1.0.0';

  static const String homeRoute = '/';
  static const String cardScannerRoute = '/card-scanner';
  static const String passbookScannerRoute = '/passbook-scanner';
  static const String cardResultRoute = '/card-result';
  static const String passbookResultRoute = '/passbook-result';

  static const int cardMinDigits = 13;

  static const int cardMaxDigits = 19;

  static const int accountMinDigits = 9;

  static const int accountMaxDigits = 18;

  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 16.0;
  static const double borderRadiusLarge = 24.0;

  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;

  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 350);
  static const Duration animationSlow = Duration(milliseconds: 600);
}
