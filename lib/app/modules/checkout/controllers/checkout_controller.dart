import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/model/booking.dart';
import '../../../core/repository/booking/booking_repository.dart';
import '../../../core/services/cart_service.dart';
import '../../cart/controllers/cart_controller.dart';
import '../views/gopay_payment_page.dart';
import '../views/payment_page.dart'; // Import PaymentPage

class CheckoutController extends GetxController {
  final BookingRepository _repository = BookingRepository();

  // Observable variables
  var isLoading = false.obs;
  var cartItems = <Map<String, dynamic>>[].obs;
  var totalHarga = 0.0.obs;
  var totalPembayaran = 0.0.obs;

  // Booking info
  var selectedDate = DateTime.now().obs;
  var selectedTime = TimeOfDay.now().obs;
  var paymentType = 'lunas'.obs; // 'dp' or 'lunas'

  // Slot tersedia
  var availableSlots = <Map<String, dynamic>>[].obs;
  var isLoadingSlots = false.obs;
  var selectedSlot = Rxn<Map<String, dynamic>>();

  // Payment method
  var selectedPaymentMethod = 'BANK_TRANSFER'.obs;
  var selectedBank = 'bri'.obs;

  // Payment method options
  final List<String> paymentMethods = ['BANK_TRANSFER', 'GOPAY'];
  final List<String> bankOptions = ['bri', 'bni', 'bca', 'mandiri', 'permata'];

  @override
  void onInit() {
    super.onInit();
    loadCartData();
  }

  @override
  void onReady() {
    super.onReady();
    loadCartData();
  }

  /// Load cart data and calculate totals
  Future<void> loadCartData() async {
    try {
      isLoading.value = true;
      final items = await CartService.getCartItems();
      cartItems.assignAll(items);
      calculateTotal();
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data: $e');
      cartItems.clear();
    } finally {
      isLoading.value = false;
    }
  }

  /// Calculate total price
  void calculateTotal() {
    double total = 0;

    try {
      for (var item in cartItems) {
        final promoAktif = item['promo_aktif'];
        double harga = 0;

        if (promoAktif != null && promoAktif['harga_diskon'] != null) {
          harga = _parseDouble(promoAktif['harga_diskon']);
        } else if (item['harga'] != null) {
          harga = _parseDouble(item['harga']);
        }

        final qty = _parseInt(item['quantity']) ?? 1;
        total += (harga * qty);
      }

      totalHarga.value = total;
      calculatePaymentAmount();
    } catch (e) {
      totalHarga.value = 0;
      totalPembayaran.value = 0;
    }
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  void calculatePaymentAmount() {
    if (paymentType.value == 'dp') {
      totalPembayaran.value = totalHarga.value * 0.5;
    } else {
      totalPembayaran.value = totalHarga.value;
    }
  }

  void changePaymentType(String type) {
    paymentType.value = type;
    calculatePaymentAmount();
  }

  void setPaymentMethod(String method) {
    selectedPaymentMethod.value = method;
  }

  void setBank(String bank) {
    selectedBank.value = bank;
  }

  Future<void> fetchSlots() async {
    if (cartItems.isEmpty) return;
    try {
      isLoadingSlots.value = true;
      selectedSlot.value = null;
      final tanggal = DateFormat('yyyy-MM-dd').format(selectedDate.value);
      final layananIds = cartItems.map((item) => item['id']).whereType<int>().toList();
      if (layananIds.isEmpty) return;
      final data = await _repository.getSlotTersedia(tanggal: tanggal, layananIds: layananIds);
      availableSlots.value = List<Map<String, dynamic>>.from(data['slots'] ?? []);
    } catch (e) {
      availableSlots.value = [];
    } finally {
      isLoadingSlots.value = false;
    }
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      selectedDate.value = picked;
      await fetchSlots();
    }
  }

  void selectSlot(Map<String, dynamic> slot) {
    selectedSlot.value = slot;
  }

  bool validateForm() {
    if (cartItems.isEmpty) {
      Get.snackbar('Error', 'Keranjang kosong');
      return false;
    }
    if (selectedSlot.value == null) {
      Get.snackbar('Error', 'Pilih jam booking terlebih dahulu');
      return false;
    }
    return true;
  }

  Future<void> processCheckout() async {
    if (!validateForm()) return;

    try {
      isLoading.value = true;

      final items = cartItems.map((item) {
        final promoAktif = item['promo_aktif'];
        double harga = 0;
        if (promoAktif != null && promoAktif['harga_diskon'] != null) {
          harga = _parseDouble(promoAktif['harga_diskon']);
        } else if (item['harga'] != null) {
          harga = _parseDouble(item['harga']);
        }
        return {
          'layanan_id': item['id'],
          'qty': _parseInt(item['quantity']) ?? 1,
          'harga': harga,
        };
      }).toList();

      final String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate.value);
      final String formattedTime = selectedSlot.value!['jam_mulai'] as String;

      final payload = {
        'tanggal_booking': formattedDate,
        'jam_booking': formattedTime,
        'jenis_pembayaran': paymentType.value,
        'items': items,
        'payment_type': selectedPaymentMethod.value,
        if (selectedPaymentMethod.value == 'BANK_TRANSFER') 'bank': selectedBank.value,
      };

      final result = await _repository.createBooking(payload);

      if (result.status) {
        // 1. Kosongkan Cart di Service (Storage)
        await CartService.clearCart();

        // 2. REFRESH CartController agar UI Keranjang ikut kosong
        if (Get.isRegistered<CartController>()) {
          Get.find<CartController>().loadCart();
        }

        // 3. Navigasi ke pembayaran
        _navigateToPaymentPage(result);
      } else {
        Get.snackbar('Error', result.message);
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void _navigateToPaymentPage(BookingModel? response) {
    if (response == null) return;
    if (selectedPaymentMethod.value == 'GOPAY') {
      Get.to(GopayPaymentPage(response: response.toJson()));
    } else {
      Get.to(PaymentPage(response: response.toJson()));
    }
  }

  String getPaymentMethodName(String method) => method == 'BANK_TRANSFER' ? 'Transfer Bank' : 'GoPay';
  String getBankName(String bank) => bank.toUpperCase();
}
