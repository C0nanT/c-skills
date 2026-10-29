```yaml
name: implement-spec
description: "Implemente em código o resultado de /to-spec e /to-tickets."
disable-model-invocation: true
```

Você recebeu uma especificação. Ela deve ter tickets associados, que descrevem como implementá-la.

Resolva o issue tracker da mesma forma que o `/to-tickets`: uma instrução explícita do usuário, senão `docs/agents/issue-tracker.md` (escrito pelo `/setup-skills`), senão markdown local em `.scratch/<feature-slug>/tickets/`.

O objetivo é a especificação inteira implementada em um único **branch de integração**, com cada ticket resolvido da forma como o issue tracker encerra o trabalho.

Os tickets não são uma lista de passos. Eles formam um **grafo de tarefas** com relações de bloqueio entre si. Isso significa que sempre há uma **fronteira** de tickets prontos para serem pegos.

A comunicação com subagentes deve ser esparsa. Comunique-se principalmente por **ponteiros de contexto**: a especificação, os tickets, as notas de pesquisa e os commits anteriores. Não duplique informações que já estão disponíveis por meio desses ponteiros.

Os **subagentes implementadores** devem rodar em segundo plano sempre que possível, para máxima concorrência.

## Modelos e esforço

Todo ticket tem uma linha `> **Difficulty:**`. Cada **subagente implementador** roda no modelo que essa linha sugere para o host atual, com esforço fixo.

- **Leitura do modelo.** No Claude Code, use o nome antes de `(Claude Code)`; no Cursor, o nome antes de `(Cursor)`. Tolere o separador antigo ainda presente em tickets velhos, um travessão no lugar dos dois-pontos que a linha tem hoje.
- **Ordem de resolução.** O modelo nomeado, se reconhecido (um nome que contenha `opus`, `sonnet` ou `haiku`, sem diferenciar maiúsculas, no lado do host na linha); senão o tier (Heavy é Opus, Standard é Sonnet, Light é Haiku); senão Sonnet quando a linha está ausente ou não pode ser interpretada. Registre cada fallback para Sonnet causado por linha ausente ou ilegível e cite-o no relatório final.
- **Esforço.** Todo spawn de Sonnet e Opus passa `effort: medium`, nunca mais alto, mesmo que o usuário aprovasse mais. Um spawn de Haiku não passa configuração de esforço. Isso vale para subagentes criados por skills invocadas dentro da execução (`tdd`, `review-axes`).
- **Tickets Heavy** rodam em Opus com esforço medium, sem aprovação humana.
- **Subagentes sem ticket.** O **subagente de exploração** e o **subagente de merge** rodam Sonnet com esforço medium. O de merge só é criado quando um merge dá conflito (passo 5). Um **subagente de correção** (falhas de estado compartilhado no passo 7, achados da revisão no passo 8) usa o modelo mais forte entre os tickets envolvidos (Haiku < Sonnet < Opus), com piso de Sonnet com esforço medium, e Sonnet com esforço medium quando não for possível determinar os tickets envolvidos.
- **Limites do host.** Pare se o host não consegue definir o modelo por spawn, ou não consegue definir o esforço por spawn em uma execução com algum spawn de Sonnet ou Opus (uma execução só com Haiku não precisa de controle de esforço). Pare antes de criar qualquer subagente, avise o usuário e sugira `/implement`. Nunca recorra ao modelo ou esforço da própria sessão.

Antes do primeiro spawn de implementador, imprima uma tabela de ticket, modelo e esforço, marcando qualquer fallback, e siga adiante sem esperar confirmação. Repita a tabela no relatório final.

## Passos

1. Leia a especificação e os tickets para entender o grafo de tarefas.

2. (opcional) Use um **subagente de exploração** (conforme **Modelos e esforço**) para fazer qualquer exploração exigida pelos tickets: arquivos relevantes da base de código ou documentação externa. Garanta que o subagente de exploração consiga salvar arquivos: ele deve gravar as notas em markdown em um diretório fora do repositório, acessível a todos os subagentes futuros. Assim, os **subagentes implementadores** se concentram na implementação, e não na exploração.

