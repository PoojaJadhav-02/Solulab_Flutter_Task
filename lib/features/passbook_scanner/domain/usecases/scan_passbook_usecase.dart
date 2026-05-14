import '../entities/bank_details.dart';
import '../repositories/i_passbook_scanner_repository.dart';

/// Use-case: scan a passbook image and return extracted [BankDetails].
class ScanPassbookUseCase {
  const ScanPassbookUseCase(this._repository);

  final IPassbookScannerRepository _repository;

  /// Executes the use-case.
  Future<BankDetails> call(String imagePath) {
    return _repository.scanPassbook(imagePath);
  }
}
