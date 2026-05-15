
enum ScanState {
  idle,

  picking,

  extracting,

  parsing,

  success,

  error,
}

enum ImageSource {
  camera,

  gallery,
}

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
