@startuml
!include https://raw.githubusercontent.com/plantuml-stdlib/C4-PlantUML/master/C4_Context.puml

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
