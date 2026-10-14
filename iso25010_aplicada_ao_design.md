# Qualidade de software, produtividade e direcionadores de design

## Objetivo

Avaliar como a ISO/IEC 25010:2023 pode orientar o design da solução antes da implementação, considerando qualidade de software, produtividade da equipe e os elementos necessários para que o software seja construído de forma mais consistente, verificável e sustentável.

## Síntese

A ISO/IEC 25010:2023 é adequada para este projeto porque permite avaliar a qualidade do produto de software ainda na fase de design. A norma organiza a qualidade em nove características: adequação funcional, eficiência de desempenho, compatibilidade, capacidade de interação, confiabilidade, segurança, manutenibilidade, flexibilidade e *safety*.

O uso da norma nesta etapa ajuda a transformar preocupações genéricas, como “o sistema deve ser rápido, seguro e confiável”, em requisitos de qualidade mais objetivos e verificáveis. Isso permite que decisões arquiteturais sejam tomadas antes da implementação e que cada decisão possa ser relacionada a requisitos, riscos, contratos, testes e evidências.

## Produtividade

A adoção da ISO/IEC 25010:2023 pode contribuir para a produtividade principalmente pela redução de retrabalho. Ao explicitar requisitos de qualidade e critérios de aceitação antes do desenvolvimento, diminui-se a probabilidade de os programadores precisarem decidir, durante a implementação, aspectos que deveriam ter sido resolvidos no design.

O ganho de produtividade esperado está relacionado a:

- redução de ambiguidades nos requisitos;
- menor número de decisões arquiteturais tomadas de forma isolada durante a programação;
- redução de retrabalho causado por requisitos descobertos tardiamente;
- melhor priorização de protótipos e experimentos;
- maior paralelismo entre integrantes da equipe;
- critérios mais objetivos para revisão de arquitetura e código;
- melhor transição entre a fase de design e a fase de desenvolvimento.

A norma não deve ser usada como mecanismo burocrático ou como obrigação de produzir documentos para todas as subcaracterísticas. O recomendado é identificar o que é aplicável ao projeto, justificar o que não se aplica e criar evidências apenas para os atributos de qualidade relevantes.

## Elementos de design a serem considerados

Para que o software possa ser construído futuramente com maior qualidade, o design deve consolidar os seguintes elementos:

1. requisitos funcionais e requisitos arquiteturalmente significativos identificados;
2. características e subcaracterísticas da ISO/IEC 25010:2023 aplicáveis ao projeto;
3. cenários de qualidade com critérios mensuráveis;
4. matriz de rastreabilidade entre requisito, decisão, componente, contrato, verificação e evidência;
5. decisões arquiteturais registradas em ADRs;
6. contratos e interfaces versionados;
7. critérios de desempenho, capacidade e escalabilidade;
8. requisitos de confiabilidade, disponibilidade, tolerância a falhas e recuperação;
9. modelo de ameaças e arquitetura de segurança;
10. análise de perigos clínicos e comportamento *fail-safe* para componentes com impacto potencial na assistência;
11. estratégia de observabilidade, auditoria e rastreabilidade;
12. protótipos orientados à redução de riscos arquiteturais;
13. plano de verificação da arquitetura e critérios de aceite;
14. baseline versionada dos padrões e artefatos externos utilizados.

## Encaminhamento

A recomendação é utilizar a ISO/IEC 25010:2023 como referência transversal para revisar e complementar os artefatos de design já existentes. O objetivo não é “certificar” o projeto nesta etapa, mas garantir que os atributos de qualidade relevantes sejam identificados antes da implementação.

Como resultado esperado, o projeto deverá possuir uma cadeia de rastreabilidade semelhante a:

**necessidade → requisito → característica de qualidade → decisão arquitetural → contrato → verificação → evidência**

Essa abordagem tende a melhorar a qualidade das decisões, reduzir retrabalho durante a implementação e aumentar a produtividade da equipe ao fornecer aos programadores uma arquitetura mais clara, consistente e verificável.
