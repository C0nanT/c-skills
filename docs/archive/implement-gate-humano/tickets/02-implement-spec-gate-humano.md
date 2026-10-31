# 02: implement-spec trata ticket com gate humano

> **Difficulty:** Standard: **suggested model:** Sonnet (Claude Code) / Sonnet (Cursor). Suggestion only, use whatever model you have to hand.

**Spec:** ../SPEC.md

**What to build:** `/implement-spec` reconhece um ticket de gate pela linha `Gate` ou, sem ela, pelos critérios de aceite, e registra a dedução no relatório. O ticket de gate não ganha implementer. Quando ele entra na frontier, o orquestrador gera no checkout principal, depois do merge, o que a pessoa vai usar (ex.: arquivo de `plan`) e pede a ação uma vez com o comando exato. Enquanto espera, segue com os tickets independentes, e os dependentes esperam a confirmação. Depois da confirmação, o orquestrador verifica o resultado. Uma falha vira um fix-up implementer, com o modelo vindo da `Difficulty` do ticket de gate. A confirmação marca o critério como `- [x]` e o relatório o lista como "confirmado pela pessoa". Sem humano disponível, os tickets independentes terminam e a run para em bloqueio, reportando o comando pendente. Na tabela de ticket, modelo e effort, o gate aparece como "gate humano", sem modelo nem effort, e não conta como fallback. Num ticket antigo que mistura código e gate, a parte de código vai para o implementer primeiro e o gate vem depois. Esta seção do `SKILL.md` é o texto base que o ticket 03 adapta para o `implement`.

**Seams:**
- Uma run real de cada skill contra uma spec de fixture (parte do `implement-spec`)
- Marcadores no ledger de divergências

**Blocked by:** 01 (to-tickets gera ticket de gate separado com linha `Gate`)

Status: done

- [x] O `SKILL.md` ganha uma seção curta de gate humano cobrindo reconhecimento (linha `Gate` ou dedução registrada), pedido único com o comando exato, tickets independentes seguindo, dependentes esperando a confirmação
- [x] O preparo do artefato do gate é feito pelo orquestrador no checkout principal, depois do merge, e o implementer de um ticket que prepara um gate só edita, commita e roda checagens locais
- [x] A verificação depois da confirmação é feita pelo orquestrador, e uma falha vira fix-up implementer pela regra atual de modelo de fix-up
- [x] A confirmação marca o critério como `- [x]` e o relatório final o lista como "confirmado pela pessoa"
- [x] Sem humano disponível, os tickets independentes terminam e a run para em bloqueio, reportando o comando pendente
- [x] Na tabela de modelos, o ticket de gate aparece como "gate humano", sem modelo nem effort, e não entra na lista de fallbacks para Sonnet
- [x] Um ticket que mistura código e gate tem a parte de código feita primeiro e o gate depois
- [x] Uma run contra a spec de fixture (código, gate que depende dele, ticket que depende do gate) pede o gate uma vez, espera, marca "confirmado pela pessoa"; uma segunda passada sem ninguém para responder termina em bloqueio
- [x] `RESUMO.md` e `TRADUCAO.pt-BR.md` do `implement-spec` re-sincronizados
- [x] Página de docs do `implement-spec` re-sincronizada conforme o guia de escrita de docs
- [x] Linha nova no ledger de divergências para o gate no `implement-spec`, dizendo que o texto base tem que ficar em sincronia com o `implement`
- [x] Prosa sem em-dashes
