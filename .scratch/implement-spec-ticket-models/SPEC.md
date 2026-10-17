# implement-spec: run each ticket on its suggested model, effort pinned to medium

Status: ready-for-agent

## Problem Statement

`/to-tickets` gives every ticket a **Difficulty** line with a tier (Heavy, Standard, Light) and a suggested model per host, but `/implement-spec` ignores it. Every implementer subagent runs on whatever model and effort the session happens to use, so a mechanical config bump burns the same model as a migration, and a session running at `high` effort silently passes that cost to every spawn.

Separately, the Light tier in `/to-tickets` was switched from Haiku to Sonnet in August, so today no ticket ever suggests a cheap fast model, and the skill's docs page still says Haiku, so the two disagree.

## Solution

`/implement-spec` reads each ticket's Difficulty line and spawns that ticket's implementer subagent on the suggested model for the current host. Sonnet and Opus subagents always run at `effort: medium`, with no exception. Haiku subagents get no effort setting at all and run on the host's default. Subagents that belong to no ticket (exploration, merger, fix-up) get fixed rules. Before launching, the run shows a ticket → model → effort table and repeats it in the final report.

`/to-tickets` goes back to suggesting Haiku for Light tickets, with the same Cursor model name `review-axes` already uses for Haiku.

## User Stories

1. As a developer running `/implement-spec`, I want each implementer subagent to run on the model its ticket suggests, so that cheap tickets cost less and hard tickets get the strongest model.
2. As a developer, I want the model read from the name written on the ticket's Difficulty line, so that a ticket I hand-edited to a different model is respected.
3. As a developer, I want an unrecognised model name to fall back to the ticket's tier (Heavy → Opus, Standard → Sonnet, Light → Haiku), so that a typo does not break the run.
4. As a developer, I want a ticket with no Difficulty line, or one that cannot be parsed, to run on Sonnet, so that one missing line never blocks the parallel run.
5. As a developer, I want every Sonnet fallback caused by a missing or unreadable line to be named in the final report, so that I can fix the ticket.
6. As a developer, I want every Sonnet and Opus subagent to run at `effort: medium`, so that my session's own effort level never leaks into the spawns.
7. As a developer, I want medium to be absolute for Sonnet and Opus, with no escalation even if I would approve it, so that the cost of a run is predictable.
8. As a developer, I want Haiku subagents spawned with no effort setting, so that the light, low-judgement tickets they run use whatever the host provides.
9. As a developer, I want the medium rule to reach subagents that skills invoked inside the run spawn (`/tdd`, `/review-axes`), so that no nested spawn escapes it.
10. As a developer, I want the exploration subagent to run on Sonnet at medium, so that exploration has a fixed, predictable cost.
11. As a developer, I want the merger subagent to run on Sonnet at medium, so that merges have a fixed, predictable cost.
12. As a developer, I want the fix-up subagent for shared-state test failures to use the strongest model among the tickets involved in the failures, so that hard code gets fixed by a model able to reason about it.
13. As a developer, I want the fix-up subagent for review findings to use the strongest model among the tickets the findings touch, for the same reason.
14. As a developer, I want every fix-up subagent to run on at least Sonnet at medium, even when every ticket involved was Haiku, so that diagnosing failures always gets real reasoning.
15. As a developer, I want a fix-up subagent whose involved tickets cannot be determined to run on Sonnet at medium, so that there is always a defined answer.
16. As a developer, I want Heavy tickets to run on Opus at medium without pausing for me, so that the whole spec still lands in one run while I watch it.
17. As a developer, I want the run to stop and tell me when the host cannot set the model or the effort per spawn, so that the medium guarantee is never broken silently.
18. As a developer, I want that stop message to suggest running `/implement` instead, so that I know how to carry on.
19. As a developer, I want a table of ticket → model → effort printed before the first implementer launches, so that I can see the plan.
20. As a developer, I want that table printed without waiting for my confirmation, so that the run keeps its momentum.
21. As a developer, I want the same table repeated in the final report, including any fallbacks, so that I can audit what actually ran.
22. As a developer in Cursor, I want `/implement-spec` to read the Cursor side of the Difficulty line, so that the feature works in both hosts.
23. As a developer in Cursor, I want the same effort rules and the same stop-and-tell rule there, so that both hosts behave the same way.
24. As a developer running `/to-tickets`, I want Light tickets to suggest Haiku on Claude Code and `claude-4.5-haiku-thinking` on Cursor, so that cheap work goes to a cheap model.
25. As a developer reading the docs pages, I want the `/to-tickets` and `/implement-spec` pages to match the skills, so that the docs never contradict the behaviour.
26. As a pt-BR reader, I want `TRADUCAO.pt-BR.md` and `RESUMO.md` of both skills updated with the change, so that the translations stay aligned.
27. As the fork maintainer, I want both divergences recorded in the fork-divergences ledger, so that the next upstream sync does not silently revert them.
28. As a developer using `/implement` or `/delegate-tickets`, I want them unchanged, so that this change has no surprise effects elsewhere.

