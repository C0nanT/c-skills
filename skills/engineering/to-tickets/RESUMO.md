# Resumo: to-tickets

**O que faz:** divide um plano, uma especificação ou a conversa atual em tickets de tracer bullet: fatias verticais completas, cada uma com suas arestas de bloqueio. Classifica cada ticket em Heavy, Standard ou Light, com um modelo sugerido, mostra o detalhamento e o publica sem pedir confirmação. Em markdown local, cria um arquivo por ticket em `.scratch/<feature-slug>/tickets/`, numerado na ordem de dependência. Em um tracker real, cria uma issue por ticket com bloqueios nativos. Ações que só uma pessoa pode fazer (um `apply`, um deploy, um teste manual) viram um ticket de gate próprio, com a linha `Gate` abaixo de `Difficulty`, que bloqueia os dependentes. Refatorações amplas são sequenciadas como expandir e depois contrair (expand-contract).

**Quando usar:** depois de uma especificação ou de uma conversa amadurecida, quando você quer quebrar o trabalho em pedaços que possam ser construídos um a um.

**Como invocar:** `/to-tickets`. É uma skill só para o usuário (`disable-model-invocation: true`).

**Arquivos:** `SKILL.md` (original em inglês), `TRADUCAO.pt-BR.md` (tradução) e este `RESUMO.md`.

<!-- aligned-with: sha256:c7cedf497938cd2f912625550c2e04c9204fb76e01b2f169cf8e36d6c32a9a59 -->
