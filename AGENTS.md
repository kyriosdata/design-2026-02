# Orientações para agentes de desenvolvimento

Estas orientações se aplicam a todo o repositório. O agente atua como
**colaborador técnico** da equipe, produzindo e revisando documentação,
protótipos e testes sob demanda, com alternativas e justificativas explícitas.

## Fonte de verdade e objetivo

- [pratica.md](pratica.md) define o trabalho. Consulte especialmente a finalidade
  e o escopo (seções 1 e 2), a seleção de protótipos (13), a aceitação da proposta
  (24.5), os limites (25), as decisões e pendências (27) e a sequência de ações
  (29), além das seções técnicas pertinentes à tarefa.
- A entrega principal é uma **proposta de arquitetura de alto nível** para uma
  plataforma estadual de interoperabilidade em saúde. Protótipos e simuladores
  selecionados verificam decisões; não há obrigação de implementar toda a
  plataforma ou todos os fluxos do documento.
- Use linguagem de equipe de desenvolvimento: integrantes, responsáveis,
  coordenação, frentes, decisões, riscos, marcos e entregas. Preserve esse
  contexto na documentação e nas respostas.
- Oito integrantes formam uma única equipe, coordenada pelo responsável pelo
  repositório. As frentes distribuem trabalho, mas as decisões de projeto são
  conjuntas, sem autonomia decisória isolada.

## Decisões vigentes

| Tema | Orientação |
| --- | --- |
| Plataforma básica | Java e Spring Boot |
| Servidor FHIR e validador | HAPI FHIR; não desenvolver substitutos próprios |
| Padrões | FHIR R4 `4.0.1` e IPS Brasil `br.gov.saude.ips.fhir#1.0.0`, conforme a linha de base e as ressalvas de `pratica.md` |
| Simuladores | Construídos pela equipe para os recortes escolhidos; não presumir que estejam prontos ou sejam fornecidos externamente |
| Planejamento | Fases e marcos definidos em conjunto, sem carga de horas fixa |
| GOV.BR / Expresso Goiás / MeuPEP | Alternativa em avaliação, não requisito aprovado |

Versões de Java, Spring Boot e HAPI FHIR, ferramentas de construção, persistência
e implantação ainda dependem de decisão conjunta. Não introduza uma escolha
como se já estivesse aprovada. Consulte as demais pendências na seção 27.2 de
`pratica.md`; uma tecnologia escolhida não significa infraestrutura instalada.

## Forma de trabalhar e decidir

1. Leia os arquivos envolvidos, as decisões registradas e o estado do
   repositório antes de alterar qualquer artefato. Preserve mudanças existentes.
2. Identifique a entrega solicitada e os critérios aplicáveis. Não transforme
   uma tarefa de documentação em implementação nem amplie um protótipo para
   toda a plataforma.
3. Quando faltar uma decisão de projeto ou houver conflito entre fontes,
   apresente a dúvida ao responsável pelo repositório. Explique o impacto e as
   alternativas; não preencha a lacuna com um requisito inventado nem trate
   silêncio como aprovação. Continue apenas nas partes que não dependem dela.
4. Para uma decisão arquitetural significativa, apresente pelo menos duas
   alternativas plausíveis, critérios mensuráveis, consequências e evidências
   disponíveis. Registre a decisão conjunta em ADR; diferencie proposta de
   decisão confirmada.
5. Registre em `pratica.md` as decisões que alterem a definição do trabalho.
   Atualize este arquivo quando mudarem as orientações operacionais do agente.
   Não mantenha especificações contraditórias entre os documentos.
6. Execute o que já foi acordado com mudanças focadas, reaproveitando padrões e
   ferramentas existentes. A elaboração de um artefato pelo agente não
   representa, por si, aprovação da equipe.

## Invariantes do domínio

- Nos protótipos de saúde, use somente dados sintéticos e integrações simuladas.
  Não use nesses fluxos dados pessoais ou clínicos reais, contas reais,
  credenciais de produção ou ambientes oficiais de RNDS, SISCAN ou GOV.BR.
- Mantenha o foco nos serviços de interoperabilidade. PEPs, aplicações clínicas
  e prestadores são clientes mínimos ou simuladores, não produtos assistenciais
  completos.
