import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../style/app_color.dart'; // tambahkan ini untuk akses AppColor

class InputTextFormField extends StatefulWidget {
  final TextEditingController controller;
  final bool isSecureField;
  final bool autoCorrect;
  final String? hint;
  final EdgeInsets? contentPadding;
  final String? Function(String?)? validation;
  final double hintTextSize;
  final bool enable;
  final TextInputAction? textInputAction;
  final Function(String)? onFieldSubmitted;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  // Tambahan properti visual
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Color? fillColor;
  final Color? hintColor;
  final Color? borderColor;
  final double borderRadius;

  const InputTextFormField({
    super.key,
    required this.controller,
    this.isSecureField = false,
    this.autoCorrect = false,
    this.enable = true,
    this.hint,
    this.validation,
    this.contentPadding,
    this.textInputAction,
    this.hintTextSize = 14,
    this.onFieldSubmitted,
    this.keyboardType,
    this.inputFormatters,
    this.prefixIcon,
    this.suffixIcon,
    this.fillColor,
    this.hintColor,
    this.borderColor,
    this.borderRadius = 12.0,
  });

  @override
  State<InputTextFormField> createState() => _InputTextFormFieldState();
}

class _InputTextFormFieldState extends State<InputTextFormField> {
  bool _passwordVisible = false;

  void _togglePasswordVisibility() {
    setState(() {
      _passwordVisible = !_passwordVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isSecureField && !_passwordVisible,
      enableSuggestions: !widget.isSecureField,
      autocorrect: widget.autoCorrect,
      validator: widget.validation ?? (_) => null,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      enabled: widget.enable,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onFieldSubmitted,
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
      decoration: InputDecoration(
        filled: true,
        fillColor: widget.fillColor ?? Colors.white,
        hintText: widget.hint,
        hintStyle: TextStyle(
          fontSize: widget.hintTextSize,
          color: widget.hintColor ?? AppColor.whiteGrey,
        ),
        contentPadding: widget.contentPadding ?? const EdgeInsets.all(16.0),
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.isSecureField
            ? IconButton(
                icon: Icon(
                  _passwordVisible ? Icons.visibility : Icons.visibility_off,
                  color: AppColor.whiteGrey,
                ),
                onPressed: _togglePasswordVisibility,
              )
            : widget.suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(
            color: widget.borderColor ?? Colors.transparent,
            width: 0.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(
            color: widget.borderColor ?? Colors.transparent,
            width: 0.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(
            color: AppColor.primary.withOpacity(0.6),
            width: 1.2,
          ),
        ),
      ),
    );
  }
}
