# Resumo: pr

**O que faz:** dá o formato do corpo de um pull request: um **Summary** com a menor visualização que mostra a mudança (pseudocódigo, árvore de chamadas, árvore de componentes, árvore de arquivos, Mermaid ou diff), um **Evidence** com antes e depois (capturas de tela ou testes que passam a falhar e a passar) e um **Merge Danger** que classifica o PR como porta de mão única ou de mão dupla e descreve o raio de impacto. Para gravar o corpo num PR que já existe, usa `gh api -X PATCH` e lê o PR de volta para confirmar o texto. Foi adaptada da skill `show-me`, de Dex Horthy (Humanlayer), com os créditos no frontmatter.

**Quando usar:** sempre que o agente escrever o corpo de um PR.

**Como invocar:** o agente a chama sozinho ao escrever um PR (sem `disable-model-invocation`). Não há um comando `/pr` separado para o usuário.

**Arquivos:** `SKILL.md` (original em inglês), `TRADUCAO.pt-BR.md` (tradução), `CREDITS.md` (créditos da origem, mantido em inglês) e este `RESUMO.md`.

<!-- aligned-with: sha256:7a9ddba91397ede9e20f9eb8418c56f370434a0716d8612a6d8883575dd37453 -->
