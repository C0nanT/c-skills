# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

Standing context for every harness lives here. `AGENTS.md` is a versioned pointer that tells Cursor, Codex, and other `AGENTS.md` readers to load this file: edit `CLAUDE.md` only. Shared domain material (`GLOSSARY.md`, `.agents/`, `docs/agents/`) is already harness-neutral, do not copy it into `.cursor/rules/` or a second agent markdown file.

## Repo Purpose

A collection of agent skills (slash commands) for Claude Code, organized into bucket folders and distributed as a Claude Code plugin (the recommended route) and via `npx skills@latest`. Skills are plain markdown files (`SKILL.md`) that Claude reads at invocation time.

## Skill Buckets

Skills live under `skills/`:

- `engineering/`: daily code work
- `productivity/`: daily non-code workflow tools
- `misc/`: kept around but rarely used, not promoted
- `in-progress/`: beta: public on purpose, feedback wanted, not shipped in the plugin
- `deprecated/`: no longer used

## Invariants

Every skill in `engineering/` or `productivity/` (the **promoted** buckets) must have a reference in the top-level `README.md` and an entry in `.claude-plugin/plugin.json`'s `skills` array (the Claude Code plugin ships exactly the promoted set). Skills in `misc/`, `in-progress/`, and `deprecated/` must not appear in either.

Install commands are copied verbatim from [.agents/install-block.md](./.agents/install-block.md). `.claude-plugin/marketplace.json` makes the repo its own single-plugin marketplace, the recommended route on Claude Code; skills.sh is the alternative for other harnesses, editable copies and unpromoted skills. Run `claude plugin validate . --strict` after touching either manifest. Why a Claude plugin but not (yet) a Codex one lives in [.agents/adr/0002-ship-as-a-claude-code-plugin.md](./.agents/adr/0002-ship-as-a-claude-code-plugin.md).

## Dev-only skills (`.agents/local-skills/`)

Skills that only make sense inside this clone (repo maintenance, not end-user work) live in `.agents/local-skills/<skill-name>/`, **not** under `skills/`. `sync-upstream` is the one that lives there today.

Why that path: `npx skills@latest add C0nanT/c-skills` scans the GitHub tree for `SKILL.md` files under `skills/`, `.claude/skills/`, `.agents/skills/`, and the other agents' skill directories, so anything sitting in one of those is offered to people installing this repo. `.agents/local-skills/` is on none of those lists, so the installer never sees it.

To make it usable while working in this clone, `.claude/skills/<skill-name>` is a **symlink** into `.agents/local-skills/<skill-name>`. Claude Code follows it and loads the skill as a project skill; git stores it as a single symlink blob whose path does not end in `SKILL.md`, so the installer still sees nothing. `.gitignore` ignores `.claude/` except for those symlinks.

Rules for a dev-only skill: no entry in `.claude-plugin/plugin.json`, no reference in the top-level `README.md` or a bucket `README.md`, no docs page under `docs/`, and no mention in `ask-skills` (the router ships to users, who do not have it).

## Skill Structure

```
skill-name/
├── SKILL.md           # Main instructions (required)
├── REFERENCE.md       # Detailed docs (if content > ~500 lines)
├── EXAMPLES.md        # Usage examples (if needed)
└── scripts/           # Utility scripts (if needed)
```

`SKILL.md` frontmatter:
```md
---
name: skill-name
description: Brief description. Use when [specific triggers].
---
```
Every `SKILL.md` is either user-invoked (`disable-model-invocation: true` plus `policy.allow_implicit_invocation: false` in `agents/openai.yaml`, reachable only by the human) or model-invoked (model- or user-reachable). See [.agents/invocation.md](./.agents/invocation.md).

Each bucket folder has a `README.md` that lists every skill in the bucket with a one-line description, with the skill name linked to its `SKILL.md`. The promoted buckets' `README.md`s and the top-level `README.md` group entries into **User-invoked** and **Model-invoked**; non-promoted bucket `README.md`s (`misc/`, `in-progress/`) use a flat list.

Skills in `engineering/` and `productivity/` also have a human-facing docs page at `docs/<bucket>/<skill-name>.md` (the docs tree mirrors those two bucket folders under `skills/`). Docs pages link each other relatively (`./<skill-name>.md`, or `../<bucket>/<skill-name>.md` across buckets), never through `aihero.dev`: the docs path is repo organisation only. When you add, rename, or change the behaviour of a skill in `engineering/` or `productivity/`, create or re-sync its docs page following [.agents/writing-docs.md](./.agents/writing-docs.md). A finished page carries four sections: **What it does**, **When to reach for it**, **Common questions**, and **It's working if**. `writing-docs.md` holds the template, the section order, and where to hunt for the questions. Skills in the non-promoted buckets (`misc/`, `in-progress/`, `deprecated/`) get **no** docs page. The one exception is a promoted skill removed outright: its page stays, marked archived (see `writing-docs.md`).

