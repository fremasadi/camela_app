import 'package:camela_app/app/modules/widgets/input_form_button.dart';
import 'package:camela_app/app/modules/widgets/input_text_form_field.dart';
import 'package:camela_app/app/style/app_color.dart';
import 'package:camela_app/app/style/app_font.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Camela Time',
          style: AppFont.bold(16.sp, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Masuk', style: AppFont.bold(24.sp, color: Colors.black)),
            SizedBox(height: 8.h),
            Text(
              'Masukkan email dan password Anda.',
              style: AppFont.medium(16.sp, color: AppColor.whiteGrey),
            ),
            SizedBox(height: 24.h),

            // 🔹 Email
            InputTextFormField(
              controller: controller.emailController,
              hint: 'Email',
              keyboardType: TextInputType.emailAddress,
              prefixIcon: const Icon(Icons.email_outlined),
            ),
            SizedBox(height: 16.h),

            // 🔹 Password
            InputTextFormField(
              controller: controller.passwordController,
              hint: 'Password',
              isSecureField: true,
              prefixIcon: const Icon(Icons.lock_outline),
            ),
            SizedBox(height: 24.h),

            // 🔹 Tombol login
            Obx(
              () => SizedBox(
                width: double.infinity,
                child: InputFormButton(
                  titleText: controller.isLoading.value
                      ? 'Loading...'
                      : 'Login',
                  onClick: controller.isLoading.value ? null : controller.login,
                ),
              ),
            ),

            SizedBox(height: 20.h),

            // 🔹 Link ke register
            Center(
              child: GestureDetector(
                onTap: () => controller.goToRegister(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Belum punya akun? ',
                      style: AppFont.medium(14.sp, color: AppColor.primary),
                    ),
                    Text(
                      'Daftar di sini',
                      style: AppFont.bold(14.sp, color: AppColor.primary),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
