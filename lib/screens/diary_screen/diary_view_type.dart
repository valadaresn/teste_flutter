enum DiaryViewType {
  daily('Hoje'),
  monthly('Por Mês'),
  mood('Humor'),
  tags('Tags'),
  favorites('Favoritos');

  final String label;
  const DiaryViewType(this.label);
}
