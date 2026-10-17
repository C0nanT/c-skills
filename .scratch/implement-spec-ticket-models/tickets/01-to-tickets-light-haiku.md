# 01: to-tickets: Light tier suggests Haiku again

> **Difficulty:** Light: **suggested model:** Sonnet (Claude Code) / Sonnet (Cursor). Suggestion only, use whatever model you have to hand.

**Spec:** ../SPEC.md

**What to build:** a ticket rated Light by `/to-tickets` suggests `Haiku (Claude Code) / claude-4.5-haiku-thinking (Cursor)`, and every place that describes the tier table (the skill, its pt-BR translation and summary, its docs page) says the same thing. The fork-divergences ledger records the choice so an upstream sync cannot revert it silently.

**Seams:**
- `scripts/validate.sh` passes on the branch

**Blocked by:** None (can start immediately)

Status: ready-for-human

- [x] The `to-tickets` difficulty-tier table gives Light the suggested model `Haiku (Claude Code) / claude-4.5-haiku-thinking (Cursor)`; Heavy and Standard are unchanged
- [x] `TRADUCAO.pt-BR.md` (and `RESUMO.md` if it mentions tiers) carry the same change, with translation markers refreshed
- [x] The `to-tickets` docs page shows the same Light model (no more Composer)
- [x] The fork-divergences ledger's `to-tickets` entry names the Light → Haiku suggestion with a detection phrase
- [x] No em-dashes in changed prose
- [x] `scripts/validate.sh` passes
