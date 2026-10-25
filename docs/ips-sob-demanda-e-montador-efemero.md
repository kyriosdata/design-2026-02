
# Parte 1. IPS sob demanda com cache curto

## 1.1 Resumo

**"qual é o IPS do paciente X?"** gerando o documento **no momento do pedido**, sem repositório longitudinal.

- Um **Serviço de Síntese** (novo) recebe o pedido, lê os fatos candidatos, aplica uma **política de seleção determinística e versionada** e usa o Montador Efêmero para produzir o IPS validado.
- O `Bundle` final fica em um **cache curto** (minutos ou horas) e depois é eliminado.
- Cada geração grava **evidência sem conteúdo clínico** em um **Arquivo de evidência** (hash, manifesto, fontes, entregas, eliminação).
- O envio a outra UF só acontece **por pedido explícito**, por um **Despachante de Envio** com outbox e idempotência.

O Montador **não muda**: continua sem selecionar fatos, sem resolver conflitos por conta própria, sem enviar o IPS e sem conservar dados após o TTL de 60 minutos.

## 1.2 Fluxo de um pedido

1. O PEP pede o IPS de um paciente ao Gateway, com o manifesto e as decisões de conflito, se houver.
2. O Gateway autentica, verifica organização e finalidade e encaminha o pedido ao Serviço de Síntese.
3. O Serviço de Síntese consulta o cache. Se houver `Bundle` válido para o mesmo paciente, política e pacote, devolve esse documento.
4. Sem cache válido, lê os **fatos candidatos** no Servidor FHIR (somente leitura).
5. Aplica a **política de seleção** e monta o manifesto.
6. Abre uma sessão no Montador, submete os fatos e recebe `OperationOutcome` com pendências e conflitos. Conflito sem regra e sem decisão impede a finalização.
7. Chama `$finalize` e recebe o `Bundle` validado, com hash.
8. Grava o `Bundle` no cache (TTL curto) e registra a evidência no Arquivo.
9. Devolve o `Bundle` ao Gateway, que o entrega ao PEP.
10. Se o cliente pedir envio a outra UF, o Despachante lê o `Bundle` do cache, entrega pelo Gateway ao Gateway da plataforma par, e grava o recibo no Arquivo.

## 1.3 O que é guardado e por quanto tempo

Todos os prazos são hipóteses a validar com o encarregado de dados.

| Dado | Onde | Conteúdo clínico | Prazo proposto |
| --- | --- | --- | --- |
| Sessão de montagem | Repositório Transacional Efêmero | Sim | 60 minutos (proposta, seção 14.7), sem backup |
| `Bundle` final | Cache curto de IPS (cifrado) | Sim | Minutos ou horas, a definir |
| Manifesto de seleção | Arquivo de evidência | Só referências | Igual ao da evidência |
| Evidência | Arquivo de evidência | Não | Alinhado ao Repositório de Auditoria (a definir) |

Campos da evidência, sem conteúdo clínico:

- `ips_id` e hash SHA-256 do `Bundle` (bytes entregues);
- identificador pseudonimizado do paciente;
- versão do pacote `br.gov.saude.ips.fhir#1.0.0` e do validador;
- instante de geração, organização responsável, autor e atestador declarados;
- versão da política de seleção e hash do manifesto;
- fontes: id do RAC, versão, identificador RNDS e hash;
- resultado da validação de assinatura (`valid`, `invalid` ou `indeterminate`), quando exigida;
- entregas: destino, chave de idempotência, tentativas, estado, instante e recibo do destinatário;
- registro da eliminação do `Bundle`.

## 1.4 Como é disponibilizado (contrato proposto)

Estas URLs são um contrato próprio do projeto, sugerido por mim, não operações oficiais do FHIR. Todas passam pelo Gateway, com organização, finalidade e contexto de paciente autorizados, e geram `AuditEvent`.

