import 'package:camela_app/app/core/utils/url.dart';
import 'package:camela_app/app/routes/app_pages.dart';
import 'package:camela_app/app/style/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/utils/price_formatter.dart';
import '../../../style/app_font.dart';
import '../../cart/controllers/cart_controller.dart';
import '../controllers/home_controller.dart';
import 'image_slider_view.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final cartController = Get.put(CartController());

    final user = controller.userData.value;

    return Scaffold(
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: AppColor.primary,
      //   onPressed: () {
      //     Get.toNamed(Routes.CHAT);
      //   },
      //   child: Icon(Icons.chat, color: AppColor.white),
      // ),
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: ScreenUtil().statusBarHeight,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 18.0.sp,
                    horizontal: 24.sp,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text.rich(
                        TextSpan(
                          text: 'Hello, ',
                          style: AppFont.medium(24.sp, color: AppColor.black),
                          children: [
                            TextSpan(
                              text: 'Girl',
                              style: AppFont.bold(
                                24.sp,
                                color: AppColor.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Spacer(),
                      Obx(() {
                        return Stack(
                          children: [
                            IconButton(
                              onPressed: () {
                                Get.toNamed('/cart');
                              },
                              icon: Icon(
                                Icons.shopping_bag,
                                size: 28.sp,
                                color: AppColor.primary,
                              ),
                            ),
                            if (cartController.cartCount.value > 0)
                              Positioned(
                                right: 8,
                                top: 8,
                                child: Container(
                                  padding: EdgeInsets.all(4.sp),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: BoxConstraints(
                                    minWidth: 16.sp,
                                    minHeight: 16.sp,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${cartController.cartCount.value}',
                                      style: AppFont.bold(
                                        10.sp,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),

                // Image Carousel
                const ImageCarousel(),
                SizedBox(height: 18.h),

                // Kategori Horizontal
                Obx(() {
                  if (controller.isLoadingKategori.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.kategoriList.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.sp),
                      child: Text(
                        'Tidak ada kategori',
                        style: AppFont.medium(16.sp, color: Colors.grey),
                      ),
                    );
                  }

                  return SizedBox(
                    height: 32.h,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 16.sp),
                      itemCount: controller.kategoriList.length + 1,
                      itemBuilder: (context, index) {
                        // Item "Semua"
                        if (index == 0) {
                          return Obx(() {
                            final isSelected =
                                controller.selectedKategoriId.value == null;
                            return GestureDetector(
                              onTap: () {
                                controller.selectKategori(null);
                              },
                              child: Container(
                                margin: EdgeInsets.only(right: 12.sp),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.sp,
                                  vertical: 4.sp,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColor.primary
                                      : Colors.white,
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColor.primary
                                        : Colors.grey.shade300,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    'Semua',
                                    style: AppFont.medium(
                                      14.sp,
                                      color: isSelected
                                          ? Colors.white
                                          : AppColor.black,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          });
                        }

                        // Item Kategori dari API
                        final kategori = controller.kategoriList[index - 1];
                        final kategoriId = kategori['id'] as int?;

                        return Obx(() {
                          final isSelected =
                              controller.selectedKategoriId.value == kategoriId;
                          return GestureDetector(
                            onTap: () {
                              controller.selectKategori(kategoriId);
                            },
                            child: Container(
                              margin: EdgeInsets.only(right: 12.sp),
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.sp,
                                vertical: 4.sp,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColor.primary
                                    : Colors.white,
                                border: Border.all(
                                  color: isSelected
                                      ? AppColor.primary
                                      : Colors.grey.shade300,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  kategori['name'] ?? '-',
                                  style: AppFont.medium(
                                    14.sp,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColor.black,
                                  ),
                                ),
                              ),
                            ),
                          );
                        });
                      },
                    ),
                  );
                }),

                SizedBox(height: 24.h),

                // Daftar Layanan
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.sp),
                  child: Text(
                    'Layanan Tersedia',
                    style: AppFont.bold(18.sp, color: AppColor.black),
                  ),
                ),
                SizedBox(height: 12.h),

                Obx(() {
                  if (controller.isLoadingLayanan.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.filteredLayananList.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.all(24.sp),
                      child: Center(
                        child: Text(
                          'Tidak ada layanan tersedia',
                          style: AppFont.medium(16.sp, color: Colors.grey),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 24.sp),
                    itemCount: controller.filteredLayananList.length,
                    itemBuilder: (context, index) {
                      final layanan = controller.filteredLayananList[index];
                      return _buildLayananCard(layanan);
                    },
                  );
                }),

                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLayananCard(Map<String, dynamic> layanan) {
    final promoAktif = layanan['promo_aktif'];
    final hargaAsli = double.parse(layanan['harga'].toString());
    final hargaDiskon = promoAktif != null ? promoAktif['harga_diskon'] : null;
    final diskonPersen = promoAktif != null
        ? promoAktif['diskon_persen']
        : null;

    return GestureDetector(
      onTap: () {
        Get.toNamed(
          '/layanan-detail',
          arguments: {
            'layanan': layanan, // Kirim data langsung
            // atau bisa kirim ID saja: 'id': layanan['id']
          },
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
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
            // Gambar Layanan
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Image.network(
                '${AppUrl.imageUrl}/${layanan['image'][0]}',
                // ambil index pertama
                height: 160.h,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 160.h,
                    color: Colors.grey[200],
                    child: Icon(Icons.image, size: 48.sp, color: Colors.grey),
                  );
                },
              ),
            ),

            Padding(
              padding: EdgeInsets.all(12.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge Kategori & Promo
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.sp,
                          vertical: 4.sp,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          layanan['kategori']?['name'] ?? '-',
                          style: AppFont.medium(10.sp, color: AppColor.primary),
                        ),
                      ),
                      if (promoAktif != null) ...[
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.sp,
                            vertical: 4.sp,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'PROMO $diskonPersen%',
                            style: AppFont.bold(10.sp, color: Colors.white),
                          ),
                        ),
                      ],
                    ],
                  ),

                  SizedBox(height: 8.h),

                  // Nama Layanan
                  Text(
                    layanan['name'] ?? '-',
                    style: AppFont.bold(16.sp, color: AppColor.black),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: 4.h),

                  // Deskripsi
                  Text(
                    layanan['deskripsi'] ?? '-',
                    style: AppFont.regular(12.sp, color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: 8.h),

                  // Harga & Estimasi
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Harga
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (promoAktif != null) ...[
                            Text(
                              'Rp.${PriceFormatter.price(hargaAsli)}',
                              style: AppFont.regular(
                                12.sp,
                                color: Colors.grey,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              'Rp.${PriceFormatter.price(hargaDiskon!)}',
                              style: AppFont.bold(
                                16.sp,
                                color: AppColor.primary,
                              ),
                            ),
                          ] else ...[
                            Text(
                              'Rp.${PriceFormatter.price(hargaAsli)}',
                              style: AppFont.bold(
                                16.sp,
                                color: AppColor.primary,
                              ),
                            ),
                          ],
                        ],
                      ),

                      // Estimasi Waktu
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14.sp,
                            color: Colors.grey,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '${layanan['estimasi_menit']} menit',
                            style: AppFont.medium(
                              12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
