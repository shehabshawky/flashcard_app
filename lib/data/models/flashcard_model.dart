import 'dart:convert';
import '../../domain/entities/flashcard_entity.dart';

class FlashcardModel extends FlashcardEntity {
  const FlashcardModel({
    required super.id,
    required super.question,
    required super.answer,
    super.category = 'General',
    required super.createdAt,
  });

  factory FlashcardModel.fromEntity(FlashcardEntity entity) {
    return FlashcardModel(
      id: entity.id,
      question: entity.question,
      answer: entity.answer,
      category: entity.category,
      createdAt: entity.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FlashcardModel.fromMap(Map<String, dynamic> map) {
    return FlashcardModel(
      id: map['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      question: map['question'] as String? ?? '',
      answer: map['answer'] as String? ?? '',
      category: map['category'] as String? ?? 'General',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory FlashcardModel.fromJson(String source) =>
      FlashcardModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
