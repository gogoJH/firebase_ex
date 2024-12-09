import 'package:cloud_firestore/cloud_firestore.dart';

class TodoItem {
  final String id;
  final String content;
  final bool completed;
  final DateTime? createdAt;
  final DateTime? lastCommentAt;

  TodoItem({
    required this.id,
    required this.content,
    required this.completed,
    this.createdAt,
    this.lastCommentAt,
  });

  factory TodoItem.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TodoItem(
      id: doc.id,
      content: data['content'] ?? '',
      completed: data['completed'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      lastCommentAt: (data['lastCommentAt'] as Timestamp?)?.toDate(),
    );
  }
}
