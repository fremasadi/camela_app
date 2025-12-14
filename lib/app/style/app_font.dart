import 'package:flutter/material.dart';

class AppFont {
  static const String _fontFamily = 'Raleway';

  // Regular
  static TextStyle regular(
    double size, {
    Color? color,
    double? height,
    TextDecoration? decoration, // 🔹 Tambahkan parameter decoration
  }) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w400,
      fontSize: size,
      height: height,
      color: color,
      decoration: decoration, // 🔹 Gunakan di sini
    );
  }

  // Medium
  static TextStyle medium(double size, {Color? color, double? height}) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w500,
      fontSize: size,
      height: height,
      color: color,
    );
  }

  // SemiBold
  static TextStyle semiBold(double size, {Color? color, double? height}) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w600,
      fontSize: size,
      height: height,
      color: color,
    );
  }

  // Bold
  static TextStyle bold(double size, {Color? color, double? height}) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w700,
      fontSize: size,
      height: height,
      color: color,
    );
  }
}
