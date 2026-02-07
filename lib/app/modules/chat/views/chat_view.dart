import 'package:camela_app/app/style/app_color.dart';
import 'package:camela_app/app/style/app_font.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/chat_controller.dart';

class ChatView extends GetView<ChatController> {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      size: 28.sp,
                      color: AppColor.primary,
                    ),
                    onPressed: () => Get.back(),
                  ),
                  CircleAvatar(
                    radius: 20.r,
                    backgroundColor: AppColor.primary.withValues(alpha: 0.1),
                    child: Icon(
                      Icons.support_agent,
                      color: AppColor.primary,
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Camela Assistant', style: AppFont.bold(16.sp)),
                      Text(
                        'Online',
                        style: AppFont.regular(11.sp, color: Colors.green),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Chat Messages
            Expanded(
              child: Container(
                decoration: BoxDecoration(color: AppColor.greyBackground),
                child: Obx(
                  () => ListView.builder(
                    controller: controller.scrollController,
                    padding: EdgeInsets.all(16.sp),
                    itemCount: controller.messages.length,
                    itemBuilder: (context, index) {
                      final message = controller.messages[index];
                      final isUser = message['isUser'] as bool;

                      return _buildMessageBubble(
                        message['text'] as String,
                        isUser,
                        message['timestamp'] as String,
                      );
                    },
                  ),
                ),
              ),
            ),

            // Quick Reply Suggestions (only show when no active chat)
            Obx(() {
              if (controller.messages.length <= 1) {
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Colors.black12)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pertanyaan Populer:',
                        style: AppFont.medium(12.sp, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 8.h),
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: controller.quickReplies.map((reply) {
                          return InkWell(
                            onTap: () => controller.sendMessage(reply),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 8.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColor.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(
                                  color: AppColor.primary.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                              child: Text(
                                reply,
                                style: AppFont.medium(
                                  11.sp,
                                  color: AppColor.primary,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            }),

            // Input Field
            Container(
              padding: EdgeInsets.all(12.sp),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.black12)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.textController,
                      decoration: InputDecoration(
                        hintText: 'Ketik pertanyaan Anda...',
                        hintStyle: AppFont.regular(
                          13.sp,
                          color: Colors.grey[400],
                        ),
                        filled: true,
                        fillColor: AppColor.greyBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24.r),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                      ),
                      style: AppFont.regular(14.sp),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (value) {
                        if (value.trim().isNotEmpty) {
                          controller.sendMessage(value);
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Obx(
                    () => InkWell(
                      onTap: controller.isLoading.value
                          ? null
                          : () {
                              if (controller.textController.text
                                  .trim()
                                  .isNotEmpty) {
                                controller.sendMessage(
                                  controller.textController.text,
                                );
                              }
                            },
                      child: Container(
                        padding: EdgeInsets.all(12.sp),
                        decoration: BoxDecoration(
                          color: controller.isLoading.value
                              ? Colors.grey
                              : AppColor.primary,
                          shape: BoxShape.circle,
                        ),
                        child: controller.isLoading.value
                            ? SizedBox(
                                width: 20.w,
                                height: 20.h,
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(
                                Icons.send,
                                color: Colors.white,
                                size: 20.sp,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isUser, String timestamp) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        constraints: BoxConstraints(maxWidth: 280.w),
        child: Column(
          crossAxisAlignment: isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: isUser ? AppColor.primary : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                  bottomLeft: isUser ? Radius.circular(16.r) : Radius.zero,
                  bottomRight: isUser ? Radius.zero : Radius.circular(16.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                text,
                style: AppFont.regular(
                  13.sp,
                  color: isUser ? Colors.white : Colors.black87,
                ),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              timestamp,
              style: AppFont.regular(10.sp, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}
