import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:camela_app/app/core/utils/url.dart';
import 'package:camela_app/app/core/utils/price_formatter.dart';
import 'package:camela_app/app/style/app_color.dart';
import 'package:camela_app/app/style/app_font.dart';
import '../controllers/cart_controller.dart';

class CartView extends GetView<CartController> {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Keranjang',
          style: AppFont.bold(18.sp, color: AppColor.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColor.black),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(() {
            if (controller.cartItems.isNotEmpty) {
              return TextButton(
                onPressed: () {
                  Get.dialog(
                    AlertDialog(
                      title: Text(
                        'Kosongkan Keranjang?',
                        style: AppFont.bold(16.sp, color: AppColor.black),
                      ),
                      content: Text(
                        'Semua item akan dihapus dari keranjang',
                        style: AppFont.regular(14.sp, color: Colors.grey[600]),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: Text(
                            'Batal',
                            style: AppFont.medium(14.sp, color: Colors.grey),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            controller.clearCart();
                            Get.back();
                          },
                          child: Text(
                            'Hapus',
                            style: AppFont.medium(14.sp, color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                child: Text(
                  'Hapus Semua',
                  style: AppFont.medium(14.sp, color: Colors.red),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.cartItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  size: 100.sp,
                  color: Colors.grey[300],
                ),
                SizedBox(height: 16.h),
                Text(
                  'Keranjang Kosong',
                  style: AppFont.bold(18.sp, color: Colors.grey[600]),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Tambahkan layanan untuk melanjutkan',
                  style: AppFont.regular(14.sp, color: Colors.grey[400]),
                ),
                SizedBox(height: 24.h),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    padding: EdgeInsets.symmetric(
                      horizontal: 32.sp,
                      vertical: 12.sp,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Lihat Layanan',
                    style: AppFont.medium(14.sp, color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // List Cart Items
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(16.sp),
                itemCount: controller.cartItems.length,
                itemBuilder: (context, index) {
                  final item = controller.cartItems[index];
                  return _buildCartItem(item);
                },
              ),
            ),

            // Bottom Summary
            Container(
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
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total (${controller.cartCount.value} item)',
                          style: AppFont.medium(14.sp, color: Colors.grey[600]),
                        ),
                        Text(
                          'Rp.${PriceFormatter.price(controller.cartTotal.value)}',
                          style: AppFont.bold(20.sp, color: AppColor.primary),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigate ke checkout
                          Get.toNamed('/checkout');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primary,
                          padding: EdgeInsets.symmetric(vertical: 14.sp),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Lanjutkan',
                          style: AppFont.bold(16.sp, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item) {
    final promoAktif = item['promo_aktif'];
    final hargaAsli = double.parse(item['harga'].toString());
    final hargaDiskon = promoAktif != null ? promoAktif['harga_diskon'] : null;
    final quantity = item['quantity'] ?? 1;

    double hargaFinal;
    if (promoAktif != null && hargaDiskon != null) {
      hargaFinal = double.parse(hargaDiskon.toString());
    } else {
      hargaFinal = hargaAsli;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(12),
            ),
            child: Image.network(
              '${AppUrl.imageUrl}/${item['image'][0]}',
              width: 100.w,
              height: 100.h,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 100.w,
                  height: 100.h,
                  color: Colors.grey[200],
                  child: Icon(Icons.image, size: 32.sp, color: Colors.grey),
                );
              },
            ),
          ),

          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(12.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name & Delete Button
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item['name'] ?? '-',
                          style: AppFont.bold(14.sp, color: AppColor.black),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          controller.removeFromCart(item['id']);
                        },
                        child: Icon(
                          Icons.delete_outline,
                          size: 20.sp,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 4.h),

                  // Category Badge
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.sp,
                      vertical: 2.sp,
                    ),
                    decoration: BoxDecoration(
                      color: AppColor.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item['kategori']?['name'] ?? '-',
                      style: AppFont.medium(10.sp, color: AppColor.primary),
                    ),
                  ),

                  SizedBox(height: 8.h),

                  // Price & Quantity
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Price
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (promoAktif != null) ...[
                            Text(
                              'Rp.${PriceFormatter.price(hargaAsli)}',
                              style: AppFont.regular(
                                10.sp,
                                color: Colors.grey,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                          Text(
                            'Rp.${PriceFormatter.price(hargaFinal)}',
                            style: AppFont.bold(14.sp, color: AppColor.primary),
                          ),
                        ],
                      ),

                      // Quantity Controls
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            InkWell(
                              onTap: () {
                                controller.decrementQuantity(item['id']);
                              },
                              child: Container(
                                padding: EdgeInsets.all(6.sp),
                                child: Icon(
                                  Icons.remove,
                                  size: 16.sp,
                                  color: AppColor.primary,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.sp),
                              child: Text(
                                '$quantity',
                                style: AppFont.bold(
                                  14.sp,
                                  color: AppColor.black,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                controller.incrementQuantity(item['id']);
                              },
                              child: Container(
                                padding: EdgeInsets.all(6.sp),
                                child: Icon(
                                  Icons.add,
                                  size: 16.sp,
                                  color: AppColor.primary,
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
            ),
          ),
        ],
      ),
    );
  }
}
