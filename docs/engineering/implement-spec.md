## What it does

`implement-spec` takes a spec and its tickets and lands the whole thing in one run. The orchestrating agent hands each ticket to an implementer subagent working in its own git worktree, merges each finished branch into a single **integration branch**, runs [review-axes](./review-axes.md) over the result, and resolves the tickets.

It reads the tickets as a **task graph**, not a list. Blocking edges decide what can start, so at any moment there is a **frontier** of tickets whose blockers have all landed, and every ticket on the frontier runs at once. That is the difference from working the tickets one by one. The graph's shape sets the pace, not the tickets' order on the tracker.

## When to reach for it

You invoke this by typing `/implement-spec`, and the agent won't reach for it on its own.

| Your situation | Reach for |
| --- | --- |
| A spec, split into tickets with blocking edges, that you want landed in one run | `/implement-spec` |
| One ticket at a time, in your own context window, clearing between tickets | [implement](./implement.md) |
| A spec that isn't split into tickets yet | [to-tickets](./to-tickets.md) first |
| A small piece of work with no real graph to it | [implement](./implement.md) directly |

## Prerequisites

- **An issue tracker.** The skill reads the tickets from, and resolves them on, a tracker it finds the way [to-tickets](./to-tickets.md) does: your explicit instruction, else the one [setup-skills](./setup-skills.md) configured, else local markdown under `.scratch/<feature-slug>/tickets/`.
- **Tickets with blocking edges**, as [to-tickets](./to-tickets.md) writes them. Without edges the graph is flat and every ticket starts at once.
- **A harness that runs subagents in the background and gives each one a git worktree.** The skill exists to run tickets at the same time, so on a harness that runs subagents one at a time, it is only a slower `implement`.

## Models and effort

Each ticket's **Difficulty** line, as [to-tickets](./to-tickets.md) writes it, names a suggested model per host. The orchestrator spawns that ticket's implementer on the name for the host it runs on (Claude Code or Cursor), trying these in order and taking the first that applies:

| Order | If the line has | The implementer runs on |
| --- | --- | --- |
| 1 | A recognised model name (one containing opus, sonnet or haiku) | That model |
| 2 | An unrecognised name, but a tier | Heavy is Opus, Standard is Sonnet, Light is Haiku |
| 3 | No line, or one it cannot parse | Sonnet, named in the final report |

- **Effort is pinned** at medium for Sonnet and Opus, even if you would approve more, and the rule reaches subagents that [tdd](./tdd.md) and [review-axes](./review-axes.md) spawn inside the run. Haiku gets no effort setting.
- **No human gate on Heavy tickets.** They run on Opus at medium without asking.
- **Fix-ups never run cheap.** A fix-up takes the strongest model among the tickets involved, because a fix needs at least the judgment of the work it repairs, with a floor of Sonnet.
- **The run stops rather than guess.** If the host cannot set the model per spawn, or the effort for a run with any Sonnet or Opus spawn, it suggests [implement](./implement.md) instead of falling back to your session's own settings.

A table of ticket, model and effort is printed before the first implementer starts, without pausing for you, and repeated in the final report with any fallbacks marked.

## Human gates

Some tickets only move when a person acts: a `terraform apply`, a deploy, a production migration, a manual test. [to-tickets](./to-tickets.md) gives each one its own **gate ticket**, marked `> **Gate:** human: <what the person does>`. A ticket without that line is still caught if its acceptance criteria describe a human action, and the final report names every gate it deduced rather than read. A gate ticket gets no implementer and shows as "human gate" in the model table, with no model or effort, and it is not counted as a Sonnet fallback.

When a gate reaches the frontier, the orchestrator:

1. prepares what you will use (a `plan` file, say) in the main checkout after the merge, right before asking, so it matches where you run the command;
2. asks once, with the exact command, and keeps working on tickets that do not depend on the gate while dependents wait;
3. after you confirm, checks the result itself (a log, a metric, a `curl`), and turns a failure into a fix-up implementer on the model the gate ticket's **Difficulty** line gives;
4. ticks the criterion `- [x]` and lists it in the final report as "confirmed by the person".

With nobody to answer (headless, or run as a subagent), the independent tickets finish and the run stops blocked, reporting each pending gate with its exact command. A ticket that mixes code and a gate has the code built first and the gate after.

## The integration branch

Everything lands on one branch. Each implementer:

1. confirms its worktree is based on the integration branch before it starts,
2. builds its ticket with [tdd](./tdd.md), red-green one slice at a time,
3. merges the integration branch tip into its own branch before reporting done, so landing it is a fast-forward.

The tracker decides whether a pull request exists at all. If your tracker closes work through PRs, or you ask for one, the skill opens a draft PR after the first merge and marks it ready at the end. Otherwise the run stops on the integration branch with every ticket resolved the way your tracker closes work, which works fully offline against a local markdown tracker.

Implementers talk to the orchestrator through context pointers (the spec, the ticket, shared exploration notes, earlier commits) rather than pasted summaries. This keeps each subagent's prompt small and leaves room in the orchestrator's window for the graph.

## Common questions

**The run stopped and asked me to run a command. What now?**

That is a human gate. Run the exact command it printed, then say so. The agent verifies the result and carries on with the tickets that were waiting. Tickets that did not depend on the gate kept running in the meantime.

**How is this different from running `/implement` on each ticket myself?**

