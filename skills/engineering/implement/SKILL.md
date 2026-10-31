---
name: implement
description: "Implement a piece of work based on a spec or set of tickets. Use when the user wants a ready spec, ticket, or agreed plan built, or says to implement it."
---

Implement the work described by the user in the spec or tickets, in six steps. Each step is done only when its completion criterion holds. A run with gates commits (step 5) before it reviews (step 4): see **Order of a gated run** under **Human gates**.

If the user passes a ticket reference, fetch it from the issue tracker and state its title before starting. If the reference is ambiguous, ask.

## Subagent effort

Every subagent spawned during this run, whether you spawn it or a skill you invoke does (`/tdd`, `/review-axes`), runs at **`effort: medium`**, whatever its model. The user's effort level belongs to this session only and never carries over to a spawn. Start every subagent with a fresh context window.

`high` or above (`high`, `xhigh`, `max`) needs the user's explicit yes **before** the spawn: ask, name the subagent, the model, the effort and why medium is not enough, then wait. No answer is a no. One yes covers only the spawn it was asked for.

Where the host cannot set effort per spawn and the subagent would inherit a `high` or higher level from this session, that inheritance counts as spawning at `high`: it needs the same yes first.

If no human can answer (you run as a subagent, unattended, or the brief says nobody is around), stop and report the question as a blocker. Never fall back to doing the work inline. In an interactive session, keep asking and waiting for the yes as above. The same rule covers every other question this run would put to the user, such as where the spec is: unattended, it is a blocker, never a guess.

## 1. Build

Before the first edit, note `git rev-parse HEAD` as the run start. If a gate comes up during the run, handle it per **Human gates** at the end of this file.

Call the Skill tool with "tdd" where possible, working at pre-agreed seams. In a repo with no test suite, the repo's available checks (`validate`, `fmt`, lint, typecheck) are the isolated tests. Run typechecking regularly and single test files regularly.

Anything you write that outlives the run (docblocks, code comments, READMEs, docs, ADRs) never points into `.scratch/`: that folder is wiped periodically, so the reference would dangle. State the needed fact inline, or cite a permanent file in the repo instead.

Done when: every piece of the spec or tickets is written.

## 2. Test

Run the full test suite once. In a repo with no test suite, run the checks the repo does have (`validate`, `fmt`, lint, typecheck) as the suite, and say in the report that there was no test suite. Shared-state checks that are manual (a `curl` from another country, a phone on 4G) become a human gate per **Human gates**: ask the person for the exact list of what to test, once, with the pass condition for each item.

Done when: the suite (or, with none, the repo's available checks) has run and you know its result.

## 3. Refactor

One cleanup pass over the code this run wrote, only while the suite is green.

- **Precondition:** the full suite was green after Test. If it was not, skip this step and say so in the Verdict.
- **Scope:** only code the run's diff created or changed (the uncommitted working tree, so under `/delegate-tickets` exactly the current ticket; when gates caused commits, everything changed since the recorded run start). A worthwhile refactor you see outside the diff is never applied: note it for the Verdict.
- **Rule:** no behaviour change. Never edit a test to make a refactor pass.
- **Snapshot first.** Use `git stash create` (records the state, changes no ref, index or working tree) or copy the diff's files aside. If `git stash create` prints nothing (the tree is clean, as when a gate's commit ended the run), the snapshot is `git rev-parse HEAD`.
- **After refactoring, run the full suite.** Green: keep the refactor. Red: restore the snapshot so the working tree is exactly the pre-refactor green state (for a `git stash create` snapshot, `git restore --source=<snapshot> --worktree -- <files>`, which leaves the index alone; also delete any file the refactor created and recreate any it deleted, since a snapshot does not cover them), then carry on to Review.

Done when: the refactor is either kept with a green suite, or undone back to the green snapshot, or skipped because the suite was red.

## 4. Review

Invoke the /review-axes skill now, as a real Skill call. Give it **the unstaged working tree** as its fixed point: the changes are not in any commit yet, so a ref-based diff would come back empty. In a gated run, follow the order in **Human gates** instead: the fixed point is the recorded run-start sha. Alongside it, pass the path of the ticket you were given, or the spec path when there is no ticket, as the spec argument, so it never has to search for the spec and syncs the right checkboxes. Leave acceptance-criteria checkboxes (`- [ ]` / `- [x]`) in the spec or tickets to `/review-axes`, which syncs them after the Spec review based on what the code actually did.

