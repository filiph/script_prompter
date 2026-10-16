# script_prompter

A tiny web helper that takes a script (in raw text)
and provides the script in a shortened form, usable as cue cards.

## First words mode:

Extracts the first few words of each sentence.

Input:

```text
Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. The first few words of each sentence should remind you of your memorized content. But you won't be distracted by the words on the teleprompter. You won't _read_ those words, which will make your performance more natural.

Try converting this script now!
```

Output:

```text
Lorem ipsum dolor sit amet,...
The first few words of...
But you won't be distracted...
You won't _read_ those words,...

Try converting this script now!
```

## First letters mode

Takes first letter of each word. Leaves punctuation.

Input:

```text
I am Bond, James Bond. Also, Řeřicha is my other name.
```

Output:

```text
I a B, J B. A, Ř i m o n.
```

## Deploy

In order to deploy this to https://filiph.net/prompter/,
you need to run:

```shell
jaspr clean
jaspr build
```

And then you replace the contents of `~/dev/filiphnet/old/prompter/`
with the built project in `build/jaspr/`.
You have to deploy the site afterwards, obviously.

