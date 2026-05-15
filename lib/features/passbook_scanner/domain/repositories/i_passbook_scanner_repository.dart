import '../entities/bank_details.dart';

abstract class IPassbookScannerRepository {
  Future<BankDetails> scanPassbook(String imagePath);
}


class PassbookScanException implements Exception {
  const PassbookScanException(this.message);
  final String message;

  @override
  String toString() => 'PassbookScanException: $message';
}
