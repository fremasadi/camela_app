import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/url.dart';

class LayananRepository {
  /// Mengambil semua layanan
  static Future<List<Map<String, dynamic>>> getLayanan() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception(
          'Token tidak ditemukan. Silakan login terlebih dahulu.',
        );
      }

      final response = await http.get(
        Uri.parse(AppUrl.layanan),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        // Ambil data dari response
        final List<dynamic> data = jsonResponse['data'] ?? [];

        // Konversi ke List<Map<String, dynamic>>
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Sesi telah berakhir. Silakan login kembali.');
      } else {
        throw Exception('Gagal mengambil data layanan: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error saat mengambil data layanan: $e');
    }
  }

  /// Mengambil detail layanan berdasarkan ID
  static Future<Map<String, dynamic>> getLayananById(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception(
          'Token tidak ditemukan. Silakan login terlebih dahulu.',
        );
      }

      final response = await http.get(
        Uri.parse('${AppUrl.layanan}/$id'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse['data'] ?? {};
      } else if (response.statusCode == 401) {
        throw Exception('Sesi telah berakhir. Silakan login kembali.');
      } else if (response.statusCode == 404) {
        throw Exception('Layanan tidak ditemukan.');
      } else {
        throw Exception(
          'Gagal mengambil detail layanan: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error saat mengambil detail layanan: $e');
    }
  }

  /// Filter layanan berdasarkan kategori
  static List<Map<String, dynamic>> filterByKategori(
    List<Map<String, dynamic>> layananList,
    int? kategoriId,
  ) {
    if (kategoriId == null) {
      return layananList; // Return semua jika tidak ada filter
    }

    return layananList.where((layanan) {
      final kategori = layanan['kategori'] as Map<String, dynamic>?;
      return kategori?['id'] == kategoriId;
    }).toList();
  }
}