| Operação | Resultado |
| --- | --- |
| `POST /ips-requests` (paciente, manifesto, decisões) | `Bundle` `type = document` em `application/fhir+json`, ou `OperationOutcome` com pendências |
| `POST /ips-documents/{id}/deliveries` (destino) | Envio à plataforma de outra UF, com outbox e idempotência |
| `GET /ips-evidence/{ipsId}` | JSON próprio com evidência, sem conteúdo clínico |
| `POST /ips-evidence/{ipsId}/$verify` (um `Bundle`) | "Hash confere" ou "não confere", sem devolver o documento |
| `Subscription` com `ips-finalized` e `ips-delivered` | Aviso sem conteúdo clínico |

Leitura humana: vem da narrativa (`Composition.text`) do próprio IPS.

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
6. **Escopo.** A C soma Serviço de Síntese, cache, Arquivo e Despachante; para o protótipo, o recorte mínimo é Síntese, Montador, Arquivo com `$verify` e um envio a uma plataforma par simulada.

## 1.7 Hipóteses a verificar nos protótipos

Uma verificação não executada permanece pendente, nunca registrada como atendida (seção 24.5 da proposta).

| Hipótese | Como verificar | Critério | Estado |
| --- | --- | --- | --- |
| H1: a evidência prova entrega sem reter conteúdo clínico | Gerar IPS sintético, enviar à UF par simulada, confirmar recibo, eliminar o `Bundle` | `$verify` confirma o hash; nenhum conteúdo clínico em logs, métricas e rastros | Pendente |
| H4: a montagem sob demanda tem latência aceitável | Medir com 2 ou mais RACs, laudo e medicamento | Limite a definir com a equipe | Pendente |
| H5: a política resolve a maioria dos casos sem curadoria | Medir a taxa de conflito sem regra em dados sintéticos realistas | Taxa a definir com a equipe | Pendente |
| H6: RAC substituído após a geração é detectável | Substituir um RAC já usado como fonte (incidente 13 da seção 21) | A evidência identifica os IPS afetados por RAC e versão | Pendente |
| H7: o cache não serve IPS defasado | Publicar RAC novo durante o TTL e pedir o IPS | Resposta reflete o RAC novo ou sinaliza defasagem | Pendente |


# Parte 2. Como montar o Montador Efêmero

## 2.1 Papel e limites

O **Montador Efêmero de IPS** produz um novo documento IPS a partir de fatos já selecionados por um cliente autorizado

| Papel | Responsabilidade | O que não faz |
| --- | --- | --- |
| Cliente autorizado (ou Serviço de Síntese) | Seleciona fatos, monta o manifesto, decide conflitos, declara autor, atestador e custodiante | Não altera a regra do Montador |
| Montador Efêmero | Valida, correlaciona, aplica regras explícitas e versionadas, gera `Composition` e `Bundle` | Não consulta fontes, não cura clinicamente, não resolve conflito sem decisão, não envia, não guarda após o TTL |
| Serviço de Documentos RNDS | Publica o IPS finalizado, se o cliente pedir | Não monta nem altera o conteúdo |

Quatro regras valem em toda a montagem:

1. **Nunca converter mecanicamente.** A `Composition` do RAC não vira `CompositionBRIPS`; o IPS é síntese derivada, com autoria e instante próprios.
2. **Ausência não é ausência clínica.** Seção vazia nunca é interpretada como "nenhuma conhecida".
3. **Conflito sem decisão impede a finalização.** Não existe "última escrita vence".
4. **Proveniência por fato.** Cada fato importado carrega RAC de origem, versão e identificador RNDS, quando houver.

O Montador também não: mantém prontuário longitudinal, corrige silenciosamente recurso inválido, resolve identidade de paciente de forma probabilística, torna-se fonte oficial dos recursos recebidos nem conserva o IPS após a expiração.

## 2.2 Contêineres vizinhos

