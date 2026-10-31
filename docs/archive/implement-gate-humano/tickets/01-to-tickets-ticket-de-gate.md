# 01: to-tickets gera ticket de gate separado com linha `Gate`

> **Difficulty:** Standard: **suggested model:** Sonnet (Claude Code) / Sonnet (Cursor). Suggestion only, use whatever model you have to hand.

**Spec:** ../SPEC.md

**What to build:** quando a spec tem uma ação que só uma pessoa pode fazer (um `apply`, um deploy, uma migração em produção, um teste manual), `/to-tickets` a separa num ticket próprio. Esse ticket leva a linha `> **Gate:** human: <o que a pessoa faz>` logo abaixo da linha `Difficulty` (que continua presente) e bloqueia os tickets que dependem da ação. Os templates de ticket local e de issue mostram a linha `Gate` como opcional, usada só em tickets de gate.

**Seams:**
- Uma run real de cada skill contra uma spec de fixture (parte do `to-tickets`: gerar os tickets de uma spec com um `apply` humano)
- Marcadores no ledger de divergências

**Blocked by:** None (can start immediately)

Status: done

- [x] O `SKILL.md` do `to-tickets` diz para separar cada ação humana num ticket dedicado que bloqueia os dependentes
- [x] Os dois templates (ticket local e issue) mostram a linha `> **Gate:** human: <o que a pessoa faz>` abaixo da `Difficulty`, como opcional e só para tickets de gate
- [x] O ticket de gate mantém a linha `Difficulty`
- [x] Rodar `/to-tickets` numa spec de fixture com um `apply` humano gera um ticket de gate separado, com as linhas `Gate` e `Difficulty`, bloqueando o ticket seguinte
- [x] `RESUMO.md` e `TRADUCAO.pt-BR.md` do `to-tickets` re-sincronizados
- [x] Página de docs do `to-tickets` re-sincronizada conforme o guia de escrita de docs
- [x] Linha nova no ledger de divergências para a linha `Gate`, com o marcador de texto que uma sincronização não pode apagar
- [x] Prosa sem em-dashes
