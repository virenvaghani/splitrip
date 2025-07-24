import 'dart:math';

import 'package:emoji_selector/emoji_selector.dart';
import 'package:get/get.dart';

class EmojiController extends GetxController {
  var selectedEmoji = Rx<EmojiData?>(null);

  @override
  void onInit() {
    super.onInit();
    // Only set default emoji if none is selected (e.g., for new trips)
    if (selectedEmoji.value == null) {
      selectedEmoji.value = getDefaultEmoji();
    }
  }

  void updateEmoji(EmojiData emoji) {
    selectedEmoji.value = emoji;
  }

  EmojiData? getEmojiDataByString(String? emojiString) {
    if (emojiString == null || emojiString.isEmpty) {
      print('Emoji string is null or empty, using default emoji');
      return _getDefaultEmoji();
    }

    // Log the raw emoji string for debugging
    print('Received emoji string: "$emojiString" (length: ${emojiString.length}, code units: ${emojiString.codeUnits})');

    // Check if emojiString is a valid emoji character
    if (RegExp(
      r'[\u{1F300}-\u{1F5FF}\u{1F600}-\u{1F64F}\u{1F680}-\u{1F6FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}\u{1F900}-\u{1FAFF}\u{FE0F}]'
          r'|[\u{1F1E6}-\u{1F1FF}]{2}'  // Regional indicators (flags)
          r'|[\u{1F466}-\u{1F469}][\u{1F3FB}-\u{1F3FF}]'  // Skin tone modifiers
          r'|\u{200D}[\u{1F466}-\u{1F469}\u{1F9D1}-\u{1F9D5}]', // Zero-width joiner sequences
      unicode: true,
    ).hasMatch(emojiString)) {
      print('Using raw emoji from database: $emojiString');
      return EmojiData(
        id: 'custom',
        char: emojiString,
        name: 'Custom Emoji',
        unified: 'custom',
        category: 'Custom',
        skin: 0,
      );
    }

    // Try to match unified code or name in _emojiList
    final matchedEmoji = _emojiList.firstWhere(
          (emoji) =>
      emoji['unified'].toLowerCase() == emojiString.toLowerCase() ||
          emoji['name'].toLowerCase() == emojiString.toLowerCase(),
      orElse: () {
        print('No matching emoji found for: "$emojiString", using default emoji');
        return _getDefaultMap();
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

  EmojiData getDefaultEmoji() {
    return _getDefaultEmoji();
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
  EmojiData _getDefaultEmoji() => EmojiData(
    id: 'luggage',
    char: '🧳',
    name: 'Luggage',
    unified: '1F9F3',
    category: 'Travel & Places',
    skin: 0,
  );

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
    {
      'id': 'sunglasses',
      'char': '😎',
      'name': 'Smiling Face with Sunglasses',
      'unified': '1F60E',
      'category': 'Smileys & People',
      'skin': 0,
    },
    {
      'id': 'beach',
      'char': '🏖️',
      'name': 'Beach with Umbrella',
      'unified': '1F3D6-FE0F',
      'category': 'Travel & Places',
      'skin': 0,
    },
    {
      'id': 'airplane',
      'char': '✈️',
      'name': 'Airplane',
      'unified': '2708-FE0F',
      'category': 'Travel & Places',
      'skin': 0,
    },
    {
      'id': 'camera',
      'char': '📸',
      'name': 'Camera with Flash',
      'unified': '1F4F8',
      'category': 'Objects',
      'skin': 0,
    },
    {
      'id': 'world_map',
      'char': '🗺️',
      'name': 'World Map',
      'unified': '1F5FA-FE0F',
      'category': 'Travel & Places',
      'skin': 0,
    },
    {
      'id': 'compass',
      'char': '🧭',
      'name': 'Compass',
      'unified': '1F9ED',
      'category': 'Travel & Places',
      'skin': 0,
    },
  ];
}