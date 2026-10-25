# Diagramas C4: IPS sob demanda e Montador Efêmero

## 1. Nível 1: contexto

A plataforma recebe o pedido do PEP, monta o IPS na hora e devolve o `Bundle`. O envio à outra UF só acontece por pedido explícito, e a organização responsável pela política é quem assume a autoria clínica.

```mermaid
flowchart TB
    prof["<b>Profissional de saúde</b><br/>usa o PEP no atendimento<br/>[Pessoa]"]
    org["<b>Organização responsável</b><br/>pela política de seleção<br/>[Pessoa ou organização]"]
    aud["<b>Auditor e encarregado de dados</b><br/>[Pessoa]"]
    pep["<b>PEP simulado</b><br/>sistema cliente FHIR<br/>[Sistema externo]"]
    plat["<b>Plataforma de Interoperabilidade em Saúde</b><br/>[Instância estadual]<br/>Monta o IPS a cada pedido,<br/>guarda em cache curto e<br/>registra a evidência"]
    uf["<b>Plataforma estadual de outra UF</b><br/>par<br/>[Sistema externo]"]
    rnds["<b>RNDS simulada</b><br/>documentos e registros<br/>[Sistema externo]"]

    prof -->|"usa"| pep
    pep -->|"pede IPS"| plat
    plat -->|"devolve"| pep
    org -->|"aprova a política"| plat
    aud -->|"consulta evidência e verifica hash"| plat
    plat -->|"envia IPS, só sob pedido"| uf
    plat <-->|"publica e consulta RACs"| rnds

    classDef foco fill:#e3f0fb,stroke:#2b78d4,stroke-width:2px
    classDef ext stroke-dasharray:5 4
    class plat foco
    class pep,uf,rnds ext
```

Não mostra: Serviço de Documentos RNDS, validação de assinaturas, auditoria e telemetria.

---

## 2. Nível 2: contêineres

O Serviço de Síntese orquestra o pedido: lê os fatos, usa o Montador, grava o `Bundle` no cache curto e a evidência no Arquivo. O Despachante só atua quando o cliente pede o envio.

```mermaid
flowchart TB
    pep["<b>PEP simulado</b><br/>[sistema externo]"]
    uf["<b>Plataforma de outra UF</b><br/>[sistema externo]"]

    subgraph plat["Plataforma de Interoperabilidade em Saúde (instância estadual)"]
        gw["<b>Gateway de Integração</b><br/>[existente]<br/>autentica, aplica organização e finalidade,<br/>registra AuditEvent"]
        fhir["<b>Servidor FHIR R4</b><br/>[existente]<br/>fonte dos fatos candidatos,<br/>acesso somente leitura"]
        sint["<b>Serviço de Síntese</b><br/>[novo]<br/>aplica a política de seleção versionada<br/>e orquestra a montagem a cada pedido"]
        cache[("<b>Cache curto de IPS</b><br/>[novo · dados]<br/>Bundle final cifrado,<br/>TTL de minutos ou horas")]
        mont["<b>Montador Efêmero</b><br/>[existente]<br/>sessão de até 60 min;<br/>valida e gera o Bundle"]
        arq[("<b>Arquivo de evidência</b><br/>[novo · dados]<br/>hash, manifesto, fontes,<br/>entregas e eliminação;<br/>sem conteúdo clínico")]
        desp["<b>Despachante de Envio</b><br/>[novo]<br/>entrega o IPS à outra UF só por<br/>pedido explícito (outbox, idempotência)"]
    end

    pep <-->|"pede IPS; recebe o Bundle"| gw
    uf <-->|"federação direta"| gw
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
    class pep,uf ext
```

Não mostra: Validação e Terminologia e Repositório Efêmero (dentro do Montador, ver diagrama 4), assinatura digital e auditoria. De onde o Serviço de Síntese lê os RACs (Servidor FHIR ou Serviço de Documentos RNDS) está em aberto.

---

## 3. Sequência de um pedido

