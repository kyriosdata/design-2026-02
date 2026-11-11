
# Parte 1. IPS sob demanda com cache curto

## 1.1 Resumo

**"qual é o IPS do paciente X?"** gerando o documento **no momento do pedido**, sem repositório longitudinal.

O pedido nasce **no celular do paciente**: o paciente gera um **QR code** no MeuPEP, o estabelecimento o lê e, **se estiver cadastrado**, acessa o IPS. Sem QR válido, ou com estabelecimento não cadastrado, nada é lido nem montado. O MeuPEP e o consentimento seguem a [proposta de autorização com GOV.BR](autorizacao-acesso-govbr-respostas.md), que continua sendo alternativa em avaliação e não requisito aprovado (`pratica.md`, seção 25).

- O **QR code** carrega só uma **referência opaca a uma concessão** do paciente (escopo IPS, prazo curto), sem identificador de paciente nem conteúdo clínico.
- Um **Serviço de Síntese** (novo) recebe o pedido, lê os fatos candidatos, aplica uma **política de seleção determinística e versionada** e usa o Montador Efêmero para produzir o IPS validado.
- O `Bundle` final fica em um **cache curto** (minutos ou horas) e depois é eliminado.
- Cada geração grava **evidência sem conteúdo clínico** em um **Arquivo de evidência** (hash, manifesto, fontes, entregas, eliminação).
- O envio a outra UF só acontece **por pedido explícito**, por um **Despachante de Envio** com outbox e idempotência.
- Há duas opções de acesso. Na **opção A**, a clínica e o paciente estão na mesma UF. Na **opção B** (seção 1.2.1), a clínica está em **outra UF**: a plataforma da clínica pede o IPS à plataforma da UF de origem do paciente, pelo contrato federado entre pares, e o PEP nunca fala com a outra UF.

O Montador **não muda**: continua sem selecionar fatos, sem resolver conflitos por conta própria, sem enviar o IPS e sem conservar dados após o TTL de 60 minutos.

## 1.2 Fluxo de um pedido (opção A: clínica e paciente na mesma UF)

**Etapa A. O paciente gera o QR code**

1. O paciente se autentica no **MeuPEP** (GOV.BR) e escolhe gerar o acesso ao seu IPS, com o prazo da concessão.
2. O MeuPEP registra o consentimento (`Consent`), emite uma **concessão** (escopo IPS, prazo curto, uso único proposto) e exibe o **QR code**. O QR contém apenas a referência opaca da concessão e o endereço da plataforma.

**Etapa B. O estabelecimento lê o QR e é verificado**

3. O profissional lê o QR no PEP. O PEP envia ao Gateway a referência da concessão, o manifesto e as decisões de conflito, se houver, autenticado com o certificado do estabelecimento. O PEP **não informa o paciente**: ele é resolvido pela concessão.
4. O Gateway consulta o **cadastro de estabelecimentos**. Se o estabelecimento **não estiver cadastrado ou ativo**, recusa (`403`), registra `AuditEvent` e encerra. Nada é lido do Servidor FHIR.
5. O Gateway valida a concessão no MeuPEP: autenticidade, prazo, escopo IPS, não revogada e ainda não usada. Concessão inválida, expirada, revogada ou já usada resulta em recusa com `AuditEvent`. Se válida, é consumida e devolve ao Gateway a referência do paciente.
6. O Gateway encaminha ao Serviço de Síntese o pedido autorizado, com paciente, estabelecimento e finalidade.

**Etapa C. Geração do IPS**

7. O Serviço de Síntese consulta o cache. Se houver `Bundle` válido para o mesmo paciente, política e pacote, devolve esse documento. O cache **não dispensa** as etapas B: cada acesso exige estabelecimento cadastrado e concessão válida.
8. Sem cache válido, lê os **fatos candidatos** no Servidor FHIR (somente leitura).
9. Aplica a **política de seleção** e monta o manifesto.
10. Abre uma sessão no Montador, submete os fatos e recebe `OperationOutcome` com pendências e conflitos. Conflito sem regra e sem decisão impede a finalização.
11. Chama `$finalize` e recebe o `Bundle` validado, com hash.
12. Grava o `Bundle` no cache (TTL curto) e registra a evidência no Arquivo, com a referência da concessão e o estabelecimento.
13. Devolve o `Bundle` ao Gateway, que o entrega ao PEP.
14. Se o cliente pedir envio a outra UF, o Despachante lê o `Bundle` do cache, entrega pelo Gateway ao Gateway da plataforma par, e grava o recibo no Arquivo. O consentimento do paciente para esse envio é questão em aberto (seção 1.6).

