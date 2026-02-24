import 'dart:math';
import 'dart:convert';
import 'package:flutter/services.dart';

class GameEngine {
  late final Set<String> _dictionary;

  static const List<String> letterPool = [
    'ا',
    'ب',
    'ت',
    'ث',
    'ج',
    'ح',
    'خ',
    'د',
    'ر',
    'ز',
    'س',
    'ش',
    'ص',
    'ض',
    'ط',
    'ظ',
    'ع',
    'غ',
    'ف',
    'ق',
    'ك',
    'ل',
    'م',
    'ن',
    'هـ',
    'و',
    'ي',
  ];

  List<String> generateHand({
    int size = 15,
    int maxRepeats = 2,
    Random? random,
  }) {
    final rng = random ?? Random();
    final hand = <String>[];
    final counts = <String, int>{};

    while (hand.length < size) {
      final letter = letterPool[rng.nextInt(letterPool.length)];
      final count = counts[letter] ?? 0;
      if (count >= maxRepeats) {
        continue;
      }
      counts[letter] = count + 1;
      hand.add(letter);
    }

    return hand;
  }

  Future<void> loadDictionary() async {
    final jsonStr =
        await rootBundle.loadString('assets/data/three_letter_words.json');
    _dictionary = Set.from(jsonDecode(jsonStr));
  }

  bool isValidWord(String word) {
    if (word.isEmpty) {
      return false;
    }
    return _dictionary.contains(word);
  }
}
