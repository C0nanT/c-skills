# validate: split into per-check scripts, and fail on stale pt-BR translations

Status: ready-for-agent

## Problem Statement

`scripts/validate.sh` is one 500-line bash file with a dozen unrelated checks. It cannot run a single check, and it is hard to extend. Separately, every skill ships `TRADUCAO.pt-BR.md` and `RESUMO.md` by hand (plus pt-BR twins of supporting docs). Nothing detects when a `SKILL.md` changes and its translation does not, so the pt-BR files drift silently, mostly after upstream syncs.

## Solution

Split the validator into one script per check behind a small runner, so a check can run alone and a new one is a new file. Add a check that fails when a skill's `SKILL.md` has changed since its translation was last aligned, using a marker the translation carries.

## User Stories

1. As the maintainer, I want to run one validation check alone, so that I iterate fast on the one I am fixing.
2. As the maintainer, I want `scripts/validate.sh` to still run every check with the same exit code behaviour, so that CI and the hook keep working.
3. As the maintainer, I want each check in its own file, so that adding one does not touch the others.
4. As the maintainer, I want the output of each check to keep its current headings, so that failures read the same.
5. As the maintainer, I want a failure when `SKILL.md` changed and `TRADUCAO.pt-BR.md` did not, so that stale translations are caught at the push, not months later.
6. As the maintainer, I want the failure message to name the skill and the out-of-date file, so that I know what to update.
7. As the maintainer, I want a documented way to mark a translation as aligned after I review it, so that a pure typo fix in English does not force a retranslation.
8. As the maintainer, I want the same check for `RESUMO.md` and for supporting-doc twins, so that no pt-BR file is left out.
9. As the maintainer, I want the check to ignore skills that have no translation yet, so that new skills are not blocked by it (the existing pair check still covers presence).
10. As a contributor, I want the rule documented next to the existing pt-BR rule, so that I know how to keep the pair aligned.
11. As the maintainer, I want an upstream sync that changes a `SKILL.md` to turn the check red, so that the sync PR lists exactly which translations to update.

## Implementation Decisions

- The validator becomes a runner plus one script per existing section (frontmatter, README links, plugin.json against disk, bucket READMEs, markdownlint, invocation mode, setup-skills snippet, wizard env check, spec file name, upstream path check, untrusted-data sentence). Shared helpers (`fail`, `pass`, repo paths, bucket lists) live in one sourced file.
- Each check is runnable directly and exits non-zero on failure; the runner aggregates and keeps the final error count and exit code.
- Staleness marker: each translation file carries the content hash of the English source it was aligned with. The new check recomputes the hash of the current source and fails on mismatch. Updating the translation means updating the marker.
- Hash covers the English file's content only, so reviewed, no-op English edits are acknowledged by refreshing the marker alone.
- Scope of the marker: `TRADUCAO.pt-BR.md` against `SKILL.md`, and each `<name>.pt-BR.md` twin against its English file. `RESUMO.md` carries the `SKILL.md` hash as well.
- A small helper command prints or refreshes a marker, so the maintainer does not hash by hand.
- No change to what the existing checks verify.

## Testing Decisions

- A good test runs the validator as a user would and asserts only exit code and the failure message, never a check's internals.
- Agreed seam, one: running `scripts/validate.sh` against a fixture repo copy. Fixtures: a minimal valid repo (passes) and the same repo with a `SKILL.md` edited and its marker stale (fails, names the skill).
- Existing per-check behaviour is covered by the real repo passing on the runner before and after the split.
- Prior art: `validate.yml` already runs the validator end to end on the real repo.

## Out of Scope

- Generating translations or summaries automatically.
- Cutting or merging documentation layers (`docs/engineering`, guides, `RESUMO`).
- Bucket promotion rules for `in-progress` and `misc`.
- Plugin versioning and release changes.
- Adding `shellcheck`.

## Further Notes

Record the new rule in the fork-divergences ledger next to the existing pt-BR rule. Backfill markers on all current translations in one pass, after reviewing that they are currently in sync.
