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

  Future<void> addCard(BusinessCard card) async {
    await _storage.saveCard(card);
    await loadCards();
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