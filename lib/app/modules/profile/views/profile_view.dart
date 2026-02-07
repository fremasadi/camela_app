import 'package:camela_app/app/modules/profile/views/edit_password_view.dart';
import 'package:camela_app/app/modules/profile/views/edit_profile_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../style/app_color.dart';
import '../../../style/app_font.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        final user = controller.userData.value;

        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.h,
                  vertical: 14.sp,
                ),
                child: Text(
                  'Profile Anda',
                  style: AppFont.bold(18.sp, color: AppColor.primary),
                ),
              ),
              Container(
                padding: EdgeInsets.all(16.sp),
                margin: EdgeInsets.symmetric(horizontal: 16.sp),
                decoration: BoxDecoration(
                  color: AppColor.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColor.primary),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40.r,
                      child: Center(child: Icon(Icons.person, size: 30.sp)),
                    ),
                    SizedBox(width: 16.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🔹 Nama
                        Text(
                          user['name'] ?? 'Tanpa Nama',
                          style: AppFont.bold(16.sp, color: AppColor.primary),
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
                            Text(
                              (user['role'] ?? 'unknown')
                                      .toString()
                                      .capitalize ??
                                  '',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.all(16.sp),
                padding: EdgeInsets.all(16.sp),
                decoration: BoxDecoration(
                  color: AppColor.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColor.primary),
                ),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Get.to(EditProfileView());
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.person,
                            size: 22.sp,
                            color: AppColor.primary,
                          ),
                          SizedBox(width: 12.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ubah Profile',
                                style: AppFont.semiBold(
                                  14.sp,
                                  color: AppColor.primary,
                                ),
                              ),
                              Text(
                                'Perbarui Profile Anda',
                                style: AppFont.regular(12.sp),
                              ),
                            ],
                          ),
                          Spacer(),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16.sp,
                            color: AppColor.primary,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12.h),
                    GestureDetector(
                      onTap: () {
                        Get.to(EditPasswordView());
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.password,
                            size: 22.sp,
                            color: AppColor.primary,
                          ),
                          SizedBox(width: 12.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ubah password',
                                style: AppFont.semiBold(
                                  14.sp,
                                  color: AppColor.primary,
                                ),
                              ),
                              Text(
                                'Ubah password anda',
                                style: AppFont.regular(12.sp),
                              ),
                            ],
                          ),
                          Spacer(),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16.sp,
                            color: AppColor.primary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  controller.logout();
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 16.sp),
                  padding: EdgeInsets.all(16.sp),
                  decoration: BoxDecoration(
                    color: AppColor.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColor.primary),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.logout, size: 22.sp, color: Colors.red),
                      SizedBox(width: 12.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Keluar',
                            style: AppFont.semiBold(16.sp, color: Colors.red),
                          ),
                          Text(
                            'Amankan Akun Anda',
                            style: AppFont.regular(12.sp),
                          ),
                        ],
                      ),
                      Spacer(),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16.sp,
                        color: Colors.red,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16.0.sp),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.date_range,
                          size: 18.sp,
                          color: AppColor.whiteGrey,
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          'User Login : Jumat 19 december 2025',
                          style: AppFont.regular(
                            12.sp,
                            color: AppColor.whiteGrey,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Icon(
                          Icons.history,
                          size: 18.sp,
                          color: AppColor.whiteGrey,
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          'Update Terakhir : Jumat 19 december 2025',
                          style: AppFont.regular(
                            12.sp,
                            color: AppColor.whiteGrey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
