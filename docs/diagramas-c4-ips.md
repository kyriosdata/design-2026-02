# Diagramas C4: IPS sob demanda e Montador Efêmero

> **Nota:** possivelmente precisa de ajustes para contemplar telemedicina.

## 1. Nível 1: contexto

Este diagrama recorta o diagrama de contexto geral da plataforma para o fluxo do IPS. O paciente gera o QR code no **MeuPEP**, o sistema do paciente, autenticado pelo GOV.BR. A clínica lê o QR na sua Aplicação Clínica e a plataforma monta o IPS na hora e devolve o `Bundle`, desde que o acesso seja autorizado: estabelecimento cadastrado, finalidade e consentimento. O GOV.BR só autentica; a decisão de autorização é do Servidor AuthZ da plataforma, que valida a concessão do QR no MeuPEP.

- **Opção A:** a clínica e o paciente estão na mesma UF.
- **Opção B:** a clínica está em outra UF, e a plataforma dela pede o IPS à plataforma de origem do paciente, pelo contrato federado.

O envio do IPS a outra UF só acontece por pedido explícito, e a organização responsável pela política é quem assume a autoria clínica.

```mermaid
flowchart TB
    pac["<b>Pessoa Atendida (Paciente)</b><br/>gera o QR code no MeuPEP<br/>[Pessoa]"]
    prof["<b>Profissional de Saúde</b><br/>lê o QR code na aplicação da clínica<br/>[Pessoa]"]
    gestor["<b>Gestor (Secretaria)</b><br/>mantém o cadastro de estabelecimentos<br/>[Pessoa]"]
    dpo["<b>DPO / Encarregado de Dados</b><br/>base legal, auditoria e consentimento<br/>[Pessoa]"]
    org["<b>Organização responsável</b><br/>pela política de seleção<br/>[Pessoa ou organização]"]
    meupep["<b>MeuPEP</b><br/>sistema do paciente: registra o consentimento<br/>e emite a concessão e o QR code<br/>[Sistema externo · em avaliação]"]
    ac["<b>Aplicação Clínica / PEP da clínica (AC)</b><br/>lê o QR e pede o IPS<br/>[Sistema externo]"]
    govbr["<b>GOV.BR</b><br/>apenas autenticação (AuthN)<br/>[Sistema externo]"]
    cad["<b>Sistema de Cadastro de Estabelecimento</b><br/>estabelecimentos participantes<br/>[Sistema externo]"]
    plat["<b>Plataforma Estadual de Interoperabilidade em Saúde</b><br/>[Instância estadual]<br/>Autoriza o acesso, monta o IPS a cada<br/>pedido, guarda em cache curto e<br/>registra a evidência"]
    uf["<b>Outra Plataforma Estadual</b><br/>par, p. ex. UF de origem do paciente<br/>[Sistema externo]"]
    rnds["<b>RNDS Simulada</b><br/>documentos e registros<br/>[Sistema externo]"]

    pac -->|"autentica-se e gera o QR"| meupep
    pac -.->|"mostra o QR"| prof
    prof -->|"lê o QR na"| ac
    ac -->|"pede IPS com a concessão do QR;<br/>recebe o IPS ou a recusa [FHIR]"| plat
    meupep -->|"delega a autenticação [OIDC]"| govbr
    ac -->|"delega a autenticação [OIDC]"| govbr
    plat -->|"valida o token [OIDC]"| govbr
    plat -->|"valida e consome a concessão"| meupep
    gestor -->|"cadastra e mantém"| cad
    plat -->|"consulta estabelecimentos participantes"| cad
    org -->|"aprova a política"| plat
    dpo -->|"audita e verifica consentimento"| plat
    plat <-->|"IPS interestadual [contrato federado]:<br/>envio sob pedido e, na opção B, pedido de IPS"| uf
    plat <-->|"publica e consulta RACs [FHIR]"| rnds

    classDef foco fill:#e3f0fb,stroke:#2b78d4,stroke-width:2px
    classDef ext stroke-dasharray:5 4
    class plat foco
    class meupep,ac,govbr,cad,uf,rnds ext
```

Não mostra: Operador da Plataforma, Aplicação Administrativa e API SISCAN do diagrama de contexto geral, que não participam do fluxo do IPS, nem a validação de assinaturas e a telemetria. A linha tracejada é a leitura do QR na tela do celular, sem comunicação entre sistemas.

---

