import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomSnackBar {
  static void show({
    required String title,
    required String message,
    SnackPosition position = SnackPosition.TOP,
    Duration duration = const Duration(seconds: 2),
    Color? backgroundColor,
    Color? textColor,
    double borderRadius = 10,
    EdgeInsets margin = const EdgeInsets.all(16),
  }) {
    Get.snackbar(
      title,
      message,
      titleText: Text(
        title,
        style: Get.theme.textTheme.titleMedium?.copyWith(
          color: textColor ?? Get.theme.colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      messageText: Text(
        message,
        style: Get.theme.textTheme.bodyMedium?.copyWith(
          color: textColor ?? Get.theme.colorScheme.onSurface,
        ),
      ),
      backgroundColor: backgroundColor ?? Get.theme.colorScheme.surface,
      colorText: textColor ?? Get.theme.colorScheme.onSurface,
      snackPosition: position,
      borderRadius: borderRadius,
      margin: margin,
      duration: duration,
      borderWidth: 1,
      borderColor: Get.theme.colorScheme.primary.withOpacity(0.2),
      boxShadows: [
        BoxShadow(
          color: Get.theme.colorScheme.primary.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
      animationDuration: const Duration(milliseconds: 300),
      barBlur: 10,
    );
  }
}
