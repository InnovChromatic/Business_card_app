import 'package:business_card_flutter/models/scanned_card.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CardStorageService {
  static const String _boxName = 'scanned_cards';

  Future<void> initialize() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<dynamic>(_boxName);
    }
  }

  Future<void> saveCard(ScannedCard card) async {
    final box = _getBox();
    await box.put(card.id, card.toMap());
  }

  List<ScannedCard> getAllCards() {
    final box = _getBox();

    return box.values.map((value) {
      if (value is! Map) {
        throw const CardStorageException(
          'Stored card data has an invalid format.',
        );
      }

      return ScannedCard.fromMap(
        Map<String, dynamic>.from(value),
      );
    }).toList(growable: false);
  }

  Box<dynamic> _getBox() {
    if (!Hive.isBoxOpen(_boxName)) {
      throw const CardStorageException(
        'Scanned cards storage is unavailable.',
      );
    }

    return Hive.box<dynamic>(_boxName);
  }
}

class CardStorageException implements Exception {
  const CardStorageException(this.message);

  final String message;

  @override
  String toString() => message;
}
