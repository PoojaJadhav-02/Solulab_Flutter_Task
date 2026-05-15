import '../../../../core/utils/enums.dart';

class CardDetails {
  const CardDetails({
    this.rawCardNumber,
    this.cardHolderName,
    this.expiryDate,
    this.cardNetwork = CardNetwork.unknown,
    this.isLuhnValid = false,
  });

  final String? rawCardNumber;

  final String? cardHolderName;

  final String? expiryDate;

  final CardNetwork cardNetwork;

  final bool isLuhnValid;


  String? get formattedCardNumber {
    if (rawCardNumber == null || rawCardNumber!.isEmpty) return null;
    final digits = rawCardNumber!.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  String? get maskedCardNumber {
    final formatted = formattedCardNumber;
    if (formatted == null) return null;
    final parts = formatted.split(' ');
    if (parts.isEmpty) return null;
    final visible = parts.last;
    final masked = List.generate(parts.length - 1, (_) => 'XXXX');
    return [...masked, visible].join(' ');
  }

  bool get hasData =>
      rawCardNumber != null || cardHolderName != null || expiryDate != null;


  CardDetails copyWith({
    String? rawCardNumber,
    String? cardHolderName,
    String? expiryDate,
    CardNetwork? cardNetwork,
    bool? isLuhnValid,
  }) {
    return CardDetails(
      rawCardNumber: rawCardNumber ?? this.rawCardNumber,
      cardHolderName: cardHolderName ?? this.cardHolderName,
      expiryDate: expiryDate ?? this.expiryDate,
      cardNetwork: cardNetwork ?? this.cardNetwork,
      isLuhnValid: isLuhnValid ?? this.isLuhnValid,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardDetails &&
          rawCardNumber == other.rawCardNumber &&
          cardHolderName == other.cardHolderName &&
          expiryDate == other.expiryDate &&
          cardNetwork == other.cardNetwork &&
          isLuhnValid == other.isLuhnValid;

  @override
  int get hashCode => Object.hash(
        rawCardNumber,
        cardHolderName,
        expiryDate,
        cardNetwork,
        isLuhnValid,
      );

  @override
  String toString() =>
      'CardDetails(number: $rawCardNumber, holder: $cardHolderName, '
      'expiry: $expiryDate, network: $cardNetwork, luhn: $isLuhnValid)';
}
