# Plataforma Estadual de Interoperabilidade em Saúde (Estratégia Prática de Design de Software)

> **Carga Horária:** 128 horas (sala 105, Centro de Aulas Aroeira)  
> **Domínio Mobilizador:** Interoperabilidade em Saúde  
> **Padronização Base:** FHIR R4 (`4.0.1`)  
> **Status:** Documento em evolução

---

## 📌 Sobre o Projeto

Este repositório contém a infraestrutura e os serviços de uma **plataforma estadual de interoperabilidade em saúde**, desenvolvida como trabalho prático contínuo para a disciplina de **Design de Software**.

O objetivo central do projeto é o **aprendizado contínuo em Design de Software** explorando problemas reais de integração distribuída, tais como: definição de fronteiras, modelos de consistência, concorrência, idempotência, resiliência a falhas, evolução de contratos e atributos de qualidade.

> **⚠️ Aviso Importante / Finalidade Educacional:**  
> Este projeto **não** pretende reproduzir ou substituir a RNDS oficial, substituir sistemas de saúde de produção ou processar dados reais de pacientes. Sistemas externos nacionais e outras UFs são representados por simuladores e contratos controlados; **todos os dados utilizados são estritamente sintéticos**.

---

## 🎯 Escopo e Foco do Sistema

O foco deste repositório está exclusivamente nos **serviços de interoperabilidade** que conectam sistemas participantes. Prontuários Eletrônicos (PEPs), portais de pacientes e sistemas departamentais de origem/destino **não** são o objeto de desenvolvimento principal e são representados apenas por clientes/simuladores mínimos.

### Jornadas Clínicas Cobertas
1. **Continuidade do Cuidado:** Compartilhamento seguro de Registros de Atendimento Clínico (RAC) por atendimento e montagem/troca federada de Sumários Internacionais do Paciente (IPS).
2. **Rastreamento do Câncer do Colo do Útero:** Integração com o SISCAN por meio de um **Adaptador FHIR-SISCAN** que oferece uma fachada FHIR sobre a API nativa REST/JSON do governo.
3. **Ciclo do Medicamento:** Troca, correlação e notificação dos atos de prescrição, dispensação e administração de medicamentos entre diferentes prestadores.

---

## 🛠️ Arquitetura e Principais Componentes (C4 Level 2)

A solução é composta por contêineres e serviços especializados que garantem a integração entre os sistemas:

* **Gateway de Integração:** Ponto de entrada que realiza autenticação, autorização, aplicação de limites (*rate limiting*) e roteamento de requisições.
* **Servidor FHIR R4:** Mantém o estado clínico sintético compartilhado para consultas e persistência.
* **Serviço de Documentos RNDS:** Gerencia a validação, publicação e reconciliação do ciclo de vida técnico de documentos (como RAC e IPS) na RNDS simulada.
* **Montador Efêmero de IPS:** Consolida e valida fatos clínicos de múltiplas fontes (RACs, laudos, medicamentos) para gerar um documento IPS com proveniência explícita e retenção efêmera (TTL de 60 min).
* **Adaptador de Interoperabilidade FHIR-SISCAN:** Fachada que traduz recursos FHIR (`ServiceRequest`, `DiagnosticReport`) em DTOs nativos para comunicação com a API SISCAN simulada.
* **Serviço de Interoperabilidade de Medicamentos:** Valida, mapeia e correlaciona prescrições, dispensações e administrações mantendo isolamento semântico dos atos.
* **Capacidades Transversais:** Validação de perfis/terminologias, validação de assinaturas digitais, mensageria via `Subscription` (FHIR R4), apoio à decisão síncrono com `CDS Hooks` e cálculo de indicadores com `CQL` (`Library`/`Measure`).

---

## 📂 Linhas de Base Técnicas Fixadas

Para garantir a reprodutibilidade dos experimentos, os artefatos de entrada foram fixados e versionados localmente:

| Domínio | Especificação / Pacote | Versão Fixada |
| :--- | :--- | :--- |
| **Padrão Base** | FHIR R4 | `4.0.1` |
| **RAC** | Modelo de Informação e Manual RNDS | `v2.0` |
| **IPS Brasil** | Pacote FHIR (`br.gov.saude.ips.fhir`) | `1.0.0 - STU1` (`package.tgz`) |
| **Medicamentos** | Pacotes REPM / REDFM da RNDS | `REDFM 1.0` / Pacotes combinados |
| **SISCAN** | Manual de Integração e Especificações OpenAPI | Manual `v3.0` / OpenAPI `v1.0` |

---

## 🚀 Estrutura de Incrementos de Implementação

O projeto está organizado para ser construído em 4 incrementos verticais:

[ Incremento 1 ] ──► Publicar RAC na RNDS simulada (Gateway + Validação + RNDS)
[ Incremento 2 ] ──► Integrar SISCAN via Adaptador FHIR (Requisição + Processamento + Laudo)
[ Incremento 3 ] ──► Registrar e Correlacionar Ciclo de Medicamentos
[ Incremento 4 ] ──► Montar IPS efêmero, Troca Interestadual Federada, Medidas CQL e CDS Hooks


---

## 📋 Pré-requisitos para Execução

* **Ambiente de Desenvolvimento:** Definido conforme a pilha adotada pela turma/equipe.
* **Dados:** Utilizar **apenas dados sintéticos** disponibilizados nas massas de testes do repositório.
* **Pacotes FHIR/OpenAPI:** Garantir que os pacotes locais armazenados nas pastas de artefatos do repositório sejam carregados pelo validador local.

---

## 🤝 Diretrizes de Contribuição e Governança

1. **Decisões Registradas (ADR):** Qualquer mudança arquitetural ou escolha de alternativa relevante deve ser documentada via *Architecture Decision Record* (`ADR`).
2. **Contratos Primeiro:** Toda alteração de interface deve atualizar previamente as especificações OpenAPI ou Perfis FHIR correspondentes.
3. **Idempotência e Erros:** Todas as operações de escrita devem aceitar chaves de idempotência e retornar falhas semanticamente mapeadas via `OperationOutcome` ou DTOs oficiais.
4. **Privacidade e Logs:** É estritamente proibido gravar identificadores pessoais reais ou conteúdo clínico em logs, rastros e métricas de telemetria.

---

## 📄 Referências Normativas e Técnicas

* [Ementa da Disciplina e Materiais de Apoio](ementa.md)
* [Portal de Serviços DATASUS - RAC v2.0](https://portalservicos-datasus.saude.gov.br/servico/thZjxKwS4u)
* [HL7 Brasil - Guia do IPS Brasil STU1](https://hl7.org.br/fhir/ips/)
* [Portal de Serviços DATASUS - REDFM / REPM](https://portalservicos-datasus.saude.gov.br/servico/BBgfSNopOs)
* [Portal de Serviços DATASUS - API SISCAN](https://portalservicos-datasus.saude.gov.br/servico/EMZN1nuCWB)
