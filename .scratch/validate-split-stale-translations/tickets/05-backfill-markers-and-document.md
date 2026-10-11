# 05: Backfill markers and document the rule

> **Difficulty:** Light: **suggested model:** Sonnet (Claude Code) / Sonnet (Cursor). Suggestion only, use whatever model you have to hand.

**Spec:** ../SPEC.md

**What to build:** After confirming translations are currently in sync, backfill the markers on every pt-BR file in one pass. Record the rule in the fork-divergences ledger next to the existing pt-BR rule, with how to refresh a marker. Avoid em-dashes in the prose.

**Seams:** Running `scripts/validate.sh` against a fixture repo copy and asserting exit code and failure message.

**Blocked by:** 04

Status: ready-for-human

- [x] Every pt-BR file has a marker and the real repo passes
- [x] The ledger documents the rule and the refresh command
- [x] Markdownlint passes
