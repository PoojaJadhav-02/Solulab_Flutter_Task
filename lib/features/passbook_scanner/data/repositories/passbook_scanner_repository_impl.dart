import '../../domain/entities/bank_details.dart';
import '../../domain/repositories/i_passbook_scanner_repository.dart';
import '../models/passbook_parser_service.dart';
import '../../../../core/services/ocr_service.dart';

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
      final rawText = await _ocrService.extractText(imagePath);

      final details = _parserService.parsePassbook(rawText);

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
