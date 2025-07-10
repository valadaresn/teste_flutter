import '../log_model.dart';

/// **FilterState** - Estado dos filtros aplicados na tela de logs
///
/// Representa todos os filtros que podem ser aplicados:
/// - Período (hoje, semana, mês, etc.)
/// - Projetos selecionados
/// - Listas selecionadas
/// - Status dos logs
/// - Range customizado de datas
class FilterState {
  final LogFilterPeriod period;
  final Set<String> selectedProjectIds;
  final Set<String> selectedListIds;
  final LogFilterStatus status;
  final DateTime? customStartDate;
  final DateTime? customEndDate;

  const FilterState({
    this.period = LogFilterPeriod.today,
    this.selectedProjectIds = const {},
    this.selectedListIds = const {},
    this.status = LogFilterStatus.all,
    this.customStartDate,
    this.customEndDate,
  });

  /// Cria uma cópia do estado atual com as modificações especificadas
  FilterState copyWith({
    LogFilterPeriod? period,
    Set<String>? selectedProjectIds,
    Set<String>? selectedListIds,
    LogFilterStatus? status,
    DateTime? customStartDate,
    DateTime? customEndDate,
  }) {
    return FilterState(
      period: period ?? this.period,
      selectedProjectIds: selectedProjectIds ?? this.selectedProjectIds,
      selectedListIds: selectedListIds ?? this.selectedListIds,
      status: status ?? this.status,
      customStartDate: customStartDate ?? this.customStartDate,
      customEndDate: customEndDate ?? this.customEndDate,
    );
  }

  /// Verifica se algum filtro está aplicado (diferente do padrão)
  bool get hasActiveFilters {
    return period != LogFilterPeriod.today ||
        selectedProjectIds.isNotEmpty ||
        selectedListIds.isNotEmpty ||
        status != LogFilterStatus.all ||
        customStartDate != null ||
        customEndDate != null;
  }

  /// Limpa todos os filtros, voltando ao estado padrão
  FilterState clearAll() {
    return const FilterState();
  }

  /// Retorna o range de datas baseado no período selecionado
  DateTimeRange getDateRange() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (period) {
      case LogFilterPeriod.today:
        return DateTimeRange(
          start: today,
          end: today.add(const Duration(days: 1)),
        );

      case LogFilterPeriod.yesterday:
        final yesterday = today.subtract(const Duration(days: 1));
        return DateTimeRange(start: yesterday, end: today);

      case LogFilterPeriod.week:
        // Início da semana (segunda-feira)
        final startOfWeek = today.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 7));
        return DateTimeRange(start: startOfWeek, end: endOfWeek);

      case LogFilterPeriod.month:
        // Início do mês atual
        final startOfMonth = DateTime(now.year, now.month, 1);
        final endOfMonth = DateTime(now.year, now.month + 1, 1);
        return DateTimeRange(start: startOfMonth, end: endOfMonth);

      case LogFilterPeriod.custom:
        if (customStartDate != null && customEndDate != null) {
          return DateTimeRange(
            start: customStartDate!,
            end: customEndDate!.add(const Duration(days: 1)),
          );
        }
        // Fallback para hoje se custom não está configurado
        return DateTimeRange(
          start: today,
          end: today.add(const Duration(days: 1)),
        );
    }
  }

  /// Converte para Map para serialização
  Map<String, dynamic> toMap() {
    return {
      'period': period.index,
      'selectedProjectIds': selectedProjectIds.toList(),
      'selectedListIds': selectedListIds.toList(),
      'status': status.index,
      'customStartDate': customStartDate?.toIso8601String(),
      'customEndDate': customEndDate?.toIso8601String(),
    };
  }

  /// Cria FilterState a partir de Map
  factory FilterState.fromMap(Map<String, dynamic> map) {
    return FilterState(
      period: LogFilterPeriod.values[map['period'] ?? 0],
      selectedProjectIds: Set<String>.from(map['selectedProjectIds'] ?? []),
      selectedListIds: Set<String>.from(map['selectedListIds'] ?? []),
      status: LogFilterStatus.values[map['status'] ?? 0],
      customStartDate:
          map['customStartDate'] != null
              ? DateTime.parse(map['customStartDate'])
              : null,
      customEndDate:
          map['customEndDate'] != null
              ? DateTime.parse(map['customEndDate'])
              : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FilterState &&
        other.period == period &&
        other.selectedProjectIds.length == selectedProjectIds.length &&
        other.selectedProjectIds.every(selectedProjectIds.contains) &&
        other.selectedListIds.length == selectedListIds.length &&
        other.selectedListIds.every(selectedListIds.contains) &&
        other.status == status &&
        other.customStartDate == customStartDate &&
        other.customEndDate == customEndDate;
  }

  @override
  int get hashCode {
    return Object.hash(
      period,
      selectedProjectIds,
      selectedListIds,
      status,
      customStartDate,
      customEndDate,
    );
  }

  @override
  String toString() {
    return 'FilterState(period: $period, projects: ${selectedProjectIds.length}, lists: ${selectedListIds.length}, status: $status)';
  }
}

/// **DateTimeRange** - Helper class para range de datas
class DateTimeRange {
  final DateTime start;
  final DateTime end;

  const DateTimeRange({required this.start, required this.end});

  Duration get duration => end.difference(start);

  @override
  String toString() => 'DateTimeRange($start - $end)';
}
