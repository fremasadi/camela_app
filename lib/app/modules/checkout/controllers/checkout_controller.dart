import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/model/booking.dart';
import '../../../core/repository/booking/booking_repository.dart';
import '../../../core/services/cart_service.dart';
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

  /// Load cart data and calculate totals
  Future<void> loadCartData() async {
    try {
      isLoading.value = true;
      final items = await CartService.getCartItems();
      cartItems.value = items;
      calculateTotal();
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data: $e');
      cartItems.value = [];
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

        // Safely get price
        if (promoAktif != null && promoAktif['harga_diskon'] != null) {
          harga = _parseDouble(promoAktif['harga_diskon']);
        } else if (item['harga'] != null) {
          harga = _parseDouble(item['harga']);
        }

        // Safely get quantity
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

  /// Helper method to safely parse double
  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  /// Helper method to safely parse int
  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  /// Calculate payment amount based on type
  void calculatePaymentAmount() {
    if (paymentType.value == 'dp') {
      totalPembayaran.value = totalHarga.value * 0.5; // DP 50%
    } else {
      totalPembayaran.value = totalHarga.value; // Lunas 100%
    }
  }

  /// Change payment type (dp/lunas)
  void changePaymentType(String type) {
    paymentType.value = type;
    calculatePaymentAmount();
  }

  /// Set payment method
  void setPaymentMethod(String method) {
    selectedPaymentMethod.value = method;
  }

  /// Set bank
  void setBank(String bank) {
    selectedBank.value = bank;
  }

  /// Select date
  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      selectedDate.value = picked;
    }
  }

  /// Select time
  Future<void> selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime.value,
    );

    if (picked != null) {
      selectedTime.value = picked;
    }
  }

  /// Validate form
  bool validateForm() {
    if (cartItems.isEmpty) {
      Get.snackbar('Error', 'Keranjang kosong');
      return false;
    }

    if (selectedPaymentMethod.value == 'BANK_TRANSFER' &&
        (selectedBank.value.isEmpty || selectedBank.value == '')) {
      Get.snackbar('Error', 'Pilih bank untuk transfer');
      return false;
    }

    return true;
  }

  /// Process checkout
  Future<void> processCheckout() async {
    if (!validateForm()) return;

    try {
      isLoading.value = true;

      // Prepare items for API
      final items = cartItems
          .map((item) {
            final promoAktif = item['promo_aktif'];
            double harga = 0;

            if (promoAktif != null && promoAktif['harga_diskon'] != null) {
              harga = _parseDouble(promoAktif['harga_diskon']);
            } else if (item['harga'] != null) {
              harga = _parseDouble(item['harga']);
            }

            final layananId = item['id'];
            if (layananId == null) return null;

            return {
              'layanan_id': layananId,
              'qty': _parseInt(item['quantity']) ?? 1,
              'harga': harga,
            };
          })
          .where((item) => item != null)
          .toList();

      if (items.isEmpty) {
        Get.snackbar('Error', 'Tidak ada item valid untuk checkout');
        return;
      }

      // Format date and time
      final String formattedDate = DateFormat(
        'yyyy-MM-dd',
      ).format(selectedDate.value);
      final String formattedTime =
          '${selectedTime.value.hour.toString().padLeft(2, '0')}:${selectedTime.value.minute.toString().padLeft(2, '0')}';

      // Prepare payload
      final payload = {
        'tanggal_booking': formattedDate,
        'jam_booking': formattedTime,
        'jenis_pembayaran': paymentType.value,
        'items': items,
        'payment_type': selectedPaymentMethod.value,
        if (selectedPaymentMethod.value == 'BANK_TRANSFER')
          'bank': selectedBank.value,
      };

      // Submit booking
      final result = await _repository.createBooking(payload);

      if (result.status) {
        // Clear cart after successful booking
        await CartService.clearCart();

        // Navigate to payment page
        _navigateToPaymentPage(result);
      } else {
        Get.snackbar('Error', result.message);
      }
    } catch (e, stackTrace) {
      Get.snackbar('Error', 'Terjadi kesalahan: ${e.toString()} $stackTrace');
    } finally {
      isLoading.value = false;
    }
  }

  /// Navigate to appropriate payment page
  void _navigateToPaymentPage(BookingModel? response) {
    if (response == null) {
      Get.snackbar('Error', 'Data booking tidak valid');
      return;
    }

    try {
      final paymentType = selectedPaymentMethod.value;

      if (paymentType == 'GOPAY') {
        Get.to(GopayPaymentPage(response: response.toJson()));
      } else {
        Get.to(PaymentPage(response: response.toJson())); // or response.toMap()
      }
    } catch (e, stackTrace) {
      Get.snackbar('Error', 'Gagal membuka halaman pembayaran: $e $stackTrace');
    }
  }

  /// Get payment method name in Indonesian
  String getPaymentMethodName(String method) {
    switch (method) {
      case 'BANK_TRANSFER':
        return 'Transfer Bank';
      case 'GOPAY':
        return 'GoPay';
      default:
        return method;
    }
  }

  /// Get bank name
  String getBankName(String bank) {
    switch (bank.toLowerCase()) {
      case 'bri':
        return 'Bank BRI';
      case 'bni':
        return 'Bank BNI';
      case 'bca':
        return 'Bank BCA';
      case 'mandiri':
        return 'Bank Mandiri';
      case 'permata':
        return 'Bank Permata';
      default:
        return bank.toUpperCase();
    }
  }
}
