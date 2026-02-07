import 'package:camela_app/app/style/app_color.dart';
import 'package:camela_app/app/style/app_font.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

class EditProfileView extends GetView {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: AppFont.semiBold(22.sp, color: AppColor.primary),
        ),
      ),
      body: Column(
        children: [
          Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 50,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 16.sp),
                  padding: EdgeInsets.all(16.sp),
                  height: 200.h,
                  decoration: BoxDecoration(
                    color: AppColor.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColor.primary),
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 12.h),
                      Text('data'),
                      Text('data'),
                      Text('data'),
                      Text('data'),
                    ],
                  ),
                ),
              ),
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50.r,
                      backgroundColor: AppColor.primary,
                      child: Icon(
                        Icons.person,
                        size: 50.sp,
                        color: AppColor.white,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(4.sp),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          Icons.edit,
                          size: 22.sp,
                          color: AppColor.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
