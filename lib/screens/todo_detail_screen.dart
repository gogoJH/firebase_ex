import 'package:firebase_ex/controllers/comment_controller.dart';
import 'package:firebase_ex/controllers/todo_controller.dart';
import 'package:firebase_ex/models/todo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class TodoDetailScreen extends StatelessWidget {
  TodoDetailScreen({super.key});

  final TodoController todoController = Get.find<TodoController>();
  final CommentController commentController = Get.find<CommentController>();
  final TextEditingController commentInputController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final TodoItem todo = Get.arguments as TodoItem;
    commentController.listenToComments(todo.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('할 일 상세'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              // 삭제 확인 다이얼로그 표시
              Get.dialog(
                AlertDialog(
                  title: const Text('할 일 삭제'),
                  content: const Text('이 할 일을 삭제하시겠습니까?'),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('취소'),
                    ),
                    TextButton(
                      onPressed: () {
                        todoController.deleteTodo(todo.id);
                        Get.back(); // 다이얼로그 닫기
                        Get.back(); // 상세 화면 닫기
                      },
                      child: const Text('삭제'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: todo.completed,
                        onChanged: (value) => todoController.toggleTodo(
                          todo.id,
                          value ?? false,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          todo.content,
                          style: TextStyle(
                            fontSize: 18,
                            decoration: todo.completed
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: commentInputController,
                    decoration: const InputDecoration(
                      hintText: '댓글을 입력하세요',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    if (commentInputController.text.isNotEmpty) {
                      commentController.addComment(commentInputController.text);
                      commentInputController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() => ListView.builder(
                  itemCount: commentController.comments.length,
                  itemBuilder: (context, index) {
                    final comment = commentController.comments[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 4.0,
                      ),
                      child: ListTile(
                        title: Text(comment.content),
                        subtitle: Text(
                          '${comment.userName} • ${DateFormat('yyyy-MM-dd HH:mm').format(comment.createdAt)}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () =>
                              commentController.deleteComment(comment.id),
                        ),
                      ),
                    );
                  },
                )),
          ),
        ],
      ),
    );
  }
}
