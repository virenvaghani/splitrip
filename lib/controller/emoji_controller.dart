import 'dart:math';

import 'package:emoji_selector/emoji_selector.dart';
import 'package:get/get.dart';

class EmojiController extends GetxController {
  var selectedEmoji = Rx<EmojiData?>(null);

  @override
  void onInit() {
    super.onInit();
    selectedEmoji.value = getRandomEmoji();
  }

  void updateEmoji(EmojiData emoji) {
    selectedEmoji.value = emoji;
  }

  EmojiData? getEmojiDataByString(String? emojiString) {
    if (emojiString == null || emojiString.isEmpty) {
      return _getDefaultEmoji();
    }

    final matchedEmoji = _emojiList.firstWhere(
          (emoji) => emoji['char'] == emojiString || emoji['unified'] == emojiString,
      orElse: () => _getDefaultMap(),
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

  EmojiData getRandomEmoji() {
    final random = Random();
    final randomEmoji = _emojiList[random.nextInt(_emojiList.length)];
    return EmojiData(
      id: randomEmoji['id'] ?? 'unknown',
      char: randomEmoji['char'] ?? '😀',
      name: randomEmoji['name'] ?? 'Unknown',
      unified: randomEmoji['unified'] ?? '1F600',
      category: randomEmoji['category'] ?? 'Unknown',
      skin: randomEmoji['skin'] ?? 0,
    );
  }

  // Helpers
  EmojiData _getDefaultEmoji() => getEmojiDataByString('🧳')!;

  Map<String, dynamic> _getDefaultMap() => {
    'id': 'default',
    'char': '😀',
    'name': 'Default Emoji',
    'unified': '1F600',
    'category': 'Smileys & People',
    'skin': 0,
  };

  List<Map<String, dynamic>> get _emojiList => [
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
}
