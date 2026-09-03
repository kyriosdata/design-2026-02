## 5. Métricas, Observabilidade e Indicadores de Saúde

Este capítulo especifica a estratégia de telemetria, métricas operacionais e indicadores de saúde (SLIs/SLOs) da Plataforma Estadual de Interoperabilidade em Saúde, cobrindo tanto as interações síncronas quanto os processamentos assíncronos da arquitetura.

---

### 5.1. Visão Geral da Estratégia de Observabilidade

Para garantir a alta disponibilidade, a resiliência e a integridade das trocas clínicas entre os sistemas participantes, a plataforma adota o monitoramento baseado nos **Four Golden Signals** (Latência, Tráfego, Erros e Saturação). Como diferencial de segurança e confiabilidade, a arquitetura correlaciona diretamente as métricas de monitoramento às fragilidades e vulnerabilidades técnicas conhecidas na taxonomia **CWE (Common Weakness Enumeration)**.

---

### 5.2. Indicadores Vitais por Componente da Arquitetura

A tabela a seguir consolida as métricas vitais da plataforma, categorizadas por tipo de componente, estabelecendo os comportamentos operacionais esperados e o mapeamento dos riscos de software associados:

| Tipo de Componente | Métricas Chave | Descrição Técnica | Operação Normal | Cenário Degradado | Mapeamento CWE Relacionado |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Gateway de Integração (Síncrono)** | `http_requests_total`<br>`http_request_duration_seconds`<br>`http_requests_errors_total` | Taxa de requisições por segundo (RPS), latência nos percentis `p50`/`p95`/`p99` e taxa de erros HTTP (4xx/5xx). | RPS dentro do baseline;<br>p95 < 200ms;<br>Taxa de erro 5xx < 0.1%. | p95 > 2000ms;<br>Taxa de erro 5xx > 5%;<br>Spike repentino de erros 429 (Rate Limit). | **CWE-400** (Uncontrolled Resource Consumption)<br>**CWE-770** (Allocation Without Limits/Throttling) |
| **Servidor FHIR / Banco de Dados (Síncrono)** | `fhir_storage_query_duration_seconds`<br>`db_connection_pool_usage`<br>`db_cpu_utilization` | Latência das consultas FHIR, consumo do pool de conexões do banco de dados e saturação de hardware. | Uso do pool < 60%;<br>Latência de busca < 100ms;<br>CPU < 50%. | Uso do pool = 100% (Exaustão);<br>Timeouts de conexão;<br>CPU > 90%. | **CWE-400** (Uncontrolled Resource Consumption)<br>**CWE-1088** (Synchronous Wait) |
| **Integrações Externas / Adapters (SISCAN, RNDS)** | `external_dependency_duration_seconds`<br>`external_dependency_failures_total`<br>`circuit_breaker_state` | Latência de chamadas de rede para APIs externas, taxa de timeout/falhas e estado do Circuit Breaker (`CLOSED`, `OPEN`, `HALF-OPEN`). | Circuit Breaker: `CLOSED`;<br>Latência externa < 1200ms;<br>Falhas de integração < 1%. | Circuit Breaker: `OPEN`;<br>Timeouts consecutivos (> 5s);<br>Cascata de erros no Gateway. | **CWE-391** (Unchecked Error Condition)<br>**CWE-835** (Unreachable Exit Condition / Retries Infinitos) |
| **Filas e Mensageria (Assíncrono)** | `queue_messages_unacknowledged`<br>`queue_message_dwell_time_seconds`<br>`queue_throughput_messages_per_second` | Volume de mensagens aguardando processamento, tempo de permanência (idade da mensagem na fila) e taxa de vazão dos consumidores. | Dwell time < 2s;<br>Tamanho da fila estável próximo a zero;<br>Vazão de consumo >= vazão de entrada. | Dwell time > 300s;<br>Acúmulo exponencial de mensagens;<br>Consumidores sem vazão (Stall). | **CWE-400** (Uncontrolled Resource Consumption)<br>**CWE-770** (Allocation Without Limits) |
| **Falhas e Resiliência Assíncrona (DLQ)** | `dlq_messages_count`<br>`worker_processing_errors_total` | Contagem total de mensagens enviadas para a Dead Letter Queue (DLQ) e contagem de exceções de processamento por worker. | DLQ = 0 (ou sem crescimento sem análise);<br>Erros em workers < 0.01%. | Crescimento contínuo e rápido da DLQ;<br>Workers entrando em CrashLoopBackOff. | **CWE-390** (Detection of Error Condition Without Action)<br>**CWE-391** (Unchecked Error Condition) |
| **Logs e Telemetria Transversal** | `log_events_total_by_level`<br>`tracing_spans_dropped_total` | Nível de severidade dos logs (`INFO`, `WARN`, `ERROR`), rastros distribuídos descartados e sanidade do pipeline de observabilidade. | Razão ERROR/INFO < 0.01;<br>0 vazamentos de dados sintéticos/sensíveis não mascarados. | Explosão de logs de `ERROR`;<br>Vazamento de PII/Dados Clínicos em logs. | **CWE-532** (Insertion of Sensitive Information into Log File) |

