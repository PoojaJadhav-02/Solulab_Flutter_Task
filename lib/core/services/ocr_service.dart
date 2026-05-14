import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Abstract contract for OCR text extraction.
///
/// Keeping this abstract allows injecting a mock in unit tests without
/// hitting the real ML Kit engine.
abstract class IOcrService {
  /// Extracts raw text from the image at [imagePath].
  ///
  /// Throws an [OcrException] if extraction fails.
  Future<String> extractText(String imagePath);

  /// Releases any underlying resources (e.g., the ML Kit recogniser).
  void dispose();
}

// ── Concrete Implementation ─────────────────────────────────────────────────

/// Implementation backed by Google ML Kit on-device text recognition.
///
/// Uses the [TextRecognizer] in LATIN script mode, which covers English and
/// most European languages – sufficient for card & passbook text.
class OcrService implements IOcrService {
  OcrService() : _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  final TextRecognizer _recognizer;

  @override
  Future<String> extractText(String imagePath) async {
    final file = File(imagePath);
    if (!file.existsSync()) {
      throw OcrException('Image file not found: $imagePath');
    }

    try {
      final inputImage = InputImage.fromFile(file);
      final recognizedText = await _recognizer.processImage(inputImage);

      // Concatenate all blocks with newlines, preserving structure
      final buffer = StringBuffer();
      for (final block in recognizedText.blocks) {
        for (final line in block.lines) {
          buffer.writeln(line.text);
        }
      }

      final raw = buffer.toString().trim();

      if (raw.isEmpty) {
        throw OcrException('No text detected in the provided image.');
      }

      return raw;
    } catch (e) {
      if (e is OcrException) rethrow;
      throw OcrException('OCR processing failed: ${e.toString()}');
    }
  }

  @override
  void dispose() {
    _recognizer.close();
  }
}

// ── Exception ───────────────────────────────────────────────────────────────

/// Typed exception for all OCR-related failures.
class OcrException implements Exception {
  const OcrException(this.message);
  final String message;

  @override
  String toString() => 'OcrException: $message';
}
