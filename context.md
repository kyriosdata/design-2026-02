# Arquitetura: Plataforma Estadual de Interoperabilidade em Saúde

Este documento descreve o "diagrama de contexto.puml", um diagrama de Nível 1 construído sob o modelo C4. O objetivo é ilustrar de forma clara a visão de alto nível da Plataforma Estadual de Interoperabilidade em Saúde, mapeando suas interações com usuários e sistemas periféricos.

---

## 1. Personas (Usuários)
As personas representam os atores humanos que interagem com o ecossistema:
* **Pessoas (Atendidos, Profissionais, Gestores):** Atores que interagem diretamente com as aplicações clínicas e prontuários (PEPs) nos estabelecimentos de saúde.
* **Operador:** Pessoa ou equipe que atua como administrador do sistema, responsável por operar, fazer requisições e consultar a plataforma de interoperabilidade.

## 2. Sistema Principal
* **Plataforma Estadual de Interoperabilidade em Saúde:** É o núcleo da arquitetura. Trata-se de um conjunto de serviços executáveis (incluindo Gateway, Servidor FHIR, Montador IPS) responsável por integrar todos os sistemas participantes de uma Unidade Federativa (UF).

## 3. Sistemas Externos e Clientes
Sistemas que não fazem parte da construção principal da plataforma, mas são essenciais para a troca de dados:
* **Aplicações Clínicas / PEPs (Sistemas Clientes):** Hospitais e clínicas que produzem e consomem recursos/documentos FHIR a partir de eventos assistenciais.
* **Outras plataformas:** Instâncias de outras UFs (ou não) com as quais a plataforma estadual troca dados de saúde diretamente.
* **RNDS Simulada (Rede Nacional de Dados em Saúde):** Atua como fonte e destino a nível nacional para os documentos de saúde e registros, como RAC e IPS.
* **API SISCAN Simulada (Sistema de Informação do Câncer):** Sistema desenhado para receber integrações de solicitações e laudos via API REST e JSON nativo.
* **Aplicação Administrativa:** Ferramenta voltada para gestores (como o secretário da saúde) obterem e consultarem informações pertinentes à gestão do estado.

## 4. Relacionamentos e Fluxo de Dados
O mapeamento de como os componentes se comunicam entre si:
* As **Pessoas** utilizam as **Aplicações Clínicas** no dia a dia para registro e consulta clínica.
* As **Aplicações Clínicas** se comunicam com a **Plataforma** via protocolos FHIR / HTTP para enviar/receber recursos e acionar fluxos de interoperabilidade.
* O **Operador** interage com a **Plataforma** para administrá-la, fazendo requisições e consultas operacionais.
* Como distribuidora e consumidora, a **Plataforma** se conecta com os sistemas externos da seguinte forma:
    * Compartilha e troca informações de saúde com **Outras plataformas** utilizando um Contrato Federado.
    * Valida, publica e consulta documentos diretamente na **RNDS** por meio do padrão FHIR.
    * Traduz e envia as solicitações/laudos de exames ao **SISCAN** utilizando JSON nativo / REST.
    * Envia os dados pertinentes e estratégicos em direção à **Aplicação Administrativa** para apoiar a gestão estadual.