import 'package:intl/intl.dart';

String formatPrice(double price) {
  final formatter = NumberFormat('#,###', 'id_ID'); // Format Indonesia
  return formatter.format(price);
}

String formatCurrency(String priceString) {
  // Mengonversi string ke double
  double? price = double.tryParse(priceString);

  // Jika konversi berhasil, format menjadi IDR
  if (price != null) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID', // Format Indonesia
      symbol: 'Rp.', // Simbol Rp
      decimalDigits: 2, // 2 digit setelah koma
    );
    return formatter.format(price); // Mengembalikan harga dalam format Rp.
  } else {
    return "Invalid Price"; // Jika format tidak valid
  }
}
