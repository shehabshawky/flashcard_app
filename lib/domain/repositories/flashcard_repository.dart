import '../entities/flashcard_entity.dart';

abstract class FlashcardRepository {
  Future<List<FlashcardEntity>> getFlashcards();
  Future<void> addFlashcard(FlashcardEntity flashcard);
  Future<void> updateFlashcard(FlashcardEntity flashcard);
  Future<void> deleteFlashcard(String id);
}
