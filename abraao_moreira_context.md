# Diagrama de contexto — Plataforma Estadual de Interoperabilidade em Saúde
[DIAGRAMA LINK](https://editor.plantuml.com/uml/dLKzRnD14EtpAvPKZaJY9X8ILSp54AFWMBOZH6MDzzR9IdUxntwOGCMFu0y0HIfAchJ-9_mItknTuZiIWaHttfcTz-RDc_MH3-H2B0kH7IuoQuAw2ej9GO5MrfMq6E74sKevMkf2vvIhdIVQo2BcIbo6KFdd_RwZ3mSNEbp6PVJAIIvYme6qPRygo73nVH_oGY_xsU7-X8_EtvpsI_8etT_27bJ8t3aTl3ixdo_UZkOdYzFXg-7ukBUt4tGeb3ZMTE6e907iveuLlpv_4Lk-OeX-yaW5vzpdBbGfPhIvGHSJvRmrlHJEhNigTi-QpztMjyX9L7VLT_TsPX_1kknjpv3y7_2CWHQK32IyvfBaHOL9QAah2AGyLuYeUFvILE1HActv20AlzURQfhY-Zx0ahq3SCzJ9wJFnycGqlQEz65w5dYoqqP8y60og0b-RwyrFu6N5vaSACBVPBITagqJdVLIYSZQFdr1P2KpPsnAVJia89G4eSYjZYMpyO5ZHGpx6l_dgj0KSsWYa4_6AP5DM1NcmroL8UGc6FZWAUdsVvw0R_ZjRfXYBG2Lqod4VurI9Pj8doIQrDOdIWrDER6m4abzimqpeB1ssV9TeZ8mFcsz6QeHKROIwtRe6HbaJ2yvAiAfvvDefS6JQQT2yFcZDYfNAamS5Geub0_ikDMTo9ZCT7yyOVeeBObptb0nuV6k4sdDfLLQyDom226fZXTbgq1cWmc0lM6Nx1oZSAicmwADPDXYtvB-jLTJMJBfWPj_XMoia2wEmPYILzzmMD-iZYS5aX9iyoowGbjLY2TbqmT9ca_qNwKSjzCeH6d0nH5S_1vUqnd0dcvibMyMBEbbfXBbjLUhKzffuJmIO1BrAdk09uF620e2VggBr8dIMFBq8JSfsXJefGxFMb9IJQgcscv5s4F6J-Nmo4_rwEQQ7JR5xTk_Kp1eJ_zF3VmTertlGpNFsevWECXGUeK3BaiqxzQWZ_yHeR3c9QHHYkuWjVoM_3hAdZFT0YJkJ3GqsHPjBWfhle_QwUGJkH2uevasvuMoEtb_FpiQrdvBl6fVM46rBTIUNxF6OAzfNMo_eunUFbCdnd_OR)

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
