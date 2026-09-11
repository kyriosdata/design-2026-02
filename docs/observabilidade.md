## Estratégia de Logs e Privacidade

Esta seção define as diretrizes de logging da Plataforma de Interoperabilidade em Saúde. O objetivo é permitir diagnóstico técnico, rastreabilidade e observabilidade sem registrar conteúdo clínico, dados pessoais sensíveis ou credenciais.

> **Escopo:** esta política cobre logs de observabilidade da plataforma. Trilhas de auditoria clínica/regulatória são artefatos separados, com requisitos próprios de retenção, acesso e base legal.

### 1. Princípios

- **Minimização:** registrar apenas o necessário para operar, diagnosticar e correlacionar eventos.
- **Allowlist:** somente campos previamente aprovados podem ser registrados.
- **Sanitização na origem:** nenhum componente deve delegar a limpeza de dados sensíveis ao coletor de logs.
- **Separação entre observabilidade e auditoria:** logs técnicos não substituem trilha de auditoria.
- **Correlação sem identificação pessoal:** usar `correlation_id`, `request_id`, `trace_id` e `span_id`; não usar CPF, CNS ou prontuário como chave de correlação.
- **JSON estruturado:** logs em JSON Lines, uma linha por evento, legíveis por máquina.
- **DEBUG não vai para produção por padrão:** quando habilitado, deve ser temporário, amostrado e auditado.

### 2. Níveis de log e cenários de uso

| Nível | Uso | Exemplos de cenário | Produção |
|---|---|---|---|
| `DEBUG` | Diagnóstico fino, passos internos, decisões de mapeamento e validação. | Início de parsing FHIR, regra de mapeamento aplicada, payload preparado para chamada externa, decisão de fallback. | Desabilitado por padrão. Só em dev/homolog ou habilitação temporária com amostragem e revisão de privacidade. |
| `INFO` | Marcos normais do fluxo. | Requisição recebida, autenticação bem-sucedida, RAC aceito, IPS montado, dispensação REDFM registrada, troca federada concluída. | Habilitado. |
| `WARN` | Situação recuperável, degradação ou anomalia esperada. | Timeout externo com retry, campo opcional ausente, versão de perfil depreciada, dependência lenta, fallback acionado, limite de taxa próximo. | Habilitado. |
| `ERROR` | Falha que impede a operação ou exige ação. | FHIR inválido, falha de autenticação/autorização, indisponibilidade da RNDS/SISCAN, erro de persistência, falha na montagem do IPS, falha de correlação de medicamentos. | Habilitado. |

Não criar níveis adicionais sem revisão. Casos fatais devem ser registrados como `ERROR` com `error.fatal: true`, se necessário.

### 3. Estrutura técnica padronizada

Formato: **JSON Lines**, UTF-8, um objeto JSON por linha. Timestamps em UTC, ISO 8601 com milissegundos.

Campos obrigatórios:

| Campo | Tipo | Descrição |
|---|---|---|
| `timestamp` | string | Data/hora UTC do evento. |
| `level` | string | `DEBUG`, `INFO`, `WARN` ou `ERROR`. |
| `service` | string | Nome do serviço/componente. |
| `env` | string | `dev`, `homolog`, `prod`. |
| `version` | string | Versão do serviço. |
| `event` | string | Nome estável do evento, ex.: `rac.ingest.completed`. |
| `correlation_id` | string | Correlação ponta a ponta sem dado pessoal. |
| `outcome` | string | `success`, `failure`, `partial`, `skipped`. |

Campos permitidos conforme contexto:

| Campo | Exemplo | Observação |
|---|---|---|
| `request_id` | `req-...` | ID interno da requisição. |
| `trace_id` / `span_id` | `...` | OpenTelemetry ou equivalente. |
| `http.method` | `POST` | Método HTTP. |
| `http.route` | `/fhir/ips/$assemble` | Rota template, nunca URL bruta com IDs. |
| `http.status_code` | `201` | Status HTTP. |
| `http.duration_ms` | `342` | Duração. |
| `error.code` | `IPS_MANDATORY_SECTION_MISSING` | Código interno estável. |
| `error.type` | `ValidationError` | Classe/tipo sanitizado. |
| `error.message_sanitized` | `IPS assembly failed...` | Mensagem sem conteúdo clínico. |
| `error.retryable` | `false` | Indica retry seguro. |
| `external.system` | `RNDS`, `SISCAN`, `REDFM` | Sistema externo. |
| `external.operation` | `rac.search` | Operação externa. |
| `external.status_code` | `200` | Status externo. |
| `resource.type` | `Bundle`, `Composition` | Tipo FHIR. |
| `resource.profile` | `.../BRRegistroAtendimentoClinico` | Perfil canônico. |
| `resource.operation` | `rac.ingest`, `ips.assemble` | Operação. |
| `counts.*` | `source_documents: 3` | Contagens operacionais. |
| `organization.id` / `establishment.id` | CNES | Apenas metadado institucional, quando indispensável. |
| `actor.id_hash` | HMAC | Apenas se necessário; nunca identificador direto. |

