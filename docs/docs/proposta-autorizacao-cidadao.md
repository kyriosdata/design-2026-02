# Como poderia funcionar a autorização de acesso aos seus dados de saúde pelo celular
## Uma ideia em avaliação: GOV.BR + MeuPEP

> **Aviso rápido**
>
> Este documento mostra uma **ideia em avaliação**. Nada aqui está
> aprovado, contratado ou funcionando. É uma proposta para discutir com
> a sociedade como o modelo digital *poderia* funcionar.
>
> As decisões oficiais do projeto estão em `pratica.md`. O detalhamento
> técnico de autorização está em `docs/autorizacao-acesso.md`.
>
> As marcas ao longo do texto indicam o status de cada afirmação:
>
> - ✅ **Já definido** — respaldado por decisão do projeto.
> - 💡 **Ideia em avaliação** — alternativa sendo considerada.
> - ⏳ **Depende de decisão** — ainda não foi definido pela equipe.
> - 🚫 **Fora do alcance deste documento** — não é tratado aqui.

---

## 1. O que este documento quer mostrar

Hoje, quando alguém precisa autorizar que um profissional ou
estabelecimento acesse seus dados de saúde, o caminho mais comum é o
papel: assinatura, formulário, arquivo. Funciona, mas tem limites
conhecidos: difícil de revogar, difícil de acompanhar, difícil de
auditar.

Este documento mostra, em situações do dia a dia, **como uma alternativa
digital poderia funcionar** — usando a conta GOV.BR e o aplicativo
MeuPEP. A ideia é que a pessoa possa autorizar, acompanhar, mudar e
revogar o acesso pelo próprio celular, com mais controle e mais
rastreabilidade do que no papel.

**Importante:** tudo o que está descrito aqui é uma **possibilidade em
avaliação**. Nada foi aprovado. O objetivo é justamente ouvir a
sociedade, os profissionais e os estabelecimentos antes de qualquer
decisão.

---

## 2. Cinco situações para entender como poderia funcionar

### Situação 1 — "Cheguei ao hospital e preciso autorizar o acesso aos meus dados"

**O que aconteceria hoje, no papel:**
A recepção entrega um formulário. A pessoa assina autorizando o acesso
aos dados. O papel vai para um arquivo. Não há registro fácil de quando
expira, para que serviu nem como revogar depois. 💡 *Ideia em avaliação*

**Como poderia funcionar no modelo digital:**

1. A recepção do estabelecimento gera um pedido de acesso no sistema
   deles. 💡 *Ideia em avaliação*
2. Aparece um **QRCode** na tela. 💡 *Ideia em avaliação*
3. A pessoa abre o **MeuPEP** no celular e aponta a câmera para o
   QRCode. 💡 *Ideia em avaliação*
4. O aplicativo pede que a pessoa se autentique com a **conta GOV.BR
   nível prata ou ouro**. ✅ *Já definido:* a plataforma usa Java e
   Spring Boot; a decisão de adotar GOV.BR como identidade ainda está em
   avaliação. 💡 *Ideia em avaliação*
5. Na tela, aparece **exatamente o que está sendo pedido**: quais dados,
   para qual finalidade e por quanto tempo. 💡 *Ideia em avaliação*
6. A pessoa escolhe: **autorizar**, **mudar o que libera** ou
   **recusar**. 💡 *Ideia em avaliação*
7. Se autorizar, o acesso é liberado para o estabelecimento pelo tempo
   definido. 💡 *Ideia em avaliação*

**O que muda em relação ao papel:** a pessoa vê o pedido antes de
autorizar, escolhe o escopo e o prazo, e o registro fica digital. ✅ *Já
definido:* a rastreabilidade usa `Provenance` e `AuditEvent`.

---

### Situação 2 — "Quero saber quem acessou meus dados e para quê"

**O que aconteceria hoje, no papel:**
Não há caminho simples. A pessoa precisaria pedir formalmente ao
estabelecimento, que precisaria procurar no arquivo. 💡 *Ideia em
avaliação*

**Como poderia funcionar no modelo digital:**

1. A pessoa abre o **MeuPEP**. 💡 *Ideia em avaliação*
2. Encontra uma lista com **quem acessou**, **quando** e **para qual
   finalidade**. 💡 *Ideia em avaliação*
