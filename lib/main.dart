// main.dart
// main.dart - Estude Ágil
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart' show sha256;
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

void main() => runApp(const EstudeAgilApp());

const azul = Color(0xFF1E6FD9);
const cinza = Color(0xFF5B6472);
const borda = Color(0xFFDDE3EE);
const fundoSuave = Color(0xFFF3F6FB);

/* ============================ CONTEÚDO ============================ */

class Pergunta {
  final String texto;
  final List<String> alternativas;
  final int correta;
  final String explicacao;
  final int?
      pagina; // página do Guia do Scrum para reler (null = sem referência)
  const Pergunta(this.texto, this.alternativas, this.correta, this.explicacao,
      [this.pagina]);
}

class Etapa {
  final String id, titulo, resumo;
  final List<Pergunta> perguntas; // banco de perguntas da etapa
  final int? guiaPagina;
  const Etapa(this.id, this.titulo, this.resumo, this.perguntas,
      {this.guiaPagina});
}

const int porTentativa = 3; // perguntas sorteadas a cada quiz
const int totalPaginasGuia = 16;

class Certificacao {
  final String sigla, nome, descricao, emoji;
  final Color cor, fundo;
  final List<Etapa> etapas;
  const Certificacao(this.sigla, this.nome, this.descricao, this.emoji,
      this.cor, this.fundo, this.etapas);
}

