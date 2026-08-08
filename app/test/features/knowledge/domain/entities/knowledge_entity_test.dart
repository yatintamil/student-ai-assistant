import 'package:flutter_test/flutter_test.dart';
import 'package:student_ai_assistant/features/knowledge/domain/entities/knowledge_entity.dart';

void main() {
  group('KnowledgeEntity', () {
    test('supports value equality and copyWith', () {
      final now = DateTime.now();
      final k1 = KnowledgeEntity(
        id: 'k1',
        title: 'Life OS Architecture',
        content: 'Clean Architecture with Riverpod & Gemini AI',
        tags: const ['AI', 'Flutter'],
        createdAt: now,
        updatedAt: now,
      );

      final k2 = KnowledgeEntity(
        id: 'k1',
        title: 'Life OS Architecture',
        content: 'Clean Architecture with Riverpod & Gemini AI',
        tags: const ['AI', 'Flutter'],
        createdAt: now,
        updatedAt: now,
      );

      expect(k1, equals(k2));

      final updated = k1.copyWith(title: 'Updated Architecture');
      expect(updated.title, equals('Updated Architecture'));
      expect(updated.id, equals('k1'));
    });
  });
}
