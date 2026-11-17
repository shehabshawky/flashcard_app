class FlashcardEntity {
  final String id;
  final String question;
  final String answer;
  final String category;
  final DateTime createdAt;

  const FlashcardEntity({
    required this.id,
    required this.question,
    required this.answer,
    this.category = 'General',
    required this.createdAt,
  });

  FlashcardEntity copyWith({
    String? id,
    String? question,
    String? answer,
    String? category,
    DateTime? createdAt,
  }) {
    return FlashcardEntity(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FlashcardEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
