# Diagrama de Contexto (Nível 1) - Plataforma Estadual de Interoperabilidade em Saúde

> Diagrama de referência: ![Diagrama de Contexto](./imagens/contexto.svg)

## Visão geral

Este diagrama representa o **Nível 1 do modelo C4 (Contexto)** da Plataforma Estadual de Interoperabilidade em Saúde. Ele mostra como a plataforma se relaciona com as pessoas que a utilizam (direta ou indiretamente) e com os sistemas externos com os quais ela troca informações, sem detalhar sua arquitetura interna (Gateway, Servidor FHIR, Montador IPS etc.), que fica reservada para o diagrama de Contêineres (Nível 2).

## Sistema principal

**Plataforma Estadual de Interoperabilidade em Saúde**
Conjunto de serviços executáveis (Gateway, Servidor FHIR, Servidor AuthZ, Montador IPS, Serviço de Medicamentos, Adaptador FHIR-SISCAN, entre outros) responsável por integrar os sistemas participantes de uma Unidade Federativa (UF). O **Servidor AuthZ** da Plataforma decide a autorização de acesso clínico (estabelecimento, vínculo profissional, finalidade de uso e consentimento) a partir da identidade autenticada e das políticas do domínio — essa decisão **não é delegada** ao provedor de identidade.

## Pessoas (atores)

| Ator | Papel |
|---|---|
| **Pessoa Atendida (Paciente)** | Busca continuidade do cuidado, privacidade e acesso aos próprios dados. Autentica-se via GOV.BR. |
| **Profissional de Saúde** | Registra atendimentos, prescreve, dispensa ou administra medicamentos e consulta o histórico clínico do paciente. |
| **Gestor** (Secretaria Municipal/Estadual) | Responsável por cadastro de estabelecimentos, coordenação regional e indicadores. |
| **DPO / Encarregado de Dados** | Responsável pela base legal, minimização, trilha de auditoria e consentimento. |
| **Operador da Plataforma** | Equipe de operação responsável por observabilidade, recuperação e diagnóstico de falhas da plataforma. |

## Sistemas externos

| Sistema | Descrição |
|---|---|
| **Aplicações Clínicas / PEPs (AC)** | Sistemas clientes que produzem e consomem recursos e documentos FHIR a partir de eventos assistenciais. Usados por pacientes e profissionais de saúde. |
| **GOV.BR** | Provedor nacional de identidade digital (SSO). Realiza **apenas a autenticação (AuthN)** dos usuários finais e disponibiliza atributos de identidade verificados. **Não define** estabelecimento, vínculo profissional, finalidade de uso ou consentimento para dados clínicos — essa decisão é da Plataforma. |
| **Sistema de Cadastro de Estabelecimento** | Registro dos estabelecimentos de saúde participantes, mantido/gerido pelo Gestor. |
| **Outra Plataforma Estadual** | Instância de outra unidade federativa com a qual a plataforma troca dados diretamente por contrato federado. |
| **RNDS Simulada** | Rede Nacional de Dados em Saúde. Fonte e destino nacional de documentos (RAC, IPS), sem função de intermediária entre UFs. |
| **API SISCAN Simulada** | Sistema de Informação do Câncer. Recebe e processa requisição/laudo via contrato JSON nativo, não FHIR. |
| **Aplicação Administrativa** | Consumida por gestores (ex.: secretário de saúde) para obter indicadores e informações de gestão do estado. |

## Relacionamentos

### Pessoas → Aplicações Clínicas e Autenticação
- **Paciente** acessa informações e histórico de saúde através das **Aplicações Clínicas**.
- **Profissional de Saúde** registra atendimentos, prescrições e consultas clínicas através das **Aplicações Clínicas**.
- **Paciente** e **Profissional de Saúde** se autenticam e obtêm atributos de identidade verificados junto ao **GOV.BR** (AuthN / OIDC) — a autenticação não implica, por si só, autorização de acesso clínico.