3. Pode ver também quais autorizações estão ativas e quais já
   expiraram. 💡 *Ideia em avaliação*

**O que muda em relação ao papel:** o histórico fica disponível a
qualquer momento, sem pedido formal. ✅ *Já definido:* a fonte desses
registros é o `AuditEvent`, mecanismo de auditoria adotado pelo projeto.
⏳ *Depende de decisão:* formato de exibição, granularidade e tempo de
retenção.

---

### Situação 3 — "Mudei de ideia e quero revogar a autorização"

**O que aconteceria hoje, no papel:**
A pessoa precisaria voltar ao estabelecimento, pedir o cancelamento,
torcer para que o papel seja localizado e para que o acesso pare de
acontecer. 💡 *Ideia em avaliação*

**Como poderia funcionar no modelo digital:**

1. A pessoa abre o **MeuPEP**. 💡 *Ideia em avaliação*
2. Encontra a autorização ativa. 💡 *Ideia em avaliação*
3. Toca em **revogar**. 💡 *Ideia em avaliação*
4. O acesso deixa de valer para novos acessos. 💡 *Ideia em avaliação*

**O que muda em relação ao papel:** revogação imediata, pelo celular,
sem deslocamento. ⏳ *Depende de decisão:* o que acontece com acessos já
em andamento e com cópias já entregues. ✅ *Já definido:* a trilha de
auditoria (`Provenance` e `AuditEvent`) é preservada mesmo após a
revogação — não se apaga histórico.

---

### Situação 4 — "Não respondi ao pedido. O que acontece?"

**O que aconteceria hoje, no papel:**
Depende do estabelecimento. Em alguns casos, o silêncio é tratado como
autorização tácita. Em outros, o atendimento fica parado. 💡 *Ideia em
avaliação*

**Como poderia funcionar no modelo digital:**

- Se a pessoa **não responder** dentro do prazo, o acesso **não é
  liberado**. 💡 *Ideia em avaliação*
- Se a pessoa **recusar**, a recusa fica registrada com a mesma
  rastreabilidade da autorização. 💡 *Ideia em avaliação*

**O que muda em relação ao papel:** o silêncio nunca vira autorização.
✅ *Já definido:* o projeto não converte falhas em sucesso nem ausência
de informação em ausência de condição clínica. ⏳ *Depende de decisão:*
qual é o prazo, como a pessoa é notificada e como a recusa é registrada.

---

### Situação 5 — "Faltou luz ou internet no atendimento"

**O que aconteceria hoje, no papel:**
O atendimento continua no papel e, depois, alguém digita no sistema.
Pode haver perda de informação e dificuldade de reconciliação. 💡 *Ideia
em avaliação*

**Como poderia funcionar no modelo digital:**

- Em situações de **ausência de energia ou conectividade**, um registro
  temporário em papel poderia ser usado, com **sincronização posterior**
  quando a conexão voltar. 💡 *Ideia em avaliação*
- O registro temporário seria reconciliado com a trilha de auditoria
  (`Provenance` e `AuditEvent`) assim que possível. 💡 *Ideia em
  avaliação*

**O que muda em relação ao papel:** o registro temporário não substitui
o fluxo normal; ele é uma contingência com reconciliação. ⏳ *Depende de
decisão:* qual mecanismo, quem pode acionar, limites de validade e como
reconciliar.

---

## 3. Como o modelo digital se compara ao papel

| O que a pessoa sente | No papel | No modelo digital (ideia em avaliação) |
| --- | --- | --- |
| Ver o que está sendo pedido | Depende do formulário | Aparece na tela antes de autorizar 💡 |
| Escolher o prazo | Difícil | A pessoa define no aplicativo 💡 |
| Revogar depois | Precisa voltar ao local | Pelo celular, na hora 💡 |
| Saber quem acessou | Pedido formal | Lista no aplicativo 💡 |
| Perder o papel | Risco real | Registro digital ✅ |
| Auditar depois | Custoso | Trilha de auditoria ✅ |

✅ *Já definido:* a plataforma adota FHIR R4 `4.0.1` e HAPI FHIR como
servidor e validador. 💡 *Ideia em avaliação:* o uso do recurso FHIR
`Consent` para registrar a autorização.

---

