import '../models/diary_entry.dart';

// Função auxiliar para criar data
DateTime _createDate(
  int year,
  int month,
  int day, [
  int hour = 12,
  int minute = 0,
]) {
  return DateTime(year, month, day, hour, minute);
}

final List<DiaryEntry> testEntries = [
  // Entradas de Hoje
  DiaryEntry(
    id: '1',
    title: 'Reunião Produtiva',
    content:
        'A reunião de hoje foi muito produtiva. Conseguimos definir todos os próximos passos do projeto.',
    dateTime: DateTime.now().copyWith(hour: 14, minute: 30),
    mood: '😊',
    tags: ['trabalho', 'reunião'],
  ),
  DiaryEntry(
    id: '2',
    content: 'Preciso revisar aquele bug estranho que apareceu hoje de manhã.',
    dateTime: DateTime.now().copyWith(hour: 9, minute: 15),
    mood: '🤔',
    tags: ['trabalho', 'bugs'],
  ),

  // Entradas desta semana
  DiaryEntry(
    id: '3',
    title: 'Bug Resolvido!',
    content:
        'Finalmente consegui resolver aquele bug que estava me incomodando há dias.',
    dateTime: DateTime.now().subtract(const Duration(days: 2)),
    mood: '😊',
    tags: ['trabalho', 'conquistas'],
  ),
  DiaryEntry(
    id: '4',
    content: 'Dia cansativo hoje. Muitas reuniões e pouco código.',
    dateTime: DateTime.now().subtract(const Duration(days: 3)),
    mood: '😐',
    tags: ['trabalho'],
  ),

  // Entradas da semana passada
  DiaryEntry(
    id: '5',
    title: 'Início do Novo Projeto',
    content:
        'Começamos o novo projeto hoje. Muitas ideias interessantes surgiram na reunião de kickoff.',
    dateTime: DateTime.now().subtract(const Duration(days: 8)),
    mood: '😊',
    tags: ['trabalho', 'projetos'],
  ),
  DiaryEntry(
    id: '6',
    content:
        'Dia difícil com o Git. Tive que resolver vários conflitos de merge.',
    dateTime: DateTime.now().subtract(const Duration(days: 10)),
    mood: '😡',
    tags: ['trabalho', 'git'],
  ),

  // Entradas deste mês (dias anteriores)
  DiaryEntry(
    id: '7',
    title: 'Feedbacks do Cliente',
    content:
        'Recebemos feedbacks muito positivos do cliente sobre a última entrega.',
    dateTime: DateTime.now().subtract(const Duration(days: 15)),
    mood: '😊',
    tags: ['trabalho', 'cliente'],
  ),
  DiaryEntry(
    id: '8',
    content:
        'Trabalhando no novo feature de notificações. Está mais complexo do que imaginei.',
    dateTime: DateTime.now().subtract(const Duration(days: 20)),
    mood: '🤔',
    tags: ['trabalho', 'desenvolvimento'],
  ),

  // Entradas do mês passado
  DiaryEntry(
    id: '9',
    title: 'Refatoração Concluída',
    content:
        'Finalizei a grande refatoração do módulo principal. O código está muito mais limpo agora.',
    dateTime: _createDate(2025, 3, 15, 16, 30),
    mood: '😊',
    tags: ['trabalho', 'refatoração'],
  ),
  DiaryEntry(
    id: '10',
    content:
        'Problemas com o servidor de produção hoje. Foi um dia estressante.',
    dateTime: _createDate(2025, 3, 10, 18, 45),
    mood: '😡',
    tags: ['trabalho', 'produção'],
  ),

  // Entradas de dois meses atrás
  DiaryEntry(
    id: '11',
    title: 'Novo Framework',
    content: 'Começamos a estudar um novo framework hoje. Parece promissor!',
    dateTime: _createDate(2025, 2, 20, 11, 0),
    mood: '🤔',
    tags: ['estudo', 'tecnologia'],
  ),
  DiaryEntry(
    id: '12',
    content:
        'Participei de um workshop muito interessante sobre arquitetura de software.',
    dateTime: _createDate(2025, 2, 15, 14, 20),
    mood: '😊',
    tags: ['estudo', 'workshop'],
  ),

  // Entradas do início do ano
  DiaryEntry(
    id: '13',
    title: 'Metas do Ano',
    content:
        'Definindo as metas de desenvolvimento para este ano. Muitos desafios pela frente!',
    dateTime: _createDate(2025, 1, 5, 9, 0),
    mood: '😊',
    tags: ['planejamento', 'metas'],
  ),
  DiaryEntry(
    id: '14',
    content:
        'Primeiro dia de trabalho do ano. Ainda me adaptando depois das férias.',
    dateTime: _createDate(2025, 1, 2, 8, 30),
    mood: '😴',
    tags: ['trabalho', 'adaptação'],
  ),

  // Entradas do ano passado
  DiaryEntry(
    id: '15',
    title: 'Retrospectiva 2024',
    content:
        'Fazendo a retrospectiva do ano. Foi um ano de muito aprendizado e crescimento.',
    dateTime: _createDate(2024, 12, 28, 15, 0),
    mood: '😊',
    tags: ['retrospectiva', 'reflexão'],
  ),
  DiaryEntry(
    id: '16',
    content: 'Último deploy do ano! Tudo funcionando perfeitamente.',
    dateTime: _createDate(2024, 12, 20, 17, 30),
    mood: '😊',
    tags: ['trabalho', 'deploy'],
  ),
];