const certificacoes = <Certificacao>[
  Certificacao(
    'PSM I',
    'Professional Scrum Master I',
    'Fundamentos do framework Scrum e papel do Scrum Master.',
    '⚡',
    Color(0xFF1E6FD9),
    Color(0xFFE8F0FC),
    [
      Etapa(
          'psm1-1',
          'Fundamentos de Scrum',
          'Scrum é um framework leve que ajuda pessoas, times e organizações a gerar valor por meio de soluções adaptativas para problemas complexos.\n\n'
              'Baseia-se no empirismo e no lean thinking. O empirismo afirma que o conhecimento vem da experiência; o lean thinking reduz o desperdício. Seus três pilares são Transparência, Inspeção e Adaptação. A inspeção sem adaptação é considerada inútil.\n\n'
              'Os valores do Scrum são Comprometimento, Foco, Abertura, Respeito e Coragem.\n\n'
              'A Sprint é o coração do Scrum: um evento de no máximo um mês em que as ideias viram valor. Implementar apenas partes do Scrum não resulta em Scrum.',
          [
            Pergunta(
                'Quais são os três pilares do empirismo no Scrum?',
                [
                  'Planejamento, Execução e Entrega',
                  'Transparência, Inspeção e Adaptação',
                  'Foco, Respeito e Coragem',
                  'Papéis, Eventos e Artefatos'
                ],
                1,
                'Transparência, Inspeção e Adaptação sustentam a teoria empírica do Scrum.',
                5),
            Pergunta(
                'Qual opção lista corretamente os valores do Scrum?',
                [
                  'Clareza, Autonomia, Acessibilidade e Melhoria',
                  'Comprometimento, Foco, Abertura, Respeito e Coragem',
                  'Qualidade, Prazo, Custo e Escopo',
                  'Velocidade, Entrega, Feedback e Lucro'
                ],
                1,
                'O Scrum Guide 2020 define cinco valores: Comprometimento, Foco, Abertura, Respeito e Coragem.',
                5),
            Pergunta(
                'Qual é a duração máxima de uma Sprint?',
                [
                  'Duas semanas',
                  'Três semanas',
                  'Um mês ou menos',
                  'Não há limite'
                ],
                2,
                'Sprints têm duração fixa de um mês ou menos, para manter a previsibilidade.',
                8),
            Pergunta(
                'Em quais duas ideias o Scrum é baseado?',
                [
                  'Empirismo e lean thinking',
                  'Planejamento detalhado e controle de custos',
                  'Hierarquia e especialização funcional',
                  'Cascata e gestão por marcos'
                ],
                0,
                'O Scrum é baseado no empirismo (conhecimento vem da experiência) e no lean thinking (reduz desperdício e foca no essencial).',
                4),
            Pergunta(
                'O que o Guia afirma sobre implementar apenas partes do Scrum?',
                [
                  'Funciona igualmente bem',
                  'O resultado não é Scrum',
                  'É recomendado para times pequenos',
                  'É permitido se o Product Owner autorizar'
                ],
                1,
                'O Scrum existe apenas em sua totalidade; implementar só partes não resulta em Scrum.',
                15),
            Pergunta(
                'Segundo o Guia, o que acontece com a inspeção sem adaptação?',
                [
                  'É considerada inútil',
                  'Gera mais transparência',
                  'Substitui a Sprint Review',
                  'Torna-se opcional'
                ],
                0,
                'A inspeção habilita a adaptação, e a inspeção sem adaptação é considerada inútil.',
                5),
          ],
          guiaPagina: 4),
      Etapa(
          'psm1-2',
          'Scrum Team',
          'O Scrum Team é uma unidade coesa, sem sub-times nem hierarquias, focada em um objetivo por vez: o Product Goal. Normalmente tem 10 pessoas ou menos.\n\n'
              'É autogerenciável: decide internamente quem faz o quê, quando e como. É formado por um Scrum Master, um Product Owner e Developers.\n\n'
              'O Product Owner maximiza o valor do produto e gerencia o Product Backlog. Os Developers criam um Incremento utilizável a cada Sprint e o plano da Sprint. '
              'O Scrum Master estabelece o Scrum conforme o Guia, ajudando todos a entender a teoria e a prática.',
          [
            Pergunta(
                'Quantos Product Owners um Scrum Team possui?',
                [
                  'Um',
                  'Dois',
                  'Um por Developer',
                  'Depende do tamanho do time'
                ],
                0,
                'O Product Owner é uma pessoa, não um comitê.',
                7),
            Pergunta(
                'Quem cria o plano da Sprint (Sprint Backlog)?',
                [
                  'O Product Owner',
                  'O Scrum Master',
                  'Os Developers',
                  'Os stakeholders'
                ],
                2,
                'Os Developers criam o plano da Sprint, pois são eles que farão o trabalho.',
                6),
            Pergunta(
                'Qual é a principal responsabilidade do Scrum Master?',
                [
                  'Atribuir tarefas ao time',
                  'Aprovar as entregas',
                  'Estabelecer o Scrum conforme o Guia e ajudar todos a entendê-lo',
                  'Definir a ordem do Product Backlog'
                ],
                2,
                'O Scrum Master é um líder-servidor: promove e apoia o Scrum, sem gerenciar o time.',
                7),
            Pergunta(
                'Qual é o tamanho típico de um Scrum Team?',
                [
                  '10 pessoas ou menos',
                  'Exatamente 7 pessoas',
                  'Entre 15 e 20 pessoas',
                  'Não há recomendação'
                ],
                0,
                'O Guia indica normalmente 10 pessoas ou menos: pequeno para ser ágil, grande para concluir trabalho significativo.',
                6),
            Pergunta(
                'O que significa um Scrum Team ser autogerenciável?',
                [
                  'Decide internamente quem faz o quê, quando e como',
                  'O Scrum Master distribui as tarefas',
                  'O Product Owner define o como',
                  'Segue ordens de um gerente funcional'
                ],
                0,
                'O time decide internamente quem faz o quê, quando e como.',
                6),
            Pergunta(
                'Existem sub-times ou hierarquias dentro de um Scrum Team?',
                [
                  'Não, é uma unidade coesa sem sub-times ou hierarquias',
                  'Sim, os Developers formam um sub-time',
                  'Sim, o Scrum Master é o chefe do time',
                  'Sim, um por especialidade'
                ],
                0,
                'Dentro de um Scrum Team não há sub-times nem hierarquias.',
                6),
          ],
          guiaPagina: 6),
      Etapa(
          'psm1-3',
          'Eventos e artefatos',
          'Os eventos são: Sprint (que contém os demais), Sprint Planning, Daily Scrum, Sprint Review e Sprint Retrospective.\n\n'
              'A Sprint Planning tem timebox máximo de oito horas para uma Sprint de um mês. A Daily Scrum dura 15 minutos e serve para os Developers inspecionarem o progresso rumo ao Sprint Goal. A Sprint Retrospective conclui a Sprint.\n\n'
              'Os artefatos são Product Backlog, Sprint Backlog e Incremento, com os compromissos Product Goal, Sprint Goal e Definição de Pronto. Um Incremento nasce quando um item atende à Definição de Pronto.\n\n'
              'Somente o Product Owner pode cancelar uma Sprint.',
          [
            Pergunta(
                'Qual é a duração da Daily Scrum?',
                ['30 minutos', '15 minutos', '1 hora', 'Depende da Sprint'],
                1,
                'A Daily Scrum é um evento de 15 minutos, realizado todos os dias da Sprint.',
                10),
            Pergunta(
                'Qual é o compromisso associado ao Product Backlog?',
                [
                  'Sprint Goal',
                  'Definição de Pronto',
                  'Product Goal',
                  'Velocity'
                ],
                2,
                'Product Goal → Product Backlog; Sprint Goal → Sprint Backlog; Definição de Pronto → Incremento.',
                12),
            Pergunta(
                'Quem pode cancelar uma Sprint?',
                [
                  'O Scrum Master',
                  'Os Developers',
                  'Os stakeholders',
                  'Somente o Product Owner'
                ],
                3,
                'Somente o Product Owner pode cancelar, quando o Sprint Goal se torna obsoleto.',
                9),
            Pergunta(
                'Qual é o timebox máximo da Sprint Planning em uma Sprint de um mês?',
                ['Quatro horas', 'Oito horas', 'Três horas', 'Quinze minutos'],
                1,
                'Para uma Sprint de um mês, a Sprint Planning tem no máximo oito horas.',
                10),
            Pergunta(
                'Qual evento conclui a Sprint?',
                [
                  'Sprint Review',
                  'Daily Scrum',
                  'Sprint Retrospective',
                  'Sprint Planning'
                ],
                2,
                'A Sprint Review é o penúltimo evento; a Sprint Retrospective conclui a Sprint.',
                11),
            Pergunta(
                'Quando um Incremento "nasce"?',
                [
                  'Quando o item atende à Definição de Pronto',
                  'Quando o Product Owner aprova a ideia',
                  'Quando a Sprint Review termina',
                  'Quando o Scrum Master libera o código'
                ],
                0,
                'No momento em que um item do Product Backlog atende à Definição de Pronto, um Incremento nasce.',
                13),
          ],
          guiaPagina: 8),
    ],
  ),
  Certificacao(
    'PSPO',
    'Professional Scrum Product Owner',
    'Maximização de valor do produto e gestão do Product Backlog.',
    '🎯',
    Color(0xFF7C3AED),
    Color(0xFFF1EAFD),
    [
      Etapa(
          'pspo-1',
          'Papel do Product Owner',
          'O Product Owner é responsável por maximizar o valor do produto resultante do trabalho do Scrum Team. É uma pessoa, não um comitê.\n\n'
              'Ele pode delegar o trabalho de gerenciar o Product Backlog, mas continua sendo o responsável por ele. Ele cria e comunica os itens, os ordena e garante a transparência do Product Backlog.\n\n'
              'Pode representar as necessidades de muitos stakeholders. Quem deseja alterar o Product Backlog tenta convencer o Product Owner. Para ter sucesso, toda a organização deve respeitar suas decisões, visíveis na ordem do Product Backlog e no Incremento inspecionável na Sprint Review.',
          [
            Pergunta(
                'Quem é responsável por maximizar o valor do produto?',
                [
                  'O Scrum Master',
                  'O Product Owner',
                  'Os Developers',
                  'O gerente de projetos'
                ],
                1,
                'O Product Owner responde por maximizar o valor do produto resultante do trabalho do Scrum Team.',
                7),
            Pergunta(
                'O Product Owner pode delegar o gerenciamento do Product Backlog?',
                [
                  'Não, deve fazer tudo sozinho',
                  'Sim, mas continua sendo o responsável',
                  'Sim, e deixa de ser responsável',
                  'Somente ao Scrum Master'
                ],
                1,
                'Ele pode delegar tarefas, mas segue como o responsável pelo Product Backlog.',
                7),
            Pergunta(
                'Como as decisões do Product Owner ficam visíveis?',
                [
                  'Por relatórios mensais de status',
                  'Pela Daily Scrum',
                  'Pelo conteúdo e ordem do Product Backlog e pelo Incremento',
                  'Por e-mails aos stakeholders'
                ],
                2,
                'Suas decisões aparecem no Product Backlog e no Incremento inspecionado na Sprint Review.',
                7),
            Pergunta(
                'O Product Owner pode representar as necessidades de quem no Product Backlog?',
                [
                  'De muitos stakeholders',
                  'Apenas dos Developers',
                  'Apenas do Scrum Master',
                  'Somente da diretoria'
                ],
                0,
                'O Product Owner pode representar as necessidades de muitos stakeholders no Product Backlog.',
                7),
            Pergunta(
                'Como um stakeholder pode alterar o Product Backlog?',
                [
                  'Tentando convencer o Product Owner',
                  'Editando o backlog diretamente',
                  'Pedindo ao Scrum Master',
                  'Votando em uma reunião'
                ],
                0,
                'Quem deseja alterar o Product Backlog deve tentar convencer o Product Owner.',
                7),
            Pergunta(
                'Qual é uma responsabilidade do Product Owner no Product Backlog?',
                [
                  'Ordenar os itens do Product Backlog',
                  'Dimensionar todos os itens sozinho',
                  'Facilitar a Daily Scrum',
                  'Escolher quem faz cada tarefa'
                ],
                0,
                'Ele desenvolve a Meta do Produto, cria e comunica itens, ordena e garante a transparência. O dimensionamento é dos Developers.',
                7),
          ],
          guiaPagina: 7),
      Etapa(
          'pspo-2',
          'Product Backlog e Product Goal',
          'O Product Backlog é uma lista emergente e ordenada do que é necessário para melhorar o produto. É a única fonte de trabalho do Scrum Team.\n\n'
              'O refinamento é o ato contínuo de quebrar e definir melhor os itens. Itens que cabem em uma Sprint estão prontos para seleção. Os Developers são responsáveis pelo dimensionamento; o Product Owner pode ajudá-los a entender trade-offs.\n\n'
              'O Product Goal descreve um estado futuro do produto e é o compromisso do Product Backlog. O time deve cumprir (ou abandonar) um Product Goal antes de assumir o próximo.',
          [
            Pergunta(
                'Qual é o compromisso do Product Backlog?',
                [
                  'Sprint Goal',
                  'Product Goal',
                  'Definição de Pronto',
                  'Release Plan'
                ],
                1,
                'O Product Goal é o compromisso do Product Backlog.',
                12),
            Pergunta(
                'O que é o refinamento do Product Backlog?',
                [
                  'Uma reunião obrigatória de quatro horas',
                  'Apagar itens antigos ao fim da Sprint',
                  'O ato contínuo de quebrar e definir melhor os itens',
                  'Estimar o custo total do projeto'
                ],
                2,
                'Refinar é quebrar e detalhar itens, de forma contínua, para deixá-los mais precisos.',
                12),
            Pergunta(
                'Quantos Product Goals o Scrum Team persegue por vez?',
                ['Um', 'Um por Developer', 'Três', 'Quantos forem necessários'],
                0,
                'O Scrum Team foca em um objetivo de cada vez: o Product Goal.',
                12),
            Pergunta(
                'Quem é responsável pelo dimensionamento dos itens do Product Backlog?',
                [
                  'Os Developers',
                  'O Product Owner sozinho',
                  'O Scrum Master',
                  'Os stakeholders'
                ],
                0,
                'Os Developers que farão o trabalho dimensionam; o Product Owner pode influenciar ajudando com trade-offs.',
                12),
            Pergunta(
                'Como o Guia descreve o Product Backlog?',
                [
                  'Uma lista ordenada e emergente do que é necessário para melhorar o produto',
                  'Um documento fechado no início do projeto',
                  'O plano detalhado de uma Sprint',
                  'Uma lista de erros encontrados'
                ],
                0,
                'É uma lista emergente e ordenada, e a única fonte de trabalho do Scrum Team.',
                12),
            Pergunta(
                'O que o Scrum Team deve fazer com um Product Goal antes de assumir o próximo?',
                [
                  'Cumprir ou abandonar o atual',
                  'Trabalhar nos dois ao mesmo tempo',
                  'Pedir autorização ao gerente',
                  'Nada, pode trocar a qualquer momento'
                ],
                0,
                'O time deve cumprir (ou abandonar) um objetivo antes de assumir o próximo.',
                12),
          ],
          guiaPagina: 12),
      Etapa(
          'pspo-3',
          'Sprint Review e stakeholders',
          'A Sprint Review inspeciona o resultado da Sprint e determina adaptações futuras. O Scrum Team apresenta os resultados aos principais stakeholders e discute o progresso rumo ao Product Goal.\n\n'
              'É uma sessão de trabalho, e o time deve evitar limitá-la a uma apresentação. Tem timebox máximo de quatro horas para uma Sprint de um mês. O Product Backlog pode ser ajustado para atender a novas oportunidades.\n\n'
              'Stakeholders são pessoas de fora do Scrum Team interessadas no produto.',
          [
            Pergunta(
                'Qual é o propósito da Sprint Review?',
                [
                  'Avaliar o desempenho individual dos Developers',
                  'Inspecionar o resultado da Sprint e determinar adaptações futuras',
                  'Planejar a próxima Sprint em detalhes',
                  'Aprovar o orçamento do projeto'
                ],
                1,
                'A Sprint Review inspeciona o resultado e define adaptações.',
                11),
            Pergunta(
                'Quem participa da Sprint Review?',
                [
                  'Somente os Developers',
                  'Somente o Product Owner',
                  'O Scrum Team e os principais stakeholders',
                  'Apenas a gerência'
                ],
                2,
                'O Scrum Team e os principais stakeholders colaboram na Sprint Review.',
                11),
            Pergunta(
                'O que são stakeholders?',
                [
                  'Pessoas de fora do Scrum Team interessadas no produto',
                  'Os Developers do time',
                  'Os fornecedores de software',
                  'Somente os clientes pagantes'
                ],
                0,
                'Stakeholders são pessoas externas ao Scrum Team com interesse no produto.'),
            Pergunta(
                'Qual é o timebox máximo da Sprint Review em uma Sprint de um mês?',
                ['Quatro horas', 'Oito horas', 'Três horas', 'Uma hora'],
                0,
                'Para uma Sprint de um mês, a Sprint Review tem no máximo quatro horas.',
                11),
            Pergunta(
                'O que o Scrum Team deve evitar na Sprint Review?',
                [
                  'Limitá-la a uma apresentação',
                  'Discutir o progresso rumo ao Product Goal',
                  'Revisar o que mudou no ambiente',
                  'Ajustar o Product Backlog'
                ],
                0,
                'A Sprint Review é uma sessão de trabalho, e não deve se limitar a uma apresentação.',
                11),
            Pergunta(
                'O Product Backlog pode ser ajustado na Sprint Review?',
                [
                  'Sim, para atender a novas oportunidades',
                  'Não, ele é fechado durante a Sprint',
                  'Somente pelo Scrum Master',
                  'Somente após a Sprint Retrospective'
                ],
                0,
                'O Product Backlog também pode ser ajustado para atender a novas oportunidades.',
                11),
          ],
          guiaPagina: 11),
    ],
  ),
  Certificacao(
    'PMP',
    'Project Management Professional',
    'Gerenciamento de projetos preditivos, ágeis e híbridos.',
    '📊',
    Color(0xFF0F766E),
    Color(0xFFE3F3F0),
    [
      Etapa(
          'pmp-1',
          'Fundamentos de projetos',
          'Um projeto é um esforço temporário para criar um produto, serviço ou resultado único, com início e fim definidos. Existe para entregar valor e benefícios à organização.\n\n'
              'Operações, ao contrário, são atividades contínuas e repetitivas.\n\n'
              'O gerente de projetos é a pessoa designada para liderar a equipe e atingir os objetivos do projeto, equilibrando restrições como escopo, cronograma, custo e qualidade. O termo de abertura autoriza formalmente o projeto.',
          [
            Pergunta(
                'O que caracteriza um projeto?',
                [
                  'Ser contínuo e repetitivo',
                  'Ser temporário e gerar um resultado único',
                  'Não ter data de término',
                  'Ser sempre de longa duração'
                ],
                1,
                'Projetos são temporários e entregam um produto, serviço ou resultado único.'),
            Pergunta(
                'Qual é a diferença entre projeto e operação?',
                [
                  'Operações são contínuas e repetitivas; projetos são temporários',
                  'Projetos são contínuos; operações são temporárias',
                  'Não há diferença',
                  'Operações sempre geram resultados únicos'
                ],
                0,
                'Operações são contínuas e repetitivas; projetos têm começo e fim.'),
            Pergunta(
                'Quem lidera a equipe para atingir os objetivos do projeto?',
                [
                  'O patrocinador',
                  'O gerente de projetos',
                  'O cliente',
                  'O time de suporte'
                ],
                1,
                'O gerente de projetos é designado para liderar a equipe rumo aos objetivos.'),
            Pergunta(
                'Quais são restrições clássicas de um projeto?',
                [
                  'Escopo, cronograma e custo',
                  'Cor do logotipo e local do escritório',
                  'Número de reuniões',
                  'Idioma e fuso horário'
                ],
                0,
                'Escopo, cronograma e custo são restrições clássicas que o gerente precisa equilibrar.'),
            Pergunta(
                'Qual documento autoriza formalmente o projeto?',
                [
                  'Termo de abertura do projeto',
                  'Registro de riscos',
                  'Cronograma detalhado',
                  'Relatório de status'
                ],
                0,
                'O termo de abertura autoriza formalmente o projeto e dá autoridade ao gerente.'),
            Pergunta(
                'Qual é o propósito de um projeto para a organização?',
                [
                  'Entregar valor e benefícios',
                  'Manter a rotina operacional',
                  'Aumentar a burocracia',
                  'Substituir a estratégia'
                ],
                0,
                'Projetos existem para entregar valor e benefícios à organização.'),
          ]),
      Etapa(
          'pmp-2',
          'Abordagens preditiva, ágil e híbrida',
          'Na abordagem preditiva (cascata), escopo, prazo e custo são planejados em detalhe no início, e as mudanças passam por controle formal. Serve bem a requisitos estáveis.\n\n'
              'Na abordagem ágil, o trabalho é iterativo e incremental, com entregas frequentes e feedback constante.\n\n'
              'A abordagem híbrida combina elementos das duas, conforme a necessidade do projeto.',
          [
            Pergunta(
                'Na abordagem preditiva, quando o planejamento é feito em detalhe?',
                [
                  'Somente no fim do projeto',
                  'No início do projeto',
                  'A cada iteração, sem plano geral',
                  'Nunca'
                ],
                1,
                'Na preditiva, o plano detalhado é feito no início.'),
            Pergunta(
                'Qual abordagem se adapta melhor a requisitos que mudam com frequência?',
                [
                  'Preditiva (cascata)',
                  'Ágil',
                  'Nenhuma abordagem',
                  'Todas se adaptam igualmente'
                ],
                1,
                'A abordagem ágil acolhe mudanças com entregas curtas e feedback constante.'),
            Pergunta(
                'O que é a abordagem híbrida?',
                [
                  'Usar apenas ferramentas digitais',
                  'Combinar elementos preditivos e ágeis',
                  'Terceirizar todo o projeto',
                  'Trabalhar sem planejamento'
                ],
                1,
                'Híbrida é a combinação de práticas preditivas e ágeis.'),
            Pergunta(
                'Na abordagem ágil, como o trabalho é entregue?',
                [
                  'De forma iterativa e incremental',
                  'Em uma única entrega final',
                  'Somente após aprovação de todos os riscos',
                  'Sem feedback do cliente'
                ],
                0,
                'O trabalho é entregue em ciclos curtos (iterações) e em partes (incrementos).'),
            Pergunta(
                'Na abordagem preditiva, como costumam ser tratadas as mudanças?',
                [
                  'Por um processo formal de controle de mudanças',
                  'Aceitas livremente a qualquer momento',
                  'Ignoradas',
                  'Decididas pelo time sem registro'
                ],
                0,
                'Na preditiva, mudanças passam por controle formal.'),
            Pergunta(
                'Requisitos estáveis e entregas bem definidas combinam melhor com qual abordagem?',
                [
                  'Preditiva',
                  'Ágil, sem planejamento',
                  'Nenhuma das anteriores',
                  'Somente a híbrida'
                ],
                0,
                'Com requisitos estáveis, o planejamento antecipado da preditiva funciona bem.'),
          ]),
      Etapa(
          'pmp-3',
          'Riscos e partes interessadas',
          'Risco é um evento ou condição incerta que, se ocorrer, afeta os objetivos do projeto de forma positiva ou negativa.\n\n'
              'Ameaças podem ser evitadas, mitigadas, transferidas ou aceitas. Aceitar é reconhecer o risco sem ação proativa, às vezes mantendo uma reserva.\n\n'
              'Partes interessadas são pessoas, grupos ou organizações que podem afetar ou ser afetados pelo projeto. Identificá-las e engajá-las cedo ajuda a entender suas expectativas e influência.',
          [
            Pergunta(
                'O que é um risco em um projeto?',
                [
                  'Um problema que já aconteceu',
                  'Um evento ou condição incerta que pode afetar os objetivos',
                  'Uma falha da equipe',
                  'Uma mudança de escopo aprovada'
                ],
                1,
                'Risco é algo incerto que, se ocorrer, afeta os objetivos.'),
            Pergunta(
                'Contratar um seguro para cobrir um possível prejuízo é qual resposta a risco?',
                ['Evitar', 'Mitigar', 'Transferir', 'Aceitar'],
                2,
                'Seguro transfere o impacto financeiro do risco a um terceiro.'),
            Pergunta(
                'Quem são as partes interessadas de um projeto?',
                [
                  'Apenas a equipe do projeto',
                  'Pessoas ou grupos que podem afetar ou ser afetados pelo projeto',
                  'Somente o cliente',
                  'Apenas os fornecedores'
                ],
                1,
                'Partes interessadas incluem quem afeta ou é afetado pelo projeto.'),
            Pergunta(
                'Qual é uma resposta possível a uma ameaça?',
                ['Mitigar', 'Ampliar', 'Explorar', 'Compartilhar'],
                0,
                'Para ameaças: evitar, transferir, mitigar ou aceitar. Explorar, compartilhar e ampliar valem para oportunidades.'),
            Pergunta(
                'Por que identificar as partes interessadas logo no início?',
                [
                  'Para entender expectativas e influência e engajá-las',
                  'Para reduzir o escopo',
                  'Para evitar reuniões',
                  'Para dispensar o plano'
                ],
                0,
                'Identificá-las cedo permite entender expectativas e influência e planejar o engajamento.'),
            Pergunta(
                'O que significa aceitar um risco?',
                [
                  'Reconhecê-lo sem ação proativa, mantendo reserva se necessário',
                  'Eliminá-lo completamente',
                  'Transferi-lo a um terceiro',
                  'Reduzir sua probabilidade'
                ],
                0,
                'Aceitar é reconhecer o risco e não agir proativamente, podendo manter uma reserva.'),
          ]),
    ],
  ),
];