| Contêiner | Relação com o Montador |
| --- | --- |
| Gateway de Integração | Autentica e autoriza as chamadas de montagem |
| Repositório Transacional Efêmero | Guarda sessões, entradas, resultado e caixa de saída lógica por até 60 minutos, sem backup persistente |
| Serviço de Validação e Terminologia | Validador HAPI com o pacote IPS Brasil local e terminologias fixadas |
| Serviço de Eventos e Subscriptions | Recebe o evento `ips-finalized`, entregue pelo menos uma vez, sem conteúdo clínico |
| Coletor de Auditoria | Recebe `AuditEvent` de criação, acesso, validação, finalização, cancelamento e expiração |

## 2.3 Entradas e saídas

**Entradas** (`application/fhir+json`): recurso individual, `Bundle` de lote, ou `Bundle` RAC com manifesto de seleção. Na criação, o cliente fixa metadados imutáveis: organização responsável, autor da `Composition`, atestador e custodiante (quando aplicável), finalidade, versão da política de seleção, pacote de perfis e prazo.

Cada submissão traz: identificador da sessão, origem organizacional, chave de idempotência, versão esperada da sessão, declaração do paciente, instante, versão do pacote, documento e versão de origem e versão do manifesto.

**Saídas:**

- confirmação dos recursos aceitos;
- `OperationOutcome` com erros, avisos e caminho dos elementos;
- inventário das seções completas, ausentes ou inconsistentes;
- estado e versão da sessão;
- no encerramento, `Bundle` com `type = document`, hash, versão do pacote, `Provenance` e instante de expiração.

O primeiro recurso do `Bundle` é a `Composition`; todas as referências internas são resolvidas e cada `fullUrl` é único.

## 2.4 Contrato conceitual

URLs próprias do projeto (seção 14.5 da proposta), não operações oficiais do FHIR.

| Operação | Finalidade |
| --- | --- |
| `POST /ips-assemblies` | Criar sessão e fixar paciente, perfil, autoridade, política e expiração |
| `POST /ips-assemblies/{id}/entries` | Submeter recurso ou lote |
| `PUT /ips-assemblies/{id}/entries/{entryId}` | Substituir entrada antes da finalização |
| `DELETE /ips-assemblies/{id}/entries/{entryId}` | Remover entrada antes da finalização |
| `POST /ips-assemblies/{id}/sources/rac` | Submeter RAC e manifesto |
| `GET /ips-assemblies/{id}` | Consultar estado, inventário e pendências |
| `POST /ips-assemblies/{id}/$validate` | Validação integral sem congelar |
| `POST /ips-assemblies/{id}/$finalize` | Congelar, montar e validar o IPS |
| `GET /ips-assemblies/{id}/document` | Reobter o resultado antes da expiração (mesmo hash) |
| `DELETE /ips-assemblies/{id}` | Cancelar e eliminar a sessão |

Regras: toda mutação exige `If-Match` e chave de idempotência. Versão desatualizada: `412`. Estado incompatível ou mesma chave com corpo diferente: `409`. Sessão expirada: `410`. A busca pela chave e pela impressão digital da requisição precede a validação do estado.

## 2.5 Ciclo de vida da sessão

Estados: `Aberta`, `Inconsistente`, `Pronta`, `Finalizando`, `Finalizada`, `Cancelada`, `Expirada`.

- Sessões finalizadas são imutáveis; nova entrada exige nova sessão.
- Cancelamento só em `Aberta`, `Inconsistente` ou `Pronta`.
- TTL padrão de **60 minutos contados da criação**, sem prorrogação silenciosa; o cliente comum pode reduzir, não ampliar.
- Ao expirar, entradas, índices, erros detalhados e documento final são eliminados.
- Logs só com identificadores opacos, tempos, códigos de resultado e correlação.

## 2.6 Pipeline de montagem

