# 03: implement trata ticket com gate humano

> **Difficulty:** Standard: **suggested model:** Sonnet (Claude Code) / Sonnet (Cursor). Suggestion only, use whatever model you have to hand.

**Spec:** ../SPEC.md

**What to build:** `/implement` usa o mesmo texto base de gate do `implement-spec`, adaptado para uma sessão única. Ao chegar num gate, a sessão commita o que foi construído até ali, gera o artefato no próprio checkout, pede a ação uma vez com o comando exato, espera a confirmação, verifica o resultado e segue para o próximo trecho. Isso dá um commit por trecho entre gates. Refactor e `review-axes` continuam uma vez só, no final, sobre a run inteira. A confirmação marca o critério como "confirmado pela pessoa", sem conflitar com a sincronização de checkboxes que o `review-axes` já faz. Sem humano disponível, o gate vira bloqueio, pela regra que o `implement` já tem para qualquer pergunta. O Verdict reflete gates confirmados e gates pendentes.

**Seams:**
- Uma run real de cada skill contra uma spec de fixture (parte do `implement`)
- Marcadores no ledger de divergências

**Blocked by:** 02 (implement-spec trata ticket com gate humano)

Status: done

- [x] O `SKILL.md` ganha a seção de gate com o mesmo texto base do `implement-spec`, adaptado para sessão única
- [x] Antes de cada gate há um commit do que foi construído até ali, e o passo de commit final continua para o último trecho
- [x] Refactor e `review-axes` rodam uma vez só, no final, sobre todos os commits da run
- [x] A confirmação marca o critério como `- [x]` registrado como "confirmado pela pessoa", sem ser desfeito pela sincronização do `review-axes`
- [x] Sem humano disponível, o gate vira bloqueio com o comando pendente, e o Verdict é 🔴
- [x] Uma run contra a spec de fixture faz um commit antes do gate, pede o gate uma vez, espera e marca "confirmado pela pessoa"; uma segunda passada sem ninguém para responder termina em bloqueio
- [x] `RESUMO.md` e `TRADUCAO.pt-BR.md` do `implement` re-sincronizados
- [x] Página de docs do `implement` re-sincronizada conforme o guia de escrita de docs
- [x] Linha nova no ledger de divergências para o gate no `implement`, apontando a sincronia com o `implement-spec`
- [x] Prosa sem em-dashes
