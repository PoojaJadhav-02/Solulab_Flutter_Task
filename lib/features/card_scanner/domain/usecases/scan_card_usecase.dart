import '../entities/card_details.dart';
import '../repositories/i_card_scanner_repository.dart';

class ScanCardUseCase {
  const ScanCardUseCase(this._repository);

  final ICardScannerRepository _repository;

  Future<CardDetails> call(String imagePath) {
    return _repository.scanCard(imagePath);
  }
}
