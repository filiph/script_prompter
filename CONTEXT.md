# Script Prompter

A web utility that transforms video scripts into shortened cue-card prompts for natural speaking performances.

## Language

**Script**:
The full text input prepared by a speaker, containing spoken content and stage notes.
_Avoid_: Input text, source text, document

**Prompt**:
The shortened cue text generated from a script to trigger memory without encouraging verbatim teleprompter reading.
_Avoid_: Output text, summary, card

**Stage Instruction**:
A line within a script indicating non-spoken actions or directions (prefixed by `> ` or optional whitespace with `- `), preserved verbatim in all prompts.
_Avoid_: Stage direction, comment, director note

**Word Count**:
The total count of spoken word tokens in a script, excluding all stage instructions.
_Avoid_: Token count, character count, script length

**Estimated Duration**:
The projected speaking time calculated from the word count using a configurable words-per-minute rate.
_Avoid_: Script length, reading time, runtime estimate

**First Letters Mode**:
A transformation mode reducing every word token to its initial letter or character while preserving punctuation, whitespace, and stage instructions.
_Avoid_: Letter mode, acronym mode

**First Words Mode**:
A transformation mode extracting the opening words of each spoken sentence while keeping stage instructions intact.
_Avoid_: Sentence mode, word truncation mode

## Example Dialogue

**Presenter**: "I added a stage instruction for the camera cue in the script, but I want to make sure it doesn't get abbreviated."
**Developer**: "In both First Letters Mode and First Words Mode, any stage instruction prefixed with `> ` or `- ` is preserved verbatim in the generated prompt."
**Presenter**: "And when I print the page for my cue cards, only the title and the prompt will appear on paper."