final todasEtapas = <Etapa>[for (final c in certificacoes) ...c.etapas];

Certificacao certDe(String etapaId) =>
    certificacoes.firstWhere((c) => c.etapas.any((e) => e.id == etapaId));
Etapa etapaPorId(String id) => todasEtapas.firstWhere((e) => e.id == id);

/* ============================ BANCO LOCAL ============================ */

class Usuario {
  final int id;
  final String nome, email;
  const Usuario(this.id, this.nome, this.email);
}

class Progresso {
  final bool leitura;
  final int? acertos, total;
  final String? concluidaEm;
  const Progresso(
      {this.leitura = false, this.acertos, this.total, this.concluidaEm});

  // Concluída se já foi concluída antes, ou se a tentativa atual cumpre a
  // regra: leitura confirmada + pelo menos 2 acertos em 3.
  bool get concluida => concluidaEm != null || (leitura && (acertos ?? 0) >= 2);
}

class Db {
  static Database? _db;

  static Future<Database> _abrir() async => _db ??= await openDatabase(
        p.join(await getDatabasesPath(), 'estude_agil_v2.db'),
        version: 1,
        onCreate: (d, v) async {
          await d.execute(
              'CREATE TABLE usuarios(id INTEGER PRIMARY KEY AUTOINCREMENT, nome TEXT NOT NULL, '
              'email TEXT NOT NULL UNIQUE, senha_hash TEXT NOT NULL, salt TEXT NOT NULL, criado_em TEXT NOT NULL)');
          await d.execute(
              'CREATE TABLE progresso(usuario_id INTEGER NOT NULL, etapa_id TEXT NOT NULL, '
              'leitura INTEGER NOT NULL DEFAULT 0, acertos INTEGER, total INTEGER, concluida_em TEXT, '
              'PRIMARY KEY(usuario_id, etapa_id))');
          await d.execute(
              'CREATE TABLE historico(id INTEGER PRIMARY KEY AUTOINCREMENT, usuario_id INTEGER NOT NULL, '
              'etapa_id TEXT NOT NULL, acertos INTEGER NOT NULL, total INTEGER NOT NULL, data TEXT NOT NULL)');
          await d.execute(
              'CREATE TABLE config(chave TEXT PRIMARY KEY, valor TEXT)');
        },
      );