1. **Abrir a sessão.** Metadados imutáveis fixados, estado `Aberta`.
2. **Submeter os fatos.** Sempre com `If-Match`, chave de idempotência e origem. Paciente diferente é rejeitado sem contaminar a sessão.
3. **Validar cada submissão.** Envelope, documento-fonte, sintaxe FHIR, perfil `BRIPS` de destino ou mapeamento explícito, terminologia na versão fixada, identidade e referências. Erro produz `OperationOutcome`.
4. **Resolver conflitos.** Duas origens sobre o mesmo fato exigem decisão explícita no manifesto; sem ela, a sessão fica `Inconsistente`.
5. **Validar integralmente** (`$validate`). Coerência de datas e estados, duplicidades, recursos substituídos e completude das seções obrigatórias. Resultado `Pronta`.
6. **Finalizar** (`$finalize`). Congela entradas e manifesto (o hash do manifesto entra nos metadados), gera a `Composition` nova e o `Bundle`.
7. **Validar o documento como unidade** contra `BundleBRIPS|1.0.0` e `CompositionBRIPS|1.0.0`, com o validador HAPI e o pacote local.
8. **Entregar.** Devolve `Bundle`, hash e `Provenance`; grava o evento `ips-finalized` na caixa de saída na mesma transação.
9. **Expirar.** Ao fim do TTL, tudo é eliminado; repetir `$finalize` antes disso devolve o mesmo documento e o mesmo hash.

O fluxo nunca conserta recurso inválido: devolve o erro ao cliente.

## 2.7 Componentes sugeridos

A proposta define o Montador só como contêiner. A divisão abaixo é sugestão minha para discussão.

| Componente | Responsabilidade |
| --- | --- |
| API de Sessões | Recebe criar, entradas, validar, finalizar, obter e cancelar |
| Concorrência e idempotência | `If-Match`, chave de idempotência, `412` e `409` |
| Ciclo de vida da sessão | Estados, TTL de 60 minutos e eliminação ao expirar |
| Verificador de entradas | Envelope, paciente da sessão, referências e coerência |
| Importador de RAC | Valida o RAC e o manifesto, extrai fatos e proveniência |
| Motor de regras | Aplica precedência escrita e bloqueia conflito sem decisão |
| Gerador do documento | Nova `Composition`, `Bundle` com `fullUrl` únicos e `Provenance` |
| Cliente de validação | Chama o Serviço de Validação para recursos e para o `Bundle` final |
| Adaptador do Repositório | Grava sessão, entradas, resultado e caixa de saída numa transação |
| Despachante de eventos | Entrega `ips-finalized` pelo menos uma vez, sem conteúdo clínico |

Todos os componentes emitem `AuditEvent` ao Coletor de Auditoria.

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

## 2.9 Matriz RAC para IPS

O guia indica que o RAC alimenta Problemas, Medicamentos, Resultados e Histórico de Procedimentos (a linha da tabela de mapeamento da página está truncada e deve ser confirmada no `StructureMapBRIPS`). As demais colunas são proposta minha.

| Seção do IPS | Fonte no RAC | Outras fontes | Regra de seleção proposta | Tratamento obrigatório |
| --- | --- | --- | --- | --- |
| Problemas | Problemas e diagnósticos avaliados | Cliente | Só recurso ativo com `ConditionBRIPS` válido | Dois RACs divergentes exigem decisão explícita |
| Alergias | Alergias | Cliente | Com `AllergyIntoleranceBRIPS` | Versões conflitantes exigem decisão; nunca inferir "nenhuma conhecida" |
| Medicamentos | Prescrições | REPM/REDFM e `MedicationStatement` do cliente | O manifesto declara qual recurso entra e com qual rótulo | Nunca converter "prescrito" ou "dispensado" em "em uso" |
| Resultados | Observações | Laudo final do SISCAN e RNDS | Só laudo `final` entra; `preliminary` é rejeitado | Correção posterior gera nova versão e nova montagem |
| Procedimentos | Procedimentos | Cliente | Cliente seleciona | Mapear para `ProcedureBRIPS` de forma explícita e auditável |
| Imunizações | Não consta no RAC citado | RNDS (documentos de imunobiológicos) | Cliente seleciona | Fonte é outro documento RNDS |

