Contêineres Executáveis

| Contêiner | Analogia | O que faz na prática |
| --- | --- | --- |
| Gateway de Integração | Porta de entrada | Autentica usuários, controla limites de acesso e roteia as chamadas para o serviço correto. |
| Servidor FHIR R4 | Banco de dados central | Mantém o estado clínico compartilhado para permitir buscas e consultas de histórico. |
| Serviço de Validação e Terminologia | Corretor automático | Verifica se os dados estão no formato correto e traduz termos médicos usando memórias temporárias. |
| Serviço de Validação de Assinaturas Digitais | Perito de segurança | Verifica a validade e a segurança das assinaturas digitais nos documentos recebidos. |
| Serviço de Documentos RNDS | Gestor de comunicação | Valida e publica documentos na RNDS simulada, conectando códigos locais aos da rede nacional. |
| Montador Efêmero de IPS | Consolidador de informações | Junta dados de várias fontes e constrói o novo Sumário Internacional do Paciente (IPS). |
| Serviço de Interoperabilidade de Medicamentos | Organizador de medicamentos | Conecta informações de prescrição, dispensação e administração sem alterar a responsabilidade original de cada etapa. |
| Adaptador FHIR-SISCAN | Tradutor técnico | Converte os dados do padrão FHIR para a linguagem específica exigida pelo sistema SISCAN. |
| Serviço de Eventos e Subscriptions | Sistema de alarmes | Detecta mudanças no servidor clínico e envia notificações automáticas aos sistemas inscritos. |
| Serviço de Medidas CQL | Calculador de indicadores | Analisa dados clínicos para calcular metas e gerar relatórios agregados de saúde. |
| CDS Services | Assistente em tempo real | Devolve orientações e alertas rápidos aos profissionais de saúde durante o fluxo de atendimento. |
| Coletor de Auditoria | Triagem de segurança | Recebe informações sobre quem acessou os dados, reduz ao mínimo necessário e encaminha para armazenamento. |
| Coletor de Telemetria | Monitor de funcionamento | Recebe e processa os logs de erro, rastros de uso e métricas operacionais da plataforma. |

Contêineres de Dados

| Contêiner | Analogia | O que faz na prática |
| --- | --- | --- |
| Repositório Transacional Efêmero | Banco de dados temporário | Guarda dados do Montador de IPS e sessões de forma temporária, apagando tudo após expirar o prazo. |
| Quarentena Temporária de Medicamentos | Sala de espera segura | Isola de forma oculta registros de medicamentos que estão aguardando a chegada de um documento pendente. |
| Repositório de Auditoria | Cofre da plataforma | Guarda com segurança e restrição todas as evidências de quem acessou e alterou informações. |
| Repositório de Telemetria | Arquivo histórico técnico | Armazena apenas o desempenho e a saúde do sistema tecnológico, sem reter conteúdo clínico dos pacientes. |
