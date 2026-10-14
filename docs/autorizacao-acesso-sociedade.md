# Autorização de acesso aos dados de saúde com GOV.BR e MeuPEP: uma proposta em avaliação

> **Status:** proposta documental preliminar, **em avaliação**.
> Não é requisito aprovado, decisão arquitetural definitiva nem solução implementada
> ([pratica.md](../pratica.md), seções 25 e 27). Este documento foi elaborado por agente
> e **não representa aprovação da equipe**. Usa apenas simuladores e dados sintéticos;
> não autoriza integração com contas ou ambientes reais.

## 1. Como ler este documento

Cada ponto recebe uma etiqueta:

| Etiqueta | Significado |
|---|---|
| **[Confirmado]** | Respaldado por decisão, documento normativo ou orientação técnica existente |
| **[Hipótese]** | Alternativa ou comportamento considerado para fins de demonstração |
| **[Pendente]** | Depende de decisão conjunta da equipe |
| **[Fora do escopo]** | Não é definido nem implementado nesta proposta |

Quando as fontes divergem, a divergência aparece como **[Pendente]**. Nada foi preenchido por inferência.

## 2. Por que este documento existe

Hoje a autorização de acesso a dados de saúde costuma ocorrer em papel. Este documento explica,
em linguagem acessível, como um modelo digital **poderia** funcionar e o que ele poderia oferecer
em agilidade, rastreabilidade e segurança.

- **[Confirmado]** O fluxo GOV.BR / Expresso Goiás / MeuPEP é uma alternativa de design em avaliação, ainda não aprovada (`pratica.md`, 27.1).
- **[Confirmado]** Dados exclusivamente sintéticos e sistemas externos simulados (`pratica.md`, 27.1).
- **[Pendente]** Padronizar o nome usado para o aplicativo (Expresso Goiás, MeuPEP, Plataforma Goiás). As fontes variam. Este documento usa **MeuPEP** e **Plataforma Goiás** conforme a issue e explica a relação aqui uma vez: *[a confirmar pela equipe]*.

## 3. Quem faz o quê

| Participante | Papel na proposta | Status |
|---|---|---|
| Paciente | Autentica-se, analisa e responde a pedidos de acesso | [Hipótese] |
| Profissional de saúde | Pede acesso aos dados no sistema do estabelecimento | [Hipótese] |
| Aplicação clínica (estabelecimento) | Envia o pedido; não fala diretamente com o GOV.BR | [Hipótese] |
| MeuPEP / Plataforma Goiás | Recebe o pedido, registra e emite a autorização | [Hipótese] |
| GOV.BR | Apenas **autentica** o paciente; não emite a autorização clínica | [Hipótese], fundamentada em `Pesquisa-aprofundada-sobre-o-uso-do-gov.br.md` |
| DPO | Audita acessos e trata denúncias | [Hipótese] |

Pontos a explicar ao leitor:

- O GOV.BR responde "quem é esta pessoa?"; a Plataforma responde "este estabelecimento pode acessar estes dados?". **[Hipótese]**
- O token do GOV.BR não é entregue à aplicação clínica. **[Hipótese]**
- **[Pendente]** Não há evidência, na pesquisa aprofundada, de que o GOV.BR ofereça hoje infraestrutura genérica para registrar autorizações clínicas estaduais.

## 4. Como o paciente autentica e autoriza pelo celular

### 4.1 Autenticação

1. O paciente abre o MeuPEP e entra com a conta GOV.BR. **[Hipótese]** (diagrama de sequência)
2. Nível da conta: prata ou ouro. **[Pendente]** Aparece só em `autorizacao-acesso-govbr-respostas.md`, sem confirmação.

### 4.2 Duas alternativas para iniciar o acesso

As fontes descrevem dois fluxos distintos. Ambos são apresentados como alternativas.

**Alternativa A: solicitação pelo estabelecimento (CPF)** (diagrama e `autorizacao-acesso.md`) **[Hipótese]**

1. O profissional informa o CPF do paciente na aplicação clínica.
2. A aplicação envia a solicitação ao MeuPEP (estabelecimento, profissional, finalidade, duração desejada).
3. O MeuPEP registra data e hora e mostra a solicitação ao paciente.
4. O paciente lê e escolhe **Autorizar** ou **Não autorizar**.
5. Ao autorizar, o celular pede biometria ou desbloqueio.
6. O MeuPEP registra a autorização e informa a aplicação clínica.

**Alternativa B: QRCode gerado pelo paciente** (`autorizacao-acesso-govbr-respostas.md`, seção 1) **[Hipótese]**

