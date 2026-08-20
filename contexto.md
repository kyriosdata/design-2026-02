@startuml DiagramaContexto_PlataformaGO
!include https://raw.githubusercontent.com/plantuml-stdlib/C4-PlantUML/master/C4_Context.puml

LAYOUT_WITH_LEGEND()

title Diagrama de Contexto (C4) - Plataforma GO

Person(operador, "Operador", "Responsável por operar, configurar e monitorar a Plataforma GO")

System(plataformaGO, "Plataforma GO", "Serviços de interoperabilidade em saúde baseados em FHIR: gateway, validação, terminologia, documentos, medicamentos e apoio à decisão")

System_Ext(ac, "Aplicação Clínica (AC)", "Sistema cliente mínimo que produz/consome RAC, IPS e demais recursos clínicos FHIR")
System_Ext(aa, "Aplicação Administrativa (AA)", "Sistema cliente mínimo responsável por processos administrativos e de gestão ligados à plataforma")
System_Ext(siscan, "SISCAN", "Sistema nacional de informação do câncer; acessado via API nativa simulada, integrado por um adaptador FHIR")
System_Ext(rnds, "RNDS", "Rede Nacional de Dados em Saúde; recebe e disponibiliza documentos clínicos (simulada)")
System_Ext(outrasPlataformas, "Outras Plataformas Estaduais", "Instâncias de outras UFs que trocam dados diretamente com a Plataforma GO via contrato federado")

Rel(operador, plataformaGO, "Configura, monitora e audita")

Rel(ac, plataformaGO, "Envia e consulta recursos FHIR (RAC, IPS)")
Rel(plataformaGO, ac, "Notifica e retorna resultados")

Rel(aa, plataformaGO, "Envia e consulta dados administrativos")
Rel(plataformaGO, aa, "Retorna informações e status")

Rel(plataformaGO, siscan, "Troca requisições e laudos via Adaptador FHIR-SISCAN")
Rel(plataformaGO, rnds, "Publica e consulta documentos clínicos (RAC, IPS)")
Rel(plataformaGO, outrasPlataformas, "Troca federada direta de dados clínicos")

@enduml