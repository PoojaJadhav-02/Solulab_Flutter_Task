import '../entities/card_details.dart';

abstract class ICardScannerRepository {
  Future<CardDetails> scanCard(String imagePath);
}


class CardScanException implements Exception {
  const CardScanException(this.message);
  final String message;

  @override
  String toString() => 'CardScanException: $message';
}
