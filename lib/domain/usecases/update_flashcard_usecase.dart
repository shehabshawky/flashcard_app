import '../entities/flashcard_entity.dart';
import '../repositories/flashcard_repository.dart';

class UpdateFlashcardUseCase {
  final FlashcardRepository repository;

  UpdateFlashcardUseCase(this.repository);

  Future<void> call(FlashcardEntity flashcard) async {
    return await repository.updateFlashcard(flashcard);
  }
}
