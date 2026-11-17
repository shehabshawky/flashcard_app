import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/flashcard_entity.dart';

class FlashcardDialog extends StatefulWidget {
  final FlashcardEntity? existingCard;

  const FlashcardDialog({super.key, this.existingCard});

  static Future<FlashcardEntity?> show(
    BuildContext context, {
    FlashcardEntity? existingCard,
  }) {
    return showDialog<FlashcardEntity>(
      context: context,
      barrierDismissible: false,
      builder: (context) => FlashcardDialog(existingCard: existingCard),
    );
  }

  @override
  State<FlashcardDialog> createState() => _FlashcardDialogState();
}

class _FlashcardDialogState extends State<FlashcardDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _questionController;
  late TextEditingController _answerController;
  late TextEditingController _categoryController;

  bool get isEditing => widget.existingCard != null;

  @override
  void initState() {
    super.initState();
    _questionController =
        TextEditingController(text: widget.existingCard?.question ?? '');
    _answerController =
        TextEditingController(text: widget.existingCard?.answer ?? '');
    _categoryController =
        TextEditingController(text: widget.existingCard?.category ?? 'Architecture');
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final question = _questionController.text.trim();
    final answer = _answerController.text.trim();
    final category = _categoryController.text.trim().isEmpty
        ? 'General'
        : _categoryController.text.trim();

    if (isEditing) {
      final updated = widget.existingCard!.copyWith(
        question: question,
        answer: answer,
        category: category,
      );
      Navigator.of(context).pop(updated);
    } else {
      final newCard = FlashcardEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        question: question,
        answer: answer,
        category: category,
        createdAt: DateTime.now(),
      );
      Navigator.of(context).pop(newCard);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 16,
      backgroundColor: isDark ? const Color(0xFF161922) : Colors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: AppTheme.sunsetGradient,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        isEditing ? Icons.edit_note_rounded : Icons.post_add_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEditing ? 'Edit Flashcard' : 'New Flashcard',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Text(
                            isEditing
                                ? 'Update question and explanation'
                                : 'Add a new card to your study deck',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // Category field
                TextFormField(
                  controller: _categoryController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Category / Topic',
                    hintText: 'e.g. Architecture, Flutter, Biology',
                    prefixIcon: Icon(Icons.label_outline_rounded, size: 19),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Question field (Front)
                TextFormField(
                  controller: _questionController,
                  maxLines: 3,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a question';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Question (Front)',
                    hintText: 'Enter concept or question...',
                    alignLabelWithHint: true,
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(bottom: 40),
                      child: Icon(Icons.help_outline_rounded, size: 19),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Answer field (Back)
                TextFormField(
                  controller: _answerController,
                  maxLines: 3,
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter the answer';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Answer (Back)',
                    hintText: 'Enter complete answer...',
                    alignLabelWithHint: true,
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(bottom: 40),
                      child: Icon(Icons.lightbulb_outline_rounded, size: 19),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(null),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        gradient: AppTheme.sunsetGradient,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.sunsetCoral.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: FilledButton.icon(
                        onPressed: _submit,
                        icon: const Icon(Icons.check_rounded, size: 18),
                        label: Text(
                          isEditing ? 'Save Changes' : 'Create Card',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