## 2. Nível 2: contêineres

O Gateway encaminha o pedido ao Servidor AuthZ, que decide o acesso: estabelecimento (consultado no Sistema de Cadastro), vínculo profissional, finalidade e consentimento. O consentimento e a concessão do QR são do MeuPEP, o sistema do paciente; o AuthZ os valida e os consome. Só um pedido autorizado chega ao Serviço de Síntese, que orquestra o pedido: lê os fatos, usa o Montador, grava o `Bundle` no cache curto e a evidência no Arquivo. O Despachante só atua quando o cliente pede o envio. Na opção B, o Gateway da UF visitada pede o IPS ao Gateway da UF de origem, onde este mesmo fluxo se repete.

```mermaid
flowchart TB
    meupep["<b>MeuPEP</b><br/>[sistema externo · em avaliação]<br/>sistema do paciente: consentimento,<br/>concessão e QR"]
    ac["<b>Aplicação Clínica / PEP da clínica (AC)</b><br/>[sistema externo]<br/>lê o QR e pede o IPS"]
    govbr["<b>GOV.BR</b><br/>[sistema externo]<br/>apenas autenticação (AuthN)"]
    cad["<b>Sistema de Cadastro de Estabelecimento</b><br/>[sistema externo]"]
    uf["<b>Outra Plataforma Estadual</b><br/>[sistema externo]"]

    subgraph plat["Plataforma Estadual de Interoperabilidade em Saúde"]
        gw["<b>Gateway de Integração</b><br/>[existente]<br/>autentica, aplica organização e finalidade,<br/>registra AuditEvent"]
        authz["<b>Servidor AuthZ</b><br/>[existente]<br/>decide o acesso: estabelecimento, vínculo,<br/>finalidade e consentimento;<br/>valida e consome a concessão do QR"]
        fhir["<b>Servidor FHIR R4</b><br/>[existente]<br/>fonte dos fatos candidatos,<br/>acesso somente leitura"]
        sint["<b>Serviço de Síntese</b><br/>[novo]<br/>aplica a política de seleção versionada<br/>e orquestra a montagem a cada pedido"]
        cache[("<b>Cache curto de IPS</b><br/>[novo · dados]<br/>Bundle final cifrado,<br/>TTL de minutos ou horas")]
        mont["<b>Montador Efêmero</b><br/>[existente]<br/>sessão de até 60 min;<br/>valida e gera o Bundle"]
        arq[("<b>Arquivo de evidência</b><br/>[novo · dados]<br/>hash, manifesto, fontes,<br/>entregas e eliminação;<br/>sem conteúdo clínico")]
        desp["<b>Despachante de Envio</b><br/>[novo]<br/>entrega o IPS à outra UF só por<br/>pedido explícito (outbox, idempotência)"]
    end

    ac <-->|"pede IPS com a concessão do QR;<br/>recebe o Bundle ou a recusa"| gw
    ac -->|"delega a autenticação [OIDC]"| govbr
    meupep -->|"delega a autenticação [OIDC]"| govbr
    gw <-->|"consulta a autorização"| authz
    authz <-->|"valida e consome a concessão"| meupep
    authz -->|"valida o token [OIDC]"| govbr
    authz -->|"consulta o estabelecimento"| cad
    uf <-->|"federação direta: envio sob pedido e,<br/>na opção B, pedido de IPS"| gw
    gw -->|"encaminha pedido autorizado"| sint
    sint -->|"lê candidatos"| fhir
    sint <-->|"grava e consulta"| cache
    sint -->|"abre sessão, submete fatos"| mont
    sint -->|"registra evidência"| arq
    desp -->|"lê o Bundle"| cache
    desp -->|"grava recibo"| arq
    desp -->|"envia pelo Gateway"| gw

    classDef novo fill:#e3f0fb,stroke:#2b78d4,stroke-width:2px
    classDef ext stroke-dasharray:5 4
    class sint novo
    class meupep,ac,govbr,cad,uf ext
```

Não mostra: Validação e Terminologia e Repositório Efêmero (dentro do Montador), assinatura digital e auditoria. Em aberto: de onde o Serviço de Síntese lê os RACs (Servidor FHIR ou Serviço de Documentos RNDS), o protocolo entre o Servidor AuthZ e o MeuPEP (o MeuPEP segue a proposta de autorização com GOV.BR, alternativa em avaliação) e entre o Gateway e o Servidor AuthZ.

---

