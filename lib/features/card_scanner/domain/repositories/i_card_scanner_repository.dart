import '../entities/card_details.dart';

/// Domain-layer contract for the card scanning feature.
///
/// The presentation layer depends only on this interface, never on the
/// concrete data-layer implementation. This enables easy testing via mocks.
abstract class ICardScannerRepository {
  /// Runs OCR on the image at [imagePath] and returns parsed [CardDetails].
  ///
  /// Throws a [CardScanException] on any failure.
  Future<CardDetails> scanCard(String imagePath);
}

// ── Exception ────────────────────────────────────────────────────────────────

/// Typed exception for card scanning failures.
class CardScanException implements Exception {
  const CardScanException(this.message);
  final String message;

  @override
  String toString() => 'CardScanException: $message';
}
