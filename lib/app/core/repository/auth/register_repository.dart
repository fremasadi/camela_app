import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:camela_app/app/core/utils/url.dart';

class RegisterRepository {
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String noTelp,
  }) async {
    final url = Uri.parse(AppUrl.register);

    try {
      final response = await http.post(
        url,
        headers: {'Accept': 'application/json'},
        body: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
          'no_telp': noTelp,
        },
      );

      final data = json.decode(response.body);

      // 🔹 Perbaikan di sini: terima 200 atau 201
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('user', json.encode(data['user']));

        return {
          'success': true,
          'message': data['message'] ?? 'Registrasi berhasil',
          'token': data['token'],
          'user': data['user'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Registrasi gagal',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan koneksi: $e'};
    }
  }
}
