import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/flashcard_local_data_source.dart';
import '../../data/repositories/flashcard_repository_impl.dart';
import '../../domain/repositories/flashcard_repository.dart';
import '../../domain/usecases/add_flashcard_usecase.dart';
import '../../domain/usecases/delete_flashcard_usecase.dart';
import '../../domain/usecases/get_flashcards_usecase.dart';
import '../../domain/usecases/update_flashcard_usecase.dart';
import '../../presentation/view_models/flashcard_view_model.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  final Map<Type, dynamic> _registry = {};

  void registerSingleton<T>(T instance) {
    _registry[T] = instance;
  }

  T get<T>() {
    final service = _registry[T];
    if (service == null) {
      throw Exception('Service of type $T is not registered in ServiceLocator');
    }
    return service as T;
  }
}

final sl = ServiceLocator();

Future<void> initDependencies({SharedPreferences? mockPrefs}) async {
  // External
  final prefs = mockPrefs ?? await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);

  // Data Sources
  final localDataSource = FlashcardLocalDataSourceImpl(sharedPreferences: sl.get<SharedPreferences>());
  sl.registerSingleton<FlashcardLocalDataSource>(localDataSource);

  // Repositories
  final repository = FlashcardRepositoryImpl(localDataSource: sl.get<FlashcardLocalDataSource>());
  sl.registerSingleton<FlashcardRepository>(repository);

  // Use Cases
  sl.registerSingleton<GetFlashcardsUseCase>(GetFlashcardsUseCase(sl.get<FlashcardRepository>()));
  sl.registerSingleton<AddFlashcardUseCase>(AddFlashcardUseCase(sl.get<FlashcardRepository>()));
  sl.registerSingleton<UpdateFlashcardUseCase>(UpdateFlashcardUseCase(sl.get<FlashcardRepository>()));
  sl.registerSingleton<DeleteFlashcardUseCase>(DeleteFlashcardUseCase(sl.get<FlashcardRepository>()));

  // View Models
  final viewModel = FlashcardViewModel(
    getFlashcardsUseCase: sl.get<GetFlashcardsUseCase>(),
    addFlashcardUseCase: sl.get<AddFlashcardUseCase>(),
    updateFlashcardUseCase: sl.get<UpdateFlashcardUseCase>(),
    deleteFlashcardUseCase: sl.get<DeleteFlashcardUseCase>(),
  );
  sl.registerSingleton<FlashcardViewModel>(viewModel);
}
