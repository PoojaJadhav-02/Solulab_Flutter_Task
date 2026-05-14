import '../../domain/entities/card_details.dart';
import '../../domain/repositories/i_card_scanner_repository.dart';
import '../models/card_parser_service.dart';
import '../../../../core/services/ocr_service.dart';

/// Concrete implementation of [ICardScannerRepository].
///
/// Orchestrates:
///   1. OCR text extraction via [IOcrService]
///   2. Text parsing via [CardParserService]
///
/// This class lives in the data layer and depends on concrete services.
/// The domain layer only sees [ICardScannerRepository].
class CardScannerRepository implements ICardScannerRepository {
  const CardScannerRepository({
    required IOcrService ocrService,
    required CardParserService parserService,
  })  : _ocrService = ocrService,
        _parserService = parserService;

  final IOcrService _ocrService;
  final CardParserService _parserService;

  @override
  Future<CardDetails> scanCard(String imagePath) async {
    try {
      // Step 1: Extract raw text via OCR
      final rawText = await _ocrService.extractText(imagePath);

      // Step 2: Parse raw text into structured CardDetails
      final details = _parserService.parseCard(rawText);

      // Step 3: Validate that we found at least a card number or expiry
      if (!details.hasData) {
        throw const CardScanException(
          'Could not detect card information. '
          'Please ensure the card is clearly visible.',
        );
      }

      return details;
    } on OcrException catch (e) {
      throw CardScanException('OCR failed: ${e.message}');
    } on CardScanException {
      rethrow;
    } catch (e) {
      throw CardScanException('Unexpected error: ${e.toString()}');
    }
  }
}
