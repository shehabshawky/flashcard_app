import '../../domain/entities/flashcard_entity.dart';
import '../../domain/repositories/flashcard_repository.dart';
import '../datasources/flashcard_local_data_source.dart';
import '../models/flashcard_model.dart';

class FlashcardRepositoryImpl implements FlashcardRepository {
  final FlashcardLocalDataSource localDataSource;

  FlashcardRepositoryImpl({required this.localDataSource});

  @override
  Future<List<FlashcardEntity>> getFlashcards() async {
    final models = await localDataSource.getFlashcards();
    return models;
  }

  @override
  Future<void> addFlashcard(FlashcardEntity flashcard) async {
    final currentList = await localDataSource.getFlashcards();
    final model = FlashcardModel.fromEntity(flashcard);
    currentList.add(model);
    await localDataSource.saveFlashcards(currentList);
  }

  @override
  Future<void> updateFlashcard(FlashcardEntity flashcard) async {
    final currentList = await localDataSource.getFlashcards();
    final index = currentList.indexWhere((c) => c.id == flashcard.id);
    if (index != -1) {
      currentList[index] = FlashcardModel.fromEntity(flashcard);
      await localDataSource.saveFlashcards(currentList);
    }
  }

  @override
  Future<void> deleteFlashcard(String id) async {
    final currentList = await localDataSource.getFlashcards();
    currentList.removeWhere((c) => c.id == id);
    await localDataSource.saveFlashcards(currentList);
  }
}
