import '../../domain/entities/bank_details.dart';
import '../../domain/repositories/i_passbook_scanner_repository.dart';
import '../models/passbook_parser_service.dart';
import '../../../../core/services/ocr_service.dart';

/// Concrete implementation of [IPassbookScannerRepository].
///
/// Orchestrates OCR extraction followed by passbook parsing.
class PassbookScannerRepository implements IPassbookScannerRepository {
  const PassbookScannerRepository({
    required IOcrService ocrService,
    required PassbookParserService parserService,
  })  : _ocrService = ocrService,
        _parserService = parserService;

  final IOcrService _ocrService;
  final PassbookParserService _parserService;

  @override
  Future<BankDetails> scanPassbook(String imagePath) async {
    try {
      // Step 1: Extract raw text via OCR
      final rawText = await _ocrService.extractText(imagePath);

      // Step 2: Parse raw text into structured BankDetails
      final details = _parserService.parsePassbook(rawText);

      // Step 3: Check we extracted at least something useful
      if (!details.hasData) {
        throw const PassbookScanException(
          'Could not detect bank information. '
          'Please ensure the passbook page is clearly visible.',
        );
      }

      return details;
    } on OcrException catch (e) {
      throw PassbookScanException('OCR failed: ${e.message}');
    } on PassbookScanException {
      rethrow;
    } catch (e) {
      throw PassbookScanException('Unexpected error: ${e.toString()}');
    }
  }
}