1. O paciente gera um QRCode no MeuPEP.
2. O estabelecimento lê o código e acessa os dados autorizados.

**[Pendente]** Escolher A, B ou ambas. A issue cita QRCode; o diagrama oficial atual descreve A.

### 4.3 Verificação adicional no celular

- Biometria ou desbloqueio do aparelho antes de confirmar. **[Hipótese]** (diagrama)
- **[Pendente]** Relação com a assinatura eletrônica avançada do GOV.BR (seção 9): complementares ou alternativas?

> *Espaço reservado para versão simplificada do diagrama de sequência.*

## 5. Período de validade e escopo

| Ponto | Alternativa A (diagrama) | Alternativa B (respostas) | Status |
|---|---|---|---|
| Quem define a duração | Profissional propõe; paciente aceita ou recusa | Paciente define, com opção de prazo indeterminado | [Pendente] |
| Quem define os dados compartilhados | Não detalhado | Paciente seleciona quais dados | [Pendente] |
| Abrangência | Estabelecimento solicitante | Todo o estabelecimento, não só o profissional | [Hipótese] parcial; [Pendente] se vale para o profissional específico |
| Finalidade exibida ao paciente | Enviada na solicitação | Não listada em `autorizacao-acesso.md` | [Pendente] |

- Uso do recurso FHIR `Consent` para registrar a autorização, "quando aplicável". **[Hipótese]**
- Contratos de API e modelos de dados. **[Fora do escopo]**

## 6. Revogar ou alterar uma autorização

- O paciente poderia revogar ou editar a autorização no MeuPEP, a qualquer momento. **[Hipótese]** (respostas, seção 1)
- **[Pendente]** Se editar faz parte da alternativa em avaliação e quais campos podem ser alterados.
- **[Pendente]** Efeito da revogação sobre acessos em andamento.

## 7. Acompanhar quem acessou os dados

- O paciente veria, no MeuPEP, o histórico: quem acessou, quando e para qual finalidade. **[Hipótese]**
- **[Pendente]** Nível de detalhe exibido, respeitando as definições existentes e a minimização de dados.
- **[Pendente]** Tempo de retenção do histórico.

## 8. Recusa ou ausência de resposta

- Se o paciente recusar ou não responder no prazo, a aplicação clínica recebe "não autorizado". **[Hipótese]** (respostas, seção 1)
- **[Pendente]** Prazo de validade de uma solicitação. Não está definido em nenhuma fonte.
- **[Pendente]** O ramo "Paciente não autoriza" do diagrama está vazio e precisa ser completado.

## 9. Segurança, autoria, autenticidade e rastreabilidade

| Mecanismo | Descrição | Status |
|---|---|---|
| Autenticação forte do paciente | Conta GOV.BR | [Hipótese] |
| Confirmação local | Biometria/desbloqueio do celular | [Hipótese] |
| Assinatura eletrônica avançada GOV.BR | Prova de que o paciente autorizou (Lei 14.063/2020, citada nas respostas) | [Pendente]: viabilidade técnica não confirmada pela pesquisa aprofundada |
| Certificado digital do estabelecimento | Canal entre aplicação clínica e MeuPEP | [Hipótese] |
| Prazo e escopo no registro de autorização | Expiração automática | [Hipótese] |
| Registro de acessos | Histórico para paciente e auditoria | [Hipótese] |
| Autorização profissional | Verificar vínculo e papel do profissional, distinto da autorização do paciente | [Hipótese] (pesquisa aprofundada) |
| `AuditEvent` isolado não garante não repúdio | Exigiria identidade forte, assinatura, carimbo de tempo confiável e armazenamento resistente a alteração | [Confirmado] em `pratica.md`, 14.10 |

## 10. Expiração automática

- O acesso expiraria sozinho ao fim do período autorizado. **[Hipótese]**
- **[Pendente]** Comportamento para prazo indeterminado (seção 5) e eventual revisão periódica.

## 11. Papel e digital: comparação

| Aspecto | Papel | Digital (proposta) | Status |
|---|---|---|---|
| Rapidez | Depende de preenchimento manual | Autoriza em segundos pelo celular | [Hipótese] |
| Rastreabilidade | Limitada | Histórico de acessos no MeuPEP | [Hipótese] |
| Revogação | Difícil | Pelo celular, a qualquer momento | [Hipótese] |
| Histórico ao profissional | Depende do que o paciente traz | Acesso conforme autorização | [Hipótese] |
| Dependência de energia/internet | Baixa | Alta; exige contingência (seção 12) | [Hipótese] |
| Inclusão digital e acesso a celular/conta GOV.BR | Não exige | Pode excluir quem não tem acesso | [Pendente]: não tratado nas fontes; registrar como limitação |

