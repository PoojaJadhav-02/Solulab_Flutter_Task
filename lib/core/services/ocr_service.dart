import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

abstract class IOcrService {
  Future<String> extractText(String imagePath);

  void dispose();
}


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

      final buffer = StringBuffer();
      for (final block in recognizedText.blocks) {
        for (final line in block.lines) {
          buffer.writeln(line.text);
        }
      }

      final raw = buffer.toString().trim();

      if (raw.isEmpty) {
        throw const OcrException('No text detected in the provided image.');
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


class OcrException implements Exception {
  const OcrException(this.message);
  final String message;

  @override
  String toString() => 'OcrException: $message';
}