### Gestor
- **Gestor** cadastra e mantém dados dos estabelecimentos no **Sistema de Cadastro de Estabelecimento**.
- **Gestor** consulta indicadores e informações de gestão na **Aplicação Administrativa**.

### DPO e Operador
- **DPO** realiza auditoria e verifica consentimento junto à **Plataforma** (via trilha de auditoria).
- **Operador** opera, monitora e diagnostica falhas da **Plataforma**; a **Plataforma** expõe métricas, logs e alertas para o **Operador**.

### Aplicações Clínicas ↔ Plataforma
- **Aplicações Clínicas** enviam/recebem recursos FHIR e acionam fluxos de interoperabilidade com a **Plataforma** (FHIR / HTTPS).
- **Plataforma** retorna resultados, notificações e apoio à decisão às **Aplicações Clínicas** (FHIR / CDS Hooks).
- **Aplicações Clínicas** delegam a **autenticação (AuthN)** do usuário final ao **GOV.BR** (OpenID Connect).
- **Plataforma** valida o token e obtém atributos de identidade autenticados junto ao **GOV.BR** (OIDC / Introspecção de Token). A **autorização de acesso clínico** (estabelecimento, vínculo profissional, finalidade de uso e consentimento) é decidida internamente pelo Servidor AuthZ da Plataforma, com base nessa identidade e nas políticas do domínio — não pelo GOV.BR.

### Plataforma ↔ Sistemas Externos
- **Plataforma** consulta dados de estabelecimentos participantes no **Sistema de Cadastro de Estabelecimento**.
- **Plataforma** e **Outra Plataforma Estadual** compartilham e trocam informações de saúde interestaduais — IPS (Contrato Federado), nos dois sentidos.
- **Plataforma** valida, publica e consulta documentos (RAC, IPS) na **RNDS** (FHIR); a **RNDS** retorna documentos e confirmações de publicação (FHIR).
- **Plataforma** traduz e envia requisições e recebe laudos de exames na **API SISCAN** (JSON nativo / REST); o **SISCAN** retorna laudos preliminar, final e corrigido (JSON nativo / REST).
- **Plataforma** fornece indicadores e dados agregados para gestão à **Aplicação Administrativa**.

## Separação entre identidade e autorização clínica

Ponto de atenção incorporado após revisão: **identidade (quem é a pessoa) e autorização de acesso clínico (o que ela pode fazer, onde e com qual finalidade) são responsabilidades distintas.**

- O **GOV.BR** resolve apenas **AuthN**: confirma quem é o usuário e fornece atributos de identidade verificados.
- A **Plataforma** (via seu Servidor AuthZ) é quem decide a **autorização de acesso clínico**, combinando a identidade autenticada com políticas locais de estabelecimento, vínculo profissional, finalidade de uso e consentimento do paciente.

Essa separação está representada no `contexto.svg` por duas notas explícitas — uma ao lado do GOV.BR e outra junto à Plataforma — e reflete o requisito descrito na seção 12.2 do documento da disciplina (`pratica.md`), segundo o qual toda operação sobre documentos exige "organização, finalidade de uso e contexto de paciente autorizados", ou seja, uma decisão local da Plataforma, e não um subproduto do login.

## Resumo do fluxo

1. **Pacientes** e **profissionais de saúde** interagem com as **Aplicações Clínicas**, autenticando-se (AuthN) via **GOV.BR**.
2. As **Aplicações Clínicas** trocam recursos FHIR com a **Plataforma**, que valida o token de identidade junto ao **GOV.BR** e, internamente, decide a autorização de acesso clínico com base em suas próprias políticas.
3. A **Plataforma** se integra com sistemas nacionais (**RNDS**, **SISCAN**) e com **outras plataformas estaduais**, além de consultar o **Sistema de Cadastro de Estabelecimento** gerido pelo **Gestor**.
4. **Gestores** acompanham indicadores pela **Aplicação Administrativa**; **DPO** e **Operador** cuidam, respectivamente, da conformidade/auditoria e da operação técnica da **Plataforma**.
