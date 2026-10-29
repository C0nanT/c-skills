# 04: Extend the check to RESUMO.md and pt-BR twins

> **Difficulty:** Light: **suggested model:** Sonnet (Claude Code) / Sonnet (Cursor). Suggestion only, use whatever model you have to hand.

**Spec:** ../SPEC.md

**What to build:** The same marker and check for `RESUMO.md` (against `SKILL.md`) and for each `<name>.pt-BR.md` twin (against its English file).

**Seams:** Running `scripts/validate.sh` against a fixture repo copy and asserting exit code and failure message.

**Blocked by:** 03

Status: done

- [x] A stale `RESUMO.md` fails the check
- [x] A stale twin fails the check
- [x] The helper handles all three file kinds
