```yaml
name: implement-spec
description: "Implemente em código o resultado de /to-spec e /to-tickets."
disable-model-invocation: true
```

Você recebeu uma especificação. Ela deve ter tickets associados, que descrevem como implementá-la.

Resolva o issue tracker da mesma forma que o `/to-tickets`: uma instrução explícita do usuário, senão `docs/agents/issue-tracker.md` (escrito pelo `/setup-skills`), senão markdown local em `.scratch/<feature-slug>/tickets/`.

O objetivo é a especificação inteira implementada em um único **branch de integração**, com cada ticket resolvido da forma como o issue tracker encerra o trabalho.

Os tickets não são uma lista de passos. Eles formam um **grafo de tarefas** com relações de bloqueio entre si. Isso significa que sempre há uma **fronteira** de tickets prontos para serem pegos.

Inicie cada subagente com uma janela de contexto nova.

A comunicação com subagentes deve ser esparsa. Comunique-se principalmente por **ponteiros de contexto**: a especificação, os tickets, as notas de pesquisa e os commits anteriores. Não duplique informações que já estão disponíveis por meio desses ponteiros.

Os **subagentes implementadores** devem rodar em segundo plano sempre que possível, para máxima concorrência.

## Modelos e esforço

Todo ticket tem uma linha `> **Difficulty:**`. Cada **subagente implementador** roda no modelo que essa linha sugere para o host atual, com esforço fixo.

- **Leitura do modelo.** No Claude Code, use o nome antes de `(Claude Code)`; no Cursor, o nome antes de `(Cursor)`. Tolere o separador antigo ainda presente em tickets velhos, um travessão no lugar dos dois-pontos que a linha tem hoje.
- **Ordem de resolução.** O modelo nomeado, se reconhecido (um nome que contenha `opus`, `sonnet` ou `haiku`, sem diferenciar maiúsculas, no lado do host na linha); senão o tier (Heavy é Opus, Standard é Sonnet, Light é Haiku); senão Sonnet quando a linha está ausente ou não pode ser interpretada. Registre cada fallback para Sonnet causado por linha ausente ou ilegível e cite-o no relatório final.
- **Esforço.** Todo spawn de Sonnet e Opus passa `effort: medium`, nunca mais alto, mesmo que o usuário aprovasse mais. Um spawn de Haiku não passa configuração de esforço. Isso vale para subagentes criados por skills invocadas dentro da execução (`tdd`, `review-axes`).
- **Tickets Heavy** rodam em Opus com esforço medium, sem precisar de aprovação do usuário.
- **Tickets de gate** (veja **Gates humanos**): um ticket de gate puro não ganha implementador, então a tabela o lista como "gate humano", sem modelo e sem esforço, e ele não conta como fallback para Sonnet. Um ticket misto (código e gate) é listado com o modelo do implementador para a parte de código, e depois o gate. A linha `Difficulty` deles ainda vale: um fix-up depois de uma verificação de gate que falhou trata o ticket de gate como um ticket envolvido.
- **Subagentes sem ticket.** O **subagente de exploração** e o **subagente de merge** rodam Sonnet com esforço medium. Um **subagente de correção** (falhas de estado compartilhado no passo 7, achados da revisão no passo 8) usa o modelo mais forte entre os tickets envolvidos (Haiku < Sonnet < Opus), com piso de Sonnet com esforço medium, e Sonnet com esforço medium quando não for possível determinar os tickets envolvidos.
- **Limites do host.** Pare se o host não consegue definir o modelo por spawn, ou não consegue definir o esforço por spawn em uma execução com algum spawn de Sonnet ou Opus (uma execução só com Haiku não precisa de controle de esforço). Pare antes de criar qualquer subagente, avise o usuário e sugira `/implement`. Nunca recorra ao modelo ou esforço da própria sessão.

Antes do primeiro spawn de implementador, imprima uma tabela de ticket, modelo e esforço, marcando qualquer fallback, e siga adiante sem esperar confirmação. Repita a tabela no relatório final.

## Gates humanos

Um **ticket de gate** só avança quando uma pessoa executa uma ação (um `terraform apply`, um deploy, uma migração em produção, um teste manual). Um ticket de gate puro não ganha implementador.

- **Reconheça-o** pela linha `> **Gate:** human: <o que a pessoa faz>`. Sem essa linha, deduza pelos critérios de aceite (por exemplo "aplicado pela pessoa") e cite cada gate deduzido no relatório final. Um ticket que mistura código e gate tem a parte de código construída primeiro por um implementador (listado na tabela com o modelo dele), e depois o gate.
- **Prepare** você mesmo o que a pessoa vai usar (um arquivo de `plan`, um script, um checklist), no checkout principal depois do merge, logo antes de pedir, para que bata com o checkout onde a ação roda. O implementador de um ticket que prepara um gate só edita, commita e roda checagens locais; ele não produz o artefato do gate.
- **Peça uma vez**, com o comando exato (por exemplo `! terraform apply /tmp/x.tfplan`). Continue nos tickets que não dependem do gate; os dependentes esperam a confirmação.
- **Depois da confirmação**, verifique você mesmo o resultado (log, métrica, `curl`). Uma checagem que falha vira um **subagente implementador** de correção, pela regra de correção de **Modelos e esforço**: o ticket de gate conta como ticket envolvido, então o piso de Sonnet com esforço medium continua valendo.
- **Registre.** A confirmação conta como evidência: marque o critério correspondente com `- [x]` e liste-o no relatório final como "confirmado pela pessoa".
- **Sem humano disponível** (headless, executado como subagente, ninguém acompanhando): termine todos os tickets independentes, depois pare bloqueado e reporte cada gate pendente com o comando exato. Nunca contorne um gate.

