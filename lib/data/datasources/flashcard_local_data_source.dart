import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/flashcard_model.dart';

abstract class FlashcardLocalDataSource {
  Future<List<FlashcardModel>> getFlashcards();
  Future<void> saveFlashcards(List<FlashcardModel> cards);
}

class FlashcardLocalDataSourceImpl implements FlashcardLocalDataSource {
  static const String _storageKey = 'flashcards_collection_clean_v1';
  final SharedPreferences sharedPreferences;

  FlashcardLocalDataSourceImpl({required this.sharedPreferences});

  static final List<FlashcardModel> _defaultSeedCards = [
    FlashcardModel(
      id: 'clean_1',
      question: 'What is Clean Architecture?',
      answer: 'A software design philosophy by Uncle Bob separating code into concentric layers (Domain, Data, Presentation) to keep business rules independent of frameworks, UI, and databases.',
      category: 'Architecture',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
    FlashcardModel(
      id: 'clean_2',
      question: 'What is the role of the Domain Layer?',
      answer: 'It represents the core business logic and rules of the app, containing pure Entities and Use Cases, completely independent of external packages or Flutter UI.',
      category: 'Architecture',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    FlashcardModel(
      id: 'clean_3',
      question: 'What is the purpose of the Repository Pattern?',
      answer: 'It acts as an abstraction between Domain and Data layers, providing a clean API for the domain while hiding data sources (local DB, cache, or remote APIs).',
      category: 'Design Patterns',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    FlashcardModel(
      id: 'clean_4',
      question: 'What is the difference between an Entity and a Model?',
      answer: 'An Entity contains pure business data and logic. A Model extends the Entity to add serialization (JSON parsing, database mapping).',
      category: 'Architecture',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    FlashcardModel(
      id: 'clean_5',
      question: 'Why use ViewModels or Notifiers in the Presentation Layer?',
      answer: 'To manage UI state and user interactions cleanly, keeping Widgets dumb and testable while exposing reactive state changes to the UI.',
      category: 'Presentation',
      createdAt: DateTime.now(),
    ),
  ];

  @override
  Future<List<FlashcardModel>> getFlashcards() async {
    final String? jsonString = sharedPreferences.getString(_storageKey);

    if (jsonString == null || jsonString.isEmpty) {
      await saveFlashcards(_defaultSeedCards);
      return List<FlashcardModel>.from(_defaultSeedCards);
    }

    try {
      final List<dynamic> decodedList = json.decode(jsonString) as List<dynamic>;
      return decodedList
          .map((item) => FlashcardModel.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return List<FlashcardModel>.from(_defaultSeedCards);
    }
  }

  @override
  Future<void> saveFlashcards(List<FlashcardModel> cards) async {
    final rawList = cards.map((card) => card.toMap()).toList();
    await sharedPreferences.setString(_storageKey, json.encode(rawList));
  }
}
