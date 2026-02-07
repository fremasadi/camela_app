import 'package:camela_app/app/modules/profile/controllers/edit_password_controller.dart';
import 'package:camela_app/app/modules/widgets/input_form_button.dart';
import 'package:camela_app/app/modules/widgets/input_text_form_field.dart';
import 'package:camela_app/app/style/app_color.dart';
import 'package:camela_app/app/style/app_font.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

class EditPasswordView extends GetView<EditPasswordController> {
  const EditPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.greyBackground,
      appBar: AppBar(
        title: Text(
          'Edit Password',
          style: AppFont.semiBold(22.sp, color: AppColor.primary),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Buat Password Baru', style: AppFont.semiBold(16.sp)),
            SizedBox(height: 8.h),
            Text('Masukan Password Lama Anda', style: AppFont.medium(12.sp)),
            SizedBox(height: 8.h),
            InputTextFormField(
              controller: controller.oldPasswordController,
              hint: 'Password Lama',
              isSecureField: true,
              prefixIcon: const Icon(Icons.lock_outline),
            ),
            SizedBox(height: 8.h),
            Text(
              'Buat password baru,pastikan memiliki kombinasi huruf besar kecil dan angka ',
              style: AppFont.regular(12.sp),
            ),
            SizedBox(height: 8.h),
            Text('Masukan Password Baru', style: AppFont.medium(12.sp)),
            SizedBox(height: 8.h),
            InputTextFormField(
              controller: controller.newPasswordController,
              hint: 'Password Baru',
              isSecureField: true,
              prefixIcon: Icon(Icons.lock_outlined),
            ),
            SizedBox(height: 8.h),
            Text('Ulangi Password Baru', style: AppFont.medium(12.sp)),
            SizedBox(height: 8.h),
            InputTextFormField(
              controller: controller.confirmNewPasswordController,
              hint: 'Ulangi Password',
              isSecureField: true,
              prefixIcon: Icon(Icons.lock_outline),
            ),
            SizedBox(height: 12.h),
            InputFormButton(titleText: 'Simpan', color: AppColor.primary),

            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     SizedBox(width: 12.w),
            //     InputFormButton(titleText: 'Kembali'),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}
