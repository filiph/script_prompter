import 'package:characters/characters.dart';

const int defaultWordsPerMinute = 190;

enum PromptMode {
  firstLetters('First letters'),
  firstWords('First words');

  final String label;
  const PromptMode(this.label);
}

class PromptTransformer {
  static const int wordsPerMinute = defaultWordsPerMinute;

  /// Converts text by replacing each word token with its first grapheme cluster,
  /// preserving all punctuation, whitespace, and formatting, while keeping
  /// stage instructions verbatim.
  static String convertToFirstLetters(String text) {
    if (text.isEmpty) return text;
    final lines = text.split('\n');
    return lines
        .map((line) {
          if (isStageInstruction(line)) {
            return line;
          }
          return line.replaceAllMapped(
            RegExp(r'[\p{L}\p{N}]+', unicode: true),
            (match) => match.group(0)!.characters.first,
          );
        })
        .join('\n');
  }

  /// Extracts the first few words of each sentence in each paragraph,
  /// while keeping stage instructions verbatim.
  /// Sentences within a paragraph are placed on their own lines,
  /// and truncated sentences have '...' appended unless they already end
  /// in terminal punctuation ('.', '?', '!', or '...').
  static String convertToFirstWords(String text, {int maxWords = 5}) {
    if (text.trim().isEmpty) return '';

    final normalized = text.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    final paragraphs = normalized.split(RegExp(r'\n{2,}'));

    final transformedParagraphs = <String>[];

    for (final paragraph in paragraphs) {
      if (paragraph.trim().isEmpty) {
        transformedParagraphs.add('');
        continue;
      }

      final lines = paragraph.split('\n');
      final outputLines = <String>[];
      final spokenBuffer = <String>[];

      void flushSpoken() {
        if (spokenBuffer.isNotEmpty) {
          final spokenText = spokenBuffer.join(' ').trim();
          if (spokenText.isNotEmpty) {
            outputLines.addAll(_processSpokenText(spokenText, maxWords));
          }
          spokenBuffer.clear();
        }
      }

      for (final line in lines) {
        if (isStageInstruction(line)) {
          flushSpoken();
          outputLines.add(line);
        } else {
          if (line.trim().isNotEmpty) {
            spokenBuffer.add(line.trim());
          }
        }
      }
      flushSpoken();

      transformedParagraphs.add(outputLines.join('\n'));
    }

    return transformedParagraphs.join('\n\n');
  }

  /// Counts the total number of spoken word tokens in [text], excluding all stage instructions.
  /// Words are defined as non-empty whitespace-separated substrings.
  static int countWords(String text) {
    if (text.trim().isEmpty) return 0;
    final lines = text.split('\n');
    int count = 0;
    for (final line in lines) {
      if (isStageInstruction(line)) continue;
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      final words = trimmed.split(RegExp(r'\s+'));
      count += words.length;
    }
    return count;
  }

  /// Estimates the speaking duration based on [wordCount] and [wordsPerMinute].
  static Duration estimateDuration(
    int wordCount, {
    int wordsPerMinute = defaultWordsPerMinute,
  }) {
    if (wordCount <= 0 || wordsPerMinute <= 0) return Duration.zero;
    final seconds = (wordCount / wordsPerMinute * 60).round();
    return Duration(seconds: seconds);
  }

  /// Formats a [duration] using compact unit omission:
  /// - 0 sec: '0 sec'
  /// - Under 1 min: '[S] sec'
  /// - Whole minutes: '[M] min'
  /// - Minutes and seconds: '[M] min [S] sec'
  static String formatDuration(Duration duration) {
    final totalSeconds = duration.inSeconds;
    if (totalSeconds <= 0) return '0 sec';
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    if (minutes == 0) {
      return '$seconds sec';
    } else if (seconds == 0) {
      return '$minutes min';
    } else {
      return '$minutes min $seconds sec';
    }
  }

  /// Checks whether a line is a stage instruction.
  /// Stage instructions begin with `> ` or optional whitespace followed by `- `.
  static bool isStageInstruction(String line) {
    return RegExp(r'^(?:> |\s*- )').hasMatch(line);
  }

  static String transform(String text, PromptMode mode) {
    switch (mode) {
      case PromptMode.firstLetters:
        return convertToFirstLetters(text);
      case PromptMode.firstWords:
        return convertToFirstWords(text);
    }
  }

  static List<String> _processSpokenText(String text, int maxWords) {
    final sentences = _splitSentences(text);
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
    return shortenedSentences;
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
