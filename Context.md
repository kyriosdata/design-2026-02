md_content = """# Documentação do Diagrama de Contexto C4 - Plataforma GO

## 1. Visão Geral
A **Plataforma GO** atua como o ecossistema e barramento centralizador de dados de saúde no Estado de Goiás. Seu objetivo principal é garantir a interoperabilidade, a agregação de dados assistenciais e administrativos, e a integração contínua entre os sistemas locais de atendimento, os órgãos estaduais e as redes de informação governamentais de âmbito nacional.

O Diagrama de Contexto C4 (Nível 1) estabelece as fronteiras do sistema da **Plataforma GO**, delimitando quais partes interessadas (atores humanos), aplicações consumidoras e sistemas externos interagem diretamente com o núcleo da plataforma.

---

## 2. Tabela de Atores e Sistemas

A tabela abaixo descreve cada entidade representada no diagrama de contexto, detalhando a sua classificação, o seu papel funcional no ecossistema e o tipo de comunicação estabelecido com a Plataforma GO:

| Entidade / Sistema | Classificação | Cor / Destaque | Papel Funcional e Descrição Detalhada | Direção da Comunicação | Protocolo / Tecnologia |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Plataforma GO** | Sistema Central (Core) | Azul (`System`) | Plataforma estadual de saúde responsável por centralizar, processar, integrar e distribuir o ecossistema de dados de saúde pública do Estado de Goiás. Funciona como hub centralizador de interoperabilidade. | **Núcleo do Sistema** | REST / FHIR / SOAP / Web Services |
| **Operador** | Ator Humano (Suporte / TI) | Cinza (`Person_Ext`) | Profissional técnico responsável pela administração, parametrização, sustentação, monitoramento operacional de tráfego, gestão de falhas e auditoria de acessos da plataforma. | Bidirecional ($\leftrightarrow$) | HTTPS / Painel Web / CLI |
| **Aplicação Clínica** | Sistema Cliente / Consumidor | Cinza (`System_Ext`) | Sistemas de atendimento à saúde (Prontuários Eletrônicos - PEP, sistemas hospitalares, UBS). Alimenta a plataforma com dados assistenciais e consulta históricos clínicos unificados dos pacientes. | Bidirecional ($\leftrightarrow$) | HTTPS / REST / FHIR |
| **Aplicação Administrativa** | Sistema Cliente / Consumidor | Cinza (`System_Ext`) | Sistemas de gestão hospitalar/ambulatorial focados em faturamento, regulação de leitos/consultas, controle de estoque de insumos e cadastro operacional de unidades. | Bidirecional ($\leftrightarrow$) | HTTPS / REST |
| **SISCAN** | Sistema Externo (Nacional) | Cinza (`System_Ext`) | Sistema de Informação do Câncer do Ministério da Saúde. Fornece dados, exames e laudos oncológicos (mamografia, citopatológico, histopatológico) para compor a base unificada de Goiás. | Unidirecional (SISCAN $\rightarrow$ Plataforma GO) | REST / SOAP |
| **RNDS** | Sistema Externo (Nacional) | Cinza (`System_Ext`) | Rede Nacional de Dados em Saúde. Plataforma do Ministério da Saúde para troca nacional de informações clínicas (Registros de Imunização, Sumários de Alta, Exames Laboratoriais). | Bidirecional ($\leftrightarrow$) | REST / FHIR |
| **CNES** | Sistema Externo (Nacional) | Cinza (`System_Ext`) | Cadastro Nacional de Estabelecimentos de Saúde. Fonte oficial para consulta, validação e sincronização de cadastros de estabelecimentos de saúde, leitos e profissionais vinculados. | Bidirecional ($\leftrightarrow$) | Web Services / REST |
| **Plataformas Estaduais** | Sistemas Externos (Outras UFs) | Cinza (`System_Ext`) | Plataformas de saúde de outros estados federativos (ex: SP, MG, DF). Permitem a troca federada do histórico de atendimento de pacientes em trânsito interestadual. | Bidirecional ($\leftrightarrow$) | REST / FHIR |

---

## 3. Detalhamento do Fluxo de Integração

1. **Aplicações Locais (Clínica e Administrativa):**
   - As **Aplicações Clínicas** enviam boletins de atendimento, prontuários e registros de imunização/consultas e consultam a linha de cuidado unificada do paciente na **Plataforma GO**.
   - As **Aplicações Administrativas** enviam relatórios de produtividade, dados de regulação e solicitações de faturamento, recebendo confirmações de sincronização e relatórios consolidados.

2. **Operação e Monitoramento:**
   - O **Operador** acessa dashboards de telemetria, logs de integração, status das filas de mensagens e interfaces de parametrização de regras de negócio.

3. **Interoperabilidade com Governo Federal e Outros Estados:**
   - **SISCAN $\rightarrow$ Plataforma GO:** Fluxo unidirecional de entrada onde laudos de exames oncológicos realizados via rede do Ministério da Saúde são importados para enriquecer o histórico do paciente na Plataforma GO.
   - **RNDS $\leftrightarrow$ Plataforma GO:** Troca contínua em padrão FHIR onde registros gerados em Goiás são replicados na rede nacional e vice-versa.
   - **CNES $\leftrightarrow$ Plataforma GO:** Validação de credenciais de profissionais de saúde e situação cadastral de estabelecimentos para autorização de transações.
   - **Plataformas Estaduais $\leftrightarrow$ Plataforma GO:** Intercâmbio sob demanda de dados clínicos de pacientes que receberam atendimento fora do estado de Goiás.

---

## 4. Código PlantUML do Diagrama (C4 Context - Nível 1)

```plantuml
@startuml C4_Context_Plataforma_GO
!include [https://raw.githubusercontent.com/plantuml-stdlib/C4-PlantUML/master/C4_Context.puml](https://raw.githubusercontent.com/plantuml-stdlib/C4-PlantUML/master/C4_Context.puml)

LAYOUT_WITH_LEGEND()

title Diagrama de Contexto C4 - Plataforma GO

' Sistema Central (Único em Azul)
System(plataformaGO, "Plataforma GO", "Plataforma estadual de saúde responsável pela centralização, integração e ecossistema de dados do Estado de Goiás.")

' Atores e Aplicações Internas/Clientes (Em Cinza - Ext)
Person_Ext(operador, "Operador", "Profissional de TI/Suporte responsável pelo monitoramento e gestão da plataforma.")
System_Ext(appClinica, "Aplicação Clínica", "Sistema de atendimento e registro assistencial (prontuários, diagnósticos e prescrições).")
System_Ext(appAdmin, "Aplicação Administrativa", "Sistema para gestão operacional, faturamento e regulação de estabelecimentos de saúde.")

' Sistemas Externos (Em Cinza - Ext)
System_Ext(siscan, "SISCAN", "Sistema de Informação do Câncer (Ministério da Saúde).")
System_Ext(rnds, "RNDS", "Rede Nacional de Dados em Saúde (Interoperabilidade Nacional).")
System_Ext(cnes, "CNES", "Cadastro Nacional de Estabelecimentos de Saúde.")
System_Ext(outrasPlataformas, "Plataformas Estaduais (Outros Estados)", "Sistemas de saúde de outras unidades federativas para intercâmbio de dados de pacientes.")

' Relacionamentos Bidirecionais
BiRel(operador, plataformaGO, "Opera, parametriza, monitora e troca dados", "HTTPS / Painel Web")
BiRel(appClinica, plataformaGO, "Envia e consulta prontuários e dados assistenciais", "HTTPS / REST / FHIR")
BiRel(appAdmin, plataformaGO, "Envia e consulta dados operacionais e administrativos", "HTTPS / REST")
BiRel(plataformaGO, outrasPlataformas, "Intercambia histórico de saúde de pacientes transitórios", "REST / FHIR")
BiRel(plataformaGO, rnds, "Transmite e recebe registros de saúde e imunização", "REST / FHIR")
BiRel(plataformaGO, cnes, "Sincroniza e valida cadastro de profissionais e estabelecimentos", "Web Services / REST")

' Relacionamento Unidirecional (SISCAN -> Plataforma GO)
Rel(siscan, plataformaGO, "Envia dados de exames e laudos oncológicos", "REST / SOAP")

@enduml