  // ---- conta ----
  static String _hash(String senha, String salt) =>
      sha256.convert(utf8.encode('$salt:$senha')).toString();

  static String _novoSalt() {
    final r = Random.secure();
    return base64UrlEncode(List<int>.generate(16, (_) => r.nextInt(256)));
  }

  static Future<Usuario?> cadastrar(
      String nome, String email, String senha) async {
    final d = await _abrir();
    final e = email.trim().toLowerCase();
    final existe =
        await d.query('usuarios', where: 'email = ?', whereArgs: [e]);
    if (existe.isNotEmpty) return null;
    final salt = _novoSalt();
    final id = await d.insert('usuarios', {
      'nome': nome.trim(),
      'email': e,
      'senha_hash': _hash(senha, salt),
      'salt': salt,
      'criado_em': DateTime.now().toIso8601String(),
    });
    await definirSessao(id);
    return Usuario(id, nome.trim(), e);
  }

  static Future<Usuario?> entrar(String email, String senha) async {
    final d = await _abrir();
    final r = await d.query('usuarios',
        where: 'email = ?', whereArgs: [email.trim().toLowerCase()]);
    if (r.isEmpty) return null;
    final u = r.first;
    if (_hash(senha, u['salt'] as String) != u['senha_hash']) return null;
    final id = u['id'] as int;
    await definirSessao(id);
    return Usuario(id, u['nome'] as String, u['email'] as String);
  }

