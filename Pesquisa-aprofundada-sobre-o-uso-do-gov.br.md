# Uso do GOV.BR para autenticação do paciente e autorização de acesso na Plataforma Goiás



**O GOV.BR autentica o paciente; a Plataforma Goiás é quem registra e emite a autorização de acesso aos dados clínicos.**

Hoje, eu **não trataria o GOV.BR como o componente que emite a autorização clínica propriamente dita**, porque a autorização oferecida pelo Login GOV.BR refere-se ao acesso, pelo serviço integrado, aos atributos/dados disponibilizados pelo próprio ecossistema GOV.BR. A documentação define a “autorização de uso de dados” como a permissão para que determinado serviço público receba ou acesse dados pessoais de identificação ou complementares, como CPF, nome e endereço.

Fonte: https://acesso.gov.br/faq/_perguntasdafaq/oqueeautorizacaodeusodedados.html

Os escopos atualmente documentados para o Login Único também são desse tipo: `openid`, `email`, `phone`, `profile`, dados de empresa e confiabilidades. Não encontrei um mecanismo genérico em que o GOV.BR possa receber algo como `patient.health-data.read` e, com isso, autorizar uma API estadual de saúde que não pertence ao GOV.BR.

Fonte: https://acesso.gov.br/roteiro-tecnico/escopoatributos.html

## O desenho que eu adotaria

A aplicação clínica privada **não precisa integrar-se ao GOV.BR**. Quem integra-se ao GOV.BR é a **Plataforma Goiás/|Expresso Goiás**, enquanto serviço público estadual.

O fluxo ficaria assim:

```text
┌───────────────────────┐
│   Aplicação clínica   │
│ Hospital / UBS / Lab  │
│ pública ou privada    │
└───────────┬───────────┘
            │
            │ solicita acesso aos dados
            │ do paciente
            ▼
┌─────────────────────────────────┐
│        PLATAFORMA GOIÁS         │
│                                 │
│ Pedido:                         │
│ • paciente X                    │
│ • estabelecimento Y             │
│ • profissional Z                │
│ • finalidade                    │
│ • dados solicitados             │
│ • duração                       │
└──────────────┬──────────────────┘
               │
               │ autenticar paciente
               ▼
       ┌───────────────┐
       │    GOV.BR     │
       │               │
       │ "Quem é esta  │
       │  pessoa?"     │
       └───────┬───────┘
               │
               │ identidade autenticada
               ▼
┌──────────────────────────────────┐
│         PLATAFORMA GOIÁS         │
│                                  │
│ "A Clínica X solicita acesso     │
│ aos seus dados para atendimento" │
│                                  │
│ Profissional: Maria Silva        │
│ Estabelecimento: Clínica X       │
│ Finalidade: atendimento          │
│ Dados: ...                       │
│ Validade: ...                    │
│                                  │
│       [NEGAR] [AUTORIZAR]        │
└───────────────┬──────────────────┘
                │
            AUTORIZAR
                ▼
┌──────────────────────────────────┐
│ Plataforma registra autorização │
│                                  │
│ patient = ...                    │
│ organization = ...               │
│ practitioner = ...               │
│ purpose = treatment              │
│ scope = ...                      │
│ validUntil = ...                 │
│ status = active                  │
└───────────────┬──────────────────┘
                │
                ▼
        Gateway da Plataforma
                │
       valida autorização
                │
        ┌───────┴───────┐
        ▼               ▼
   enviar dados     receber dados
   para o PEP       vindos do PEP
```

Esse desenho resolve justamente o problema **público × privado**.

A clínica privada nunca fala com o GOV.BR. Ela fala com a **Plataforma Goiás/Expresso Goiás**.

O GOV.BR nunca precisa confiar na clínica privada. Ele precisa reconhecer apenas a **Plataforma Goiás**, que é o serviço público estadual.

E o token GOV.BR **não deve ser entregue à aplicação clínica**. Isso, inclusive, está alinhado com a documentação técnica do Login Único, que recomenda que a aplicação integrada estabeleça sua própria sessão e não utilize o token GOV.BR como token da própria aplicação.

Fonte: https://acesso.gov.br/roteiro-tecnico/iniciarintegracao.html

