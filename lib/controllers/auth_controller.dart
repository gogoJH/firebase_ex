import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Rx<User?> user = Rx<User?>(null);

  @override
  void onInit() {
    super.onInit();
    user.bindStream(_auth.authStateChanges());
  }

  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      Get.snackbar('로그인 성공', '즐거운 시간 보내슈!');
      Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar('아차차!', '로그인 실패');
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      Get.snackbar('가입 성공', '로그인 해보슈');
    } catch (e) {
      Get.snackbar('아차차!', '가입 실패했네유');
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      Get.offAllNamed('/login');
      Get.snackbar('로그아웃', '다음에 또 만나요!');
    } catch (e) {
      Get.snackbar('오류', '로그아웃 실패');
    }
  }
}
