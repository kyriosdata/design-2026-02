# Introdução, Visão Geral, Negócio e Requisitos da Plataforma

## 1. Visão Geral e Propósito da Plataforma
A **Plataforma Estadual de Interoperabilidade em Saúde** é uma infraestrutura de serviços de software em nível estadual projetada para integrar estabelecimentos de saúde (hospitais, postos de saúde, laboratórios e clínicas públicas ou privadas) que utilizam sistemas de prontuário heterogêneos.

* **O que a Plataforma faz:** Atua como uma camada intermediária de integração que recebe, valida, padroniza e compartilha informações clínicas entre diferentes estabelecimentos de saúde, municípios, a Rede Nacional de Dados em Saúde (RNDS) e outros estados parceiros.
* **O que ela NÃO é:** Não é um Prontuário Eletrônico (PEP), não substitui as telas onde o médico digita a consulta e não substitui os sistemas oficiais do DATASUS.
* **Objetivo Principal:** **Garantir a continuidade do cuidado ao paciente.** A plataforma assegura que, se um paciente for atendido em uma Unidade Básica de Saúde em um município e posteriormente precisar de atendimento em um hospital de outra cidade, seu histórico médico essencial estará disponível para os profissionais de saúde.
* **Uso Exclusivo de Dados Sintéticos:** A plataforma opera exclusivamente com dados simulados/sintéticos para validação de arquitetura, em total conformidade com as diretrizes da LGPD e garantindo privacidade absoluta.

---

## 2. O Problema de Negócio que a Plataforma Resolve
A plataforma responde ao desafio central da saúde pública e privada: **a fragmentação das informações clínicas**.

Atualmente, cada estabelecimento de saúde opera em "ilhas de informação", utilizando sistemas isolados que não se comunicam entre si. Esse cenário resulta em exames duplicados, desconhecimento de alergias graves por parte da equipe médica, atrasos diagnósticos e riscos em atendimentos de urgência. A plataforma resolve esse problema criando uma ponte e um contrato único de comunicação entre todos esses sistemas.

---

## 3. As Três Jornadas de Saúde Atendidas
A atuação e os serviços da plataforma são fundamentados em 3 cenários práticos e essenciais do ecossistema de saúde:

1. **Continuidade do Cuidado (RAC e IPS):**
   - **RAC (Registro de Atendimento Clínico):** Documento padronizado gerado a cada consulta ou atendimento individualizado.
   - **IPS (Sumário Internacional do Paciente):** Resumo clínico consolidado do paciente (alergias, medicamentos em uso e diagnósticos recentes), montado a partir de múltiplos atendimentos para consulta rápida e unificada.
2. **Rastreamento do Câncer do Colo do Útero (SISCAN):**
   - Intermedia a comunicação entre os postos de saúde (que solicitam os exames) e os laboratórios (que enviam os laudos), traduzindo essas informações para o sistema nacional do câncer (SISCAN).
3. **Interoperabilidade do Ciclo do Medicamento:**
   - Permite acompanhar e correlacionar as informações entre a receita médica (prescrição), a entrega do remédio na farmácia (dispensação) e a aplicação no paciente (administração), evitando erros ou duplicidades no tratamento.

---

## 4. Os Requisitos Essenciais da Plataforma
Os requisitos definem os comportamentos e as garantias fundamentais de funcionamento que a plataforma deve assegurar:

* **Padronização de Comunicação:** Toda troca de dados deve seguir o padrão internacional **HL7 FHIR R4**, garantindo que sistemas de diferentes fabricantes consigam interpretar as informações enviadas.
* **Segurança e Proteção de Dados (LGPD):** A plataforma centraliza o controle de acesso e autorização, proibindo estritamente a exposição de dados pessoais ou clínicos em logs e registros operacionais.
* **Rastreabilidade de Informações:** Capacidade de acompanhar o ciclo de vida e a trajetória de cada solicitação, identificando com precisão a origem e o destino do dado enviado.
* **Garantia de Não Duplicação (Idempotência):** Mecanismos para reconhecer reenvios de dados causados por oscilações na rede, impedindo que a ficha ou histórico do paciente seja duplicado.
* **Informação Temporária e Atualizada:** Sínteses e resumos clínicos (como o IPS) possuem tempo de retenção temporário, garantindo que o médico consulte sempre dados atualizados e sem acúmulo desnecessário de armazenamento.
