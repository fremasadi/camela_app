import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:camela_app/app/core/repository/layanan/layanan_repository.dart';

class LayananDetailController extends GetxController {
  var layanan = <String, dynamic>{}.obs;
  var isLoading = true.obs;

  // Untuk image slider
  final PageController pageController = PageController();
  var currentImageIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadLayananData();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void loadLayananData() {
    try {
      final args = Get.arguments;

      print('Arguments received: $args');

      if (args == null) {
        print('Error: No arguments provided');
        isLoading.value = false;
        Get.snackbar(
          'Error',
          'Data layanan tidak ditemukan',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      if (args is Map<String, dynamic>) {
        // Jika data layanan sudah dikirim dari halaman sebelumnya
        if (args.containsKey('layanan') && args['layanan'] != null) {
          layanan.value = args['layanan'];
          isLoading.value = false;
          print('Layanan loaded from arguments: ${layanan['name']}');
        }
        // Jika hanya ID yang dikirim, fetch dari API
        else if (args.containsKey('id') && args['id'] != null) {
          fetchLayananDetail(args['id']);
        } else {
          print('Error: Invalid arguments structure');
          isLoading.value = false;
          Get.snackbar(
            'Error',
            'Format data tidak valid',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else {
        print('Error: Arguments is not a Map');
        isLoading.value = false;
      }
    } catch (e) {
      print('Error in loadLayananData: $e');
      isLoading.value = false;
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Fetch detail layanan dari API
  Future<void> fetchLayananDetail(int id) async {
    try {
      isLoading.value = true;
      final data = await LayananRepository.getLayananById(id);
      layanan.value = data;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengambil detail layanan: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh data
  Future<void> refreshData() async {
    if (layanan.isNotEmpty && layanan['id'] != null) {
      await fetchLayananDetail(layanan['id']);
    }
  }

  /// Update current image index saat slider berubah
  void onPageChanged(int index) {
    currentImageIndex.value = index;
  }

  /// Get image list
  List<String> get imageList {
    final images = layanan['image'];
    if (images is List && images.isNotEmpty) {
      return images.map((e) => e.toString()).toList();
    }
    return [];
  }
}
