import 'package:camela_app/app/core/utils/url.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/price_formatter.dart';
import '../../../style/app_color.dart';
import '../../../style/app_font.dart';
import '../controllers/history_controller.dart';

class HistoryView extends GetView<HistoryController> {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Riwayat Booking',
          style: AppFont.bold(18.sp, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: AppColor.primary,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter Tabs
          _buildFilterTabs(),

          // Booking List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.errorMessage.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
                      SizedBox(height: 16.h),
                      Text(
                        'Gagal memuat data',
                        style: AppFont.medium(16.sp, color: Colors.grey[700]),
                      ),
                      SizedBox(height: 8.h),
                      ElevatedButton(
                        onPressed: controller.fetchBookingHistory,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primary,
                        ),
                        child: Text('Coba Lagi'),
                      ),
                    ],
                  ),
                );
              }

              if (controller.filteredBookings.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_outlined, size: 64.sp, color: Colors.grey),
                      SizedBox(height: 16.h),
                      Text(
                        'Belum ada riwayat booking',
                        style: AppFont.medium(16.sp, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.refreshHistory,
                child: ListView.builder(
                  padding: EdgeInsets.all(16.sp),
                  itemCount: controller.filteredBookings.length,
                  itemBuilder: (context, index) {
                    final booking = controller.filteredBookings[index];
                    return _buildBookingCard(booking);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Obx(() {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16.sp),
          child: Row(
            children: [
              _buildTabItem('all', 'Semua', controller.countByStatus('all')),
              SizedBox(width: 12.w),
              _buildTabItem('pending', 'Menunggu', controller.countByStatus('pending')),
              SizedBox(width: 12.w),
              _buildTabItem('confirmed', 'Dikonfirmasi', controller.countByStatus('confirmed')),
              SizedBox(width: 12.w),
              _buildTabItem('cancelled', 'Dibatalkan', controller.countByStatus('cancelled')),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTabItem(String value, String label, int count) {
    final isSelected = controller.selectedTab.value == value;
    return GestureDetector(
      onTap: () => controller.selectTab(value),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.sp),
        decoration: BoxDecoration(
          color: isSelected ? AppColor.primary : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColor.primary : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppFont.medium(
                14.sp,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
            ),
            if (count > 0) ...[
              SizedBox(width: 6.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.sp, vertical: 2.sp),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : AppColor.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: AppFont.bold(
                    11.sp,
                    color: isSelected ? AppColor.primary : Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final details = booking['details'] as List?;
    final pembayaran = booking['pembayaran'] as Map<String, dynamic>?;
    final status = booking['status'] as String? ?? 'pending';

    final tanggalBooking = booking['tanggal_booking'] != null
        ? DateTime.parse(booking['tanggal_booking'])
        : DateTime.now();
    final jamBooking = booking['jam_booking'] as String? ?? '';

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(12.sp),
            decoration: BoxDecoration(
              color: controller.getStatusColor(status).withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.receipt_long,
                      size: 18.sp,
                      color: controller.getStatusColor(status),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      booking['order_id'] ?? 'N/A',
                      style: AppFont.bold(
                        14.sp,
                        color: controller.getStatusColor(status),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 4.sp),
                  decoration: BoxDecoration(
                    color: controller.getStatusColor(status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    controller.getStatusLabel(status),
                    style: AppFont.medium(11.sp, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.all(12.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date & Time
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16.sp, color: Colors.grey[600]),
                    SizedBox(width: 8.w),
                    Text(
                      DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(tanggalBooking),
                      style: AppFont.medium(13.sp, color: Colors.grey[700]),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16.sp, color: Colors.grey[600]),
                    SizedBox(width: 8.w),
                    Text(
                      jamBooking,
                      style: AppFont.medium(13.sp, color: Colors.grey[700]),
                    ),
                  ],
                ),

                SizedBox(height: 12.h),
                const Divider(),
                SizedBox(height: 12.h),

                // Services
                if (details != null && details.isNotEmpty)
                  ...details.map((detail) {
                    final layanan = detail['layanan'] as Map<String, dynamic>?;
                    final qty = detail['qty'] ?? 1;
                    final harga = detail['harga'] ?? '0';

                    return Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              '${AppUrl.imageUrl}/${layanan?['image']?[0] ?? ''}',
                              width: 60.w,
                              height: 60.h,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 60.w,
                                  height: 60.h,
                                  color: Colors.grey[200],
                                  child: Icon(Icons.image, color: Colors.grey),
                                );
                              },
                            ),
                          ),
                          SizedBox(width: 12.w),
                          // Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  layanan?['name'] ?? 'Layanan',
                                  style: AppFont.bold(14.sp, color: AppColor.black),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'Qty: $qty',
                                  style: AppFont.regular(12.sp, color: Colors.grey[600]),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'Rp.${PriceFormatter.price(double.parse(harga.toString()))}',
                                  style: AppFont.bold(13.sp, color: AppColor.primary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),

                const Divider(),
                SizedBox(height: 8.h),

                // Payment Info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Pembayaran',
                      style: AppFont.medium(14.sp, color: Colors.grey[700]),
                    ),
                    Text(
                      'Rp.${PriceFormatter.price(double.parse(booking['total_pembayaran'].toString()))}',
                      style: AppFont.bold(16.sp, color: AppColor.primary),
                    ),
                  ],
                ),

                if (pembayaran != null) ...[
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Metode Pembayaran',
                        style: AppFont.regular(12.sp, color: Colors.grey[600]),
                      ),
                      Text(
                        pembayaran['payment_type'] ?? 'N/A',
                        style: AppFont.medium(12.sp, color: Colors.grey[800]),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Status Pembayaran',
                        style: AppFont.regular(12.sp, color: Colors.grey[600]),
                      ),
                      Text(
                        pembayaran['status_label'] ?? 'N/A',
                        style: AppFont.medium(
                          12.sp,
                          color: pembayaran['is_paid'] == true
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ],

                SizedBox(height: 12.h),

                // Action Button
                if (status == 'pending' && pembayaran != null && pembayaran['is_paid'] != true)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => controller.navigateToPayment(booking),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primary,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Lanjutkan Pembayaran',
                        style: AppFont.bold(14.sp, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}