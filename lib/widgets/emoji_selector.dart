import 'package:emoji_selector/emoji_selector.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/trip/emoji_controller.dart';

class EmojiSelectorBottomSheet extends StatelessWidget {
  const EmojiSelectorBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final EmojiController emojiController = Get.find<EmojiController>();

    return Wrap(
      children: [
        Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha:
                  0.3,
                ), // Match CreateTrip subtle colors
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            // Header with title and close button
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select an Emoji',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color:
                          theme
                              .colorScheme
                              .onSurface, // Match CreateTrip text color
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,// Match CreateTrip delete icon
                      size: 24, // Match CreateTrip icon size
                    ),
                    onPressed: () => Navigator.pop(context),
                    splashRadius: 20, // Match CreateTrip icon button
                    tooltip: 'Close', // Add tooltip for accessibility
                  ),
                ],
              ),
            ),
            AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(
                milliseconds: 200,
              ), // Match CreateTrip animation
              child: Container(
                margin: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.1),
                      theme.colorScheme.secondary.withValues(alpha: 0.1),
                    ], // Match CreateTrip gradient
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(
                    12,
                  ), // Match CreateTrip radius
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  ),
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
      ],
    );
  }
}
