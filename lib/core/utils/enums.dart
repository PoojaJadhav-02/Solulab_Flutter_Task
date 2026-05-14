/// Enumerations used across the application.
///
/// Using enums instead of raw strings/booleans makes state transitions
/// explicit and exhaustively checkable via switch expressions.

/// Represents the current state of an OCR scan operation.
enum ScanState {
  /// No scan has been initiated yet.
  idle,

  /// The user is in the process of selecting/taking an image.
  picking,

  /// The image has been acquired and OCR text recognition is running.
  extracting,

  /// Raw text has been extracted and is being parsed into structured data.
  parsing,

  /// Scan & parse completed successfully. Data is available.
  success,

  /// An error occurred at any stage. Check the error message.
  error,
}

/// Represents the source of an image for scanning.
enum ImageSource {
  /// Captured via the device camera.
  camera,

  /// Picked from the device gallery/photo library.
  gallery,
}

/// Represents the card network/brand detected from the card number prefix.
enum CardNetwork {
  visa,
  mastercard,
  americanExpress,
  discover,
  rupay,
  maestro,
  unknown,
}

extension CardNetworkExtension on CardNetwork {
  /// Human-readable display label.
  String get label {
    switch (this) {
      case CardNetwork.visa:
        return 'Visa';
      case CardNetwork.mastercard:
        return 'Mastercard';
      case CardNetwork.americanExpress:
        return 'American Express';
      case CardNetwork.discover:
        return 'Discover';
      case CardNetwork.rupay:
        return 'RuPay';
      case CardNetwork.maestro:
        return 'Maestro';
      case CardNetwork.unknown:
        return 'Unknown';
    }
  }
}