## Então temos três autorizações diferentes

Essa separação é fundamental:

| Camada | Pergunta | Responsável |
|---|---|---|
| **Autenticação do paciente** | “Quem é esta pessoa?” | **GOV.BR** |
| **Autorização do paciente** | “Este estabelecimento/profissional pode acessar estes dados para esta finalidade?” | **Plataforma Goiás** |
| **Autorização técnica da aplicação** | “Esta aplicação clínica pode chamar esta API?” | **IAM/Gateway da Plataforma Goiás** |

E existe ainda uma quarta validação:

**autorização profissional**.

A Plataforma precisa verificar que o profissional realmente possui vínculo/papel compatível com a operação pretendida. Isso é diferente de o paciente ter autorizado o estabelecimento.

Portanto, para liberar a chamada, o Gateway poderia avaliar algo conceitualmente assim:

```text
ACESSO PERMITIDO SE:

Aplicação autenticada
        AND
Estabelecimento autorizado
        AND
Profissional identificado
        AND
Vínculo profissional válido
        AND
Papel profissional compatível
        AND
Autorização do paciente ativa
        AND
Finalidade permitida
        AND
Escopo solicitado ⊆ escopo autorizado
        AND
Autorização não expirada
```

Isso se encaixa particularmente bem no desenho da Plataforma Goiás, porque ali o Gateway já é responsável pela autenticação e aplicação de políticas, enquanto identidade e autorização aparecem como capacidades transversais.

## Onde exatamente entra o GOV.BR

Suponha que o profissional da Clínica Santa Maria solicite os dados da paciente Ana.

A Plataforma Goiás poderia gerar algo como:

```text
authorization_request_id = 58fa...

Paciente:
Ana da Silva

Solicitante:
Clínica Santa Maria

Profissional:
Dr. João Souza
CRM-GO xxxxx

Finalidade:
Continuidade do cuidado

Solicitação:
- Sumário clínico
- Medicamentos
- Alergias
- Diagnósticos
- Últimos exames

Validade:
24 horas
```

A paciente recebe o pedido e escolhe:

**“Entrar com GOV.BR para responder à solicitação”.**

Então ocorre:

```text
Paciente
   │
   ▼
GOV.BR
   │
   │ autentica CPF xxx
   ▼
Plataforma Goiás
   │
   │ associa:
   │ CPF autenticado
   │       +
   │ authorization_request_id
   ▼
Tela da Plataforma Goiás
   │
   ├── NEGAR
   │
   └── AUTORIZAR
           │
           ▼
   Authorization Grant
   da Plataforma Goiás
```

Nesse momento, **não é necessário que o GOV.BR saiba que Ana autorizou a Clínica Santa Maria a consultar alergias ou medicamentos**.

Quem precisa saber disso é a Plataforma Goiás.

Isso também evita enviar informações de saúde desnecessariamente para o GOV.BR.

## Poderíamos fazer a própria autorização dentro do GOV.BR?

Aqui existe uma sutileza interessante.

O GOV.BR já possui mecanismos de **gestão de consentimentos e autorizações de uso de dados**. O cidadão consegue visualizar autorizações, revogá-las e consultar histórico de tratamentos. A documentação oficial atual inclusive fala em consentimentos envolvendo empresas e acesso a dados mantidos pelo poder público.

Fonte: https://www.gov.br/governodigital/pt-br/copy_of_perguntas-frequentes-lgpd-1/conheca-os-seus-direitos/nao-quero-mais-que-a

Existe ainda documentação governamental de um modelo de **Governo como Plataforma** em que, depois de autenticado pelo GOV.BR, o cidadão poderia consentir que dados governamentais fossem disponibilizados a uma organização não governamental. O fluxo documentado prevê identificação pelo GOV.BR, apresentação dos dados/finalidade, consentimento e posterior acesso da organização habilitada.

Fonte: https://www.gov.br/secretariageral/pt-br/moderniza-brasil/identificacao-do-cidadao/cefic/copy_of_Minuta_RIPD_SIC_GOV_BR1.pdf

Isso é muito próximo conceitualmente do que você está propondo.

