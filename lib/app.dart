import 'dart:async';

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import 'clipboard.dart';
import 'logic/prompt_transformer.dart';

const String defaultSampleScript = '''
Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. The first few words of each sentence should remind you of your memorized content. But you won't be distracted by the words on the teleprompter. You won't _read_ those words, which will make your performance more natural.

Try converting this script now!''';

@client
class App extends StatefulComponent {
  const App({super.key});

  @override
  State<App> createState() => AppState();
}

class AppState extends State<App> {
  @css
  static List<StyleRule> get styles => [
    css('.prompter-container', [
      css('&').styles(
        maxWidth: 60.em,
        padding: .all(2.rem),
        margin: .symmetric(horizontal: .auto, vertical: .zero),
        boxSizing: .borderBox,
      ),
      css('h1').styles(
        margin: .only(bottom: 0.5.rem),
        color: const Color('#1a202c'),
        fontSize: 2.4.rem,
      ),
      css('.subtitle').styles(
        margin: .only(bottom: 1.5.rem),
        color: const Color('#4a5568'),
        fontSize: 1.1.rem,
        lineHeight: 1.5.em,
      ),
      css('.mode-selector-group', [
        css('&').styles(
          display: .inlineFlex,
          padding: .all(4.px),
          margin: .only(bottom: 1.5.rem),
          radius: .all(.circular(8.px)),
          backgroundColor: const Color('#edf2f7'),
        ),
        css('.mode-button', [
          css('&').styles(
            padding: .symmetric(horizontal: 1.2.rem, vertical: 0.6.rem),
            border: .unset,
            radius: .all(.circular(6.px)),
            cursor: .pointer,
            transition: const Transition(
              'all',
              duration: Duration(milliseconds: 150),
            ),
            color: const Color('#4a5568'),
            fontSize: 1.rem,
            fontWeight: .w600,
            backgroundColor: Colors.transparent,
          ),
          css('&.active').styles(
            shadow: BoxShadow(
              offsetX: 0.px,
              offsetY: 1.px,
              blur: 3.px,
              color: const Color('#0000001a'),
            ),
            color: const Color('#2b6cb0'),
            backgroundColor: const Color('#ffffff'),
          ),
        ]),
      ]),
      css('.editor-section', [
        css('&').styles(margin: .only(bottom: 1.5.rem)),
        css('.section-header', [
          css('&').styles(
            display: .flex,
            margin: .only(bottom: 0.5.rem),
            justifyContent: .spaceBetween,
            alignItems: .center,
          ),
          css('.header-title-container', [
            css('&').styles(
              display: .flex,
              alignItems: .baseline,
              raw: {'gap': '0.75rem', 'flex-wrap': 'wrap'},
            ),
            css('.wpm-input').styles(width: 8.em),
          ]),
          css('.script-stats', [
            css('&').styles(
              color: const Color('#718096'),
              fontSize: 0.9.rem,
              fontWeight: .w400,
            ),
          ]),
          css('h2').styles(margin: .zero),
        ]),
        css('h2').styles(
          margin: .only(bottom: 0.5.rem),
          color: const Color('#2d3748'),
          fontSize: 1.4.rem,
        ),
        css('textarea').styles(
          width: 100.percent,
          minHeight: 160.px,
          padding: .all(0.8.rem),
          boxSizing: .borderBox,
          border: .all(
            style: .solid,
            color: const Color('#cbd5e0'),
            width: 1.px,
          ),
          radius: .all(.circular(6.px)),
          fontFamily: const .list([
            FontFamily('Roboto'),
            FontFamilies.sansSerif,
          ]),
          fontSize: 1.rem,
          lineHeight: 1.5.em,
          backgroundColor: const Color('#ffffff'),
        ),
        css('textarea:focus').styles(
          border: .all(
            style: .solid,
            color: const Color('#3182ce'),
            width: 1.px,
          ),
          outline: .unset,
        ),
        css('.copy-button', [
          css('&').styles(
            padding: .symmetric(horizontal: 0.8.rem, vertical: 0.4.rem),
            border: .all(
              style: .solid,
              color: const Color('#cbd5e0'),
              width: 1.px,
            ),
            radius: .all(.circular(6.px)),
            cursor: .pointer,
            transition: const Transition(
              'all',
              duration: Duration(milliseconds: 150),
            ),
            color: const Color('#4a5568'),
            fontSize: 0.9.rem,
            fontWeight: .w600,
            backgroundColor: const Color('#ffffff'),
          ),
          css('&:hover:not([disabled])').styles(
            border: .all(
              color: const Color('#a0aec0'),
              style: .solid,
              width: 1.px,
            ),
            color: const Color('#2d3748'),
            backgroundColor: const Color('#edf2f7'),
          ),
          css('&[disabled]').styles(opacity: 0.6, cursor: .notAllowed),
          css('&.copied').styles(
            border: .all(
              style: .solid,
              color: const Color('#3182ce'),
              width: 1.px,
            ),
            color: const Color('#2b6cb0'),
            backgroundColor: const Color('#ebf8ff'),
          ),
        ]),
        css('.prompts-output', [
          css('&').styles(
            width: 100.percent,
            minHeight: 160.px,
            padding: .all(0.8.rem),
            margin: .zero,
            boxSizing: .borderBox,
            border: .all(
              style: .solid,
              color: const Color('#cbd5e0'),
              width: 1.px,
            ),
            radius: .all(.circular(6.px)),
            color: const Color('#2d3748'),
            fontFamily: const .list([
              FontFamily('Roboto'),
              FontFamilies.sansSerif,
            ]),
            fontSize: 1.rem,
            lineHeight: 1.5.em,
            whiteSpace: .preWrap,
            backgroundColor: const Color('#f7fafc'),
            raw: {'word-break': 'break-word', 'overflow-wrap': 'break-word'},
          ),
          css(
            '&.placeholder',
          ).styles(color: const Color('#a0aec0'), fontStyle: .italic),
          css('.spoken-text').styles(fontSize: 1.5.rem),
          css('.stage-instruction').styles(fontSize: 0.9.rem),
        ]),
      ]),
      css('.action-bar', [
        css('&').styles(margin: .only(top: 0.8.rem)),
        css('.convert-button', [
          css('&').styles(
            padding: .symmetric(horizontal: 1.5.rem, vertical: 0.75.rem),
            border: .unset,
            radius: .all(.circular(6.px)),
            cursor: .pointer,
            transition: const Transition(
              'background-color',
              duration: Duration(milliseconds: 150),
            ),
            color: const Color('#ffffff'),
            fontSize: 1.1.rem,
            fontWeight: .bold,
            backgroundColor: const Color('#2b6cb0'),
          ),
          css('&:hover').styles(backgroundColor: const Color('#2c5282')),
        ]),
      ]),
    ]),
    css.media(MediaQuery.print(), [
      css('html, body').styles(
        padding: .zero,
        margin: .zero,
        backgroundColor: const Color('#ffffff'),
      ),
      css('.prompter-container', [
        css('&').styles(maxWidth: 50.percent, padding: .zero, margin: .zero),
        css(
          'h1, .subtitle, .mode-selector-group, #input',
        ).styles(display: .none),
        css('.editor-section', [
          css('&').styles(margin: .zero),
          css('.section-header').styles(display: .none),
          css('.prompts-output', [
            css('&').styles(
              minHeight: .unset,
              padding: .zero,
              margin: .zero,
              border: .unset,
              color: const Color('#000000'),
              fontFamily: const .list([
                FontFamily('Georgia'),
                FontFamily('Cambria'),
                FontFamily('Times New Roman'),
                FontFamily('Times'),
                FontFamilies.serif,
              ]),
              backgroundColor: Colors.transparent,
            ),
            css('.spoken-text').styles(
              padding: .initial,
              margin: .zero,
              fontSize: 1.0.rem,
              lineHeight: 1.5.em,
              raw: {'break-inside': 'avoid'},
            ),
            css('.stage-instruction').styles(
              padding: .initial,
              margin: .zero,
              fontSize: 0.5.rem,
              lineHeight: 0.7.rem,
              raw: {'break-inside': 'avoid'},
            ),
          ]),
        ]),
      ]),
    ]),
  ];

