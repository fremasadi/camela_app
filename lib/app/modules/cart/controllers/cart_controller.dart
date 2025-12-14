import 'package:get/get.dart';
import '../../../core/services/cart_service.dart';

class CartController extends GetxController {
  var cartItems = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var cartCount = 0.obs;
  var cartTotal = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadCart();
  }

  /// Memuat data cart dari SharedPreferences
  Future<void> loadCart() async {
    try {
      isLoading.value = true;
      cartItems.value = await CartService.getCartItems();
      await updateCartInfo();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat keranjang: $e',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Update informasi cart (count & total)
  Future<void> updateCartInfo() async {
    cartCount.value = await CartService.getCartCount();
    cartTotal.value = await CartService.getCartTotal();
  }

  /// Menambahkan item ke cart
  Future<void> addToCart(Map<String, dynamic> layanan) async {
    try {
      final success = await CartService.addToCart(layanan);

      if (success) {
        await loadCart();
        Get.snackbar(
          'Berhasil',
          '${layanan['name']} ditambahkan ke keranjang',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );
      } else {
        Get.snackbar(
          'Gagal',
          'Gagal menambahkan ke keranjang',
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: $e',
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  /// Update quantity item
  Future<void> updateQuantity(int layananId, int quantity) async {
    try {
      final success = await CartService.updateQuantity(layananId, quantity);

      if (success) {
        await loadCart();
      } else {
        Get.snackbar(
          'Gagal',
          'Gagal mengupdate jumlah',
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: $e',
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  /// Hapus item dari cart
  Future<void> removeFromCart(int layananId) async {
    try {
      final success = await CartService.removeFromCart(layananId);

      if (success) {
        await loadCart();
        Get.snackbar(
          'Berhasil',
          'Item dihapus dari keranjang',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );
      } else {
        Get.snackbar(
          'Gagal',
          'Gagal menghapus item',
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: $e',
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  /// Kosongkan cart
  Future<void> clearCart() async {
    try {
      final success = await CartService.clearCart();

      if (success) {
        await loadCart();
        Get.snackbar(
          'Berhasil',
          'Keranjang dikosongkan',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengosongkan keranjang: $e',
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  /// Increment quantity
  Future<void> incrementQuantity(int layananId) async {
    final currentQty = await CartService.getItemQuantity(layananId);
    await updateQuantity(layananId, currentQty + 1);
  }

  /// Decrement quantity
  Future<void> decrementQuantity(int layananId) async {
    final currentQty = await CartService.getItemQuantity(layananId);
    if (currentQty > 1) {
      await updateQuantity(layananId, currentQty - 1);
    } else {
      await removeFromCart(layananId);
    }
  }

  /// Cek apakah item ada di cart
  Future<bool> isInCart(int layananId) async {
    return await CartService.isInCart(layananId);
  }
}