  static Future<void> definirSessao(int? id) async {
    final d = await _abrir();
    if (id == null) {
      await d
          .delete('config', where: 'chave = ?', whereArgs: ['usuario_atual']);
    } else {
      await d.insert('config', {'chave': 'usuario_atual', 'valor': '$id'},
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  static Future<Usuario?> sessaoAtual() async {
    final d = await _abrir();
    final c = await d
        .query('config', where: 'chave = ?', whereArgs: ['usuario_atual']);
    if (c.isEmpty) return null;
    final r = await d.query('usuarios',
        where: 'id = ?', whereArgs: [int.parse(c.first['valor'] as String)]);
    if (r.isEmpty) return null;
    return Usuario(r.first['id'] as int, r.first['nome'] as String,
        r.first['email'] as String);
  }

  // ---- progresso ----
  static Future<Map<String, Progresso>> carregar(int uid) async {
    final d = await _abrir();
    final rows =
        await d.query('progresso', where: 'usuario_id = ?', whereArgs: [uid]);
    return {
      for (final r in rows)
        r['etapa_id'] as String: Progresso(
          leitura: (r['leitura'] as int) == 1,
          acertos: r['acertos'] as int?,
          total: r['total'] as int?,
          concluidaEm: r['concluida_em'] as String?,
        ),
    };
  }

  static Future<void> _mesclar(
      int uid, String etapa, Map<String, Object?> novos) async {
    final d = await _abrir();
    final at = await d.query('progresso',
        where: 'usuario_id = ? AND etapa_id = ?', whereArgs: [uid, etapa]);
    final base = at.isEmpty
        ? <String, Object?>{'usuario_id': uid, 'etapa_id': etapa, 'leitura': 0}
        : Map<String, Object?>.from(at.first);
    base.addAll(novos);
    await d.insert('progresso', base,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> confirmarLeitura(int uid, String etapa, bool lido) =>
      _mesclar(uid, etapa, {'leitura': lido ? 1 : 0});

  static Future<bool> leituraConfirmada(int uid, String etapa) async =>
      (await carregar(uid))[etapa]?.leitura ?? false;

  static Future<void> salvarTentativa(
      int uid, String etapa, int acertos, int total, bool concluida) async {
    final agora = DateTime.now().toIso8601String();
    await _mesclar(uid, etapa, {
      'acertos': acertos,
      'total': total,
      if (concluida) 'concluida_em': agora
    });
    final d = await _abrir();
    await d.insert('historico', {
      'usuario_id': uid,
      'etapa_id': etapa,
      'acertos': acertos,
      'total': total,
      'data': agora
    });
  }

  static Future<List<Map<String, Object?>>> historico(int uid) async {
    final d = await _abrir();
    return d.query('historico',
        where: 'usuario_id = ?',
        whereArgs: [uid],
        orderBy: 'id DESC',
        limit: 8);
  }

  static Future<void> resetar(int uid) async {
    final d = await _abrir();
    await d.delete('progresso', where: 'usuario_id = ?', whereArgs: [uid]);
    await d.delete('historico', where: 'usuario_id = ?', whereArgs: [uid]);
  }
}

/* ============================ COMPONENTES ============================ */

Widget barra(double v, Color cor) => ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: LinearProgressIndicator(
          value: v, minHeight: 6, color: cor, backgroundColor: borda),
    );

Widget selo(Certificacao c) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration:
          BoxDecoration(color: c.fundo, borderRadius: BorderRadius.circular(6)),
      child: Text(c.sigla,
          style: TextStyle(
              color: c.cor, fontSize: 11, fontWeight: FontWeight.w700)),
    );

Widget rotulo(String t) => Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 8),
      child: Text(t,
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: cinza)),
    );

Widget campoTexto(TextEditingController c, String nome,
        {bool senha = false,
        TextInputType? tipo,
        String? Function(String?)? validar}) =>
    Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: c,
        obscureText: senha,
        keyboardType: tipo,
        validator: validar,
        decoration: InputDecoration(
            labelText: nome,
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
      ),
    );

String? obrigatorio(String? v) =>
    (v == null || v.trim().isEmpty) ? 'Campo obrigatório' : null;
String? validaEmail(String? v) =>
    RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch((v ?? '').trim())
        ? null
        : 'Informe um e-mail válido';
String? validaSenha(String? v) =>
    (v == null || v.length < 6) ? 'Mínimo de 6 caracteres' : null;

String dataCurta(String iso) {
  final d = DateTime.parse(iso);
  String dois(int n) => n.toString().padLeft(2, '0');
  return '${dois(d.day)}/${dois(d.month)}/${d.year}';
}

class Logo extends StatelessWidget {
  final double tamanho;
  const Logo({super.key, this.tamanho = 80});

  @override
  Widget build(BuildContext context) => Container(
        width: tamanho,
        height: tamanho,
        decoration: BoxDecoration(
          color: azul,
          borderRadius: BorderRadius.circular(tamanho * .28),
          boxShadow: const [
            BoxShadow(
                color: Color(0x331E6FD9), blurRadius: 18, offset: Offset(0, 8))
          ],
        ),
        child: Icon(Icons.bolt, color: Colors.white, size: tamanho * .6),
      );
}

/* ============================ APP ============================ */

class EstudeAgilApp extends StatelessWidget {
  const EstudeAgilApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Estude Ágil',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: azul),
          scaffoldBackgroundColor: Colors.white,
        ),
        home: const Inicio(),
      );
}

class Inicio extends StatefulWidget {
  const Inicio({super.key});
  @override
  State<Inicio> createState() => _InicioState();
}

class _InicioState extends State<Inicio> {
  late final Future<Usuario?> _sessao = Db.sessaoAtual();

  @override
  Widget build(BuildContext context) => FutureBuilder<Usuario?>(
        future: _sessao,
        builder: (ctx, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Scaffold(body: Center(child: Logo(tamanho: 88)));
          }
          final u = snap.data;
          return u == null ? const BemVindoScreen() : HomeScreen(usuario: u);
        },
      );
}

/* ---- Boas-vindas ---- */

class BemVindoScreen extends StatelessWidget {
  const BemVindoScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(flex: 2),
                const Center(child: Logo(tamanho: 96)),
                const SizedBox(height: 24),
                const Text('Estude Ágil',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                const Text(
                    'Preparação para certificações em Scrum e gestão de projetos',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: cinza)),
                const Spacer(flex: 3),
                const Text('Você já tem cadastro?',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 14),
                FilledButton(
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const LoginScreen())),
                  child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Text('Sim, quero entrar')),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const CadastroScreen())),
                  child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Text('Não, quero me cadastrar')),
                ),
                const SizedBox(height: 16),
                const Text('Não emite certificação oficial · fins educacionais',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: cinza)),
              ],
            ),
          ),
        ),
      );
}

