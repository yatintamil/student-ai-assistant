import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/knowledge_entity.dart';

class KnowledgeModel {
  const KnowledgeModel({
    required this.id,
    required this.title,
    required this.content,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  factory KnowledgeModel.fromEntity(KnowledgeEntity entity) {
    return KnowledgeModel(
      id: entity.id,
      title: entity.title,
      content: entity.content,
      tags: entity.tags,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  factory KnowledgeModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return KnowledgeModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      content: data['content'] as String? ?? '',
      tags: List<String>.from(data['tags'] as List<dynamic>? ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  final String id;
  final String title;
  final String content;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'tags': tags,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  KnowledgeEntity toEntity() {
    return KnowledgeEntity(
      id: id,
      title: title,
      content: content,
      tags: tags,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
