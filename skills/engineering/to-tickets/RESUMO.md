# Resumo: to-tickets

**O que faz:** divide um plano, uma especificação ou a conversa atual em tickets de tracer bullet: fatias verticais completas, cada uma com suas arestas de bloqueio. Classifica cada ticket em Heavy, Standard ou Light, com um modelo sugerido, mostra o detalhamento e o publica sem pedir confirmação. Em markdown local, cria um arquivo por ticket em `.scratch/<feature-slug>/tickets/`, numerado na ordem de dependência. Em um tracker real, cria uma issue por ticket com bloqueios nativos. Refatorações amplas são sequenciadas como expandir e depois contrair (expand-contract).

**Quando usar:** depois de uma especificação ou de uma conversa amadurecida, quando você quer quebrar o trabalho em pedaços que possam ser construídos um a um.

**Como invocar:** `/to-tickets`. É uma skill só para o usuário (`disable-model-invocation: true`).

**Arquivos:** `SKILL.md` (original em inglês), `TRADUCAO.pt-BR.md` (tradução) e este `RESUMO.md`.

<!-- aligned-with: sha256:e87c0eae43d7c4c77df76c7229fd20ed32ffcb9d58836122246e9a6788252f1b -->
