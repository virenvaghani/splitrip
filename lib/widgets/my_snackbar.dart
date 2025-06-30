import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomSnackBar {
  static void show({
    required String title,
    required String message,
    SnackPosition position = SnackPosition.TOP,
    Duration duration = const Duration(seconds: 3),
    Color? backgroundColor,
    Color? textColor,
    double borderRadius = 16,
    EdgeInsets margin = const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  }) {
    Get.snackbar(
      '',
      '',
      titleText: Row(
        children: [
          Icon(Icons.notifications_none_rounded, color: textColor ?? Get.theme.colorScheme.onSurface, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: Get.theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: textColor ?? Get.theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
      messageText: Padding(
        padding: const EdgeInsets.only(left: 30.0),
        child: Text(
          message,
          style: Get.theme.textTheme.bodyMedium?.copyWith(
            color: textColor ?? Get.theme.colorScheme.onSurface,
          ),
        ),
      ),
      backgroundColor: backgroundColor ?? Get.theme.colorScheme.surface.withOpacity(0.95),
      colorText: textColor ?? Get.theme.colorScheme.onSurface,
      snackPosition: position,
      borderRadius: borderRadius,
      margin: margin,
      duration: duration,
      borderColor: Get.theme.colorScheme.primary.withOpacity(0.15),
      borderWidth: 1,
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
      barBlur: 16,
      overlayBlur: 0,
      isDismissible: true,
      animationDuration: const Duration(milliseconds: 300),
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeIn,
    );
  }
}
