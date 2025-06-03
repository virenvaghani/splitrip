import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/button_controller.dart';

class CustomAnimatedButton extends StatelessWidget {
  final String buttonId;
  final VoidCallback onTap;
  final Widget? icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final double borderRadius;
  final EdgeInsets padding;
  final Size minimumSize;
  final bool useGradient;
  final List<Color>? gradientColors;
  final Color? borderColor;
  final String? semanticsLabel;
  final bool
  showLoadingIndicator; // Added to control loading indicator visibility

  const CustomAnimatedButton({
    super.key,
    required this.buttonId,
    required this.onTap,
    this.icon,
    this.backgroundColor = Colors.white,
    this.foregroundColor = Colors.black87,
    this.borderRadius = 12.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.minimumSize = const Size(0, 48),
    this.useGradient = false,
    this.gradientColors,
    this.borderColor,
    this.semanticsLabel,
    this.showLoadingIndicator =
        true, // Default to true for backward compatibility
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonState = context.watch<ButtonState>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      buttonState.initButton(buttonId);
    });

    return GestureDetector(
      onTapDown: (_) => buttonState.onTapDown(buttonId),
      onTapUp: (_) {
        buttonState.onTapUp(buttonId);
        if (!buttonState.getIsLoading(buttonId)) {
          buttonState.setLoading(buttonId, true);
          onTap();
          buttonState.setLoading(buttonId, false);
        }
      },
      onTapCancel: () => buttonState.onTapCancel(buttonId),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()..scale(buttonState.getScale(buttonId)),
        child: Material(
          elevation: buttonState.getElevation(buttonId),
          borderRadius: BorderRadius.circular(borderRadius),
          shadowColor: theme.colorScheme.primary.withOpacity(0.3),
          child: Container(
            padding: padding,
            width: minimumSize.width == 0 ? null : minimumSize.width,
            height: minimumSize.height,
            decoration: BoxDecoration(
              color: useGradient ? null : backgroundColor,
              gradient:
                  useGradient
                      ? LinearGradient(
                        colors:
                            gradientColors ??
                            [
                              theme.colorScheme.primary.withOpacity(0.1),
                              theme.colorScheme.secondary.withOpacity(0.1),
                            ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                      : null,
              borderRadius: BorderRadius.circular(borderRadius),
              border:
                  borderColor != null
                      ? Border.all(color: borderColor!)
                      : Border.all(
                        color: theme.colorScheme.primary.withOpacity(0.2),
                      ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Semantics(
                label: semanticsLabel ?? 'Button',
                child:
                    buttonState.getIsLoading(buttonId) && showLoadingIndicator
                        ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.colorScheme.onPrimary,
                            ),
                          ),
                        )
                        : IconTheme(
                          data: IconThemeData(color: foregroundColor),
                          child: icon ?? const SizedBox.shrink(),
                        ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
