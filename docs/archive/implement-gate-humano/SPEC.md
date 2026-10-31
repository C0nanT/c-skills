# Gate humano e repos sem testes em `implement-spec` e `implement`

Status: done

Origem: issue C0nanT/c-skills#57.

## Problem Statement

Quem usa `/implement-spec` ou `/implement` numa spec que tem passos feitos por uma pessoa (um `terraform apply`, um deploy, uma migração em produção, um teste de celular no 4G) não encontra lugar para esses passos no fluxo. As duas skills presumem que todo ticket é código que um agente constrói, testa com uma suíte automatizada e integra numa branch de integração.

Na run real do #57 (repo Terraform, 5 tickets em cadeia, dois com `apply` humano, sem testes automatizados e com ordem de commitar direto na `main`) a run funcionou, mas por improviso em quase todos os passos:

- o ticket com ação humana não tinha implementer possível, e a skill não dizia se o orquestrador para, espera ou segue;
- a branch de integração conflitou com a instrução de commitar na `main`;
- o `plan` gerado no worktree do implementer teve que ser refeito no checkout principal, onde o `apply` roda;
- o passo de testes de estado compartilhado não se aplicava, porque os testes eram manuais e fora da máquina;
- critérios como "plan aplicado pela pessoa" ficaram sem regra para serem marcados, deixando a run aberta por várias trocas de mensagem.

O comportamento dependia de o orquestrador acertar o desvio a cada vez.

## Solution

`/implement-spec` e `/implement` passam a reconhecer **tickets com gate humano** (um ticket que só avança depois que uma pessoa executa uma ação) e a tratá-los com um fluxo previsível: o agente prepara o que a pessoa vai usar, pede a ação uma vez com o comando exato, espera a confirmação, verifica o resultado e marca o critério como confirmado pela pessoa. Enquanto espera, os tickets que não dependem do gate continuam.

`/to-tickets` passa a separar cada ação humana num ticket próprio, marcado com uma linha `Gate`, que bloqueia os tickets que dependem dela.

As duas skills de implementação também passam a aceitar dois desvios previstos: commitar na `main` quando o projeto manda explicitamente, e repos sem suíte de testes, onde as checagens disponíveis contam como testes isolados e os testes manuais viram gate humano.

## User Stories