Resultados possíveis para o PEP: `Bundle` (IPS), `OperationOutcome` com pendências, ou recusa (`403`) por estabelecimento não cadastrado ou concessão inválida. A resposta de recusa não revela qual das duas causas ocorreu além do necessário para o atendimento (a definir).

### 1.2.1 Opção B: a clínica está em outra UF

Termos: **UF de origem** é a UF onde estão os dados do paciente e onde a concessão é emitida. **UF visitada** é a UF da clínica que atende o paciente. Quem decide que é a opção B é a plataforma da UF visitada, pelo QR.

**Etapa A. O paciente gera o QR na UF de origem**

1. O paciente se autentica no MeuPEP e pede o QR do IPS. O pedido vai à plataforma da **UF de origem**, que registra o `Consent` e emite a concessão (escopo IPS, prazo curto, uso único proposto).
2. O QR contém a referência opaca da concessão e o identificador da **UF emissora**. Continua sem identificador de paciente e sem conteúdo clínico.

**Etapa B. A clínica lê o QR e a UF visitada reconhece que é de outra UF**

3. O profissional lê o QR no PEP. O PEP envia ao Gateway da **sua própria plataforma** (UF visitada) a referência da concessão, o manifesto e as decisões de conflito, autenticado com o certificado do estabelecimento. O PEP não conhece nem chama a UF de origem.
4. O Gateway da UF visitada verifica o estabelecimento no **seu cadastro**. Não cadastrado: `403`, `AuditEvent` e fim.
5. O Gateway lê a UF emissora do QR e identifica que é outra UF. Ele **não valida a concessão localmente**, porque ela pertence à UF de origem.
6. O Gateway da UF visitada encaminha o pedido ao Gateway da UF de origem, pelo contrato federado entre pares, com a referência da concessão, o estabelecimento solicitante, a finalidade, o manifesto, as decisões e uma chave de idempotência.

**Etapa C. A UF de origem autoriza e gera o IPS**

7. O Gateway da UF de origem autentica a plataforma par e confere que ela está habilitada no contrato federado.
8. Valida e consome a concessão no MeuPEP da UF de origem (autenticidade, prazo, escopo, não revogada, não usada). Se válida, obtém a referência do paciente.
9. A UF de origem executa o fluxo da opção A a partir do passo 7 (cache, fatos, política de seleção, Montador, `$finalize`) e registra a evidência no seu Arquivo, com o estabelecimento solicitante e a UF visitada. A política de seleção e a autoria clínica são as da UF de origem.
10. A UF de origem devolve o `Bundle` ao Gateway da UF visitada na mesma chamada federada.
11. O Gateway da UF visitada entrega o `Bundle` ao PEP. Ele **não grava o `Bundle`** em cache nem em Arquivo; registra só a evidência de recebimento (hash, UF de origem, estabelecimento, instante), sem conteúdo clínico.

Resultados possíveis para o PEP: `Bundle`, `OperationOutcome` com pendências, `403` por estabelecimento não cadastrado, concessão inválida ou par não habilitado, ou erro explícito se a UF de origem estiver indisponível ou não responder no prazo. A indisponibilidade nunca é apresentada como "paciente sem IPS".

A opção B é um **pedido** da UF visitada à UF de origem (a UF visitada puxa o IPS). Isso é diferente do Despachante de Envio, em que a plataforma que já tem o `Bundle` o envia a pedido do cliente. Em ambos, a troca é direta entre pares e a RNDS não é intermediária.

## 1.3 O que é guardado e por quanto tempo

Todos os prazos são hipóteses a validar com o encarregado de dados.

| Dado | Onde | Conteúdo clínico | Prazo proposto |
| --- | --- | --- | --- |
| Sessão de montagem | Repositório Transacional Efêmero | Sim | 60 minutos (proposta, seção 14.7), sem backup |
| `Bundle` final | Cache curto de IPS (cifrado) | Sim | Minutos ou horas, a definir |
| Manifesto de seleção | Arquivo de evidência | Só referências | Igual ao da evidência |
| Evidência | Arquivo de evidência | Não | Alinhado ao Repositório de Auditoria (a definir) |
| Concessão do paciente (QR) | MeuPEP, com `Consent` | Não | Prazo escolhido pelo paciente; uso único proposto (a definir) |
| Cadastro de estabelecimentos | Fonte a definir (CNES simulado ou cadastro próprio) | Não | Atualização por quem mantém o cadastro |

Campos da evidência, sem conteúdo clínico:

