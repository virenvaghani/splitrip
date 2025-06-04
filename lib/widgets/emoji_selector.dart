import 'package:emoji_selector/emoji_selector.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/emoji_controller.dart';

class EmojiSelectorBottomSheet extends StatelessWidget {
  const EmojiSelectorBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final EmojiController emojiController = Get.find<EmojiController>();

    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface, // Use surface color
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)), // Match CreateTrip radius
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.onSurface.withOpacity(0.05), // Match CreateTrip shadow
            blurRadius: 8,
            offset: const Offset(0, 4), // Match CreateTrip offset
          ),
        ],
      ),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(), // Match CreateTrip physics
        child: Column(
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withOpacity(0.3), // Match CreateTrip subtle colors
                borderRadius:  BorderRadius.circular(10),
              ),
            ),
            // Header with title and close button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select an Emoji',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface, // Match CreateTrip text color
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: theme.colorScheme.error, // Match CreateTrip delete icon
                      size: 24, // Match CreateTrip icon size
                    ),
                    onPressed: () => Navigator.pop(context),
                    splashRadius: 20, // Match CreateTrip icon button
                    tooltip: 'Close', // Add tooltip for accessibility
                  ),
                ],
              ),
            ),
            // Divider
            Container(
              height: 1,
              color: theme.colorScheme.onSurface.withOpacity(0.2), // Match CreateTrip subtle borders
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
            ),
            // Emoji selector with animation
            AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 200), // Match CreateTrip animation
              child: Container(
                margin: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withOpacity(0.1),
                      theme.colorScheme.secondary.withOpacity(0.1),
                    ], // Match CreateTrip gradient
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12), // Match CreateTrip radius
                  border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2))
                ),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: EmojiSelector(
                    padding: const EdgeInsets.all(12),
                    onSelected: (emoji) {
                      emojiController.updateEmoji(emoji);
                      Navigator.pop(context);
                    },
                    columns: 7,
                    withTitle: true,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}