/* ---- Login ---- */

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _senha = TextEditingController();
  String? _erro;
  bool _ocupado = false;

  Future<void> _entrar() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _ocupado = true;
      _erro = null;
    });
    final u = await Db.entrar(_email.text, _senha.text);
    if (!mounted) return;
    if (u == null) {
      setState(() {
        _ocupado = false;
        _erro = 'E-mail ou senha incorretos.';
      });
      return;
    }
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(usuario: u)),
        (r) => false);
  }

  @override
  void dispose() {
    _email.dispose();
    _senha.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Center(child: Logo(tamanho: 64)),
            const SizedBox(height: 20),
            const Text('Entrar',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            const Text('Informe seu e-mail e senha.',
                style: TextStyle(color: cinza)),
            const SizedBox(height: 20),
            Form(
              key: _form,
              child: Column(children: [
                campoTexto(_email, 'E-mail',
                    tipo: TextInputType.emailAddress, validar: validaEmail),
                campoTexto(_senha, 'Senha', senha: true, validar: obrigatorio),
              ]),
            ),
            if (_erro != null)
              Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child:
                      Text(_erro!, style: const TextStyle(color: Colors.red))),
            FilledButton(
              onPressed: _ocupado ? null : _entrar,
              child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Text(_ocupado ? 'Entrando...' : 'Entrar')),
            ),
            TextButton(
              onPressed: () => Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const CadastroScreen())),
              child: const Text('Ainda não tenho cadastro'),
            ),
          ],
        ),
      );
}

/* ---- Cadastro ---- */

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});
  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _form = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _email = TextEditingController();
  final _senha = TextEditingController();
  final _confirma = TextEditingController();
  String? _erro;
  bool _ocupado = false;

  Future<void> _cadastrar() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _ocupado = true;
      _erro = null;
    });
    final u = await Db.cadastrar(_nome.text, _email.text, _senha.text);
    if (!mounted) return;
    if (u == null) {
      setState(() {
        _ocupado = false;
        _erro =
            'Este e-mail já está cadastrado. Volte e escolha "Sim, quero entrar".';
      });
      return;
    }
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(usuario: u)),
        (r) => false);
  }

  @override
  void dispose() {
    _nome.dispose();
    _email.dispose();
    _senha.dispose();
    _confirma.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Center(child: Logo(tamanho: 64)),
            const SizedBox(height: 20),
            const Text('Criar cadastro',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            const Text('Só precisamos de algumas informações básicas.',
                style: TextStyle(color: cinza)),
            const SizedBox(height: 20),
            Form(
              key: _form,
              child: Column(children: [
                campoTexto(_nome, 'Nome', validar: obrigatorio),
                campoTexto(_email, 'E-mail',
                    tipo: TextInputType.emailAddress, validar: validaEmail),
                campoTexto(_senha, 'Senha', senha: true, validar: validaSenha),
                campoTexto(_confirma, 'Confirmar senha',
                    senha: true,
                    validar: (v) =>
                        v != _senha.text ? 'As senhas não conferem' : null),
              ]),
            ),
            if (_erro != null)
              Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child:
                      Text(_erro!, style: const TextStyle(color: Colors.red))),
            FilledButton(
              onPressed: _ocupado ? null : _cadastrar,
              child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Text(_ocupado ? 'Cadastrando...' : 'Cadastrar')),
            ),
            TextButton(
              onPressed: () => Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const LoginScreen())),
              child: const Text('Já tenho cadastro'),
            ),
          ],
        ),
      );
}

/* ---- Início: escolha da trilha ---- */

class HomeScreen extends StatefulWidget {
  final Usuario usuario;
  const HomeScreen({super.key, required this.usuario});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, Progresso> _prog = {};

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final r = await Db.carregar(widget.usuario.id);
    if (mounted) setState(() => _prog = r);
  }

  int _feitas(Certificacao c) =>
      c.etapas.where((e) => _prog[e.id]?.concluida ?? false).length;

  @override
  Widget build(BuildContext context) {
    final total =
        todasEtapas.where((e) => _prog[e.id]?.concluida ?? false).length;
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: azul,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ESTUDE ÁGIL',
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.w600)),
                          SizedBox(height: 4),
                          Text('Escolha sua trilha',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800)),
                        ],
                      ),
                      GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      PerfilScreen(usuario: widget.usuario)));
                          _carregar();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                              color: const Color(0x2EFFFFFF),
                              borderRadius: BorderRadius.circular(20)),
                          child: const Text('👤 Perfil',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: const Color(0x2EFFFFFF),
                        borderRadius: BorderRadius.circular(14)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Progresso geral · $total/${todasEtapas.length} etapas',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 13)),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: total / todasEtapas.length,
                            minHeight: 6,
                            color: Colors.white,
                            backgroundColor: const Color(0x40FFFFFF),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [for (final c in certificacoes) _cartao(c)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cartao(Certificacao c) {
    final feitas = _feitas(c);
    final frac = feitas / c.etapas.length;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: borda)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        CertificacaoScreen(usuario: widget.usuario, cert: c)));
            _carregar();
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: c.fundo, borderRadius: BorderRadius.circular(12)),
                  child: Text(c.emoji, style: const TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      selo(c),
                      const SizedBox(height: 6),
                      Text(c.nome,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(c.descricao,
                          style: const TextStyle(fontSize: 13, color: cinza)),
                      const SizedBox(height: 10),
                      barra(frac, c.cor),
                      const SizedBox(height: 4),
                      Text(
                          '$feitas/${c.etapas.length} etapas · ${(frac * 100).round()}%',
                          style: const TextStyle(fontSize: 11, color: cinza)),
                    ],
                  ),
                ),
                const Padding(
                    padding: EdgeInsets.only(top: 14),
                    child: Icon(Icons.chevron_right, color: cinza)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* ---- Etapas de uma certificação ---- */

class CertificacaoScreen extends StatefulWidget {
  final Usuario usuario;
  final Certificacao cert;
  const CertificacaoScreen(
      {super.key, required this.usuario, required this.cert});
  @override
  State<CertificacaoScreen> createState() => _CertificacaoScreenState();
}

class _CertificacaoScreenState extends State<CertificacaoScreen> {
  Map<String, Progresso> _prog = {};

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final r = await Db.carregar(widget.usuario.id);
    if (mounted) setState(() => _prog = r);
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.cert;
    return Scaffold(
      appBar: AppBar(
          title: Text(c.nome,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(c.descricao, style: const TextStyle(color: cinza)),
          const SizedBox(height: 16),
          for (final e in c.etapas) _cartaoEtapa(e),
          const SizedBox(height: 8),
          const Text(
              'Concluir uma etapa: confirmar a leitura e acertar pelo menos 2 de 3 perguntas. Não equivale à aprovação oficial.',
              style: TextStyle(fontSize: 12, color: cinza)),
        ],
      ),
    );
  }

  Widget _cartaoEtapa(Etapa e) {
    final pr = _prog[e.id] ?? const Progresso();
    final IconData icone;
    final Color cor;
    final String status;
    if (pr.concluida) {
      icone = Icons.check_circle;
      cor = Colors.green;
      status = 'Concluída · última tentativa ${pr.acertos ?? 0}/3';
    } else if (pr.acertos != null) {
      icone = Icons.refresh;
      cor = Colors.orange;
      status =
          'Revisar · ${pr.acertos}/3 acertos${pr.leitura ? '' : ' · leitura pendente'}';
    } else if (pr.leitura) {
      icone = Icons.menu_book;
      cor = Colors.blue;
      status = 'Leitura confirmada · quiz pendente';
    } else {
      icone = Icons.radio_button_unchecked;
      cor = Colors.grey;
      status = 'Pendente';
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: borda)),
        child: ListTile(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          leading: Icon(icone, color: cor, size: 32),
          title: Text(e.titulo,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(status),
          trailing: const Icon(Icons.chevron_right),
          onTap: () async {
            await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        ConteudoScreen(usuario: widget.usuario, etapa: e)));
            _carregar();
          },
        ),
      ),
    );
  }
}

