import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Rx<User?> user = Rx<User?>(null);

  // 사용자 추가 정보를 저장할 변수
  final Rx<Map<String, dynamic>> userAdditionalInfo = Rx<Map<String, dynamic>>({});

  @override
  void onInit() {
    super.onInit();
    user.bindStream(_auth.authStateChanges());
  }

  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      await _loadUserInfo();
      Get.snackbar('로그인 성공', '즐거운 시간 보내슈!');
      Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar('아차차!', '로그인 실패');
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required DateTime birthDate,
    required String phone,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'birthDate': Timestamp.fromDate(birthDate),
        'phone': phone,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      Get.snackbar('가입 성공', '로그인 해보슈');
      Get.offAllNamed('/login');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        Get.snackbar(
          '회원가입 실패',
          '이미 사용 중인 이메일입니다. 다른 이메일을 사용해주세요.',
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red.withOpacity(0.2),
        );
      } else if (e.code == 'weak-password') {
        Get.snackbar(
          '회원가입 실패',
          '비밀번호가 너무 약합니다. 더 강력한 비밀번호를 사용해주세요.',
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red.withOpacity(0.2),
        );
      } else if (e.code == 'invalid-email') {
        Get.snackbar(
          '회원가입 실패',
          '유효하지 않은 이메일 형식입니다.',
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red.withOpacity(0.2),
        );
      } else {
        Get.snackbar(
          '회원가입 실패',
          '회원가입 중 오류가 발생했습니다.',
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red.withOpacity(0.2),
        );
      }
      print('회원가입 실패: ${e.code}');
    } catch (e) {
      Get.snackbar(
        '오류',
        '알 수 없는 오류가 발생했습니다.',
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red.withOpacity(0.2),
      );
      print('기타 오류: $e');
    }
  }

  Future<void> _loadUserInfo() async {
    if (user.value != null) {
      try {
        final doc = await _firestore.collection('users').doc(user.value!.uid).get();
        if (doc.exists) {
          userAdditionalInfo.value = doc.data() ?? {};
        }
      } catch (e) {
        print('사용자 정보 로드 실패: $e');
      }
    } else {
      userAdditionalInfo.value = {};
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      userAdditionalInfo.value = {};
      Get.offAllNamed('/login');
      Get.snackbar('로그아웃', '다음에 또 만나요!');
    } catch (e) {
      Get.snackbar('오류', '로그아웃 실패');
    }
  }
}
