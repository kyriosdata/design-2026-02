# Plataforma Estadual de Interoperabilidade em Saúde: Limitações de Integração Privada

## Contexto da Plataforma
A proposta do sistema envolve o projeto, prototipagem, integração e avaliação de partes de uma plataforma estadual de interoperabilidade em saúde. Ela é baseada no padrão HL7 Fast Healthcare Interoperability Resources (FHIR). O objetivo principal é educacional, focado no aprendizado contínuo em Design de Software, lidando com restrições e contratos reais como Registro de Atendimento Clínico (RAC), Sumário Internacional do Paciente (IPS) e SISCAN. O sistema foca nos **serviços de interoperabilidade** entre sistemas participantes (gateways, adaptadores, validação, terminologia), em vez de focar nas aplicações clínicas de origem (prontuários).

## Por que não integra ainda com empresas privadas?
A arquitetura de segurança, autorização e identidade é uma capacidade transversal essencial para essa plataforma de interoperabilidade. No entanto, existe uma limitação técnica e estrutural no momento em relação à adoção da infraestrutura de autenticação centralizada nacional para entes privados.

### 1. Exclusividade do Login Único para o Setor Público
Apesar de uma primeira leitura da documentação e de propostas sugerir a viabilidade de uma integração ampla, pesquisas mais aprofundadas demonstraram que a infraestrutura do **login único (gov.br) é, atualmente, exclusiva para serviços e órgãos públicos**. Os serviços de integração de identidade digital do governo federal são disponibilizados estritamente para o ecossistema governamental para garantir o acesso a plataformas como o ConecteSUS e outras ferramentas estatais.

### 2. Fase de Testes para o Setor Privado
A expansão do login único para validação de identidade em empresas e serviços privados não é uma realidade consolidada em produção. Essa funcionalidade ainda **está em testes e não foi disponibilizada oficialmente para o mercado**. Iniciativas de autenticação pelo gov.br em serviços privados, bem como a definição de formas para compartilhar dados do cidadão com o setor privado, estão em fases de prova de conceito e regulamentação.

Consequentemente, integrar empresas privadas a uma plataforma que depende dessa infraestrutura de identidade unificada esbarra na falta de disponibilidade do serviço. Para o escopo deste trabalho (que possui finalidade educacional e usa contratos controlados e simuladores), assumir a integração com sistemas reais e privados violaria as restrições atuais do serviço de login único nacional.

## A Perspectiva do Domain-Driven Design (DDD)
Esta limitação de integração é um excelente exemplo prático das forças que moldam o design de software moderno. Lidar com sistemas complexos e mal compreendidos exige o estabelecimento de uma **Linguagem Ubíqua (Ubiquitous Language)** [cite: 1]. Desenvolvedores e especialistas de domínio devem conversar na mesma linguagem para deixar explícito que os "Sistemas Externos" (no nosso modelo) não englobam serviços de empresas privadas, devido a restrições contratuais e de autenticação [cite: 1].

Segundo Eric Evans na obra *Eric Evans 2003 - Domain-Driven Design - Tackling Complexity in the Heart of Software.pdf*, um modelo de domínio precisa abstrair os aspectos irrelevantes e se concentrar naqueles que resolvem o problema atual [cite: 1]. Como a integração privada exigiria contornar as limitações do login único governamental (talvez desenvolvendo um serviço de identidade paralelo enorme e complexo), excluir essa integração do nosso *Bounded Context* (Contexto Delimitado) no momento mantém a integridade do modelo [cite: 1]. Refletir essas limitações regulatórias diretamente na arquitetura e nos contratos dos Gateway da plataforma evita o acúmulo de débito técnico e falsas expectativas sobre o alcance da interoperabilidade atual.

## Conclusão
A integração de empresas privadas à plataforma aguarda a evolução e liberação dos serviços federais de autenticação. Até que as APIs do governo federal permitam oficialmente o uso do login único por aplicações privadas de saúde com a devida segurança e base legal (LGPD), a solução arquitetural correta é desenhar as fronteiras do sistema assumindo apenas a integração com o setor público ou utilizando ambientes estritamente sintéticos/simulados para fins educacionais e de design.