This is the question the skill exists to answer. Before it shipped, people kept building their own versions, and one user described the need: they wanted "subagents implement the tickets" instead of having "to individually create new session and tell them to implement a ticket one by one, when a spec may contain over 5 tickets." With `implement` you are the dispatcher: one session per ticket, clearing in between, and keeping track yourself of which tickets are unblocked. `implement-spec` hands that job to one orchestrating session. The price is that you no longer read each ticket's work as it lands; you review the integration branch at the end. To start a run, clear the context and type `/implement-spec` with a pointer to the spec (an issue number or a file path). For a small change with no real graph, skip it and use `implement` directly.

**Does it need GitHub? I want it to stop at the branch.**

No, not any more. One user who liked the in-progress version had exactly this complaint: "it creates a PR at the end, which requires an online repository like GitHub. I wish it could do the same work offline and stop at the branch where all the work is merged." The run now ends on the integration branch. A PR opens only when the configured tracker closes work through PRs or you ask for one, so on a local markdown tracker the run ends with every ticket resolved and the work merged on the branch.

**Its review and fix loop ran for hours, or kept "fixing" tickets that hadn't been built yet.**

Both happen when `review-axes` runs anywhere other than the one point the skill gives it. It compares the code against the whole spec, so it only makes sense once every ticket has landed. If it runs mid-run, every unbuilt ticket reads as a failure. The agent then builds that ticket, and that triggers another review. At the end, the skill runs `review-axes` once and sends every finding to one fix subagent, but it doesn't yet say when to stop after that fix. One user reported a five-ticket feature where "the review and fix loop took roughly four hours". If you see a second broad review start, tell it to run focused checks for the fixed findings and stop. Expect that first review to find real problems. The run's output is a draft that the review completes, not something to ship on its own.

**Does it drive tdd like implement does?**

It does now, though it didn't at first. Users running the in-progress version noticed that "the implementer subagents don't inherit the /tdd directive", so red-green stopped as soon as they scaled up from one ticket to a whole spec. Each implementer now builds its ticket with `tdd`. There is still no step where you agree seams interactively, as there is in an `implement` session, so name the seams in the spec or the tickets if you want them pinned.

**Two implementers running in parallel collided on the same file, or picked different names for the same thing.**

Worktrees don't remove collisions; they postpone them to merge time. A blocking edge written from ticket text is a guess about which files each ticket will touch, and two tickets on "different parts of the codebase" still share a message catalogue, a config registry, or a type. Each implementer sees only its own ticket and the shared notes, never the other's work in progress, so one user's web and mobile tickets added the same string as `blockedSince` and `blockedOn`. When two frontier tickets touch one shared file, either add a blocking edge between them so they run one after the other, or have the exploration notes fix the exact names each ticket adds.

**Blocked tickets never start, even after their blocker has merged.**

This is a known problem on GitHub. The tracker's blocked-by count only drops when a blocker *closes*, and tickets typically close when the PR merges, which is the end of the run. The tracker is the right source for the starting graph but a stale one mid-run. Tell the orchestrator to track which tickets have merged into the integration branch itself and compute the frontier from that.

**Does this replace Sandcastle or an AFK script?**

No. People ask because the skills now reach into implementation: "is Sandcastle still relevant? Your skills now seem to be able to handle implementation as well." `implement-spec` puts an agent in charge of orchestration inside one harness session, which needs no infrastructure and lets you watch and steer. For work that is truly AFK, a deterministic loop ([Sandcastle](https://github.com/mattpocock/sandcastle), a shell script, a CI job) is faster, cheaper, and more reliable, because no agent makes the orchestration decisions.

**Parallel implementers broke each other's database or API tests.**

Worktrees isolate files, not the database, ports, or external services the tests hit. Two implementers running DB, API, or e2e tests at once can overwrite each other's data and fail for reasons unrelated to their code. So implementers run only isolated tests (unit and pure logic). They still write the shared-state tests their ticket needs, but the orchestrator runs those once, serially, on the integration branch after the last merge, and one fix subagent handles any failure.

**A ticket's key test was skipped inside its worktree, and it reported green.**

A worktree holds only what git tracks. Tests that read gitignored fixtures, local databases, or credentials can silently skip there. For a ticket whose verification depends on untracked material, tell the orchestrator to run it in the main checkout instead.

## It's working if

- Several implementers are running at once whenever the graph allows, not one after another.
- A ticket starts as soon as its last blocker lands on the integration branch, not when the whole run ends.
- The plan table shows each ticket on its suggested model at medium effort (Haiku with none), and the final report repeats it.
- Every ticket's trace shows `tdd` running, with a failing test before the code.
- Merges into the integration branch are fast-forwards, not conflict resolutions.
- The run ends on one branch with every ticket resolved, and a PR only if your tracker wanted one.
- A human gate is asked for once, with the exact command, and the report lists it as "confirmed by the person" (or as blocked, with the pending command, if nobody was there).
- On a local tracker, every finished ticket file has its boxes ticked and `Status: ready-for-human`, so [archive-feature](./archive-feature.md) can close the feature.

## Where it fits

`implement-spec` is the build step of the main chain, as the parallel alternative to running [implement](./implement.md) once per ticket:

```txt
grill-with-docs → to-spec → to-tickets → implement-spec → retro
```

Its neighbours are [to-tickets](./to-tickets.md), which declares the blocking edges it reads as a task graph, and [review-axes](./review-axes.md), which it runs over the integration branch before closing out. [ask-skills](./ask-skills.md) is the router over the whole set when you are not sure which flow you are in.