Done when: `/review-axes` has returned its Standards and Spec reports in this run. Steps 1 to 3 passing is the input to this step, never a substitute for it: the Verdict below is built from the review's output, so it cannot be written until the review exists.

## 5. Commit

Commit your work to the current branch.

In a gated run, follow the order in **Human gates**: this step runs before Review, and fixes made after Review go in one final commit.

Done when: the run's changes are in a commit on the current branch (a run with gates has one commit per stretch, plus a final one for post-review fixes).

## 6. Report

End with a **Verdict** section.

### Verdict

One line: the emoji, then a short reason. 🟢 is the emoji **alone**, with no text after it.

- 🟢 Everything went as planned: fully implemented, nothing deviated from the spec or tickets, `/review-axes` raised nothing that needs action, no user action needed. Print the emoji and nothing else.
- 🟡 Implemented, but something had to be adjusted mid-flight: planned logic changed, an approach was swapped, a spec detail was interpreted, or `/review-axes` raised findings worth a look. Also 🟡: the refactor was undone because the suite went red after it (one-line reason), or a worthwhile refactor was seen outside the diff (suggest a prefactor ticket, never apply it). A refactor that was kept has no effect on the colour. A refactor skipped because the suite was red is stated in the Verdict, and the red suite itself sets the colour as it does today. Say what changed and why.
- 🔴 Something did not land, or the user has to act before moving on: a piece was not implemented, `/review-axes` found a spec gap, a decision needs their call, a credential/migration/manual step is required, anything that breaks their "just start the next ticket" flow. Say what it is and what they need to do.

A run with gates adds: a gate confirmed and verified does not change the colour and is listed as "confirmed by the person". A gate still pending (nobody to ask, or no confirmation yet) is 🔴: name it with its exact command.

Pick the worst applicable colour: any red condition makes the verdict 🔴 even if the rest went fine.

## Human gates

A **gate ticket** only advances when a person performs an action (a `terraform apply`, a deploy, a production migration, a manual test). This session never performs it. The same base text lives in `implement-spec`; keep the two in sync.

- **Recognise it** by the `> **Gate:** human: <what the person does>` line. Without that line, deduce it from the acceptance criteria (for example "applied by the person") and name every deduced gate in the final report. Work that mixes code and a gate has its code part built first, then the gate.
- **Record the run start.** Before the first edit, note `git rev-parse HEAD`: it is the fixed point for the whole run.
- **Commit first.** On reaching a gate, commit what was built so far, so the tree is clean before the person acts. Each **stretch** (the work between two gates, or between the run start and the first gate) gets its own commit; the Commit step covers the last one.
- **Prepare** what the person will use (a `plan` file, a script, a checklist) yourself, in this checkout, right before asking, so it matches the checkout where the action runs.
- **Ask once**, with the exact command (for example `! terraform apply /tmp/x.tfplan`), and wait for the confirmation. Work that does not depend on the gate may continue while you wait; anything that does depend on it waits.
- **After the confirmation**, verify the result yourself (log, metric, `curl`). A failed check is fixed in this session, then verified again, before the next stretch.
- **Record it.** The confirmation counts as evidence: tick the matching criterion `- [x]` and list it in the report as "confirmed by the person". `/review-axes` syncs checkboxes from the code, so it must not undo this: name those criteria when you invoke it, and after it returns re-tick any it flipped back.
- **No human available** (headless, run as a subagent, nobody watching): finish every stretch that does not depend on the gate, then stop blocked and report each pending gate with its exact command. Never work around a gate.

**Order of a gated run.** Refactor and Review run once, at the end, over the whole run, and Commit moves ahead of Review so the last stretch is committed when `/review-axes` diffs from the recorded run start:

1. Build and Test each stretch, committing at every gate.
2. Refactor, over everything changed since the recorded run start.
3. Commit the last stretch.
4. Review, with the recorded run-start sha as the fixed point.
5. Fixes the review drives go into one final commit.
