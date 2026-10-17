## What it does

You type `traduzir` when you cannot read the agent's last message in English. The agent writes that same message again in Brazilian Portuguese (pt-BR), whole, with nothing added.

It is a reading aid, so it changes nothing else. The agent does not answer the questions the message asked, does not run what it proposed, and goes back to English for its next reply. Code blocks, commands, file paths and skill names stay exactly as they were, because those are the parts you copy.

## When to reach for it

You invoke it by typing `/traduzir`. The agent will not reach for it on its own, and it shouldn't: only you know which message you could not read.

| Situation | Use |
| --- | --- |
| You understand the idea but not the English words | `/traduzir` |
| You read it fine but the message made no sense | [wait-what](./wait-what.md) |
| You want every reply in pt-BR from now on | Say so in your `CLAUDE.md`, not here |

## Common questions

**Does it change the language of later replies?**
No. It applies to the last message only. The next reply is in English again, so you can keep practising.

**Does it translate the whole conversation?**
No, only the agent's most recent reply. Run it again after the next message if you need that one too.

**Why does it not simplify the message while translating?**
Translating and re-explaining are different jobs. A translation that quietly rewrites the message hides what the agent actually said. For a re-explanation use [wait-what](./wait-what.md).

## It's working if

- The output is only the translation, with no "here is the translation" lead-in.
- Code, commands and paths in it are identical to the original.
- The agent does not start acting on the message it just translated.
- Its next reply is in English, in the same style as before.

## Where it fits

A reach-for-it-anytime standalone: use it in any conversation, inside any other skill. Its neighbour is [wait-what](./wait-what.md), which fixes a message you could read but not follow. [ask-skills](../engineering/ask-skills.md) routes you if you are unsure which fits.
