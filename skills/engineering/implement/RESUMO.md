# Resumo: implement

**O que faz:** implementa um trabalho descrito em especificação ou tickets, em seis passos: construir (com `tdd`, nos seams acordados), testar a suíte, refatorar com cuidado (só se a suíte estiver verde e só no código do diff), revisar com `review-axes` (padrões e aderência à especificação), commitar no branch atual e reportar com um **Veredito** em 🟢, 🟡 ou 🔴. Se um ticket tem um gate humano (uma ação que só uma pessoa faz, como um `terraform apply`), a sessão commita o que construiu, prepara o artefato, pede a ação uma vez com o comando exato, espera, verifica e segue, registrando o critério como "confirmado pela pessoa"; sem humano disponível, para bloqueada com o comando pendente (🔴). Todo subagente roda em esforço `medium`, a menos que você aprove um nível maior.

**Quando usar:** quando você tem uma especificação ou ticket pronto, ou um plano acordado, e quer que ele seja construído de ponta a ponta.

**Como invocar:** `/implement`, ou o agente pode chamá-la sozinho quando você pedir para implementar um trabalho pronto (sem `disable-model-invocation`).

**Arquivos:** `SKILL.md` (original em inglês), `TRADUCAO.pt-BR.md` (tradução) e este `RESUMO.md`.

<!-- aligned-with: sha256:d3dab1977f6be17973866a8e8dce3379d0830c2f99c9d7b86ca97503d3a45b73 -->
