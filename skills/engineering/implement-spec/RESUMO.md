# Resumo: implement-spec

**O que faz:** implementa em código uma especificação que já tem tickets, gerados por `/to-spec` e `/to-tickets`. Os tickets formam um grafo de dependências. Subagentes implementadores trabalham em paralelo, cada um em seu worktree, e o orquestrador junta o trabalho em um **branch de integração**, com `git merge --no-ff`; um subagente de merge só entra quando há conflito. O prompt de cada implementador abre com o branch de integração e o sha esperado, e a especificação e os tickets são lidos por caminho absoluto no checkout principal. Subagentes em segundo plano avisam sozinhos ao terminar, então o orquestrador encerra o turno e espera, sem wakeup nem cron. Testes que mexem em estado compartilhado (banco, API, e2e) só rodam uma vez, em série, no branch de integração depois dos merges, para os paralelos não se corromperem. Cada implementador roda no modelo que a linha Difficulty do seu ticket sugere (Sonnet e Opus sempre com esforço medium, Haiku sem configuração de esforço); exploração e merge (este só em conflito) rodam Sonnet medium, e uma tabela ticket, modelo e esforço é mostrada antes de começar e repetida no relatório final. Se o host não define o modelo por subagente (ou o esforço, quando há Sonnet ou Opus na execução), a execução para e sugere `/implement`. Depois roda `review-axes` e corrige os problemas encontrados. Depois marca o PR como pronto ou atualiza os tickets no tracker local.

**Quando usar:** quando uma especificação e seus tickets já estão prontos e você quer que sejam construídos.

**Como invocar:** `/implement-spec`. É uma skill só para o usuário (`disable-model-invocation: true`).

**Arquivos:** `SKILL.md` (original em inglês), `TRADUCAO.pt-BR.md` (tradução) e este `RESUMO.md`. Usa as skills `tdd` e `review-axes`, além de `/archive-feature`.

<!-- aligned-with: sha256:0521357061b26e43d1c2cef1fcee22e4fe9ea4a79f4b94dd74bf38c336296d91 -->
