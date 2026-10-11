---
name: traduzir
description: Translate your last message into Brazilian Portuguese (pt-BR), once.
disable-model-invocation: true
---

Translate your last message to the user into Brazilian Portuguese (pt-BR), so they can read it. "Last message" means your most recent reply before this one, the whole of it, not a summary. If that reply was only tool calls, use the latest one that had text.

- Output only the translation. No preamble, no notes, no "here is the translation".
- Keep the structure: headings, lists, tables, emphasis. Keep code blocks, commands, file paths, identifiers, skill names, and error messages exactly as they were. Translate the prose around them.
- Translate what the message says in the voice it used. If it was terse, stay terse. Do not simplify, expand, or fix it.
- Do not answer questions the message asked, do not run anything it proposed, and do not continue the work. This is a reading aid, not a new turn of the task.
- This is one-off. Afterwards reply in the language you were using before, and treat the translation as having changed nothing about how you write from now on.
