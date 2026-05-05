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

  // Tambahkan onReady untuk memastikan data selalu fresh saat halaman dibuka kembali
  @override
  void onReady() {
    super.onReady();
    loadCart();
  }

  /// Memuat data cart dari SharedPreferences
  Future<void> loadCart() async {
    try {
      isLoading.value = true;
      final items = await CartService.getCartItems();
      cartItems.assignAll(items); // Gunakan assignAll agar UI langsung update
      await updateCartInfo();
    } catch (e) {
      print("Error loadCart: $e");
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
        Get.snackbar('Berhasil', '${layanan['name']} ditambahkan');
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan: $e');
    }
  }

  /// Update quantity item
  Future<void> updateQuantity(int layananId, int quantity) async {
    final success = await CartService.updateQuantity(layananId, quantity);
    if (success) await loadCart();
  }

  /// Hapus item dari cart
  Future<void> removeFromCart(int layananId) async {
    final success = await CartService.removeFromCart(layananId);
    if (success) await loadCart();
  }

  /// Kosongkan cart
  Future<void> clearCart() async {
    final success = await CartService.clearCart();
    if (success) await loadCart();
  }

  Future<void> incrementQuantity(int layananId) async {
    final currentQty = await CartService.getItemQuantity(layananId);
    await updateQuantity(layananId, currentQty + 1);
  }

  Future<void> decrementQuantity(int layananId) async {
    final currentQty = await CartService.getItemQuantity(layananId);
    if (currentQty > 1) {
      await updateQuantity(layananId, currentQty - 1);
    } else {
      await removeFromCart(layananId);
    }
  }

  Future<bool> isInCart(int layananId) async => await CartService.isInCart(layananId);
}