---

### 5.3. Regras de Alertabilidade e Indicadores de Anomalias (SLIs / SLOs)

#### 5.3.1. Alertas de Severidade Alta (P1 - Atendimento Imediato)
* **Abertura do Circuit Breaker das APIs Governamentais (SISCAN/RNDS):**
  * **Sinalizador:** `circuit_breaker_state == OPEN` por mais de 1 minuto.
  * **Impacto:** Impossibilidade imediata de integração e sincronização com serviços nacionais.
* **Acúmulo Crítico na Fila de Mensageria (Assíncrono):**
  * **Sinalizador:** `queue_message_dwell_time_seconds > 300` (Mensagens retidas há mais de 5 minutos).
  * **Impacto:** Atraso severo na entrega de notificações e na montagem federada de documentos efêmeros de IPS.
* **Retenção de Erros na DLQ (Dead Letter Queue):**
  * **Sinalizador:** `rate(dlq_messages_count[5m]) > 0`.
  * **Impacto:** Perda ou rejeição sistemática de mensagens devido a inconsistências de contrato ou indisponibilidade de dependências.

#### 5.3.2. Alertas de Severidade Média (P2 - Investigação Técnica)
* **Degradação de Latência em Fluxos Síncronos:**
  * **Sinalizador:** `http_request_duration_seconds{quantile="0.95"} > 1.5s` mantido por 5 minutos consecutivos.
* **Esgotamento de Recursos de Armazenamento:**
  * **Sinalizador:** `db_connection_pool_usage > 85%` mantido por 3 minutos consecutivos.

---

### 5.4. Decisões Arquiteturais e Pendências (ADR)

#### 5.4.1. Decisões Consolidadas
1. **Padrão de Exposição de Telemetria:** Adoção unificada do formato Prometheus para exposição de métricas via endpoint `/metrics` em todos os microserviços e adaptadores.
2. **Isolamento e Resiliência Assíncrona:** Toda mensagem não processada com sucesso após 3 tentativas via *Exponential Backoff* DEVE ser encaminhada automaticamente para a Dead Letter Queue (DLQ) correspondente, evitando gargalos no *pipeline* principal.
3. **Mapeamento Explícito de Vulnerabilidades (CWE):** Vinculação formal das exceções de observabilidade com fraquezas conhecidas da arquitetura de software (**CWE-390**, **CWE-391**, **CWE-400**, **CWE-532**, **CWE-770** e **CWE-1088**).

#### 5.4.2. Pontos Pendentes de Definição
* **Calibração Fina dos Limiares de SLI/SLO:** Ajuste dos valores numéricos definitivos de alertas com base nos resultados obtidos nos testes de carga e estresse programados no Incremento 1.
* **Governança e Replay de DLQ:** Definição da política operacional e das rotinas automáticas de reprocessamento (*replay*) ou expurgo controlado das mensagens armazenadas na DLQ.
