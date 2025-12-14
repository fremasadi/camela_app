import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../style/app_color.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        centerTitle: true,
        backgroundColor: AppColor.primary,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        final user = controller.userData.value;

        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 45,
                  backgroundColor: AppColor.primary.withOpacity(0.2),
                  child: Icon(Icons.person, size: 50, color: AppColor.primary),
                ),
              ),
              const SizedBox(height: 20),

              // 🔹 Nama
              Text(
                user['name'] ?? 'Tanpa Nama',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // 🔹 Email
              Row(
                children: [
                  const Icon(Icons.email_outlined, size: 20),
                  const SizedBox(width: 8),
                  Text(user['email'] ?? '-'),
                ],
              ),
              const SizedBox(height: 8),

              // 🔹 Nomor Telepon
              Row(
                children: [
                  const Icon(Icons.phone_outlined, size: 20),
                  const SizedBox(width: 8),
                  Text(user['no_telp'] ?? '-'),
                ],
              ),
              const SizedBox(height: 8),

              // 🔹 Role
              Row(
                children: [
                  const Icon(Icons.badge_outlined, size: 20),
                  const SizedBox(width: 8),
                  Text((user['role'] ?? 'unknown').toString().capitalize ?? ''),
                ],
              ),

              const Spacer(),

              // 🔹 Tombol Logout
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: controller.logout,
                  child: const Text(
                    'Logout',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
