# Roteiro do vídeo auxiliar — Autorização de acesso a dados de saúde pelo celular
## Uma ideia em avaliação: GOV.BR + MeuPEP

> **Status:** roteiro de demonstração, integralmente 💡 *Ideia em
> avaliação*. O vídeo é material **auxiliar** de divulgação para alcançar
> pessoas com baixo letramento em saúde. Não substitui o documento formal
> `docs/proposta-autorizacao-cidadao.md` nem as decisões de `pratica.md`.
> A elaboração pelo agente não representa aprovação da equipe.

---

## 1. Objetivo do vídeo

Mostrar, em linguagem simples e em situações do dia a dia, **como
poderia funcionar** a autorização de acesso aos dados de saúde pelo
celular, usando GOV.BR e MeuPEP como alternativa em avaliação. O vídeo
acompanha o documento `docs/proposta-autorizacao-cidadao.md` e usa as
mesmas cinco situações.

## 2. Público

Sociedade, pacientes, profissionais e estabelecimentos de saúde, com
atenção especial a pessoas com baixo letramento em saúde.

## 3. Diretrizes de produção

- **Duração alvo:** 60 segundos. Limite máximo: 90 segundos.
- **Legendas** em português.
- **Janela de Libras.**
- **Audiodescrição.**
- Linguagem simples, frases curtas, sem jargão.
- Termos técnicos aparecem apenas quando indispensáveis, sempre
  explicados na primeira menção.
- **Tempo verbal condicional:** "poderia", "seria", "estaria". Nunca
  "é", "será", "está".
- Nenhuma cena com dados pessoais ou clínicos reais.
- Nenhuma cena sugere que a funcionalidade já existe.

⏳ *Depende de decisão:* custos e responsáveis por legendagem, Libras e
audiodescrição precisam ser confirmados com a coordenação.

## 4. Cartelas obrigatórias (início e fim)

- **Cartela de abertura (0:00–0:04):** texto na tela —
  > "Ideia em avaliação. Nada aqui está aprovado ou funcionando."
- **Cartela de encerramento (últimos 4 s):** texto na tela —
  > "Proposta em avaliação. As decisões oficiais estão nos documentos
  > do projeto."

Essas cartelas são ✅ *Já definido* como exigência de transparência da
issue.

## 5. Roteiro cena a cena

O vídeo percorre **as cinco situações** do documento formal, em ritmo
rápido e visual. Cada situação tem uma cena curta.

---

### Cena 1 — Abertura (0:00–0:06)

- **Visual:** cartela de abertura sobre fundo neutro. Abaixo, ícones
  do GOV.BR e do MeuPEP lado a lado, com a etiqueta "em avaliação".
- **Narração:** "Esta é uma ideia em avaliação para autorizar o acesso
  aos seus dados de saúde pelo celular."
- **Classificação:** ✅ *Já definido* (exigência de transparência).

---

### Cena 2 — Situação 1: "Cheguei ao hospital" (0:06–0:20)

- **Visual:** recepção de um estabelecimento de saúde. Um QRCode aparece
  na tela do balcão. A pessoa aponta o celular. A tela do MeuPEP mostra
  o pedido: *quais dados, para quê, por quanto tempo*. Três botões:
  "Autorizar", "Alterar", "Recusar".
- **Narração:** "No hospital, em vez de assinar um papel, a pessoa
  poderia ler um QRCode com o aplicativo. Veria o que está sendo pedido
  e escolheria autorizar, mudar ou recusar."
- **Sobreposição de texto:** "Situação 1 — Autorizar pelo celular".
- **Classificação:** 💡 *Ideia em avaliação* (QRCode, MeuPEP, escopo,
  prazo, decisão do paciente). ✅ *Já definido:* a plataforma usa Java e
  Spring Boot.

---

### Cena 3 — Situação 2: "Quem acessou meus dados?" (0:20–0:32)

- **Visual:** tela do MeuPEP com uma lista simples: "Quem acessou",
  "Quando", "Para quê". A pessoa desliza o dedo pela lista.
- **Narração:** "Depois, a pessoa poderia ver no aplicativo quem acessou
  seus dados, quando e para quê."
- **Sobreposição de texto:** "Situação 2 — Acompanhar acessos".
- **Classificação:** 💡 *Ideia em avaliação* (tela do MeuPEP). ✅ *Já
  definido:* a fonte dos registros é o `AuditEvent`. ⏳ *Depende de
  decisão:* formato de exibição, granularidade e retenção.

