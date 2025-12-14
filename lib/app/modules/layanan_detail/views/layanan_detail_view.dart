import 'package:camela_app/app/style/app_color.dart';
import 'package:camela_app/app/style/app_font.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/utils/url.dart';
import '../../cart/controllers/cart_controller.dart';
import '../controllers/layanan_detail_controller.dart';

class LayananDetailView extends GetView<LayananDetailController> {
  const LayananDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final cartController = Get.put(CartController());
    final layanan = controller.layanan;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.layanan.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64.sp, color: Colors.grey),
                SizedBox(height: 16.h),
                Text(
                  'Data layanan tidak ditemukan',
                  style: AppFont.medium(16.sp, color: Colors.grey),
                ),
                SizedBox(height: 24.h),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                  ),
                  child: Text(
                    'Kembali',
                    style: AppFont.medium(14.sp, color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        }

        final layanan = controller.layanan;
        final promoAktif = layanan['promo_aktif'];
        final hargaAsli =
            double.tryParse(layanan['harga']?.toString() ?? '0') ?? 0.0;
        final hargaDiskon = promoAktif != null
            ? (promoAktif['harga_diskon'] ?? 0)
            : null;
        final diskonPersen = promoAktif != null
            ? (promoAktif['diskon_persen'] ?? 0)
            : null;

        return CustomScrollView(
          slivers: [
            // App Bar dengan Image Slider
            SliverAppBar(
              expandedHeight: 300.h,
              pinned: true,
              backgroundColor: AppColor.primary,
              leading: IconButton(
                icon: Container(
                  padding: EdgeInsets.all(8.sp),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_back,
                    color: AppColor.black,
                    size: 20.sp,
                  ),
                ),
                onPressed: () => Get.back(),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  children: [
                    Positioned.fill(
                      child: controller.imageList.isNotEmpty
                          ? PageView.builder(
                              controller: controller.pageController,
                              onPageChanged: controller.onPageChanged,
                              itemCount: controller.imageList.length,
                              itemBuilder: (context, index) {
                                final imagePath = controller.imageList[index];
                                return Image.network(
                                  '${AppUrl.imageUrl}/$imagePath',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[200],
                                      child: Icon(
                                        Icons.image,
                                        size: 64.sp,
                                        color: Colors.grey,
                                      ),
                                    );
                                  },
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Container(
                                          color: Colors.grey[200],
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              value:
                                                  loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        loadingProgress
                                                            .expectedTotalBytes!
                                                  : null,
                                            ),
                                          ),
                                        );
                                      },
                                );
                              },
                            )
                          : Container(
                              color: Colors.grey[200],
                              child: Icon(
                                Icons.image,
                                size: 64.sp,
                                color: Colors.grey,
                              ),
                            ),
                    ),

                    // Gradient overlay - Positioned untuk tidak block gestures
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Indicator Dots
                    if (controller.imageList.length > 1)
                      Positioned(
                        bottom: 16.h,
                        left: 0,
                        right: 0,
                        child: IgnorePointer(
                          child: Obx(
                            () => Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                controller.imageList.length,
                                (index) => AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                                  width:
                                      controller.currentImageIndex.value ==
                                          index
                                      ? 24.w
                                      : 8.w,
                                  height: 8.h,
                                  decoration: BoxDecoration(
                                    color:
                                        controller.currentImageIndex.value ==
                                            index
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Badge Promo
                    if (promoAktif != null)
                      Positioned(
                        top: 60.h,
                        right: 16.w,
                        child: IgnorePointer(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.sp,
                              vertical: 6.sp,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              'PROMO $diskonPersen% OFF',
                              style: AppFont.bold(12.sp, color: Colors.white),
                            ),
                          ),
                        ),
                      ),

                    // Image Counter
                    if (controller.imageList.length > 1)
                      Positioned(
                        bottom: 10.h,
                        left: 16.w,
                        child: IgnorePointer(
                          child: Obx(
                            () => Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.sp,
                                vertical: 6.sp,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${controller.currentImageIndex.value + 1}/${controller.imageList.length}',
                                style: AppFont.medium(
                                  12.sp,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Content
            SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(24.r),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(24.sp),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Kategori Badge
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.sp,
                          vertical: 6.sp,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          layanan['kategori']?['name'] ?? '-',
                          style: AppFont.medium(12.sp, color: AppColor.primary),
                        ),
                      ),

                      SizedBox(height: 16.h),

                      // Nama Layanan
                      Text(
                        layanan['name'] ?? '-',
                        style: AppFont.bold(24.sp, color: AppColor.black),
                      ),

                      SizedBox(height: 8.h),

                      // Estimasi Waktu
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 18.sp,
                            color: Colors.grey,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            '${layanan['estimasi_menit']} menit',
                            style: AppFont.medium(
                              14.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 24.h),

                      // Harga
                      _buildPriceSection(hargaAsli, hargaDiskon, promoAktif),

                      SizedBox(height: 24.h),

                      // Divider
                      Divider(color: Colors.grey[300]),

                      SizedBox(height: 24.h),

                      // Deskripsi
                      Text(
                        'Deskripsi',
                        style: AppFont.bold(18.sp, color: AppColor.black),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        layanan['deskripsi'] ?? '-',
                        style: AppFont.regular(14.sp, color: Colors.grey[700]),
                        textAlign: TextAlign.justify,
                      ),

                      SizedBox(height: 24.h),

                      // Info Promo
                      if (promoAktif != null) ...[
                        Divider(color: Colors.grey[300]),
                        SizedBox(height: 24.h),
                        _buildPromoInfo(promoAktif),
                      ],

                      SizedBox(height: 100.h), // Space for bottom button
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
      bottomNavigationBar: Obx(() {
        if (controller.isLoading.value || controller.layanan.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: EdgeInsets.all(24.sp),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: ElevatedButton(
              onPressed: () async {
                await cartController.addToCart(layanan);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Tambahkan Keranjang',
                style: AppFont.bold(16.sp, color: Colors.white),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPriceSection(
    double hargaAsli,
    dynamic hargaDiskon,
    dynamic promoAktif,
  ) {
    return Container(
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: AppColor.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.primary.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Harga',
                style: AppFont.medium(12.sp, color: Colors.grey[600]),
              ),
              SizedBox(height: 4.h),
              if (promoAktif != null) ...[
                Text(
                  'Rp ${hargaAsli.toStringAsFixed(0)}',
                  style: AppFont.regular(
                    14.sp,
                    color: Colors.grey,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Rp ${hargaDiskon?.toStringAsFixed(0) ?? '0'}',
                  style: AppFont.bold(24.sp, color: AppColor.primary),
                ),
              ] else ...[
                Text(
                  'Rp ${hargaAsli.toStringAsFixed(0)}',
                  style: AppFont.bold(24.sp, color: AppColor.primary),
                ),
              ],
            ],
          ),
          if (promoAktif != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 8.sp),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Hemat Rp ${(hargaAsli - (hargaDiskon ?? 0)).toStringAsFixed(0)}',
                style: AppFont.bold(12.sp, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPromoInfo(Map<String, dynamic> promo) {
    return Container(
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_offer, color: Colors.red, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'Promo Spesial',
                style: AppFont.bold(16.sp, color: Colors.red),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Periode Promo',
                style: AppFont.medium(12.sp, color: Colors.grey[600]),
              ),
              Text(
                '${promo['tanggal_mulai']} - ${promo['tanggal_selesai']}',
                style: AppFont.medium(12.sp, color: AppColor.black),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
