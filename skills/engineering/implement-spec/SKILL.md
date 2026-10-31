---
name: implement-spec
description: "Implement the result of /to-spec and /to-tickets in code."
disable-model-invocation: true
---

You have been provided a spec. This spec should have tickets associated with it, describing how to implement the spec.

Resolve the issue tracker the way `/to-tickets` does: an explicit user instruction, else `docs/agents/issue-tracker.md` (written by `/setup-skills`), else local markdown under `.scratch/<feature-slug>/tickets/`.

The goal is the entire spec implemented on a single **integration branch**, with every ticket resolved the way the issue tracker closes work.

The tickets are not a list of steps. They are a **task graph** with blocking relationships between them. This means there is always a **frontier** of tickets which are ready to be grabbed.

Start every subagent with a fresh context window.

Communication to and from subagents should be sparse. Communicate primarily through **context pointers**: to the spec, tickets, research notes, and previous commits. Don't duplicate information already available via pointers.

**Implementer subagents** should be run in the background where possible for maximum concurrency.

## Models and effort

Every ticket has a `> **Difficulty:**` line. Each **implementer subagent** runs on the model that line suggests for the current host, at a pinned effort.

- **Reading the model.** On Claude Code take the name before `(Claude Code)`; on Cursor, the name before `(Cursor)`. Tolerate the older separator still found in old tickets, an em-dash where the line now has a colon.
- **Resolution order.** The named model if recognised (a name containing `opus`, `sonnet` or `haiku`, case-insensitive, on the host's side of the line), else the tier (Heavy is Opus, Standard is Sonnet, Light is Haiku), else Sonnet when the line is missing or unparsable. Record every Sonnet fallback caused by a missing or unparsable line and name it in the final report.
- **Effort.** Every spawn on a model that supports effort (Opus, Sonnet and Haiku on Claude Code) passes `effort: medium`, never higher, even if the user would approve more. A model without effort support (such as `claude-4.5-haiku-thinking` on Cursor) gets no effort setting. This covers subagents spawned by skills invoked inside the run (`tdd`, `review-axes`).
- **Heavy tickets** run on Opus at medium, with no user approval needed.
- **Gate tickets** (see **Human gates**): a pure gate ticket gets no implementer, so the table lists it as "human gate" with no model and no effort, and it is not a Sonnet fallback. A mixed ticket (code and a gate) is listed with its implementer's model for the code part, then its gate. Their `Difficulty` line still counts: a fix-up after a failed gate verification uses the gate ticket as an involved ticket.
- **Subagents with no ticket.** The **exploration subagent** and the **merger subagent** run Sonnet at medium. A **fix-up subagent** (shared-state failures in step 7, review findings in step 8) uses the strongest model among the tickets involved (Haiku < Sonnet < Opus), with a floor of Sonnet at medium, and Sonnet at medium when the involved tickets cannot be determined.
- **Host limits.** Stop if the host cannot set the model per spawn, or cannot set the effort per spawn for a run with any spawn on a model that supports effort (a run made only of models without effort support needs no effort control). Stop before spawning anything, tell the user, and suggest `/implement` instead. Never fall back to the session's own model or effort.

Before the first implementer spawn, print a table of ticket, model, effort, marking any fallback, and carry on without waiting for confirmation. Repeat the table in the final report.

## Human gates

A **gate ticket** only advances when a person performs an action (a `terraform apply`, a deploy, a production migration, a manual test). A pure gate ticket gets no implementer.

- **Recognise it** by the `> **Gate:** human: <what the person does>` line. Without that line, deduce it from the acceptance criteria (for example "applied by the person") and name every deduced gate in the final report. A ticket that mixes code and a gate has its code part built first by an implementer (listed in the table with its model), then the gate.
- **Prepare** what the person will use (a `plan` file, a script, a checklist) yourself, in the main checkout after the merge, right before asking, so it matches the checkout where the action runs. An implementer of a ticket that prepares a gate only edits, commits and runs local checks; it does not produce the gate's artifact.
- **Ask once**, with the exact command (for example `! terraform apply /tmp/x.tfplan`). Keep working on tickets that do not depend on the gate; dependents wait for the confirmation.
- **After the confirmation**, verify the result yourself (log, metric, `curl`). A failed check becomes a fix-up **implementer subagent**, on the fix-up rule in **Models and effort**: the gate ticket counts as an involved ticket, so the floor of Sonnet at medium still applies.
- **Record it.** The confirmation counts as evidence: tick the matching criterion `- [x]`, and list it in the final report as "confirmed by the person".
- **No human available** (headless, run as a subagent, nobody watching): finish every independent ticket, then stop blocked and report each pending gate with its exact command. Never work around a gate.

## Steps

1. Read the spec and tickets to understand the task graph.

2. (optional) Use an **exploration subagent** to conduct any exploration required by the tickets - relevant codebase files or external documentation. Run it per **Models and effort**. Ensure the exploration subagent can save files - it should save its markdown notes in a directory outside the repo, accessible by all future subagents. This lets **implementer subagents** focus on implementation rather than exploration.

3. Create the integration branch, unless the spec, the tickets or the repo's own instructions (`CLAUDE.md`, `AGENTS.md`) explicitly say to commit straight to `main`: then `main` is the integration branch and nothing is created. Without that explicit instruction, always create the branch. Implementers keep their worktrees and temporary local branches either way (the base check in step 4 still applies), and step 10 cleans them up. If the issue tracker closes work through PRs, or the user asks for one, open a draft PR after the first merge in step 5 (a branch with no commits ahead of main can't open one), marked as closing the spec and tickets.

