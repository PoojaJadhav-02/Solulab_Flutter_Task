import '../../../../core/utils/enums.dart';

/// Immutable entity representing the structured data extracted from a
/// payment card scan.
///
/// All fields are nullable because OCR may not detect every field reliably.
class CardDetails {
  const CardDetails({
    this.rawCardNumber,
    this.cardHolderName,
    this.expiryDate,
    this.cardNetwork = CardNetwork.unknown,
    this.isLuhnValid = false,
  });

  /// The 13–19 digit card number as extracted (digits only, no spaces).
  final String? rawCardNumber;

  /// Name of the card holder as printed on the card.
  final String? cardHolderName;

  /// Expiry date string in normalised MM/YY format, e.g. "12/25".
  final String? expiryDate;

  /// Detected card network (Visa, Mastercard, etc.).
  final CardNetwork cardNetwork;

  /// Whether the card number passed the Luhn checksum.
  final bool isLuhnValid;

  // ── Computed Properties ──────────────────────────────────────────────────

  /// Card number formatted in groups of 4, e.g. "4532 0151 1283 0366".
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

  /// Card number masked so only the last 4 digits are visible:
  /// "XXXX XXXX XXXX 1234"
  String? get maskedCardNumber {
    final formatted = formattedCardNumber;
    if (formatted == null) return null;
    final parts = formatted.split(' ');
    if (parts.isEmpty) return null;
    final visible = parts.last;
    final masked = List.generate(parts.length - 1, (_) => 'XXXX');
    return [...masked, visible].join(' ');
  }

  /// Returns true only when we have enough data to display a meaningful result.
  bool get hasData =>
      rawCardNumber != null || cardHolderName != null || expiryDate != null;

  // ── Equality / Copy ──────────────────────────────────────────────────────

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
