import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' as image_picker;

import '../../domain/entities/bank_details.dart';
import '../../domain/usecases/scan_passbook_usecase.dart';
import '../../domain/repositories/i_passbook_scanner_repository.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/constants/app_strings.dart';

/// Provider (ChangeNotifier) for the Passbook Scanner feature.
class PassbookScannerProvider extends ChangeNotifier {
  PassbookScannerProvider({required ScanPassbookUseCase scanPassbookUseCase})
      : _scanPassbookUseCase = scanPassbookUseCase;

  final ScanPassbookUseCase _scanPassbookUseCase;
  final image_picker.ImagePicker _picker = image_picker.ImagePicker();

  // ── State ─────────────────────────────────────────────────────────────────
  ScanState _state = ScanState.idle;
  BankDetails? _bankDetails;
  String? _errorMessage;
  String? _scannedImagePath;

  // ── Getters ───────────────────────────────────────────────────────────────
  ScanState get state => _state;
  BankDetails? get bankDetails => _bankDetails;
  String? get errorMessage => _errorMessage;
  String? get scannedImagePath => _scannedImagePath;

  bool get isLoading =>
      _state == ScanState.picking ||
      _state == ScanState.extracting ||
      _state == ScanState.parsing;

  // ── Public methods ────────────────────────────────────────────────────────

  Future<void> scanFromCamera() =>
      _pickAndScan(image_picker.ImageSource.camera);

  Future<void> scanFromGallery() =>
      _pickAndScan(image_picker.ImageSource.gallery);

  void reset() {
    _state = ScanState.idle;
    _bankDetails = null;
    _errorMessage = null;
    _scannedImagePath = null;
    notifyListeners();
  }

  // ── Private ───────────────────────────────────────────────────────────────

  Future<void> _pickAndScan(image_picker.ImageSource source) async {
    try {
      _setState(ScanState.picking);

      final image_picker.XFile? xFile = await _picker.pickImage(
        source: source,
        imageQuality: 90,
        maxWidth: 2560,
        maxHeight: 1440,
      );

      if (xFile == null) {
        _setState(ScanState.idle);
        return;
      }

      _scannedImagePath = xFile.path;
      notifyListeners();

      _setState(ScanState.extracting);
      _setState(ScanState.parsing);

      final details = await _scanPassbookUseCase(xFile.path);

      _bankDetails = details;
      _errorMessage = null;
      _setState(ScanState.success);
    } on PassbookScanException catch (e) {
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