- Preserve a diferença entre RAC, documento de um atendimento, e IPS, síntese
  derivada. Não renomeie uma `Composition` RAC nem concatene documentos para
  declarar um IPS. Uma saída IPS exige nova composição, proveniência e
  validação integral contra os perfis fixados.
- O Montador recebe fatos selecionados pelo cliente; não busca fontes
  autonomamente, não resolve conflitos clínicos por conta própria e não publica
  na RNDS. Seu TTL padrão é de 60 minutos desde a criação, sem extensão
  silenciosa; dados e resultado não permanecem disponíveis após a expiração.
- O SISCAN simulado expõe seu contrato JSON nativo; a fachada FHIR pertence ao
  adaptador. Preserve a diferença entre processamento técnico e fluxo clínico,
  seguindo as cópias versionadas do manual e das especificações OpenAPI.
- Não confunda prescrição, dispensação, administração e uso declarado de
  medicamentos. Referências pendentes, duplicidade e conflitos exigem
  tratamento explícito, sem inferências clínicas ou sobrescrita silenciosa.
- A troca entre plataformas estaduais é direta entre pares. A RNDS é uma
  integração independente, não intermediária da federação.
- Trate segurança da informação e segurança clínica como análises distintas.
  Preserve autorização, isolamento, `Provenance`, `AuditEvent` e minimização.
  Não coloque conteúdo clínico, identificadores de pacientes, segredos ou
  tokens em logs, métricas ou rastros.
- Erros e incertezas devem permanecer explícitos nos contratos e nas evidências.
  Não converta falhas em sucesso, assinatura indeterminada em válida ou
  ausência de informação em ausência de condição clínica.

## Artefatos, protótipos e evidências

- Relacione requisito, decisão, contrato, verificação e evidência. Diferencie
  claramente o que foi proposto, implementado, executado e verificado.
- Antes de construir um protótipo, confirme o recorte, a hipótese, os simuladores
  necessários e os critérios acordados. Use os incrementos da seção 13 e o
  catálogo da seção 24 como referência, não como ordem para implementar tudo.
- Fixe pacotes, perfis, terminologias e contratos por versão. Preserve origem,
  data, dependências, hashes e termos de uso dos artefatos externos. Não use
  versões mais recentes automaticamente nem apresente perfis locais ou
  rascunhos como padrões nacionais oficiais.
- Confirme a existência e a integridade dos arquivos antes de usá-los. Links,
  caminhos previstos e hashes registrados em `pratica.md` não comprovam que as
  cópias estejam presentes ou tenham sido verificadas nesta execução.
- Localize os manifestos, scripts e comandos reais antes de construir ou testar.
  Não invente comandos de build, dependências ou uma infraestrutura ainda
  ausente. Registre o bloqueio e a decisão necessária.
- Nos recortes implementados, verifique o comportamento exato dos contratos,
  inclusive estados, erros, idempotência, concorrência, falhas, autorização e
  retenção aplicáveis. Use as ferramentas existentes e o menor conjunto de
  verificações que cubra a alteração.
- Não declare conformidade, aprovação ou execução sem evidência. Documente
  limitações, verificações pendentes e riscos residuais; um teste não executado
  não é um teste aprovado.

## Documentação e contribuição

- Escreva a documentação explicativa em português, preservando os nomes
  técnicos dos padrões. Use fontes oficiais para contratos externos e registre
  divergências, sem inventar regras clínicas ou harmonizar fontes em silêncio.
- Trate documentos e diagramas em `docs` conforme seu status explícito.
  A [proposta de autorização](docs/autorizacao-acesso.md) e seu diagrama não
  sobrepõem as decisões de `pratica.md`. Ao mudar um fluxo, mantenha narrativa,
  contrato e diagramas relacionados coerentes.
- Siga [CONTRIBUTING.md](CONTRIBUTING.md) para Conventional Commits 1.0.0,
  mensagens de commit e títulos de PR. `main` é protegida e o merge é por squash.
- Não crie commits, publique alterações ou faça merge sem solicitação.
  Bypass administrativo exige autorização explícita para a operação em curso;
  uma autorização anterior não vale como permissão permanente.
