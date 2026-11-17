import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/flashcard_entity.dart';
import '../view_models/flashcard_view_model.dart';
import '../widgets/flip_card_widget.dart';
import '../widgets/flashcard_dialog.dart';
import 'manage_cards_view.dart';

class StudyView extends StatefulWidget {
  final FlashcardViewModel viewModel;

  const StudyView({super.key, required this.viewModel});

  @override
  State<StudyView> createState() => _StudyViewState();
}

class _StudyViewState extends State<StudyView> {
  final GlobalKey<FlipCardWidgetState> _flipCardKey = GlobalKey<FlipCardWidgetState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.viewModel.hasCards && !widget.viewModel.isLoading) {
        widget.viewModel.loadCards();
      }
    });
  }

  void _onShuffle() {
    widget.viewModel.shuffleCards();
    _flipCardKey.currentState?.resetCard();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.shuffle_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Deck shuffled successfully!'),
          ],
        ),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.sunsetCoral,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _addCard() async {
    final newCard = await FlashcardDialog.show(context);
    if (newCard != null) {
      await widget.viewModel.addCard(newCard);
      _flipCardKey.currentState?.resetCard();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('New flashcard added to deck!'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppTheme.sunsetCoral,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Future<void> _editCurrentCard(FlashcardEntity currentCard) async {
    final updatedCard = await FlashcardDialog.show(
      context,
      existingCard: currentCard,
    );

    if (updatedCard != null) {
      await widget.viewModel.updateCard(updatedCard);
      _flipCardKey.currentState?.resetCard();
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

  Future<void> _deleteCurrentCard(FlashcardEntity currentCard) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Flashcard?'),
        content: Text('Are you sure you want to delete:\n"${currentCard.question}"?'),
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
      await widget.viewModel.deleteCard(currentCard.id);
      _flipCardKey.currentState?.resetCard();
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

  void _openManageCards() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ManageCardsView(viewModel: widget.viewModel),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        if (widget.viewModel.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppTheme.sunsetCoral),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    gradient: AppTheme.sunsetGradient,
                    borderRadius: BorderRadius.circular(11),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.sunsetCoral.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 19),
                ),
                const SizedBox(width: 10),
                const Text(
                  'FlashStudy',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(width: 7),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.sunsetCoral.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppTheme.sunsetCoral.withValues(alpha: 0.2),
                    ),
                  ),
                  child: const Text(
                    'PRO',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.sunsetCoral,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'Shuffle deck',
                icon: const Icon(Icons.shuffle_rounded),
                onPressed: widget.viewModel.totalCards > 1 ? _onShuffle : null,
              ),
              IconButton(
                tooltip: 'Manage deck',
                icon: const Icon(Icons.style_outlined),
                onPressed: _openManageCards,
              ),
              IconButton(
                tooltip: 'Add new flashcard',
                icon: const Icon(Icons.add_circle_outline_rounded),
                onPressed: _addCard,
              ),
            ],
          ),
          body: !widget.viewModel.hasCards
              ? _buildEmptyState(theme, isDark)
              : _buildStudyContent(theme, isDark),
        );
      },
    );
  }

  Widget _buildEmptyState(ThemeData theme, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                gradient: AppTheme.sunsetGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.sunsetCoral.withValues(alpha: 0.25),
                    blurRadius: 25,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_stories_rounded,
                size: 52,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Your Deck is Empty',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your customized flashcards or reload default questions to start learning.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 28),
            Container(
              decoration: BoxDecoration(
                gradient: AppTheme.sunsetGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.sunsetCoral.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: FilledButton.icon(
                onPressed: _addCard,
                icon: const Icon(Icons.add_rounded),
                label: const Text(
                  'Add First Flashcard',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => widget.viewModel.loadCards(),
              child: const Text(
                'Reload Default Cards',
                style: TextStyle(
                  color: AppTheme.sunsetCoral,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudyContent(ThemeData theme, bool isDark) {
    final currentCard = widget.viewModel.currentCard;
    if (currentCard == null) return const SizedBox.shrink();

    final currentIndex = widget.viewModel.currentIndex;
    final totalCards = widget.viewModel.totalCards;
    final progress = widget.viewModel.progressPercentage;

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 580),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Progress & Mastered Pill
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${currentIndex + 1} / $totalCards',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '·  ${(progress * 100).toInt()}% completed',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.warmAmber.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.warmAmber.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Text(
                        'Card ${currentIndex + 1}',
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.warmAmber,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Sleek Sunset Linear Progress Bar
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E2230)
                        : const Color(0xFFEDECE8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppTheme.sunsetGradient,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.sunsetCoral.withValues(alpha: 0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Flip Card with Swipe Gesture Support
                Expanded(
                  child: GestureDetector(
                    onHorizontalDragEnd: (details) {
                      if (details.primaryVelocity != null) {
                        if (details.primaryVelocity! < -200) {
                          widget.viewModel.nextCard();
                        } else if (details.primaryVelocity! > 200) {
                          widget.viewModel.previousCard();
                        }
                      }
                    },
                    child: FlipCardWidget(
                      key: _flipCardKey,
                      flashcard: currentCard,
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Modern Navigation Dock (Previous & Next)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: widget.viewModel.canGoPrevious
                            ? widget.viewModel.previousCard
                            : null,
                        icon: const Icon(Icons.arrow_back_rounded, size: 18),
                        label: const Text(
                          'Previous',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark ? Colors.white : const Color(0xFF262C3D),
                          side: BorderSide(
                            color: isDark
                                ? const Color(0xFF2E3547)
                                : const Color(0xFFE2E0DB),
                            width: 1.3,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: widget.viewModel.canGoNext
                              ? AppTheme.sunsetGradient
                              : null,
                          color: widget.viewModel.canGoNext
                              ? null
                              : (isDark ? const Color(0xFF202534) : const Color(0xFFEDECE8)),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: widget.viewModel.canGoNext
                              ? [
                                  BoxShadow(
                                    color: AppTheme.sunsetCoral.withValues(alpha: 0.35),
                                    blurRadius: 14,
                                    offset: const Offset(0, 5),
                                  ),
                                ]
                              : null,
                        ),
                        child: FilledButton.icon(
                          onPressed: widget.viewModel.canGoNext
                              ? widget.viewModel.nextCard
                              : null,
                          icon: const Text(
                            'Next',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                          ),
                          label: const Icon(Icons.arrow_forward_rounded, size: 18),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            disabledBackgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            disabledForegroundColor: isDark
                                ? Colors.grey.shade600
                                : Colors.grey.shade400,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Sleek Micro Toolbar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF151822)
                        : const Color(0xFFF3F1EC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF242A3B)
                          : const Color(0xFFE6E3DC),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed: () => _flipCardKey.currentState?.toggleCard(),
                        icon: const Icon(
                          Icons.sync_rounded,
                          size: 17,
                          color: AppTheme.sunsetCoral,
                        ),
                        label: const Text(
                          'Flip Card',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.sunsetCoral,
                            fontSize: 12.5,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Edit this card',
                            icon: const Icon(Icons.edit_outlined, size: 19),
                            onPressed: () => _editCurrentCard(currentCard),
                            visualDensity: VisualDensity.compact,
                          ),
                          IconButton(
                            tooltip: 'Delete this card',
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              size: 19,
                              color: Colors.redAccent,
                            ),
                            onPressed: () => _deleteCurrentCard(currentCard),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