## Implementation Decisions

- **Modules changed:** the `implement-spec` skill and the `to-tickets` skill, each with its `TRADUCAO.pt-BR.md`, `RESUMO.md` and docs page, plus the fork-divergences ledger. `implement` and `delegate-tickets` are untouched. Re-read `ask-skills` and update it only if its description of `/implement-spec` stops being accurate.
- **Model source:** the Difficulty line `/to-tickets` writes, in the shape `> **Difficulty:** <Tier>: **suggested model:** <Claude Code model> (Claude Code) / <Cursor model> (Cursor). ...`. On Claude Code, read the name before `(Claude Code)`; on Cursor, the name before `(Cursor)`. The parse is tolerant of the older em-dash separator still found in old tickets.
- **Resolution order per ticket:** named model if recognised → tier mapping (Heavy → Opus, Standard → Sonnet, Light → Haiku) → Sonnet when the line is missing or unparsable, recorded for the report.
- **Effort rule:** Sonnet and Opus spawns always pass `effort: medium`. Haiku spawns pass no effort. No path raises effort above medium, with or without user approval. The rule covers subagents spawned by skills invoked within the run.
- **Non-ticket subagents:** exploration Sonnet/medium; merger Sonnet/medium; fix-up (shared-state failures and review findings) the strongest model among the involved tickets with a floor of Sonnet/medium, and Sonnet/medium when the involved tickets cannot be determined. Strength order: Haiku < Sonnet < Opus.
- **Heavy tickets:** no human gate (unlike `delegate-tickets`).
- **Host capability:** if the host cannot set model or effort per spawn, stop before spawning and tell the user, suggesting `/implement`. Never fall back to the session's model or effort.
- **Plan table:** printed before the first implementer spawn, no confirmation pause; repeated in the final report with fallbacks marked.
- **to-tickets Light tier:** suggested model becomes `Haiku (Claude Code) / claude-4.5-haiku-thinking (Cursor)`, in the skill, its translation and its docs page (the docs page currently says Haiku with Composer on Cursor; align it).
- **Ledger:** add or extend `implement-spec` and `to-tickets` rows in the fork-divergences ledger, each with a detection phrase whose absence in the skill shows a sync reverted it.
- **Prose rules:** no em-dashes; cross-skill steps keep the "Call the Skill tool with" form.

## Testing Decisions

- A good check here tests what a user or a sync would break: translations drifting from their `SKILL.md`, lint, invocation mode, links. It does not assert specific wording of the new rules.
- Agreed seam: `scripts/validate.sh` passes on the branch (stale-translation markers refreshed for both skills, markdownlint, invocation-mode, README link checks). No new check is added.
- Modules covered: `implement-spec` and `to-tickets` skill folders, their docs pages, the ledger.
- Prior art: the existing `scripts/checks/` suite and `tests/validate-checks.sh`; the ledger's detection-phrase convention for the manual sync check.

## Out of Scope

- Changing `/implement` (keeps its medium-by-default with approval for high) or `/delegate-tickets` (keeps Sonnet fixed and its Heavy gate).
- Changing the Heavy or Standard tier models in `/to-tickets`.
- Rewriting existing tickets in other repos to the new Light suggestion.
- A new validator check for the Difficulty line format.

## Further Notes

- The August change from Haiku to Sonnet for Light was deliberate (commit `2f45954`); the user chose to revert it so Light work goes to a cheap model.
- The Cursor Haiku name follows the precedent already recorded for `review-axes` in the ledger, which forbids `composer-2.5`.
