import '../entities/bank_details.dart';

/// Domain-layer contract for the passbook scanning feature.
abstract class IPassbookScannerRepository {
  /// Runs OCR on the image at [imagePath] and returns parsed [BankDetails].
  ///
  /// Throws a [PassbookScanException] on any failure.
  Future<BankDetails> scanPassbook(String imagePath);
}

// ── Exception ────────────────────────────────────────────────────────────────

/// Typed exception for passbook scanning failures.
class PassbookScanException implements Exception {
  const PassbookScanException(this.message);
  final String message;

  @override
  String toString() => 'PassbookScanException: $message';
}
