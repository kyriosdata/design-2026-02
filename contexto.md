# Explicação do Diagrama de Contexto - Plataforma de Saúde Integrada

Aqui está uma explicação simples e direta do seu diagrama, dividida em três partes principais:

## 1. O Coração do Sistema
*   **Plataforma GO:** É o "cérebro" central da operação. Ela recebe, organiza e valida todos os dados clínicos de saúde, garantindo que diferentes sistemas consigam "conversar" entre si usando uma linguagem padrão (FHIR R4).

## 2. Quem usa e como (Acesso e Entrada de Dados)
*   **Pacientes e Profissionais de Saúde:** Eles interagem com os **Sistemas Clientes** (como os prontuários eletrônicos). O médico registra a consulta e o sistema envia esses dados para a Plataforma GO.
*   **Gestor de Saúde:** Acessa apenas o **Sistema Aplicação Administrativa**. Em vez de ver o prontuário individual de um paciente, o gestor consome dados agregados e painéis gerados pela Plataforma GO para tomar decisões e criar políticas públicas.

## 3. Integrações (Troca de Informações com o Mundo Externo)
A Plataforma GO não guarda a informação só para ela; ela repassa e busca dados em outros grandes sistemas governamentais e de parceiros:
*   **RNDS:** Troca de dados com a rede do Ministério da Saúde (Governo Federal).
*   **Plataforma Estadual PAR:** Integração regional com o estado parceiro.
*   **SISCAN:** Envio de dados específicos sobre acompanhamento de câncer.
*   **Outras Plataformas:** Uma "porta aberta" genérica para plugar sistemas de terceiros ou futuras tecnologias.

