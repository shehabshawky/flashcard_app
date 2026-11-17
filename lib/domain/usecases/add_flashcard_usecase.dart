import '../entities/flashcard_entity.dart';
import '../repositories/flashcard_repository.dart';

class AddFlashcardUseCase {
  final FlashcardRepository repository;

  AddFlashcardUseCase(this.repository);

  Future<void> call(FlashcardEntity flashcard) async {
    return await repository.addFlashcard(flashcard);
  }
}