[`ask-skills`](./skills/engineering/ask-skills/SKILL.md) is the router that maps every user-reachable skill and how they relate. Whenever you add, rename, remove, or change how a user-reachable skill fits the flows, re-read `ask-skills`'s `SKILL.md` and update it so the map stays accurate: a new skill it never mentions, or a stale one it still routes to, is a router that lies.

## Scripts

```bash
scripts/list-skills.sh    # Print all SKILL.md paths in the repo
scripts/sync-upstream.sh  # Merge mattpocock/skills (upstream) and strip the skills this fork excludes
```

## Syncing with upstream

This repo is a fork of [mattpocock/skills](https://github.com/mattpocock/skills). Every deliberate difference from it (renamed skills, changed behaviour, dropped paths) is recorded in [.agents/fork-divergences.md](./.agents/fork-divergences.md), and that ledger is what a sync defends. Keep it current the day you decide on a divergence; one that isn't written down is one the next merge silently reverts. Run the sync through the [sync-upstream](./.agents/local-skills/sync-upstream/SKILL.md) skill (dev-only, see below), which resolves conflicts against the ledger and then sweeps the cleanly-merged files for divergences the merge took back.

## Runtime Skill Layout (the install locations, not the clone)

When configuring skills, hooks, or anything that points at a skill asset at
runtime, target where an install puts the skill, never this cloned repo. End
users are not expected to clone this project: they only have what the plugin or
`npx skills@latest` downloads, and the repo path (`skills/<bucket>/<skill>/`)
exists on neither.

- **Plugin**: Claude Code copies the plugin into its cache, at a path that
  changes with each version. Resolve it at runtime from the `installPath` of
  the `c-skills@…` entry in `~/.claude/plugins/installed_plugins.json`, then
  append the repo-relative path (`skills/<bucket>/<skill>/…`). Never hard-code
  the cache path.
- **skills.sh**: `npx skills@latest …` installs into `~/.agents/skills/<skill>/`
  (the real directory), then symlinks each into `~/.claude/skills/<skill>` →
  `../../.agents/skills/<skill>`. Reference that through
  `~/.claude/skills/<skill>/…`.
- A hook that reads a skill asset checks both, so it works on either route and
  stays "live" (the asset is read at runtime, so updates take effect without
  reinstalling the hook). The `caveman` function in `c-mods` still reads only
  `~/.claude/skills/caveman/SKILL.md`, so on the plugin route it finds nothing
  until `c-mods` follows this rule.

## Writing Style

No em-dashes anywhere in this repo's prose (`SKILL.md` files, docs, `README.md`, `CHANGELOG.md`, ADRs, changesets, code comments). Where a sentence reaches for one, rewrite it instead with a comma, colon, period, parentheses, or a conjunction, whichever the sentence actually wants; never do a blind character substitution. This matches upstream, so prose files stop conflicting on punctuation at every sync.

Every skill that dispatches a subagent says to start it with a fresh context window. Some harnesses (Codex, for one) fork the parent conversation by default, and a fork inherits the parent's context, which is what the subagent was meant to escape.

## Domain Language (from GLOSSARY.md)

- **Issue tracker**: the tool hosting a repo's issues (GitHub Issues, Linear, local `.scratch/`). Not "backlog".
- **Ticket**: a single tracked unit of work. Use "issue" only when naming a real object on an external tracker (a GitHub issue, a GitLab issue).
- **Triage role**: a state-machine label applied to an issue during triage.

Every `SKILL.md` is either user-invoked (`disable-model-invocation: true`, reachable only by the human) or model-invoked (model- or user-reachable). For the full definitions, description conventions, and why a user-invoked skill can invoke model-invoked skills but never another user-invoked one, see [.agents/invocation.md](./.agents/invocation.md).

## Agent skills

### Issue tracker

Tickets live as local markdown files under `.scratch/<feature-slug>/tickets/` (no GitHub integration). See `docs/agents/issue-tracker.md`.

### Triage labels

Default canonical strings: `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context repo: one `GLOSSARY.md` at the root, ADRs in `.agents/adr/`. See `docs/agents/domain.md`.
