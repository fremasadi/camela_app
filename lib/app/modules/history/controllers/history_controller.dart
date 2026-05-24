import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/repository/booking/booking_repository.dart';
import '../../checkout/views/gopay_payment_page.dart';
import '../../checkout/views/payment_page.dart';

class HistoryController extends GetxController {
  final BookingRepository _bookingRepository = BookingRepository();

  var isLoading = false.obs;
  var bookingHistory = <Map<String, dynamic>>[].obs;
  var errorMessage = ''.obs;

  // Filter tabs
  var selectedTab = 'all'.obs; // all, pending, confirmed, cancelled

  @override
  void onInit() {
    super.onInit();
    fetchBookingHistory();
  }

  /// Fetch booking history from API
  Future<void> fetchBookingHistory() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _bookingRepository.getBookingHistory();
      bookingHistory.value = result;
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Gagal memuat riwayat booking: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh booking history
  Future<void> refreshHistory() async {
    await fetchBookingHistory();
  }

  /// Filter bookings by status
  List<Map<String, dynamic>> get filteredBookings {
    if (selectedTab.value == 'all') {
      return bookingHistory;
    }

    return bookingHistory.where((booking) {
      final bookingData = booking['booking'] as Map<String, dynamic>? ?? {};
      final status = bookingData['status']?.toString().toLowerCase();
      return status == selectedTab.value;
    }).toList();
  }

  /// Select filter tab
  void selectTab(String tab) {
    selectedTab.value = tab;
  }

  /// Get status color
  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// Get status label
  String getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return 'Dikonfirmasi';
      case 'pending':
        return 'Menunggu';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  /// Normalisasi data history agar sesuai format payment page
  Map<String, dynamic> _normalizeBookingData(Map<String, dynamic> historyItem) {
    final bookingData = historyItem['booking'] as Map<String, dynamic>? ?? {};
    final paymentData = historyItem['payment'] as Map<String, dynamic>? ?? {};

    return {
      'status': true,
      'message': 'Continue payment from history',
      'data': {
        'booking_id': historyItem['booking_id'],
        'order_id': historyItem['order_id'],
        'total_harga': historyItem['total_harga'],
        'total_pembayaran': historyItem['total_pembayaran'],
        'jenis_pembayaran': historyItem['jenis_pembayaran'],
        'booking': {
          ...bookingData,
          'total_harga': bookingData['total_harga'].toString(),
          'total_pembayaran': bookingData['total_pembayaran'].toString(),
        },
        'payment': {
          ...paymentData,
          'gross_amount': paymentData['gross_amount'].toString(),
        },
      },
    };
  }

  /// Navigate to payment page based on payment type
  void navigateToPayment(Map<String, dynamic> booking) {
    final payment = booking['payment'];

    if (payment == null) {
      Get.snackbar('Error', 'Data pembayaran tidak tersedia');
      return;
    }

    if (payment['is_paid'] == true) {
      Get.snackbar('Info', 'Pembayaran sudah selesai');
      return;
    }

    final formattedResponse = _normalizeBookingData(booking);
    final paymentType = payment['payment_type'];

    try {
      if (paymentType == 'GOPAY') {
        Get.to(() => GopayPaymentPage(response: formattedResponse));
      } else {
        Get.to(() => PaymentPage(response: formattedResponse));
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal membuka halaman pembayaran');
    }
  }

  /// Count bookings by status
  int countByStatus(String status) {
    if (status == 'all') return bookingHistory.length;

    return bookingHistory.where((booking) {
      final bookingData = booking['booking'] as Map<String, dynamic>? ?? {};
      // Perbaikan: gunakan toLowerCase agar tidak bug jika API mengirim "Pending"
      return bookingData['status']?.toString().toLowerCase() == status;
    }).length;
  }
}
