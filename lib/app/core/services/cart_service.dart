import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CartService {
  static const String _cartKey = 'cart_items';

  /// Mendapatkan semua item di cart
  static Future<List<Map<String, dynamic>>> getCartItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartString = prefs.getString(_cartKey);

      if (cartString == null || cartString.isEmpty) {
        return [];
      }

      final List<dynamic> decoded = jsonDecode(cartString);
      // pastikan tiap elemen berupa Map<String, dynamic>
      return decoded.map((item) => Map<String, dynamic>.from(item)).toList();
    } catch (e) {
      // jika error parsing, hapus data rusak
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cartKey);
      return [];
    }
  }

  /// Menambahkan item ke cart
  static Future<bool> addToCart(Map<String, dynamic> layanan) async {
    try {
      if (layanan['id'] == null) {
        return false;
      }

      final cartItems = await getCartItems();

      final existingIndex = cartItems.indexWhere(
        (item) => item['id'] == layanan['id'],
      );

      if (existingIndex != -1) {
        // Item sudah ada, tambah quantity
        final oldQty = (cartItems[existingIndex]['quantity'] ?? 1) as int;
        cartItems[existingIndex]['quantity'] = oldQty + 1;
      } else {
        // Item baru
        final cartItem = {
          'id': layanan['id'],
          'name': layanan['name'] ?? 'Tanpa Nama',
          'harga': layanan['harga'] ?? 0,
          'image': (layanan['image'] is List)
              ? layanan['image']
              : [layanan['image']],
          'kategori': layanan['kategori'] ?? {},
          'estimasi_menit': layanan['estimasi_menit'] ?? 0,
          'promo_aktif': layanan['promo_aktif'],
          'quantity': 1,
          'added_at': DateTime.now().toIso8601String(),
        };
        cartItems.add(cartItem);
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cartKey, jsonEncode(cartItems));
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Update quantity item di cart
  static Future<bool> updateQuantity(int layananId, int quantity) async {
    try {
      final cartItems = await getCartItems();
      final index = cartItems.indexWhere((item) => item['id'] == layananId);

      if (index == -1) return false;

      if (quantity <= 0) {
        cartItems.removeAt(index);
      } else {
        cartItems[index]['quantity'] = quantity;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cartKey, jsonEncode(cartItems));
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Menghapus item dari cart
  static Future<bool> removeFromCart(int layananId) async {
    try {
      final cartItems = await getCartItems();
      cartItems.removeWhere((item) => item['id'] == layananId);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cartKey, jsonEncode(cartItems));
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Mengosongkan seluruh cart
  static Future<bool> clearCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cartKey);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Mendapatkan jumlah total item
  static Future<int> getCartCount() async {
    final cartItems = await getCartItems();
    return cartItems.fold<int>(
      0,
      (sum, item) => sum + (item['quantity'] as int? ?? 1),
    );
  }

  /// Mendapatkan total harga cart
  static Future<double> getCartTotal() async {
    final cartItems = await getCartItems();
    double total = 0;

    for (var item in cartItems) {
      final qty = (item['quantity'] ?? 1) as int;
      final promo = item['promo_aktif'];
      double harga;

      try {
        if (promo != null && promo['harga_diskon'] != null) {
          harga = double.tryParse(promo['harga_diskon'].toString()) ?? 0.0;
        } else {
          harga = double.tryParse(item['harga'].toString()) ?? 0.0;
        }
      } catch (_) {
        harga = 0.0;
      }

      total += harga * qty;
    }

    return total;
  }

  /// Cek apakah item sudah ada di cart
  static Future<bool> isInCart(int layananId) async {
    final cartItems = await getCartItems();
    return cartItems.any((item) => item['id'] == layananId);
  }

  /// Mendapatkan quantity item di cart
  static Future<int> getItemQuantity(int layananId) async {
    final cartItems = await getCartItems();
    final item = cartItems.firstWhere(
      (i) => i['id'] == layananId,
      orElse: () => {},
    );
    return item['quantity'] as int? ?? 0;
  }
}
