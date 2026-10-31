# The canonical install block

One install story, one wording. `README.md` and every page under `docs/` must say **this** and nothing else. Change it here first, then propagate. `README.md` carries it in Portuguese; the commands stay verbatim.

## Claude Code plugin first

The documented route on Claude Code is the plugin. `.claude-plugin/marketplace.json` makes this repo its own single-plugin marketplace, shipping exactly the promoted set listed in `.claude-plugin/plugin.json`. It is a read-only bundle: updates arrive with `claude plugin update`, and the files live in Claude Code's plugin cache, not in a folder you edit.

<canonical-block name="claude-code-plugin">

```text
/plugin marketplace add C0nanT/c-skills
/plugin install c-skills@c-skills
```

Update with `claude plugin update c-skills`, then `/reload-plugins`.

</canonical-block>

<canonical-block name="claude-code-plugin-remove">

```text
/plugin uninstall c-skills@c-skills
```

</canonical-block>

## skills.sh (alternative)

skills.sh serves the cases the plugin does not: other harnesses (Codex, Cursor and the rest), skill files you want to edit, and the unpromoted skills in `misc/` and `in-progress/`, which the plugin never ships. It copies the skills into `~/.agents/skills/<skill>/` and symlinks each into every agent's skills directory (`~/.claude/skills/<skill>` on Claude Code).

<canonical-block name="skills-sh">

```bash
npx skills@latest add C0nanT/c-skills
```

When the installer asks which skills to take, include `setup-skills`. To update, run `npx skills@latest update`, and re-run `add` to pick up new skills.

</canonical-block>

Use the single-skill form wherever one skill is named on its own, including the unpromoted ones in `misc/` and `in-progress/`. `docs/` pages don't use this block. See [writing-docs.md](./writing-docs.md).

<canonical-block name="skills-sh-one-skill">

```bash
npx skills@latest add C0nanT/c-skills --skill=<name>
```

```bash
npx skills@latest update <name>
```

</canonical-block>

<canonical-block name="skills-sh-remove">

```bash
npx skills@latest remove              # interactive menu
npx skills@latest remove <name>       # one skill
npx skills@latest remove --all -g     # all of them (global scope)
```

Without `-g` the command acts on the current project; with `-g`, on `~/.agents/skills/` and each agent's symlinks.

</canonical-block>

`skills@latest` is the pinned spelling everywhere.

## The two routes are exclusive

The plugin is a read-only bundle you subscribe to. skills.sh writes files you own and edit. Installing both leaves the user with every skill twice: always say "pick one". The one exception is an unpromoted skill added with the single-skill form next to the plugin: the plugin does not carry it, so nothing doubles.

## Hooks

Hooks are not part of this repo. They ship as the `c-mods` plugin from [C0nanT/c-mods](https://github.com/C0nanT/c-mods), installed separately on either route.

<canonical-block name="hooks">

```text
/plugin install c-mods --marketplace C0nanT/c-mods
```

Update with `claude plugin update c-mods`, then `/reload-plugins`. Remove with `/plugin uninstall c-mods`.

</canonical-block>
