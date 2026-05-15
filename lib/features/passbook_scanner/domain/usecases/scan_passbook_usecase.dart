import '../entities/bank_details.dart';
import '../repositories/i_passbook_scanner_repository.dart';

class ScanPassbookUseCase {
  const ScanPassbookUseCase(this._repository);

  final IPassbookScannerRepository _repository;

  Future<BankDetails> call(String imagePath) {
    return _repository.scanPassbook(imagePath);
  }
}
