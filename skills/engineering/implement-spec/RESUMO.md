# Resumo: implement-spec

**O que faz:** implementa em código uma especificação que já tem tickets, gerados por `/to-spec` e `/to-tickets`. Os tickets formam um grafo de dependências. Subagentes implementadores trabalham em paralelo, cada um em seu worktree, e um subagente de merge junta o trabalho em um **branch de integração**. Testes que mexem em estado compartilhado (banco, API, e2e) só rodam uma vez, em série, no branch de integração depois dos merges, para os paralelos não se corromperem. Cada implementador roda no modelo que a linha Difficulty do seu ticket sugere (Sonnet e Opus sempre com esforço medium, Haiku sem configuração de esforço); exploração e merge rodam Sonnet medium, e uma tabela ticket, modelo e esforço é mostrada antes de começar e repetida no relatório final. Se o host não define o modelo por subagente (ou o esforço, quando há Sonnet ou Opus na execução), a execução para e sugere `/implement`. Depois roda `review-axes` e corrige os problemas encontrados. Depois marca o PR como pronto ou atualiza os tickets no tracker local.

**Quando usar:** quando uma especificação e seus tickets já estão prontos e você quer que sejam construídos.

**Como invocar:** `/implement-spec`. É uma skill só para o usuário (`disable-model-invocation: true`).

**Arquivos:** `SKILL.md` (original em inglês), `TRADUCAO.pt-BR.md` (tradução) e este `RESUMO.md`. Usa as skills `tdd` e `review-axes`, além de `/archive-feature`.

<!-- aligned-with: sha256:fb950a9c300ebd03f580e072adccaca669856eb1a766f20810e903257012f3f0 -->
