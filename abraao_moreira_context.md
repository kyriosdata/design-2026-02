# Diagrama de contexto — Plataforma Estadual de Interoperabilidade em Saúde

## Propósito

Este diagrama representa o nível de contexto do modelo C4: mostra a plataforma como um sistema único, sem detalhar seus componentes internos, e delimita quem ou o que interage diretamente com ela.

## O sistema

Plataforma Estadual de Interoperabilidade em Saúde: conjunto de serviços que conecta sistemas participantes de uma UF por meio de recursos FHIR R4.

## Atores e sistemas externos

| Nome | Tipo | Papel |
| --- | --- | --- |
| Operador | Pessoa | Opera a plataforma diretamente |
| Aplicações Clínicas | Sistema externo | Produz e consome recursos e documentos FHIR (prontuários, portais de pacientes etc.) |
| Aplicações Administrativas | Sistema externo | Consulta indicadores e dados operacionais da plataforma |
| Outras Plataformas | Sistema externo | Instâncias estaduais de outras UFs, trocam RAC e IPS por contrato federado entre pares |
| RNDS | Sistema externo | Rede Nacional de Dados em Saúde — fonte e destino nacionais de documentos e registros |
| SISCAN | Sistema externo | Sistema nacional de informação do câncer, acessado por sua API nativa |
| ICP-Brasil | Sistema externo | Infraestrutura de Chaves Públicas Brasileira, emite e valida certificados digitais |

## Relações

- Operador opera a plataforma.
- Aplicações Clínicas envia e recebe recursos FHIR da plataforma via HTTPS / FHIR R4.
- Aplicações Administrativas consulta indicadores e dados operacionais da plataforma via HTTPS / FHIR R4.
- Plataforma troca RAC e IPS diretamente com Outras Plataformas por contrato federado entre pares.
- Plataforma publica e consulta documentos (RAC, IPS) na RNDS.
- Plataforma encaminha requisições e recebe laudos do SISCAN via REST / JSON nativo.
- ICP-Brasil emite certificados digitais para a plataforma e para as Aplicações Clínicas.

## Observações de escopo

O ICP-Brasil aparece como emissor de certificados tanto para a plataforma quanto para as Aplicações Clínicas porque a assinatura digital de documentos clínicos (por exemplo, o RAC) depende de certificados emitidos sob essa infraestrutura, conforme descrito no glossário da RNDS: https://rnds-guia.saude.gov.br/docs/glossario#icp-brasil

Esse diagrama não detalha contêineres internos como Gateway, Servidor FHIR, Serviço de Documentos RNDS, Montador de IPS ou Adaptador FHIR-SISCAN. Esse detalhamento fica para o próximo nível do C4, o diagrama de contêineres.
