import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ex/controllers/auth_controller.dart';
import 'package:firebase_ex/controllers/todo_controller.dart';
import 'package:firebase_ex/firebase_options.dart';
import 'package:firebase_ex/screens/home_screen.dart';
import 'package:firebase_ex/screens/login_screen.dart';
import 'package:firebase_ex/screens/signup_screen.dart';
import 'package:firebase_ex/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() async {
  // Flutter 바인딩 초기화 추가
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Get.put(AuthController());
  Get.put(TodoController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Login app',
      initialRoute: '/login',
      getPages: [
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/signup', page: () => SignupScreen()),
        GetPage(name: '/home', page: () => HomeScreen()),
        GetPage(name: '/settings', page: () => SettingsScreen()),
      ],
    );
  }
}
