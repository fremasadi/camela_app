import 'package:camela_app/app/modules/widgets/input_form_button.dart';
import 'package:camela_app/app/routes/app_pages.dart';
import 'package:camela_app/app/style/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../style/app_font.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        // 🔹 State 1: Sedang cek token → tampilkan logo saja
        if (controller.isChecking.value) {
          return Center(
            child: Padding(
              padding: EdgeInsets.only(top: ScreenUtil().statusBarHeight),
              child: Image.asset(
                'assets/images/camela.png',
                width: 250.w,
                height: 250.h,
                fit: BoxFit.contain,
              ),
            ),
          );
        }

        // 🔹 State 2: Token tidak ada → tampilkan UI welcome
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: ScreenUtil().statusBarHeight,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'CamelaSalon',
                  style: AppFont.bold(16.sp, color: Colors.black),
                ),
                Center(
                  child: Image.asset(
                    'assets/images/camela.png',
                    width: 350.w,
                    height: 400.h,
                  ),
                ),
                Text(
                  'Selamat Datang di\nCamella Beauty Salon',
                  style: AppFont.bold(28.sp, color: Colors.black),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10.h),
                Text(
                  'Ikuti langkah-langkah untuk\nmenjadwalkan reservasi Anda.',
                  style: AppFont.medium(16.sp, color: AppColor.whiteGrey),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0.sp),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: InputFormButton(
                          onClick: () => Get.toNamed(Routes.REGISTER),
                          titleText: 'Register',
                          color: Colors.white,
                          titleColor: AppColor.primary,
                        ),
                      ),
                      SizedBox(width: 15.w),
                      Expanded(
                        child: InputFormButton(
                          onClick: () => Get.toNamed(Routes.LOGIN),
                          titleText: 'Login',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
