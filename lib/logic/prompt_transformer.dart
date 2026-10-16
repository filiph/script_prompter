import 'package:characters/characters.dart';

enum PromptMode {
  firstLetters('First letters'),
  firstWords('First words');

  final String label;
  const PromptMode(this.label);
}

class PromptTransformer {
  /// Converts text by replacing each word token with its first grapheme cluster,
  /// preserving all punctuation, whitespace, and formatting.
  static String convertToFirstLetters(String text) {
    if (text.isEmpty) return text;
    return text.replaceAllMapped(
      RegExp(r'[\p{L}\p{N}]+', unicode: true),
      (match) => match.group(0)!.characters.first,
    );
  }

  /// Extracts the first few words of each sentence in each paragraph.
  /// Sentences within a paragraph are placed on their own lines,
  /// and truncated sentences have '...' appended unless they already end
  /// in terminal punctuation ('.', '?', '!', or '...').
  static String convertToFirstWords(String text, {int maxWords = 5}) {
    if (text.trim().isEmpty) return '';

    final normalized = text.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    final paragraphs = normalized.split(RegExp(r'\n{2,}'));

    final transformedParagraphs = <String>[];

    for (final paragraph in paragraphs) {
      final trimmedPara = paragraph.trim();
      if (trimmedPara.isEmpty) {
        transformedParagraphs.add('');
        continue;
      }

      final sentences = _splitSentences(trimmedPara);
      final shortenedSentences = <String>[];

      for (final rawSentence in sentences) {
        final sentence = rawSentence.trim();
        if (sentence.isEmpty) continue;

        final words = sentence.split(RegExp(r'\s+'));
        String shortened;
        if (words.length <= maxWords) {
          shortened = words.join(' ');
        } else {
          shortened = words.take(maxWords).join(' ');
        }

        if (shortened.isNotEmpty &&
            !shortened.endsWith('.') &&
            !shortened.endsWith('?') &&
            !shortened.endsWith('!') &&
            !shortened.endsWith('...')) {
          shortened = '$shortened...';
        }

        shortenedSentences.add(shortened);
      }

      transformedParagraphs.add(shortenedSentences.join('\n'));
    }

    return transformedParagraphs.join('\n\n');
  }

  static String transform(String text, PromptMode mode) {
    switch (mode) {
      case PromptMode.firstLetters:
        return convertToFirstLetters(text);
      case PromptMode.firstWords:
        return convertToFirstWords(text);
    }
  }

  static List<String> _splitSentences(String paragraph) {
    final sentences = <String>[];
    final buffer = StringBuffer();

    for (int i = 0; i < paragraph.length; i++) {
      final char = paragraph[i];
      buffer.write(char);

      if (char == '.' || char == '?' || char == '!') {
        // Check if next char is whitespace or end of string
        if (i == paragraph.length - 1 || RegExp(r'\s').hasMatch(paragraph[i + 1])) {
          sentences.add(buffer.toString().trim());
          buffer.clear();
        }
      }
    }

    if (buffer.isNotEmpty) {
      final remaining = buffer.toString().trim();
      if (remaining.isNotEmpty) {
        sentences.add(remaining);
      }
    }

    return sentences;
  }
}