1. Como pessoa que roda `/implement-spec`, quero que um ticket de `apply` humano seja reconhecido como gate, para que o orquestrador não tente spawnar um implementer que não tem como fazê-lo.
2. Como pessoa que roda `/implement`, quero o mesmo reconhecimento de gate, para que a sessão única pare no ponto certo em vez de deixar a ação humana para um veredito 🔴 no final.
3. Como pessoa que roda `/to-tickets`, quero que cada ação humana da spec vire um ticket próprio, para que o grafo de tickets mostre onde a run precisa de mim.
4. Como pessoa que lê um ticket, quero uma linha `> **Gate:** human: <o que a pessoa faz>` fixa no topo, para saber de relance que aquele ticket depende de mim.
5. Como pessoa com tickets antigos ou escritos à mão sem a linha `Gate`, quero que a skill deduza o gate pelos critérios de aceite, para que esses tickets também funcionem.
6. Como pessoa que revisa a run, quero que o relatório final diga quando um gate foi deduzido em vez de lido, para poder corrigir o ticket se a dedução errou.
7. Como pessoa com um ticket antigo que mistura código e ação humana, quero que a skill faça primeiro o código e depois o gate, para não precisar reescrever o ticket.
8. Como pessoa acompanhando a run, quero receber o pedido de ação uma vez, com o comando exato (por exemplo `! terraform apply /tmp/x.tfplan`), para não ter que descobrir o que rodar.
9. Como pessoa acompanhando `/implement-spec`, quero que os tickets independentes do gate continuem enquanto ele espera, para não perder paralelismo por causa de um passo meu.
10. Como pessoa acompanhando a run, quero que os tickets que dependem do gate só comecem depois da minha confirmação, para que nada seja construído sobre um estado que ainda não existe.
11. Como pessoa que vai executar o `apply`, quero que o arquivo de `plan` seja gerado no checkout onde eu vou rodar o comando, logo antes do pedido, para não ter `plan` duplicado nem desatualizado.
12. Como pessoa que roda `/implement-spec`, quero que o implementer só edite, commite e rode as checagens locais num ticket que prepara um gate, para que o artefato do gate saia de um lugar só, o orquestrador.
13. Como pessoa que confirmou a ação, quero que o agente verifique o resultado (log, métrica, `curl`), para não ter que fazer a verificação eu mesma.
14. Como pessoa que confirmou a ação, quero que uma verificação que falha vire trabalho de correção normal (um fix-up implementer no `implement-spec`), para que falha pós-gate não fique em limbo.
15. Como pessoa que roda `/implement`, quero um commit com o que foi construído antes de cada gate, para que o que foi aplicado em produção corresponda a um commit.
16. Como pessoa que roda `/implement`, quero refactor e revisão (`review-axes`) uma vez só, no final, sobre a run inteira, para não multiplicar revisões por causa dos gates.
17. Como pessoa que roda uma das skills sem ninguém para responder (headless, como subagente, sem acompanhamento), quero que um gate vire bloqueio reportado com o comando pendente, para que a run nunca tente contornar uma ação humana.
18. Como pessoa que roda `/implement-spec` sem acompanhamento, quero que os tickets independentes do gate terminem antes do bloqueio, para aproveitar o que dá para fazer.
19. Como pessoa que confirmou uma ação, quero que minha confirmação marque o `- [x]` do critério correspondente, para que o ticket possa ser resolvido.
20. Como pessoa que lê o relatório, quero que critérios marcados por confirmação apareçam como "confirmado pela pessoa", para diferenciar do que foi verificado por código.
21. Como pessoa que lê a tabela de ticket, modelo e effort do `implement-spec`, quero que o ticket de gate apareça como "gate humano", sem modelo nem effort, para não confundir com um spawn.
22. Como pessoa que lê a tabela, quero que o ticket de gate não conte como fallback para Sonnet, para que o relatório de fallbacks só aponte linhas `Difficulty` realmente faltando.
23. Como pessoa que escreve tickets, quero que o ticket de gate mantenha a linha `Difficulty`, para que a skill saiba qual modelo usar num fix-up se a verificação falhar.
24. Como pessoa cujo projeto manda commitar direto na `main`, quero que a `main` vire a branch de integração, para que a skill respeite a regra do repo.
25. Como pessoa cujo projeto manda commitar na `main`, quero que os implementers continuem usando worktrees e branches locais temporárias, para manter o isolamento entre eles sem expor branches para ninguém.
26. Como pessoa sem instrução explícita sobre branches, quero que nada mude e a branch de integração continue sendo criada, para que o desvio só valha quando pedido.
27. Como pessoa num repo sem suíte de testes, quero que as checagens que o repo tem (`validate`, `fmt`, lint, typecheck) contem como testes isolados, para que o `tdd` e o passo de testes tenham algo real para rodar.
28. Como pessoa num repo sem suíte de testes, quero que o relatório diga que não havia suíte, para saber que a verificação foi mais fraca.
29. Como pessoa com testes de estado compartilhado manuais (`curl` de fora do país, celular no 4G), quero que eles virem um gate humano com a lista exata do que testar, para que o passo de testes de estado compartilhado tenha um caminho.
30. Como mantenedora do fork, quero que as duas skills tenham o mesmo texto base de gate, adaptado a cada uma, para que não divirjam com o tempo.
31. Como mantenedora do fork, quero o fluxo de gate registrado no ledger de divergências, para que uma sincronização com o upstream não o apague em silêncio.

## Implementation Decisions