**Mas eu não projetaria a Plataforma Goiás assumindo que essa infraestrutura federal pode ser usada hoje para registrar autorizações de acesso a dados clínicos estaduais.** Não localizei documentação operacional atual que permita a um estado cadastrar livremente um escopo de saúde como:

```text
goias.health.patient.read
goias.health.patient.write
goias.health.medication.read
```

e fazer o GOV.BR emitir essa autorização para uma API estadual.

Ou seja, há **base conceitual e experiências governamentais nessa direção**, mas não encontrei evidência suficiente para afirmar que esse produto está disponível hoje como infraestrutura genérica para o caso da Plataforma Goiás.

## E isso é até melhor para a arquitetura

Eu evitaria colocar no GOV.BR a responsabilidade pela autorização clínica.

Porque a Plataforma Goiás conhece:

- estabelecimentos;
- CNES;
- profissionais;
- papéis profissionais;
- vínculos;
- paciente;
- recursos FHIR;
- finalidade assistencial;
- episódios de atendimento;
- políticas estaduais;
- prazo da autorização.

O GOV.BR não precisa conhecer nada disso.

Ele fornece uma coisa extremamente valiosa:

> **“Tenho evidência de que quem está respondendo a esta solicitação é o titular da identidade CPF X.”**

A Plataforma transforma essa autenticação forte em uma decisão de autorização contextual.

## Há ainda um detalhe jurídico importante

Como estamos falando de **dados de saúde**, não convém arquitetar tudo presumindo que “consentimento” será sempre a base legal do tratamento.

A LGPD classifica dados de saúde como dados pessoais sensíveis e prevê diversas hipóteses para seu tratamento. Entre elas estão consentimento específico e destacado, execução de políticas públicas e **tutela da saúde por profissionais, serviços de saúde ou autoridade sanitária**.

Fonte: https://www.planalto.gov.br/ccivil_03/_ato2015-2018/2018/lei/l13709.htm

Portanto, tecnicamente eu chamaria esse componente de algo como:

**Serviço de Autorização de Acesso do Paciente**

e não necessariamente “Serviço de Consentimento LGPD”.

A autorização operacional do paciente e a hipótese legal de tratamento são conceitos relacionados, mas **não necessariamente iguais**.

## Minha recomendação para a Plataforma Goiás fica, portanto, assim

Eu usaria esta arquitetura:

```text
                     GOV.BR
                       │
                 autenticação
                       │
                       ▼
              ┌─────────────────┐
              │ Plataforma Goiás│
              │                 │
              │ Identity Broker │
              └────────┬────────┘
                       │
                       ▼
              identidade do paciente
                       │
                       ▼
       ┌────────────────────────────┐
       │ Serviço de Autorizações    │
       │ de Acesso                  │
       │                            │
       │ paciente                   │
       │ estabelecimento            │
       │ profissional               │
       │ finalidade                 │
       │ escopo                     │
       │ duração                    │
       │ status                     │
       └─────────────┬──────────────┘
                     │
                     ▼
                 GATEWAY
                     │
         ┌───────────┴───────────┐
         │                       │
         ▼                       ▼
 Aplicação Clínica A      Aplicação Clínica B
     privada                   pública
```

**Então, sim: sua ideia resolve o principal obstáculo identificado anteriormente**, desde que façamos esta alteração conceitual:

> **GOV.BR não autoriza a aplicação clínica a acessar o dado. GOV.BR autentica fortemente o paciente perante a Plataforma Goiás. O paciente, já autenticado, concede a autorização à Plataforma Goiás, e a própria Plataforma emite e controla o direito de a aplicação clínica enviar/receber determinados dados.**

Esse desenho mantém a **integração GOV.BR exclusivamente na fronteira pública**, permite que **PEPs privados participem da rede sem integrarem diretamente com o GOV.BR** e dá à Plataforma Goiás controle granular sobre **quem, onde, para quê, quais dados e por quanto tempo** poderão ser acessados.

Além disso, é compatível com a diretriz do Ministério da Saúde de que compartilhamentos com entidades privadas, quando cabíveis, estejam vinculados a finalidade legítima e específica e limitados ao mínimo necessário.

Fonte: https://www.gov.br/saude/pt-br/acesso-a-informacao/lgpd/compartilhamento-de-dados-pessoais