4. Use a fresh **implementer subagent** for each ticket, each in its own worktree on its own branch, on the model and effort from **Models and effort**. Each implementer subagent:
   - confirms its worktree is based on the integration branch before starting, and resets onto it if not;
   - calls the Skill tool with `tdd` to build the ticket, running only **isolated tests** (unit and pure logic, nothing that touches shared state). It writes the **shared-state tests** the ticket needs (database, API, e2e, anything on a shared port, file, queue, or external service) but does not run them. In a repo with no test suite, the checks the repo does have (`validate`, `fmt`, lint, typecheck) count as the isolated tests, and the implementer runs those;
   - merges the integration branch tip into its own branch before reporting done

5. Once an **implementer subagent** completes, merge its work to the integration branch with a **merger subagent** (see **Models and effort**).

6. If this changes the **frontier** of available tickets, kick off more **implementer subagents** to work on the new tickets. This allows for maximum concurrency. A gate ticket on the frontier is handled per **Human gates**, not spawned.

7. Once all tickets are complete and merged, run the **shared-state tests** once, serially, on the integration branch (no other subagent running). Parallel implementers share the same database, ports, and services, so these tests would corrupt each other's data if run during steps 4 to 6. Fix every failure in a single fresh fix-up **implementer subagent**, then rerun only the failing tests. In a repo with no test suite, run the repo's available checks once on the integration branch instead, and say in the final report that there was no test suite. Shared-state checks that are manual (a `curl` from another country, a phone on 4G) become a gate ticket per **Human gates**: ask the person for the exact list of what to test, once, with the pass condition for each item.

8. Call the Skill tool with `review-axes` on the integration branch, passing the spec path as its spec argument. Pass it the criteria a person confirmed at a gate (ticked `- [x]` by the confirmation) and name them as not to be flipped, since it syncs checkboxes from the code. After it returns, re-tick any of them it flipped back to `- [ ]` before step 9. Fix all issues raised by the review in a single fresh fix-up **implementer subagent**. If the fixes touch code covered by shared-state tests, rerun those tests serially afterwards.

9. If a draft PR exists, mark it ready for review. Otherwise, resolve each ticket the way the issue tracker closes work, and report the integration branch, with the ticket, model, effort table from **Models and effort**.
   On a local markdown tracker, resolving a ticket means marking its file in the main checkout (not a worktree): flip each acceptance criterion the integration branch implements to `- [x]`, judged from the step-8 Spec report and the ticket's merged work, leave unmet ones `- [ ]` (a gate criterion the person confirmed is ticked), and set `Status: ready-for-human` once every box is ticked. A ticket with an unticked box keeps its status and is listed in the report. This is what `/archive-feature` checks before it archives the feature.

10. Clean up all **implementer subagent** worktrees and their temporary local branches.
