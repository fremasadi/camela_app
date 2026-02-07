import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camela_app/app/core/repository/auth/register_repository.dart';

class RegisterController extends GetxController {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isPasswordHidden = true.obs;
  final isLoading = false.obs;

  Future<void> register() async {
    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        nameController.text.isEmpty ||
        phoneController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      Get.snackbar('Gagal', 'Semua field wajib diisi');
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar('Gagal', 'Konfirmasi password tidak cocok');
      return;
    }

    isLoading.value = true;

    final result = await RegisterRepository.register(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
      passwordConfirmation: confirmPasswordController.text.trim(),
      noTelp: phoneController.text.trim(),
    );

    isLoading.value = false;

    if (result['success']) {
      Get.snackbar('Berhasil', result['message']);
      clearFields(); // 🔹 Kosongkan semua field setelah sukses
    } else {
      Get.snackbar('Gagal', result['message']);
    }
  }

  /// 🔹 Fungsi untuk menghapus semua input field
  void clearFields() {
    nameController.clear();
    phoneController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
