
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final List<TextInputFormatter>? inputFormatters;
  final Function(String)? onFieldSubmitted;
  final InputBorder? border;
  final InputBorder? enabledBorder;
  final InputBorder? errorBorder;
  final InputBorder? disabledBorder;
  final InputBorder? focusedBorder;
  final bool? filled;
  final Color? fillColor;
  final bool isEnabled;

  const CustomTextField({
    super.key,
    required this.hintText,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.textInputAction,
    this.focusNode,
    this.inputFormatters,
    this.onFieldSubmitted,
    this.border,
    this.disabledBorder,
    this.enabledBorder,
    this.errorBorder,
    this.focusedBorder,
    this.filled,
    this.fillColor,
    this.isEnabled=true


  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextField(

      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      onChanged: onChanged,
      textInputAction: textInputAction,
      focusNode: focusNode,
      inputFormatters: inputFormatters,
      onSubmitted: onFieldSubmitted,
      decoration: InputDecoration(
        enabled: isEnabled,
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(borderSide: BorderSide(width: 1.0),borderRadius: BorderRadius.circular(10.0)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(width: 1.0),borderRadius: BorderRadius.circular(10.0)),
        errorBorder:errorBorder,
        disabledBorder:OutlineInputBorder(borderSide: BorderSide(width: 1.0),borderRadius: BorderRadius.circular(10.0)),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(width: 1.0),borderRadius: BorderRadius.circular(10.0)),
        filled: filled,
        fillColor: fillColor,
      ),
      style: theme.textTheme.bodyLarge,
      cursorColor: theme.colorScheme.primary,
    );
  }
}