## 12. Contingência: sem energia ou conectividade

Fluxo sugerido nas respostas, seção 6 **[Hipótese]**:

1. Conferir identidade por documento oficial com foto.
2. Paciente assina termo em papel (estabelecimento, profissional, finalidade, prazo), de um kit de contingência.
3. Atendimento registrado em papel.
4. Com a energia de volta, o termo e o atendimento são lançados no sistema.
5. O MeuPEP envia a autorização lançada ao paciente para confirmação; se ele não reconhecer, o caso vai ao DPO.

- Em emergência, aplica-se acesso emergencial com justificativa registrada e lançada depois. **[Hipótese]**
- Todo termo e impressão entram na auditoria. **[Hipótese]**
- **[Pendente]** Responsável pelo kit, validade jurídica do termo e prazo para lançamento posterior.

## 13. DPO e auditoria

- O DPO audita acessos, recebe denúncias pelo MeuPEP e pode suspender acessos indevidos e abrir incidentes. **[Hipótese]**
- **[Pendente]** Modelo em emergência: notificação imediata com revisão posterior ou aprovação prévia (exigiria plantão 24/7). As respostas apresentam os dois.
- **[Hipótese]** Acesso emergencial sem consentimento, com base na LGPD art. 11, II (citada nas respostas). A base legal exige validação jurídica; este documento não cria requisito jurídico. **[Pendente]**
- Perfil próprio do DPO, painel de auditoria sem conteúdo clínico e justificativa para abrir conteúdo clínico. **[Hipótese]** (respostas, seção 8)
- Dados disponíveis para investigação: trilha de auditoria, telemetria minimizada, proveniência e controles de retenção (`dados_para_investiga_o_do_dpo.md`). **[Confirmado]** como orientação técnica existente.

## 14. Privacidade e minimização

*(O texto da issue está cortado neste ponto; conferir o trecho final antes de fechar a seção.)*

- Nenhum dado pessoal real é usado. **[Confirmado]**
- Logs, métricas e rastros não registram identificadores pessoais reais nem conteúdo clínico (`pratica.md`, README; `observabilidade.md`). **[Confirmado]**
- O paciente vê o que será compartilhado antes de autorizar. **[Hipótese]**
- A Plataforma, e não o GOV.BR, guarda a informação sobre o que foi autorizado, evitando enviar dados de saúde ao GOV.BR. **[Hipótese]**
- **[Pendente]** Dados mínimos exibidos ao paciente e ao DPO.

## 15. Quadro de pendências

| # | Pendência | Seção |
|---|---|---|
| 1 | Alternativa A, B ou ambas | 4 |
| 2 | Quem define duração e escopo | 5 |
| 3 | Finalidade exibida ao paciente | 5 |
| 4 | Edição de autorização e efeito da revogação | 6 |
| 5 | Prazo de resposta e fluxo de recusa no diagrama | 8 |
| 6 | Assinatura eletrônica avançada × biometria local | 4, 9 |
| 7 | Nível prata/ouro | 4 |
| 8 | Nomenclatura (Expresso Goiás / MeuPEP / Plataforma Goiás) | 2 |
| 9 | Modelo do DPO em emergência e base legal | 13 |
| 10 | Contingência: kit, validade do termo, prazo | 12 |
| 11 | Inclusão digital como limitação | 11 |
| 12 | Retenção do histórico de acessos | 7 |

## 16. Fora do escopo

- Integração real com GOV.BR, contas ou ambientes reais.
- Definição de contratos de API ou modelos de dados.
- Alteração do escopo da plataforma e substituição dos documentos técnicos de autorização.
- Implementação completa de consentimento dinâmico (`pratica.md`, seção 25).
- Criação de requisitos jurídicos, regulatórios, de segurança ou arquitetura sem respaldo nos documentos de referência.

## 17. Fontes

- `pratica.md` (seções 14.10, 25 e 27)
- `docs/autorizacao-acesso.md`
- `docs/Diagrama-de-sequencia-autorizacao-acesso.md`
- `docs/autorizacao-acesso-govbr-respostas.md`
- `docs/Pesquisa-aprofundada-sobre-o-uso-do-gov.br.md`
- `docs/analise_login_unico_govbr.md`
- `docs/dados_para_investiga_o_do_dpo (1).md`
- `docs/observabilidade.md`