/* ---- Conteúdo ---- */

class ConteudoScreen extends StatefulWidget {
  final Usuario usuario;
  final Etapa etapa;
  const ConteudoScreen({super.key, required this.usuario, required this.etapa});
  @override
  State<ConteudoScreen> createState() => _ConteudoScreenState();
}

class _ConteudoScreenState extends State<ConteudoScreen> {
  bool _lido = false;

  @override
  void initState() {
    super.initState();
    Db.leituraConfirmada(widget.usuario.id, widget.etapa.id).then((v) {
      if (mounted) setState(() => _lido = v);
    });
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.etapa;
    return Scaffold(
      appBar: AppBar(
          title: Text(e.titulo,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Text(e.resumo,
                  style: const TextStyle(fontSize: 16, height: 1.5)),
            ),
          ),
          if (e.guiaPagina != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.menu_book),
                  label: Text('Consultar o Guia do Scrum (p. ${e.guiaPagina})'),
                  onPressed: () => abrirGuia(context, e.guiaPagina!),
                ),
              ),
            ),
          CheckboxListTile(
            value: _lido,
            title: const Text('Li e entendi este conteúdo'),
            onChanged: (v) async {
              setState(() => _lido = v ?? false);
              await Db.confirmarLeitura(widget.usuario.id, e.id, _lido);
            },
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.quiz),
                label: const Text('Fazer quiz'),
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            QuizScreen(usuario: widget.usuario, etapa: e))),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ---- Quiz ---- */

class QuizScreen extends StatefulWidget {
  final Usuario usuario;
  final Etapa etapa;
  const QuizScreen({super.key, required this.usuario, required this.etapa});
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _i = 0;
  int? _escolha;
  bool _salvando = false;
  late final List<Pergunta> _perguntas;
  final List<int> _respostas = [];

  // Guarda, durante a sessão, quais perguntas saíram na última tentativa de
  // cada etapa, para que "Refazer quiz" traga perguntas diferentes.
  static final Map<String, Set<int>> _ultimas = {};

  // Embaralha as alternativas e recalcula qual é a correta.
  Pergunta _embaralhar(Pergunta q) {
    final ordem = List<int>.generate(q.alternativas.length, (i) => i)
      ..shuffle();
    return Pergunta(q.texto, [for (final i in ordem) q.alternativas[i]],
        ordem.indexOf(q.correta), q.explicacao, q.pagina);
  }

  @override
  void initState() {
    super.initState();
    final banco = widget.etapa.perguntas;
    final ultimas = _ultimas[widget.etapa.id] ?? <int>{};
    final novas = [
      for (var i = 0; i < banco.length; i++)
        if (!ultimas.contains(i)) i
    ]..shuffle();
    final antigas = ultimas.toList()..shuffle();
    final escolhidas = [...novas, ...antigas].take(porTentativa).toList()
      ..shuffle();
    _ultimas[widget.etapa.id] = escolhidas.toSet();
    _perguntas = [for (final i in escolhidas) _embaralhar(banco[i])];
  }

  Pergunta get _pergunta => _perguntas[_i];

  Future<void> _avancar() async {
    if (_escolha == null || _salvando) return;
    if (_i < _perguntas.length - 1) {
      setState(() {
        _respostas.add(_escolha!);
        _i++;
        _escolha = null;
      });
      return;
    }
    setState(() => _salvando = true);
    final respostas = List<int>.unmodifiable([..._respostas, _escolha!]);
    final total = _perguntas.length;
    var acertos = 0;
    for (var k = 0; k < total; k++) {
      if (respostas[k] == _perguntas[k].correta) acertos++;
    }
    try {
      final uid = widget.usuario.id;
      final lido = await Db.leituraConfirmada(uid, widget.etapa.id);
      await Db.salvarTentativa(
          uid, widget.etapa.id, acertos, total, lido && acertos >= 2);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) => ResultadoScreen(
                  usuario: widget.usuario,
                  etapa: widget.etapa,
                  acertos: acertos,
                  leitura: lido,
                  perguntas: List<Pergunta>.unmodifiable(_perguntas),
                  respostas: respostas,
                )),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _salvando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Não foi possível salvar. Tente finalizar novamente.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _perguntas.length;
    return Scaffold(
      appBar: AppBar(title: Text('Pergunta ${_i + 1} de $total')),
      body: SafeArea(
          child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          barra((_i + 1) / total, azul),
          const SizedBox(height: 12),
          const Text('O gabarito será exibido ao finalizar esta etapa.',
              style: TextStyle(color: cinza, fontSize: 13)),
          const SizedBox(height: 20),
          Text(_pergunta.texto, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          for (var k = 0; k < _pergunta.alternativas.length; k++)
            _alternativa(k),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _escolha == null || _salvando ? null : _avancar,
            child: Text(_salvando
                ? 'Salvando...'
                : (_i < total - 1 ? 'Próxima pergunta' : 'Finalizar etapa')),
          ),
        ],
      )),
    );
  }

  Widget _alternativa(int k) {
    final selecionada = _escolha == k;
    return Card(
      color: selecionada ? const Color(0xFFE8F0FC) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: selecionada ? azul : borda),
      ),
      child: ListTile(
        leading: Icon(
            selecionada
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked,
            color: selecionada ? azul : cinza),
        title: Text(_pergunta.alternativas[k]),
        selected: selecionada,
        selectedColor: azul,
        onTap: _salvando ? null : () => setState(() => _escolha = k),
      ),
    );
  }
}

/* ---- Resultado e gabarito da tentativa ---- */

class ResultadoScreen extends StatelessWidget {
  final Usuario usuario;
  final Etapa etapa;
  final int acertos;
  final bool leitura;
  final List<Pergunta> perguntas;
  final List<int> respostas;
  const ResultadoScreen(
      {super.key,
      required this.usuario,
      required this.etapa,
      required this.acertos,
      required this.leitura,
      required this.perguntas,
      required this.respostas});

  @override
  Widget build(BuildContext context) {
    final total = perguntas.length;
    final concluida = leitura && acertos >= 2;
    final situacao = concluida
        ? 'Etapa concluída!'
        : !leitura
            ? 'Confirme a leitura do conteúdo para concluir a etapa.'
            : 'Revise o conteúdo e tente novamente (mínimo de 2 acertos).';
    return Scaffold(
      appBar: AppBar(
          title: const Text('Resultado'), automaticallyImplyLeading: false),
      body: SafeArea(
          child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Icon(concluida ? Icons.emoji_events : Icons.menu_book,
              size: 72, color: concluida ? Colors.amber : Colors.blueGrey),
          const SizedBox(height: 16),
          Text('$acertos de $total acertos',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(situacao, textAlign: TextAlign.center),
          ..._reveja(context),
          rotulo('GABARITO DA ETAPA'),
          const SizedBox(height: 12),
          for (var k = 0; k < total; k++) _correcao(context, k),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        QuizScreen(usuario: usuario, etapa: etapa))),
            child: const Text('Refazer quiz'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () {
              var n = 0;
              Navigator.popUntil(context, (r) => n++ >= 2);
            },
            child: const Text('Voltar à trilha'),
          ),
        ],
      )),
    );
  }

  List<Widget> _reveja(BuildContext context) {
    final paginas = <int>{
      for (var k = 0; k < perguntas.length; k++)
        if (respostas[k] != perguntas[k].correta && perguntas[k].pagina != null)
          perguntas[k].pagina!
    }.toList()
      ..sort();
    if (paginas.isEmpty) return const [];
    return [
      rotulo('REVEJA NO GUIA DO SCRUM'),
      const Text('Você errou perguntas ligadas a estas páginas:',
          style: TextStyle(color: cinza)),
      const SizedBox(height: 10),
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (final n in paginas)
          ActionChip(
            avatar: const Icon(Icons.menu_book, size: 18),
            label: Text('Página $n'),
            onPressed: () => abrirGuia(context, n),
          ),
      ]),
    ];
  }

  Widget _correcao(BuildContext context, int k) {
    final pg = perguntas[k];
    final acertou = respostas[k] == pg.correta;
    return Card(
      color: acertou ? Colors.green.shade50 : Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Pergunta ${k + 1} · ${acertou ? "Correta" : "Incorreta"}',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color:
                      acertou ? Colors.green.shade800 : Colors.red.shade800)),
          const SizedBox(height: 8),
          Text(pg.texto, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('Sua resposta: ${pg.alternativas[respostas[k]]}'),
          Text('Resposta correta: ${pg.alternativas[pg.correta]}'),
          const SizedBox(height: 8),
          Text(pg.explicacao,
              style: const TextStyle(color: cinza, height: 1.4)),
          if (!acertou && pg.pagina != null)
            TextButton.icon(
              onPressed: () => abrirGuia(context, pg.pagina!),
              icon: const Icon(Icons.menu_book),
              label: Text('Reler no Guia · página ${pg.pagina}'),
            ),
        ]),
      ),
    );
  }
}

