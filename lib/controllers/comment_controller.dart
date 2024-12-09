import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../models/comment.dart';

class CommentController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 현재 선택된 todo의 댓글들을 저장
  final RxList<Comment> comments = <Comment>[].obs;

  // 현재 선택된 todo의 ID
  final RxString selectedTodoId = ''.obs;

  void listenToComments(String todoId) {
    selectedTodoId.value = todoId;
    _firestore
        .collection('comments')
        .where('todoId', isEqualTo: todoId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .listen((snapshot) {
      try {
        comments.value =
            snapshot.docs.map((doc) => Comment.fromDocument(doc)).toList();
      } catch (e) {
        print('댓글 변환 오류: $e');
        comments.value = [];
      }
    });
  }

  Future<void> addComment(String content) async {
    if (_auth.currentUser == null || selectedTodoId.isEmpty) return;

    final userName = _auth.currentUser!.displayName ?? '익명';

    // 트랜잭션으로 댓글 추가와 Todo 업데이트를 동시에 처리
    await _firestore.runTransaction((transaction) async {
      // 1. 새 댓글 문서 생성
      final commentRef = _firestore.collection('comments').doc();
      transaction.set(commentRef, {
        'todoId': selectedTodoId.value,
        'userId': _auth.currentUser!.uid,
        'userName': userName,
        'content': content,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 2. Todo 문서 업데이트
      final todoRef = _firestore.collection('todos').doc(selectedTodoId.value);
      transaction.update(todoRef, {
        'lastCommentAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> deleteComment(String commentId) async {
    if (_auth.currentUser == null) return;

    final comment =
        await _firestore.collection('comments').doc(commentId).get();
    if (comment.data()?['userId'] == _auth.currentUser!.uid) {
      await _firestore.collection('comments').doc(commentId).delete();
    }
  }
}
