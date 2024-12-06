import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ex/models/todo.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TodoController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final RxList<TodoItem> todos = <TodoItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    _listenToTodos();
  }

  void _listenToTodos() {
    if (_auth.currentUser != null) {
      _firestore
          .collection('todos')
          .where('userId', isEqualTo: _auth.currentUser!.uid)
          .snapshots()
          .listen((snapshot) {
        todos.value =
            snapshot.docs.map((doc) => TodoItem.fromDocument(doc)).toList();
      });
    }
  }

  Future<void> addTodo(String content) async {
    if (_auth.currentUser == null) return;

    await _firestore.collection('todos').add({
      'content': content,
      'userId': _auth.currentUser!.uid,
      'createdAt': FieldValue.serverTimestamp(),
      'completed': false,
    });
  }

  Future<void> deleteTodo(String todoId) async {
    await _firestore.collection('todos').doc(todoId).delete();
  }

  Future<void> toggleTodo(String todoId, bool completed) async {
    await _firestore.collection('todos').doc(todoId).update({
      'completed': completed,
    });
  }
}
