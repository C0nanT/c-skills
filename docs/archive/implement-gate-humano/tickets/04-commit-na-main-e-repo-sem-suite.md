# 04: Commit na `main` e repo sem suíte de testes nas duas skills

> **Difficulty:** Standard: **suggested model:** Sonnet (Claude Code) / Sonnet (Cursor). Suggestion only, use whatever model you have to hand.

**Spec:** ../SPEC.md

**What to build:** quando a spec, os tickets ou o repo mandam explicitamente commitar direto na `main`, o `/implement-spec` usa a `main` como branch de integração. Os worktrees e as branches locais temporárias dos implementers continuam e são limpos no passo final. Sem instrução explícita, nada muda. Num repo sem suíte de testes, as duas skills descobrem as checagens que o repo tem (`validate`, `fmt`, lint, typecheck) e as usam como testes isolados, no `tdd` e no passo de suíte do `implement`. O relatório diz que não havia suíte. Testes manuais de estado compartilhado viram um gate humano com a lista exata do que a pessoa testa, usando o mecanismo dos tickets 02 e 03.

**Seams:**
- Uma run real de cada skill contra uma spec de fixture (repo sem suíte e com instrução de commitar na `main`)
- Marcadores no ledger de divergências

**Blocked by:** 02 (implement-spec trata ticket com gate humano), 03 (implement trata ticket com gate humano)

Status: done

- [x] O `implement-spec` usa a `main` como branch de integração só com instrução explícita, mantendo worktrees e branches locais dos implementers
- [x] Sem instrução explícita, o `implement-spec` continua criando a branch de integração
- [x] As duas skills, num repo sem suíte, usam as checagens disponíveis como testes isolados e dizem no relatório que não havia suíte
- [x] Testes manuais de estado compartilhado viram gate humano com a lista exata do que testar (passo 7 do `implement-spec`, passo de suíte do `implement`)
- [x] Uma run de cada skill contra a spec de fixture (sem suíte, com instrução de commitar na `main`) usa a `main` como integração e relata que não havia suíte
- [x] `RESUMO.md`, `TRADUCAO.pt-BR.md` e páginas de docs das duas skills re-sincronizados
- [x] Linhas novas no ledger de divergências para commit na `main` e para repo sem suíte
- [x] Prosa sem em-dashes
