import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import 'logic/prompt_transformer.dart';

const String defaultSampleScript = '''
I am Bond, James Bond. Also, Řeřicha is my other name.

Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. The first few words of each sentence should remind you of your memorized content. But you won't be distracted by the words on the teleprompter. You won't _read_ those words, which will make your performance more natural.

Try converting this script now!''';

@client
class App extends StatefulComponent {
  const App({super.key});

  @override
  State<App> createState() => AppState();
}

class AppState extends State<App> {
  String inputScript = defaultSampleScript;
  String outputPrompts = '';
  PromptMode selectedMode = PromptMode.firstLetters;

  void _convert() {
    setState(() {
      outputPrompts = PromptTransformer.transform(inputScript, selectedMode);
    });
  }

  @override
  Component build(BuildContext context) {
    return div(id: 'matrioska', classes: 'prompter-container', [
      h1([.text('Script Prompter')]),
      p(
        classes: 'subtitle',
        [
          .text(
            'Takes a video script (or other prose) and provides shortened cue-card prompts.',
          ),
        ],
      ),
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
          button(
            id: 'submit',
            classes: 'convert-button',
            onClick: _convert,
            [.text('Convert')],
          ),
        ]),
      ]),
      div(id: 'output', classes: 'editor-section', [
        label([
          h2([.text('Prompts')]),
          textarea(
            id: 'shortened',
            rows: 10,
            cols: 80,
            disabled: true,
            [
              .text(
                outputPrompts.isEmpty ? 'Output will appear here.' : outputPrompts,
              ),
            ],
          ),
        ]),
      ]),
    ]);
  }

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
            transition: const Transition('all', duration: Duration(milliseconds: 150)),
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
        css('&').styles(
          margin: .only(bottom: 1.5.rem),
        ),
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
          border: .all(style: .solid, color: const Color('#cbd5e0'), width: 1.px),
          radius: .all(.circular(6.px)),
          fontFamily: const .list([FontFamily('Roboto'), FontFamilies.sansSerif]),
          fontSize: 1.rem,
          lineHeight: 1.5.em,
          backgroundColor: const Color('#ffffff'),
        ),
        css('textarea:focus').styles(
          border: .all(style: .solid, color: const Color('#3182ce'), width: 1.px),
          outline: .unset,
        ),
        css('textarea[disabled]').styles(
          cursor: .notAllowed,
          color: const Color('#2d3748'),
          backgroundColor: const Color('#f7fafc'),
        ),
      ]),
      css('.action-bar', [
        css('&').styles(
          margin: .only(top: 0.8.rem),
        ),
        css('.convert-button', [
          css('&').styles(
            padding: .symmetric(horizontal: 1.5.rem, vertical: 0.75.rem),
            border: .unset,
            radius: .all(.circular(6.px)),
            cursor: .pointer,
            transition: const Transition('background-color', duration: Duration(milliseconds: 150)),
            color: const Color('#ffffff'),
            fontSize: 1.1.rem,
            fontWeight: .bold,
            backgroundColor: const Color('#2b6cb0'),
          ),
          css('&:hover').styles(
            backgroundColor: const Color('#2c5282'),
          ),
        ]),
      ]),
    ]),
  ];
}
