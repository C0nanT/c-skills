# 02: implement-spec: spawn each ticket on its suggested model, effort pinned to medium

> **Difficulty:** Standard: **suggested model:** Sonnet (Claude Code) / Sonnet (Cursor). Suggestion only, use whatever model you have to hand.

**Spec:** ../SPEC.md

**What to build:** `/implement-spec` reads each ticket's Difficulty line and spawns its implementer subagent on the suggested model for the current host. Sonnet and Opus spawns always run at `effort: medium` with no escalation; Haiku spawns set no effort. Exploration and merger run Sonnet/medium; fix-up subagents use the strongest model among the involved tickets with a Sonnet/medium floor. When the host cannot set model or effort per spawn, the run stops and suggests `/implement`. A ticket → model → effort table is shown before the first spawn (no pause) and repeated in the final report with fallbacks marked. Translation, summary, docs page and ledger match.

**Seams:**
- `scripts/validate.sh` passes on the branch

**Blocked by:** None (can start immediately)

Status: ready-for-human

- [x] Model is read from the host's side of the Difficulty line (Claude Code or Cursor), tolerant of the old em-dash separator
- [x] Unrecognised name falls back to the tier (Heavy → Opus, Standard → Sonnet, Light → Haiku); missing or unparsable line falls back to Sonnet and is named in the report
- [x] Sonnet and Opus spawns always pass `effort: medium`, never higher, even with user approval; the rule covers spawns from skills invoked inside the run (`tdd`, `review-axes`)
- [x] Haiku spawns pass no effort setting
- [x] Exploration and merger subagents run Sonnet/medium
- [x] Fix-up subagents (shared-state failures, review findings) use the strongest model among involved tickets, floor Sonnet/medium, Sonnet/medium when involvement is unknown
- [x] Heavy tickets run on Opus/medium with no human gate
- [x] Host unable to set model or effort per spawn: stop before spawning, tell the user, suggest `/implement`; never fall back to the session's settings
- [x] Plan table printed before the first implementer spawn without a confirmation pause, and repeated in the final report
- [x] `TRADUCAO.pt-BR.md`, `RESUMO.md` and the `implement-spec` docs page carry the change, translation markers refreshed
- [x] The fork-divergences ledger gains an `implement-spec` row for the model/effort rules with a detection phrase
- [x] `ask-skills` re-read; updated only if its `/implement-spec` description became inaccurate
- [x] `implement` and `delegate-tickets` untouched; no em-dashes in changed prose
- [x] `scripts/validate.sh` passes
