import 'package:business_card_flutter/models/business_card.dart';
import 'package:business_card_flutter/services/business_card_storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ContactsNotifier extends StateNotifier<List<BusinessCard>> {
  ContactsNotifier() : super([]) {
    loadCards();
  }

  final BusinessCardStorageService _storage =
      BusinessCardStorageService();

  Future<void> loadCards() async {
    await _storage.initialize();

    final cards = _storage.getAllCards();

    cards.sort(
      (a, b) => b.createdAt.compareTo(a.createdAt),
    );

    state = cards;
  }

  String _normalizePhone(String phone) {
    return phone.replaceAll(RegExp(r'[^0-9+]'), '');
  }

  Future<bool> addCard(BusinessCard card) async {
    await _storage.initialize();

    final existingCards = _storage.getAllCards();

    bool duplicate = false;

    for (final existing in existingCards) {
      final phoneMatch =
          existing.phone != null &&
          card.phone != null &&
          _normalizePhone(existing.phone!) ==
              _normalizePhone(card.phone!);

      final emailMatch =
          existing.email != null &&
          card.email != null &&
          existing.email!.toLowerCase() ==
              card.email!.toLowerCase();

      if (phoneMatch || emailMatch) {
        duplicate = true;
        break;
      }
    }

    if (!duplicate) {
      await _storage.saveCard(card);
    }

    await loadCards();

    return !duplicate;
  }

  Future<void> deleteCard(String id) async {
    await _storage.deleteCard(id);
    await loadCards();
  }

  Future<void> refresh() async {
    await loadCards();
  }
}

final contactsProvider =
    StateNotifierProvider<ContactsNotifier, List<BusinessCard>>(
  (ref) => ContactsNotifier(),
);