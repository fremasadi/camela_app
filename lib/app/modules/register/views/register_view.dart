import 'package:camela_app/app/modules/widgets/input_form_button.dart';
import 'package:camela_app/app/modules/widgets/input_text_form_field.dart';
import 'package:camela_app/app/style/app_color.dart';
import 'package:camela_app/app/style/app_font.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/register_controller.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pendaftaran',
              style: AppFont.bold(24.sp, color: Colors.black),
            ),
            SizedBox(height: 4.h),
            Text(
              'Masukan data diri Anda untuk membuat akun.',
              style: AppFont.medium(16.sp, color: AppColor.whiteGrey),
            ),
            SizedBox(height: 20.h),

            // 🔹 Nama Lengkap
            InputTextFormField(
              controller: controller.nameController,
              hint: 'Nama Lengkap',
              keyboardType: TextInputType.name,
            ),
            SizedBox(height: 15.h),

            // 🔹 Nomor Telepon
            InputTextFormField(
              controller: controller.phoneController,
              hint: 'Nomor Telepon',
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 15.h),

            // 🔹 Email
            InputTextFormField(
              controller: controller.emailController,
              hint: 'Email',
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 15.h),

            // 🔹 Password
            InputTextFormField(
              controller: controller.passwordController,
              hint: 'Password',
              isSecureField: true,
            ),
            SizedBox(height: 15.h),

            // 🔹 Konfirmasi Password
            InputTextFormField(
              controller: controller.confirmPasswordController,
              hint: 'Konfirmasi Password',
              isSecureField: true,
            ),
            SizedBox(height: 25.h),

            // 🔹 Tombol Daftar
            Obx(
              () => SizedBox(
                width: double.infinity,
                child: InputFormButton(
                  titleText: controller.isLoading.value
                      ? 'Loading...'
                      : 'Daftar',
                  onClick: controller.isLoading.value
                      ? () {}
                      : controller.register,
                  color: AppColor.primary,
                  titleColor: Colors.white,
                ),
              ),
            ),

            SizedBox(height: 20.h),
            Center(
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Text(
                  'Sudah punya akun? Login',
                  style: AppFont.medium(14.sp, color: AppColor.primary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
