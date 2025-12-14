class PriceFormatter {
  /// Format angka menjadi ribuan, contoh: 100000 -> 100.000
  static String price(num value) {
    // pastikan ke double dulu, lalu bulatkan
    final rounded = value.toDouble().toStringAsFixed(0);

    return rounded.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}
