import 'package:flutter/material.dart';
import '../../style/app_color.dart';

class InputFormButton extends StatelessWidget {
  final Function()? onClick; // <-- nullable
  final String? titleText;
  final Icon? icon;
  final Color? color;
  final Color? titleColor;
  final double? cornerRadius;
  final EdgeInsets padding;

  const InputFormButton({
    super.key,
    this.onClick, // <-- gak required lagi
    this.titleText,
    this.icon,
    this.color,
    this.titleColor,
    this.cornerRadius,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onClick, // bisa null = otomatis disabled
      style: ElevatedButton.styleFrom(
        padding: padding,
        backgroundColor: color ?? AppColor.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cornerRadius ?? 12.0),
        ),
      ),
      child: Text(
        titleText ?? '',
        style: TextStyle(
          color: titleColor ?? Colors.white,
          fontFamily: 'SemiBold',
        ),
      ),
    );
  }
}
