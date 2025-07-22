import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/loginButton/button_controller.dart';

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
  final bool showLoadingIndicator;

  const CustomAnimatedButton({
    super.key,
    required this.buttonId,
    required this.onTap,
    this.icon,
    this.backgroundColor = Colors.transparent,
    this.foregroundColor = Colors.black87,
    this.borderRadius = 12.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.minimumSize = const Size(0, 48),
    this.useGradient = false,
    this.gradientColors,
    this.borderColor,
    this.semanticsLabel,
    this.showLoadingIndicator = false,
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
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.identity()..scale(buttonState.getScale(buttonId)),
        child: Container(
          constraints: BoxConstraints(minHeight: minimumSize.height),
          width: minimumSize.width == 0 ? null : minimumSize.width,
          padding: padding,
          decoration: BoxDecoration(
            color: useGradient ? null : backgroundColor,
            gradient: useGradient
                ? LinearGradient(
              colors: gradientColors ??
                  [
                    theme.colorScheme.primary.withValues(alpha: 0.1),
                    theme.colorScheme.secondary.withValues(alpha: 0.1),
                  ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
                : null,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: borderColor ??
                  theme.colorScheme.outline.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Center(
            child: Semantics(
              label: semanticsLabel ?? 'Minimal Button',
              child: buttonState.getIsLoading(buttonId) && showLoadingIndicator
                  ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    foregroundColor,
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
    );
  }
}