## Passos

1. Leia a especificação e os tickets para entender o grafo de tarefas.

2. (opcional) Use um **subagente de exploração** (conforme **Modelos e esforço**) para fazer qualquer exploração exigida pelos tickets: arquivos relevantes da base de código ou documentação externa. Garanta que o subagente de exploração consiga salvar arquivos: ele deve gravar as notas em markdown em um diretório fora do repositório, acessível a todos os subagentes futuros. Assim, os **subagentes implementadores** se concentram na implementação, e não na exploração.

3. Crie o branch de integração, a menos que a especificação, os tickets ou as instruções do próprio repositório (`CLAUDE.md`, `AGENTS.md`) digam explicitamente para commitar direto na `main`: então a `main` é o branch de integração e nada é criado. Sem essa instrução explícita, sempre crie o branch. Os implementadores mantêm seus worktrees e branches locais temporários de qualquer forma (a checagem de base do passo 4 continua valendo), e o passo 10 os limpa. Se o issue tracker encerra o trabalho por meio de PRs, ou se o usuário pedir, abra um PR em rascunho depois do primeiro merge do passo 5 (um branch sem commits à frente da main não pode abrir um PR), marcado como fechando a especificação e os tickets.

4. Use um **subagente implementador** novo para cada ticket, cada um em seu próprio worktree e em seu próprio branch, no modelo e esforço de **Modelos e esforço**. Cada subagente implementador:
   - confirma que seu worktree está baseado no branch de integração antes de começar, e faz reset para ele se não estiver;
   - chama a ferramenta Skill com `tdd` para construir o ticket, rodando apenas **testes isolados** (unitários e de lógica pura, nada que toque estado compartilhado). Ele escreve os **testes de estado compartilhado** que o ticket exige (banco de dados, API, e2e, qualquer coisa em porta, arquivo, fila ou serviço externo compartilhado), mas não os executa. Num repositório sem suíte de testes, as checagens que o repositório tem (`validate`, `fmt`, lint, typecheck) contam como os testes isolados, e o implementador as executa;
   - faz merge da ponta do branch de integração no próprio branch antes de reportar que terminou

5. Assim que um **subagente implementador** terminar, faça merge do trabalho dele no branch de integração com um **subagente de merge** (veja **Modelos e esforço**).

6. Se isso alterar a **fronteira** de tickets disponíveis, dispare mais **subagentes implementadores** para trabalhar nos novos tickets. Isso permite máxima concorrência. Um ticket de gate na fronteira é tratado conforme **Gates humanos**, não disparado.

7. Quando todos os tickets estiverem concluídos e mesclados, rode os **testes de estado compartilhado** uma única vez, em série, no branch de integração (sem nenhum outro subagente rodando). Implementadores em paralelo compartilham o mesmo banco, portas e serviços, então esses testes corromperiam os dados uns dos outros se rodassem durante os passos 4 a 6. Corrija todas as falhas em um único **subagente implementador** de correção novo e rode de novo apenas os testes que falharam. Num repositório sem suíte de testes, rode uma vez as checagens disponíveis do repositório no branch de integração e diga no relatório final que não havia suíte de testes. Checagens de estado compartilhado manuais (um `curl` de outro país, um celular no 4G) viram um ticket de gate conforme **Gates humanos**: peça à pessoa, uma vez, a lista exata do que testar, com a condição de sucesso de cada item.

8. Chame a ferramenta Skill com `review-axes` no branch de integração, passando o caminho da especificação como argumento de spec. Passe a ela os critérios que uma pessoa confirmou em um gate (marcados `- [x]` pela confirmação) e diga que não devem ser desmarcados, já que ela sincroniza as caixas a partir do código. Depois que ela retornar, marque de novo qualquer um que ela tenha voltado para `- [ ]` antes do passo 9. Corrija todos os problemas levantados pela revisão em um único **subagente implementador** de correção novo. Se as correções tocarem código coberto por testes de estado compartilhado, rode esses testes de novo, em série, depois.

9. Se existir um PR em rascunho, marque-o como pronto para revisão. Caso contrário, resolva cada ticket da forma como o issue tracker encerra o trabalho e informe o branch de integração, com a tabela de ticket, modelo e esforço de **Modelos e esforço**.
   Em um tracker local em markdown, resolver um ticket significa marcar o arquivo dele no checkout principal (não em um worktree): troque cada critério de aceitação que o branch de integração implementa para `- [x]`, com base no relatório de Spec do passo 8 e no trabalho mesclado do ticket, deixe os não atendidos como `- [ ]` (um critério de gate confirmado pela pessoa fica marcado) e defina `Status: ready-for-human` quando todas as caixas estiverem marcadas. Um ticket com alguma caixa desmarcada mantém o status e é listado no relatório. É isso que o `/archive-feature` verifica antes de arquivar a funcionalidade.

10. Limpe todos os worktrees dos **subagentes implementadores** e seus branches locais temporários.

<!-- aligned-with: sha256:ea86d52be091e1a3561f5dfd5b7eee78b2b48c3e9d132464e7af906de9001d2a -->