3. Crie o branch de integração. Se o issue tracker encerra o trabalho por meio de PRs, ou se o usuário pedir, abra um PR em rascunho depois do primeiro merge do passo 5 (um branch sem commits à frente da main não pode abrir um PR), marcado como fechando a especificação e os tickets.

4. Use **subagentes implementadores** para implementar cada ticket, cada um em seu próprio worktree e em seu próprio branch, no modelo e esforço de **Modelos e esforço**. Abra o prompt de cada implementador com o branch de integração e o sha de onde ele deve partir. Se o host permitir escolher a base do worktree, use isso; senão o implementador faz reset. Em um tracker local em markdown, a especificação e os tickets não são rastreados e por isso não existem nos worktrees: aponte os implementadores para eles por caminho absoluto no checkout principal. Cada subagente implementador:
   - confere seu worktree contra esse branch e esse sha antes de começar, e faz reset para o branch de integração se forem diferentes;
   - chama a ferramenta Skill com `tdd` para construir o ticket, rodando apenas **testes isolados** (unitários e de lógica pura, nada que toque estado compartilhado). Ele escreve os **testes de estado compartilhado** que o ticket exige (banco de dados, API, e2e, qualquer coisa em porta, arquivo, fila ou serviço externo compartilhado), mas não os executa;
   - faz merge da ponta do branch de integração no próprio branch antes de reportar que terminou

   Subagentes em segundo plano avisam sozinhos quando terminam: encerre o turno e espere esse aviso, sem wakeup e sem cron.

5. Assim que um **subagente implementador** terminar, faça você mesmo o merge do branch dele no branch de integração com `git merge --no-ff`. Se o git relatar conflito, rode `git merge --abort` e entregue esse merge a um **subagente de merge** (veja **Modelos e esforço**).

6. Se isso alterar a **fronteira** de tickets disponíveis, dispare mais **subagentes implementadores** para trabalhar nos novos tickets. Isso permite máxima concorrência.

7. Quando todos os tickets estiverem concluídos e mesclados, rode os **testes de estado compartilhado** uma única vez, em série, no branch de integração (sem nenhum outro subagente rodando). Implementadores em paralelo compartilham o mesmo banco, portas e serviços, então esses testes corromperiam os dados uns dos outros se rodassem durante os passos 4 a 6. Corrija todas as falhas em um único **subagente implementador** de correção e rode de novo apenas os testes que falharam.

8. Chame a ferramenta Skill com `review-axes` no branch de integração, passando o caminho da especificação como argumento de spec. Corrija todos os problemas levantados pela revisão em um único **subagente implementador** de correção. Se as correções tocarem código coberto por testes de estado compartilhado, rode esses testes de novo, em série, depois.

9. Se existir um PR em rascunho, marque-o como pronto para revisão. Caso contrário, resolva cada ticket da forma como o issue tracker encerra o trabalho e informe o branch de integração, com a tabela de ticket, modelo e esforço de **Modelos e esforço**.
   Em um tracker local em markdown, resolver um ticket significa marcar o arquivo dele no checkout principal (não em um worktree): troque cada critério de aceitação que o branch de integração implementa para `- [x]`, com base no relatório de Spec do passo 7 e no trabalho mesclado do ticket, deixe os não atendidos como `- [ ]` e defina `Status: ready-for-human` quando todas as caixas estiverem marcadas. Um ticket com alguma caixa desmarcada mantém o status e é listado no relatório. É isso que o `/archive-feature` verifica antes de arquivar a funcionalidade.

10. Limpe todos os worktrees dos **subagentes implementadores**.

<!-- aligned-with: sha256:0521357061b26e43d1c2cef1fcee22e4fe9ea4a79f4b94dd74bf38c336296d91 -->
