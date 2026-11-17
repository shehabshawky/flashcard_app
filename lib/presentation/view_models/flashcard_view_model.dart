import 'package:flutter/foundation.dart';
import '../../domain/entities/flashcard_entity.dart';
import '../../domain/usecases/add_flashcard_usecase.dart';
import '../../domain/usecases/delete_flashcard_usecase.dart';
import '../../domain/usecases/get_flashcards_usecase.dart';
import '../../domain/usecases/update_flashcard_usecase.dart';

class FlashcardViewModel extends ChangeNotifier {
  final GetFlashcardsUseCase _getFlashcardsUseCase;
  final AddFlashcardUseCase _addFlashcardUseCase;
  final UpdateFlashcardUseCase _updateFlashcardUseCase;
  final DeleteFlashcardUseCase _deleteFlashcardUseCase;

  FlashcardViewModel({
    required this._getFlashcardsUseCase,
    required this._addFlashcardUseCase,
    required this._updateFlashcardUseCase,
    required this._deleteFlashcardUseCase,
  });

  List<FlashcardEntity> _cards = [];
  int _currentIndex = 0;
  bool _isLoading = false;
  String? _errorMessage;

  List<FlashcardEntity> get cards => List.unmodifiable(_cards);
  int get currentIndex => _currentIndex;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get hasCards => _cards.isNotEmpty;
  int get totalCards => _cards.length;

  FlashcardEntity? get currentCard {
    if (_cards.isEmpty || _currentIndex < 0 || _currentIndex >= _cards.length) {
      return null;
    }
    return _cards[_currentIndex];
  }

  bool get canGoNext => _currentIndex < _cards.length - 1;
  bool get canGoPrevious => _currentIndex > 0;

  double get progressPercentage {
    if (_cards.isEmpty) return 0.0;
    return (_currentIndex + 1) / _cards.length;
  }

  Future<void> loadCards() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _cards = await _getFlashcardsUseCase();
      _currentIndex = 0;
    } catch (e) {
      _errorMessage = 'Failed to load flashcards: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void nextCard() {
    if (canGoNext) {
      _currentIndex++;
      notifyListeners();
    }
  }

  void previousCard() {
    if (canGoPrevious) {
      _currentIndex--;
      notifyListeners();
    }
  }

  void shuffleCards() {
    if (_cards.length <= 1) return;
    final shuffled = List<FlashcardEntity>.from(_cards)..shuffle();
    _cards = shuffled;
    _currentIndex = 0;
    notifyListeners();
  }

  Future<void> addCard(FlashcardEntity newCard) async {
    try {
      await _addFlashcardUseCase(newCard);
      _cards = List<FlashcardEntity>.from(_cards)..add(newCard);
      _currentIndex = _cards.length - 1;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to add flashcard: $e';
      notifyListeners();
    }
  }

  Future<void> updateCard(FlashcardEntity updatedCard) async {
    try {
      await _updateFlashcardUseCase(updatedCard);
      final index = _cards.indexWhere((c) => c.id == updatedCard.id);
      if (index != -1) {
        final updatedList = List<FlashcardEntity>.from(_cards);
        updatedList[index] = updatedCard;
        _cards = updatedList;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to update flashcard: $e';
      notifyListeners();
    }
  }

  Future<void> deleteCard(String id) async {
    try {
      await _deleteFlashcardUseCase(id);
      final updatedList = List<FlashcardEntity>.from(_cards)
        ..removeWhere((c) => c.id == id);
      _cards = updatedList;
      if (_currentIndex >= _cards.length && _cards.isNotEmpty) {
        _currentIndex = _cards.length - 1;
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete flashcard: $e';
      notifyListeners();
    }
  }

  Future<void> deleteCurrentCard() async {
    final current = currentCard;
    if (current != null) {
      await deleteCard(current.id);
    }
  }
}
