# 02: Split validate.sh into per-check scripts

> **Difficulty:** Standard: **suggested model:** Sonnet (Claude Code) / Sonnet (Cursor). Suggestion only, use whatever model you have to hand.

**Spec:** ../SPEC.md

**What to build:** A runner plus one script per existing section, sharing one sourced helpers file. Any check runs alone. The runner keeps the same headings, error count and exit code. No change to what each check verifies.

**Seams:** Running `scripts/validate.sh` against a fixture repo copy and asserting exit code and failure message.

**Blocked by:** 01

Status: done

- [x] One script per existing section, each runnable directly
- [x] `scripts/validate.sh` runs all and keeps headings and exit behaviour
- [x] Fixture harness from 01 passes unchanged
- [x] The real repo passes
