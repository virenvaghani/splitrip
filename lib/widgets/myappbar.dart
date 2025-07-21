import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final  bool? CenterTitle;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this. CenterTitle = true, TextStyle? titleTextStyle, required bool centerTitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      title: Stack(
        children: [
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
            ),
          ),
          Text(title, style: theme.textTheme.headlineSmall),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withValues(alpha: 0.3),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      centerTitle: CenterTitle,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
