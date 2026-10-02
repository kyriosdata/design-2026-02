# Dados para Investigação de Emergências pelo DPO

## 1. Trilha de Auditoria (`AuditEvent`)

Registros de eventos minimizados mantidos em um Repositório de Auditoria isolado. O sistema deve registrar de forma explícita eventos de:

* Criação

* Acesso

* Validação

* Finalização

* Cancelamento

* Expiração

## 2. Telemetria e Logs Operacionais

Registros técnicos usados para identificar falhas sistêmicas ou gargalos. Para manter a conformidade com a minimização de dados, esses logs devem conter **apenas**:

* Identificadores opacos

* Tempos de execução (timestamps)

* Códigos de resultado (como status HTTP)

* Dados de correlação de transações/rastreamento distribuído

## 3. Dados de Proveniência (`Provenance`)

Registros que preservam a origem dos dados e as responsabilidades envolvidas em cada transação, permitindo rastrear:

* Qual sistema cliente enviou ou solicitou a informação

* Qual profissional e organização detêm a autoria clínica do ato

* A atuação e transformação feita por agentes de software (como o Montador Efêmero)

## 4. Controles de Retenção (TTL)

Evidências operacionais de que os prazos de retenção foram cumpridos rigorosamente. O principal exemplo é o Repositório Transacional Efêmero, cujo *Time to Live* (TTL) é de 60 minutos, garantindo a exclusão verificável dos dados da montagem de IPS após esse tempo.

## Restrições Rigorosas na Investigação (Invariantes)

Ao conduzir qualquer investigação analisando logs, métricas, rastros distribuídos ou mensagens de erro, o DPO **não deve encontrar** as seguintes informações:

* **Conteúdo clínico integral** (diagnósticos, procedimentos, resultados, etc.).

* **Identificadores diretos de pacientes** (como CNS ou nome).

* **Segredos, tokens de acesso ou credenciais** de qualquer natureza.

A arquitetura exige que os componentes transversais de segurança da informação apliquem a minimização e mantenham esses dados estritamente fora dos repositórios de telemetria e das saídas de erro.
