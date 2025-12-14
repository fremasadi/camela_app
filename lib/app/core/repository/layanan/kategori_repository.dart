import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../utils/url.dart';

class KategoriRepository {
  /// Ambil daftar kategori layanan dari server
  static Future<List<Map<String, dynamic>>> getKategori() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception(
          'Token tidak ditemukan. Silakan login terlebih dahulu.',
        );
      }

      final response = await http.get(
        Uri.parse(AppUrl.kategori),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['data'] != null) {
        // Kembalikan list kategori
        return List<Map<String, dynamic>>.from(data['data']);
        print(data);
      } else {
        throw Exception(data['message'] ?? 'Gagal mengambil kategori');
      }
    } catch (e) {
      print('Terjadi kesalahan saat ambil kategori: $e');
      return [];
    }
  }
}
