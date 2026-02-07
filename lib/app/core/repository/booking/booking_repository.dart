import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../model/booking.dart';
import '../../utils/url.dart';

class BookingRepository {
  /// Create new booking
  Future<BookingModel> createBooking(Map<String, dynamic> payload) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception(
          'Token tidak ditemukan. Silakan login terlebih dahulu.',
        );
      }

      final response = await http.post(
        Uri.parse('${AppUrl.baseUrl}/bookings'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(payload),
      );

      final Map<String, dynamic> data = json.decode(response.body);
      print('token $token');
      print('data ${json.encode(payload)}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return BookingModel.fromJson(data);
      } else {
        throw Exception(data['message'] ?? 'Gagal membuat booking');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Get booking history
  Future<List<Map<String, dynamic>>> getBookingHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception(
          'Token tidak ditemukan. Silakan login terlebih dahulu.',
        );
      }

      final response = await http.get(
        Uri.parse('${AppUrl.baseUrl}/bookings/history'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final Map<String, dynamic> data = json.decode(response.body);

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      } else {
        throw Exception(data['message'] ?? 'Gagal memuat riwayat booking');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Get booking detail
  Future<Map<String, dynamic>> getBookingDetail(int bookingId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception(
          'Token tidak ditemukan. Silakan login terlebih dahulu.',
        );
      }

      final response = await http.get(
        Uri.parse('${AppUrl.baseUrl}/bookings/$bookingId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final Map<String, dynamic> data = json.decode(response.body);

      if (response.statusCode == 200) {
        return data['data'];
      } else {
        throw Exception(data['message'] ?? 'Gagal memuat detail booking');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Check payment status
  Future<Map<String, dynamic>> checkPaymentStatus(int bookingId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception(
          'Token tidak ditemukan. Silakan login terlebih dahulu.',
        );
      }

      final response = await http.get(
        Uri.parse('${AppUrl.baseUrl}/bookings/check-status/$bookingId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final Map<String, dynamic> data = json.decode(response.body);

      if (response.statusCode == 200) {
        return data['data'];
      } else {
        throw Exception(data['message'] ?? 'Gagal cek status pembayaran');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Check status by order ID
  Future<Map<String, dynamic>> checkStatus(String orderId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception(
          'Token tidak ditemukan. Silakan login terlebih dahulu.',
        );
      }

      final response = await http.get(
        Uri.parse('${AppUrl.baseUrl}/bookings/check/$orderId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final Map<String, dynamic> data = json.decode(response.body);

      if (response.statusCode == 200) {
        return data['data'];
      } else {
        throw Exception(data['message'] ?? 'Gagal cek status booking');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
