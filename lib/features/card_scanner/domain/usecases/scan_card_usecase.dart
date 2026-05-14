import '../entities/card_details.dart';
import '../repositories/i_card_scanner_repository.dart';

/// Use-case: scan a card image and return extracted [CardDetails].
///
/// Use-cases in clean architecture encapsulate a single business operation.
/// They depend only on the domain repository interface — never on data-layer
/// or UI code.
class ScanCardUseCase {
  const ScanCardUseCase(this._repository);

  final ICardScannerRepository _repository;

  /// Executes the use-case.
  ///
  /// [imagePath] — absolute path to the image file captured/picked by the user.
  Future<CardDetails> call(String imagePath) {
    return _repository.scanCard(imagePath);
  }
}
