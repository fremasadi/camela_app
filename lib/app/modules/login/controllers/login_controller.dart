import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camela_app/app/core/repository/auth/login_repository.dart';
import 'package:camela_app/app/routes/app_pages.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final isLoading = false.obs;
  final isPasswordHidden = true.obs;

  void login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar('Error', 'Email dan password wajib diisi');
      return;
    }

    isLoading.value = true;
    final result = await LoginRepository.login(
      email: email,
      password: password,
    );
    isLoading.value = false;

    if (result['success'] == true) {
      Get.snackbar('Berhasil', result['message']);
      Get.offAllNamed(Routes.BASE); // langsung ke home setelah login
    } else {
      Get.snackbar('Gagal', result['message']);
    }
  }

  void goToRegister() => Get.toNamed(Routes.REGISTER);

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