- **Módulos alterados:** `implement-spec`, `implement` e `to-tickets` (os três `SKILL.md`), com os acompanhantes em português de cada skill (`RESUMO.md`, `TRADUCAO.pt-BR.md`) re-sincronizados, as páginas de docs de cada skill re-sincronizadas conforme o guia de escrita de docs e o ledger de divergências do fork atualizado. Conferir se o `ask-skills` precisa mencionar algo; a expectativa é que não, porque nenhuma skill nova entra nem sai do fluxo.
- **Texto do gate mora em cada skill.** As skills são instaladas separadamente pelo `npx`, então uma não pode apontar para um arquivo da outra. Cada `SKILL.md` de implementação ganha uma seção curta com o mesmo texto base, adaptada: orquestrador e subagentes no `implement-spec`, sessão única no `implement`. O ledger registra que as duas precisam ficar em sincronia.
- **Marcação do gate no ticket (`to-tickets`).** Cada ação humana da spec vira um ticket dedicado, com a linha `> **Gate:** human: <o que a pessoa faz>` logo abaixo da linha `Difficulty`, que continua presente. O ticket de gate bloqueia os tickets que dependem da ação.
- **Reconhecimento do gate (`implement-spec` e `implement`).** Lê a linha `Gate` quando existe. Sem ela, deduz pelos critérios de aceite (ex.: "aplicado pela pessoa") e registra a dedução no relatório final. Num ticket que mistura código e gate, a parte de código vem primeiro e o gate depois.
- **Fluxo ao chegar num gate.** Pedir a ação uma vez, com o comando exato. Seguir com os tickets independentes. Os dependentes esperam a confirmação. A run não para inteira, a não ser que nada mais possa andar.
- **Preparo do artefato.** Tudo que a pessoa vai consumir no gate é gerado logo antes do pedido, no checkout onde a ação roda. No `implement-spec`, isso é o checkout principal depois do merge, feito pelo orquestrador; o implementer só edita, commita e roda checagens locais. No `implement`, tudo acontece no mesmo checkout.
- **Verificação pós-confirmação.** Feita pelo orquestrador (a própria sessão no `implement`). Falha vira correção normal: fix-up implementer no `implement-spec`, com o modelo escolhido pela regra atual de fix-up a partir da linha `Difficulty` do ticket de gate.
- **Commit antes do gate no `implement`.** Antes de pedir a ação, commitar o que foi construído até ali; resulta em um commit por trecho entre gates. Refactor e `review-axes` continuam uma vez só, no final, sobre a run inteira.
- **Sem humano disponível.** O gate vira bloqueio: a run para e reporta o gate pendente com o comando exato, sem tentar contornar. É a mesma regra que o `implement` já aplica a qualquer pergunta. No `implement-spec`, os tickets independentes terminam antes.
- **Marcação de critérios por confirmação.** A confirmação da pessoa conta como evidência: o critério correspondente vira `- [x]` e o relatório o lista como "confirmado pela pessoa". No `implement`, isso convive com a sincronização de checkboxes que o `review-axes` já faz.
- **Tabela de modelos (`implement-spec`).** O ticket de gate aparece como "gate humano", sem modelo nem effort, e não conta como fallback para Sonnet.
- **Commit na `main`.** Só com instrução explícita da spec, dos tickets ou do repo: a `main` vira a branch de integração; worktrees e branches locais temporárias dos implementers continuam e são limpas no passo final. Sem instrução, comportamento atual.
- **Repo sem suíte de testes.** A skill descobre as checagens que o repo tem e as usa como testes isolados (no `tdd` e no passo de suíte do `implement`), e o relatório diz que não havia suíte. Testes de estado compartilhado manuais viram um gate humano com a lista exata do que testar, pelo mesmo mecanismo.
- **Estilo.** Prosa sem em-dashes, como manda o `CLAUDE.md` do repo.

## Testing Decisions

- Um bom teste aqui observa o comportamento da skill numa run (o que ela pede, quando espera, o que commita, o que marca e o que relata), nunca a redação interna do `SKILL.md`.
- **Seam: uma run real de cada skill contra uma spec de fixture.** Repo descartável, sem suíte de testes, com instrução de commitar na `main`, e uma spec de 3 tickets: um de código; um com `> **Gate:** human` que depende do primeiro; um que depende do gate. Passa se a run pede o gate uma vez com o comando exato, espera a confirmação, marca o critério do gate como "confirmado pela pessoa", usa a `main` como branch de integração, relata que não havia suíte e, no `implement`, faz um commit antes do gate. Uma segunda passada, sem ninguém para responder, termina em bloqueio com o comando pendente. Para o `to-tickets`, gerar os tickets a partir de uma spec com um `apply` humano e conferir que sai um ticket de gate separado, com a linha `Gate` e a linha `Difficulty`.
- **Seam: marcadores no ledger de divergências.** Linhas novas na tabela do ledger, uma por comportamento novo (gate em `implement-spec`, gate em `implement`, linha `Gate` no `to-tickets`, commit na `main`, repo sem suíte), cada uma com o texto que uma sincronização com o upstream não pode apagar. Funcionam como teste de regressão por busca de texto.
- Módulos testados: `implement-spec`, `implement`, `to-tickets`.
- Prior art: as linhas existentes do ledger para `implement` (ex.: "No human, stop", "Verdict section"), que já usam esse formato de marcador.

## Out of Scope

- Item 5 do #57 (merger subagente para merge trivial): tratado no #47 e no #54.
- Sugerir `/implement` para uma cadeia linear sem paralelismo. Pode virar outro ticket depois.
- Qualquer integração com ferramentas de infra (Terraform, hooks que bloqueiam `apply`): a skill só pede o comando, não conhece a ferramenta.
- Mudanças no `review-axes` ou no `tdd` além de receberem as checagens do repo como testes isolados.

## Further Notes

- O caso de origem (#57) é um repo Terraform, mas o mecanismo é genérico: deploy, migração e testes manuais aparecem em qualquer projeto.
- O #53 (worktrees que começam na `main` em vez da branch de integração) fica mais sensível com o desvio de commit na `main`: quando a `main` é a branch de integração, os dois coincidem, e a checagem de base do implementer continua valendo.
