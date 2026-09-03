A proposta de autorização é utilizando apenas o GOV.BR como mecanismo de autenticação. 

Um caso em que vamos usar para ilustrar o modo de concessão de acesso aos dados pela parte do paciente ao estabelecimento de saúde é:

Paciente chegou com o GOV.BR aberto.
O profissional vê o paciente e solicita que abra o app Expresso Goiás e autentique-se com sua conta gov.br
Após o paciente estar autenticado no MeuPEP do Expresso Goiás, o profissional solicita na Aplicação clínica a adição de 
mais uma autorização de acesso ao dados por parte do estabelecimento. O profissional solicita o número de CPF do paciente
preenche esse dado na aplicação clínica  e envia a solicitação.
 Aparece na lista de solicitações do MeuPep uma solicitação de acesso aos dados com informação de data e hora de seu envio.
 O paciente abre a última solicitação enviada e consegue ler o seguinte:
 O estabelecimento solicitante, o profissional, a duração do acesso, um botão para autorizar e um botão para não autorizar.

 Se o botão de autorizar for pressionado o próprio celular exige biometria ou mecanismo de desbloqueio que o paciente já
  utiliza em seu celular. Após essa segunda verificação o paciente autorizou com sucesso o acesso aos seus dados por parte
  do estabelecimento por um tempo determinado pelo profissional solicitante na solicitação de acesso.

  O GOV.BR autentica José no Expresso Goiás e concede acesso ao MeuPep, O celular do José estando no MeuPep é usado para 
  aprovar a solicitação de acesso aos dados por parte da aplicação clínica do estabelecimento.

Código do diagrama de sequência:

@startuml
title Fluxo de Autorização de Acesso aos Dados de Saúde - Expresso Goiás (MeuPEP)

actor "Paciente\nJosé" as Jose
actor "Profissional de Saúde" as Profissional

participant "Aplicação Clínica\n(Estabelecimento de Saúde)" as AppClinica
participant "Expresso Goiás\n(MeuPEP)" as MeuPEP
participant "Serviço de Identidade\nGOV.BR" as GovBR


== Autenticação do paciente no Expresso Goiás (MeuPEP) ==

Profissional -> Jose: Solicita abertura do\nExpresso Goiás (MeuPEP)

Jose -> MeuPEP: Abre aplicativo\nExpresso Goiás (MeuPEP)

MeuPEP -> GovBR: Solicita autenticação\ndo cidadão

GovBR -> Jose: Solicita autenticação\nna conta GOV.BR

Jose -> GovBR: Realiza autenticação\ncom conta GOV.BR

GovBR --> MeuPEP: Confirma identidade\nJosé autenticado

MeuPEP --> Jose: Acesso liberado\nao MeuPEP


note right of MeuPEP
O GOV.BR realiza apenas a
autenticação da identidade
do cidadão.

Após validado, o José acessa
o ambiente seguro do MeuPEP.
end note


== Solicitação de acesso pelo estabelecimento ==

Profissional -> AppClinica: Solicita nova autorização\nde acesso aos dados do paciente

AppClinica -> Profissional: Solicita CPF do paciente

Profissional -> AppClinica: Informa CPF do José

AppClinica -> MeuPEP: Envia solicitação de acesso\n\nDados enviados:\n- CPF do paciente\n- Estabelecimento solicitante\n- Profissional solicitante\n- Finalidade do acesso\n- Duração desejada


MeuPEP -> MeuPEP: Registra solicitação\ncom data e hora

MeuPEP -> Jose: Disponibiliza nova solicitação\nde autorização


== Paciente analisa solicitação ==

Jose -> MeuPEP: Abre solicitação recebida

MeuPEP -> Jose: Exibe informações:\n\n- Estabelecimento solicitante\n- Profissional solicitante\n- Finalidade do acesso\n- Duração do acesso\n\n[Autorizar]\n[Não autorizar]


alt Paciente autoriza

    Jose -> MeuPEP: Pressiona "Autorizar"

    MeuPEP -> Jose: Solicita autenticação local\ndo dispositivo\n\n(Biometria ou desbloqueio)

    Jose -> MeuPEP: Confirma identidade\nusando mecanismo do celular

    MeuPEP -> MeuPEP: Registra autorização\n\nCria autorização de acesso:\n- Paciente José\n- Estabelecimento autorizado\n- Profissional solicitante\n- Período autorizado\n- Finalidade

    MeuPEP --> AppClinica: Retorna acesso autorizado

    AppClinica -> Profissional: Dados disponíveis\nconforme regras de acesso

else Paciente não autoriza
@enduml
