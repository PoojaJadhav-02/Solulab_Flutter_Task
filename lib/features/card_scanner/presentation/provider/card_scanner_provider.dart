import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' as image_picker;

import '../../domain/entities/card_details.dart';
import '../../domain/usecases/scan_card_usecase.dart';
import '../../domain/repositories/i_card_scanner_repository.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/constants/app_strings.dart';

/// Provider (ChangeNotifier) for the Card Scanner feature.
///
/// Manages:
///  • [ScanState] transitions (idle → picking → extracting → parsing → success/error)
///  • [ImagePicker] integration for camera & gallery
///  • Calling [ScanCardUseCase] and storing the result
///  • Error message propagation to the UI
class CardScannerProvider extends ChangeNotifier {
  CardScannerProvider({required ScanCardUseCase scanCardUseCase})
      : _scanCardUseCase = scanCardUseCase;

  final ScanCardUseCase _scanCardUseCase;
  final image_picker.ImagePicker _picker = image_picker.ImagePicker();

  // ── State ─────────────────────────────────────────────────────────────────
  ScanState _state = ScanState.idle;
  CardDetails? _cardDetails;
  String? _errorMessage;
  String? _scannedImagePath;

  // ── Getters ───────────────────────────────────────────────────────────────
  ScanState get state => _state;
  CardDetails? get cardDetails => _cardDetails;
  String? get errorMessage => _errorMessage;
  String? get scannedImagePath => _scannedImagePath;

  bool get isLoading =>
      _state == ScanState.picking ||
      _state == ScanState.extracting ||
      _state == ScanState.parsing;

  // ── Public methods ────────────────────────────────────────────────────────

  /// Launches the camera to capture a card image, then runs OCR + parsing.
  Future<void> scanFromCamera() =>
      _pickAndScan(image_picker.ImageSource.camera);

  /// Opens the gallery picker, then runs OCR + parsing.
  Future<void> scanFromGallery() =>
      _pickAndScan(image_picker.ImageSource.gallery);

  /// Resets the provider back to idle state so the user can scan again.
  void reset() {
    _state = ScanState.idle;
    _cardDetails = null;
    _errorMessage = null;
    _scannedImagePath = null;
    notifyListeners();
  }

  // ── Private ───────────────────────────────────────────────────────────────

  Future<void> _pickAndScan(image_picker.ImageSource source) async {
    try {
      // 1️⃣  Picking phase
      _setState(ScanState.picking);

      final image_picker.XFile? xFile = await _picker.pickImage(
        source: source,
        imageQuality: 90, // balance quality vs OCR speed
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (xFile == null) {
        // User cancelled the picker
        _setState(ScanState.idle);
        return;
      }

      _scannedImagePath = xFile.path;
      notifyListeners();

      // 2️⃣  Extracting phase - update UI to show progress
      _setState(ScanState.extracting);

      // 3️⃣  Parsing phase (use-case handles both OCR + parse internally)
      _setState(ScanState.parsing);
      final details = await _scanCardUseCase(xFile.path);

      // 4️⃣  Success
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
