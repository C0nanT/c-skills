```yaml
name: setup-statusline
description: Substitua a antiga status line em shell pelo plugin c-mods
disable-model-invocation: true
```

# Configurar a status line

A status line agora vive no plugin `c-mods` (função `statusline`): modelo, esforço, uso de contexto, duração da sessão, limite de taxa e branch do git, sem script bash, sem `jq` e sem arquivo de linha de base. Esta skill não instala mais nada. Ela remove da máquina o modelo antigo baseado em shell e aponta para o plugin.

## O que é removido

- `statusLine` em `~/.claude/settings.json`, somente quando o comando dela aponta para `statusline-command.sh`.
- Entradas de hook com o marcador `claude-hook:statusline-reset` em `SessionStart`, `SessionEnd` e `UserPromptSubmit`.
- `~/.claude/statusline-command.sh`, `~/.claude/statusline-reset-hook.sh` e `~/.claude/statusline-baseline.json`.

Todo o resto do `settings.json` permanece intacto.

## Pré-requisitos

- `jq` instalado (usado apenas para esta limpeza)

## Passos

### 1. Limpe a configuração antiga

```bash
SETTINGS="$HOME/.claude/settings.json"

if [ -s "$SETTINGS" ] && jq -e . "$SETTINGS" >/dev/null 2>&1; then
  jq '
    (if ((.statusLine.command // "") | test("statusline-command\\.sh")) then del(.statusLine) else . end)
    | reduce ("SessionStart","SessionEnd","UserPromptSubmit") as $ev (.;
        if .hooks[$ev] then
          .hooks[$ev] |= map(select((.hooks // []) | map(.command // "") | any(test("claude-hook:statusline-reset")) | not))
          | if (.hooks[$ev] | length) == 0 then del(.hooks[$ev]) else . end
        else . end)
    | if (.hooks // null) == {} then del(.hooks) else . end
  ' "$SETTINGS" > "$SETTINGS.tmp" && mv "$SETTINGS.tmp" "$SETTINGS"
else
  echo "settings.json missing or not valid JSON: nothing to clean"
fi

rm -f "$HOME/.claude/statusline-command.sh" \
      "$HOME/.claude/statusline-reset-hook.sh" \
      "$HOME/.claude/statusline-baseline.json"
```

### 2. Instale o plugin

Diga ao usuário para rodar, dentro do Claude Code:

```text
/plugin install c-mods --marketplace C0nanT/c-mods
```

Se já estiver instalado: `claude plugin update c-mods`, depois `/reload-plugins`.

### 3. Ative e desative

```text
/c-mods statusline off
/c-mods statusline on
```

O relógio de reinício usa o fuso horário local da máquina. Se a detecção automática estiver errada, defina `STATUSLINE_TZ` (nome IANA, por exemplo `America/Sao_Paulo`) em `env` no `~/.claude/settings.json`.

<!-- aligned-with: sha256:4a29da9a4f9728cae9a0dfcccba26584cb36c5060f6c0eadf37054de4c61588c -->