/* ---- Perfil ---- */

class PerfilScreen extends StatefulWidget {
  final Usuario usuario;
  const PerfilScreen({super.key, required this.usuario});
  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  Map<String, Progresso> _prog = {};
  List<Map<String, Object?>> _hist = [];

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final a = await Db.carregar(widget.usuario.id);
    final h = await Db.historico(widget.usuario.id);
    if (mounted) {
      setState(() {
        _prog = a;
        _hist = h;
      });
    }
  }

  Future<void> _resetar() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Resetar progresso?'),
        content:
            const Text('Isso apaga leituras, acertos e histórico desta conta.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Resetar')),
        ],
      ),
    );
    if (ok != true) return;
    await Db.resetar(widget.usuario.id);
    _carregar();
  }

  Future<void> _sair() async {
    await Db.definirSessao(null);
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const BemVindoScreen()),
        (r) => false);
  }

  Widget _stat(String valor, String legenda) => Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
              color: fundoSuave, borderRadius: BorderRadius.circular(14)),
          child: Column(children: [
            Text(valor,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w800, color: azul)),
            const SizedBox(height: 2),
            Text(legenda, style: const TextStyle(fontSize: 12, color: cinza)),
          ]),
        ),
      );

  Widget _cartaoCert(Certificacao c) {
    final feitas =
        c.etapas.where((e) => _prog[e.id]?.concluida ?? false).length;
    final frac = feitas / c.etapas.length;
    var questoes = 0;
    for (final e in c.etapas) {
      questoes += _prog[e.id]?.total ?? 0;
    }
    final maxQ = c.etapas.length * porTentativa;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          border: Border.all(color: borda),
          borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(c.emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            selo(c),
            const Spacer(),
            Text('${(frac * 100).round()}%',
                style: TextStyle(color: c.cor, fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 10),
          barra(frac, c.cor),
          const SizedBox(height: 6),
          Text('$feitas/${c.etapas.length} etapas · $questoes/$maxQ questões',
              style: const TextStyle(fontSize: 12, color: cinza)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final etapasOk =
        todasEtapas.where((e) => _prog[e.id]?.concluida ?? false).length;
    var acertos = 0, questoes = 0;
    for (final pr in _prog.values) {
      acertos += pr.acertos ?? 0;
      questoes += pr.total ?? 0;
    }
    final pct = questoes == 0 ? 0 : (acertos * 100 / questoes).round();
    final totalQ = todasEtapas.length * porTentativa;

    return Scaffold(
      appBar: AppBar(
          title: const Text('👤 Meu Perfil',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(widget.usuario.nome,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          Text(widget.usuario.email, style: const TextStyle(color: cinza)),
          const SizedBox(height: 14),
          Row(children: [
            _stat('$etapasOk/${todasEtapas.length}', 'Etapas'),
            _stat('$pct%', 'Acertos'),
            _stat('$questoes/$totalQ', 'Questões'),
          ]),
          rotulo('CERTIFICAÇÕES'),
          for (final c in certificacoes) _cartaoCert(c),
          rotulo('HISTÓRICO DE QUIZZES'),
          if (_hist.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                  color: fundoSuave, borderRadius: BorderRadius.circular(14)),
              child: const Text('Nenhum quiz realizado ainda.',
                  textAlign: TextAlign.center, style: TextStyle(color: cinza)),
            )
          else
            for (final h in _hist) _linhaHistorico(h),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () => abrirGuia(context, 1),
            icon: const Icon(Icons.menu_book),
            label: const Text('Abrir o Guia do Scrum 2020'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red.shade700,
              side: BorderSide(color: Colors.red.shade400),
              padding: const EdgeInsets.all(14),
              shape: const StadiumBorder(),
            ),
            onPressed: _resetar,
            child: const Text('Resetar progresso'),
          ),
          TextButton(onPressed: _sair, child: const Text('Sair da conta')),
          const SizedBox(height: 8),
          const Text('Não emite certificação oficial · fins educacionais',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: cinza)),
        ],
      ),
    );
  }

  Widget _linhaHistorico(Map<String, Object?> h) {
    final id = h['etapa_id'] as String;
    final ac = h['acertos'];
    final tt = h['total'];
    final data = dataCurta(h['data'] as String);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: fundoSuave, borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        Expanded(
            child: Text('${certDe(id).sigla} · ${etapaPorId(id).titulo}',
                style: const TextStyle(fontSize: 13))),
        Text('$ac/$tt · $data',
            style: const TextStyle(fontSize: 12, color: cinza)),
      ]),
    );
  }
}

/* ---- Guia do Scrum (páginas do material de estudo) ---- */

void abrirGuia(BuildContext context, int pagina) {
  Navigator.push(context,
      MaterialPageRoute(builder: (_) => GuiaScreen(paginaInicial: pagina)));
}

class GuiaScreen extends StatefulWidget {
  final int paginaInicial;
  const GuiaScreen({super.key, this.paginaInicial = 1});
  @override
  State<GuiaScreen> createState() => _GuiaScreenState();
}

class _GuiaScreenState extends State<GuiaScreen> {
  late int _pag = widget.paginaInicial.clamp(1, totalPaginasGuia).toInt();

  void _ir(int n) =>
      setState(() => _pag = n.clamp(1, totalPaginasGuia).toInt());

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            title: Text('Guia do Scrum · página $_pag de $totalPaginasGuia',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700))),
        body: Column(children: [
          Expanded(
            child: InteractiveViewer(
              key: ValueKey(_pag),
              minScale: 1,
              maxScale: 5,
              child: Center(
                child: Image.asset(
                  'assets/guia/$_pag.jpeg',
                  fit: BoxFit.contain,
                  errorBuilder: (ctx, err, st) => const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                        'Imagem da página não encontrada. Confira a pasta assets/guia e o pubspec.yaml.',
                        textAlign: TextAlign.center),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Row(children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pag > 1 ? () => _ir(_pag - 1) : null,
                      icon: const Icon(Icons.chevron_left),
                      label: const Text('Anterior'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed:
                          _pag < totalPaginasGuia ? () => _ir(_pag + 1) : null,
                      icon: const Icon(Icons.chevron_right),
                      label: const Text('Próxima'),
                    ),
                  ),
                ]),
                const SizedBox(height: 6),
                const Text(
                    'Scrum Guide 2020 · Ken Schwaber e Jeff Sutherland · CC BY-SA 4.0',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: cinza)),
              ]),
            ),
          ),
        ]),
      );
}