- `ips_id` e hash SHA-256 do `Bundle` (bytes entregues);
- identificador pseudonimizado do paciente;
- versão do pacote `br.gov.saude.ips.fhir#1.0.0` e do validador;
- instante de geração, organização responsável, autor e atestador declarados;
- versão da política de seleção e hash do manifesto;
- fontes: id do RAC, versão, identificador RNDS e hash;
- resultado da validação de assinatura (`valid`, `invalid` ou `indeterminate`), quando exigida;
- referência da concessão (nunca o conteúdo do QR nem o token) e identificação do estabelecimento que leu o QR;
- entregas: destino, chave de idempotência, tentativas, estado, instante e recibo do destinatário;
- registro da eliminação do `Bundle`.

## 1.4 Como é disponibilizado (contrato proposto)

Estas URLs são um contrato próprio do projeto, sugerido por mim, não operações oficiais do FHIR. Todas passam pelo Gateway, com organização, finalidade e contexto de paciente autorizados, e geram `AuditEvent`.

| Operação | Resultado |
| --- | --- |
| `POST /ips-requests` (referência da concessão lida do QR, manifesto, decisões) | `Bundle` `type = document` em `application/fhir+json`, `OperationOutcome` com pendências, ou `403` se o estabelecimento não for cadastrado ou a concessão for inválida |
| `POST /federation/ips-requests` (referência da concessão, estabelecimento solicitante, plataforma solicitante, finalidade, manifesto, decisões) | Entre Gateways de plataformas pares, na opção B. Devolve `Bundle`, `OperationOutcome` ou `403`. Não é chamado pelo PEP |
| `POST /ips-documents/{id}/deliveries` (destino) | Envio à plataforma de outra UF, com outbox e idempotência |
| `GET /ips-evidence/{ipsId}` | JSON próprio com evidência, sem conteúdo clínico |
| `POST /ips-evidence/{ipsId}/$verify` (um `Bundle`) | "Hash confere" ou "não confere", sem devolver o documento |
| `Subscription` com `ips-finalized` e `ips-delivered` | Aviso sem conteúdo clínico |

Leitura humana: vem da narrativa (`Composition.text`) do próprio IPS.

O pedido não recebe identificador de paciente do PEP. A geração, a validação e o consumo da concessão pertencem ao MeuPEP, descrito na proposta de autorização; este contrato só a consome. O formato do QR (por exemplo, URL com referência opaca), o protocolo entre Gateway e MeuPEP e o contrato federado da opção B (inclusive autenticação entre pares) são pontos a decidir. O PEP usa o mesmo `POST /ips-requests` nas duas opções; é o Gateway que decide pela UF emissora do QR.

## 1.5 Comparação com as outras alternativas

| Critério | A: evidência | B: IPS vigente | C: sob demanda, cache curto |
| --- | --- | --- | --- |
| Pergunta que responde | O que enviamos e a quem | Qual é o IPS do paciente X | Qual é o IPS do paciente X |
| Documento clínico retido | Até 72 h | Meses | Minutos ou horas |
| Frescor do IPS | Do momento do pedido | Pode estar defasado, sinalizado | Do momento do pedido |
| Risco LGPD | Baixo | Alto | Baixo a médio |
| Perigo clínico principal | Baixo | IPS defasado lido como atual | Política errada aplicada a cada pedido |
| Autoria clínica | Cliente, a cada pedido | Organização da política, contínua | Organização da política, a cada pedido |
| Latência | Não se aplica | Baixa | Alta (montagem na hora) |
| Componentes novos | Arquivo de evidência | Arquivo, Síntese, curadoria, chaves | Síntese, cache, evidência, Despachante |

## 1.6 Riscos e contraponto

