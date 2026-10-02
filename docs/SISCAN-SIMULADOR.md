O simulador do SISCAN (SISCAN *fake*) deve atuar como uma réplica contratual estrita da API oficial publicada pelo DATASUS. O objetivo não é reinventar a API a partir de telas, mas sim fornecer uma superfície REST oficial com dados sintéticos para experimentação, permitindo que o Adaptador de Interoperabilidade FHIR-SISCAN converta os recursos FHIR para o JSON nativo do SISCAN.

Abaixo está a descrição da arquitetura e dos componentes deste simulador mínimo:

### 1. Autenticação e Segurança (Mock do Keycloak)

A API real utiliza o fluxo `client_credentials` do OAuth 2.0 no Keycloak. O simulador deve prover:

* **Endpoint Emulado:** Um equivalente local da rota `POST /realms/portal-servicos/protocol/openid-connect/token`.


* **Parâmetros de Entrada:** Deve aceitar o cabeçalho `Content-Type: application/x-www-form-urlencoded` com os parâmetros `grant_type=client_credentials`, `client_id` e `client_secret`.


* **Retorno:** O simulador emitirá um token JWT educacional/fictício.


* **Validação de Acesso:** Todas as demais rotas da API deverão exigir esse token validado por meio do cabeçalho `Authorization: Bearer <token>`. Os segredos e tokens devem ser puramente sintéticos e nunca devem aparecer em logs.



### 2. Superfície REST: API de Escrita (Emulação do Swagger 1)

O simulador deve reproduzir os endpoints para requisições e laudos de exames citopatológicos e histopatológicos, mantendo nomes, tipos, obrigatoriedade e cardinalidade dos DTOs definidos na especificação OpenAPI.

* **Rotas de Requisição:** Suporte a `POST`, `PUT` e `DELETE` nas rotas `/api/v1/requisicao-exame/citopatologico-colo-utero` e `/api/v1/requisicao-exame/histopatologico-colo-utero`. A alteração e a exclusão exigirão o `{protocolo}`.


* **Rotas de Resultado:** Suporte a `POST`, `PUT` e `DELETE` nas rotas `/api/v1/resultado-exame/citopatologico-colo-utero` e `/api/v1/resultado-exame/histopatologico-colo-utero`.


* **Resposta Imediata:** Ao receber um `POST` com um DTO válido, o simulador responderá com código HTTP 201 (Created), retornando um payload contendo o `codigoProcesso`.



### 3. Superfície REST: API de Consulta (Emulação do Swagger 2)

A API de consulta permitirá o acompanhamento técnico e a leitura da jornada.

* **Consulta de Processamento:** A rota `GET /api/v1/processamento/requisicao-exame/{codigo}` retornará o status técnico da integração: 1 (processando), 2 (processado com sucesso) ou 3 (processado com erro). Em caso de sucesso, fornecerá o `numeroProtocolo`.


* **Consulta da Jornada Clínica:** As rotas `GET /api/v1/requisicao-exame/{protocolo}` e `GET /api/v1/requisicao-exame/{protocolo}/resultado-exame` exporão o conteúdo e o histórico clínico da requisição e do laudo.


* **Validação Cadastral:** O simulador proverá consultas para validar estabelecimentos, profissionais por CNS/CNES/CBO, e vínculos (entre prestador, unidade requisitante e terceiros) para os exames.



### 4. Fluxo Assíncrono e Retorno (Callback)

A integração segue um fluxo de quatro passos: gerar token, enviar requisição, consultar status e receber resultado via callback.

* Quando o DTO nativo possuir a URL de retorno no campo `callBackUrl`, o simulador deverá executar o retorno assíncrono para esta URL HTTPS educacional.


* Essa funcionalidade deve permitir testar cenários de resiliência, como atrasos, envios duplicados e indisponibilidade do endpoint receptor.



### 5. Regras de Negócio e Validações Cadastrais

O simulador validará as regras de negócio operacionais para não corromper o estado clínico sintético:

* **Habilitação de Profissionais:** O sistema deve verificar o CNS e o CBO do profissional em relação ao CNES (ex: CBOs 2231F8, 223505 para coleta citopatológica).


* **Vínculos de Serviço:** Replicará a exigência de vinculação contratual e financiamento, bloqueando fluxos onde a unidade requisitante não possui vínculo com o prestador de serviço para o exame específico.


* **Inconsistências:** Dados inválidos (como formato de CNS, CNES ausente) ou erros de transição de estado resultarão em códigos de falha adequados (como 400, 422 ou 404), garantindo o comportamento documentado no manual.


### Proposta Preliminar de Uso: Jornada de Integração na Plataforma

A proposta preliminar para o uso do simulador (SISCAN fake) é posicioná-lo como um sistema de software externo na arquitetura C4 da plataforma, com a responsabilidade exclusiva de prover a superfície REST nativa para o Adaptador de Interoperabilidade FHIR-SISCAN. O simulador não interage diretamente com os sistemas clínicos clientes nem consome recursos FHIR; em vez disso, ele atua como o destino final do adaptador, recebendo e devolvendo os DTOs JSON previstos no contrato oficial.   

