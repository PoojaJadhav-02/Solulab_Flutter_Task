import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' as image_picker;

import '../../domain/entities/card_details.dart';
import '../../domain/usecases/scan_card_usecase.dart';
import '../../domain/repositories/i_card_scanner_repository.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/constants/app_strings.dart';

class CardScannerProvider extends ChangeNotifier {
  CardScannerProvider({required ScanCardUseCase scanCardUseCase})
      : _scanCardUseCase = scanCardUseCase;

  final ScanCardUseCase _scanCardUseCase;
  final image_picker.ImagePicker _picker = image_picker.ImagePicker();

  ScanState _state = ScanState.idle;
  CardDetails? _cardDetails;
  String? _errorMessage;
  String? _scannedImagePath;

  ScanState get state => _state;
  CardDetails? get cardDetails => _cardDetails;
  String? get errorMessage => _errorMessage;
  String? get scannedImagePath => _scannedImagePath;

  bool get isLoading =>
      _state == ScanState.picking ||
      _state == ScanState.extracting ||
      _state == ScanState.parsing;


  Future<void> scanFromCamera() =>
      _pickAndScan(image_picker.ImageSource.camera);

  Future<void> scanFromGallery() =>
      _pickAndScan(image_picker.ImageSource.gallery);

  void reset() {
    _state = ScanState.idle;
    _cardDetails = null;
    _errorMessage = null;
    _scannedImagePath = null;
    notifyListeners();
  }


  Future<void> _pickAndScan(image_picker.ImageSource source) async {
    try {
      _setState(ScanState.picking);

      final image_picker.XFile? xFile = await _picker.pickImage(
        source: source,
        imageQuality: 90, // balance quality vs OCR speed
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (xFile == null) {
        _setState(ScanState.idle);
        return;
      }

      _scannedImagePath = xFile.path;
      notifyListeners();

      _setState(ScanState.extracting);

      _setState(ScanState.parsing);
      final details = await _scanCardUseCase(xFile.path);

      _cardDetails = details;
      _errorMessage = null;
      _setState(ScanState.success);
    } on CardScanException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('${AppStrings.invalidScan}\n${e.toString()}');
    }
  }

  void _setState(ScanState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _state = ScanState.error;
    notifyListeners();
  }
}