1. **A política de seleção é curadoria clínica automática com outro nome.** Se for simples, erra em casos limite; se for sofisticada, vira regra clínica inventada, risco que a seção 26 da proposta já nomeia. Limitar a regras verificáveis por exemplos oficiais e mandar o resto para decisão humana.
2. **Cache pode devolver IPS defasado.** Se chegar um RAC novo durante o TTL, o `Bundle` em cache deixa de ser a síntese mais atual. A chave do cache deve incluir paciente, versão da política, versão do pacote e hash do manifesto, e o cache deve ser invalidado por evento de novo RAC. Sem isso, a C reproduz o perigo clínico da B em escala menor. A resposta sempre deve trazer `generatedAt`.
3. **A latência da montagem pode inviabilizar o uso no ponto de cuidado.** Só medição em protótipo decide.
4. **A taxa de conflito sem regra pode ser alta.** Se for, o resultado comum é "não foi possível gerar", o que enfraquece a promessa "qual é o IPS do paciente X?".
5. **O que a UF destinatária faz depois da entrega não é controlado.** A evidência prova o que enviamos; a retenção do outro lado precisa entrar no contrato federado.
6. **QR code é credencial ao portador.** Quem fotografar ou interceptar o QR antes do uso pode tentar usá-lo, mas só um estabelecimento cadastrado é aceito. Mitigações propostas: prazo curto, uso único, escopo só IPS, QR rotativo e vínculo da concessão ao estabelecimento que a leu. A recusa por concessão já usada precisa ser visível ao paciente no MeuPEP, que mostra o histórico de acessos.
7. **Cadastro de estabelecimentos.** "Cadastrada" ainda não tem fonte nem critério definidos (CNES simulado, cadastro próprio da plataforma, habilitação por finalidade). Estabelecimento descadastrado depois da leitura do QR deve ser recusado no momento do pedido, não na emissão.
8. **Conectividade e acessibilidade do paciente.** O fluxo exige celular com o MeuPEP e conta GOV.BR de nível adequado. Sem eles (emergência, paciente inconsciente, sem celular), o fluxo não funciona; o acesso emergencial da proposta de autorização está fora deste recorte.
9. **Escopo do consentimento.** A concessão cobre a leitura do IPS pelo estabelecimento. O envio a outra UF (Despachante) é um segundo uso e precisa ou de consentimento próprio ou de decisão explícita de que a concessão o cobre. Consentimento dinâmico completo está fora do escopo do protótipo (`pratica.md`), então o protótipo simula a concessão com dados sintéticos.
10. **Opção B: o QR revela a UF emissora.** O identificador da UF no QR informa onde o paciente tem cadastro. É pouco sensível, mas não é anônimo; a equipe precisa decidir se aceita ou se o QR deve usar só uma referência que a UF visitada resolva por um serviço de descoberta.
11. **Opção B: confiança no cadastro do par.** A UF de origem aceita o estabelecimento porque a UF visitada o declarou cadastrado, ou verifica por conta própria? A primeira alternativa transfere a confiança para outra UF; a segunda exige um cadastro compartilhado. A decisão vai para o contrato federado (ADR).
12. **Opção B: latência e disponibilidade em dois saltos.** O tempo soma a ida e a volta entre UFs e a montagem na UF de origem, e a falha de uma UF afeta o atendimento na outra. Só medição em protótipo com duas plataformas simuladas decide, e o tempo limite e o erro precisam estar no contrato.
13. **Opção B: retenção na UF visitada e rastros nas duas UFs.** A proposta é a UF visitada não reter o `Bundle`, só entregá-lo e registrar o hash. Cada UF gera `AuditEvent` e evidência com um identificador de correlação que não identifique o paciente. A base legal e a retenção do lado da clínica precisam entrar no contrato federado.
14. **Escopo.** A C soma Serviço de Síntese, cache, Arquivo e Despachante; para o protótipo, o recorte mínimo é MeuPEP simulado (emite a concessão e o QR), verificação de estabelecimento cadastrado no Gateway, Síntese, Montador, Arquivo com `$verify` e um envio a uma plataforma par simulada. A opção B acrescenta uma segunda plataforma simulada (UF visitada) que só tem Gateway, cadastro e cliente federado.

## 1.7 Hipóteses a verificar nos protótipos

Uma verificação não executada permanece pendente, nunca registrada como atendida (seção 24.5 da proposta).

