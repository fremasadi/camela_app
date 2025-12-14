class AppUrl {
  // 🌐 Base URL utama API kamu
  static const String baseUrl = 'http://192.168.1.7:8080/api';
  static const String imageUrl = 'http://192.168.1.7:8080/storage';

  // 🧩 Auth Endpoints
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  static const String logout = '$baseUrl/auth/logout';

  static const String kategori = '$baseUrl/kategori-layanan';
  static const String layanan = '$baseUrl/layanan';

  // Booking
  static const String booking = '$baseUrl/booking';
}
