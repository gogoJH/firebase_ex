import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Rx<User?> user = Rx<User?>(null);

  // 사용자 추가 정보를 저장할 변수
  final Rx<Map<String, dynamic>> userAdditionalInfo =
      Rx<Map<String, dynamic>>({});

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
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
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
    } catch (e) {
      print('회원가입 실패: $e');
      Get.snackbar('아차차!', '가입 실패했네유');
    }
  }

  Future<void> _loadUserInfo() async {
    if (user.value != null) {
      try {
        final doc =
            await _firestore.collection('users').doc(user.value!.uid).get();
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

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      await _loadUserInfo();
      Get.offAllNamed('/home');
      Get.snackbar('로그인 성공', '구글 계정으로 로그인했습니다!');
    } catch (e) {
      print('Google 로그인 실패: $e');
      Get.snackbar('오류', '구글 로그인에 실패했습니다');
    }
  }

  Future<void> signInAnonymously() async {
    try {
      UserCredential userCredential = await _auth.signInAnonymously();
      Get.offAllNamed('/home');
      Get.snackbar('로그인 성공', '익명으로 로그인했습니다!');
    } catch (e) {
      print('익명 로그인 실패: $e');
      Get.snackbar('오류', '익명 로그인에 실패했습니다');
    }
  }
}