Regras de sanitização:

- Não registrar URL bruta, query string completa ou headers completos.
- Mascarar/remover `Authorization`, `Cookie`, `Set-Cookie`, `X-Api-Key`, tokens JWT, certificados e segredos.
- Não registrar payloads FHIR completos, JSON do SISCAN, XML, PDFs, laudos ou textos livres.
- Stack traces só podem ser registrados se não contiverem dados clínicos/pessoais. Preferir `error.type`, `error.code` e `stack_trace_hash`.

### 4. Dados que NÃO podem ser registrados em logs

| Categoria | Exemplos proibidos |
|---|---|
| Conteúdo clínico integral | Bundle RAC, Composition, IPS, recursos `Patient`, `Encounter`, `Observation`, `Condition`, `AllergyIntolerance`, `MedicationRequest`, `MedicationDispense`, `MedicationAdministration`, `DiagnosticReport`, `Procedure`. |
| Textos clínicos livres | Motivo do atendimento, evolução, observações, plano de cuidados, orientações, anotações, laudos, pareceres. |
| Diagnósticos e resultados | CID/CIAP, alergias, problemas avaliados, resultados laboratoriais, sinais vitais, citologia, histopatologia, mamografia, DNA-HPV. |
| Medicamentos | Prescrições, doses, posologia, via, frequência, dispensação, administração, correlação medicamentosa. |
| Identificadores pessoais | CPF, CNS, nome, nome social, data de nascimento, RG, endereço, telefone, e-mail, biometria, foto, cartão de benefício. |
| Credenciais e segredos | JWT, `Authorization: Bearer`, `client_secret`, senha, refresh token, certificado digital, chave privada, cookie de sessão. |
| Payloads brutos | Corpo de requisição/resposta FHIR, JSON SISCAN, XML, PDF, anexos, imagens. |
| Query strings sensíveis | Parâmetros com CPF, CNS, nome, prontuário, data de nascimento, identificadores de paciente. |

> CNES e CBO podem ser tratados como metadados institucionais/ocupacionais, mas não devem ser combinados com dados clínicos a ponto de permitir reidentificação indevida.

### 5. Metadados técnicos permitidos

- `timestamp`, `level`, `service`, `env`, `version`, `event`, `outcome`.
- `correlation_id`, `request_id`, `trace_id`, `span_id`.
- `http.method`, `http.route`, `http.status_code`, `http.duration_ms`.
- `error.code`, `error.type`, `error.message_sanitized`, `error.retryable`, `error.fatal`.
- `external.system`, `external.operation`, `external.status_code`, `external.duration_ms`.
- `resource.type`, `resource.profile`, `resource.operation`.
- `counts.source_documents`, `counts.entries`, `counts.warnings`, `counts.errors`.
- `organization.id`, `establishment.id` (ex.: CNES), quando estritamente necessário para operação.
- `actor.id_hash` ou pseudônimo interno, apenas se indispensável e com HMAC/chave gerenciada.

### 6. Exemplos práticos de payload de log

#### 6.1 Fluxo executado com sucesso

Evento: montagem de IPS concluída com sucesso a partir de RACs e outras fontes.

```json
{
  "timestamp": "2026-08-02T14:35:22.123Z",
  "level": "INFO",
  "service": "ips-assembler",
  "env": "prod",
  "version": "1.0.0",
  "event": "ips.assembly.completed",
  "correlation_id": "corr-7f3a9c2e",
  "request_id": "req-8b1d4e6f",
  "trace_id": "4bf92f3577b34da6a3ce929d0e0e4736",
  "span_id": "00f067aa0ba902b7",
  "http": {
    "method": "POST",
    "route": "/fhir/ips/$assemble",
    "status_code": 201,
    "duration_ms": 342
  },
  "resource": {
    "type": "Bundle",
    "profile": "https://ips.saude.gov.br/fhir/StructureDefinition/BundleBRIPS|1.0.0",
    "operation": "ips.assemble"
  },
  "external": {
    "system": "RNDS",
    "operation": "rac.search",
    "status_code": 200,
    "duration_ms": 120
  },
  "counts": {
    "source_documents": 3,
    "warnings": 0
  },
  "outcome": "success"
}