| Hipótese | Como verificar | Critério | Estado |
| --- | --- | --- | --- |
| H1: a evidência prova entrega sem reter conteúdo clínico | Gerar IPS sintético, enviar à UF par simulada, confirmar recibo, eliminar o `Bundle` | `$verify` confirma o hash; nenhum conteúdo clínico em logs, métricas e rastros | Pendente |
| H4: a montagem sob demanda tem latência aceitável | Medir com 2 ou mais RACs, laudo e medicamento | Limite a definir com a equipe | Pendente |
| H5: a política resolve a maioria dos casos sem curadoria | Medir a taxa de conflito sem regra em dados sintéticos realistas | Taxa a definir com a equipe | Pendente |
| H6: RAC substituído após a geração é detectável | Substituir um RAC já usado como fonte (incidente 13 da seção 21) | A evidência identifica os IPS afetados por RAC e versão | Pendente |
| H7: o cache não serve IPS defasado | Publicar RAC novo durante o TTL e pedir o IPS | Resposta reflete o RAC novo ou sinaliza defasagem | Pendente |
| H8: só estabelecimento cadastrado com concessão válida acessa o IPS | Testar com estabelecimento não cadastrado, cadastrado e descadastrado; concessão válida, expirada, revogada, já usada e de outro escopo | Todo caso inválido recebe recusa, não lê o Servidor FHIR e gera `AuditEvent`; o caso válido devolve o `Bundle` | Pendente |
| H9: o QR e os rastros não expõem dado do paciente | Inspecionar o conteúdo do QR, logs, métricas e rastros em um fluxo completo com dados sintéticos | Nenhum identificador de paciente, token ou conteúdo clínico no QR, nos logs e nos rastros | Pendente |
| H10: o QR de uso único funciona no ponto de cuidado | Medir o tempo da leitura até a resposta, incluindo a validação da concessão, e repetir a leitura do mesmo QR | Tempo a definir com a equipe; a segunda leitura é recusada | Pendente |
| H11: o acesso de outra UF entrega o IPS sem a UF visitada reter conteúdo clínico | Com duas plataformas simuladas, ler o QR emitido pela UF de origem na clínica da UF visitada | PEP recebe o `Bundle`; a UF visitada não tem `Bundle` em cache, Arquivo, logs ou rastros, só o hash; a evidência da UF de origem identifica o estabelecimento e a UF visitada | Pendente |
| H12: a opção B recusa e falha de forma explícita | Testar estabelecimento não cadastrado na UF visitada, par não habilitado, concessão inválida, usada e UF de origem fora do ar | Cada caso recebe `403` ou erro explícito, nunca "sem IPS"; nenhuma leitura de fatos na UF de origem nos casos de recusa | Pendente |


# Parte 2. Como montar o Montador Efêmero

## 2.8 Seções do IPS Brasil

Fonte: [perfil CompositionBRIPS publicado](https://hl7.org.br/fhir/ips/StructureDefinition-CompositionBRIPS.html), consultado em 21 de outubro de 2026. O perfil define 3 seções obrigatórias e 11 opcionais, todas com código LOINC fixo.

**Atenção à versão:** a página se declara "v1.2.0, versão publicada corrente, ativa desde 2026-08-22" e, no mesmo texto, cita "versão atual 1.1.0". A linha de base da proposta (seção 10.3) é `br.gov.saude.ips.fhir#1.0.0`, sem publicação formal em 2 de agosto de 2026. Os dados abaixo vêm da página atual e precisam ser reconferidos contra o `package.tgz` 1.0.0 arquivado antes de virarem regra do Montador. Divergência exige ADR.

| Seção | LOINC | Obrigatoriedade | Recursos aceitos |
| --- | --- | --- | --- |
| Medicamentos (`sectionMedications`) | 10160-0 | Obrigatória | `MedicationStatementBRIPS`, `MedicationRequestBRIPS` |
| Alergias e intolerâncias (`sectionAllergies`) | 48765-2 | Obrigatória | `AllergyIntoleranceBRIPS` |
| Lista de problemas (`sectionProblems`) | 11450-4 | Obrigatória | `ConditionBRIPS` |
| Histórico de procedimentos | 47519-4 | Opcional | `ProcedureBRIPS` |
| Imunizações | 11369-6 | Opcional | `ImmunizationBRIPS` |
| Dispositivos médicos | 46264-8 | Opcional | `DeviceUseStatement` (IPS) |
| Resultados | 30954-2 | Opcional | `ObservationResultsBRIPS`, `DiagnosticReportBRIPS` |
| Sinais vitais | 8716-3 | Opcional | `VitalSignsBRIPS` |
| Doenças pregressas | 11348-0 | Opcional | `ConditionBRIPS` |
| Capacidade funcional | 47420-5 | Opcional | `ConditionBRIPS`, `ClinicalImpression` |
| Plano de cuidados | 18776-5 | Opcional | `CarePlan` |
| História social | 29762-2 | Opcional | `Observation` (tabaco e álcool) |
| História obstétrica | 10162-6 | Opcional | `ObservationPregnancyStatusBRIPS`, `ObservationPregnancyOutcomeBRIPS` |
| Diretivas antecipadas | 42348-3 | Opcional | `Consent` |

Outros fatos do perfil: `Composition.type` fixo em LOINC 60591-5, `status` fixo em `final`, `title` fixo em "Sumário Internacional do Paciente", `subject` apenas `PatientBRIPS` e narrativa obrigatória em cada seção.

**Recorte proposto para o protótipo:** as 3 obrigatórias mais Resultados e Imunizações, se a jornada SISCAN e o cenário integrado da seção 24.2 forem selecionados.
