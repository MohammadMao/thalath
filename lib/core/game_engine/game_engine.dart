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

  /// Draw one card respecting the max-2-per-letter rule.
  /// Returns null if no valid letter can be drawn (shouldn't happen in practice).
  String? drawCard(List<String> currentHand, {int maxRepeats = 2, Random? random}) {
    final rng = random ?? Random();
    final counts = <String, int>{};
    for (final l in currentHand) {
      counts[l] = (counts[l] ?? 0) + 1;
    }

    // Build list of letters still available
    final available = letterPool.where((l) => (counts[l] ?? 0) < maxRepeats).toList();
    if (available.isEmpty) return null;

    return available[rng.nextInt(available.length)];
  }

  bool isValidWord(String word) {
    if (word.isEmpty) {
      return false;
    }
    // return _dictionary.contains(word);
    return true; // temporary bypass for testing
  }

  /// Attempt to replace a letter in the current word.
  /// Returns a [PlayResult] with the new word and whether it's valid.
  PlayResult tryPlay({
    required String currentWord,
    required int wordIndex,
    required String newLetter,
  }) {
    // Use runes to properly handle Arabic Unicode characters
    final letters = currentWord.runes
        .map((rune) => String.fromCharCode(rune))
        .toList();
    
    // Validate word is exactly 3 letters
    if (letters.length != 3) {
      return PlayResult(
        newWord: currentWord,
        replacedLetter: '',
        isValid: false,
      );
    }
    
    if (wordIndex < 0 || wordIndex >= letters.length) {
      return PlayResult(
        newWord: currentWord,
        replacedLetter: '',
        isValid: false,
      );
    }

    final replacedLetter = letters[wordIndex];
    if (newLetter == replacedLetter) {
      return PlayResult(
        newWord: currentWord,
        replacedLetter: replacedLetter,
        isValid: false,
      );
    }

    letters[wordIndex] = newLetter;
    final newWord = letters.join();
    
    // Final validation: ensure result is exactly 3 characters
    if (newWord.runes.length != 3) {
      return PlayResult(
        newWord: currentWord,
        replacedLetter: '',
        isValid: false,
      );
    }
    
    final valid = isValidWord(newWord);

    return PlayResult(
      newWord: newWord,
      replacedLetter: replacedLetter,
      isValid: valid,
    );
  }
}

class PlayResult {
  final String newWord;
  final String replacedLetter;
  final bool isValid;

  const PlayResult({
    required this.newWord,
    required this.replacedLetter,
    required this.isValid,
  });
}
