enum DiaryViewType {
  daily('Hoje'),
  weekly('Semana'),
  monthly('Mês'),
  yearly('Ano'),
  mood('Humor');

  final String label;
  const DiaryViewType(this.label);
}
