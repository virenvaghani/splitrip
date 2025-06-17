import 'dart:math';

import 'package:emoji_selector/emoji_selector.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class EmojiController extends GetxController {
  var selectedEmoji = Rx<EmojiData?>(null);

  @override
  void onInit() {
    super.onInit();
    selectedEmoji.value = _getRandomEmoji();
  }

  void updateEmoji(EmojiData emoji) {
    selectedEmoji.value = emoji;
  }

  // New method to find or create EmojiData from a string
  EmojiData? getEmojiDataByString(String? emojiString) {
    if (emojiString == null || emojiString.isEmpty) {
      return _getDefaultEmoji();
    }

    // Predefined emoji list (same as in _getRandomEmoji)
    final List<Map<String, dynamic>> emojiList = [
      {
        'id': 'smile',
        'char': '😊',
        'name': 'Smiling Face',
        'unified': '1F642',
        'category': 'Smileys & People',
        'skin': 0,
      },
      {
        'id': 'heart',
        'char': '❤️',
        'name': 'Red Heart',
        'unified': '2764-FE0F',
        'category': 'Smileys & People',
        'skin': 0,
      },
      {
        'id': 'star',
        'char': '⭐',
        'name': 'Star',
        'unified': '2B50',
        'category': 'Travel & Places',
        'skin': 0,
      },
      {
        'id': 'fire',
        'char': '🔥',
        'name': 'Fire',
        'unified': '1F525',
        'category': 'Travel & Places',
        'skin': 0,
      },
      {
        'id': 'thumbsup',
        'char': '👍',
        'name': 'Thumbs Up',
        'unified': '1F44D',
        'category': 'Smileys & People',
        'skin': 0,
      },
      {
        'id': 'party',
        'char': '🎉',
        'name': 'Party Popper',
        'unified': '1F389',
        'category': 'Activities',
        'skin': 0,
      },
      {
        'id': 'rocket',
        'char': '🚀',
        'name': 'Rocket',
        'unified': '1F680',
        'category': 'Travel & Places',
        'skin': 0,
      },
      {
        'id': 'sun',
        'char': '☀️',
        'name': 'Sun',
        'unified': '2600-FE0F',
        'category': 'Travel & Places',
        'skin': 0,
      },
      // Add the luggage emoji to the list
      {
        'id': 'luggage',
        'char': '🧳',
        'name': 'Luggage',
        'unified': '1F9F3',
        'category': 'Travel & Places',
        'skin': 0,
      },
    ];

    // Try to find the emoji by char or unified code
    final matchedEmoji = emojiList.firstWhere(
      (emoji) =>
          emoji['char'] == emojiString || emoji['unified'] == emojiString,
      orElse:
          () => {
            'id': 'default',
            'char': '😀',
            'name': 'Default Emoji',
            'unified': '1F600',
            'category': 'Smileys & People',
            'skin': 0,
          },
    );

    return EmojiData(
      id: matchedEmoji['id'] ?? 'unknown',
      char: matchedEmoji['char'] ?? '😀',
      name: matchedEmoji['name'] ?? 'Unknown',
      unified: matchedEmoji['unified'] ?? '1F600',
      category: matchedEmoji['category'] ?? 'Unknown',
      skin: matchedEmoji['skin'] ?? 0,
    );
  }

  EmojiData _getDefaultEmoji() {
    return EmojiData(
      id: 'luggage',
      char: '🧳',
      name: 'Luggage',
      unified: '1F9F3',
      category: 'Travel & Places',
      skin: 0,
    );
  }

  EmojiData _getRandomEmoji() {
    final List<Map<String, dynamic>> emojiList = [
      // Same list as above, including luggage
      {
        'id': 'smile',
        'char': '😊',
        'name': 'Smiling Face',
        'unified': '1F642',
        'category': 'Smileys & People',
        'skin': 0,
      },
      {
        'id': 'heart',
        'char': '❤️',
        'name': 'Red Heart',
        'unified': '2764-FE0F',
        'category': 'Smileys & People',
        'skin': 0,
      },
      {
        'id': 'star',
        'char': '⭐',
        'name': 'Star',
        'unified': '2B50',
        'category': 'Travel & Places',
        'skin': 0,
      },
      {
        'id': 'fire',
        'char': '🔥',
        'name': 'Fire',
        'unified': '1F525',
        'category': 'Travel & Places',
        'skin': 0,
      },
      {
        'id': 'thumbsup',
        'char': '👍',
        'name': 'Thumbs Up',
        'unified': '1F44D',
        'category': 'Smileys & People',
        'skin': 0,
      },
      {
        'id': 'party',
        'char': '🎉',
        'name': 'Party Popper',
        'unified': '1F389',
        'category': 'Activities',
        'skin': 0,
      },
      {
        'id': 'rocket',
        'char': '🚀',
        'name': 'Rocket',
        'unified': '1F680',
        'category': 'Travel & Places',
        'skin': 0,
      },
      {
        'id': 'sun',
        'char': '☀️',
        'name': 'Sun',
        'unified': '2600-FE0F',
        'category': 'Travel & Places',
        'skin': 0,
      },
      {
        'id': 'luggage',
        'char': '🧳',
        'name': 'Luggage',
        'unified': '1F9F3',
        'category': 'Travel & Places',
        'skin': 0,
      },
    ];

    if (emojiList.isEmpty) {
      return _getDefaultEmoji();
    }

    final random = Random();
    final randomEmoji = emojiList[random.nextInt(emojiList.length)];
    return EmojiData(
      id: randomEmoji['id'] ?? 'unknown',
      char: randomEmoji['char'] ?? '😀',
      name: randomEmoji['name'] ?? 'Unknown',
      unified: randomEmoji['unified'] ?? '1F600',
      category: randomEmoji['category'] ?? 'Unknown',
      skin: randomEmoji['skin'] ?? 0,
    );
  }
}
