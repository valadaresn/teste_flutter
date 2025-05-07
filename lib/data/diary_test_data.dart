import '../models/diary_entry.dart';

// Função auxiliar para criar data com horário específico
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
  // Hoje
  DiaryEntry(
    id: '1',
    title: 'Reunião de Planejamento',
    content:
        'Excelente reunião hoje! Definimos as principais metas do próximo trimestre.',
    dateTime: DateTime.now().copyWith(hour: 15, minute: 30),
    mood: '😊',
    tags: ['trabalho', 'planejamento'],
    isFavorite: true,
  ),
  DiaryEntry(
    id: '2',
    content: 'Preciso revisar aquele bug no módulo de notificações.',
    dateTime: DateTime.now().copyWith(hour: 10, minute: 15),
    mood: '🤔',
    tags: ['trabalho', 'bugs'],
  ),

  // Ontem
  DiaryEntry(
    id: '3',
    title: 'Avanço no Projeto',
    content:
        'Consegui implementar todas as funcionalidades planejadas para hoje.',
    dateTime: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
    mood: '😊',
    tags: ['trabalho', 'conquistas'],
  ),

  // Esta semana
  DiaryEntry(
    id: '4',
    content: 'Dia muito corrido. Várias reuniões e pouco tempo para codar.',
    dateTime: DateTime.now().subtract(const Duration(days: 3)),
    mood: '😐',
    tags: ['trabalho'],
  ),
  DiaryEntry(
    id: '5',
    title: 'Novo Framework',
    content: 'Comecei a estudar um framework novo hoje. Parece promissor!',
    dateTime: DateTime.now().subtract(const Duration(days: 4, hours: 5)),
    mood: '🤔',
    tags: ['estudo', 'tecnologia'],
    isFavorite: true,
  ),

  // Semana passada
  DiaryEntry(
    id: '6',
    title: 'Apresentação do Projeto',
    content:
        'A apresentação foi um sucesso! O cliente adorou as novas features.',
    dateTime: DateTime.now().subtract(const Duration(days: 8)),
    mood: '😊',
    tags: ['trabalho', 'apresentação', 'cliente'],
    isFavorite: true,
  ),
  DiaryEntry(
    id: '7',
    content:
        'Problemas com merge conflicts hoje. Git pode ser frustrante às vezes.',
    dateTime: DateTime.now().subtract(const Duration(days: 10)),
    mood: '😡',
    tags: ['trabalho', 'git'],
  ),

  // Mais antigos este mês
  DiaryEntry(
    id: '8',
    title: 'Feedback da Equipe',
    content:
        'Reunião de feedback trimestral. Muitos pontos positivos destacados.',
    dateTime: DateTime.now().subtract(const Duration(days: 15)),
    mood: '😊',
    tags: ['trabalho', 'feedback'],
  ),
  DiaryEntry(
    id: '9',
    content: 'Não dormi bem essa noite, muita coisa na cabeça sobre o projeto.',
    dateTime: DateTime.now().subtract(const Duration(days: 18)),
    mood: '😴',
    tags: ['pessoal', 'sono'],
  ),

  // Mês passado
  DiaryEntry(
    id: '10',
    title: 'Deploy em Produção',
    content: 'Grande deploy hoje. Tudo correu bem, sem problemas.',
    dateTime: _createDate(2025, 3, 25, 17, 30),
    mood: '😊',
    tags: ['trabalho', 'deploy', 'produção'],
    isFavorite: true,
  ),
  DiaryEntry(
    id: '11',
    content:
        'Dia difícil com o servidor de produção. Muitos problemas inesperados.',
    dateTime: _createDate(2025, 3, 15, 14, 20),
    mood: '😡',
    tags: ['trabalho', 'problemas', 'servidor'],
  ),
  DiaryEntry(
    id: '12',
    title: 'Workshop de Arquitetura',
    content:
        'Participei de um workshop incrível sobre arquitetura de software.',
    dateTime: _createDate(2025, 3, 10, 9, 0),
    mood: '🤔',
    tags: ['estudo', 'arquitetura', 'workshop'],
  ),

  // Abril 2025 - 100 entradas
  DiaryEntry(
    id: 'abril_1',
    title: 'Reunião de Planejamento Q2',
    content:
        'Iniciamos o segundo trimestre com grande planejamento estratégico.',
    dateTime: _createDate(2025, 4, 30, 15, 30),
    mood: '😊',
    tags: ['trabalho', 'planejamento', 'Q2'],
  ),
  DiaryEntry(
    id: 'abril_2',
    content: 'Sprint review mostrou ótimos resultados da equipe.',
    dateTime: _createDate(2025, 4, 30, 11, 0),
    mood: '😊',
    tags: ['trabalho', 'sprint', 'review'],
  ),
  ...List.generate(98, (index) {
    final day = 30 - (index ~/ 4); // Distribui 4 entradas por dia
    final hour = 9 + (index % 8); // Varia o horário entre 9 e 16
    final moodOptions = ['😊', '😐', '😢', '😡', '🤔', '😴'];
    final tagOptions = [
      ['trabalho', 'desenvolvimento'],
      ['pessoal', 'reflexão'],
      ['estudo', 'aprendizado'],
      ['projeto', 'milestone'],
      ['saúde', 'exercício'],
      ['família', 'evento'],
      ['reunião', 'planejamento'],
      ['código', 'review'],
    ];

    return DiaryEntry(
      id: 'abril_${index + 3}',
      title: index % 3 == 0 ? 'Entrada ${index + 3} de Abril' : null,
      content:
          'Conteúdo da entrada ${index + 3} do dia $day de abril de 2025. ' +
          [
            'Avançamos bem no desenvolvimento do projeto.',
            'Resolvemos vários bugs pendentes.',
            'Participei de uma excelente reunião de equipe.',
            'Implementei novas funcionalidades.',
            'Code review do novo módulo.',
            'Planejamento do próximo sprint.',
            'Estudando novas tecnologias.',
            'Documentação do projeto atualizada.',
          ][index % 8],
      dateTime: _createDate(2025, 4, day, hour, index % 60),
      mood: moodOptions[index % moodOptions.length],
      tags: tagOptions[index % tagOptions.length],
      isFavorite: index % 10 == 0,
    );
  }),

  // Meses anteriores
  DiaryEntry(
    id: '13',
    title: 'Início do Projeto',
    content: 'Começamos o novo projeto hoje. Muitas ideias interessantes!',
    dateTime: _createDate(2025, 2, 15, 10, 0),
    mood: '😊',
    tags: ['trabalho', 'início', 'projeto'],
    isFavorite: true,
  ),
  DiaryEntry(
    id: '14',
    content:
        'Revisão de código o dia todo. Encontramos vários pontos de melhoria.',
    dateTime: _createDate(2025, 2, 8, 16, 45),
    mood: '🤔',
    tags: ['trabalho', 'código', 'revisão'],
  ),

  // Janeiro
  DiaryEntry(
    id: '15',
    title: 'Metas do Ano',
    content:
        'Definindo as metas profissionais para 2025. Muitos desafios pela frente!',
    dateTime: _createDate(2025, 1, 5, 11, 0),
    mood: '😊',
    tags: ['trabalho', 'metas', 'planejamento'],
  ),
  DiaryEntry(
    id: '16',
    content: 'Primeiro dia após as férias. Ainda me adaptando ao ritmo.',
    dateTime: _createDate(2025, 1, 2, 9, 0),
    mood: '😴',
    tags: ['trabalho', 'retorno'],
  ),
];
