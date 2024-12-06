import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ex/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});

  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '사용자 정보',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Obx(() {
              final userInfo = authController.userAdditionalInfo.value;
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(
                        icon: Icons.email,
                        label: '이메일',
                        value: authController.user.value?.email ?? '없음',
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        icon: Icons.person,
                        label: '이름',
                        value: userInfo['name'] ?? '없음',
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        icon: Icons.cake,
                        label: '생년월일',
                        value: userInfo['birthDate'] != null
                            ? DateFormat('yyyy년 MM월 dd일').format(
                                (userInfo['birthDate'] as Timestamp).toDate())
                            : '없음',
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        icon: Icons.phone,
                        label: '전화번호',
                        value: userInfo['phone'] ?? '없음',
                      ),
                    ],
                  ),
                ),
              );
            }),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () => authController.signOut(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: const Size(200, 50),
                ),
                child: const Text(
                  '로그아웃',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blue),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 16),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