```mermaid
sequenceDiagram
    autonumber
    participant PEP as PEP simulado
    participant GW as Gateway
    participant S as Serviço de Síntese
    participant C as Cache curto
    participant F as Servidor FHIR
    participant M as Montador Efêmero
    participant A as Arquivo de evidência

    PEP->>GW: pede IPS do paciente (manifesto e decisões)
    GW->>S: pedido autorizado
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

Em aberto: se um cache hit registra novo evento de evidência, e como o cache é invalidado quando chega um RAC novo durante o TTL.

---

## 4. Montador Efêmero, nível 2: contêineres

O Montador guarda tudo no Repositório Transacional Efêmero, que expira em até 60 minutos e não tem backup; o evento `ips-finalized` parte da caixa de saída desse mesmo repositório. O Montador não consulta fontes nem envia o IPS.

```mermaid
flowchart TB
    cli["<b>Cliente autorizado</b><br/>PEP ou Serviço de Síntese"]
    gw["<b>Gateway de Integração</b><br/>[existente]<br/>autoriza o acesso"]
    mont["<b>Montador Efêmero de IPS</b><br/>[existente · sessão de 60 min]<br/>cria a sessão, valida as entradas,<br/>aplica regras de precedência e gera<br/>o IPS validado, sem curadoria"]
    rep[("<b>Repositório Efêmero</b><br/>[existente · dados]<br/>sessões, entradas, resultado e<br/>caixa de saída; expira em até<br/>60 min, sem backup")]
    val["<b>Validação e Terminologia</b><br/>[existente]<br/>validador HAPI com o pacote<br/>IPS Brasil local e terminologias fixadas"]
    ev["<b>Serviço de Eventos e Subscriptions</b><br/>[existente]<br/>avisa que o IPS existe"]
    aud["<b>Coletor de Auditoria</b><br/>[existente]<br/>recebe AuditEvent de criação,<br/>acesso e expiração"]

    cli <-->|"pedidos de montagem"| gw
    gw <-->|"chamadas autorizadas"| mont
    mont <-->|"sessão, entradas"| rep
    mont -->|"valida recursos"| val
    mont -->|"ips-finalized (pelo menos uma vez)"| ev
    mont -->|"AuditEvent"| aud

    classDef foco fill:#e3f0fb,stroke:#2b78d4,stroke-width:2px
    classDef ext stroke-dasharray:5 4
    class mont foco
    class cli ext
```

Não mostra: Serviço de Validação de Assinaturas e telemetria.

---

## 5. Montador Efêmero, nível 3: componentes

Leia do Gateway para baixo: a API recebe a chamada, os controles de versão e de estado a filtram, o Verificador, o Importador e o Motor preparam os fatos, e o Gerador produz o `Bundle` antes de gravar e avisar. A proposta só define o Montador como contêiner; estes componentes são sugestão para discussão.

```mermaid
flowchart TB
    gw["<b>Gateway de Integração</b><br/>[existente]"]
    val["<b>Validação e Terminologia</b><br/>[existente]"]
    rep[("<b>Repositório Efêmero</b><br/>[existente]")]
    ev["<b>Serviço de Eventos</b><br/>[existente]"]

    subgraph mont["Montador Efêmero de IPS · componentes"]
        api["<b>API de Sessões</b><br/>recebe criar, entradas, validar,<br/>finalizar, obter e cancelar"]
        conc["<b>Concorrência e idempotência</b><br/>If-Match e chave de idempotência;<br/>devolve 412 ou 409 em conflito"]
        ciclo["<b>Ciclo de vida da sessão</b><br/>estados da sessão e TTL de 60 min;<br/>elimina ao expirar"]
        verif["<b>Verificador de entradas</b><br/>envelope, paciente da sessão,<br/>referências e coerência"]
        imp["<b>Importador de RAC</b><br/>valida o RAC e o manifesto,<br/>extrai fatos e proveniência"]
        motor["<b>Motor de regras</b><br/>aplica precedência escrita e<br/>bloqueia conflito sem decisão"]
        ger["<b>Gerador do documento</b><br/>nova Composition, Bundle com<br/>fullUrl únicos e Provenance"]
        cliv["<b>Cliente de validação</b><br/>chama o Serviço de Validação para<br/>recursos e para o Bundle final"]
        adp["<b>Adaptador do Repositório</b><br/>grava sessão, entradas, resultado<br/>e caixa de saída numa transação"]
        desp["<b>Despachante de eventos</b><br/>entrega ips-finalized pelo menos<br/>uma vez, sem conteúdo clínico"]
    end

    gw --> api
    api --> conc --> ciclo --> verif --> imp --> motor --> ger --> cliv --> adp --> desp
    cliv --> val
    verif -. "também valida" .-> cliv
    adp <--> rep
    desp --> ev
```

Todos os componentes emitem `AuditEvent` ao Coletor de Auditoria (setas omitidas). A seta tracejada indica que o Cliente de validação também atende o Verificador.

---

## 6. Ciclo de vida da sessão do Montador

Reproduz o diagrama de estados da seção 14.6 da proposta.

```mermaid
stateDiagram-v2
    [*] --> Aberta: criar sessão
    Aberta --> Aberta: receber ou substituir entrada válida
    Aberta --> Inconsistente: submissão cria conflito
    Inconsistente --> Aberta: corrigir ou remover entrada
    Aberta --> Pronta: validação integral aprovada
    Pronta --> Aberta: nova entrada antes do fechamento
    Pronta --> Finalizando: solicitar finalização
    Finalizando --> Finalizada: Bundle aprovado
    Finalizando --> Inconsistente: validação final falhou
    Aberta --> Cancelada: cancelar
    Inconsistente --> Cancelada: cancelar
    Pronta --> Cancelada: cancelar
    Aberta --> Expirada: atingir TTL
    Inconsistente --> Expirada: atingir TTL
    Pronta --> Expirada: atingir TTL
    Finalizando --> Expirada: atingir TTL
    Finalizada --> Expirada: atingir TTL
    Cancelada --> [*]
    Expirada --> [*]
```