## 3. Sequência de um pedido (opção A: mesma UF)

```mermaid
sequenceDiagram
    autonumber
    participant P as Paciente (MeuPEP)
    participant PEP as PEP simulado
    participant GW as Gateway
    participant CAD as Cadastro de estabelecimentos
    participant MP as MeuPEP simulado
    participant S as Serviço de Síntese
    participant C as Cache curto
    participant F as Servidor FHIR
    participant M as Montador Efêmero
    participant A as Arquivo de evidência

    P->>MP: autentica, escolhe prazo e gera o QR
    MP-->>P: QR com referência opaca da concessão
    P-->>PEP: estabelecimento lê o QR
    PEP->>GW: pede IPS com a concessão (manifesto e decisões)
    GW->>CAD: estabelecimento cadastrado?
    alt não cadastrado
        GW-->>PEP: 403 (AuditEvent registrado)
    else cadastrado
        GW->>MP: valida e consome a concessão
        alt concessão inválida, expirada, revogada ou usada
            MP-->>GW: negada
            GW-->>PEP: 403 (AuditEvent registrado)
        else concessão válida
            MP-->>GW: referência do paciente
            GW->>S: pedido autorizado (paciente, estabelecimento, finalidade)
        end
    end
    Note over GW,S: os passos abaixo só ocorrem se o pedido foi autorizado
    S->>C: consulta Bundle válido
    alt Bundle válido em cache
        C-->>S: Bundle
    else sem cache válido
        S->>F: lê fatos candidatos (somente leitura)
        S->>M: abre sessão e submete fatos
        M-->>S: OperationOutcome (pendências e conflitos)
        S->>M: $finalize
        M-->>S: Bundle validado e hash
        S->>C: grava Bundle (TTL curto)
    end
    S->>A: registra evidência (geração ou reuso)
    S-->>GW: Bundle
    GW-->>PEP: Bundle
```

O cache não dispensa a verificação do cadastro e da concessão: ela ocorre antes de qualquer consulta ao cache.

Em aberto: se um cache hit registra novo evento de evidência, e como o cache é invalidado quando chega um RAC novo durante o TTL.

---

## 3B. Sequência de um pedido da opção B (clínica em outra UF)

O QR é emitido pela UF de origem do paciente. A UF visitada reconhece pelo QR que é de outra UF e pede o IPS à UF de origem, por federação direta entre pares. O PEP só fala com o Gateway da própria UF.

```mermaid
sequenceDiagram
    autonumber
    participant P as Paciente (MeuPEP)
    participant PEP as PEP da clínica
    participant GV as Gateway (UF visitada)
    participant CAD as Cadastro (UF visitada)
    participant GO as Gateway (UF de origem)
    participant MP as MeuPEP e consentimento (UF de origem)
    participant S as Síntese e Montador (UF de origem)
    participant A as Arquivo de evidência (UF de origem)

    P->>MP: autentica e pede o QR do IPS
    MP-->>P: QR (referência opaca e UF emissora)
    P-->>PEP: clínica lê o QR
    PEP->>GV: pede IPS com a concessão (manifesto e decisões)
    GV->>CAD: estabelecimento cadastrado?
    alt não cadastrado
        GV-->>PEP: 403 (AuditEvent registrado)
    else cadastrado
        Note over GV: QR indica outra UF, então não valida a concessão localmente
        GV->>GO: pedido federado (concessão, estabelecimento, finalidade)
        Note over GO: autentica a plataforma par e confere se está habilitada
        GO->>MP: valida e consome a concessão
        alt par não habilitado ou concessão inválida
            GO-->>GV: recusa
            GV-->>PEP: 403 (AuditEvent registrado)
        else autorizado
            MP-->>GO: referência do paciente
            GO->>S: pedido autorizado
            S->>S: gera o IPS (cache, política, Montador)
            S->>A: registra evidência (estabelecimento e UF visitada)
            S-->>GO: Bundle
            GO-->>GV: Bundle
            Note over GV: não grava o Bundle, só a evidência de recebimento (hash)
            GV-->>PEP: Bundle
        end
    end
    Note over GV,GO: UF de origem indisponível ou fora do prazo: erro explícito ao PEP, nunca "sem IPS"
```

Em aberto: se a UF de origem confia no cadastro da UF visitada ou mantém verificação própria, o que o QR revela da UF emissora, o tempo limite da chamada federada e a retenção do lado da UF visitada.