Abaixo está o detalhamento técnico e de fluxo de como essa integração deve ocorrer por meio da Jornada do Adaptador FHIR-SISCAN:

### 1. Contrato nativo emulado pelo SISCAN fake

* O simulador é acessado exclusivamente pelo adaptador FHIR-SISCAN e deve reproduzir fielmente o contrato externo do DATASUS.


* A fonte de verdade é a cópia versionada do Manual de Integração v3.0 e das especificações OpenAPI de escrita e consulta (versão 1.0).


* O simulador exigirá o uso do cabeçalho `Authorization: Bearer <token>` e utilizará credenciais puramente sintéticas.


* Ele deve preservar a estrutura exata dos DTOs oficiais, bem como reproduzir os códigos HTTP adequados para cada operação, como `201 Created` para aceitação, além de lidar com os erros documentados (`400`, `401`, `403`, `404`, `422`, `500`).


* Em respostas bem-sucedidas de criação, o simulador deve devolver um `codigoProcesso`.


* O processamento técnico pode ser acompanhado periodicamente ou por um retorno assíncrono (callback) executado pelo simulador contra a URL educacional do adaptador.



### 2. A Fachada FHIR para os Sistemas Clientes

* Os sistemas clientes (como os Prontuários Eletrônicos de Pacientes - PEPs) acessam o adaptador por meio do Gateway.


* O adaptador expõe um contrato educacional baseado no padrão FHIR R4 com URLs próprias, como `POST /siscan-fhir/requests` para solicitar exames e `POST /siscan-fhir/results` para submeter laudos.


* A fachada valida o envelope FHIR e devolve `202 Accepted` indicando a integração assíncrona.


* Erros capturados na comunicação com o SISCAN *fake* (ou validações FHIR reprovadas) são traduzidos e devolvidos ao sistema cliente em formato `OperationOutcome`.



### 3. O Fluxo Mínimo de Integração

* Uma unidade de saúde gera um recurso `ServiceRequest` para o rastreamento ou investigação.


* O Gateway da plataforma autentica o cliente, enquanto o adaptador obtém o token sintético para se comunicar com a API do SISCAN simulado.


* O adaptador valida o recurso FHIR, converte a solicitação clínica para o DTO nativo esperado pelo SISCAN e realiza um POST no simulador.


* O SISCAN *fake* devolve o `codigoProcesso`, permitindo ao adaptador acompanhar se a integração obteve sucesso ou falhou.


* Após o sucesso, o adaptador obtém o protocolo único do SISCAN e o associa ao recurso `ServiceRequest` e à `Task` do fluxo clínico.


* Posteriormente, o laboratório/prestador executa o exame, gera resultados preliminares (`Observation`) e um laudo final (`DiagnosticReport`), que são convertidos e enviados à rota nativa de resultados do simulador.



### 4. A Separação de Estados (Técnico vs. Clínico)

* O adaptador mantém o ciclo de vida técnico totalmente independente do ciclo de vida clínico.


* **Estado Técnico:** Controlado pelo `codigoProcesso` devolvido pelo simulador. Possui os estados `1 processando`, `2 concluído` e `3 falhou`. Falhas neste estágio geram diagnósticos técnicos, pois o exame sequer foi aceito.


* **Estado Clínico:** Identificado pelo protocolo SISCAN, em conjunto com o `ServiceRequest.identifier` e `Task.identifier`. Acompanha a execução do exame com os estados `solicitado`, `em execução`, `concluído` ou `cancelado`.



### 5. Mapeamento Principal de Dados

* Uma requisição no SISCAN corresponde a um `ServiceRequest` no FHIR.


* O protocolo único gerado pelo SISCAN reflete os identificadores do `ServiceRequest` e da `Task`.


* O material biológico coletado equivale ao recurso `Specimen`.


* Os laudos preliminares e finais são geridos pelas transições de estado do recurso `DiagnosticReport` (ex: `preliminary` e `final`).


* As regras do manual referentes a correções e autoria não vazam para o simulador como conceitos de tela (como "destravar"), sendo mapeadas formalmente como novas versões clínicas e proveniência sistêmica através dos recursos `Provenance` e `AuditEvent`.

### Referencias

A documentação completa da API (especificações OpenAPI 3.0), que servirá de base para a criação do SISCAN Fake, encontra-se dividida em duas frentes de homologação e uma página geral de serviço:

1.  A especificação da API de escrita está localizada no link: https://www.inca.gov.br/publicacoes/manuais/manual-do-sistema-de-informacao-do-cancer-siscan-modulos-1-2-3-e-4

2. A página do serviço da API SISCAN no Portal de Serviços do DATASUS pode ser acessada em: https://portalservicos-datasus.saude.gov.br/portfolio/EMZN1nuCWB


