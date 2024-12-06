import 'package:firebase_ex/controllers/auth_controller.dart';
import 'package:firebase_ex/controllers/todo_controller.dart';
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
            Text('환영합니다. ${authController.user.value?.email ?? '누구?'}'),
            const SizedBox(height: 20),
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
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: handleAddTodo,
                  child: const Text('추가'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Obx(() => ListView.builder(
                    itemCount: todoController.todos.length,
                    itemBuilder: (context, index) {
                      final todo = todoController.todos[index];
                      return Card(
                        child: ListTile(
                          leading: Checkbox(
                            value: todo.completed,
                            onChanged: (value) => todoController.toggleTodo(
                              todo.id,
                              value ?? false,
                            ),
                          ),
                          title: Text(
                            todo.content,
                            style: TextStyle(
                              decoration: todo.completed
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => todoController.deleteTodo(todo.id),
                          ),
                        ),
                      );
                    },
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
