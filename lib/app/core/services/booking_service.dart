import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/url.dart';

class BookingService {
  /// Ambil token dari SharedPreferences
  static Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception(
        'Token tidak ditemukan. Silakan login terlebih dahulu.',
      );
    }

    return token;
  }

  /// -----------------------------
  /// GET REQUEST
  /// -----------------------------
  static Future<dynamic> get(String endpoint) async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse('${AppUrl.baseUrl}$endpoint'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    return jsonDecode(response.body);
  }

  /// -----------------------------
  /// POST REQUEST
  /// -----------------------------
  static Future<dynamic> post(
      String endpoint, Map<String, dynamic> data) async {
    final token = await _getToken();

    final response = await http.post(
      Uri.parse('${AppUrl.baseUrl}$endpoint'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    return jsonDecode(response.body);
  }

  /// -----------------------------
  /// PUT REQUEST
  /// -----------------------------
  static Future<dynamic> put(
      String endpoint, Map<String, dynamic> data) async {
    final token = await _getToken();

    final response = await http.put(
      Uri.parse('${AppUrl.baseUrl}$endpoint'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    return jsonDecode(response.body);
  }

  /// -----------------------------
  /// DELETE REQUEST
  /// -----------------------------
  static Future<dynamic> delete(String endpoint) async {
    final token = await _getToken();

    final response = await http.delete(
      Uri.parse('${AppUrl.baseUrl}$endpoint'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    return jsonDecode(response.body);
  }
}
