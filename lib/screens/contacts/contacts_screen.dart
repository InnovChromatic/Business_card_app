import 'package:business_card_flutter/models/business_card.dart';
import 'package:business_card_flutter/providers/contacts_provider.dart';
import 'package:business_card_flutter/screens/contacts/contact_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ContactsSortMode {
  byName,
  byDate,
}

class ContactsScreen extends ConsumerStatefulWidget {
  const ContactsScreen({super.key});

  @override
  ConsumerState<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends ConsumerState<ContactsScreen> {
  static const Color _accentColor = Color(0xFF1D5CFF);

  final TextEditingController _searchController = TextEditingController();

  ContactsSortMode _sortMode = ContactsSortMode.byName;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {});
  }

  List<BusinessCard> _visibleCards(List<BusinessCard> inputCards) {
    final query = _searchController.text.trim().toLowerCase();

    final cards = inputCards.where((card) {
      if (query.isEmpty) return true;

      return card.name.toLowerCase().contains(query) ||
          (card.company?.toLowerCase().contains(query) ?? false);
    }).toList();

    switch (_sortMode) {
      case ContactsSortMode.byName:
        cards.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
        break;

      case ContactsSortMode.byDate:
        cards.sort(
          (a, b) => b.createdAt.compareTo(a.createdAt),
        );
        break;
    }

    return cards;
  }

  void _setSortMode(ContactsSortMode mode) {
    if (_sortMode == mode) return;

    setState(() {
      _sortMode = mode;
    });
  }

  Future<void> _openContact(BusinessCard card) async {
    final wasDeleted = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ContactDetailScreen(card: card),
      ),
    );

    if (wasDeleted == true && mounted) {
      await ref.read(contactsProvider.notifier).refresh();
    }
  }

  Future<void> _editMemo(BusinessCard card) async {
    final controller = TextEditingController(text: card.memo);

    final memo = await showDialog<String>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Edit Memo'),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Why did you save this card?',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(controller.text.trim());
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (memo == null || !mounted) return;

    final updatedCard = BusinessCard(
      id: card.id,
      name: card.name,
      company: card.company,
      designation: card.designation,
      email: card.email,
      phone: card.phone,
      website: card.website,
      imagePath: card.imagePath,
      memo: memo.isEmpty ? null : memo,
      createdAt: card.createdAt,
      source: card.source,
    );

    try {
      await ref.read(contactsProvider.notifier).addCard(updatedCard);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update memo')),
      );
    }
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cards = ref.watch(contactsProvider);
    final visibleCards = _visibleCards(cards);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _SearchRow(controller: _searchController),
            _ContactsTabs(contactsCount: cards.length),
            _SortRow(
              sortMode: _sortMode,
              onChanged: _setSortMode,
            ),
            Expanded(
              child: visibleCards.isEmpty
                  ? const _EmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                      itemCount: visibleCards.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 12),
                      itemBuilder: (_, index) {
                        final card = visibleCards[index];

                        return _ContactCard(
                          card: card,
                          onTap: () => _openContact(card),
                          onLongPress: () => _editMemo(card),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchRow extends StatelessWidget {
  const _SearchRow({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Person or company',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFFF1F3F6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 10),
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tag search coming soon')),
              );
            },
            child: const Text('Search tags'),
          ),
        ],
      ),
    );
  }
}

class _ContactsTabs extends StatelessWidget {
  const _ContactsTabs({required this.contactsCount});

  final int contactsCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: _TabLabel(
                  label: 'Your contacts',
                  count: contactsCount,
                  isActive: true,
                ),
              ),
              const Expanded(
                child: _TabLabel(
                  label: 'Your colleagues',
                  count: 0,
                  isActive: false,
                ),
              ),
            ],
          ),
        ),
        const Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: 0.5,
            child: Divider(
              height: 3,
              thickness: 3,
              color: _ContactsScreenState._accentColor,
            ),
          ),
        ),
      ],
    );
  }
}

class _TabLabel extends StatelessWidget {
  const _TabLabel({
    required this.label,
    required this.count,
    required this.isActive,
  });

  final String label;
  final int count;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? Colors.black : Colors.black54;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F2F5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SortRow extends StatelessWidget {
  const _SortRow({
    required this.sortMode,
    required this.onChanged,
  });

  final ContactsSortMode sortMode;
  final ValueChanged<ContactsSortMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
      child: Row(
        children: [
          _SortButton(
            label: 'Your cards',
            isActive: sortMode == ContactsSortMode.byName,
            onTap: () => onChanged(ContactsSortMode.byName),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text('|', style: TextStyle(color: Colors.black26)),
          ),
          _SortButton(
            label: 'Date added',
            isActive: sortMode == ContactsSortMode.byDate,
            onTap: () => onChanged(ContactsSortMode.byDate),
          ),
        ],
      ),
    );
  }
}

class _SortButton extends StatelessWidget {
  const _SortButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          label,
          style: TextStyle(
            color: isActive
                ? _ContactsScreenState._accentColor
                : Colors.black45,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.credit_card_outlined, size: 54, color: Colors.black38),
          SizedBox(height: 16),
          Text(
            'Contacts you add will appear here',
            style: TextStyle(color: Colors.black54, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.card,
    required this.onTap,
    required this.onLongPress,
  });

  final BusinessCard card;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final contactDetail = card.email ?? card.phone;
    final memo = card.memo;

    return Material(
      color: const Color(0xFFF4F5F7),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                card.name,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (card.company != null && card.company!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  card.company!,
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
              if (contactDetail != null && contactDetail.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(contactDetail),
              ],
              if (memo != null && memo.isNotEmpty) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.push_pin_outlined,
                      size: 16,
                      color: _ContactsScreenState._accentColor,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        memo,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _ContactsScreenState._accentColor,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}