  String inputScript = defaultSampleScript;

  String outputPrompts = '';

  PromptMode selectedMode = PromptMode.firstLetters;

  bool _copied = false;

  Timer? _copyResetTimer;

  String _wpmInput = PromptTransformer.wordsPerMinute.toString();

  int _wordsPerMinute = PromptTransformer.wordsPerMinute;

  int _wordCount = PromptTransformer.countWords(defaultSampleScript);

  String _estimatedDuration = PromptTransformer.formatDuration(
    PromptTransformer.estimateDuration(
      PromptTransformer.countWords(defaultSampleScript),
    ),
  );

  @override
  Component build(BuildContext context) {
    return div(id: 'matrioska', classes: 'prompter-container', [
      h1([.text('Script Prompter')]),
      p(classes: 'subtitle', [
        .text(
          'Takes a video script (or other prose) and provides shortened cue-card prompts.',
        ),
      ]),
      div(classes: 'mode-selector-group', [
        for (final mode in PromptMode.values)
          button(
            classes: 'mode-button ${selectedMode == mode ? "active" : ""}',
            onClick: () {
              setState(() {
                selectedMode = mode;
              });
            },
            [.text(mode.label)],
          ),
      ]),
      div(id: 'input', classes: 'editor-section', [
        label([
          h2([.text('Script')]),
          textarea(
            id: 'script',
            rows: 10,
            cols: 80,
            onInput: (value) {
              inputScript = value;
            },
            [.text(inputScript)],
          ),
        ]),
        div(classes: 'action-bar', [
          button(id: 'submit', classes: 'convert-button', onClick: _convert, [
            .text('Convert'),
          ]),
        ]),
      ]),
      div(id: 'output', classes: 'editor-section', [
        div(classes: 'section-header', [
          div(classes: 'header-title-container', [
            h2([.text('Prompts')]),
            span(id: 'script-stats', classes: 'script-stats', [
              .text(
                '$_wordCount ${_wordCount == 1 ? "word" : "words"} · ~$_estimatedDuration',
              ),
            ]),
            .text(' at '),
            input(
              type: .number,
              classes: 'wpm-input',
              attributes: {'min': '10', 'step': '10'},
              value: _wpmInput,
              onInput: (value) {
                _wpmInput = value?.toString() ?? '';
              },
            ),
            .element(
              tag: 'abbr',
              attributes: {'title': 'Words Per Minute'},
              children: [.text(' WPM')],
            ),
          ]),
          button(
            id: 'copy',
            classes: 'copy-button ${_copied ? "copied" : ""}',
            disabled: outputPrompts.isEmpty,
            onClick: _copyToClipboard,
            [.text(_copied ? 'Copied!' : 'Copy to clipboard')],
          ),
        ]),
        pre(
          id: 'shortened',
          classes:
              'prompts-output ${outputPrompts.isEmpty ? "placeholder" : ""}',
          _buildPromptComponents(),
        ),
      ]),
    ]);
  }

