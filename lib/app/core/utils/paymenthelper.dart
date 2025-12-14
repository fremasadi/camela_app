/// Helper class untuk format data pembayaran
/// Digunakan untuk standardisasi data antara Checkout dan History
class PaymentDataHelper {
  /// Format data dari response checkout (BookingModel)
  static Map<String, dynamic> fromCheckoutResponse(Map<String, dynamic> response) {
    return {
      'booking': response['booking'] ?? response,
      'pembayaran': response['pembayaran'] ?? response['payment'],
      'order_id': response['order_id'],
      'total_pembayaran': response['total_pembayaran'],
    };
  }

  /// Format data dari history booking
  static Map<String, dynamic> fromHistoryBooking(Map<String, dynamic> booking) {
    final pembayaran = booking['pembayaran'];

    return {
      'booking': {
        'id': booking['id'],
        'order_id': booking['order_id'],
        'tanggal_booking': booking['tanggal_booking'],
        'jam_booking': booking['jam_booking'],
        'status': booking['status'],
        'total_harga': booking['total_harga'],
        'jenis_pembayaran': booking['jenis_pembayaran'],
        'total_pembayaran': booking['total_pembayaran'],
        'details': booking['details'],
      },
      'pembayaran': {
        'id': pembayaran?['id'],
        'booking_id': pembayaran?['booking_id'],
        'order_id': pembayaran?['order_id'],
        'transaction_id': pembayaran?['transaction_id'],
        'gross_amount': pembayaran?['gross_amount'],
        'transaction_status': pembayaran?['transaction_status'],
        'fraud_status': pembayaran?['fraud_status'],
        'payment_type': pembayaran?['payment_type'],
        'payment_gateway': pembayaran?['payment_gateway'],
        'bank': pembayaran?['bank'],
        'va_number': pembayaran?['va_number'],
        'qr_url': pembayaran?['qr_url'],
        'deeplink_url': pembayaran?['deeplink_url'],
        'payment_url': pembayaran?['payment_url'],
        'payment_date': pembayaran?['payment_date'],
        'transaction_time': pembayaran?['transaction_time'],
        'settlement_time': pembayaran?['settlement_time'],
        'expired_at': pembayaran?['expired_at'],
        'is_paid': pembayaran?['is_paid'],
        'is_expired': pembayaran?['is_expired'],
        'status_label': pembayaran?['status_label'],
      },
      'order_id': booking['order_id'],
      'total_pembayaran': booking['total_pembayaran'],
    };
  }

  /// Get safe value dari nested map
  static dynamic getSafeValue(Map<String, dynamic>? data, String key, [dynamic defaultValue]) {
    if (data == null) return defaultValue;
    return data[key] ?? defaultValue;
  }

  /// Get payment data dengan fallback
  static Map<String, dynamic>? getPaymentData(Map<String, dynamic> response) {
    // Try to get from 'pembayaran' key first
    if (response.containsKey('pembayaran') && response['pembayaran'] != null) {
      return response['pembayaran'] as Map<String, dynamic>;
    }

    // Try to get from 'payment' key
    if (response.containsKey('payment') && response['payment'] != null) {
      return response['payment'] as Map<String, dynamic>;
    }

    // Check if response itself contains payment fields
    if (response.containsKey('payment_type')) {
      return response;
    }

    return null;
  }

  /// Get booking data dengan fallback
  static Map<String, dynamic>? getBookingData(Map<String, dynamic> response) {
    // Try to get from 'booking' key first
    if (response.containsKey('booking') && response['booking'] != null) {
      return response['booking'] as Map<String, dynamic>;
    }

    // Check if response itself contains booking fields
    if (response.containsKey('order_id')) {
      return response;
    }

    return null;
  }
}