import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/repository/booking/booking_repository.dart';

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
    return bookingHistory
        .where((booking) => booking['status'] == selectedTab.value)
        .toList();
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

  /// Navigate to payment page based on payment type
  void navigateToPayment(Map<String, dynamic> booking) {
    final pembayaran = booking['pembayaran'];
    if (pembayaran == null) {
      Get.snackbar(
        'Error',
        'Data pembayaran tidak tersedia',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final paymentType = pembayaran['payment_type'];

    if (paymentType == 'GOPAY') {
      Get.toNamed('/gopay-payment', arguments: booking);
    } else {
      Get.toNamed('/payment', arguments: booking);
    }
  }

  /// Count bookings by status
  int countByStatus(String status) {
    if (status == 'all') return bookingHistory.length;
    return bookingHistory.where((b) => b['status'] == status).length;
  }
}