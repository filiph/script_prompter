import 'package:script_prompter/logic/prompt_transformer.dart';
import 'package:test/test.dart';

void main() {
  group('PromptTransformer - First letters mode', () {
    test('transforms basic English sentence preserving punctuation and spaces', () {
      const input = 'I am Bond, James Bond.';
      final result = PromptTransformer.convertToFirstLetters(input);
      expect(result, 'I a B, J B.');
    });

    test('handles Czech diacritics and unicode grapheme clusters correctly', () {
      const input = 'Also, Řeřicha is my other name.';
      final result = PromptTransformer.convertToFirstLetters(input);
      expect(result, 'A, Ř i m o n.');
    });

    test('handles Czech pangram', () {
      const input = 'Příliš žluťoučký kůň úpěl ďábelské ódy.';
      final result = PromptTransformer.convertToFirstLetters(input);
      expect(result, 'P ž k ú ď ó.');
    });

    test('preserves whitespace, tabs, and newlines', () {
      const input = 'Hello   world!\n\nThis is\ta test.';
      final result = PromptTransformer.convertToFirstLetters(input);
      expect(result, 'H   w!\n\nT i\ta t.');
    });

    test('preserves markdown, quotes, dashes, and special characters', () {
      const input = 'You won\'t _read_ "those" words—never!';
      final result = PromptTransformer.convertToFirstLetters(input);
      expect(result, 'Y w\'t _r_ "t" w—n!');
    });

    test('handles numbers as word tokens', () {
      const input = '100 bottles of milk on 1st wall.';
      final result = PromptTransformer.convertToFirstLetters(input);
      expect(result, '1 b o m o 1 w.');
    });

    test('handles empty and whitespace-only strings', () {
      expect(PromptTransformer.convertToFirstLetters(''), '');
      expect(PromptTransformer.convertToFirstLetters('   \n  '), '   \n  ');
    });

    test('preserves stage instructions starting with > and - verbatim', () {
      const input =
          '> Look directly into camera 1.\n'
          'I am Bond, James Bond.\n'
          '  - Pause for dramatic effect\n'
          'Also, Řeřicha is my other name.';
      final result = PromptTransformer.convertToFirstLetters(input);
      expect(
        result,
        '> Look directly into camera 1.\n'
        'I a B, J B.\n'
        '  - Pause for dramatic effect\n'
        'A, Ř i m o n.',
      );
    });

    test('works via PromptTransformer.transform', () {
      const input = 'I am Bond, James Bond. Also, Řeřicha is my other name.';
      final result = PromptTransformer.transform(input, PromptMode.firstLetters);
      expect(result, 'I a B, J B. A, Ř i m o n.');
    });
  });

  group('PromptTransformer - First words mode', () {
    test('matches README demonstration example', () {
      const input =
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. '
          'The first few words of each sentence should remind you of your memorized content. '
          'But you won\'t be distracted by the words on the teleprompter. '
          'You won\'t _read_ those words, which will make your performance more natural.\n\n'
          'Try converting this script now!';

      final result = PromptTransformer.convertToFirstWords(input);

      const expected =
          'Lorem ipsum dolor sit amet,...\n'
          'The first few words of...\n'
          'But you won\'t be distracted...\n'
          'You won\'t _read_ those words,...\n\n'
          'Try converting this script now!';

      expect(result, expected);
    });

    test('truncates long sentences to maxWords and appends ellipsis', () {
      const input = 'One two three four five six seven eight nine ten.';
      final result = PromptTransformer.convertToFirstWords(input, maxWords: 5);
      expect(result, 'One two three four five...');
    });

    test('preserves short sentences ending in period, question mark, or exclamation', () {
      const input = 'Hello there. How are you? All good!';
      final result = PromptTransformer.convertToFirstWords(input);
      expect(result, 'Hello there.\nHow are you?\nAll good!');
    });

    test('appends ellipsis to short sentences without terminal punctuation', () {
      const input = 'Hello there world';
      final result = PromptTransformer.convertToFirstWords(input);
      expect(result, 'Hello there world...');
    });

    test('handles multiple paragraphs separated by blank lines', () {
      const input = 'Paragraph one sentence one. Paragraph one sentence two.\n\nParagraph two single sentence.';
      final result = PromptTransformer.convertToFirstWords(input);
      expect(
        result,
        'Paragraph one sentence one.\n'
        'Paragraph one sentence two.\n\n'
        'Paragraph two single sentence.',
      );
    });

    test('handles empty and whitespace-only strings', () {
      expect(PromptTransformer.convertToFirstWords(''), '');
      expect(PromptTransformer.convertToFirstWords('   \n\n  '), '');
    });

    test('preserves stage instructions starting with > and - verbatim', () {
      const input =
          '> Intro shot: Wide angle\n'
          'Welcome to the channel everyone. Today we are exploring script prompter.\n'
          '  - Show title card on screen\n'
          'Let us get started right away!';
      final result = PromptTransformer.convertToFirstWords(input);
      expect(
        result,
        '> Intro shot: Wide angle\n'
        'Welcome to the channel everyone.\n'
        'Today we are exploring script...\n'
        '  - Show title card on screen\n'
        'Let us get started right...',
      );
    });

    test('works via PromptTransformer.transform', () {
      const input = 'Short sentence.\n\nAnother short sentence.';
      final result = PromptTransformer.transform(input, PromptMode.firstWords);
      expect(result, 'Short sentence.\n\nAnother short sentence.');
    });
  });

  group('PromptTransformer - Word count and speaking duration', () {
    test('counts words in basic English text', () {
      const input = 'I am Bond, James Bond. Also, Řeřicha is my other name.';
      expect(PromptTransformer.countWords(input), 11);
    });

    test('ignores stage instructions when counting words', () {
      const input =
          '> Look directly into camera 1.\n'
          'I am Bond, James Bond.\n'
          '  - Pause for dramatic effect\n'
          'Also, Řeřicha is my other name.';
      expect(PromptTransformer.countWords(input), 11);
    });

    test('returns 0 words for empty, whitespace-only, or instruction-only scripts', () {
      expect(PromptTransformer.countWords(''), 0);
      expect(PromptTransformer.countWords('   \n\n  \t '), 0);
      expect(PromptTransformer.countWords('> Look at camera\n  - Dramatic pause'), 0);
    });

    test('counts words correctly across multiple lines, whitespace, and tabs', () {
      const input = 'One   two \t three\n\nfour   five\n\nsix';
      expect(PromptTransformer.countWords(input), 6);
    });

    test('estimates duration based on word count and words per minute', () {
      expect(PromptTransformer.estimateDuration(0), Duration.zero);
      expect(PromptTransformer.estimateDuration(190), const Duration(seconds: 60));
      expect(PromptTransformer.estimateDuration(95), const Duration(seconds: 30));
      expect(PromptTransformer.estimateDuration(285), const Duration(seconds: 90));
      // Custom rate
      expect(
        PromptTransformer.estimateDuration(100, wordsPerMinute: 100),
        const Duration(seconds: 60),
      );
      expect(
        PromptTransformer.estimateDuration(100, wordsPerMinute: 0),
        Duration.zero,
      );
      expect(
        PromptTransformer.estimateDuration(100, wordsPerMinute: -50),
        Duration.zero,
      );
    });

    test('formats duration using compact unit omission', () {
      expect(PromptTransformer.formatDuration(Duration.zero), '0 sec');
      expect(PromptTransformer.formatDuration(const Duration(seconds: 45)), '45 sec');
      expect(PromptTransformer.formatDuration(const Duration(seconds: 60)), '1 min');
      expect(PromptTransformer.formatDuration(const Duration(seconds: 90)), '1 min 30 sec');
      expect(PromptTransformer.formatDuration(const Duration(seconds: 120)), '2 min');
      expect(PromptTransformer.formatDuration(const Duration(seconds: 125)), '2 min 5 sec');
    });
  });
}
