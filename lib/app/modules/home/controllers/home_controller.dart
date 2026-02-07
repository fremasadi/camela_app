import 'package:get/get.dart';
import 'package:camela_app/app/core/repository/layanan/kategori_repository.dart';
import 'package:camela_app/app/core/repository/layanan/layanan_repository.dart';

import '../../../core/repository/auth/login_repository.dart';

class HomeController extends GetxController {
  // Kategori
  var kategoriList = <Map<String, dynamic>>[].obs;
  var selectedKategoriId = Rxn<int>(); // null = "Semua"

  // Layanan
  var layananList = <Map<String, dynamic>>[].obs;
  var filteredLayananList = <Map<String, dynamic>>[].obs;

  // Loading states
  var isLoadingKategori = true.obs;
  var isLoadingLayanan = true.obs;
  var userData = Rxn<Map<String, dynamic>>();

  Future<void> loadUserData() async {
    final user = await LoginRepository.getUser();
    userData.value = user;
  }

  @override
  void onInit() {
    super.onInit();
    // Set default ke "Semua" (null)
    loadUserData();

    selectedKategoriId.value = null;
    fetchKategori();
    fetchLayanan();
  }

  /// Mengambil data kategori
  Future<void> fetchKategori() async {
    try {
      isLoadingKategori.value = true;
      final data = await KategoriRepository.getKategori();
      kategoriList.value = data;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengambil kategori: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingKategori.value = false;
    }
  }

  /// Mengambil data layanan
  Future<void> fetchLayanan() async {
    try {
      isLoadingLayanan.value = true;
      final data = await LayananRepository.getLayanan();
      layananList.value = data;
      filterLayanan(); // Filter setelah data dimuat
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengambil layanan: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingLayanan.value = false;
    }
  }

  /// Filter layanan berdasarkan kategori yang dipilih
  void filterLayanan() {
    if (selectedKategoriId.value == null) {
      // Tampilkan semua layanan
      filteredLayananList.value = List.from(layananList);
    } else {
      // Filter berdasarkan kategori
      filteredLayananList.value = layananList.where((layanan) {
        final kategori = layanan['kategori'] as Map<String, dynamic>?;
        return kategori?['id'] == selectedKategoriId.value;
      }).toList();
    }

    // Debug log
  }

  /// Pilih kategori (dipanggil saat user tap kategori)
  void selectKategori(int? kategoriId) {
    selectedKategoriId.value = kategoriId;
    filterLayanan();
  }

  /// Refresh semua data
  Future<void> refreshData() async {
    await Future.wait([fetchKategori(), fetchLayanan()]);
  }

  /// Mengambil detail layanan berdasarkan ID
  Future<Map<String, dynamic>?> getLayananDetail(int id) async {
    try {
      return await LayananRepository.getLayananById(id);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengambil detail layanan: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }
}
