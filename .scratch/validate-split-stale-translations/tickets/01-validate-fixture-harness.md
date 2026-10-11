# 01: Fixture harness around validate.sh

> **Difficulty:** Standard: **suggested model:** Sonnet (Claude Code) / Sonnet (Cursor). Suggestion only, use whatever model you have to hand.

**Spec:** ../SPEC.md

**What to build:** A test runs the validator against a minimal valid fixture repo and asserts it passes, and against a copy with one known defect (for example a broken README link) and asserts the exit code and message. This is the safety net for the split.

**Seams:** Running `scripts/validate.sh` against a fixture repo copy and asserting exit code and failure message.

**Blocked by:** None (can start immediately)

Status: ready-for-human

- [x] A minimal valid fixture passes with exit 0
- [x] A defective fixture fails with non-zero and the expected message
- [x] The real repo still passes
- [x] The harness is wired where the validator runs in CI
