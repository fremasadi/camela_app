class AppUrl {
  // 🌐 Base URL utama API kamu
  static const String baseUrl = 'https://b7c2-208-76-40-198.ngrok-free.app/api';
  static const String imageUrl = 'https://b7c2-208-76-40-198.ngrok-free.app/storage';
  // 🧩 Auth Endpoints
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  static const String logout = '$baseUrl/auth/logout';

  static const String kategori = '$baseUrl/kategori-layanan';
  static const String layanan = '$baseUrl/layanan';

  // Booking
  static const String booking = '$baseUrl/booking';
}
