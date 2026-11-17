import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flashcard_app/core/di/service_locator.dart';
import 'package:flashcard_app/domain/entities/flashcard_entity.dart';
import 'package:flashcard_app/presentation/view_models/flashcard_view_model.dart';

void main() {
  late FlashcardViewModel viewModel;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await initDependencies();
    viewModel = sl.get<FlashcardViewModel>();
  });

  group('FlashcardViewModel Clean Architecture Tests', () {
    test('initial state loads seed cards', () async {
      await viewModel.loadCards();

      expect(viewModel.hasCards, isTrue);
      expect(viewModel.totalCards, equals(5));
      expect(viewModel.currentIndex, equals(0));
      expect(viewModel.currentCard, isNotNull);
      expect(viewModel.canGoPrevious, isFalse);
      expect(viewModel.canGoNext, isTrue);
    });

    test('navigation next and previous works correctly', () async {
      await viewModel.loadCards();

      viewModel.nextCard();
      expect(viewModel.currentIndex, equals(1));
      expect(viewModel.canGoPrevious, isTrue);

      viewModel.previousCard();
      expect(viewModel.currentIndex, equals(0));
    });

    test('addCard appends new flashcard and updates current index', () async {
      await viewModel.loadCards();

      final newCard = FlashcardEntity(
        id: 'test_card_1',
        question: 'What is TDD?',
        answer: 'Test-Driven Development',
        category: 'Testing',
        createdAt: DateTime.now(),
      );

      await viewModel.addCard(newCard);

      expect(viewModel.totalCards, equals(6));
      expect(viewModel.currentCard?.question, equals('What is TDD?'));
      expect(viewModel.currentIndex, equals(5));
    });

    test('updateCard updates existing card data', () async {
      await viewModel.loadCards();
      final firstCard = viewModel.currentCard!;

      final updated = firstCard.copyWith(question: 'Updated Question');
      await viewModel.updateCard(updated);

      expect(viewModel.currentCard?.question, equals('Updated Question'));
    });

    test('deleteCard removes card from collection', () async {
      await viewModel.loadCards();
      final initialCount = viewModel.totalCards;
      final firstId = viewModel.currentCard!.id;

      await viewModel.deleteCard(firstId);

      expect(viewModel.totalCards, equals(initialCount - 1));
      expect(viewModel.cards.any((c) => c.id == firstId), isFalse);
    });
  });
}