## 4. Segurança, autoria e rastreabilidade — em linguagem simples

- **Quem autorizou:** a autenticação com GOV.BR prata ou ouro ajudaria
  a garantir que é a própria pessoa. 💡 *Ideia em avaliação*
- **Como se prova que foi a pessoa:** a assinatura eletrônica avançada
  do GOV.BR poderia ser usada. 💡 *Ideia em avaliação*
- **Como se prova que foi o estabelecimento:** o certificado digital do
  estabelecimento poderia ser usado. 💡 *Ideia em avaliação*
- **Como se sabe o que aconteceu:** `Provenance` e `AuditEvent` registram
  origem, autoria e acessos. ✅ *Já definido*
- **Quem pode auditar:** o DPO (encarregado pela proteção de dados)
  poderia participar dos processos de auditoria. 💡 *Ideia em avaliação*
  ⏳ *Depende de decisão:* papel operacional, alçada e periodicidade.

🚫 *Fora do alcance deste documento:* criar regras jurídicas ou
regulatórias novas, definir contratos de API ou modelos de dados.

---

## 5. Privacidade e minimização

- A pessoa autoriza **só o que precisa** e **só pelo tempo
  necessário**. 💡 *Ideia em avaliação*
- O histórico mostra **o mínimo necessário** para a pessoa entender o
  que aconteceu. 💡 *Ideia em avaliação*
- Dados clínicos, identificadores de pacientes, segredos e tokens **não
  aparecem em logs, métricas ou rastros**. ✅ *Já definido*
- Segurança da informação e segurança clínica são análises
  **distintas**. ✅ *Já definido*

⏳ *Depende de decisão:* base legal, tempo de retenção e regras de
compartilhamento entre estados.

---

## 6. Perguntas que ainda precisam de resposta da equipe

Estas perguntas **não** foram respondidas por inferência. Elas dependem
de decisão conjunta:

1. A alternativa GOV.BR + MeuPEP será adotada? ⏳
2. Qual é o prazo de silêncio e como a recusa é registrada? ⏳
3. Qual é o mecanismo de contingência e quem pode acioná-lo? ⏳
4. Qual é o papel operacional do DPO na auditoria? ⏳
5. Qual é a base legal e o tempo de retenção dos registros? ⏳
6. Como este documento se relaciona com `docs/autorizacao-acesso.md`? ⏳
7. O item final da issue (truncado em "privacidade e minimiza...")
   precisa ser confirmado. ⏳

---

## 7. O que este documento não faz

- 🚫 Não implementa integração real.
- 🚫 Não altera o escopo da plataforma.
- 🚫 Não define contratos de API nem modelos de dados.
- 🚫 Não substitui `pratica.md` nem `docs/autorizacao-acesso.md`.
- 🚫 Não usa dados reais, contas reais, credenciais de produção nem
  ambientes oficiais.

---

## 8. Glossário rápido

- **GOV.BR prata/ouro** — níveis de conta que exigem verificação mais
  forte de identidade.
- **MeuPEP** — aplicativo do paciente no contexto do SUS digital.
- **QRCode** — código quadrado que o celular lê pela câmera.
- **`Consent`** — recurso do padrão FHIR usado para registrar
  consentimentos.
- **`Provenance`** — registro de origem e histórico de um dado.
- **`AuditEvent`** — registro de quem acessou, quando e para quê.
- **DPO** — encarregado pela proteção de dados.
- **TTL** — tempo de vida de um dado antes de expirar.

---

## 9. Material auxiliar

O roteiro do vídeo de divulgação está em
`docs/proposta-autorizacao-cidadao-video.md`. O vídeo é material
**auxiliar** para alcançar pessoas com baixo letramento em saúde. Ele
não substitui este documento nem as decisões formais do projeto.

---

## 10. Nota para a equipe

Este documento foi elaborado pelo agente a partir da issue e das
orientações do repositório. **A elaboração pelo agente não representa
aprovação da equipe.** Antes de qualquer merge:

- Confirmar caminho e nome do arquivo.
- Confirmar relação com `docs/autorizacao-acesso.md`.
- Confirmar o texto completo do item truncado da issue.
- Revisar as marcações ✅/💡/⏳/🚫 item a item.
- Registrar as pendências da seção 6 em `pratica.md`, seção 27.2.
