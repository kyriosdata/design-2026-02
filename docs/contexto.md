O Diagrama de Contexto (Nível 1 do C4 Model) mapeia a Plataforma de Interoperabilidade de Saúde, estabelecendo as fronteiras do sistema central em relação aos seus usuários e aos sistemas externos com os quais interage.

**Configurações Iniciais do Código**

* **Importação do C4 PlantUML:** A diretiva de inclusão carrega os estilos, paletas de cores e padronizações visuais do C4 Model no PlantUML.  
* **Legenda Automática:** A instrução de layout insere uma legenda no diagrama explicando o significado das cores de pessoas, sistemas internos e sistemas externos.  
* **Título:** Define a identificação visual posicionada no topo da imagem gerada.

**Atores e Pessoas (Person)**

* **Pessoa Atendida:** Representa os pacientes que consultam seu próprio histórico clínico e sínteses de atendimento por meio de aplicações externas.  
* **Profissionais de Saúde:** Agrupa médicos, enfermeiros, farmacêuticos e equipes de laboratório que alimentam o sistema com registros de atendimento e consultam o histórico dos pacientes.  
* **Gestores e Auditores:** Abrange secretarias de saúde, auditores e operadores responsáveis por monitorar a conformidade com a LGPD, analisar logs de observabilidade e acompanhar métricas operacionais.

**Sistema Central em Escopo (System)**

* **Plataforma de Interoperabilidade:** Representa o único sistema central sendo efetivamente desenvolvido no projeto. Funciona com base no padrão FHIR R4 e consolida internamente os serviços de autenticação via Gateway, validação, montagem efêmera de IPS, serviços RNDS e o adaptador para o SISCAN.

**Sistemas Externos (System\_Ext)**

* **Sistemas Clientes (PEPs):** Prontuários Eletrônicos e aplicações clínicas simuladas que geram os dados de atendimentos e solicitam sínteses de informações.  
* **RNDS Simulada:** Instância simulada da Rede Nacional de Dados em Saúde. Funciona como o repositório nacional oficial para armazenamento e consulta de documentos clínicos padronizados como RAC e IPS.  
* **API SISCAN Simulada:** Sistema Nacional de Informação do Câncer. Opera como uma aplicação externa que exige contrato de dados em formato JSON nativo.  
* **Plataforma Estadual Par:** Representa a infraestrutura de outra Unidade da Federação, permitindo a comunicação federada entre estados.

**Fluxos e Integrações (Rel)**

* **Interação Humana:** Pacientes e profissionais de saúde interagem diretamente com as interfaces dos PEPs. Gestores e auditores interagem diretamente com a Plataforma para obter dados de auditoria.  
* **Comunicação PEPs e Plataforma:** Os PEPs enviam eventos de atendimento e solicitam sínteses clínicas à Plataforma via protocolo HTTPS utilizando o padrão FHIR R4.  
* **Comunicação Plataforma e RNDS:** A Plataforma envia e recupera o ciclo de vida dos documentos clínicos na RNDS através de Web Services FHIR sobre HTTPS.  
* **Comunicação Plataforma e SISCAN:** A Plataforma utiliza seu componente adaptador interno para converter os dados FHIR e transmiti-los em JSON Nativo via HTTPS para a API do SISCAN.  
* **Comunicação Entre Estados:** A troca de informações com a Plataforma Estadual Par é realizada diretamente entre os gateways de origem e destino por meio de um contrato federado sobre HTTPS.