O que o RAC traz e o IPS não aproveita (motivo do atendimento, dados do encontro, desfecho, atestado) é descartado, não migrado.

## 2.10 Política de seleção e conflitos

O Montador aplica regras, não julgamento clínico. Toda regra é explícita, versionada, testável com exemplo e auditável pelo hash do manifesto.

**Manifesto** (versionado, congelado na finalização): entradas selecionadas (origem, versão, identificador RNDS, hash), seção de destino de cada uma e decisões de conflito (qual fato prevalece, quem decidiu, motivo, instante).

| Situação | Tratamento | Quem decide |
| --- | --- | --- |
| Mesmo fato, versões diferentes do mesmo RAC | Usa a versão indicada no manifesto | Cliente |
| Mesmo fato em dois RACs, valores diferentes | Bloqueia a finalização até haver decisão | Cliente ou curador |
| Alergia ou problema ativo em um RAC e ausente em outro | Não conclui que foi resolvido; exige decisão | Cliente ou curador |
| Medicamento prescrito em um registro e dispensado em outro | Mantém os dois recursos distintos, com rótulos distintos | Política declara |
| Resultado preliminar e final do mesmo exame | Só o final entra | Regra fixa |
| RAC substituído depois da geração | Não altera IPS já finalizado; novo pedido gera novo IPS | Cliente |
| Seção obrigatória sem fato | Exige `emptyReason` explícito ou bloqueia | Cliente |

Precedência temporal só vale quando escrita na política e aprovada pela organização responsável; nunca como padrão implícito.

## 2.11 Composition, Bundle, proveniência e ausência

- **Composition:** gerada nova, com tipo LOINC 60591-5, status `final`, título fixo, `subject` para `PatientBRIPS`, `date` igual ao instante de geração do IPS (nunca a data do RAC) e uma `section` por seção incluída.
- **Bundle:** `type = document`, `Composition` como primeiro recurso, `fullUrl` único, referências fechadas, perfil `BundleBRIPS|1.0.0`, validado como unidade.
- **Proveniência:** um `Provenance` separa os responsáveis clínicos declarados pelo cliente, o sistema cliente e o Montador como agente de software. O Montador nunca assume autoria, atestação ou custódia clínica.
- **Ausência de informação:** o perfil admite `emptyReason`. A política distingue "nenhuma conhecida", "não perguntado" e "informação indisponível" apenas quando o cliente declara; seção obrigatória sem fato e sem declaração bloqueia a finalização.

**Conflito de autoria com o guia publicado.** O guia descreve que, na transformação oficial de documentos RNDS em IPS, autor, atestador e custodiante são fixos como Ministério da Saúde, com modo de atestação `legal`. A proposta (seção 14.3) define o oposto: organização, autor e atestador são declarados pelo cliente na criação da sessão. As duas posições não coexistem; a decisão exige ADR antes de implementar a `Composition`. A leitura mais segura é seguir a proposta e declarar no protótipo que o IPS é sintético e sem atestação nacional.

## 2.12 Segurança e privacidade

- Autenticação de sistema para sistema e autorização por organização, finalidade e sessão.
- Isolamento entre estabelecimentos e entre sessões.
- Criptografia em trânsito e no armazenamento temporário.
- Limites de tamanho, taxa e quantidade de recursos; proibição de URLs externas arbitrárias em anexos.
- Minimização dos dados enviados ao validador e ao serviço terminológico.
- `AuditEvent` para criação, acesso, validação, finalização, cancelamento e expiração.
- Exclusão verificável ao final do TTL.
- Testes que confirmem ausência de conteúdo clínico em logs, rastros e mensagens de erro.
- `AuditEvent` não garante não repúdio sozinho; se houver esse requisito, acrescentar identidade forte, assinatura digital, carimbo temporal e armazenamento resistente a alteração.

