import 'package:business_card_flutter/models/business_card.dart';
import 'package:hive_flutter/hive_flutter.dart';

class BusinessCardStorageService {
  static const String _boxName = 'business_cards';

  Future<void> initialize() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<dynamic>(_boxName);
    }
  }

  Future<void> saveCard(BusinessCard card) async {
    final box = _getBox();
    await box.put(card.id, card.toMap());
  }

  List<BusinessCard> getAllCards() {
    final box = _getBox();

    return box.values.map((value) {
      if (value is! Map) {
        throw const BusinessCardStorageException(
          'Stored business card data has an invalid format.',
        );
      }

      return BusinessCard.fromMap(
        Map<String, dynamic>.from(value),
      );
    }).toList(growable: false);
  }

  Box<dynamic> _getBox() {
    if (!Hive.isBoxOpen(_boxName)) {
      throw const BusinessCardStorageException(
        'Business card storage is unavailable.',
      );
    }

    return Hive.box<dynamic>(_boxName);
  }
}

class BusinessCardStorageException implements Exception {
  const BusinessCardStorageException(this.message);

  final String message;

  @override
  String toString() => message;
}
