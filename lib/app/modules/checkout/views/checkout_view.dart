import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:camela_app/app/core/utils/price_formatter.dart';
import 'package:camela_app/app/style/app_color.dart';
import 'package:camela_app/app/style/app_font.dart';
import '../controllers/checkout_controller.dart';

class CheckoutView extends GetView<CheckoutController> {
  const CheckoutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Checkout',
          style: AppFont.bold(18.sp, color: AppColor.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColor.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              // Booking Info Section
              Container(
                margin: EdgeInsets.all(16.sp),
                padding: EdgeInsets.all(16.sp),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informasi Booking',
                      style: AppFont.bold(16.sp, color: AppColor.black),
                    ),
                    SizedBox(height: 16.h),

                    // Date Selection
                    _buildInfoRow(
                      icon: Icons.calendar_today,
                      label: 'Tanggal Booking',
                      value: DateFormat(
                        'dd MMMM yyyy',
                        'id_ID',
                      ).format(controller.selectedDate.value),
                      onTap: () => controller.selectDate(context),
                    ),
                    Divider(height: 24.h),

                    // Time Selection
                    _buildInfoRow(
                      icon: Icons.access_time,
                      label: 'Jam Booking',
                      value: controller.selectedTime.value.format(context),
                      onTap: () => controller.selectTime(context),
                    ),
                  ],
                ),
              ),

              // Payment Type Section
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16.sp),
                padding: EdgeInsets.all(16.sp),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jenis Pembayaran',
                      style: AppFont.bold(16.sp, color: AppColor.black),
                    ),
                    SizedBox(height: 12.h),

                    // DP Option
                    _buildPaymentOption(
                      title: 'DP 50%',
                      subtitle: 'Bayar setengah sekarang',
                      value: 'dp',
                    ),
                    SizedBox(height: 8.h),

                    // Lunas Option
                    _buildPaymentOption(
                      title: 'Lunas',
                      subtitle: 'Bayar penuh sekarang',
                      value: 'lunas',
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              // Payment Method Section
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16.sp),
                padding: EdgeInsets.all(16.sp),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Metode Pembayaran',
                      style: AppFont.bold(16.sp, color: AppColor.black),
                    ),
                    SizedBox(height: 12.h),

                    // Payment Methods
                    Column(
                      children: controller.paymentMethods.map((method) {
                        return RadioListTile<String>(
                          title: Text(controller.getPaymentMethodName(method)),
                          value: method,
                          groupValue: controller.selectedPaymentMethod.value,
                          onChanged: (value) =>
                              controller.setPaymentMethod(value!),
                          activeColor: AppColor.primary,
                        );
                      }).toList(),
                    ),

                    // Bank Selection (only for Bank Transfer)
                    Obx(() {
                      if (controller.selectedPaymentMethod.value ==
                          'BANK_TRANSFER') {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 16.h),
                            Text(
                              'Pilih Bank',
                              style: AppFont.medium(
                                14.sp,
                                color: AppColor.black,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            DropdownButtonFormField<String>(
                              value: controller.selectedBank.value,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              items: controller.bankOptions.map((bank) {
                                return DropdownMenuItem(
                                  value: bank,
                                  child: Text(controller.getBankName(bank)),
                                );
                              }).toList(),
                              onChanged: (value) => controller.setBank(value!),
                            ),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                  ],
                ),
              ),

              // Order Summary
              Container(
                margin: EdgeInsets.all(16.sp),
                padding: EdgeInsets.all(16.sp),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ringkasan Pesanan',
                      style: AppFont.bold(16.sp, color: AppColor.black),
                    ),
                    SizedBox(height: 16.h),

                    // Items Count
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Item',
                          style: AppFont.regular(
                            14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '${controller.cartItems.length} layanan',
                          style: AppFont.medium(14.sp, color: AppColor.black),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),

                    // Total Harga
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Harga',
                          style: AppFont.regular(
                            14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          'Rp.${PriceFormatter.price(controller.totalHarga.value)}',
                          style: AppFont.medium(14.sp, color: AppColor.black),
                        ),
                      ],
                    ),

                    if (controller.paymentType.value == 'dp') ...[
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'DP 50%',
                            style: AppFont.regular(
                              14.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            'Rp.${PriceFormatter.price(controller.totalPembayaran.value)}',
                            style: AppFont.medium(
                              14.sp,
                              color: AppColor.primary,
                            ),
                          ),
                        ],
                      ),
                    ],

                    Divider(height: 24.h),

                    // Total Pembayaran
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Pembayaran',
                          style: AppFont.bold(16.sp, color: AppColor.black),
                        ),
                        Text(
                          'Rp.${PriceFormatter.price(controller.totalPembayaran.value)}',
                          style: AppFont.bold(20.sp, color: AppColor.primary),
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
      bottomNavigationBar: Obx(
        () => Container(
          padding: EdgeInsets.all(16.sp),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () => controller.processCheckout(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                  padding: EdgeInsets.symmetric(vertical: 14.sp),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: controller.isLoading.value
                    ? SizedBox(
                        height: 20.h,
                        width: 20.w,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Bayar Sekarang',
                        style: AppFont.bold(16.sp, color: Colors.white),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 20.sp, color: AppColor.primary),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppFont.regular(12.sp, color: Colors.grey[600]),
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: AppFont.medium(14.sp, color: AppColor.black),
                ),
              ],
            ),
          ),
          if (onTap != null)
            Icon(Icons.arrow_forward_ios, size: 16.sp, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required String title,
    required String subtitle,
    required String value,
  }) {
    return Obx(
      () => InkWell(
        onTap: () => controller.changePaymentType(value),
        child: Container(
          padding: EdgeInsets.all(12.sp),
          decoration: BoxDecoration(
            border: Border.all(
              color: controller.paymentType.value == value
                  ? AppColor.primary
                  : Colors.grey[300]!,
              width: controller.paymentType.value == value ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
            color: controller.paymentType.value == value
                ? AppColor.primary.withValues(alpha: 0.05)
                : Colors.white,
          ),
          child: Row(
            children: [
              Radio<String>(
                value: value,
                groupValue: controller.paymentType.value,
                onChanged: (val) {
                  if (val != null) {
                    controller.changePaymentType(val);
                  }
                },
                activeColor: AppColor.primary,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppFont.bold(14.sp, color: AppColor.black),
                    ),
                    Text(
                      subtitle,
                      style: AppFont.regular(12.sp, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
