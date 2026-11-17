import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/flashcard_entity.dart';
import '../view_models/flashcard_view_model.dart';
import '../widgets/flashcard_dialog.dart';

class ManageCardsView extends StatefulWidget {
  final FlashcardViewModel viewModel;

  const ManageCardsView({super.key, required this.viewModel});

  @override
  State<ManageCardsView> createState() => _ManageCardsViewState();
}

class _ManageCardsViewState extends State<ManageCardsView> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<FlashcardEntity> _getFilteredCards(List<FlashcardEntity> cards) {
    if (_searchQuery.trim().isEmpty) return cards;
    final query = _searchQuery.toLowerCase();
    return cards.where((card) {
      return card.question.toLowerCase().contains(query) ||
          card.answer.toLowerCase().contains(query) ||
          card.category.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _addNewCard() async {
    final newCard = await FlashcardDialog.show(context);
    if (newCard != null) {
      await widget.viewModel.addCard(newCard);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Flashcard added to deck!'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppTheme.sunsetCoral,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Future<void> _editCard(FlashcardEntity card) async {
    final updatedCard = await FlashcardDialog.show(context, existingCard: card);
    if (updatedCard != null) {
      await widget.viewModel.updateCard(updatedCard);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Flashcard updated!'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppTheme.warmAmber,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Future<void> _deleteCard(FlashcardEntity card) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Flashcard?'),
        content: Text(
          'Are you sure you want to delete this card:\n"${card.question}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await widget.viewModel.deleteCard(card.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Flashcard removed.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final cards = widget.viewModel.cards;
        final filtered = _getFilteredCards(cards);

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Deck Manager',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                letterSpacing: -0.3,
              ),
            ),
            actions: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.sunsetCoral.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.sunsetCoral.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Text(
                      '${cards.length} cards',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 11.5,
                        color: AppTheme.sunsetCoral,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              // Search input
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search questions, answers, categories...',
                    hintStyle: TextStyle(
                      fontSize: 13.5,
                      color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
                    ),
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),

              // Cards list
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _searchQuery.isNotEmpty
                                    ? Icons.search_off_rounded
                                    : Icons.style_outlined,
                                size: 56,
                                color: isDark ? Colors.grey.shade700 : Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _searchQuery.isNotEmpty
                                    ? 'No flashcards matched "$_searchQuery"'
                                    : 'Your deck is currently empty',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _searchQuery.isNotEmpty
                                    ? 'Try searching with another keyword'
                                    : 'Tap the + button to add your first study card',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: 84,
                          top: 4,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final card = filtered[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                              side: BorderSide(
                                color: isDark
                                    ? const Color(0xFF262C3E)
                                    : const Color(0xFFEDECE8),
                                width: 1.2,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 9,
                                          vertical: 3.5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppTheme.sunsetCoral.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: AppTheme.sunsetCoral.withValues(alpha: 0.2),
                                          ),
                                        ),
                                        child: Text(
                                          card.category.toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: AppTheme.sunsetCoral,
                                            letterSpacing: 0.6,
                                          ),
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            tooltip: 'Edit Card',
                                            icon: const Icon(Icons.edit_outlined, size: 19),
                                            color: isDark ? Colors.grey.shade300 : const Color(0xFF4A5568),
                                            onPressed: () => _editCard(card),
                                            visualDensity: VisualDensity.compact,
                                          ),
                                          IconButton(
                                            tooltip: 'Delete Card',
                                            icon: const Icon(Icons.delete_outline_rounded, size: 19),
                                            color: Colors.redAccent,
                                            onPressed: () => _deleteCard(card),
                                            visualDensity: VisualDensity.compact,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    card.question,
                                    style: const TextStyle(
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? const Color(0xFF13161F)
                                          : const Color(0xFFF7F6F3),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      card.answer,
                                      style: TextStyle(
                                        fontSize: 13,
                                        height: 1.4,
                                        color: isDark
                                            ? Colors.grey.shade300
                                            : const Color(0xFF4A5568),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: Container(
            decoration: BoxDecoration(
              gradient: AppTheme.sunsetGradient,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.sunsetCoral.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: FloatingActionButton.extended(
              onPressed: _addNewCard,
              backgroundColor: Colors.transparent,
              elevation: 0,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text(
                'Add Card',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
