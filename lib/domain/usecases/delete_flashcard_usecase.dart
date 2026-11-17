import '../repositories/flashcard_repository.dart';

class DeleteFlashcardUseCase {
  final FlashcardRepository repository;

  DeleteFlashcardUseCase(this.repository);

  Future<void> call(String id) async {
    return await repository.deleteFlashcard(id);
  }
}
