import 'package:cloud_firestore/cloud_firestore.dart';

class TodoItem {
  final String id;
  final String content;
  final bool completed;
  final DateTime? createdAt;

  TodoItem({
    required this.id,
    required this.content,
    required this.completed,
    this.createdAt,
  });

  factory TodoItem.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TodoItem(
      id: doc.id,
      content: data['content'] ?? '',
      completed: data['completed'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
