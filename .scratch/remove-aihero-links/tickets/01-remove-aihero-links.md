# 01: remove the aihero.dev link convention from docs

Status: ready-for-human

**What to build:** drop the convention that docs pages link skills (and dictionary terms) through `aihero.dev`. This fork's docs are not published there, so those links point at upstream pages that may not match the fork's behaviour. Link skills relatively (`./<name>.md`) instead, and stop prescribing the `aihero.dev` form in the repo guidance.

**Scope found (about 241 references in 30 files):**
- Rule text: `CLAUDE.md` (published URL line), `.agents/writing-docs.md` (the unchanged-from-upstream vs renamed split, the trigger-boundary template, the AI Coding Dictionary rule), `.agents/fork-divergences.md`
- Docs pages under `docs/engineering/` and `docs/productivity/`, plus `docs/guides/pt-br/ask-skills.md`
- `skills/engineering/ask-skills/` (`SKILL.md`, `PHASE-BOUNDARIES.md`, their pt-BR translations)

**Open questions (triage):**
- Do the `https://www.aihero.dev/ai-coding-dictionary/...` term links go too, or only the `aihero.dev/skills-*` ones?
- Changing `ask-skills` `SKILL.md` makes its translation stale: refresh markers.
- This diverges from upstream docs on every future sync: record it in the fork-divergences ledger with a detection phrase.

**Blocked by:** None (can start immediately)

- [x] `.agents/writing-docs.md` and `CLAUDE.md` no longer prescribe `aihero.dev` links; they say to link skills relatively
- [x] No `aihero.dev/skills-*` link remains under `docs/` or `skills/`
- [x] Dictionary-link decision applied consistently
- [x] Fork-divergences ledger records the divergence with a detection phrase
- [x] `ask-skills` re-read, translations refreshed
- [x] No em-dashes in changed prose
- [x] `scripts/validate.sh` passes