  @override
  void dispose() {
    _copyResetTimer?.cancel();
    super.dispose();
  }

  List<Component> _buildPromptComponents() {
    if (outputPrompts.isEmpty) {
      return [.text('Output will appear here.')];
    }
    final lines = outputPrompts.split('\n');
    return [
      for (int i = 0; i < lines.length; i++)
        span(
          classes: PromptTransformer.isStageInstruction(lines[i])
              ? 'stage-instruction'
              : 'spoken-text',
          [.text(i < lines.length - 1 ? '${lines[i]}\n' : lines[i])],
        ),
    ];
  }

  void _convert() {
    setState(() {
      outputPrompts = PromptTransformer.transform(inputScript, selectedMode);
      _wordCount = PromptTransformer.countWords(inputScript);
      final parsedWpm = int.tryParse(_wpmInput);
      _wordsPerMinute = (parsedWpm != null && parsedWpm > 0)
          ? parsedWpm
          : PromptTransformer.wordsPerMinute;
      final duration = PromptTransformer.estimateDuration(
        _wordCount,
        wordsPerMinute: _wordsPerMinute,
      );
      _estimatedDuration = PromptTransformer.formatDuration(duration);
    });
  }

  void _copyToClipboard() {
    if (outputPrompts.isEmpty) return;
    copyToClipboard(outputPrompts);
    _copyResetTimer?.cancel();
    setState(() {
      _copied = true;
    });
    _copyResetTimer = Timer(const Duration(seconds: 2), () {
      setState(() {
        _copied = false;
      });
    });
  }
}
