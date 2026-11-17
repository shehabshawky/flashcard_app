import '../entities/flashcard_entity.dart';
import '../repositories/flashcard_repository.dart';

class GetFlashcardsUseCase {
  final FlashcardRepository repository;

  GetFlashcardsUseCase(this.repository);

  Future<List<FlashcardEntity>> call() async {
    return await repository.getFlashcards();
  }
}
