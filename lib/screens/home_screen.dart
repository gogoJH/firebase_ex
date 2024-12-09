import 'package:firebase_ex/controllers/auth_controller.dart';
import 'package:firebase_ex/controllers/todo_controller.dart';
import 'package:firebase_ex/models/todo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final AuthController authController = Get.find<AuthController>();
  final TodoController todoController = Get.find<TodoController>();
  final TextEditingController todoInputController = TextEditingController();

  void handleAddTodo() {
    if (todoInputController.text.isNotEmpty) {
      todoController.addTodo(todoInputController.text);
      todoInputController.clear();
    }
  }

  Widget _buildTodoItem(TodoItem todo) {
    final bool hasNewComment = todo.lastCommentAt != null && 
        DateTime.now().difference(todo.lastCommentAt!) < const Duration(days: 1);

    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: Checkbox(
          value: todo.completed,
          onChanged: (value) => todoController.toggleTodo(todo.id, value ?? false),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                todo.content,
                style: TextStyle(
                  decoration:
                      todo.completed ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            if (hasNewComment)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '새 댓글',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
        onTap: () => Get.toNamed('/todo-detail', arguments: todo),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('할 일 목록'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Get.toNamed('/settings'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: todoInputController,
                    decoration: const InputDecoration(
                      hintText: '할 일을 입력하세요',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: handleAddTodo,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                if (todoController.todos.isEmpty) {
                  return const Center(
                    child: Text('할 일이 없습니다'),
                  );
                }
                return ListView.builder(
                  itemCount: todoController.todos.length,
                  itemBuilder: (context, index) {
                    final todo = todoController.todos[index];
                    return _buildTodoItem(todo);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
