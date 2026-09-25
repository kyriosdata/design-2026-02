# Autorização de acesso com GOV.BR — respostas às questões em aberto

Sep 25, 2026 · @Marina Alves

## Contexto

Este documento propõe respostas às perguntas que a proposta de autorização de acesso com GOV.BR ainda não cobre. A proposta segue como alternativa de design em avaliação, e cada resposta abaixo depende de decisão conjunta da equipe (pratica.md, seções 25 e 27).

O fluxo base se mantém: o GOV.BR autentica o paciente, o MeuPEP (Expresso Goiás) recebe e aprova a solicitação, e a aplicação clínica do estabelecimento pede o acesso. Qualquer protótipo usa simuladores e dados sintéticos.

## 1. Como autorizar o acesso de forma segura?

- **Identidade do paciente:** o GOV.BR autentica o paciente no MeuPEP, com conta nível ouro.
- **Presença no atendimento:** a aplicação clínica gera um QR code que o paciente lê no MeuPEP.
- **Canal entre sistemas:** a comunicação entre aplicação clínica e MeuPEP usa o certificado digital do estabelecimento.

Ao aprovar, o MeuPEP cria um registro de consentimento (recurso FHIR `Consent`) e emite um token com escopo e prazo definidos. O acesso expira sozinho, e o paciente pode revogá-lo a qualquer momento no MeuPEP.

Se o paciente recusar, ou não responder dentro do prazo da solicitação, a aplicação clínica recebe "não autorizado". Pacientes sem celular, sem conta GOV.BR ou representados por responsável legal seguem um fluxo alternativo, com termo presencial ou procuração.

## 2. Como provar que foi o próprio paciente quem autorizou?

Usar a assinatura eletrônica avançada do GOV.BR (Lei 14.063/2020).

O paciente recebe um comprovante e passa a ver, no MeuPEP, o histórico de quem acessou seus dados.

## 3. Como garantir que é o estabelecimento X com o profissional Y?

Cada lado é identificado por registros oficiais e verificado pela plataforma a cada solicitação.

- **Estabelecimento:** identificado pelo CNES e autenticado pelo certificado e-CNPJ.
- **Profissional:** entra na aplicação clínica com GOV.BR ou certificado digital. A plataforma confere o registro ativo no conselho de classe e o vínculo com aquele estabelecimento no CNES.
- **Registro da autorização:** o consentimento guarda os dois identificadores. O acesso vale só para aquele profissional naquele estabelecimento.

## 4. Como restringir o acesso conforme o tipo de profissional?

- **Dados sensíveis:** recebem rótulos de restrição (`meta.security` no FHIR), como saúde mental, HIV, genética e saúde reprodutiva.
- **Finalidade:** escolhida numa lista fechada, limita ainda mais o que pode ser visto.
- **Onde se aplica:** no servidor de dados, não na aplicação clínica, para que nenhum sistema local possa ignorar a regra.

Cada profissional acessa só o mínimo necessário. Antes de autorizar, o paciente vê na tela o que será compartilhado.

## 5. Como limitar os procedimentos por profissional, estabelecimento e contrato?

A permissão efetiva é a interseção de três fontes. O profissional só faz o que as três permitem ao mesmo tempo.

| Fonte | O que define | Origem |
| --- | --- | --- |
| Profissão | O que a categoria pode fazer | Conselho de classe |
| Estabelecimento | O que o local está habilitado a fazer | CNES |
| Contrato | O que o vínculo vigente cobre, com data de vigência | Cadastro do estabelecimento |

## 6. Como tornar o digital mais vantajoso que o papel?

O fluxo digital oferece o que o papel não consegue oferecer, para os dois lados do atendimento.

- **Paciente:** autoriza em segundos pelo celular, vê quem acessou seus dados e revoga quando quiser.
- **Profissional:** recebe o histórico completo sem depender de exames e cópias trazidos pelo paciente.

## 7. Impressão para falta de energia ou internet

No atendimento sem energia, o fluxo de contingência é este:

1. O profissional confere a identidade do paciente por documento oficial com foto.
2. O paciente assina um termo de autorização em papel, com estabelecimento, profissional, finalidade e prazo, retirado de um kit de contingência mantido pela clínica.
3. O profissional atende com base no impresso que o paciente trouxer, se houver, e registra o atendimento em papel.
4. Quando a energia voltar, o profissional lança o termo e o atendimento no sistema.
5. O MeuPEP envia ao paciente a autorização lançada para confirmação. Se ele não reconhecer, o caso vai para o DPO.

Em emergência sem energia, vale a regra de acesso emergencial da seção 8, com justificativa registrada em papel e lançada depois. Toda impressão e todo termo em papel entram na auditoria.

## 8. Papel do DPO

Em emergência, o profissional aciona um acesso emergencial com justificativa obrigatória, e o DPO é notificado na hora e revisa o caso depois. A LGPD (art. 11, II) já permite esse acesso sem consentimento para proteger a vida e a saúde, e uma aprovação prévia atrasaria o atendimento.

Se a equipe preferir que o DPO aprove antes, será preciso garantir plantão 24/7 com substituto. Nos dois modelos, o DPO:

- audita os acessos;
- recebe denúncias dos pacientes pelo MeuPEP;
- pode suspender acessos indevidos e abrir incidentes.9. Acesso do DPO à Plataforma GO

## 9. Acesso do DPO à Plataforma GO

O DPO tem um perfil próprio, separado dos perfis clínicos.

- **Autenticação:** GOV.BR ouro, certificado digital e segundo fator.
- **Visão padrão:** painel de auditoria com quem acessou, quando, o quê e para qual finalidade, sem conteúdo clínico.
- **Conteúdo clínico:** só é aberto mediante justificativa registrada.
- **Auditoria do próprio DPO:** as ações dele também ficam registradas e são revisadas por um comitê ou instância independente.

## Complemento do diagrama de sequência

O diagrama da proposta termina no `else` sem conteúdo. O trecho abaixo substitui o final a partir de `alt Paciente autoriza`, fechando a recusa e acrescentando expiração e revogação.

```plantuml
alt Paciente autoriza

    Jose -> MeuPEP: Pressiona "Autorizar"
    MeuPEP -> Jose: Solicita biometria ou desbloqueio
    Jose -> MeuPEP: Confirma com mecanismo do celular
    MeuPEP -> MeuPEP: Assina e registra autorização\n(Consent FHIR + trilha de auditoria)
    MeuPEP --> AppClinica: Retorna token de acesso\n(escopo e prazo definidos)
    AppClinica -> Profissional: Dados disponíveis\nconforme regras de acesso

else Paciente não autoriza

    Jose -> MeuPEP: Pressiona "Não autorizar"
    MeuPEP -> MeuPEP: Registra recusa com data e hora
    MeuPEP --> AppClinica: Retorna "não autorizado"
    AppClinica -> Profissional: Informa recusa do paciente

else Sem resposta no prazo

    MeuPEP -> MeuPEP: Expira a solicitação
    MeuPEP --> AppClinica: Retorna "solicitação expirada"

end

== Revogação pelo paciente ==

Jose -> MeuPEP: Revoga autorização ativa
MeuPEP -> MeuPEP: Encerra consentimento e invalida token
MeuPEP --> AppClinica: Notifica revogação

@enduml
```
