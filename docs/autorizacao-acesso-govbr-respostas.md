# Autorização de acesso com GOV.BR — respostas às questões em aberto

## Contexto

Este documento propõe respostas às perguntas que a proposta de autorização de acesso com GOV.BR ainda não cobre. A proposta segue como alternativa de design em avaliação, e cada resposta abaixo depende de decisão conjunta da equipe (pratica.md, seções 25 e 27).

## 1. Como autorizar o acesso de forma segura?

- **Identidade do paciente:** o GOV.BR autentica o paciente no MeuPEP, com conta nível prata ou ouro.
- **Presença no atendimento:** o paciente gera um QRCode pelo MeuPEP permitindo a aplicação clínica a acessar os dados, o estabelecimento de saúde lê o código QR e acessa os dados.
-     O paciente deverá permitir o acesso por tempo determinado por ele, com a opção de selecionar tempo indeterminado
-     O paciente deverá selecionar quais dados permitirá que o estabelecimento acesse
-     A autorização vale para todo o estabelecimento de saúde, não apenas para o profissional específico
-     Sempre deverá apresentar a opção de revogar ou editar a autorização
- **Canal entre sistemas:** a comunicação entre aplicação clínica e MeuPEP usa o certificado digital do estabelecimento.

Ao aprovar, o MeuPEP cria um registro de consentimento (recurso FHIR `Consent`) e emite um token com escopo e prazo definidos. O acesso expira sozinho, e o paciente pode revogá-lo a qualquer momento no MeuPEP.

Se o paciente recusar, ou não responder dentro do prazo da solicitação, a aplicação clínica recebe "não autorizado".

## 2. Como provar que foi o próprio paciente quem autorizou?

Usar a assinatura eletrônica avançada do GOV.BR (Lei 14.063/2020).

O paciente recebe um comprovante e passa a ver, no MeuPEP, o histórico de quem acessou seus dados.

## 3. Como garantir que é o estabelecimento X com o profissional Y?

O acesso será concedido pelo paciente, logo, ele já estará ciente de qual estabelecimento esta autorizando.

## 4. Como restringir o acesso conforme o tipo de profissional?

Os acessos serão concedidos ao estabelecimento pelo paciente

Antes de autorizar, o paciente vê na tela o que será compartilhado.

## 5. Como tornar o digital mais vantajoso que o papel?

O fluxo digital oferece o que o papel não consegue oferecer, para os dois lados do atendimento.

- **Paciente:** autoriza em segundos pelo celular, vê quem acessou seus dados e revoga quando quiser.
- **Profissional:** recebe o histórico completo sem depender de exames e cópias trazidos pelo paciente.

## 6. Impressão para falta de energia ou internet

No atendimento sem energia, o fluxo de contingência é este:

1. O profissional confere a identidade do paciente por documento oficial com foto.
2. O paciente assina um termo de autorização em papel, com estabelecimento, profissional, finalidade e prazo, retirado de um kit de contingência mantido pela clínica.
3. O profissional atende com base no impresso que o paciente trouxer, se houver, e registra o atendimento em papel.
4. Quando a energia voltar, o profissional lança o termo e o atendimento no sistema.
5. O MeuPEP envia ao paciente a autorização lançada para confirmação. Se ele não reconhecer, o caso vai para o DPO.

Em emergência sem energia, vale a regra de acesso emergencial da seção 8, com justificativa registrada em papel e lançada depois. Toda impressão e todo termo em papel entram na auditoria.

## 7. Papel do DPO

Em emergência, o profissional aciona um acesso emergencial com justificativa obrigatória, e o DPO é notificado na hora e revisa o caso depois. A LGPD (art. 11, II) já permite esse acesso sem consentimento para proteger a vida e a saúde, e uma aprovação prévia atrasaria o atendimento.

Se a equipe preferir que o DPO aprove antes, será preciso garantir plantão 24/7 com substituto. Nos dois modelos, o DPO:

- audita os acessos;
- recebe denúncias dos pacientes pelo MeuPEP;
- pode suspender acessos indevidos e abrir incidentes.9. Acesso do DPO à Plataforma GO

## 8. Acesso do DPO à Plataforma GO

O DPO tem um perfil próprio, separado dos perfis clínicos.

- **Autenticação:** GOV.BR ouro, certificado digital e segundo fator.
- **Visão padrão:** painel de auditoria com quem acessou, quando, o quê e para qual finalidade, sem conteúdo clínico.
- **Conteúdo clínico:** só é aberto mediante justificativa registrada.
- **Auditoria do próprio DPO:** as ações dele também ficam registradas e são revisadas por um comitê ou instância independente.
