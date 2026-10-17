# 03: Fail when TRADUCAO.pt-BR.md is stale

> **Difficulty:** Standard: **suggested model:** Sonnet (Claude Code) / Sonnet (Cursor). Suggestion only, use whatever model you have to hand.

**Spec:** ../SPEC.md

**What to build:** Each `TRADUCAO.pt-BR.md` carries the content hash of the `SKILL.md` it was aligned with. A new check recomputes the hash and fails on mismatch, naming the skill and file. A helper command prints or refreshes the marker. Skills without a translation are ignored.

**Seams:** Running `scripts/validate.sh` against a fixture repo copy and asserting exit code and failure message.

**Blocked by:** 02

Status: done

- [x] A fixture with an edited `SKILL.md` and a stale marker fails, naming the skill
- [x] A fixture with a matching marker passes
- [x] The helper refreshes a marker
- [x] Skills with no translation are skipped by this check