---

### Cena 4 — Situação 3: "Mudei de ideia" (0:32–0:42)

- **Visual:** a pessoa toca em uma autorização ativa. Aparece o botão
  "Revogar". Ela toca. A tela muda para "Autorização revogada".
- **Narração:** "A qualquer momento, a pessoa poderia revogar ou mudar
  o que autorizou, direto pelo celular."
- **Sobreposição de texto:** "Situação 3 — Revogar pelo celular".
- **Classificação:** 💡 *Ideia em avaliação* (revogação pelo paciente).
  ✅ *Já definido:* a trilha de auditoria é preservada mesmo após a
  revogação.

---

### Cena 5 — Situação 4: "Não respondi" (0:42–0:52)

- **Visual:** tela do MeuPEP mostrando um pedido com um relógio
  contando. Ao fim do tempo, a tela muda para "Acesso não liberado".
- **Narração:** "Se a pessoa não respondesse dentro do prazo, o acesso
  não seria liberado. Silêncio não vira autorização."
- **Sobreposição de texto:** "Situação 4 — Sem resposta, sem acesso".
- **Classificação:** 💡 *Ideia em avaliação* (prazo, silêncio como não
  autorização). ✅ *Já definido:* o projeto não converte falhas em
  sucesso. ⏳ *Depende de decisão:* prazo e canal de notificação.

---

### Cena 6 — Situação 5: "Faltou luz ou internet" (0:52–1:02)

- **Visual:** sala de atendimento com luz apagada. Profissional anota em
  papel. A luz volta. A tela mostra o registro sendo sincronizado com o
  sistema, com a etiqueta "reconciliação".
- **Narração:** "Se faltasse luz ou internet, um registro temporário em
  papel poderia ser usado, com sincronização depois. O detalhe desse
  fluxo ainda depende de decisão da equipe."
- **Sobreposição de texto:** "Situação 5 — Contingência".
- **Classificação:** 💡 *Ideia em avaliação* (contingência offline). ⏳
  *Depende de decisão:* mecanismo, alçada, limites e reconciliação.

---

### Cena 7 — Encerramento (1:02–1:10)

- **Visual:** cartela de encerramento sobre fundo neutro. Abaixo, a
  indicação: "Documento completo: docs/proposta-autorizacao-cidadao.md".
- **Narração:** "Esta é uma ideia em avaliação. As decisões oficiais
  estão nos documentos do projeto."
- **Classificação:** ✅ *Já definido* (exigência de transparência).

---

## 6. O que o vídeo NÃO pode fazer

- 🚫 Mostrar dados reais de pacientes.
- 🚫 Usar contas, credenciais ou ambientes oficiais de GOV.BR, RNDS,
  SISCAN ou MeuPEP.
- 🚫 Sugerir que o fluxo já está implementado.
- 🚫 Definir contratos de API, modelos de dados ou regras jurídicas.
- 🚫 Apresentar a alternativa como requisito aprovado.
- 🚫 Substituir o documento formal.
- 🚫 Usar tempo verbal no presente ou futuro do indicativo para
  descrever funcionalidades.
- 🚫 Dramatizar a dificuldade do papel em tom negativo.

## 7. Tabela de correspondência com o documento formal

| Cena do vídeo | Situação no documento formal | Classificação predominante |
| --- | --- | --- |
| 1 — Abertura | Aviso de status | ✅ |
| 2 — Autorizar pelo celular | Situação 1 | 💡 |
| 3 — Acompanhar acessos | Situação 2 | 💡 + ✅ |
| 4 — Revogar pelo celular | Situação 3 | 💡 + ✅ |
| 5 — Sem resposta, sem acesso | Situação 4 | 💡 + ✅ |
| 6 — Contingência | Situação 5 | 💡 + ⏳ |
| 7 — Encerramento | Aviso de status | ✅ |

## 8. Verificações pendentes antes da produção

- ⏳ Confirmar com o responsável pelo repositório se a produção do
  vídeo faz parte do escopo desta issue.
- ⏳ Confirmar responsáveis por roteiro, locução, animação, legendagem,
  Libras e audiodescrição.
- ⏳ Confirmar custos e fonte de recursos.
- ⏳ Confirmar se o vídeo será publicado em canal oficial ou apenas
  anexado ao repositório.
